# OpenCode Agent

The OpenCode workflow runs a generic OpenCode agent. It acts as a lean pass-through wrapper for `anomalyco/opencode/github`.

## Usage

### Prerequisites

1. Add `OPENCODE_API_KEY` to your repository secrets (**Settings → Secrets and variables → Actions**).
2. Install the [GitHub OpenCode app](https://github.com/apps/opencode-agent) or follow the [manual setup guide](https://opencode.ai/docs/github/#manual-setup).

You can trigger the agent via `workflow_dispatch`, or via issue or PR
comments using commands like `/oc`, `/opencode`, or `/review`.

### Basic workflow

```yaml
---
name: OpenCode Agent

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
      (github.event_name == 'workflow_dispatch' || github.event.sender.type != 'Bot') &&
      (
        github.event_name == 'workflow_dispatch' ||
        contains(github.event.comment.body || '', '/') ||
        contains(github.event.comment.body || '', '@')
      )
    runs-on: ubuntu-latest
    permissions:
      actions: read
      contents: write
      id-token: write
      issues: write
      pull-requests: write
    steps:
      - uses: actions/checkout@v6
        with:
          persist-credentials: false  # Prevents Duplicate header: "Authorization" error.
      - name: Run OpenCode Agent
        uses: Cogni-AI-OU/cogni-ai-agent-action/opencode@main
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          opencode-api-key: ${{ secrets.OPENCODE_API_KEY }}
          prompt: ${{ inputs.prompt }}
    timeout-minutes: 60
```

### Advanced workflow

An example of a more advanced configuration with issue and pull request triggers. Note that unlike the root action, this wrapper does not automatically resolve prompts from comment bodies or wait for concurrent runs.

```yaml
---
# See: <https://opencode.ai/docs>
name: OpenCode Agent

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
          - opencode/qwen3.6-plus
          - opencode/qwen3.5-plus
        required: true
        type: choice
      prompt:
        description: Prompt for the agent
        required: true
        type: string

jobs:
  opencode-agent:
    name: Run OpenCode agent
    if: |
      (github.event_name == 'workflow_dispatch' || github.event.sender.type != 'Bot') &&
      (
        github.event_name == 'workflow_dispatch' ||
        github.event_name == 'issues' ||
        github.event_name == 'pull_request' ||
        contains(github.event.comment.body || '', '/') ||
        contains(github.event.comment.body || '', '@')
      )
    runs-on: ubuntu-latest
    permissions:
      actions: read
      contents: write
      id-token: write
      issues: write
      pull-requests: write
    steps:
      - uses: actions/checkout@v6
        with:
          persist-credentials: false
      - name: Run OpenCode Agent
        uses: Cogni-AI-OU/cogni-ai-agent-action/opencode@main
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          model: ${{ inputs.model }}
          opencode-api-key: ${{ secrets.OPENCODE_API_KEY }}
          prompt: >-
            ${{
              github.event.comment.body ||
              github.event.issue.body ||
              github.event.pull_request.body ||
              inputs.prompt
            }}
    timeout-minutes: 60
```

### Inputs

| Input              | Description                 | Default                   | Required |
| ------------------ | --------------------------- | ------------------------- | -------- |
| `agent`            | Agent to use                | —                         | No       |
| `mentions`         | Comma-separated mentions    | `/oc,/opencode,/review`   | No       |
| `model`            | Model to use for OpenCode   | `opencode/gemini-3-flash` | No       |
| `opencode-api-key` | API key for OpenCode        | —                         | **Yes**  |
| `permissions`      | Permissions (JSON string)   | —                         | No       |
| `prompt`           | Prompt to pass to the agent | `''`                      | No       |

### Outputs

| Output     | Description                           |
| ---------- | ------------------------------------- |
| `prompt`   | The resolved prompt sent to the agent |
| `response` | The response from the agent           |
