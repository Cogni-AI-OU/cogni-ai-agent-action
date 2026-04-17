# OpenCode Agent

The OpenCode workflow runs a generic OpenCode agent without loading any specialized Cogni AI agents, skills, or instructions.

## Usage

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
