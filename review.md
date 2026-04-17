GitHub Actions expressions do not natively support arithmetic operators like subtraction (`-`). Because of this, the expression `${{ github.run_attempt - 1 }}` is invalid syntax and will result in a workflow parsing error.

Fortunately, GitHub Actions automatically exposes variables like `GITHUB_RUN_ATTEMPT`, `GITHUB_RUN_ID`, `GITHUB_REPOSITORY`, and `GITHUB_SERVER_URL` to the shell environment. It is much safer to calculate the previous attempt and construct the URL directly inside the `bash` block.

I recommend removing `PREVIOUS_BUILD_URL` from the `env:` block and updating the bash logic like this:

```diff
       env:
         COMMENT_BODY: >-
           ${{ github.event_name == 'issues' && github.event.issue.body ||
           github.event.comment.body || '' }}
         ISSUE_NUMBER: ${{ github.event.issue.number || github.event.pull_request.number || '' }}
-        PREVIOUS_BUILD_URL: >-
-          ${{ github.run_attempt > 1 &&
-          format('{0}/{1}/actions/runs/{2}/attempts/{3}',
-          github.server_url, github.repository, github.run_id,
-          github.run_attempt - 1) || '' }}
         PROMPT_INPUT: ${{ inputs.prompt }}
       run: |
         set -euo pipefail
         prompt="${PROMPT_INPUT:-}"
         if [ -z "$prompt" ]; then
           prompt="${COMMENT_BODY:-}"
         fi
         if [ -n "${ISSUE_NUMBER:-}" ]; then
           if [ -n "$prompt" ]; then
             prompt=$(printf 'Related to issue/PR #%s\n\n%s' "$ISSUE_NUMBER" "$prompt")
           else
             prompt="Related to issue/PR #${ISSUE_NUMBER}"
           fi
         fi
-        if [ -n "${PREVIOUS_BUILD_URL:-}" ]; then
+        if [ "${GITHUB_RUN_ATTEMPT:-1}" -gt 1 ]; then
+          prev_attempt=$(( GITHUB_RUN_ATTEMPT - 1 ))
+          previous_build_url="${GITHUB_SERVER_URL}/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}/attempts/${prev_attempt}"
           rerun_note="Note: This is a re-run of a previous build attempt."
           rerun_note+=" Check the previous attempt to understand what was"
           rerun_note+=" already done and continue from where it left off:"
-          rerun_note+=" ${PREVIOUS_BUILD_URL}"
+          rerun_note+=" ${previous_build_url}"
           prompt=$(printf '%s\n\n%s' "$prompt" "$rerun_note")
         fi
         {
           echo 'prompt<<EOF'
           printf '%s\n' "$prompt"
           echo 'EOF'
         } >> "$GITHUB_OUTPUT"
```