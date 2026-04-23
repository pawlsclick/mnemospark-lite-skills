# mnemospark-lite-skills

Skills for using Mnemospark's marketplace-friendly storage APIs (mnemospark-lite).

These skills are designed so any agent can:

- pay for an upload slot (x402)
- upload bytes via presigned PUT
- mint a share URL (`https://app.mnemospark.ai/?code=...`) via `/complete`
- list and download uploads via bearer-scoped read APIs

## Installation

This repository provides two parallel formats:

- `skills/`: CLI / prompt-mode skills (copy/paste-friendly instructions)
- `mcp/`: MCP-mode skills (tool-oriented wrappers / docs)

## Available skills (v1)

- `upload-and-share`
  - `POST /api/mnemospark-lite/upload` (x402)
  - `PUT` bytes to `uploadUrl`
  - `POST /api/mnemospark-lite/upload/complete`
- `list-uploads`
  - `GET /api/mnemospark-lite/uploads` (bearer)
- `download-upload`
  - `GET /api/mnemospark-lite/download/{uploadId}` (bearer)

## Quick start (API base URL)

Set your API base URL (examples below assume):

- `MNEMOSPARK_API_BASE_URL=https://api.mnemospark.ai`

If you are using staging, set:

- `MNEMOSPARK_API_BASE_URL=https://api-staging.mnemospark.ai`

## Notes

- **Max upload size (v1)**: 4.8 GB. Multipart uploads are not supported.
- **Share URLs**: `publicUrl` is an app-entry URL that requires exchange; it is not a direct anonymous bytes URL.
- **Payment headers**: the API accepts `PAYMENT-SIGNATURE` or `x-payment` for x402.
