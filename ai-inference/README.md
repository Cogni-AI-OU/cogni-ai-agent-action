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
        id: inference
        with:
          prompt: >-
            ${{ github.event.comment.body ||
                github.event.discussion.body ||
                github.event.issue.body ||
                github.event.pull_request.body ||
                inputs.prompt }}
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
              (
                github.event_name == 'issue_comment' &&
                github.event.issue.pull_request &&
                format('refs/pull/{0}/head', github.event.issue.number)
              ) ||
              (
                github.event_name == 'pull_request_review_comment' &&
                format('refs/pull/{0}/head', github.event.pull_request.number)
              ) ||
              github.ref
            }}
      - name: Run AI Inference
        uses: Cogni-AI-OU/cogni-ai-agent-action/ai-inference@v1
        id: inference
        with:
          model: ${{ inputs.model || 'openai/gpt-4o-mini' }}
          prompt: >-
            ${{
              inputs.prompt ||
              github.event.comment.body ||
              github.event.issue.body ||
              github.event.discussion.body
            }}
          token: ${{ secrets.GITHUB_TOKEN }}
```

### Inputs

| Input | Description | Default | Required |
| :--- | :--- | :--- | :--- |
| `agent` | Agent to use for system prompt | `default` | No |
| `enable-github-mcp` | Enable Model Context Protocol integration | `true` | No |
| `github-mcp-token` | Token to use for GitHub MCP server | — | No |
| `github-mcp-toolsets` | Toolsets to enable for GitHub MCP | `repos,issues,pull_requests,actions,code_security` | No |
| `max-completion-tokens` | The maximum number of tokens to generate | — | No |
| `max-tokens` | Max tokens to generate (deprecated) | `16000` | No |
| `mentions` | Comma-separated triggers | `/ai` | No |
| `model` | Model to use for inference | `openai/gpt-4o-mini` | No |
| `prompt` | Prompt to pass to the model | `''` | No |
| `prompt-file` | Path to a file containing the prompt | `''` | No |
| `input` | Template variables for .prompt.yml files | `''` | No |
| `file_input` | File-based template variables | `''` | No |
| `system-prompt` | The system prompt to send | `You are a helpful assistant` | No |
| `temperature` | The sampling temperature to use (0-1) | — | No |
| `token` | Token to use for inference | `github.token` | No |
| `top-p` | The nucleus sampling parameter to use (0-1) | — | No |
| `version_agents` | Version of cogni-ai-agents to use | `main` | No |
| `version_instructions` | Version of cogni-ai-agent-instructions to use | `main` | No |
| `version_skills` | Version of cogni-ai-agent-skills to use | `main` | No |

### Outputs

| Output | Description |
| :--- | :--- |
| `prompt` | The resolved prompt sent to the model |
| `response` | The response from the model |
| `response-file` | The file path where the response is saved (useful for larger responses) |

## Requirements

- **Permissions**: The following minimal permissions are required:
  - `models: read`: Required to access GitHub Models.
  - `id-token: write`: Required for OIDC authentication.
- **GitHub Models Access**: To use this action, you must have GitHub Models enabled for your organization or repository.
  You can configure this in your organization or repository settings under the **Models** section.
  For more information, see [Prototyping with AI models](https://docs.github.com/en/github-models/use-github-models/prototyping-with-ai-models).

## Limitations

### GitHub Models Inference API

When using GitHub's Models inference API, you may encounter an error if your inference request exceeds the model's allowed token budget. This means you need to send less input or request fewer output tokens.

**Error which can happen:**
`413 Request body too large for gpt-4o-mini model. Max size: 8000 tokens.`

**Why:**
GitHub's Models inference API requires that messages be included in the request body, and the total token usage is constrained by the model's context/window and requested output. The docs state that `max_tokens` plus your prompt tokens cannot exceed the model's limit, so a large prompt body can trigger a 413-style failure when it is too big for that model. See [REST API endpoints for models inference](https://docs.github.com/en/rest/models/inference). Also, GitHub Models documentation shows per-request token limits for some models in the prototyping experience, which reinforces that request size limits are model-specific and subject to change. See [Prototyping with AI models](https://docs.github.com/en/github-models/use-github-models/prototyping-with-ai-models).

**What to do:**
- Reduce the size of the messages you send.
- Lower `max_tokens`.
- Trim or summarize prior conversation/history before sending it.
- Remove large pasted logs, diffs, file contents, or tool schemas from the prompt.
- Split one large request into multiple smaller requests.
