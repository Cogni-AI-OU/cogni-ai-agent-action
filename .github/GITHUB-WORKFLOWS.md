# GitHub Workflows, Agents, and Problem Matchers

This document provides an overview of the GitHub Actions workflows, agent prompts, and problem matchers used in
this repository.

## Workflow Templates Overview

This repository utilizes several standard GitHub Actions workflows to automate development tasks:

- **Check Workflow (`check.yml`)**: Runs linting (actionlint, pre-commit) and link checking (lychee) to ensure code
  quality and documentation consistency.
- **Cogni AI Agent Workflow (`cogni-ai-agent.yml`)**: Enables AI-assisted development tasks through the
  Cogni AI Agent.
- **OpenCode Workflow (`opencode.yml`)**: Provides AI-assisted automation via slash commands in issue and
  pull request comments.
- **Devcontainer CI Workflow (`devcontainer-ci.yml`)**: Validates development container builds and ensures
  required tools are functional.

## Agent Prompts Usage

Prompts for AI agents are stored in the `.github/prompts/` directory. These prompts are used to guide AI agents in
performing specific tasks, such as repository setup, PR reviews, and automated testing.

- **Loading Prompts**: Agents can load specific prompts by referencing their filenames.
- **Prompt Catalog**: See [.github/prompts/AGENTS.md](prompts/AGENTS.md) for a list of available prompts and
  their purposes.

## Problem Matchers Configuration

Problem matchers are used to annotate GitHub Actions workflow runs with errors and warnings.

- **actionlint-matcher.json**: Captures errors from GitHub Actions workflow linting.
- **pre-commit-matcher.json**: Captures errors from various pre-commit hooks.

These matchers are automatically registered during workflow execution.

## Security Notes

### OpenCode and AI Agent Security

The AI agents operating in this repository have permissions to perform code changes and interact with GitHub
resources. To maintain security:

- **Access Control**: Only trusted collaborators can trigger AI agent workflows.
- **Branch Protection**: Critical branches (like `main`) are protected by rules that require pull request reviews
  and passing status checks.
- **Audit Logs**: All AI agent actions are recorded in GitHub workflow logs and audit logs for review.

### Secrets Management

Workflows that require external API access (like OpenCode) use encrypted GitHub secrets. Ensure that secrets are
managed securely and rotated periodically.

## Repository-Specific Workflows

*Add documentation for any custom workflows specific to this repository here.*
