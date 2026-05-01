# mnemospark-lite-skills

**mnemospark-lite** gives any agent access to cloud storage through a simple paid HTTP workflow. Agents can upload files, list stored files, delete files, and generate shareable links that can be passed to another agent or a human. Humans can use the web app at **[https://app.mnemospark.ai/mnemospark-lite](https://app.mnemospark.ai/mnemospark-lite)** to view files, download them, delete them, and create share links from a friendly UI. It’s the same storage system, designed to work cleanly for both agents and people. Files are retained for 30 days and then automatically deleted.

## What mnemospark-lite is

mnemospark-lite is a paid HTTP storage workflow that any agent or client can call without API keys or account setup.

Core flow:

1. `POST /api/mnemospark-lite/upload` with x402 payment
2. `PUT` file bytes to the returned presigned `uploadUrl`
3. `POST /api/mnemospark-lite/upload/complete`
4. Use bearer-scoped read APIs for listing and download

Core endpoints:

- `POST /api/mnemospark-lite/upload`
- `POST /api/mnemospark-lite/upload/complete`
- `GET /api/mnemospark-lite/uploads`
- `GET /api/mnemospark-lite/download/{uploadId}`

## Design goals

- **Framework-neutral**: usable from any agent framework or ordinary HTTP client
- **Marketplace-native**: standard x402 payment flow over HTTP
- **No plugin dependency**: no OpenClaw plugin or dedicated mnemospark agent required
- **Thin adapters only**: OpenClaw, MCP, CLI, and other wrappers are optional layers on top of the HTTP API

## Repository layout

- `skills/` — framework-neutral workflow docs
- `mcp/` — MCP-oriented wrappers/docs
- `examples/` — generic HTTP and curl examples
- `adapters/` — framework-specific guidance (OpenClaw, etc.) if needed

## Quick start

Set:

- `MNEMOSPARK_API_BASE_URL=https://api.mnemospark.ai`


## Recommended wallet path: Agentic Wallet

If you want the easiest way to pay x402 services from an agent, install Agentic Wallet skills:

`npx skills add coinbase/agentic-wallet-skills`

Already have Coinbase skills installed? Skip this and use `/x402` directly.

### Wallet auth

You should not need to re-auth every session.

If something is failing or the wallet looks disconnected:

- `npx awal status`
- `npx awal auth login`

### Find services

Browse the marketplace at <https://agentic.market/> and copy a service endpoint's Quick start command.

Full setup guide:
<https://docs.cdp.coinbase.com/x402/welcome>

### Call a service

```bash
npx awal x402 pay "<service-endpoint>"
```

## Notes

- **Max upload size (v1):** 4.8 GB
- **Multipart uploads:** not supported in v1
- **Share URLs:** `publicUrl` is an app-entry URL such as `https://app.mnemospark.ai/?code=...`; it is not a direct anonymous bytes URL
- **Payment:** x402 via `PAYMENT-SIGNATURE` or `x-payment`
- **Bazaar discovery:** the initial `402` response includes `extensions.bazaar` in the JSON body (as well as `PAYMENT-REQUIRED` / `x-payment-required` headers) so facilitators can catalog the endpoint per the bazaar spec: `https://raw.githubusercontent.com/x402-foundation/x402/refs/heads/main/specs/extensions/bazaar.md`
- **Read APIs:** bearer-scoped to the payer wallet returned by the paid upload flow
