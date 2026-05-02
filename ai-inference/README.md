# Cogni AI Inference

This action runs AI inference using GitHub Models.

## Usage

### Basic workflow

```yaml
---
name: AI Inference

on:
  workflow_dispatch:
    inputs:
      prompt:
        description: Prompt for the model
        required: true
        type: string

jobs:
  inference:
    runs-on: ubuntu-latest
    steps:
      - name: Run AI Inference
        uses: Cogni-AI-OU/cogni-ai-agent-action/ai-inference@v1
        with:
          prompt: ${{ inputs.prompt }}
          token: ${{ secrets.GITHUB_TOKEN }}
```

### Inputs

| Input                  | Description                                   | Default                   | Required |
| ---------------------- | --------------------------------------------- | ------------------------- | -------- |
| `agent`                | Agent to use for system prompt                | `default`                 | No       |
| `enable-github-mcp`    | Enable Model Context Protocol integration      | `false`                   | No       |
| `github-mcp-token`     | Token to use for GitHub MCP server            | —                         | No       |
| `github-mcp-toolsets`  | Toolsets to enable for GitHub MCP server      | `repos,issues,pull_requests,actions,code_security` | No       |
| `maxCompletionTokens`   | The maximum number of tokens to generate      | —                         | No       |
| `maxTokens`            | Max tokens to generate (deprecated)           | —                         | No       |
| `mentions`             | Comma-separated triggers                      | `/ai`                     | No       |
| `model`                | Model to use for inference                    | `openai/gpt-4o-mini`      | No       |
| `prompt`               | Prompt to pass to the model                   | `''`                      | No       |
| `system-prompt`        | The system prompt to send                     | `You are a helpful assistant` | No       |
| `temperature`          | The sampling temperature to use (0-1)         | —                         | No       |
| `token`                | Token to use for inference                    | `github.token`            | No       |
| `topP`                 | The nucleus sampling parameter to use (0-1)   | —                         | No       |

### Outputs

| Output     | Description                           |
| ---------- | ------------------------------------- |
| `prompt`   | The resolved prompt sent to the model |
| `response` | The response from the model           |
