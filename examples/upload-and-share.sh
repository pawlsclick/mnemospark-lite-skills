#!/usr/bin/env bash
set -euo pipefail

: "${MNEMOSPARK_API_BASE_URL:?set MNEMOSPARK_API_BASE_URL}"
: "${FILE_PATH:?set FILE_PATH}"
: "${CONTENT_TYPE:?set CONTENT_TYPE}"
: "${TIER:?set TIER}"
: "${PAYMENT_HEADER:?set PAYMENT_HEADER}"
: "${PAYMENT_VALUE:?set PAYMENT_VALUE}"

filename="$(basename "$FILE_PATH")"
size_bytes="$(wc -c < "$FILE_PATH" | tr -d ' ')"

create_json="$(jq -n \
  --arg filename "$filename" \
  --arg contentType "$CONTENT_TYPE" \
  --arg tier "$TIER" \
  --argjson size_bytes "$size_bytes" \
  '{filename:$filename, contentType:$contentType, tier:$tier, size_bytes:$size_bytes}')"

create_resp="$(curl -sS \
  -X POST "${MNEMOSPARK_API_BASE_URL}/api/mnemospark-lite/upload" \
  -H "Content-Type: application/json" \
  -H "${PAYMENT_HEADER}: ${PAYMENT_VALUE}" \
  -d "$create_json")"

upload_url="$(printf '%s' "$create_resp" | jq -r '.data.uploadUrl')"
upload_id="$(printf '%s' "$create_resp" | jq -r '.data.uploadId')"
completion_token="$(printf '%s' "$create_resp" | jq -r '.data.completion_token')"
list_scope_bearer="$(printf '%s' "$create_resp" | jq -r '.data.list_scope_bearer')"

curl -sS -T "$FILE_PATH" \
  -H "Content-Type: ${CONTENT_TYPE}" \
  "$upload_url" >/dev/null

complete_json="$(jq -n \
  --arg uploadId "$upload_id" \
  --arg completion_token "$completion_token" \
  '{uploadId:$uploadId, completion_token:$completion_token}')"

complete_resp="$(curl -sS \
  -X POST "${MNEMOSPARK_API_BASE_URL}/api/mnemospark-lite/upload/complete" \
  -H "Content-Type: application/json" \
  -d "$complete_json")"

jq -n \
  --arg uploadId "$upload_id" \
  --arg bearer "$list_scope_bearer" \
  --arg publicUrl "$(printf '%s' "$complete_resp" | jq -r '.data.upload.publicUrl')" \
  --arg siteUrl "$(printf '%s' "$complete_resp" | jq -r '.data.upload.siteUrl')" \
  '{uploadId:$uploadId, publicUrl:$publicUrl, siteUrl:$siteUrl, list_scope_bearer:$bearer}'
