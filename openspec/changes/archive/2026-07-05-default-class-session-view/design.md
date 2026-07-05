# Design: default-class-session-view

## Context

`TodayClassesView` holds the filter in `@State private var filter: Filter = .toStart`
and renders `filteredOccurrences` from `todaysOccurrences` (derived per render from
`@Query` classes + sessions). Navigation to `ClassSessionView` is `@State`-driven via
`.navigationDestination(item:)`, so the list view stays alive while a session detail
is pushed and receives `onAppear` again when the detail is popped.

## Goals / Non-Goals

**Goals:**
- Land the user on a useful list: when nothing is left to start but sessions are
  started, show "Started" without a manual switch.
- Keep manual filter control fully functional.

**Non-Goals:**
- No persistence of the last-chosen filter across app launches.
- No change to occurrence derivation, session matching, or navigation.

## Decisions

- **Auto-select in `onAppear` only, not `onChange` of the data.** `onAppear` fires
  both on first presentation and when the pushed session detail is popped — exactly
  the two moments the proposal covers. Reacting to data changes while the screen is
  frontmost (the alternative considered) could yank the picker out from under a user
  who deliberately selected the empty "To start" view.
- **One-directional switch.** Auto-selection only moves `.toStart → .started`, and
  only when to-start is empty and at least one started occurrence exists. It never
  forces "Started" back to "To start", so a manual choice is never fought: after a
  manual switch the only way auto-selection runs again is a re-appear, where the
  same condition would justify it anyway.
- **Compute the condition from `todaysOccurrences` directly** (`!contains(where:
  !isStarted)` and `contains(where: isStarted)`) rather than through
  `filteredOccurrences`, which depends on the current filter value.

## Risks / Trade-offs

- [onAppear timing vs. @Query load] SwiftData `@Query` results are available on the
  first body evaluation, before `onAppear`, so the check sees real data → no
  mitigation needed beyond keeping the check cheap and idempotent.
- [User pops back after viewing, not starting, a session] Condition is unchanged in
  that case (still nothing to start), so re-running the check is a no-op or the
  correct switch either way.
