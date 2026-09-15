# Agent Instructions

## Repository Purpose

This repository contains Danilo Pianini's curriculum vitae in LaTeX.
The main entrypoints are:

- `curriculum.tex`: English CV
- `curriculum-ita.tex`: Italian CV

Several sections are split into standalone `.tex` fragments and included from the main documents.

## File Layout

- Edit `curriculum.tex` or `curriculum-ita.tex` for document-specific content, layout, and section ordering.
- Edit shared fragments such as `contracts.tex`, `collaborations.tex`, `editorial.tex`, `reviews.tex`, `service-conferences.tex`, `conference-talks.tex`, `conference-invited-talks.tex`, and `teaching.tex` when updating reusable sections.
- Edit `bibliography.bib` for publication data.
- Treat `scholar.tex` as generated content if it exists. It is produced by `scholar_scraper.rb` during the English CV build.

## Build And Validation

- Canonical build command: `latexmk -pdf -file-line-error -interaction=nonstopmode -synctex=1 -output-format=pdf -output-directory=out *.tex`
  - Run from the repository root; `*.tex` expands to every top-level `.tex` file (currently `curriculum.tex` and `curriculum-ita.tex`), and output lands in `out/`.
  - To validate a single document, replace `*.tex` with just that filename, e.g. `curriculum-ita.tex`.
  - `curriculum.tex` requires `-shell-escape` added to that command (see below); `curriculum-ita.tex` does not need it.
- Alternative full build: `./build.kts` — compiles every `curriculum*.tex` file with `pdflatex -shell-escape`, then runs `bibtex` when citations are detected. Slower and uses classic `bibtex` semantics rather than `latexmk`/`biber`.
- `curriculum.tex` uses `biblatex` with `biber`; the repository's `.latexmkrc` sets `$bibtex = 'biber %O %B'` so `latexmk` invokes `biber` automatically. `curriculum-ita.tex` uses classic `bibtex` with the `IEEEtran` style.
- `curriculum.tex` runs `./setup_ruby.sh` and `./scholar_scraper.rb` via LaTeX shell escape (`\write18`), which requires passing `-shell-escape` to `latexmk`/`pdflatex`. This step can install Ruby gems and fetch Google Scholar data over the network, and regenerates `scholar.tex`.
- Do not assume network access is available. If build validation is needed in a restricted environment, explain clearly when the Scholar-generation step prevents a full compile, and consider validating `curriculum-ita.tex` (no shell-escape/network dependency) instead.

## Editing Rules

- Preserve the existing LaTeX style and section formatting; this repo is content-first, not a template redesign task.
- Keep content changes minimal and targeted. Avoid reflowing large blocks unless necessary for the requested edit.
- Maintain ASCII unless a file already uses non-ASCII text naturally, which is common in `curriculum-ita.tex`.
- When updating dates, roles, or lists of activities, keep the existing formatting conventions such as `\\halfblankline`, `\\hfill`, and section-local list environments.
- Prefer updating shared section fragments rather than duplicating content in the main files.

## Verification Expectations

- After content edits, validate by compiling the smallest relevant target when practical.
- If a full compile is not practical, at least check the edited file for obvious LaTeX syntax issues and report the remaining risk.
- Do not delete generated auxiliary files unless explicitly asked.
