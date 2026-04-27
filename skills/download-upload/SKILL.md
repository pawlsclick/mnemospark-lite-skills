# download-upload (mnemospark-lite)

Get upload detail and, when available, a short-lived download URL for a specific upload.

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

- `data.upload`
- `data.upload.downloadUrl` when the upload is in a downloadable state

## Notes

- bearer access is wallet-scoped
- download URLs are short-lived presigned URLs
- clients should not assume the download URL is permanent
