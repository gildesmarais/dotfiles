# GitHub adapter

`gh` CLI. Facts in `<project>/.agents/tracker.md` (project number + owner, status field and option names, labels) win; else discover per repo (never hardcode). Rows mirror `jira.md`; this file owns only the GitHub column. Check flags with `gh <cmd> --help` before relying on them.

| Concept           | GitHub                                                                                                 |
| ----------------- | ------------------------------------------------------------------------------------------------------ |
| Ticket ID         | `owner/repo#12`, `#12`, or issue URL; branch prefix is the number                                      |
| Fetch             | `gh issue view <n> --comments`; structure via `--json parent,subIssues,blockedBy,blocking,labels,milestone,projectItems,issueType` |
| Status change     | Projects v2 Status field: `gh project field-list <proj> --owner <owner>` for options, then `gh project item-edit <proj> --owner <owner> --url <issue-url> --field Status --value "<option>"`; no project → open/closed only |
| Hierarchy         | Sub-issues: `gh issue create --parent <p>` / `gh issue edit <n> --parent <p>`; milestones (`--milestone`) where the repo groups that way |
| Link / blocking   | `gh issue edit <n> --add-blocked-by <m>` / `--add-blocking <m>`; other relations: mention `#m` in a comment |
| Comment           | `gh issue comment <n> --body-file -`                                                                   |
| Close with reason | `gh issue close <n> --reason completed` / `--reason "not planned"`; duplicate: `--duplicate-of <m>`; `--comment` carries the redirect; hiding from grouped views: discover per repo |
| Post-PR sync      | PR body carries `Closes #N` (`gh pr edit <pr> --body-file -` if `open` missed it); GitHub closes it on merge; move the project Status to the review option if the project has one |
| Create type       | `gh issue create --title <t> --body-file - --type <Type>` where the org defines issue types; else `--label` (names: discover per repo) |
| Epic shape        | Parent issue with sub-issues; start/due via project date fields (`gh project item-edit --date`); portfolio link: discover per repo |
