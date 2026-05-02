# Cogni AI Agent Action Protocols

Authoritative, agent-facing catalog of protocols and invariants for the repository.

## Input Support Policy

- **Action Differentiation**:
  The `opencode` and `ai-inference` actions serve different purposes and support different sets of inputs.
  - `ai-inference` supports LLM-specific parameters such as `maxCompletionTokens`, `maxTokens`, `temperature`, and `topP`.
  - `opencode` related actions focus on agent orchestration and use `opencode-api-key` and `permissions`.
- **Breaking Changes**:
  Do NOT add AI inference-specific inputs to `opencode` related actions as they are considered breaking changes and are not valid for those actions.

## Directory structure

- **[action.yml](action.yml)**: The root composite action.
- **[ai-inference/](ai-inference/)**: Specialized action for AI inference using GitHub Models.
- **[opencode/](opencode/)**: Specialized action for OpenCode Agent.
