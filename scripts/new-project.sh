#!/usr/bin/env bash
# Open a project in the rimuru-research organization.
#
#   scripts/new-project.sh <repo-name> "<one-line description>" [--public] [--source <dir>]
#
# 1. the repository, private unless --public:
#    without --source  created from the template rimuru-research/project-template
#    with --source     an existing project folder goes up as it is. <dir> must already be a git repository with a
#                      commit and no uncommitted change, and must carry scripts/check-repo.sh from the template,
#                      which has to pass on every tracked file. The .gitignore and the first commit are yours to
#                      write: what goes in is a decision (other people's material, data, build products). The
#                      script creates an empty repository, makes it the origin of <dir> and pushes HEAD as main.
# 2. sets the organization's label set on it
# 3. links it to the organization project board "Rimuru Research"
# 4. creates a team of the same name with write access to the repository
# Safe to rerun: every step checks what already exists.  Needs gh with the scopes repo, admin:org, project.
set -euo pipefail

ORG=rimuru-research
TEMPLATE="$ORG/project-template"
BOARD="Rimuru Research"

usage() { sed -n '2,16p' "$0"; exit 2; }
[[ $# -ge 2 ]] || usage
NAME=$1; DESC=$2; shift 2
VIS=--private; SRC=
while [[ $# -gt 0 ]]; do
    case $1 in
        --public) VIS=--public; shift ;;
        --source) [[ $# -ge 2 ]] || usage; SRC=$2; shift 2 ;;
        *) usage ;;
    esac
done
[[ $NAME =~ ^[a-z0-9][a-z0-9-]{1,62}$ ]] || { echo "repo name: lowercase letters, digits and '-' only"; exit 2; }
REPO="$ORG/$NAME"

# 0. an existing folder must be ready before anything is created on GitHub
if [[ -n $SRC ]]; then
    git -C "$SRC" rev-parse -q --verify HEAD > /dev/null || { echo "$SRC: not a git repository with a commit"; exit 1; }
    [[ $(git -C "$SRC" rev-parse --show-toplevel) -ef $SRC ]] || { echo "$SRC: not the top of its repository"; exit 1; }
    [[ -z $(git -C "$SRC" status --porcelain) ]] || { echo "$SRC: commit or ignore the changes first"; exit 1; }
    [[ -f $SRC/scripts/check-repo.sh ]] || { echo "$SRC: copy scripts/check-repo.sh from $TEMPLATE first"; exit 1; }
    (cd "$SRC" && bash scripts/check-repo.sh --all) || exit 1
fi

# 1. repository
if gh repo view "$REPO" > /dev/null 2>&1; then
    echo "repo   $REPO exists"
elif [[ -n $SRC ]]; then
    gh repo create "$REPO" "$VIS" --description "$DESC" > /dev/null
    echo "repo   $REPO created empty ($VIS)"
else
    gh repo create "$REPO" "$VIS" --template "$TEMPLATE" --description "$DESC" > /dev/null
    echo "repo   $REPO created from $TEMPLATE ($VIS)"
fi

if [[ -n $SRC ]]; then
    url="git@github.com:$REPO.git"      # the organization's clones use SSH
    have=$(git -C "$SRC" remote get-url origin 2> /dev/null || true)
    if [[ -z $have ]]; then
        git -C "$SRC" remote add origin "$url"
    elif [[ $have != "$url" ]]; then
        echo "$SRC: origin is $have, not $url"; exit 1
    fi
    git -C "$SRC" push -q -u origin HEAD:main
    [[ -d $SRC/.githooks ]] && git -C "$SRC" config core.hooksPath .githooks
    echo "pushed $SRC to $REPO (main)"
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
