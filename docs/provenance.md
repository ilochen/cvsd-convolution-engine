# Source and validation provenance

The RTL was copied from the student submission and matched byte-for-byte with the working RTL on the course server. SHA-256 of `rtl/core.v` is `6414bea9d06ff1a9ea6e6aaf09ba2a6aad34cb2a9108900d6ad73e93615a36ad`. The pattern files come from the corresponding course testbed. `constraints/interface.sdc` preserves the source timing and I/O assumptions with technology selection removed.

The archived synthesis output directory contains `core_syn.v`, `core_syn.sdc`, `core_syn.sdf` and `core_syn.ddc`. The mapped design contains generated implementations of the DesignWare multipliers. The generated timing constraints select an operating corner and a technology wire-load model. SDF records instance timing; DDC is a compiled tool database. These artifacts remain in the course archive pending artifact-specific redistribution clearance. The portable tests operate on RTL with no foundry library dependency.

GitHub Actions runs the same local Make regression on pushes and pull requests. The values in the README referring to the original report describe that submission.
