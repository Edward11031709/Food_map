-- Account profiles, server-managed roles, private favorites, and private visit records.
create table public.profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  display_name text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.user_roles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  role text not null default 'user' check (role in ('user', 'admin')),
  created_at timestamptz not null default now()
);

create table public.favorites (
  user_id uuid not null references auth.users(id) on delete cascade,
  place_id uuid not null references public.places(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, place_id)
);

create table public.place_visits (
  user_id uuid not null references auth.users(id) on delete cascade,
  place_id uuid not null references public.places(id) on delete cascade,
  eaten_at timestamptz not null default now(),
  primary key (user_id, place_id)
);

create index favorites_place_id_idx on public.favorites(place_id);
create index place_visits_place_id_idx on public.place_visits(place_id);

alter table public.profiles enable row level security;
alter table public.user_roles enable row level security;
alter table public.favorites enable row level security;
alter table public.place_visits enable row level security;

create policy "profiles_select_own"
  on public.profiles for select to authenticated
  using ((select auth.uid()) = user_id);

create policy "profiles_update_own"
  on public.profiles for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

create policy "user_roles_select_own"
  on public.user_roles for select to authenticated
  using ((select auth.uid()) = user_id);

create policy "favorites_select_own"
  on public.favorites for select to authenticated
  using ((select auth.uid()) = user_id);

create policy "favorites_insert_own_published_places"
  on public.favorites for insert to authenticated
  with check (
    (select auth.uid()) = user_id
    and exists (
      select 1 from public.places p
      where p.id = place_id and p.is_published = true
    )
  );

create policy "favorites_delete_own"
  on public.favorites for delete to authenticated
  using ((select auth.uid()) = user_id);

create policy "place_visits_select_own"
  on public.place_visits for select to authenticated
  using ((select auth.uid()) = user_id);

create policy "place_visits_insert_own_published_places"
  on public.place_visits for insert to authenticated
  with check (
    (select auth.uid()) = user_id
    and exists (
      select 1 from public.places p
      where p.id = place_id and p.is_published = true
    )
  );

create policy "place_visits_delete_own"
  on public.place_visits for delete to authenticated
  using ((select auth.uid()) = user_id);

revoke all on public.profiles from anon, authenticated;
revoke all on public.user_roles from anon, authenticated;
revoke all on public.favorites from anon, authenticated;
revoke all on public.place_visits from anon, authenticated;

grant select on public.profiles to authenticated;
grant update (display_name) on public.profiles to authenticated;
grant select on public.user_roles to authenticated;
grant select, insert, delete on public.favorites to authenticated;
grant select, insert, delete on public.place_visits to authenticated;

-- Every new Auth identity gets a profile and a normal user role.
-- Administrator promotion is a privileged database-owner operation only.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (user_id, display_name)
  values (
    new.id,
    nullif(trim(coalesce(new.raw_user_meta_data ->> 'display_name', '')), '')
  )
  on conflict (user_id) do nothing;

  insert into public.user_roles (user_id, role)
  values (new.id, 'user')
  on conflict (user_id) do nothing;

  return new;
end;
$$;

revoke all on function public.handle_new_user() from public, anon, authenticated;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
