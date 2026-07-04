## Context

The persisted layer today is `TrainingClass → ScheduleEntry` (a live cascade relationship)
plus the self-contained snapshot `ClassSession`. There is no member, dog, or combination
data anywhere — so this is a greenfield normalized schema, not a migration of existing
records. This change models the club's people and dogs so a later change can record which
combinations attended a session.

Constraints from the codebase (CLAUDE.md and existing files):
- SwiftUI + SwiftData, iPhone-only, iOS 26, no third-party dependencies for this change.
- Every `@Model` stored property gets a default value (lightweight-migration-safe) and must
  be registered in the `Schema([...])` in `TrainingAssistantApp.swift` and in every relevant
  in-memory `#Preview` container.
- Navigation uses `@State` selection + `.navigationDestination(item:)` or closure-based
  `NavigationLink { ... }`; never push a `@Model` as a path value (infinite-loop trap).
  Custom tappable rows get `.contentShape(Rectangle())`.
- Duplicate handling is done app-level (see `SettingsView.isDuplicateName`,
  `ClassEditorView.commitName`), not with store constraints.

## Goals / Non-Goals

**Goals:**
- Model `Member`, `Dog`, and a global (member, dog) `Combination` as first-class entities
  with live relationships, matching the definition-model style of `TrainingClass`.
- Provide management UI to create/list/edit/delete members, form combinations, and
  create/edit the dogs each member trains — reusing the existing Settings/editor patterns.
- Give each dog an optional breed and date of birth; the name stays required.
- Enforce a unique club member id and no duplicate (member, dog) pairing.

**Non-Goals:**
- A standalone dogs list or dog deletion. Dogs are created and edited only through the member
  who trains them; a retired dog is marked inactive rather than deleted.
- Session attendance / participant selection, QR scanning, camera permissions — deferred to
  the follow-up `session-attendance` change.
- Per-class rosters. Combinations are global; they are not enrolled into specific classes.
- Editing a combination's member or dog after creation (delete + recreate instead) — kept
  out to keep the first change tight.

## Decisions

### Combination is an explicit join `@Model`, not an implicit many-to-many
Model the pairing as its own `@Model` with to-one `member: Member?` and `dog: Dog?`, and a
to-many `combinations` on each of `Member` and `Dog`.
*Why:* the follow-up attendance change must snapshot a *specific* pairing, so the pairing
needs a stable first-class `id` (`combinationID`) to reference. An implicit
`[Member] ⇄ [Dog]` many-to-many has no join identity to snapshot.
*Alternatives considered:* implicit many-to-many (rejected — no stable join id); embedding
person fields on a combination (rejected — cannot express shared dogs or one person with
multiple dogs, which is the whole motivation).

### Relationship inverses and delete rules
Declare `@Relationship(deleteRule: .cascade, inverse: \Combination.member)` on
`Member.combinations` and `@Relationship(deleteRule: .cascade, inverse: \Combination.dog)`
on `Dog.combinations`. Leave `Combination.member` / `Combination.dog` as plain optional
to-one properties (default `.nullify`).
*Why:* deleting a member or a dog should remove the now-meaningless pairings, but never
delete the *other* party; deleting a combination should only unlink. The two inverse
declarations are unambiguous because each targets a distinct property on `Combination`.
*Alternatives considered:* `.nullify` on the parent sides (rejected — would leave orphan
combinations with a dangling side); declaring inverses on the `Combination` side instead
(equivalent, but the parent-side declaration reads closer to the existing
`TrainingClass.schedule` precedent).

### Club member id uniqueness enforced app-level, trim-only and case-sensitive
On create, reject a club member id that already exists after trimming whitespace, comparing
the exact (case-sensitive) string.
*Why:* consistent with the app's existing app-level duplicate handling, and it surfaces a
friendly "already exists" alert. Unlike class names, a club member id is an externally
issued token, so it is compared case-sensitively (not folded).
*Alternatives considered:* `@Attribute(.unique)` (rejected as the primary guard — SwiftData
treats a collision as a silent upsert/replace rather than a throwable error, and a pre-check
would still be needed for good UX).

### No-duplicate-pairing rule
Before creating a `Combination`, reject it if the member already has a combination with the
same dog: `member.combinations.contains { $0.dog?.id == candidateDog.id }`. App-level only;
acceptable for a single-user local store.

### Settings becomes a small hub; dogs live under members
`SettingsView` gains a "Club" section (a closure `NavigationLink` to `MembersView`) above the
existing "Classes" section, which is unchanged. There is no standalone dogs list. New views
each mirror an existing pattern:
- `MembersView` mirrors `SettingsView` (`@Query` list + add + `.onDelete`), plus `.searchable`
  filtering by first name, last name, or club member id.
- `MemberEditorView` / `DogEditorView` mirror `ClassEditorView` (draft-commit fields plus
  immediate-save toggles).
- `CombinationEditorView` mirrors `ScheduleEntryEditorView` (add-child sheet:
  `insert` → link → `save` → `dismiss`).
Members are added via a `.sheet` form. A dog is edited by tapping it in the member's dog list
(a closure `NavigationLink` to `DogEditorView`), which edits name (required), breed (optional
free-text), date of birth (optional — a toggle enables an inline `DatePicker`), and the active
flag.

### Dogs belong to members; sharing is explicit; no orphans
Dogs are owned through combinations, so `CombinationEditorView` never offers other members'
dogs automatically. It has two modes: **New dog** (default — name + optional breed + active)
and **Another member's dog**, which drills through a searchable member lookup
(`MemberDogLookupView`, excluding the current member and members with no shareable dog) to that
owner's dogs (`SharedDogListView`, excluding dogs already paired with the current member).
Selecting either path creates the `Combination` and dismisses.
Orphan cleanup keeps ownership meaningful: when a member is deleted (`MembersView`) or a
combination is removed (`MemberEditorView`), any dog left with no other owner is deleted in the
same save. Ownership is computed before the delete (`dog.combinations` still holds the pairing),
so the check is a simple "does another member's combination reference this dog?".
*Why:* with no standalone dogs list, an orphaned dog would be permanently unreachable; deleting
it on the last unpair keeps the store clean. A retired-but-kept dog is expressed with the
inactive flag instead.

## Risks / Trade-offs

- **[Two-inverse cascade behaves unexpectedly]** → verify at run time that deleting a Member
  and deleting a Dog each cascade-delete their `Combination`s, and that deleting a Combination
  leaves both Member and Dog intact.
- **[Uniqueness race]** the app-level club-id and duplicate-pair checks have a theoretical
  race window → acceptable for a single-user local store; no mitigation beyond the pre-check.
- **[Case policy drift]** the club-id match policy (trim-only, case-sensitive) must be reused
  verbatim by the follow-up scan lookup → documented here and in the follow-up's open question.
- **[Dev-store reset]** `makeContainer()` deletes the store on migration failure → adding
  entities is additive/lightweight, but a bad schema edit could wipe existing data. Acceptable
  pre-release; call it out in review.
- **[Target membership]** new files must be added to the `TrainingAssistant` target → confirm
  after creation (the project uses a file-system-synchronized group, so this is usually
  automatic).

## Open Questions

- Breed is free-text for now; a later change will replace it with a reference to an official
  breed list.
