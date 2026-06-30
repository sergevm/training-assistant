## Why

The dog school runs recurring classes on fixed weekly training days, but the app has no way to capture this structure. Before we can register actual trainings (attendance, dogs, results), we first need a place to define which classes exist and when they recur. A settings page for managing class schedules is the foundation everything else builds on.

## What Changes

- Add a **Settings** area to the app, reachable from the main screen.
- Add the ability to **create, edit, and delete classes**, each identified by a name.
- Add the ability to define a **weekly recurring schedule** for a class: one or more entries, each consisting of a day of the week and a start time on the quarter hour (e.g. 09:00, 09:15, 09:30, 09:45). Class duration is fixed at one hour.
- Allow a single class to be scheduled on **multiple days per week** (and multiple times per day).
- **Persist** classes and their schedules in a local on-device database so they survive app restarts.

## Capabilities

### New Capabilities
- `class-management`: Creating, naming, editing, and deleting the classes offered by the school, persisted locally.
- `class-scheduling`: Defining the weekly recurring schedule (day-of-week + start hour, fixed one-hour duration) for each class, including multiple weekly occurrences.

### Modified Capabilities
<!-- None — no existing specs in openspec/specs/. -->

## Impact

- **App shell**: `ContentView` gains navigation into a new Settings screen (currently a placeholder "Hello, world" view).
- **New SwiftUI views**: settings list, class list, class editor, and schedule entry editor.
- **New persistence layer**: local database models for classes and schedule entries, wired into the app via the SwiftUI environment.
- **Dependencies**: introduces SwiftData (built into iOS 26) as the local store; no third-party dependencies.
- **Scope note**: this change covers only defining the schedule. Registering/recording actual trainings against the schedule is a later change.
