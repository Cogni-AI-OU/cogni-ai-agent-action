# cogni-ai-agent-action

[![Tag][gh-tag-image]][gh-tag-link]
[![Check][gha-image-check-main]][gha-link-check-main]
[![Edit][gh-edit-badge]][gh-edit-link]

Cogni AI agent (GitHub Action) — runs [OpenCode](https://opencode.ai) inside a GitHub Actions workflow.

## Usage

### Prerequisites

1. Add `OPENCODE_API_KEY` to your repository secrets (**Settings → Secrets and variables → Actions**).
2. Install the [GitHub OpenCode app](https://github.com/apps/opencode-agent) or follow the [manual setup guide](https://opencode.ai/docs/github/#manual-setup).

You can trigger the agent via `workflow_dispatch`, or via issue or PR comments using commands like `/co`, `/cogni`, or `/review`.

### Basic workflow

The default Cogni AI agent workflow loads specialized agents, skills, and instructions.

```yaml
---
name: Cogni AI

on:
  workflow_dispatch:
    inputs:
      prompt:
        description: Prompt for the agent
        required: true
        type: string

jobs:
  agent:
    if: |
      github.event_name == 'workflow_dispatch' ||
      contains(github.event.comment.body, '/') ||
      contains(github.event.comment.body, '@')
    runs-on: ubuntu-latest
    permissions:
      contents: write
      id-token: write
      issues: write
      pull-requests: write
      discussions: write
    steps:
      - uses: actions/checkout@v6
        with:
          persist-credentials: false  # Prevents Duplicate header: "Authorization" error.
      - name: Run Cogni AI Agent
        uses: Cogni-AI-OU/cogni-ai-agent-action@v1
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          opencode-api-key: ${{ secrets.OPENCODE_API_KEY }}
          prompt: ${{ inputs.prompt || github.event.comment.body || github.event.issue.body || github.event.pull_request.body || github.event.discussion.body }}
    timeout-minutes: 60
```

### Execution flow

For a detailed overview of the action's logic and execution flow, see [FLOWS.mmd](FLOWS.mmd).

### Task delegation

`cogni-ai-context7-ops`, `cogni-ai-devops`, `cogni-ai-fact-ops`, `cogni-ai-github-ops`, `cogni-ai-python-dev`, and `cogni-ai-reviewer` are configured with `mode: all`, so
they remain selectable as primary agents and are also exposed to OpenCode's
`task` tool as named subagent delegation targets.

### OpenCode workflow

For running a generic OpenCode agent without specialized skills or instructions, see the [OpenCode Agent documentation](opencode/README.md).

### Advanced workflow

An example of a more advanced configuration with issue and pull request triggers:

```yaml
---
# See: <https://opencode.ai/docs>
name: Cogni AI Agent

# yamllint disable-line rule:truthy
on:
  issues:
    types:
      - opened
      - edited
      - reopened
  issue_comment:
    types:
      - created
      - edited
  discussion:
    types:
      - created
      - edited
      - answered
  discussion_comment:
    types:
      - created
      - edited
  pull_request:
    types:
      - opened
      - edited
      - reopened
      - synchronize
  pull_request_review_comment:
    types:
      - created
      - edited
  workflow_dispatch:
    inputs:
      model:
        default: opencode/gemini-3-flash
        description: Model to use for OpenCode
        options:
          - opencode/big-pickle
          - opencode/claude-3-5-haiku
          - opencode/claude-haiku-4-5
          - opencode/claude-opus-4-5
          - opencode/claude-opus-4-6
          - opencode/claude-sonnet-4
          - opencode/claude-sonnet-4-5
          - opencode/claude-sonnet-4-6
          - opencode/gemini-3.1-pro
          - opencode/gemini-3-flash
          - opencode/gemini-3-pro
          - opencode/glm-5
          - opencode/glm-5.1
          - opencode/gpt-5
          - opencode/gpt-5-codex
          - opencode/gpt-5-nano
          - opencode/gpt-5.3-codex
          - opencode/gpt-5.3-codex-spark
          - opencode/gpt-5.4
          - opencode/gpt-5.4-mini
          - opencode/gpt-5.4-nano
          - opencode/minimax-m2.5
          - opencode/minimax-m2.5-free
          - opencode/nemotron-3-super-free
          - opencode/qwen3-coder
          - opencode/qwen3.6-plus-free
        required: true
        type: choice
      prompt:
        description: Prompt for the agent
        required: true
        type: string

jobs:
  cogni-ai-agent:
    name: Run Cogni AI agent
    if: |
      github.event_name == 'workflow_dispatch' ||
      github.event_name == 'pull_request' ||
      (
        github.event_name == 'issues' &&
        (
          contains(github.event.issue.body || '', '/') ||
          contains(github.event.issue.body || '', '@')
        )
      ) ||
      (
        github.event_name == 'discussion' &&
        (
          contains(github.event.discussion.body || '', '/') ||
          contains(github.event.discussion.body || '', '@')
        )
      ) ||
      contains(github.event.comment.body || '', '/') ||
      contains(github.event.comment.body || '', '@')
    runs-on: ubuntu-latest
    permissions:
      contents: write
      id-token: write
      issues: write
      pull-requests: write
      discussions: write
    steps:
      - uses: actions/checkout@v6
        with:
          persist-credentials: false  # Prevents Duplicate header: "Authorization" error.
      # See: <https://github.com/Cogni-AI-OU/cogni-ai-agent-action>
      - name: Run Cogni AI Agent
        uses: Cogni-AI-OU/cogni-ai-agent-action@main
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          model: ${{ inputs.model }}
          opencode-api-key: ${{ secrets.OPENCODE_API_KEY }}  # <https://opencode.ai/auth>
          prompt: ${{ inputs.prompt || github.event.comment.body || github.event.issue.body || github.event.pull_request.body || github.event.discussion.body }}
    timeout-minutes: 60
```

### Inputs

| Input              | Description                 | Default                   | Required |
| ------------------ | --------------------------- | ------------------------- | -------- |
| `agent`            | Agent to use                | `cogni-ai-architect`      | No       |
| `mentions`         | Comma-separated mentions    | `/co,/cogni,/review`      | No       |
| `model`            | Model to use for OpenCode   | `opencode/gemini-3-flash` | No       |
| `opencode-api-key` | API key for OpenCode        | —                         | **Yes**  |
| `permissions`      | Permissions configuration   | —                         | No       |
| `prompt`           | Prompt to pass to the agent | `''`                      | No       |

### Hierarchical Permissions

Define granular permissions per agent type using a hierarchical YAML structure. The `default` section applies to all agents, while agent-specific sections (e.g., `cogni-ai-architect`, `cogni-ai-reviewer`) override or extend these defaults. See [action.yml](action.yml) for default permissions.

### Outputs

| Output     | Description                           |
| ---------- | ------------------------------------- |
| `prompt`   | The resolved prompt sent to the agent |
| `response` | The response from the agent           |

<!-- Named links -->

[gh-edit-badge]: https://img.shields.io/badge/GitHub-edit-purple.svg?logo=github
[gh-edit-link]: https://github.dev/Cogni-AI-OU/cogni-ai-agent-action

[gh-tag-image]: https://img.shields.io/github/tag/Cogni-AI-OU/cogni-ai-agent-action.svg?logo=github
[gh-tag-link]: https://github.com/Cogni-AI-OU/cogni-ai-agent-action/tags

[gha-link-check-main]: https://github.com/Cogni-AI-OU/cogni-ai-agent-action/actions?query=workflow%3ACheck+branch%3Amain
[gha-image-check-main]: https://github.com/Cogni-AI-OU/cogni-ai-agent-action/workflows/Check/badge.svg
