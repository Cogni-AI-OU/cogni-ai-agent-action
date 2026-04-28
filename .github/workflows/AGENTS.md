# GitHub Actions Workflows (Agent Catalog)

Authoritative, agent-facing catalog of workflows in this repository. Use this when loading or modifying
workflows and keep it in sync with the files in this directory.

For a human-readable overview, see [README.md](README.md).

## Workflow catalog

- **[FLOWS.mmd](../../FLOWS.mmd)**: Mermaid diagram describing the logic of `action.yml`.
- **[ai-inference-local.yml](ai-inference-local.yml)**: Tests the local `ai-inference/action.yml` action manually.
- **[ai-inference-test.yml](ai-inference-test.yml)**: Tests the local `ai-inference/action.yml` action on push.
- **[check.yml](check.yml)**: Linting and quality gates via org-level reusable workflow.
- **[cogni-ai-agent-local.yml](cogni-ai-agent-local.yml)**: Runs local `action.yml` as a wrapper for OpenCode.
- **[copilot-setup-steps.yml](copilot-setup-steps.yml)**: Environment setup utility.
- **[opencode-agent-local.yml](opencode-agent-local.yml)**: Runs local `./opencode/action.yml` as a wrapper for OpenCode.
- **[opencode.yml](opencode.yml)**: Invokes org-level reusable OpenCode workflow manually.

## Details

### ai-inference-local.yml

- Purpose: Tests the local `ai-inference/action.yml` action manually.
- Triggers: `workflow_dispatch`.

### ai-inference-test.yml

- Purpose: Tests the local `ai-inference/action.yml` action on push.
- Triggers: `push`.

### check.yml

- Purpose: Runs actionlint and pre-commit via org-level reusable workflow.
- Triggers: `push`, `pull_request`.
- Reusable: `uses: Cogni-AI-OU/.github/.github/workflows/check.yml@main`.

### cogni-ai-agent-local.yml

- Purpose: Runs local `action.yml` wrapper.
- Triggers: `issues`, `issue_comment`, `pull_request_review_comment`, `discussion`, `discussion_comment`, `workflow_dispatch`, `workflow_call`.
- Commands: `/co`, `/cogni`, `/review`.

### copilot-setup-steps.yml

- Purpose: Utility workflow for setting up the environment.
- Triggers: `push` and `pull_request` on `copilot-setup-steps.yml` or `.devcontainer/requirements.txt`.
- Details: Checks out repo, sets up Python 3.12, restores cache, and installs dependencies.

### opencode-agent-local.yml

- Purpose: Runs local `./opencode/action.yml` wrapper.
- Triggers: `issues`, `issue_comment`, `pull_request_review_comment`, `discussion`, `discussion_comment`, `workflow_dispatch`, `workflow_call`.
- Commands: `/oc`, `/opencode`, `/review`.

### opencode.yml

- Purpose: Invokes org-level reusable OpenCode workflow.
- Triggers: `workflow_dispatch`.

## Notes

- Ensure workflow files follow standard project conventions (ordering, formatting, validation).
- Keep this catalog updated when workflows are added, removed, or renamed.
