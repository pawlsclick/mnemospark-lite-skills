# share-upload (mnemospark-lite)

Mint a **24-hour** share URL for a specific upload ID via the mnemospark-lite HTTP API.

## Endpoint used

- `POST /api/mnemospark-lite/share`

## Inputs you need

- `MNEMOSPARK_API_BASE_URL`
- `Authorization: Bearer <token>` (typically `list_scope_bearer` from the paid upload flow)
- `uploadId`

## Request

```bash
curl "${MNEMOSPARK_API_BASE_URL}/api/mnemospark-lite/share" \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"uploadId":"<uploadId>"}'
```

## Response

Response includes:

- `data.shareUrl` (e.g. `https://app.mnemospark.ai/mnemospark-lite/?share=...`)
- `data.expiresAt` (24 hours from mint)

## Notes

- Bearer access is wallet-scoped to the same payer scope as list/download.
- The share URL is anonymous and expires after 24 hours; recipients use the app flow to exchange the token for a short-lived download URL.
