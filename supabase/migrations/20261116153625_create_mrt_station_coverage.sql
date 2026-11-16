create table if not exists public.mrt_stations (
  id uuid primary key default gen_random_uuid(),
  station_code text not null unique,
  station_name text not null,
  station_name_en text,
  line_ids text[] not null default '{}',
  operator text not null default 'Taipei Metro',
  city text,
  district text,
  latitude double precision,
  longitude double precision,
  station_source_url text,
  source_updated_at date,
  is_active boolean not null default true,
  last_verified_at timestamptz,
  created_at timestamptz not null default now(),
  constraint mrt_stations_latitude_check check (latitude is null or latitude between -90 and 90),
  constraint mrt_stations_longitude_check check (longitude is null or longitude between -180 and 180),
  constraint mrt_stations_coordinates_pair_check check ((latitude is null and longitude is null) or (latitude is not null and longitude is not null))
);

create table if not exists public.place_mrt_stations (
  id uuid primary key default gen_random_uuid(),
  place_id uuid not null references public.places(id) on delete cascade,
  station_id uuid not null references public.mrt_stations(id) on delete cascade,
  straight_line_distance_m integer,
  walking_distance_m integer,
  walking_minutes integer,
  is_primary boolean not null default false,
  assignment_method text not null default 'needs_review',
  verification_status text not null default 'unverified',
  source_url text,
  last_verified_at timestamptz,
  created_at timestamptz not null default now(),
  unique (place_id, station_id),
  constraint place_mrt_stations_straight_distance_check check (straight_line_distance_m is null or straight_line_distance_m >= 0),
  constraint place_mrt_stations_walk_distance_check check (walking_distance_m is null or walking_distance_m >= 0),
  constraint place_mrt_stations_walk_minutes_check check (walking_minutes is null or walking_minutes >= 0),
  constraint place_mrt_stations_method_check check (assignment_method in ('official_source', 'verified_walking_route', 'straight_line', 'manual', 'needs_review')),
  constraint place_mrt_stations_verification_check check (verification_status in ('verified', 'partially_verified', 'needs_review', 'unverified'))
);

create index if not exists mrt_stations_name_idx on public.mrt_stations (station_name);
create index if not exists mrt_stations_line_ids_gin_idx on public.mrt_stations using gin (line_ids);
create index if not exists place_mrt_stations_station_idx on public.place_mrt_stations (station_id, place_id);
create index if not exists place_mrt_stations_place_idx on public.place_mrt_stations (place_id, station_id);

alter table public.mrt_stations enable row level security;
alter table public.place_mrt_stations enable row level security;

drop policy if exists "Active MRT stations are visible to everyone" on public.mrt_stations;
create policy "Active MRT stations are visible to everyone"
  on public.mrt_stations for select to anon, authenticated
  using (is_active = true);

drop policy if exists "Station links of published places are visible" on public.place_mrt_stations;
create policy "Station links of published places are visible"
  on public.place_mrt_stations for select to anon, authenticated
  using (
    exists (select 1 from public.places p where p.id = place_mrt_stations.place_id and p.is_published = true)
    and exists (select 1 from public.mrt_stations s where s.id = place_mrt_stations.station_id and s.is_active = true)
  );

revoke all privileges on table public.mrt_stations, public.place_mrt_stations from anon, authenticated;
grant select on table public.mrt_stations, public.place_mrt_stations to anon, authenticated;

comment on table public.mrt_stations is '捷運站主檔；站碼、路線、站點座標與官方來源。';
comment on table public.place_mrt_stations is '店家與捷運站多對多關聯；記錄直線距離、步行距離、關聯方式與查證狀態。';
