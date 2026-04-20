## Challenge

The agent struggles to correctly resolve relative paths for skill files (such as `ansible/SKILL.md` or references to `.github/skills/...`). This occurs because the skills repository is cloned into an external temporary directory (`$RUNNER_TEMP/.skills`) during the GitHub Actions run, whereas the agent's current working directory (CWD) is set to the project repository root.

Since LLMs lack the automatic relative path resolution mechanism that browsers have, when the agent encounters a relative link in a Markdown file, it typically tries to resolve it against its CWD, resulting in "File Not Found" errors.

## Current Workaround

As implemented in [PR #26](https://github.com/Cogni-AI-OU/cogni-ai-agent-action/pull/26), the current approach uses `sed` to rewrite paths on the fly inside the Markdown files before they are fed to the agent. While this effectively forces absolute paths and reduces the cognitive load for the agent, it is a brittle workaround that relies on the specific formatting of Markdown links.

## Proposed Options

Instead of modifying the text of the Markdown files, we could consider the following architectural alternatives:

### Option 1: Symlinking (Clean Shell-Level Fix)

We can create a symbolic link in the runner's project workspace that points to the temporary skills directory:

```bash
ln -s ${{ runner.temp }}/.skills .github/skills
```

Since the agent is already instructed to look in `.github/skills` by default, this symlink allows standard paths to work perfectly without requiring regex-based text replacements.

### Option 2: Using a Dedicated Tool (Clean Architecture Fix)

Relying on generic file system tools (`read`, `write`, `bash`) for skill loading is error-prone. The ideal solution is to utilize the dedicated `skill` tool (which is currently stubbed out/empty). 

By implementing the backend logic for the `skill` tool within the GitHub Action framework, the agent would no longer need to read the raw Markdown catalog. Instead, it could simply call a tool like `skill(name="git")`, and the underlying Python/Node.js script would handle path resolution against the temporary directory, read the file, and seamlessly return the context.