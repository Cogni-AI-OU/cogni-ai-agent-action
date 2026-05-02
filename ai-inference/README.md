# Cogni AI Inference

This action runs AI inference using GitHub Models.

## Usage

### Basic workflow

The default AI inference workflow runs on `workflow_dispatch`.

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
    permissions:
      models: read
    steps:
      - name: Run AI Inference
        uses: Cogni-AI-OU/cogni-ai-agent-action/ai-inference@v1
        with:
          prompt: ${{ inputs.prompt }}
          token: ${{ secrets.GITHUB_TOKEN }}
```

### Advanced workflow

An example of a more advanced configuration with issue and pull request triggers:

```yaml
---
name: AI Inference

on:
  issue_comment:
    types: [created, edited]
  pull_request_review_comment:
    types: [created, edited]
  discussion:
    types: [created, edited, answered]
  discussion_comment:
    types: [created, edited]
  issues:
    types: [opened, edited]
  workflow_dispatch:
    inputs:
      model:
        default: openai/gpt-4o-mini
        description: Model to use for inference
        options:
          - openai/gpt-4o
          - openai/gpt-4o-mini
          - meta/llama-3.3-70b-instruct
          - deepseek/deepseek-r1
        required: true
        type: choice
      prompt:
        description: Prompt for the model
        required: true
        type: string

jobs:
  inference:
    if: |
      (github.event_name == 'workflow_dispatch' || github.event.sender.type != 'Bot') &&
      (
        github.event_name == 'workflow_dispatch' ||
        (
          github.event_name == 'issues' &&
          contains(github.event.issue.body || '', '/ai')
        ) ||
        (
          github.event_name == 'discussion' &&
          contains(github.event.discussion.body || '', '/ai')
        ) ||
        contains(github.event.comment.body || '', '/ai')
      )
    runs-on: ubuntu-latest
    permissions:
      contents: read
      discussions: write
      id-token: write  # Needed for OIDC token for GitHub Models API calls
      issues: write
      models: read
      pull-requests: write
    steps:
      - uses: actions/checkout@v6
        with:
          persist-credentials: false
          ref: >-
            ${{
              (github.event_name == 'issue_comment' && github.event.issue.pull_request && format('refs/pull/{0}/head', github.event.issue.number)) ||
              (github.event_name == 'pull_request_review_comment' && format('refs/pull/{0}/head', github.event.pull_request.number)) ||
              github.ref
            }}
      - name: Run AI Inference
        uses: Cogni-AI-OU/cogni-ai-agent-action/ai-inference@v1
        with:
          model: ${{ inputs.model || 'openai/gpt-4o-mini' }}
          prompt: ${{ inputs.prompt || github.event.comment.body || github.event.issue.body || github.event.discussion.body }}
          token: ${{ secrets.GITHUB_TOKEN }}
```

### Inputs

| Input                  | Description                                   | Default                   | Required |
| ---------------------- | --------------------------------------------- | ------------------------- | -------- |
| `agent`                | Agent to use for system prompt                | `default`                 | No       |
| `enable-github-mcp`    | Enable Model Context Protocol integration      | `false`                   | No       |
| `github-mcp-token`     | Token to use for GitHub MCP server            | —                         | No       |
| `github-mcp-toolsets`  | Toolsets to enable for GitHub MCP server      | `repos,issues,pull_requests,actions,code_security` | No       |
| `max-completion-tokens` | The maximum number of tokens to generate      | —                         | No       |
| `max-tokens`            | Max tokens to generate (deprecated)           | —                         | No       |
| `mentions`             | Comma-separated triggers                      | `/ai`                     | No       |
| `model`                | Model to use for inference                    | `openai/gpt-4o-mini`      | No       |
| `prompt`               | Prompt to pass to the model                   | `''`                      | No       |
| `prompt-file`          | Path to a file containing the prompt          | `''`                      | No       |
| `input`                | Template variables for .prompt.yml files      | `''`                      | No       |
| `file_input`           | File-based template variables                 | `''`                      | No       |
| `system-prompt`        | The system prompt to send                     | `You are a helpful assistant` | No       |
| `temperature`          | The sampling temperature to use (0-1)         | —                         | No       |
| `token`                | Token to use for inference                    | `github.token`            | No       |
| `top-p`                 | The nucleus sampling parameter to use (0-1)   | —                         | No       |

### Outputs

| Output          | Description                                                                  |
| --------------- | ---------------------------------------------------------------------------- |
| `prompt`        | The resolved prompt sent to the model                                        |
| `response`      | The response from the model                                                  |
| `response-file` | The file path where the response is saved (useful for larger responses)      |
