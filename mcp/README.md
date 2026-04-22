# Mnemospark skills (MCP-mode)

This folder contains MCP-friendly skills and guidance for calling Mnemospark's marketplace storage APIs.

If your agent runtime supports MCP tools, you can implement a thin tool wrapper that:

- calls `POST /api/mnemospark-lite/upload` with x402 payment headers
- performs `PUT` bytes to the returned presigned `uploadUrl`
- calls `POST /api/mnemospark-lite/upload/complete` with `completion_token`
- uses the returned bearer token for `GET /uploads` and `GET /download/{uploadId}`

See `mcp/storage-lite/SKILL.md` for the full contract.
