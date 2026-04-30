# storage-lite (MCP-mode)

This skill defines a minimal MCP tool contract for calling mnemospark-lite over HTTP. Names are suggestions; map them to your host’s tool naming rules.

## Recommended MCP tools

### `mnemospark_lite_create_upload_slot`

**Endpoint:** `POST /api/mnemospark-lite/upload` (x402 paid)

**Inputs:**

- JSON body: `filename`, `contentType`, `tier` (`10mb` … `3gb`), `size_bytes`
- Headers: `Content-Type: application/json`, `PAYMENT-SIGNATURE: <payment>` or `x-payment: <payment>`

**Response (important fields):**

- `data.uploadId`
- `data.uploadUrl`
- `data.completion_token`
- `data.list_scope_bearer`
- `data.publicUrl`, `data.siteUrl` — `null` until completion

---

### `mnemospark_lite_put_bytes`

**Behavior:** `PUT` the file bytes to the presigned `uploadUrl` from `create_upload_slot`.

**Inputs:**

- `uploadUrl` (from prior step)
- Raw body: file bytes
- Header: `Content-Type` matching the original upload request

**Response:** HTTP status from object storage (typically `200` on success)

---

### `mnemospark_lite_complete_upload`

**Endpoint:** `POST /api/mnemospark-lite/upload/complete`

**Inputs:**

- JSON body:

```json
{
  "uploadId": "<uploadId>",
  "completion_token": "<completion_token>"
}
```

**Response:**

- `data.upload.publicUrl`, `data.upload.siteUrl` (e.g. app entry with `?code=...`)
- `data.upload.status`

---

### `mnemospark_lite_list_uploads`

**Endpoint:** `GET /api/mnemospark-lite/uploads`

**Inputs:**

- Header: `Authorization: Bearer <list_scope_bearer>`

**Response:**

- `data.uploads[]` with fields such as `id`, `filename`, `contentType`, `tier`, `publicUrl`, `status`, etc.

---

### `mnemospark_lite_get_download_url`

**Endpoint:** `GET /api/mnemospark-lite/download/{uploadId}`

**Inputs:**

- Path: `uploadId`
- Header: `Authorization: Bearer <list_scope_bearer>`

**Response:**

- `data.upload`
- `data.upload.downloadUrl` when the upload is in a downloadable state (short-lived presigned GET)

---

### `mnemospark_lite_share_upload`

**Endpoint:** `POST /api/mnemospark-lite/share`

**Inputs:**

- Header: `Authorization: Bearer <list_scope_bearer>`
- JSON body: `{ "uploadId": "<uploadId>" }`

**Response:**

- `data.shareUrl` (24-hour anonymous share link)
- `data.expiresAt`

---

### `mnemospark_lite_delete_uploads`

**Endpoint:** `POST /api/mnemospark-lite/delete`

**Inputs:**

- Header: `Authorization: Bearer <list_scope_bearer>`
- JSON body: `{ "uploadIds": ["<id1>", "<id2>"] }`

**Response:**

- `data.deleted`
- `data.results[]` per ID

---

### `mnemospark_lite_exchange_share`

**Endpoint:** `POST /api/mnemospark-lite/shares/exchange` (public; no bearer)

**Inputs:**

- JSON body: `{ "share_token": "<token>" }`

**Response:**

- `data.downloadUrl` (short-lived presigned GET)
- `data.filename`, `data.shareExpiresAt`, `data.downloadExpiresInSeconds`, etc.

## Payment behavior

- The upload call is the paid x402 entrypoint.
- A client may probe without payment, receive `402 Payment Required`, then pay and retry with the same request shape.
- The `402` JSON body includes `extensions.bazaar` discovery info so facilitators can catalog the endpoint (spec: `https://raw.githubusercontent.com/x402-foundation/x402/refs/heads/main/specs/extensions/bazaar.md`).
- Best practice: echo the `extensions.bazaar` object into the x402 `PaymentPayload` used for settlement.

## Constraints (v1)

- Max upload size: **4,800,000,000 bytes** (4.8 GB)
- Multipart uploads are not supported in v1
