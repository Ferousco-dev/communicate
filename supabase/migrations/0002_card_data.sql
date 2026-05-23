-- CommuniCare — per-child card / schedule / mood tables
--
-- Apply after 0001_children_and_link_codes.sql.
--
-- Every row carries a child_id. RLS lets a parent see/write any row whose
-- child belongs to them, and a paired child device see/write any row whose
-- child it is linked to via public.child_devices (the helper function
-- public.is_paired_device is defined in 0001).

-- ---------- cards ----------
create table if not exists public.cards (
  id uuid primary key default gen_random_uuid(),
  child_id uuid not null references public.children(id) on delete cascade,
  label text not null,
  category text not null,
  icon_key text not null,
  color_hex text,
  image_url text,
  speak_text text,
  sort_order int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists cards_child_idx on public.cards(child_id);
create index if not exists cards_child_category_idx
  on public.cards(child_id, category);
alter table public.cards enable row level security;

create policy "cards: parent full access"
  on public.cards for all
  using (exists (select 1 from public.children c
                  where c.id = child_id and c.owner_id = auth.uid()))
  with check (exists (select 1 from public.children c
                  where c.id = child_id and c.owner_id = auth.uid()));

create policy "cards: paired device full access"
  on public.cards for all
  using (public.is_paired_device(child_id))
  with check (public.is_paired_device(child_id));

-- ---------- schedule_items ----------
create table if not exists public.schedule_items (
  id uuid primary key default gen_random_uuid(),
  child_id uuid not null references public.children(id) on delete cascade,
  label text not null,
  icon_key text not null,
  sort_order int not null default 0,
  done boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists schedule_child_idx on public.schedule_items(child_id);
alter table public.schedule_items enable row level security;

create policy "schedule: parent full access"
  on public.schedule_items for all
  using (exists (select 1 from public.children c
                  where c.id = child_id and c.owner_id = auth.uid()))
  with check (exists (select 1 from public.children c
                  where c.id = child_id and c.owner_id = auth.uid()));

create policy "schedule: paired device full access"
  on public.schedule_items for all
  using (public.is_paired_device(child_id))
  with check (public.is_paired_device(child_id));

-- ---------- mood_entries ----------
create table if not exists public.mood_entries (
  id uuid primary key default gen_random_uuid(),
  child_id uuid not null references public.children(id) on delete cascade,
  feeling_id text not null,
  label text not null,
  created_at timestamptz not null default now()
);
create index if not exists mood_child_created_idx
  on public.mood_entries(child_id, created_at desc);
alter table public.mood_entries enable row level security;

-- Parents read everything they own; devices can insert their own and read
-- recent entries (kept simple — no delete from device).
create policy "mood: parent read"
  on public.mood_entries for select
  using (exists (select 1 from public.children c
                  where c.id = child_id and c.owner_id = auth.uid()));
create policy "mood: parent write"
  on public.mood_entries for all
  using (exists (select 1 from public.children c
                  where c.id = child_id and c.owner_id = auth.uid()))
  with check (exists (select 1 from public.children c
                  where c.id = child_id and c.owner_id = auth.uid()));
create policy "mood: device read"
  on public.mood_entries for select
  using (public.is_paired_device(child_id));
create policy "mood: device insert"
  on public.mood_entries for insert
  with check (public.is_paired_device(child_id));

-- updated_at maintenance for cards + schedule_items.
create or replace function public.touch_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at := now();
  return new;
end $$;

drop trigger if exists touch_cards_updated on public.cards;
create trigger touch_cards_updated
  before update on public.cards
  for each row execute function public.touch_updated_at();

drop trigger if exists touch_schedule_updated on public.schedule_items;
create trigger touch_schedule_updated
  before update on public.schedule_items
  for each row execute function public.touch_updated_at();
