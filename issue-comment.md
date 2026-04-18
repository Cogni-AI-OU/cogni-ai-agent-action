### Implementation Analysis & Solution Root Cause

The upstream `opencode github run` CLI command (used by `anomalyco/opencode/github@v1.4.3`) maintains a hardcoded list of supported event types. `push` is not in this list, causing the `Unsupported event type: push` error seen in the failing build.

Internally, `opencode` categorizes GitHub events into two groups:
1. **Issue/PR events** (`issue_comment`, `pull_request_review_comment`, `issues`, `pull_request`) — require issue/PR context
2. **Repo events** (`schedule`, `workflow_dispatch`) — no issue/PR context, accept a `PROMPT` env var, create a new branch, do work, and optionally create a PR

The `push` event semantically belongs in the "repo events" category but was never added upstream.

### Solution Options Evaluated

#### Option A: Event Masquerade — Map `push` → `workflow_dispatch` ✅ (Implemented)
Since `workflow_dispatch` already does everything needed for `push` events (accepts `PROMPT` env var, creates a branch, does work, creates a PR), we can masquerade `push` as `workflow_dispatch`:

- **Check conditions step:** Added `push` handler that sets `run=true` and `agent='cogni-ai-architect'`
- **Resolve prompt step:** For `push` events, constructs the prompt from `head_commit.message` and `ref` when no explicit `inputs.prompt` is provided
- **GITHUB_EVENT_NAME override:** Maps `push` → `workflow_dispatch` using the same short-circuit expression pattern as the existing `pull_request_target` → `pull_request` mapping

Implemented in: `copilot/investigate-push-event-support` branch — changes to both `action.yml` and `opencode/action.yml`.

Key code changes:

```javascript
// Check conditions — new push handler
} else if (eventName === 'push') {
  run = true;
  agent = 'cogni-ai-architect';
```

```bash
# Resolve prompt — push-specific prompt construction
if [ "$EVENT_NAME" = "push" ] && [ -n "${HEAD_COMMIT_MESSAGE:-}" ]; then
  prompt="${HEAD_COMMIT_MESSAGE}"
  if [ -n "${PUSH_REF:-}" ]; then
    prompt=$(printf 'Push to %s\n\n%s' "$PUSH_REF" "$prompt")
  fi
```

```yaml
# GITHUB_EVENT_NAME — masquerade push as workflow_dispatch
GITHUB_EVENT_NAME: >-
  ${{ github.event_name == 'pull_request_target' && 'pull_request'
  || github.event_name == 'push' && 'workflow_dispatch'
  || github.event_name }}
```

**Known risk:** The event payload will still have `push` structure (commits, ref, etc.) instead of `workflow_dispatch` structure. Testing is needed to confirm `opencode` does not read payload fields that would cause runtime errors for `workflow_dispatch` events. The `PROMPT` env var is the primary input mechanism for repo events, so the payload mismatch is likely benign.

#### Option B: Bypass `opencode github run` ❌ (Too Complex)
Start `opencode serve`, create a session via the API, and handle git operations manually. This duplicates too much of what `opencode github run` already provides and would be fragile to upstream API changes.

#### Option C: Contribute Push Support Upstream 🔜 (Recommended Medium-Term)
File a PR on `anomalyco/opencode` to add "push" to `REPO_EVENTS` in `packages/opencode/src/cli/cmd/github.ts`. This is the cleanest solution and benefits the wider community.

#### Option D: Wait for Upstream Support ⏳ (Fallback)
Monitor anomalyco/opencode#23314. Timeline is unpredictable — the similar `pull_request_target` issue (#9196) was never fixed.