## 1. Models

- [x] 1.1 Create `Models/Member.swift` — `@Model` with `id: UUID = UUID()`, `clubMemberID: String = ""`, `firstName: String = ""`, `lastName: String = ""`, and `@Relationship(deleteRule: .cascade, inverse: \Combination.member) var combinations: [Combination] = []`
- [x] 1.2 Add computed helpers to `Member`: `fullName` and `activeCombinations` (`combinations.filter { $0.dog?.isActive == true }`)
- [x] 1.3 Create `Models/Dog.swift` — `@Model` with `id: UUID = UUID()`, `name: String = ""`, `isActive: Bool = true`, and `@Relationship(deleteRule: .cascade, inverse: \Combination.dog) var combinations: [Combination] = []`
- [x] 1.4 Create `Models/Combination.swift` — `@Model` with `id: UUID = UUID()`, `member: Member?`, `dog: Dog?` (plain to-one, default `.nullify`), and an `init(id:member:dog:)`

## 2. Schema & preview registration

- [x] 2.1 Add `Member.self, Dog.self, Combination.self` to the `Schema([...])` in `TrainingAssistantApp.swift` `makeContainer()`
- [x] 2.2 Add the three models to every full-set `#Preview` `.modelContainer(for:)`: `ContentView.swift`, `Views/RootView.swift`, `Views/TodayClassesView.swift`, `Views/ClassSessionView.swift`, `Views/SessionHistoryView.swift`
- [x] 2.3 Extend the `SettingsView` `#Preview` container with the three models

## 3. Dogs management UI

<!-- NOTE: task 3.1 was superseded by group 8 after user feedback — the standalone
     DogsView was removed; dogs are created inline while pairing and edited from the member. -->

- [x] 3.1 Create `Views/DogsView.swift` — `@Query(sort: \Dog.name)` list; rows show name + active indicator, navigate to `DogEditorView` via closure `NavigationLink`; add via name-only `.alert` (mirror the class-add alert); `.onDelete` to delete the dog <!-- superseded by 8.2 -->
- [x] 3.2 Reject a blank/whitespace-only dog name on add
- [x] 3.3 Create `Views/DogEditorView.swift` — draft-commit "Name" field (mirror `ClassEditorView`) plus `Toggle("Active", isOn:)` bound to `dog.isActive`, committing + saving immediately

## 4. Members management UI

- [x] 4.1 Create `Views/MembersView.swift` — `@Query` sorted by last then first name; rows show `fullName` + club id, navigate to `MemberEditorView`; `.onDelete` to delete the member; add via a `.sheet` form
- [x] 4.2 Build the add-member sheet form (club id, first name, last name) with Cancel/Add toolbar (mirror `ScheduleEntryEditorView`); reject blank club id and reject a duplicate club id (trimmed, case-sensitive) with an alert
- [x] 4.3 Create `Views/MemberEditorView.swift` — draft-commit first/last/club-id fields with revert-on-invalid and the duplicate-club-id guard (mirror `ClassEditorView.commitName`)
- [x] 4.4 Add a "Dogs" section to `MemberEditorView` listing this member's combinations (dog name + active badge) with `.onDelete` to remove the combination, plus an "Add Dog" button opening `CombinationEditorView` as a `.sheet`

## 5. Combinations

- [x] 5.1 Create `Views/CombinationEditorView.swift` — presented from `MemberEditorView` with the member fixed; `Form` in `NavigationStack` with Cancel/Add toolbar (mirror `ScheduleEntryEditorView`)
- [x] 5.2 Provide a picker/list of existing dogs, filtered to dogs not already combined with this member, plus a "Create new dog" affordance (name + active toggle) <!-- superseded by 9.1/9.2: global existing-dogs picker replaced by new-dog default + explicit member lookup -->
- [x] 5.3 On Add: resolve or insert the `Dog`, guard the no-duplicate-pairing rule (`member.combinations.contains { $0.dog?.id == candidateDog.id }`), create `Combination(member:dog:)`, `insert`, link, `save`, `dismiss`

