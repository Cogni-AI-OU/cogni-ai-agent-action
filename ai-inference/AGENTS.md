# AI Inference Protocols

Authoritative, agent-facing catalog of protocols and invariants for the `ai-inference/` directory.

## Invariants

- **Summary Job**:
  The `summary` job (visual audit report) is NOT needed for the AI Inference action.
  This action is a simple wrapper for model inference and does not require the specialized auditing summary
  used by the primary Cogni AI agent.

## Directory structure

- **[action.yml](action.yml)**: The composite action metadata and logic.
- **[README.md](README.md)**: Documentation for the AI Inference action.
- **[summary/](summary/)**: Sub-action for generating visual audit reports (used by other actions).
