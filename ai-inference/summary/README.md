# Cogni AI Summary Action

This action generates a comprehensive summary and visual audit report of an agent's execution session by analyzing GitHub Actions job logs.

## Overview

The Summary action performs the following steps:
1.  **Log Extraction**: Retrieves logs from the `Cogni AI Agent Local` job of a specific run and attempt.
2.  **Prompt Preparation**: Formulates a detailed prompt for the auditor agent, including the execution context and the extracted logs.
3.  **Auditor Execution**: Invokes the `cogni-ai-agent-auditor` using the `ai-inference` action to generate a Mermaid-based visual audit report.

## Usage

This action is typically called after an agent execution job to provide a human-readable summary of the session.

```yaml
- name: Generate Session Summary
  uses: Cogni-AI-OU/cogni-ai-agent-action/ai-inference/summary@main
  with:
    github_token: ${{ secrets.GITHUB_TOKEN }}
```

### Advanced Usage

You can specify a different run or attempt if needed:

```yaml
- name: Generate Session Summary
  uses: Cogni-AI-OU/cogni-ai-agent-action/ai-inference/summary@main
  with:
    github_token: ${{ secrets.GITHUB_TOKEN }}
    run_id: 1234567890
    run_attempt: 1
```

## Inputs

| Input | Description | Default | Required |
| :--- | :--- | :--- | :--- |
| `github_token` | GitHub Token with permissions to read job logs | — | Yes |
| `run_id` | The ID of the workflow run to summarize | `${{ github.run_id }}` | No |
| `run_attempt` | The attempt number of the workflow run | `${{ github.run_attempt }}` | No |

## Requirements

- **Permissions**: The provided `github_token` must have `actions: read` permissions to fetch job logs.
- **Job Name**: The action specifically looks for a job named `Cogni AI Agent Local`.
- **Infrastructure**: This action depends on the `ai-inference` action located in the `ai-inference/` directory of this repository.
