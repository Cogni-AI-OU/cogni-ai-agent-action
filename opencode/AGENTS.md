# OpenCode Agent Protocols

Authoritative, agent-facing catalog of protocols and invariants for the `opencode/` directory.

## Invariants

- **Conditional Execution**:
  The `opencode/action.yml` action now handles conditional execution internally via a `Check conditions` step.
  It evaluates `mentions` and `mentions_bots` to determine if the agent should run.
- **Default Triggers**:
  Do NOT change the default triggers for the OpenCode action in `opencode/action.yml`.
  The current default triggers are `/oc`, `/opencode`, and `/review`.
- **Scope**:
  The OpenCode action in this directory is intended to be a generic wrapper for OpenCode and should remain decoupled
  from specialized Cogni AI agent triggers (like `/brainstorm`) unless explicitly requested.

## Directory structure

- **[action.yml](action.yml)**: The composite action metadata and logic.
- **[README.md](README.md)**: Documentation for the OpenCode action.

## OpenCode Tools

### OpenCode (MCP) Tools

When operating via OpenCode in the GitHub Actions runtime, the following MCP tools are available and
should be utilized to perform tasks effectively:

- **vscode**: `getProjectSetupInfo`, `installExtension`, `memory`, `newWorkspace`, `resolveMemoryFileUri`, `runCommand`,
  `vscodeAPI`, `extensions`, `askQuestions`
- **execute**: `runNotebookCell`, `testFailure`, `getTerminalOutput`, `killTerminal`, `sendToTerminal`,
  `createAndRunTask`, `runInTerminal`
- **read**: `getNotebookSummary`, `problems`, `readFile`, `viewImage`, `terminalSelection`, `terminalLastCommand`
- **edit**: `createDirectory`, `createFile`, `createJupyterNotebook`, `editFiles`, `editNotebook`, `rename`
- **search**: `changes`, `codebase`, `fileSearch`, `listDirectory`, `textSearch`, `usages`
- **web**: `fetch`, `githubRepo`
- **browser**: `openBrowserPage`
- **agent**: `runSubagent`
- **misc**: `vscode.mermaid-chat-features/renderMermaidDiagram`, `ms-python.python/getPythonEnvironmentInfo`,
  `ms-python.python/getPythonExecutableCommand`, `ms-python.python/installPythonPackage`, `todo`

### OpenCode Core Native Agent Tools

In addition to the MCP integrations, the agent runtime provides a set of core built-in capabilities
(often logged during builds as `Glob`, `Todo` or `TodoWrite`, `Edit`, etc.). These are executed directly by
the agent's core engine, rather than through the OpenCode MCP protocol.

Available native tools include:

- **File System & Search**: `Glob` (fast file pattern matching), `Grep` (fast content search),
  `Read` (read files/directories)
- **File Mutation**: `Edit` (exact string replacements), `Write` (overwrite/create files)
- **Execution**: `Bash` (persistent shell session for terminal operations like git, npm, etc.)
- **Agentic Tracking**: `Todo` / `TodoWrite` (creates and manages structured task lists for complex sessions)
- **Research & Sub-agents**: `Task` (launch specialized sub-agents), `Webfetch`, `Websearch`, `Codesearch`

*Note: The native tools `Glob`, `Read`, `Grep`, `Edit`, and `Write` are explicitly prioritized over their shell
equivalents (such as `find`, `cat`, `grep`, `sed`) to ensure precise context retention and safety.*
