# delete-upload (mnemospark-lite)

Delete one or more uploads by upload ID via the mnemospark-lite HTTP API.

## Endpoint used

- `POST /api/mnemospark-lite/delete`

## Inputs you need

- `MNEMOSPARK_API_BASE_URL`
- `Authorization: Bearer <token>` (typically `list_scope_bearer` from the paid upload flow)
- One or more `uploadId` values

## Request

```bash
curl "${MNEMOSPARK_API_BASE_URL}/api/mnemospark-lite/delete" \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{"uploadIds":["<uploadId1>","<uploadId2>"]}'
```

## Response

Response includes:

- `data.deleted` (count)
- `data.results[]` per upload ID

## Notes

- Deletes are wallet-scoped; each ID is processed independently in `data.results[]`.
- Re-run `GET /api/mnemospark-lite/uploads` to confirm removals.
