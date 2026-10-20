#!/usr/bin/env bash
# Open a new project in the rimuru-research organization.
#
#   scripts/new-project.sh <repo-name> "<one-line description>" [--public]
#
# 1. creates rimuru-research/<repo-name> from the template rimuru-research/project-template (private by default)
# 2. sets the organization's label set on it
# 3. links it to the organization project board "Rimuru Research"
# 4. creates a team of the same name with write access to the repository
# Safe to rerun: every step checks what already exists.  Needs gh with the scopes repo, admin:org, project.
set -euo pipefail

ORG=rimuru-research
TEMPLATE="$ORG/project-template"
BOARD="Rimuru Research"

[[ $# -ge 2 ]] || { sed -n '2,10p' "$0"; exit 2; }
NAME=$1; DESC=$2; VIS=--private
[[ ${3:-} == --public ]] && VIS=--public
[[ $NAME =~ ^[a-z0-9][a-z0-9-]{1,62}$ ]] || { echo "repo name: lowercase letters, digits and '-' only"; exit 2; }
REPO="$ORG/$NAME"

# 1. repository
if gh repo view "$REPO" > /dev/null 2>&1; then
    echo "repo   $REPO exists"
else
    gh repo create "$REPO" "$VIS" --template "$TEMPLATE" --description "$DESC" > /dev/null
    echo "repo   $REPO created from $TEMPLATE ($VIS)"
fi

# 2. labels: name|colour|description
while IFS='|' read -r label colour text; do
    [[ -z $label ]] && continue
    gh label create "$label" --repo "$REPO" --color "$colour" --description "$text" --force > /dev/null
done <<'LABELS'
task|1D76DB|Planned work item
experiment|5319E7|Measurement or study with a question, a metric and a threshold
bug|D73A4A|Something produces a wrong result
docs|0075CA|Documentation
blocked|B60205|Waiting on something outside the issue
area:model|C5DEF5|Reference or golden model
area:rtl|C5DEF5|RTL design
area:verification|C5DEF5|Testbenches and regressions
area:fpga|C5DEF5|FPGA implementation and board
area:asic|C5DEF5|ASIC flow
area:paper|C5DEF5|Papers, reports, slides
LABELS
echo "labels set"

# 3. project board
num=$(gh project list --owner "$ORG" --format json --jq ".projects[] | select(.title == \"$BOARD\") | .number")
[[ -n $num ]] || { echo "no project board \"$BOARD\" in $ORG"; exit 1; }
gh project link "$num" --owner "$ORG" --repo "$REPO" > /dev/null 2>&1 || true
echo "linked to project #$num ($BOARD)"

# 4. team with write access
if ! gh api "orgs/$ORG/teams/$NAME" > /dev/null 2>&1; then
    gh api -X POST "orgs/$ORG/teams" -f name="$NAME" -f privacy=closed \
        -f description="Members of $NAME" > /dev/null
    echo "team   $NAME created"
fi
gh api -X PUT "orgs/$ORG/teams/$NAME/repos/$REPO" -f permission=push > /dev/null
echo "team   $NAME has write access to $REPO"
echo "done: https://github.com/$REPO"
