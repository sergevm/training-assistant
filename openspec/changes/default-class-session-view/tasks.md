# Tasks: default-class-session-view

## 1. Auto-select the started filter

- [x] 1.1 In `TodayClassesView`, add a private helper that switches `filter` from
  `.toStart` to `.started` when `todaysOccurrences` contains no unstarted
  occurrence and at least one started occurrence
- [x] 1.2 Invoke the helper from `.onAppear` so it runs on first presentation and
  whenever the view reappears after a pushed `ClassSessionView` is popped

## 2. Verify

- [x] 2.1 Build the app and check the preview: with all of today's occurrences
  started, the view opens on "Started"; with any occurrence unstarted, it opens on
  "To start"; manually selecting "To start" afterwards stays put
