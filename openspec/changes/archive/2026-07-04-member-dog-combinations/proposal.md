## Why

The app has no notion of *who* trains in a class: there is no member, dog, or combination
data, and the "Participants" section on a session is an empty placeholder. Before we can
record session attendance, we need a normalized model of the club's people and dogs. The
same person can train several dogs, and the same dog can be shared by several people, so a
flat "person" record on a combination cannot express reality — we model members, dogs, and
their pairings as first-class entities.

## What Changes

- Introduce three definition models with live SwiftData relationships:
  - `Member` — a club person (externally-assigned club member id, first name, last name).
  - `Dog` — a dog with a required name, an optional breed (free-text for now) and optional
    date of birth, and an `isActive` flag; can be shared across members.
  - `Combination` — an explicit, **global** many-to-many join pairing one `Member` with one
    `Dog` (not scoped to a class).
- Add a **Club** area in Settings to create, edit, delete, and search members and to add dogs
  to them. A member's dog is created new by default, or shared from another member via a
  searchable member lookup (so two people can own the same dog); other members' dogs are never
  offered automatically. A dog is edited by tapping it in the member's list — there is no
  standalone dogs list.
- Never leave orphaned dogs: when a member is deleted, or a dog is removed from a member, any
  dog that no other member owns is deleted too.
- Enforce a unique club member id and prevent duplicate (member, dog) pairings via
  app-level checks, consistent with the existing class-name duplicate handling.
- Register the three new models in the app's `ModelContainer` schema and in every relevant
  in-memory `#Preview` container.
- No breaking changes: existing classes, schedules, and sessions are untouched. This change
  adds new entities and UI only; wiring combinations into session attendance is a separate
  follow-up change.

## Capabilities

### New Capabilities
- `club-membership`: managing club members, dogs, and the global (member, dog) combinations
  that pair them — creation, listing, editing, deletion, uniqueness rules, and the
  active-dog flag.

### Modified Capabilities
(none — `class-management`, `class-scheduling`, and `class-sessions` are unaffected. The
`class-sessions` "placeholder participants list" requirement will be revised in the
follow-up `session-attendance` change, not here.)

## Impact

- **New models**: `Member`, `Dog`, `Combination` under
  `TrainingAssistant/TrainingAssistant/Models/`. Each stored property gets a default value
  (lightweight-migration-safe); Member/Dog own cascade to-many `combinations`, Combination
  holds nullify to-one `member`/`dog`.
- **Schema registration**: add `Member.self, Dog.self, Combination.self` to the `Schema([...])`
  in `TrainingAssistantApp.swift` and to every full-set `#Preview` `.modelContainer(for:)`.
- **New views**: `MembersView` (searchable), `MemberEditorView`, `DogEditorView` (reached from
  a member's dog row), `CombinationEditorView` with an in-flow member/dog lookup for sharing;
  `SettingsView` gains a "Club" section with a Members entry. There is no standalone dogs list.
- **No new dependencies.** SwiftUI + SwiftData only; QR scanning and camera entitlements are
  deferred to the follow-up change.
- **Dev-store note**: `makeContainer()` wipes the on-disk store on a migration failure.
  Adding entities is additive/lightweight, but a mistaken schema edit could reset existing
  classes/sessions — acceptable for the current pre-release posture.
