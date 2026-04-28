#!/usr/bin/env bash
set -euo pipefail

: "${MNEMOSPARK_API_BASE_URL:?set MNEMOSPARK_API_BASE_URL}"
: "${FILE_PATH:?set FILE_PATH}"
: "${CONTENT_TYPE:?set CONTENT_TYPE}"
: "${TIER:?set TIER}"
: "${PAYMENT_HEADER:?set PAYMENT_HEADER}"
: "${PAYMENT_VALUE:?set PAYMENT_VALUE}"

# This helper assumes PAYMENT_VALUE is already the exact base64(JSON(payment_payload))
# returned by a real x402 client library. Do not hand-normalize the payload here.
# For a complete reference that performs the 402 probe, generates the x402 payload,
# polls /upload/complete on 202, and verifies read APIs, see:
#   examples/upload_and_share_python.py

filename="$(basename "$FILE_PATH")"
size_bytes="$(wc -c < "$FILE_PATH" | tr -d ' ')"

create_json="$(jq -n \
  --arg filename "$filename" \
  --arg contentType "$CONTENT_TYPE" \
  --arg tier "$TIER" \
  --argjson size_bytes "$size_bytes" \
  '{filename:$filename, contentType:$contentType, tier:$tier, size_bytes:$size_bytes}')"

create_deadline=$((SECONDS + 60))
create_resp=''
while :; do
  create_resp_with_status="$(curl -sS \
    -w $'\n%{http_code}' \
    -X POST "${MNEMOSPARK_API_BASE_URL}/api/mnemospark-lite/upload" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -H "${PAYMENT_HEADER}: ${PAYMENT_VALUE}" \
    -d "$create_json")"
  create_http_status="${create_resp_with_status##*$'\n'}"
  create_resp="${create_resp_with_status%$'\n'*}"

  if [[ "$create_http_status" == "200" ]]; then
    break
  fi
  if [[ "$create_http_status" != "202" ]]; then
    echo "Create upload slot failed: status=$create_http_status body=$create_resp" >&2
    exit 1
  fi
  if (( SECONDS >= create_deadline )); then
    echo "Timed out waiting for paid /upload to settle" >&2
    exit 1
  fi
  sleep 2
done

upload_url="$(printf '%s' "$create_resp" | jq -r '.data.uploadUrl')"
upload_id="$(printf '%s' "$create_resp" | jq -r '.data.uploadId')"
completion_token="$(printf '%s' "$create_resp" | jq -r '.data.completion_token')"
list_scope_bearer="$(printf '%s' "$create_resp" | jq -r '.data.list_scope_bearer')"
payment_status="$(printf '%s' "$create_resp" | jq -r '.metadata.payment.status // empty')"
payment_tx_hash="$(printf '%s' "$create_resp" | jq -r '.metadata.payment.transactionHash // empty')"

curl -sS -T "$FILE_PATH" \
  -H "Content-Type: ${CONTENT_TYPE}" \
  "$upload_url" >/dev/null

complete_json="$(jq -n \
  --arg uploadId "$upload_id" \
  --arg completion_token "$completion_token" \
  '{uploadId:$uploadId, completion_token:$completion_token}')"

deadline=$((SECONDS + 45))
complete_resp=''
while :; do
  complete_resp_with_status="$(curl -sS \
    -w $'\n%{http_code}' \
    -X POST "${MNEMOSPARK_API_BASE_URL}/api/mnemospark-lite/upload/complete" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -d "$complete_json")"
  complete_http_status="${complete_resp_with_status##*$'\n'}"
  complete_resp="${complete_resp_with_status%$'\n'*}"

  if [[ "$complete_http_status" == "200" ]]; then
    public_url="$(printf '%s' "$complete_resp" | jq -r '.data.upload.publicUrl // empty')"
    if [[ -n "$public_url" ]]; then
      break
    fi
    echo "Complete response missing publicUrl: body=$complete_resp" >&2
    exit 1
  fi
  if [[ "$complete_http_status" != "202" ]]; then
    echo "Complete failed: status=$complete_http_status body=$complete_resp" >&2
    exit 1
  fi
  if (( SECONDS >= deadline )); then
    echo "Timed out waiting for /upload/complete to mint a URL" >&2
    exit 1
  fi
  sleep 2
done

jq -n \
  --arg uploadId "$upload_id" \
  --arg bearer "$list_scope_bearer" \
  --arg publicUrl "$(printf '%s' "$complete_resp" | jq -r '.data.upload.publicUrl')" \
  --arg siteUrl "$(printf '%s' "$complete_resp" | jq -r '.data.upload.siteUrl')" \
  --arg uploadPaymentStatus "$payment_status" \
  --arg uploadPaymentTransactionHash "$payment_tx_hash" \
  '{uploadId:$uploadId, publicUrl:$publicUrl, siteUrl:$siteUrl, list_scope_bearer:$bearer, upload_payment_status:$uploadPaymentStatus, upload_payment_transaction_hash:$uploadPaymentTransactionHash}'
