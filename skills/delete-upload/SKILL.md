# delete-upload (mnemospark-lite)

Delete one or more uploads by upload ID.

## Endpoint used

- `POST /api/mnemospark-lite/delete`

## Inputs you need

- `MNEMOSPARK_API_BASE_URL`
- `Authorization: Bearer <token>` (use `list_scope_bearer` returned from the paid upload call)
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

After deleting, re-run `GET /api/mnemospark-lite/uploads` to confirm the items are gone.

