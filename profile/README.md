# Rimuru Research

Research on hardware accelerators for deep learning, from quantized models to RTL, FPGA and ASIC.

Each project lives in its own repository, created from a common template, so every project reads the same way:

| folder | contents |
|---|---|
| `docs/` | specifications, design notes, figures |
| `model/` | reference and bit-accurate golden models (Python) |
| `rtl/`, `tb/` | hardware description and its testbenches |
| `sim/` | simulation, synthesis and timing runners |
| `fpga/` | constraints, block designs, board bring-up |
| `results/` | tables, figures and logs that every reported number is read from |

Work is tracked as issues (`task`, `experiment`, `bug`) on one organization-wide project board.
Conventions for issues, branches, commits and results: [CONTRIBUTING.md](../CONTRIBUTING.md).
