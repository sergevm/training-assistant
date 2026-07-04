## ADDED Requirements

### Requirement: Club management entry point

The app SHALL provide a Club area, reachable from Settings, from which the user can manage
members. Dogs are managed in the context of the member who trains them, not as a standalone
list.

#### Scenario: Open the Club area from Settings

- **WHEN** the user opens Settings
- **THEN** a Club section is shown with an entry to manage Members
- **AND** the existing Classes management remains available

### Requirement: Create a member

The system SHALL allow the user to create a member identified by a club member id, a first
name, and a last name. The club member id MUST be non-empty after trimming surrounding
whitespace.

#### Scenario: Create a member with valid details

- **WHEN** the user enters a non-empty club member id, first name, and last name and confirms
- **THEN** the system persists a new member and shows it in the members list

#### Scenario: Reject a blank club member id

- **WHEN** the user attempts to create a member whose club member id is empty after trimming
- **THEN** the system does not create the member

### Requirement: Club member id is unique

The system SHALL reject a new member whose club member id matches an existing member's club
member id after trimming, compared case-sensitively.

#### Scenario: Reject a duplicate club member id

- **WHEN** the user enters a club member id that, after trimming, exactly matches an existing
  member's club member id
- **THEN** the system does not create the member
- **AND** the system informs the user that the club member id already exists

### Requirement: List, edit, and delete members

The system SHALL show all members in a list, allow editing a member's details, and allow
deleting a member.

#### Scenario: Edit a member's details

- **WHEN** the user opens a member and changes the first name, last name, or club member id to
  valid values
- **THEN** the system persists the updated details

#### Scenario: Delete a member

- **WHEN** the user deletes a member
- **THEN** the system removes the member and its combinations
- **AND** any dog that no other member owns is deleted; dogs still owned by another member remain

### Requirement: Create a dog when pairing with a member

When forming a combination, the system SHALL allow the user to create a dog identified by a
name, with an optional breed and an optional date of birth, and an active flag that defaults
to active. The name MUST be non-empty after trimming; breed and date of birth are optional.

#### Scenario: Create a dog with only a name

- **WHEN** the user creates a new dog with a non-empty name and no breed or date of birth
- **THEN** the system persists a new active dog paired with the member

#### Scenario: Create a dog with a breed

- **WHEN** the user creates a new dog and enters a breed
- **THEN** the system persists the dog with that breed

### Requirement: Edit a dog from a member

The system SHALL allow the user to edit a dog — its name, breed, date of birth, and active
flag — by selecting the dog from the member's list of dogs. The name MUST remain non-empty.
Dogs are not listed or deleted independently of members.

#### Scenario: Edit a dog's details

- **WHEN** the user selects a dog under a member and changes its name, breed, or date of birth
- **THEN** the system persists the updated details

#### Scenario: Toggle a dog's active flag

- **WHEN** the user turns a dog's active flag off or on
- **THEN** the system persists the dog's active state

### Requirement: Add a dog to a member

The system SHALL allow the user to add a dog to a member either by creating a new dog or by
sharing a dog owned by another member. When not sharing, the system SHALL offer only creating a
new dog — it SHALL NOT list other members' existing dogs.

#### Scenario: Add a newly created dog

- **WHEN** the user, editing a member, creates a new dog in the add-dog flow and confirms
- **THEN** the system persists the new dog and a combination linking it to the member
- **AND** the combination appears under the member's dogs

#### Scenario: Existing dogs are not offered without a lookup

- **WHEN** the user opens the add-dog flow without using the member lookup
- **THEN** the system offers only creating a new dog, not other members' existing dogs

### Requirement: Share a dog owned by another member

The system SHALL allow sharing a dog owned by another member by looking that member up by first
name, last name, or club member id, then selecting one of that member's dogs. The lookup SHALL
NOT offer a dog the current member is already paired with.

#### Scenario: Share another member's dog

- **WHEN** the user looks up another member and selects one of that member's dogs
- **THEN** the system creates a combination pairing the current member with that dog
- **AND** the dog is owned by both members

#### Scenario: Dogs already owned are excluded from the lookup

- **WHEN** the user looks up a member whose dogs are all already paired with the current member
- **THEN** the lookup offers none of that member's dogs to share

### Requirement: A member cannot be paired with the same dog twice

The system SHALL reject forming a combination between a member and a dog when a combination
between that member and that dog already exists.

#### Scenario: Reject a duplicate pairing

- **WHEN** the user attempts to pair a member with a dog they are already combined with
- **THEN** the system does not create a second combination
- **AND** the system informs the user that the pairing already exists

### Requirement: Members and dogs are independently shareable

The model SHALL allow one member to be combined with multiple dogs and one dog to be combined
with multiple members.

#### Scenario: One member trains multiple dogs

- **WHEN** the user pairs a member with two different dogs
- **THEN** the member has two combinations, one per dog

#### Scenario: One dog is trained by multiple members

- **WHEN** the user shares one member's dog with another member via the lookup
- **THEN** the dog is combined with both members, each as a separate combination

### Requirement: Remove a combination and clean up orphaned dogs

The system SHALL allow removing a combination, keeping the member. The paired dog SHALL be kept
only if another member still owns it; otherwise the dog SHALL be deleted so no orphaned dogs
remain.

#### Scenario: Remove a combination for a dog with another owner

- **WHEN** the user removes a member's combination for a dog that another member also owns
- **THEN** the system deletes only that combination
- **AND** the member and the dog remain

#### Scenario: Remove a combination for a dog with no other owner

- **WHEN** the user removes a member's combination for a dog no other member owns
- **THEN** the system deletes the combination and the now-orphaned dog
- **AND** the member remains

### Requirement: Find a member in the members list

The members list SHALL be searchable by first name, last name, or club member id.

#### Scenario: Search the members list

- **WHEN** the user enters text in the members search field
- **THEN** the list shows only members whose first name, last name, or club member id contains
  that text
