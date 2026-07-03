-- Invite-only signup for TrainingAssistant.
--
-- Run this once in the Supabase SQL editor, then wire the function as the
-- "Before User Created" Auth Hook (Auth → Hooks). See supabase/README.md.
--
-- The hook fires for EVERY provider (Apple / Google / email): the
-- event payload always carries user.email, so a single allowlist check gates all
-- sign-up paths — a client can't bypass it.

-- 1. Allowlist of who may create an account.
create table if not exists public.invited_users (
  email      text primary key,
  invited_by text,
  invited_at timestamptz not null default now(),
  claimed_at timestamptz
);

-- 2. The hook: reject signup unless the email was invited.
create or replace function public.hook_restrict_signup_to_invited(event jsonb)
returns jsonb
language plpgsql
as $$
declare
  v_email text;
  v_count int;
begin
  v_email := lower(event->'user'->>'email');

  if v_email is null or v_email = '' then
    return jsonb_build_object('error', jsonb_build_object(
      'message', 'An email address is required to create an account.',
      'http_code', 400));
  end if;

  select count(*) into v_count
  from public.invited_users iu
  where lower(iu.email) = v_email;

  if v_count = 0 then
    return jsonb_build_object('error', jsonb_build_object(
      'message', 'You need an invitation to create an account.',
      'http_code', 403));
  end if;

  -- Best-effort: record that this invite has now been claimed.
  update public.invited_users iu
  set claimed_at = now()
  where lower(iu.email) = v_email and iu.claimed_at is null;

  return '{}'::jsonb;  -- empty object == allow
end;
$$;

-- 3. Only the auth admin may run the hook or read/write the allowlist.
grant usage on schema public to supabase_auth_admin;
grant execute on function public.hook_restrict_signup_to_invited to supabase_auth_admin;
revoke execute on function public.hook_restrict_signup_to_invited from authenticated, anon, public;
grant select, update on table public.invited_users to supabase_auth_admin;
revoke all on table public.invited_users from authenticated, anon, public;

-- 4. Seed an invite so you can test the happy path (replace the address).
-- insert into public.invited_users (email, invited_by) values ('you@example.com', 'setup');
