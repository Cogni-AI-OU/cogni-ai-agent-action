# AGENTS-RUNTIME

<!-- markdownlint-disable MD013 -->

## SUBAGENT DELEGATION POLICY

The use of the `task` tool and spawning sub-agents is permitted for complex, multi-step tasks, but delegation is limited to the project agents explicitly configured by this runtime.

- **Allowed Delegation Targets**:
  Use only the named project agents exposed by this runtime configuration.
- **Built-in Subagents Disabled**:
  Built-in `explore` and `general` subagents are not approved for this runtime and MUST NOT be used, even if a host tool still lists them.
- **Maintain Context**:
  Ensure that the primary agent remains the coordinator and synthesizes the results from sub-agents into the final response.
- **Strategic Delegation**:
  Delegate only when the task involves broad codebase analysis or independent sub-tasks that can be executed in parallel.

## Initialization Project Sequence

1. **Agent Contract Alignment**:
   Locate, read, and strictly enforce the invariants defined in the current project workspace's main `AGENTS.md`, `CONSTRAINTS.mzn`, and any of its directory-specific `AGENTS.md`. Do not commence context gathering or strategy formulation without synchronizing with these directives first.
2. **Skill & Instruction Loading**:
   Autonomously discover and load `.github/copilot-instructions.md`, relevant `.instructions.md` rules, and applicable `SKILL.md` workflows.
3. **URL & Link Processing**:
   For any URLs or links provided in the user prompt, you MUST load and analyze their content using available web retrieval tools to ensure the most up-to-date context is incorporated into your strategy.
4. **Context Gathering for Ambiguity**:
   For ambiguous queries, you MUST load the project's `README.md`, relevant documentation, and files from the project codebase to establish sufficient context.
5. **Session Task Initialization**:
   Ensure appropriate todos are created before starting work, so the session can be continued upon restart.

## Path Resolution for Instructions and Skills

When instructions are loaded from a temporary directory (e.g., `${{ runner.temp }}/.agents/` or `${{ runner.temp }}/.skills/`), you MUST resolve any relative paths mentioned within those files against the directory where the instruction file itself is located.

To determine the base directory for an instruction file, check the `Instructions from: <path>` header provided in your system prompt. Do NOT assume paths are relative to your current working directory unless the instruction file explicitly states otherwise or is located within your project's workspace.

## GitHub Actions Runtime

You are running as an autonomous agent via the `cogni-ai-agent-action` GitHub action through the OpenCode integration within a GitHub runner environment. The project resides in `/home/runner/work/` in the GitHub runner.

### Action Runtime Internals

- **Internal Flow Reference**:
  ONLY when explicitly asked about the internal step-by-step logic, concurrency polling, or execution flow of the `cogni-ai-agent-action` runtime itself, you MUST refer to [FLOWS.mmd](./FLOWS.mmd) for the complete architectural mapping.
- **Formal Constraint Model**:
  Refer to [CONSTRAINTS.mzn](./CONSTRAINTS.mzn) for the formal definition of runtime bounds, budgets, and logical enforcing functions.
- **Routing & Sync Policies**:
  Refer to the `github-pr` and `github-issue` skills
  for OpenCode PR Context, Response Routing, Branch Syncing, Pre-Completion Upstream Sync,
  and restricted shell caveats.

### General Constraints

- **Contextual Continuity**: Maintain conversation context within the originating thread.
- **Minimal Scope & Focused Execution**: ALWAYS narrow down your focus strictly to the original user prompt or task.
  Perform minimal refactoring and avoid broad or massive changes outside the explicitly requested scope.
  Do not auto-discover and modify unrelated files.

### Workspace & Syncing Invariants

- **Git File Operations**:
  Use `git mv`, `git rm`, or equivalent Git-aware tooling (instead of `mv` or `rm`) to preserve history when working with files under source control.
- **No Untracked Additions**:
  NEVER automatically commit untracked files or workspace artifacts (like temporary API payloads, script outputs, `.github/ISSUE_TEMPLATE/*`, or `CODE_OF_CONDUCT.md`) unless explicitly specified in the synchronization checklist or explicitly asked by the user. Always clean up temporary files created during execution.
- **Selective Sync**:
  Do not blindly copy entire directories from remote templates. Cherry-pick only the files that are meant to be updated or created.
- **Strict File Syncing**:
  When syncing configuration files from an external repository or template, only modify or copy the specific files requested.
- **Final Status Check**:
  ALWAYS run `git status` at the end of your work before completion to verify the final workspace state and ensure no unintended modifications or untracked files remain.
- **Final Origin Sync**:
  ALWAYS pull from the origin after completion of the work to ensure the codebase is up-to-date.

### Commit & CI/CD Invariants

- **CI/CD Failure Escalation**:
  When CI/CD pipelines or automated checks fail, do NOT immediately patch local configuration files or create suppressions to hide errors. Investigate the execution environment and upstream dependencies. If the root cause originates outside the repository scope, state the required upstream fix clearly and halt rather than introducing local entropy.
- **No Garbage Commits**:
  Ensure no dummy or unrelated test files (such as API payloads, bash script outputs, or generated markdown comments) are included in the commit.
- **Verify Before Commit**:
  Verify your expected changes with `git diff --no-color`. NEVER use blanket `git add .` without verifying the exact list of staged files.

## Firewall issues

If you encounter firewall issues when using the GitHub Copilot Agent:

- Refer to <https://gh.io/copilot/firewall-config> for configuration details.
- Do not workaround blocked URLs by whitelisting them in the existing configurations.
