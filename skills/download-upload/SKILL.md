# download-upload (mnemospark-lite)

Get a short-lived download URL for a specific upload (wallet-scoped).

## Endpoint used

- `GET /api/mnemospark-lite/download/{uploadId}`

## Inputs you need

- `MNEMOSPARK_API_BASE_URL`
- `Authorization: Bearer <token>`
- `uploadId`

## Request

```bash
curl "${MNEMOSPARK_API_BASE_URL}/api/mnemospark-lite/download/<uploadId>" \
  -H "Authorization: Bearer <token>"
```

## Response

Response includes:

- `data.downloadUrl` (presigned GET)
- `data.expiresAt`
- `data.upload` (the upload record)
