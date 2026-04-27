# upload-and-share (mnemospark-lite)

Upload a file through Mnemospark's marketplace-friendly storage API and get a share URL.

## Endpoints used

- `POST /api/mnemospark-lite/upload` (x402 paid)
- `PUT` to `data.uploadUrl` (presigned S3 PUT)
- `POST /api/mnemospark-lite/upload/complete` (free; completion token)

## Inputs you need

- `MNEMOSPARK_API_BASE_URL`: e.g. `https://api.mnemospark.ai` (or staging)
- A file on disk
- `tier`: one of `10mb`, `100mb`, `500mb`, `1gb`, `2gb`, `3gb`
- `contentType`: MIME type
- x402 payment capability to provide `PAYMENT-SIGNATURE` or `x-payment` header

## Flow (two-step)

### 1) Create paid upload slot

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
- `PAYMENT-SIGNATURE: <x402 payment payload>` (or `x-payment`)

Notes:

- This endpoint uses the **`exact` (default)** payment scheme: the client pays the exact advertised price.
- If you call it **without payment**, it returns **`402 Payment Required`** and includes a base64-encoded
  `PAYMENT-REQUIRED` challenge header. Bazaar discovery may probe with **no body**, so the endpoint still
  responds with `402` in that case (not `400`).
- Pricing is **tier-based** and is computed from the selected tier’s **max size** (not necessarily your exact `size_bytes`).
  To ensure you pay the correct amount:
  - First call `/api/mnemospark-lite/upload` **without payment** but **with a JSON body including `tier`**.
  - Read `PAYMENT-REQUIRED` → `accepts[0].amount` and pay that exact amount using `PAYMENT-SIGNATURE` / `x-payment`.

Response:

- `data.uploadId`
- `data.uploadUrl`
- `data.completion_token`
- `data.list_scope_bearer`
- `data.publicUrl` is `null` (minted after `/complete`)

### 2) PUT bytes to S3

Use `data.uploadUrl`:

```bash
curl --data-binary @"example.txt" \
  -H "Content-Type: text/plain" \
  "<uploadUrl>"
```

### 3) Complete (reconcile + mint share URL)

`POST ${MNEMOSPARK_API_BASE_URL}/api/mnemospark-lite/upload/complete`

```json
{
  "uploadId": "<uploadId>",
  "completion_token": "<completion_token>"
}
```

Response contains:

- `data.upload.publicUrl` (and `siteUrl` via the same string) as `https://app.mnemospark.ai/?code=...`
- `data.upload.status = "uploaded"`

## Error behavior

- Files larger than **4.8 GB** return a clear 4xx error (multipart is not supported in v1).
