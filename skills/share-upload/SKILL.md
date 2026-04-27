# share-upload (mnemospark-lite)

Mint a **24-hour** share URL for a specific upload ID.

## Endpoint used

- `POST /api/mnemospark-lite/share`

## Inputs you need

- `MNEMOSPARK_API_BASE_URL`
- `Authorization: Bearer <token>` (use `list_scope_bearer` returned from the paid upload call)
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

- `data.shareUrl` like `https://app.mnemospark.ai/mnemospark-lite/?share=...`
- `data.expiresAt` (24 hours)

