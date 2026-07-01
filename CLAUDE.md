# TrainingAssistant

SwiftUI + SwiftData app for a dog-training school: define classes and their weekly
schedule, start dated class sessions, and review past sessions. Specs live under
`openspec/` (spec-driven workflow); the app is in `TrainingAssistant/`.

## Conventions

### Navigation: use `@State` selection + `.navigationDestination(item:)`

To push a detail view from a row, drive it from local `@State`, not a value-based
path:

```swift
@State private var selectedSession: ClassSession?
// row:
Button { selectedSession = session } label: { RowView(session) }
    .buttonStyle(.plain)
// once, on the container:
.navigationDestination(item: $selectedSession) { session in
    SessionDetailView(session: session)
}
```

Do **not** push a SwiftData `@Model` as a `NavigationStack` path value
(`NavigationLink(value: model)` + `.navigationDestination(for: Model.self)`). A
`@Model` is a reference type, and using it as a path value re-triggers the push
endlessly — tapping a row stacks the same screen in an infinite loop. The
`item:`-based pattern above is proven in `TodayClassesView` and
`SessionHistoryView`; match it for all row → detail navigation.

Add `.contentShape(Rectangle())` to any tappable row so the **whole** row is
hittable, not just its text/icon. Under `.buttonStyle(.plain)` a `Spacer()` gap is
transparent and therefore not tappable without it.

### SwiftData models are self-contained snapshots

`ClassSession` stores originating ids (`trainingClassID`, `scheduleEntryID`) plus a
snapshot of the definition (`className`, `dayOfWeek`, `startHour`, `startMinute`)
rather than live `@Relationship`s. This keeps records immune to dangling references
when the originating class/slot is edited or deleted. Render detail/history views
from the snapshot, not from live relationships. Give every stored property a default
value to stay lightweight-migration-safe.

### Matching and ordering

- Match sessions to a day/slot in Swift (`Calendar.isDate(_:inSameDayAs:)`, `UUID`
  equality), not in `#Predicate` — date equality is unreliable across the
  in-memory→store round-trip. Lean on `@Query` only for coarse ordering
  (e.g. `sort: \ClassSession.date, order: .reverse`).
- Register every model in the `.modelContainer(for:)` array in
  `TrainingAssistantApp.swift` **and** in every `#Preview`'s in-memory container.
