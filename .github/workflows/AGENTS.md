# GitHub Actions Workflows (Agent Catalog)

Authoritative, agent-facing catalog of workflows in this repository. Use this when loading or modifying
workflows and keep it in sync with the files in this directory.

For a human-readable overview, see [README.md](README.md).

## Workflow catalog

- **[FLOWS.mmd](../../docs/FLOWS.mmd)**:
  Mermaid diagram describing the logic of `action.yml`.
- **[ai-inference-local.yml](ai-inference-local.yml)**:
  Tests the local `ai-inference/action.yml` action manually.
- **[ai-inference-test.yml](ai-inference-test.yml)**:
  Tests the local `ai-inference/action.yml` action on push.
- **[check.yml](check.yml)**:
  Linting and quality gates via org-level reusable workflow.
- **[cogni-ai-agent-architect.opencode.md](cogni-ai-agent-architect.opencode.md)**:
  Runs Cogni AI Architect via OpenCode (Agentic Workflow).
- **[cogni-ai-agent-local.yml](cogni-ai-agent-local.yml)**:
  Runs local `action.yml` as a wrapper for OpenCode.
- **[cogni-ai-agent-local-sudo.yml](cogni-ai-agent-local-sudo.yml)**:
  Runs local `action.yml` as a wrapper for OpenCode with elevated permissions.
- **[cogni-ai-agent-test.yml](cogni-ai-agent-test.yml)**:
  Tests the local `action.yml` action manually with predefined settings
  and matrices for agents, models, and prompts.
- **[cogni-ai-local-aw.yml](cogni-ai-local-aw.yml)**:
  Runs the local `gh-aw/action.yml` as a wrapper for the Architect workflow.
- **[copilot-setup-steps.yml](copilot-setup-steps.yml)**:
  Environment setup utility.
- **[devcontainer-ci.yml](devcontainer-ci.yml)**:
  Validates development container builds.
- **[opencode-agent-local.yml](opencode-agent-local.yml)**:
  Runs local `./opencode/action.yml` as a wrapper for OpenCode.

## Details

### ai-inference-local.yml

- Purpose: Tests the local `ai-inference/action.yml` action manually.
- Triggers: `issues`, `issue_comment`, `pull_request_review_comment`, `discussion`, `discussion_comment`,
  `workflow_dispatch`.
- Commands: `/ai`.

### ai-inference-test.yml

- Purpose: Tests the local `ai-inference/action.yml` action on push.
- Triggers: `push`.

### check.yml

- Purpose: Runs actionlint and pre-commit via org-level reusable workflow.
- Triggers: `push`, `pull_request`, `schedule`, `workflow_dispatch`.
- Reusable: `uses: Cogni-AI-OU/.github/.github/workflows/check.yml@main`.

### cogni-ai-agent-architect.opencode.md

- Purpose: Runs Cogni AI Architect, an elite autonomous engineering kernel and systems architect.
- Triggers: `issues`, `issue_comment`, `pull_request`, `pull_request_review_comment`,
  `discussion`, `discussion_comment`, `workflow_dispatch`, `workflow_call`.
- Commands: `/architect` (label), `/archi` (legacy).
- Engine: `opencode`.
- Model: `copilot/claude-sonnet-4.6`.

### cogni-ai-agent-local.yml

- Purpose: Runs local `action.yml` wrapper.
- Triggers: `issues`, `issue_comment`, `pull_request_review_comment`, `discussion`, `discussion_comment`,
  `workflow_dispatch`, `workflow_call`.
- Commands: `/co`, `/cogni`, `/review`, `/brainstorm`.

### cogni-ai-agent-local-sudo.yml

- Purpose: Runs local `action.yml` wrapper with elevated permissions.
- Triggers: `issues`, `issue_comment`, `pull_request_review_comment`, `discussion`, `discussion_comment`,
  `workflow_dispatch`, `workflow_call`.
- Commands: `/sudo`.

### cogni-ai-agent-test.yml

- Purpose: Tests the local `action.yml` action manually with predefined settings
  and matrices for agents, models, and prompts.
- Triggers: `pull_request`, `pull_request_review_comment`, `pull_request_target`, `workflow_dispatch`.

### cogni-ai-local-aw.yml

- Purpose: Runs the local `gh-aw/action.yml` as a wrapper for the Architect workflow.
- Triggers: `workflow_dispatch`.
- Details: Dispatches `.github/workflows/cogni-ai-agent-architect.opencode.lock.yml` via the `gh-aw` composite action.

### copilot-setup-steps.yml

- Purpose: Utility workflow for setting up the environment.
- Triggers: `push` and `pull_request` on `copilot-setup-steps.yml` or `.devcontainer/requirements.txt`.
- Details: Checks out repo, sets up Python 3.12, restores cache, and installs dependencies.

### devcontainer-ci.yml

- Purpose: Tests devcontainer builds and validates required tools.
- Triggers: `pull_request`, `push`.
- Reusable: `uses: Cogni-AI-OU/.github/.github/workflows/devcontainer-ci.yml@main`.

### opencode-agent-local.yml

- Purpose: Runs local `./opencode/action.yml` wrapper.
- Triggers: `issues`, `issue_comment`, `pull_request_review_comment`, `discussion`, `discussion_comment`,
  `workflow_dispatch`, `workflow_call`.
- Commands: `/oc`, `/opencode`, `/review`.

## Notes

- Ensure workflow files follow standard project conventions (ordering, formatting, validation).
- Keep this catalog updated when workflows are added, removed, or renamed.