## 6. Settings hub

- [x] 6.1 Add a "Club" section to `SettingsView` with closure `NavigationLink`s to `MembersView` and `DogsView`, above the existing "Classes" section <!-- the DogsView link was later removed in 8.2; Club → Members only -->
- [x] 6.2 Fold the classes empty-state into an in-section row so the Club links remain visible when there are no classes

## 7. Verification

- [x] 7.1 Run `openspec validate member-dog-combinations --strict` and fix any issues
- [x] 7.2 Build for an iOS 26 simulator; confirm first launch has no schema/migration errors and existing classes/sessions survive
- [x] 7.3 Create a dog, toggle Active, relaunch, confirm persistence
- [x] 7.4 Create a member; attempt a duplicate club id → rejected with alert; confirm sort order and `fullName`/club-id rendering
- [x] 7.5 From a member, form a combination with an existing dog and with a newly created dog; confirm the same dog cannot be added twice; confirm a shared dog appears under two different members
- [x] 7.6 Delete a combination → member remains; the dog remains only if another member owns it, else it is deleted. Delete a member → its combinations vanish, shared dogs remain, dogs it solely owned are deleted
- [x] 7.7 Confirm all new views' SwiftUI `#Preview`s render

## 8. Refinement: breed/DOB, dogs managed from members

<!-- Follow-up on user feedback: remove the standalone Dogs area; dogs are created inline
     while pairing and edited from the member. Supersedes task 3.1 and 6.1's Dogs link. -->

- [x] 8.1 Add optional `breed: String = ""` and `dateOfBirth: Date? = nil` to `Dog` (name still required); update its `init`
- [x] 8.2 Remove `Views/DogsView.swift` and the Dogs link from `SettingsView` (Club → Members only)
- [x] 8.3 Make each dog row in `MemberEditorView` a closure `NavigationLink` to `DogEditorView`; show breed as a subtitle
- [x] 8.4 Extend `DogEditorView` with breed (draft-commit) and optional date of birth (toggle enabling an inline `DatePicker`)
- [x] 8.5 Capture optional breed in `CombinationEditorView`'s new-dog section and pass it when creating the `Dog`
- [x] 8.6 Re-run `openspec validate --strict` and rebuild for the iOS 26 simulator (BUILD SUCCEEDED)

## 9. Ownership: dogs belong to members, explicit sharing, no orphans

<!-- Follow-up on user feedback: don't offer other members' dogs automatically; share via an
     explicit member lookup; delete orphaned dogs. Supersedes task 5.2's existing-dogs picker. -->

- [x] 9.1 Rework `CombinationEditorView` into two modes — "New dog" (default) and "Another member's dog"; drop the global existing-dogs picker
- [x] 9.2 Add a searchable member lookup (`MemberDogLookupView`, excludes the current member and members with no shareable dog) → the owner's shareable dogs (`SharedDogListView`, excludes dogs already paired with the current member)
- [x] 9.3 Add `.searchable` (first name / last name / club id) to `MembersView`
- [x] 9.4 On member delete (`MembersView`), also delete any dog that no other member owns
- [x] 9.5 On combination removal (`MemberEditorView`), delete the dog when it has no other owner
- [x] 9.6 Re-run `openspec validate --strict` and rebuild for the iOS 26 simulator (BUILD SUCCEEDED)

## 10. Manual verification (ownership)

- [x] 10.1 Add a dog to member A → only "New dog" and "Another member's dog" are offered (no global dog list)
- [x] 10.2 Share A's dog with member B via lookup (search by name/id) → dog appears under both; the lookup no longer offers that dog to B
- [x] 10.3 Search the members list by first name, last name, and club id
- [x] 10.4 Remove the dog from B (A still owns it) → dog remains; remove from A too → dog is deleted
- [x] 10.5 Delete a member who solely owns a dog → the dog is deleted; delete a member who co-owns a dog → the dog remains
