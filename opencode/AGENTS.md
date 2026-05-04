# OpenCode Agent Protocols

Authoritative, agent-facing catalog of protocols and invariants for the `opencode/` directory.

## Invariants

- **Conditional Execution**:
  The `opencode/action.yml` action now handles conditional execution internally via a `Check conditions` step.
  It evaluates `mentions` and `mentions_bots` to determine if the agent should run.
- **Default Triggers**:
  Do NOT change the default triggers for the OpenCode action in `opencode/action.yml`.
  The current default triggers are `/oc`, `/opencode`, and `/review`.
- **Scope**:
  The OpenCode action in this directory is intended to be a generic wrapper for OpenCode and should remain decoupled
  from specialized Cogni AI agent triggers (like `/brainstorm`) unless explicitly requested.

## Directory structure

- **[action.yml](action.yml)**: The composite action metadata and logic.
- **[README.md](README.md)**: Documentation for the OpenCode action.
