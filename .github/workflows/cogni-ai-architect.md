---
# Cogni AI Architect
# Triggered by /archi
name: Cogni AI Architect
description: Runs Cogni AI Architect, an elite autonomous engineering kernel and systems architect.
engine:
  id: copilot
imports:
  - Cogni-AI-OU/cogni-ai-agents/cogni-ai-architect/cogni-ai-architect.agent.md@main
network: defaults
on:
  discussion:
    types: [created, edited, labeled]
  discussion_comment:
    types: [created, edited]
  label_command:
    name: cogni-ai-architect
    events: [pull_request]
    strategy: decentralized
  issues:
    types: [opened]
  issue_comment:
    types: [created, edited]
  pull_request:
    types: [edited, labeled, opened, reopened]
  pull_request_review_comment:
    types: [created, edited]
  workflow_dispatch:
    inputs:
      prompt:
        description: User prompt
        required: false
        default: ''
  workflow_call:
    inputs:
      prompt:
        description: User prompt
        required: false
        type: string
        default: ''
permissions:
  contents: read
  actions: read
  discussions: read
  issues: read
  pull-requests: read
safe-outputs:
  create-pull-request-review-comment:
    max: 20
  update-issue:
strict: false
steps:
  - name: Install Cogni AI agents
    shell: bash
    run: |
      git clone --depth 1 \
        https://github.com/Cogni-AI-OU/cogni-ai-agents.git \
        $HOME/.copilot/agents
  - name: Install Cogni AI skills
    shell: bash
    run: |
      git clone --depth 1 \
        https://github.com/Cogni-AI-OU/cogni-ai-agent-skills.git \
        $HOME/.copilot/skills
  - name: Install awesome-copilot plugin
    run: gh copilot -- plugin install awesome-copilot@awesome-copilot
  - name: Install devops-oncall plugin
    run: gh copilot -- plugin install devops-oncall@awesome-copilot
  - name: Install git-commit skill
    run: gh skill install github/awesome-copilot git-commit --scope user
  - name: Checkout cogni-ai-agent-instructions
    shell: bash
    run: |
      git clone --depth 1 \
        https://github.com/Cogni-AI-OU/cogni-ai-agent-instructions.git \
        ${{ runner.temp }}/.instructions
  - name: Script test
    permissions:
      pull-requests: read
      issues: read
    uses: actions/github-script@v9
    with:
      script: |
        const issueNumber = context.payload.issue?.number || context.payload.pull_request?.number || context.runId;
        const repo = context.repo.repo;
        const owner = context.repo.owner;
        const actor = context.actor;
        const isPR = !!(context.payload.issue?.pull_request || context.payload.pull_request);
        const contextType = isPR ? 'pull request' : (context.payload.issue ? 'issue' : 'workflow_dispatch');
        const sessionId = `${owner}-${repo}-${isPR ? 'pr' : (context.payload.issue ? 'issue' : 'run')}${issueNumber}`;
tools:
  bash:
    - "cat:*"
    - "echo:*"
    - "mkdir:*"
    - "tee:*"
    - "date:*"
    - "ls:*"
    - "gh:*"
    - "grep:*"
    - "git:*"
    - "pwd:*"
    - "cd:*"
    - "rm:*"
    - "mv:*"
    - "cp:*"
    - "touch:*"
    - "sed:*"
    - "awk:*"
    - "find:*"
  cache-memory: true
  cli-proxy: true
  github:
    mode: gh-proxy
    toolsets: [default, actions, issues, pull_requests]  # default: context, repos, issues, pull_requests; actions: workflow logs and artifacts
  web-fetch:
timeout-minutes: 60

---

You are Cogni AI Architect, an elite autonomous engineering kernel and systems architect.

## Current Context

- **Base SHA**: `${{ github.event.pull_request.base.sha }}`
- **Head SHA**: `${{ github.event.pull_request.head.sha }}`

{{#if github.event.pull_request.number}}
- **Issue/PR Number**: ${{ github.event.issue.number || github.run_id }}
{{/if}}

{{#if github.event.issue.number}}
- **Issue Number**: ${{ github.event.issue.number }}
{{/if}}

- **Issue/PR Title**: ${{ steps.sanitized.outputs.title }}
- **Repository**: ${{ github.repository }}
- **Triggered by**: @${{ github.actor }}
- **Triggering Content**: "${{ inputs.prompt || github.event.inputs.prompt || steps.sanitized.outputs.text }}"
{{#if github.event.workflow_run.id}}
- **Conclusion**: ${{ github.event.workflow_run.conclusion }}
- **Head SHA**: ${{ github.event.workflow_run.head_sha }}
- **Workflow Run**: [${{ github.event.workflow_run.id }}](${{ github.event.workflow_run.html_url }})
- **Workflow Trigger**: ${{ github.event.workflow_run.event }}
{{/if}}

## Important Instructions

- **Git Configuration**: The environment is pre-configured with the necessary Git identity. **NEVER** attempt to run `git config --global` as it will be blocked by security policy.
- **Committing and Pushing**: Do **NOT** attempt to manually commit or push changes using `git commit` or `git push`. The opencode infrastructure automatically handles committing and pushing your changes to the appropriate branch after you complete your task.
- **Tools**: Use the provided tools (ls, grep, cat, etc.) to explore the codebase and perform your task.
- Assign sub-issues to Copilot with `assignees: copilot` for parallel execution.
