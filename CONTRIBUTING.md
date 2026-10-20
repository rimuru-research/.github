# Working conventions

These apply to every repository of the organization. A repository may add its own rules in its README; it does not
relax these.

## 1. Issues

Every piece of work is an issue on the project board "Rimuru Research", opened from one of three forms:

| form | label | use it for |
|---|---|---|
| Task | `task` | planned work with a deliverable |
| Experiment | `experiment` | a measurement or study: a question, a setup, a metric and a pass threshold |
| Bug | `bug` | something that produces a wrong result |

An issue states its completion criteria as numbers or commands that can be rerun ("0 mismatches over the trace
regression", "Fmax >= 300 MHz after route"), not as wording ("works", "faster"). Status on the board moves
Todo -> In progress -> Done; an issue is closed when its criteria are met and the evidence is linked in a comment.

## 2. Branches and pull requests

- `main` always builds and passes its checks.
- One branch per issue, named `<issue-number>-<short-name>` (for example `12-requant-shift`), merged through a pull
  request that links the issue (`Closes #12`).
- On private repositories of the Free plan GitHub cannot enforce this; it is kept by convention and by the check
  in section 5.

## 3. Commits

```
<area>: <what changed, in the imperative> (#<issue>)
```

`<area>` is one of `model`, `rtl`, `tb`, `sim`, `fpga`, `docs`, `results`, `tools`, `repo`. One logical change
per commit. The body says why, and gives the command and result when the commit reports a measurement.

## 4. Results

- Every number that goes into a report, a slide or a paper is read from a file under `results/tables/`, written by a
  script from logs under `results/logs/`. No number is typed by hand.
- Each table says what was measured, on what (configuration, sample size) and at which level of evidence: model,
  simulation, post-synthesis estimate, post-route, on board.
- Correctness is reported as values compared and mismatches; a run that compared nothing is a failure.
- A log keeps the command, the commit and the tool versions that produced it.

## 5. Repository hygiene

`scripts/check-repo.sh` runs as a pre-commit hook (`git config core.hooksPath .githooks`, once per clone) and in CI
on every push. It refuses:

- files of 50 MB or more (GitHub rejects 100 MB);
- build products: Vivado / xsim directories, checkpoints and bitstreams, Python caches, notebook checkpoints;
- strings that look like private keys or access tokens.

Large or third-party data (checkpoints, datasets, other people's code) stays outside the repository; the README says
where it comes from and how to fetch it, with a checksum.
