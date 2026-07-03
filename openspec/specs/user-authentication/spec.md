# user-authentication Specification

## Purpose
TBD - created by archiving change add-user-authentication. Update Purpose after archive.
## Requirements
### Requirement: App access requires an authenticated session
The system SHALL require a signed-in session before showing any existing app content.
Signed-out users SHALL see only a login screen offering Apple and Google sign-in.

#### Scenario: Cold launch while signed out
- **WHEN** the app launches and no valid session exists
- **THEN** the login screen is shown, and no class, schedule, or session data is
  reachable

#### Scenario: Cold launch while signed in
- **WHEN** the app launches and a valid persisted session exists
- **THEN** the app shows its existing root content (today's `ContentView`) directly,
  without prompting for sign-in again

### Requirement: Sign-in via Apple or Google
The system SHALL let a user sign in using their Apple or Google identity.

#### Scenario: Successful Apple sign-in
- **WHEN** an invited user completes the Apple sign-in flow
- **THEN** the system establishes an authenticated session and shows the app's
  existing root content

#### Scenario: Successful Google sign-in
- **WHEN** an invited user completes the Google sign-in flow
- **THEN** the system establishes an authenticated session and shows the app's
  existing root content

### Requirement: Account creation is restricted to invited users
The system SHALL reject account creation for any email that has not been explicitly
invited, regardless of which identity provider (Apple or Google) is used to
attempt the signup.

#### Scenario: Non-invited user attempts signup via any provider
- **WHEN** a user completes a provider's sign-in flow with an email that is not present
  in the invited-users allowlist and no account exists yet for that email
- **THEN** account creation is rejected, no session is established, and the user sees
  a clear "you need to be invited" message rather than a generic error

#### Scenario: Invited user completes signup
- **WHEN** a user completes a provider's sign-in flow with an email present in the
  invited-users allowlist and no account exists yet for that email
- **THEN** an account is created, a session is established, and the user sees the
  app's existing root content

### Requirement: Session persists across app launches
The system SHALL keep a signed-in user's session valid across app restarts until they
explicitly sign out or the session is revoked/expires.

#### Scenario: Relaunch after force-quit while signed in
- **WHEN** a signed-in user force-quits and relaunches the app
- **THEN** the app shows its existing root content directly, without requiring
  sign-in again

### Requirement: User can sign out
The system SHALL let a signed-in user explicitly end their session.

#### Scenario: User signs out
- **WHEN** a signed-in user triggers sign-out
- **THEN** the session is cleared, the login screen is shown, and all existing local
  class/schedule/session data remains intact and unaffected on the device

