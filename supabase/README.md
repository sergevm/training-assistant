# Supabase setup — TrainingAssistant auth

The app code (`AuthService`, `LoginView`, `RootView`) is committed, but it can't
build or run until the steps below are done. These are the tasks in
`openspec/changes/add-user-authentication/tasks.md` groups **1**, **2**, and **5**
that live outside the repo (Xcode GUI, the Supabase dashboard, provider consoles,
and on-device testing).

## 1. Supabase project (tasks 1.1–1.5)

1. Create a Supabase project (or a dedicated dev project).
2. **Providers** (Auth → Providers): enable **Apple** and **Google**. Each needs
   OAuth credentials created in that vendor's console:
   - **Apple**: an App ID with *Sign in with Apple* enabled, plus a Services ID +
     key for the web/OAuth side. Add Supabase's callback URL to the Services ID.
   - **Google**: an OAuth 2.0 client (Cloud Console); paste client ID/secret into
     Supabase and add Supabase's callback URL as an authorized redirect URI.

   Facebook is deferred (see the change's design.md); adding it later is just
   enabling the Supabase provider plus a login button — no app-architecture change.
3. **Allowlist + hook**: open the SQL editor and run [`schema.sql`](./schema.sql).
   Then Auth → Hooks → **Before User Created** → select the Postgres function
   `hook_restrict_signup_to_invited` and enable it.
4. **URL configuration** (Auth → URL Configuration): add the app's redirect scheme
   `com.softwareprojects.trainingassistant://login-callback` to the allow-list (used
   by the browser-based Google flow).
5. **Seed a test invite** so you can sign in:
   ```sql
   insert into public.invited_users (email, invited_by) values ('you@example.com', 'setup');
   ```

## 2. Xcode project (tasks 2.1–2.3)

1. **Add the SDK** (task 2.1): File → Add Package Dependencies →
   `https://github.com/supabase/supabase-swift` → add the **Supabase** product to
   the TrainingAssistant target. This clears the `No such module 'Supabase'` error.
2. **Sign in with Apple** (task 2.2): target → Signing & Capabilities → **+
   Capability** → *Sign in with Apple*. (This also enables the capability on the App
   ID in the Apple Developer portal.)
3. **Config** (task 2.3): copy [`Supabase-Info.example.plist`](./Supabase-Info.example.plist)
   to `TrainingAssistant/TrainingAssistant/Supabase-Info.plist`, fill in your
   project URL + anon/publishable key (Project Settings → API), and confirm the file
   is a member of the TrainingAssistant target. The real file is git-ignored.
4. **URL scheme** (for Google): target → Info → URL Types → add the scheme
   `com.softwareprojects.trainingassistant` so the OAuth browser flow can return.

## 5. Verify on device/simulator (tasks 5.1–5.4)

- Non-invited email via Apple/Google → rejected with the "need an
  invitation" message; no row appears in Auth → Users.
- The seeded invited email via each provider → lands on the app's home screen.
- Force-quit + relaunch while signed in → still signed in (no re-login).
- Sign out (Settings → Sign Out) → returns to the login screen; local classes and
  sessions are untouched.
