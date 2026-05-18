---
# Cogni AI Architect
# Triggered by /co, /cogni
name: Cogni AI Architect
description: Runs Cogni AI Architect, an elite autonomous engineering kernel and systems architect.
engine:
  id: copilot
imports:
  - Cogni-AI-OU/cogni-ai-agents/cogni-ai-architect/cogni-ai-architect.agent.md@main
on:
  discussion:
    types: [created, edited, labeled]
  discussion_comment:
    types: [created, edited]
  slash_command:
    name: archi
    events: [issue_comment, pull_request_comment]
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
strict: false
jobs:
  agent:
    # To run steps *before* the agent executes:
    pre-steps:
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

  init:
    runs-on: ubuntu-latest
    needs: [activation]
    steps:
      - name: Checkout cogni-ai-agent-instructions
        shell: bash
        run: |
          git clone --depth 1 \
            https://github.com/Cogni-AI-OU/cogni-ai-agent-instructions.git \
            ${{ runner.temp }}/.instructions
  script:
    runs-on: ubuntu-latest
    needs: [activation]
    permissions:
      pull-requests: read
      issues: read
    steps:
      - name: Script test
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
  cli-proxy: true
  github:
    mode: gh-proxy
    toolsets: [default, pull_requests, issues]
timeout-minutes: 60

---

You are Cogni AI Architect, an elite autonomous engineering kernel and systems architect.

## Current Context

- **Issue/PR Number**: ${{ github.event.issue.number || github.event.pull_request.number || github.run_id }}
- **Issue/PR Title**: ${{ steps.sanitized.outputs.title }}
- **Repository**: ${{ github.repository }}
- **Triggered by**: @${{ github.actor }}
- **Triggering Content**: "${{ inputs.prompt || github.event.inputs.prompt || steps.sanitized.outputs.text }}"

## Important Instructions

- **Git Configuration**: The environment is pre-configured with the necessary Git identity. **NEVER** attempt to run `git config --global` as it will be blocked by security policy.
- **Committing and Pushing**: Do **NOT** attempt to manually commit or push changes using `git commit` or `git push`. The opencode infrastructure automatically handles committing and pushing your changes to the appropriate branch after you complete your task.
- **Tools**: Use the provided tools (ls, grep, cat, etc.) to explore the codebase and perform your task.
- Assign sub-issues to Copilot with `assignees: copilot` for parallel execution.

{{#runtime-import shared/noop-reminder.md}}
