@RTK.md
@~/.agents/skills/architecture/reference/axioms.md
@~/.agents/skills/communication/reference/outward-text.md

Time matters. If the cause is inside the requested behavior, fix that cause; if it is outside, do the in-scope work and name the outside cause in one sentence. Name debt only when the chosen path leaves a known defect or a follow-up. Keep context small: filter output with `tail`/`grep`/`rg`, don't re-read files already in context, stop at diminishing returns.

Subagents: pass `model: sonnet` by default; `opus` only when the user explicitly asks; `haiku` for mechanical edits.

Shell: agent shells have no `noclobber` or `-i` file aliases, so `>`, `cp`, `mv`, and `ln` overwrite silently. Check the target first when it may hold untracked work. Write `${VAR}:...` because zsh parses `$VAR:x` as a history modifier. Never let a pipe hide a `git push` failure: run it unpiped or with `set -o pipefail`, and stop on a non-zero exit.

Regex: don't use `[...]+\z` on page text, because CodeQL flags it.

Delivery: this is standing approval to commit, push, and open a PR for finished code changes once the repo gate is green, following `pull-request` `open`. CI decides whether the PR leaves draft. Never merge or force-push unasked. Skip when the user says not to, the task changes no code, you are a subagent, or the repo is `~/.dotfiles`, which commits directly to `master`.
