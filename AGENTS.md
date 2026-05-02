# Cogni AI Agent Action Protocols

Authoritative, agent-facing catalog of protocols and invariants for the repository.

## Input Support Policy

- **Action Differentiation**:
  The `opencode` and `ai-inference` actions serve different purposes and support different sets of inputs.
  - `ai-inference` supports LLM-specific parameters such as `maxCompletionTokens`, `maxTokens`, `temperature`, and `topP`.
  - `opencode` related actions focus on agent orchestration and use `opencode-api-key` and `permissions`.
- **Breaking Changes**:
  Do NOT add AI inference-specific inputs to `opencode` related actions as they are considered breaking changes and are not valid for those actions.

## Execution Flow & Constraints

- **Execution Flow**: For a detailed overview of the action's logic and execution flow, see [FLOWS.mmd](FLOWS.mmd).
- **Formal Constraint Model**: For the formal constraint model covering skill and tool permission constraints, see [CONSTRAINTS.mzn](CONSTRAINTS.mzn).

## Task Delegation

`cogni-ai-context7-ops`, `cogni-ai-devops`, `cogni-ai-fact-ops`, `cogni-ai-github-ops`,
`cogni-ai-python-dev`, `cogni-ai-code-reviewer`, `cogni-ai-plan-reviewer`, `cogni-ai-tester`, and `cogni-ai-brain-ops` are configured with `mode: all`, so
they remain selectable as primary agents and are also exposed to OpenCode's
`task` tool as named subagent delegation targets.

## Hierarchical Permissions

Define granular permissions per agent type using a hierarchical YAML structure. The `default`
section applies to all agents, while agent-specific sections (e.g., `cogni-ai-architect`, `cogni-ai-code-reviewer`)
override or extend these defaults. See [action.yml](action.yml) for default permissions.

## Triggers & Mentions

The agent can be triggered via `workflow_dispatch`, or via issue/PR comments
using commands like `/co`, `/cogni`, `/review`, or `/brainstorm`. The `mentions` input
(default: `/co,/cogni,/review,/brainstorm`) controls which keywords activate the agent.

## Directory structure

- **[action.yml](action.yml)**: The root composite action.
- **[ai-inference/](ai-inference/)**: Specialized action for AI inference using GitHub Models.
- **[opencode/](opencode/)**: Specialized action for OpenCode Agent.
