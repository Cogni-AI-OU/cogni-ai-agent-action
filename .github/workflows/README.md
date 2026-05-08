# GitHub Workflows and Actions

This directory contains GitHub Actions workflows, agent prompts, and related configuration.

## Workflows

### Check Workflow (`check.yml`)

The `check.yml` workflow runs on pull requests, pushes, and weekly schedule to
ensure code quality and correctness.

Jobs:

- **actionlint**: Validates GitHub Actions workflow files
- **link-checker**: Checks for broken links in Markdown files using Lychee
- **pre-commit**: Runs pre-commit hooks for code formatting and linting

### Devcontainer CI Workflow (`devcontainer-ci.yml`)

The `devcontainer-ci.yml` workflow builds and tests the development container image.
It ensures that all required command-line tools and Python packages are properly installed and functional.

### Local/Test Workflows

- **ai-inference-local.yml**: Tests the local `ai-inference/action.yml` action manually.
- **ai-inference-test.yml**: Tests the local `ai-inference/action.yml` action on push.
- **cogni-ai-agent-local.yml**: Runs local `action.yml` as a wrapper for OpenCode.
- **cogni-ai-agent-local-sudo.yml**: Runs local `action.yml` as a wrapper for OpenCode with elevated permissions.
- **cogni-ai-agent-test.yml**: Tests the local `action.yml` action manually.
- **opencode-agent-local.yml**: Runs local `./opencode/action.yml` as a wrapper for OpenCode.
- **task-update-docs.yml**: Update core architecture and documentation files.
- **test-constraints.yml**: Runs MiniZinc constraints check.

## Problem Matchers

GitHub Actions problem matchers automatically annotate files with errors and
warnings in pull requests, making it easier to identify and fix issues.

- **actionlint-matcher.json**: Captures errors from actionlint workflow linting.
- **pre-commit-matcher.json**: Captures errors from various pre-commit hooks.
