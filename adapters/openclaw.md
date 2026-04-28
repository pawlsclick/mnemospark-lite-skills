# openclaw adapter

Use this adapter only when running mnemospark-lite from OpenClaw.

## Notes

- OpenClaw installs with the mnemospark plugin may already have a funded mnemospark-compatible wallet on disk.
- Framework-specific secret paths and runtime behavior belong here, not in the core API workflow docs.
- Use the same canonical HTTP flow:
  1. probe `/upload` and decode `PAYMENT-REQUIRED`
  2. paid `/upload` using the raw x402 client payload in `PAYMENT-SIGNATURE`
  3. if `/upload` returns `202 settlement_pending`, retry the same paid request with the same payment payload
  4. PUT to `uploadUrl`
  5. `/upload/complete` with only `uploadId` and `completion_token`
  6. bearer-scoped read APIs for verification

## OpenClaw-specific hints

- If the mnemospark plugin is installed, the wallet key usually exists at:
  - `/home/ubuntu/.openclaw/mnemospark/wallet/wallet.key`
- Some older or local setups may also have a legacy Blockrun wallet path, but do not assume it is the active mnemospark wallet.
- For the plugin CLI, prefer an absolute invocation like:
  - `/usr/bin/node /home/ubuntu/.openclaw/extensions/mnemospark/dist/cli.js wallet`
- Do not rely on `npx mnemospark` or cwd-sensitive paths when local install state may have drifted.
- If you use the Python x402 client path, install the EVM extras, not only the base package:
  - `pip install 'x402[evm]'`

## Reliability rule

When running under OpenClaw, prefer the known-good x402 client flow over hand-built JSON. The raw client output worked; manual payload normalization created avoidable failures.

Also capture `metadata.payment.status` and `metadata.payment.transactionHash` from the paid `/upload` response when present. Those fields are the cleanest proof that facilitator settlement succeeded.
