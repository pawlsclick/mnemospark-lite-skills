# list-uploads (mnemospark-lite)

List uploads for the wallet scope tied to the bearer token.

## Endpoint used

- `GET /api/mnemospark-lite/uploads`

## Inputs you need

- `MNEMOSPARK_API_BASE_URL`
- `Authorization: Bearer <token>`

You typically receive the bearer token as `list_scope_bearer` from the paid upload call.

## Request

```bash
curl "${MNEMOSPARK_API_BASE_URL}/api/mnemospark-lite/uploads" \
  -H "Authorization: Bearer <token>"
```

## Response shape

`data.uploads[]` records include:

- `id`
- `filename`
- `contentType`
- `tier`
- `maxSize`
- `actualSize`
- `publicUrl` (may be `null` until `/complete`)
- `status`
- `pricePaid`
- `expiresAt`
- `createdAt`
