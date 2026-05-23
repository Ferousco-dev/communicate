-- CommuniCare — children + link-code pairing
--
-- Apply via the Supabase Dashboard (SQL Editor) or `supabase db push`.
-- Adds the three tables the parent-owns-children + child-device-pairing
-- model needs, and turns on Row Level Security on all of them.

-- ---------- profiles ----------
-- Mirrors auth.users so we have a place to keep display_name/role and to
-- join from `children.owner_id`. A trigger keeps it in sync on sign-up.
create table if not exists public.profiles (
  id uuid primary key references auth.users on delete cascade,
  display_name text,
  role text not null default 'parent' check (role in ('parent','therapist')),
  created_at timestamptz not null default now()
);
alter table public.profiles enable row level security;

create policy "profiles: read own"
  on public.profiles for select using (auth.uid() = id);
create policy "profiles: update own"
  on public.profiles for update using (auth.uid() = id);
create policy "profiles: insert own"
  on public.profiles for insert with check (auth.uid() = id);

-- Auto-create a profile row whenever a new auth user is created.
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
begin
  insert into public.profiles (id, display_name, role)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'display_name', new.email),
    coalesce(new.raw_user_meta_data->>'role', 'parent')
  )
  on conflict (id) do nothing;
  return new;
end $$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------- children ----------
create table if not exists public.children (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles(id) on delete cascade,
  name text not null,
  avatar_url text,
  birth_year int,
  created_at timestamptz not null default now()
);
create index if not exists children_owner_idx on public.children(owner_id);
alter table public.children enable row level security;

create policy "children: parent full access"
  on public.children for all
  using (owner_id = auth.uid())
  with check (owner_id = auth.uid());

-- ---------- child_devices ----------
-- One row per child device that has paired via a link code. The device
-- authenticates as an anonymous Supabase user; this table is what gives
-- that anon user permission to read the child's cards/schedule.
create table if not exists public.child_devices (
  id uuid primary key default gen_random_uuid(),
  child_id uuid not null references public.children(id) on delete cascade,
  auth_user_id uuid not null references auth.users(id) on delete cascade,
  paired_at timestamptz not null default now(),
  last_seen_at timestamptz,
  unique (child_id, auth_user_id)
);
create index if not exists child_devices_user_idx on public.child_devices(auth_user_id);
alter table public.child_devices enable row level security;

-- The parent (owner of the child) can see all devices linked to their kids;
-- the device itself can see its own row.
create policy "child_devices: parent read"
  on public.child_devices for select
  using (exists (select 1 from public.children c
                  where c.id = child_id and c.owner_id = auth.uid()));
create policy "child_devices: device read self"
  on public.child_devices for select
  using (auth_user_id = auth.uid());
create policy "child_devices: parent revoke"
  on public.child_devices for delete
  using (exists (select 1 from public.children c
                  where c.id = child_id and c.owner_id = auth.uid()));

-- Helper used by the data-table policies (cards/schedule/mood) to ask
-- "is the caller a device paired to this child?".
create or replace function public.is_paired_device(target_child uuid)
returns boolean language sql stable security definer set search_path = public as $$
  select exists (
    select 1 from public.child_devices d
    where d.child_id = target_child and d.auth_user_id = auth.uid()
  );
$$;

-- ---------- link_codes ----------
-- We store a SHA-256 hash of the code, never the plaintext. The plaintext
-- only exists on the parent's device, briefly, while the share screen is up.
create table if not exists public.link_codes (
  id uuid primary key default gen_random_uuid(),
  child_id uuid not null references public.children(id) on delete cascade,
  code_hash text not null,
  created_at timestamptz not null default now(),
  expires_at timestamptz not null,
  consumed_at timestamptz,
  consumed_by uuid references auth.users(id)
);
create index if not exists link_codes_child_idx on public.link_codes(child_id);
create unique index if not exists link_codes_active_unique
  on public.link_codes(code_hash) where consumed_at is null;
alter table public.link_codes enable row level security;

create policy "link_codes: parent manages own"
  on public.link_codes for all
  using (exists (select 1 from public.children c
                  where c.id = child_id and c.owner_id = auth.uid()))
  with check (exists (select 1 from public.children c
                  where c.id = child_id and c.owner_id = auth.uid()));

-- ---------- redeem_link_code RPC ----------
-- Child device calls this after signInAnonymously(). On success it links the
-- caller's anon user to the matching child and returns the child id+name so
-- the app can show the right profile immediately.
create or replace function public.redeem_link_code(p_code text)
returns table (child_id uuid, child_name text)
language plpgsql security definer set search_path = public as $$
declare
  v_hash text := encode(digest(p_code, 'sha256'), 'hex');
  v_row public.link_codes%rowtype;
begin
  if auth.uid() is null then
    raise exception 'Not authenticated. Sign in anonymously first.';
  end if;

  select * into v_row
    from public.link_codes
    where code_hash = v_hash
      and consumed_at is null
      and expires_at > now()
    for update;

  if not found then
    raise exception 'invalid_or_expired_code';
  end if;

  update public.link_codes
    set consumed_at = now(), consumed_by = auth.uid()
    where id = v_row.id;

  insert into public.child_devices (child_id, auth_user_id)
    values (v_row.child_id, auth.uid())
    on conflict (child_id, auth_user_id)
    do update set last_seen_at = now();

  return query
    select c.id, c.name from public.children c where c.id = v_row.child_id;
end $$;

-- Anyone (including anon users) needs execute permission to redeem.
grant execute on function public.redeem_link_code(text) to anon, authenticated;

-- digest() lives in pgcrypto. Most Supabase projects already have it, but
-- enable it just in case.
create extension if not exists pgcrypto;
