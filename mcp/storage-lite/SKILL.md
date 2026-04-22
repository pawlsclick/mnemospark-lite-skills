# storage-lite (MCP-mode)

This skill defines the minimal tool contract an MCP-capable agent should expose to use Mnemospark's marketplace storage APIs.

## Recommended MCP tools

You can implement these tools in your MCP host (names are suggestions):

- `mnemospark_lite_create_upload_slot`
  - Makes `POST /api/mnemospark-lite/upload` with x402 payment headers
- `mnemospark_lite_put_bytes`
  - Uploads bytes to the returned presigned `uploadUrl`
- `mnemospark_lite_complete_upload`
  - Calls `POST /api/mnemospark-lite/upload/complete`
- `mnemospark_lite_list_uploads`
  - Calls `GET /api/mnemospark-lite/uploads` with bearer
- `mnemospark_lite_get_download_url`
  - Calls `GET /api/mnemospark-lite/download/{uploadId}` with bearer

## API details

### Create paid upload slot

`POST /api/mnemospark-lite/upload`

Request body:

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
- `PAYMENT-SIGNATURE: <x402 payment payload>` (or `X-PAYMENT`)

Response (important fields):

- `uploadId`
- `uploadUrl`
- `completion_token`
- `list_scope_bearer`
- `publicUrl`: `null` initially

### PUT bytes

Use the returned `uploadUrl` and include `Content-Type` matching the original request.

### Complete upload

`POST /api/mnemospark-lite/upload/complete`

```json
{
  "uploadId": "<uploadId>",
  "completion_token": "<completion_token>"
}
```

Response includes `upload.publicUrl` as `https://app.mnemospark.ai/?code=...` (and `siteUrl` equal to it).

### List uploads (bearer)

`GET /api/mnemospark-lite/uploads`

Header:

- `Authorization: Bearer <list_scope_bearer>`

### Download (bearer)

`GET /api/mnemospark-lite/download/{uploadId}`

Header:

- `Authorization: Bearer <list_scope_bearer>`

Response includes:

- `downloadUrl` (presigned GET)
- `expiresAt`

## Constraints

- Max upload size (v1): **4,800,000,000 bytes** (4.8 GB)
- Multipart uploads are not supported in v1
