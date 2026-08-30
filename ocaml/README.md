# OCaml

Advent of Code solutions in OCaml. One dune project, one executable per day.

## Prerequisites

OCaml and dune, installed through opam. `aoc.opam` pins them exactly: **OCaml 5.4.1** and **dune 3.24.2**. `dune-project` separately declares `(lang dune 3.24)`, which fixes dune's *behaviour* rather than the version of the binary.

ocamlformat and ocaml-lsp-server are deliberately left unpinned and track their latest releases. Neither changes what the code compiles to.

Every command below is written as `opam exec -- ...` so it runs against the opam switch rather than whatever happens to be first on `PATH`.

## Building

```sh
opam exec -- dune build @default @ocaml-index
```

`@ocaml-index` builds the cross-reference index that ocaml-lsp-server reads for project-wide navigation. A plain `dune build` does not produce it, and without it the editor can resolve names within a file but not across the project.

## Running a solution

From this directory:

```sh
opam exec -- dune exec bin/y2025d01.exe
```

The executable for a day is named `y`, the four-digit year, `d`, the two-digit day. The `.exe` suffix is dune's name for a native executable on every platform, Linux included; it is not a Windows artefact.

**No argument is passed.** A solution reads its own executable name and resolves `data/<that name>.txt` from the repository root, which it finds by walking up from the working directory until a `data/` directory appears. That works from here or from the root, and it fails with a message rather than a wrong answer when the input is missing.

Inputs are not committed, so a fresh checkout has to create `data/` at the repository root and add its own files there before anything will run.

Build output lands in `_build/` and is ignored by git.

## Formatting

```sh
opam exec -- dune fmt
```

The style is `profile = janestreet`, set in `.ocamlformat`. `dune fmt` also reformats `dune-project` and the `dune` files themselves, using dune's own formatter rather than ocamlformat. It exits 1 when it changed something and 0 when there was nothing left to do, so a non-zero exit right after an edit is the normal outcome rather than a failure.

## Adding a day

Three steps, all required.

1. Write `bin/yYYYYdDD.ml` with a `let () = ...` entry point, covering **both parts** and printing both answers.
2. Add an `(executable (name yYYYYdDD) (modules yYYYYdDD))` stanza to `bin/dune`. The `(modules ...)` field is not optional once there is more than one stanza: without it each stanza claims every module in the directory, and dune rejects a module claimed twice.
3. Add or extend the row for that day in the progress table in the repository root `README.md`. Nothing verifies this one, so it has to happen in the same commit or it will not happen at all.
