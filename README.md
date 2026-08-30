# aoc

Solutions to [Advent of Code](https://adventofcode.com/) puzzles, written in several languages. The point is practice in the languages themselves rather than a complete set, so the same day may appear more than once solved differently, and no day is guaranteed to appear in every language.

## Progress

Nothing solved yet.

This section is maintained by hand and nothing checks it, so a row belongs in the same commit as the solution it describes. Days are grouped by year, one table per year, added as the first solution for that year lands.

## Layout

Each top-level directory is one language.

A day is identified by a single token: `y`, the four-digit year, `d`, the two-digit day, giving `y2025d01`. The same token is the source filename, the executable name and the input filename, in every language. Zero-padding the day keeps names in numeric rather than lexicographic order, and because the year leads, sorting by name sorts by date for free. The letters are there because several languages derive an identifier from the filename and will not accept one starting with a digit.

**The year is part of the token, not a directory.** A `2025/` directory inside a language tree would look tidier and cost more: Cabal executable names are unique across a package, so a bare `d01` could not be reused for a second year, and the year would end up spelled once in the path and again in the executable name. One token spelled one way everywhere is what keeps the source file, the built executable and the input file findable from each other. The price is a flat directory that grows to 25 files per year, and if that ever becomes the problem, a language can adopt subdirectories on its own without any name changing.

Each day is **one program covering both parts**, printing both answers. The two parts of an Advent of Code day share their input and nearly all of their parsing, so splitting them would mean writing the parser twice or building a shared module to avoid it.

Build configuration stays inside the language directory that owns it, and the root holds none. Build tools work out their scope by scanning outward from a marker file, so a `dune-project` or a `cabal.project` sitting at the root would let one language's tooling wander through every other language's tree.

Organising by language rather than by day is what gives each language server a real project root to attach to, and with it completion, types and go-to-definition. Grouping by day instead would leave every source file an orphan that its own tooling could not place.

## Puzzle inputs

Inputs live in a root `data/` directory, one file per day, named by the same token with a `.txt` extension: `data/y2025d01.txt`. A program derives that path from its own name rather than taking it as an argument, so a solution runs with no arguments.

**`data/` is not committed.** Advent of Code asks that puzzle inputs not be included in a published repository, and inputs are issued per user in any case. A fresh checkout therefore has to create `data/` and add its own files before anything will run.

## Running

Each language directory carries its own `README.md`, with the prerequisites for that language and the command to run a solution.
