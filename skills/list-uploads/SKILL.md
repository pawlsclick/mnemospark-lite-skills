# list-uploads (mnemospark-lite)

List uploads visible to the payer wallet scope represented by a bearer token.

## Endpoint used

- `GET /api/mnemospark-lite/uploads`

## Inputs you need

- `MNEMOSPARK_API_BASE_URL`
- `Authorization: Bearer <token>`

You typically receive the token as `list_scope_bearer` from the paid upload flow.

## Request

```bash
curl "${MNEMOSPARK_API_BASE_URL}/api/mnemospark-lite/uploads" \
  -H "Authorization: Bearer <token>"
```

## Response shape

`data.uploads[]` includes fields such as:

- `id`
- `filename`
- `contentType`
- `tier`
- `maxSize`
- `actualSize`
- `publicUrl`
- `status`
- `pricePaid`
- `expiresAt`
- `createdAt`

## Notes

- bearer scope is tied to the payer wallet
- `publicUrl` may be `null` until `/upload/complete`
- clients should treat bearer tokens as credentials and store them appropriately for their runtime
