# upload-and-share (mnemospark-lite)

Upload a file through the mnemospark-lite HTTP API and mint a share URL.

## Endpoints used

- `POST /api/mnemospark-lite/upload` (x402 paid)
- `PUT` to `data.uploadUrl` (presigned object upload)
- `POST /api/mnemospark-lite/upload/complete` (completion token)

## Inputs you need

- `MNEMOSPARK_API_BASE_URL`
- a file on disk
- `tier`: one of `10mb`, `100mb`, `500mb`, `1gb`, `2gb`, `3gb`
- `contentType`
- an x402-capable payer that can send `PAYMENT-SIGNATURE` or `x-payment`

## Canonical flow

### 1) Request a paid upload slot

`POST ${MNEMOSPARK_API_BASE_URL}/api/mnemospark-lite/upload`

Body:

```json
{
  "filename": "example.txt",
  "contentType": "text/plain",
  "tier": "10mb",
  "size_bytes": 12
}
```

Headers:

- `Content-Type: application/json`
- `PAYMENT-SIGNATURE: <payment>` or `x-payment: <payment>`

Response fields include:

- `data.uploadId`
- `data.uploadUrl`
- `data.completion_token`
- `data.list_scope_bearer`
- `data.publicUrl` = `null` before completion
- `data.siteUrl` = `null` before completion

### 2) Upload bytes

Send the file bytes to `data.uploadUrl` with `PUT`.

Example:

```bash
curl -T "example.txt" \
  -H "Content-Type: text/plain" \
  "<uploadUrl>"
```

### 3) Complete and mint the share URL

`POST ${MNEMOSPARK_API_BASE_URL}/api/mnemospark-lite/upload/complete`

```json
{
  "uploadId": "<uploadId>",
  "completion_token": "<completion_token>"
}
```

Response includes:

- `data.upload.publicUrl`
- `data.upload.siteUrl`
- `data.upload.status`

## Payment behavior

- The upload call is the paid x402 entrypoint.
- A client may first probe without payment to receive the `402 Payment Required` challenge.
- Read `PAYMENT-REQUIRED` or `x-payment-required`, base64-decode it, and preserve the advertised payment requirement.
- The retry request should send `PAYMENT-SIGNATURE: <base64-json>` or `x-payment: <base64-json>`.

For x402 v2, the payment payload sent back to mnemospark-lite must include:

- `x402Version`
- `scheme`
- `network`
- `accepted`
- `payload.signature`
- `payload.authorization`

Important: include the full `accepted` object from the 402 challenge, not only `scheme`/`network`.

Minimal shape:

```json
{
  "x402Version": 2,
  "scheme": "exact",
  "network": "eip155:8453",
  "accepted": {
    "scheme": "exact",
    "network": "eip155:8453",
    "asset": "<asset>",
    "payTo": "<recipient>",
    "amount": "<amount>",
    "maxTimeoutSeconds": 3600,
    "extra": {
      "name": "USD Coin",
      "version": "2"
    }
  },
  "payload": {
    "signature": "<eip3009-signature>",
    "authorization": {
      "from": "<payer-wallet>",
      "to": "<recipient>",
      "value": "<amount>",
      "validAfter": "<unix-seconds>",
      "validBefore": "<unix-seconds>",
      "nonce": "<bytes32>"
    }
  }
}
```

## Output expectations

Return or persist for the active task:

- `uploadId`
- `publicUrl`
- `siteUrl`
- `list_scope_bearer`
