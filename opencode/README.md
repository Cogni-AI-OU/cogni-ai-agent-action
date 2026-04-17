# OpenCode Agent

The OpenCode workflow runs a generic OpenCode agent without loading any specialized Cogni AI agents, skills, or instructions.

## Usage

### Prerequisites

1. Add `OPENCODE_API_KEY` to your repository secrets (**Settings → Secrets and variables → Actions**).
2. Install the [GitHub OpenCode app](https://github.com/apps/opencode-agent) or follow the [manual setup guide](https://opencode.ai/docs/github/#manual-setup).

You can trigger the agent via `workflow_dispatch`, or via issue or PR comments using
commands like `/oc`, `/opencode`, or `/review`.

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
    runs-on: ubuntu-latest
    permissions:
      contents: write
      id-token: write
      issues: write
      pull-requests: write
    steps:
      - uses: actions/checkout@v4
      - name: Run OpenCode Agent
        uses: Cogni-AI-OU/cogni-ai-agent-action/opencode@main
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          opencode-api-key: ${{ secrets.OPENCODE_API_KEY }}
          prompt: ${{ inputs.prompt }}
```

### Advanced workflow

An example of a more advanced configuration:

```yaml
---
# See: <https://opencode.ai/docs>
name: OpenCode Agent

# yamllint disable-line rule:truthy
on:
  issue_comment:
    types:
      - created
      - edited
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
          - opencode/gemini-3.1-pro
          - opencode/gemini-3-flash
          - opencode/gemini-3-pro
        required: true
        type: choice
      prompt:
        description: Prompt for the agent
        required: true
        type: string

jobs:
  opencode-agent:
    name: Run OpenCode agent
    runs-on: ubuntu-latest
    permissions:
      contents: write
      id-token: write
      issues: write
      pull-requests: write
    steps:
      - uses: actions/checkout@v4
        with:
          persist-credentials: false  # Prevents Duplicate header: "Authorization" error.
      # See: <https://github.com/Cogni-AI-OU/cogni-ai-agent-action/tree/main/opencode>
      - name: Run OpenCode Agent
        uses: Cogni-AI-OU/cogni-ai-agent-action/opencode@main
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        with:
          model: ${{ inputs.model }}
          opencode-api-key: ${{ secrets.OPENCODE_API_KEY }}  # <https://opencode.ai/auth>
          prompt: ${{ github.event.comment.body || inputs.prompt }}
```

### Inputs

| Input              | Description                 | Default                | Required |
| ------------------ | --------------------------- | ---------------------- | -------- |
| `agent`            | Agent to use                | —                      | No       |
| `mentions`         | Comma-separated mentions    | `/oc,/opencode,/review`| No       |
| `model`            | Model to use for OpenCode   | `opencode/gpt-5-codex` | No       |
| `opencode-api-key` | API key for OpenCode        | —                      | **Yes**  |
| `permissions`      | Permissions configuration   | —                      | No       |
| `prompt`           | Prompt to pass to the agent | `''`                   | No       |

### Outputs

| Output     | Description                 |
| ---------- | --------------------------- |
| `response` | The response from the agent |
