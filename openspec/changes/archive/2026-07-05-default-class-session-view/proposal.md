# Proposal: default-class-session-view

## Why

The Today screen always opens on the "To start" filter. Once every class scheduled
for the day has been started, that default shows an empty-state message even though
there are started sessions the trainer is actively working with — an extra manual
filter switch on every visit for the rest of the day.

## What Changes

- The Today classes overview auto-selects the "Started" filter when there are no
  occurrences left to start but at least one started session exists.
- Auto-selection applies when the screen appears and when it reappears after the
  user returns from a session detail (e.g. after starting the last remaining class).
- A filter the user picked by hand is never overridden while they are on the screen;
  auto-selection only ever switches away from an empty "To start" list toward
  "Started", never the reverse.

## Capabilities

### New Capabilities

None.

### Modified Capabilities

- `class-sessions`: the "Filter the list by started state" requirement gains a
  default-selection rule — the started filter is auto-selected when nothing is left
  to start and started sessions exist.

## Impact

- `TrainingAssistant/TrainingAssistant/Views/TodayClassesView.swift`: filter
  selection logic only; no model, query, or navigation changes.
- `openspec/specs/class-sessions/spec.md`: delta to the filter requirement.
