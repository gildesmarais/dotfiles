# Jira adapter

Atlassian MCP required. Tracker facts per `SKILL.md` Shared prep. Rows mirror `github.md`; this file owns only the Jira column.

| Concept           | Jira                                                                                                   |
| ----------------- | ------------------------------------------------------------------------------------------------------ |
| Ticket ID         | Issue key (`ABC-123`) or issue URL; branch prefix is the key                                           |
| Fetch             | `getJiraIssue` for the Shared prep fields (parent or Epic Link field); linked Confluence pages         |
| Status change     | `getTransitionsForJiraIssue` first; transition by the listed name                                      |
| Hierarchy         | `parent` (or the project's Epic Link field); re-read to verify                                         |
| Link / blocking   | `getIssueLinkTypes`; use the exact type name (often `Blocks`)                                          |
| Comment           | `addCommentToJiraIssue`                                                                                |
| Close with reason | Transition to Done / Won't Do / Duplicate; set the archive flag and the terminal board-column field so grouped views hide it |
| Post-PR sync      | Transition via Status change; comment via Comment                                                      |
| Create type       | `createJiraIssue` with Story / Task / Bug (Epic for an epic)                                           |
| Epic shape        | Start and due date fields; portfolio item link via the project's portfolio link type                   |
