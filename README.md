# cogni-ai-agent-action

Cogni AI agent (GitHub Action) — runs [OpenCode](https://opencode.ai) inside a GitHub Actions workflow.

## Usage

### Prerequisites

1. Add `OPENCODE_API_KEY` to your repository secrets (**Settings → Secrets and variables → Actions**).

### Basic workflow

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
    runs-on: ubuntu-latest
    permissions:
      contents: write
      id-token: write
      issues: write
      pull-requests: write
    steps:
      - uses: actions/checkout@v4
      - name: Run Cogni AI Agent
        uses: Cogni-AI-OU/cogni-ai-agent-action@v1
        with:
          opencode-api-key: ${{ secrets.OPENCODE_API_KEY }}
          prompt: ${{ inputs.prompt }}
```

### Inputs

| Input | Description | Default | Required |
|---|---|---|---|
| `agent` | Agent to use | `cogni-ai-architect` | No |
| `github-token` | GitHub token | `${{ github.token }}` | No |
| `issue_number` | Issue or PR number to reference | — | No |
| `model` | Model to use for OpenCode | `opencode/gemini-3.1-pro` | No |
| `opencode-api-key` | API key for OpenCode | — | **Yes** |
| `prompt` | Prompt to pass to the agent | `''` | No |

### Outputs

| Output | Description |
|---|---|
| `response` | The response from the agent |
