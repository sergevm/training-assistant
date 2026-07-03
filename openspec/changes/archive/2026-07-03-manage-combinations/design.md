## Context

`TrainingClass`/`ScheduleEntry` model the weekly schedule and `ClassSession` models dated occurrences, but nothing today records the handler-dog pairs ("combinations") that actually train in a class. This adds that roster as a new top-level concept: `Combination`.

Unlike `ClassSession`, a combination's class assignment is a *current, live* fact (like membership), not a historical snapshot of a point-in-time occurrence — it should track the class's live name and be nullified if the class is deleted, not freeze a copy of stale data.

## Goals / Non-Goals

**Goals:**
- Persist combinations (handler + dog + optional current class + notes).
- Let a combination be created without a class, and assigned/reassigned to any existing class at any time.
- Surface a dedicated Combinations list, groupable by current class, reachable from the landing screen.
- Keep a combination alive (unassigned) if its current class is deleted.

**Non-Goals:**
- No per-session attendance/check-in (linking combinations to `ClassSession`s) — future change, foreshadowed by the existing "participants" placeholder in `ClassSessionView`.
- No capacity limits on a class's roster.
- No duplicate-detection across combinations (two combinations may legitimately share a dog name or handler name).
- No photo/avatar, email, or phone fields — out of scope for this phase.

## Decisions

**1. Model `Combination` as a SwiftData `@Model` with a live `@Relationship` to `TrainingClass`, not an id snapshot.**
`ClassSession` snapshots its originating class/slot by id + copied fields, because a session is a historical record that must stay stable even if the definition it came from changes later (see `ClassSession.swift` doc comment and CLAUDE.md). A combination's class assignment is the opposite: it's a live, current-state pointer — if the class is renamed, the combination should show the new name; if the class is deleted, the assignment should clear. That is exactly what a SwiftData relationship gives for free, matching the existing `ScheduleEntry.trainingClass` pattern rather than `ClassSession`'s id+snapshot pattern.

```swift
// TrainingClass.swift
@Relationship(deleteRule: .nullify, inverse: \Combination.currentClass)
var combinations: [Combination] = []

// Combination.swift
var currentClass: TrainingClass?
```

Alternative considered: store `currentClassID: UUID?` plus a snapshotted `currentClassName: String` (mirroring `ClassSession`'s style), and manually clear it in `SettingsView.deleteClasses`. Rejected — it reintroduces manual dangling-reference bookkeeping that SwiftData's `.nullify` delete rule already solves declaratively, and a combination's class membership is current state, not a record of the past.

**2. Store `dogGender` as a raw `Int` with a typed computed accessor, following the `Weekday`/`ClassSession.dayOfWeek` convention.**
```swift
var dogGenderRaw: Int = 0
var dogGender: DogGender? { DogGender(rawValue: dogGenderRaw) }
```
`DogGender` is a simple `Int`-backed enum (`male`, `female`) in its own file, matching `Weekday.swift`. This keeps the model lightweight-migration-safe (default value, no enum stored directly) consistent with every other stored enum-like field in the codebase.

**3. Combinations screen is a new top-level entry point, not nested in `ClassEditorView`.**
A combination's class is optional and changeable, so its natural home is a standalone roster (`CombinationsView`) reachable from `ContentView`, listing all combinations and grouping by current class (with an "Unassigned" group) — not scoped inside a single class's editor. This matches the user's explicit navigation choice and keeps `ClassEditorView` focused on schedule management.

**4. Reuse the `@State` selection + `.navigationDestination(item:)` pattern for row → detail/edit navigation**, per CLAUDE.md — `Combination` is a SwiftData `@Model` (reference type), so it must not be pushed as a `NavigationStack` path value.

**5. Single combined create/edit view (`CombinationEditorView`) rather than separate create and edit screens.**
Mirrors `ClassEditorView`'s style of inline editing with a `Form`; a "New Combination" flow presents the same editor bound to a newly-inserted, not-yet-saved combination shown via a sheet, avoiding duplicated form code.

## Risks / Trade-offs

- **[Risk]** Grouping-by-class on the Combinations list requires resolving each combination's `currentClass` relationship, which is `nil`-safe but means an "Unassigned" bucket must be handled explicitly in the grouping logic. → Mitigation: group with a keyed dictionary keyed by `TrainingClass.id?` (nil key = "Unassigned"), covered by a spec scenario.
- **[Risk]** Because `currentClass` is a live relationship (not a snapshot), renaming a class immediately changes how existing combinations display — this is intended (current-state, not historical) but differs from `ClassSession`'s snapshot behavior and should not be confused with it.
- **[Trade-off]** No capacity/duplicate validation in this phase means the roster can grow unbounded per class; acceptable per the proposal's explicit non-goal, revisit if trainers ask for it.

## Migration Plan

New model addition only — no existing data to migrate. `Combination` must be added to the `.modelContainer(for:)` array in `TrainingAssistantApp.swift` and to every `#Preview` in-memory container that touches `TrainingClass` deletion or the new views. Since all new `Combination` properties have default values, this is a lightweight, additive schema change.

## Open Questions

- None — scope and fields were confirmed with the user (handler first/last name, dog name, dog birthday, dog gender, optional current class, notes).
