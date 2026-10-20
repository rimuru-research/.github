# .github

Organization-wide files of rimuru-research.

| path | purpose |
|---|---|
| `profile/README.md` | the organization's front page |
| `CONTRIBUTING.md` | conventions for issues, branches, commits, results and repository hygiene |
| `.github/ISSUE_TEMPLATE/` | the Task, Experiment and Bug forms, used by every repository that has none of its own |
| `.github/pull_request_template.md` | default pull request description |
| `scripts/new-project.sh` | opens a new project: repository from the template, labels, project board, team |

```bash
scripts/new-project.sh <repo-name> "<one-line description>" [--public]
```
