# openclaw adapter

Use this adapter only when running mnemospark-lite from OpenClaw.

## Notes

- OpenClaw installs with the mnemospark plugin may already have a funded mnemospark-compatible wallet on disk
- framework-specific secret paths and runtime behavior belong here, not in the core API workflow docs
- use the same canonical HTTP flow:
  1. paid `/upload`
  2. PUT to `uploadUrl`
  3. `/upload/complete`
  4. bearer-scoped read APIs
