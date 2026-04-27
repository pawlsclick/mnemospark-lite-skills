# mnemospark-lite MCP adapter

MCP-oriented wrappers and docs for mnemospark-lite. The HTTP API described in `skills/` is the source of truth; this folder shows how to expose it as MCP tools.

If your agent runtime supports MCP tools, you can implement thin tool wrappers that call the same endpoints as the framework-neutral skills.

See `mcp/storage-lite/SKILL.md` for the full tool contract.
