# AGENTS.md

Instructions for AI coding agents working in this repository. See `CLAUDE.md` for
codebase architecture and domain conventions; this file covers agent working
preferences.

## Vocabulary

- **Classes** — the school's class definitions: a named class plus its weekly
  schedule entries (`TrainingClass`, `ScheduleEntry`). Managed on the Classes
  screen.
- **Class Sessions** — dated, started occurrences of a class (`ClassSession`),
  e.g. what Today's Classes starts and History lists.
- Never say "Class Definitions" in UI copy, code identifiers, specs, or docs —
  the term is always "Classes".

## Git & PR attribution

- Do **not** add Claude, Claude Code, or Anthropic as a co-author, and do not add a
  "Generated with Claude Code" (or similar) attribution line to commit messages or
  pull request descriptions. Author all commits and PRs as the user, with no agent
  attribution trailer.
