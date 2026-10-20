# .github

Organization-wide files of rimuru-research.

| path | purpose |
|---|---|
| `profile/README.md` | the organization's front page |
| `CONTRIBUTING.md` | conventions for issues, branches, commits, results and repository hygiene |
| `.github/ISSUE_TEMPLATE/` | the Task, Experiment and Bug forms, used by every repository that has none of its own |
| `.github/pull_request_template.md` | default pull request description |
| `scripts/new-project.sh` | opens a project: repository (from the template, or an existing folder), labels, project board, team |

```bash
scripts/new-project.sh <repo-name> "<one-line description>" [--public]                  # new project from the template
scripts/new-project.sh <repo-name> "<one-line description>" [--public] --source <dir>   # existing project folder
```

For an existing folder, prepare it first: `git init -b main`; copy `scripts/check-repo.sh`, `.githooks/`,
`.github/workflows/check.yml`, `.gitattributes` and the `.gitignore` from `project-template`; add the project's own
ignore rules (other people's material, data, build products) and a README that lists what stays outside; commit.
The script refuses a folder with uncommitted changes or one where the hygiene check fails.

On Windows, git follows directory junctions: ignore any junction in the folder (for example `.claude/skills`) or
its target is stored twice.
