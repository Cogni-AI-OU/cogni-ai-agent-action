# GitHub Workflows and Actions

This directory contains GitHub Actions workflows, agent prompts, and related configuration.

## Workflows

### Check Workflow (`check.yml`)

The `check.yml` workflow runs on pull requests and pushes to ensure code quality and correctness.
It calls the org-level reusable `check.yml` workflow.

Jobs:

- **actionlint**: Validates GitHub Actions workflow files
- **link-checker**: Checks for broken links in Markdown files using Lychee
- **pre-commit**: Runs pre-commit hooks for code formatting and linting

### Cogni AI Agent Local Workflow (`cogni-ai-agent-local.yml`)

The `cogni-ai-agent-local.yml` workflow runs the local composite action (`./action.yml`) as a wrapper for OpenCode.
It is triggered by `/co`, `/cogni`, or `/review` commands in comments, or manually via `workflow_dispatch`/`workflow_call`.

### OpenCode Workflow (`opencode.yml`)

The `opencode.yml` workflow calls the org-level reusable OpenCode workflow. It is triggered manually via `workflow_dispatch`.

### OpenCode Agent Local Workflow (`opencode-agent-local.yml`)

The `opencode-agent-local.yml` workflow runs the local composite action (`./opencode/action.yml`) as a wrapper for OpenCode.
It is triggered by `/oc`, `/opencode`, or `/review` commands in comments, or manually via `workflow_dispatch`/`workflow_call`.

### Copilot Setup Steps Workflow (`copilot-setup-steps.yml`)

The `copilot-setup-steps.yml` workflow is a utility workflow that checks out the repository, sets up Python 3.12,
restores the Python user site cache, and installs dependencies from `.devcontainer/requirements.txt`. It is triggered
on pushes and pull requests that modify the workflow file or the requirements file.

## Problem Matchers

GitHub Actions problem matchers automatically annotate files with errors and
warnings in pull requests, making it easier to identify and fix issues.

The matchers are provided from the org-level `.github` repository when using
the `check.yml` reusable workflow.
