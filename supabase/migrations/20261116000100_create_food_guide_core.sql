-- 黑貓飲食指南：核心店家資料模型
-- 公開網站僅能讀取 is_published = true 的內容；匿名角色沒有任何寫入權限。

create table if not exists public.sources (
  id uuid primary key default gen_random_uuid(),
  source_name text not null,
  source_url text not null,
  source_type text not null default 'website',
  license_name text,
  license_url text,
  retrieved_at timestamptz not null default now(),
  verified_at timestamptz,
  created_at timestamptz not null default now(),
  constraint sources_source_type_check check (source_type in ('official_website', 'official_social', 'government', 'map', 'directory', 'media', 'user_provided', 'website', 'other'))
);

create table if not exists public.places (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  name text not null,
  aliases text[] not null default '{}',
  description text,
  business_type text[] not null default '{}',
  cuisines text[] not null default '{}',
  meal_times text[] not null default '{}',
  dietary_options text[] not null default '{}',
  address text,
  city text,
  district text,
  postal_code text,
  latitude double precision,
  longitude double precision,
  coordinate_source text,
  coordinate_verified_at timestamptz,
  phone text,
  website_url text,
  social_urls jsonb not null default '{}'::jsonb,
  price_min integer,
  price_max integer,
  currency text not null default 'TWD',
  dining_time_policy text not null default 'unknown',
  dining_time_limit_minutes integer,
  services text[] not null default '{}',
  amenities text[] not null default '{}',
  verification_status text not null default 'unverified',
  is_published boolean not null default false,
  last_verified_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint places_latitude_check check (latitude is null or latitude between -90 and 90),
  constraint places_longitude_check check (longitude is null or longitude between -180 and 180),
  constraint places_price_check check (price_min is null or price_min >= 0),
  constraint places_price_range_check check (price_max is null or (price_max >= 0 and (price_min is null or price_max >= price_min))),
  constraint places_currency_check check (currency = 'TWD'),
  constraint places_dining_time_check check (dining_time_policy in ('limited', 'unlimited', 'unknown', 'not_applicable')),
  constraint places_verification_check check (verification_status in ('unverified', 'partially_verified', 'verified', 'needs_review', 'closed', 'unknown')),
  constraint places_coordinate_pair_check check ((latitude is null and longitude is null) or (latitude is not null and longitude is not null))
);

create table if not exists public.place_hours (
  id uuid primary key default gen_random_uuid(),
  place_id uuid not null references public.places(id) on delete cascade,
  day_of_week smallint not null,
  opens_at time,
  closes_at time,
  is_closed boolean not null default false,
  valid_from date,
  valid_until date,
  notes text,
  source_id uuid references public.sources(id) on delete set null,
  created_at timestamptz not null default now(),
  constraint place_hours_day_check check (day_of_week between 0 and 6),
  constraint place_hours_time_check check (is_closed or (opens_at is not null and closes_at is not null)),
  constraint place_hours_date_range_check check (valid_until is null or valid_from is null or valid_until >= valid_from)
);

create table if not exists public.menu_items (
  id uuid primary key default gen_random_uuid(),
  place_id uuid not null references public.places(id) on delete cascade,
  name text not null,
  description text,
  category text,
  price integer,
  currency text not null default 'TWD',
  serving_times text[] not null default '{}',
  dietary_labels text[] not null default '{}',
  availability_status text not null default 'unknown',
  source_id uuid references public.sources(id) on delete set null,
  last_verified_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint menu_items_price_check check (price is null or price >= 0),
  constraint menu_items_currency_check check (currency = 'TWD'),
  constraint menu_items_availability_check check (availability_status in ('available', 'seasonal', 'unavailable', 'unknown'))
);

create table if not exists public.place_sources (
  id uuid primary key default gen_random_uuid(),
  place_id uuid not null references public.places(id) on delete cascade,
  source_id uuid not null references public.sources(id) on delete cascade,
  supports_fields text[] not null default '{}',
  confidence numeric(4,3),
  created_at timestamptz not null default now(),
  unique (place_id, source_id),
  constraint place_sources_confidence_check check (confidence is null or confidence between 0 and 1)
);

create table if not exists public.ingestion_runs (
  id uuid primary key default gen_random_uuid(),
  query_text text not null,
  region text,
  status text not null default 'started',
  found_count integer not null default 0,
  inserted_count integer not null default 0,
  updated_count integer not null default 0,
  skipped_count integer not null default 0,
  error_summary text,
  started_at timestamptz not null default now(),
  finished_at timestamptz,
  constraint ingestion_runs_status_check check (status in ('started', 'completed', 'partial', 'failed'))
);

create index if not exists places_published_name_idx on public.places (is_published, name);
create index if not exists places_city_district_idx on public.places (city, district);
create index if not exists places_business_type_gin_idx on public.places using gin (business_type);
create index if not exists places_cuisines_gin_idx on public.places using gin (cuisines);
create index if not exists places_meal_times_gin_idx on public.places using gin (meal_times);
create index if not exists places_dietary_options_gin_idx on public.places using gin (dietary_options);
create index if not exists places_coordinates_idx on public.places (latitude, longitude) where latitude is not null and longitude is not null;
create index if not exists place_hours_place_day_idx on public.place_hours (place_id, day_of_week);
create index if not exists menu_items_place_idx on public.menu_items (place_id);
create index if not exists place_sources_place_idx on public.place_sources (place_id);
create index if not exists place_sources_source_idx on public.place_sources (source_id);

alter table public.places enable row level security;
alter table public.place_hours enable row level security;
alter table public.menu_items enable row level security;
alter table public.sources enable row level security;
alter table public.place_sources enable row level security;
alter table public.ingestion_runs enable row level security;

drop policy if exists "Published places are visible to everyone" on public.places;
create policy "Published places are visible to everyone"
  on public.places for select to anon, authenticated
  using (is_published = true);

drop policy if exists "Hours of published places are visible to everyone" on public.place_hours;
create policy "Hours of published places are visible to everyone"
  on public.place_hours for select to anon, authenticated
  using (exists (select 1 from public.places p where p.id = place_hours.place_id and p.is_published = true));

drop policy if exists "Menus of published places are visible to everyone" on public.menu_items;
create policy "Menus of published places are visible to everyone"
  on public.menu_items for select to anon, authenticated
  using (exists (select 1 from public.places p where p.id = menu_items.place_id and p.is_published = true));

drop policy if exists "Sources linked to published places are visible to everyone" on public.sources;
create policy "Sources linked to published places are visible to everyone"
  on public.sources for select to anon, authenticated
  using (exists (
    select 1 from public.place_sources ps
    join public.places p on p.id = ps.place_id
    where ps.source_id = sources.id and p.is_published = true
  ));

drop policy if exists "Public source links of published places are visible" on public.place_sources;
create policy "Public source links of published places are visible"
  on public.place_sources for select to anon, authenticated
  using (exists (select 1 from public.places p where p.id = place_sources.place_id and p.is_published = true));

grant select on public.places, public.place_hours, public.menu_items, public.sources, public.place_sources to anon, authenticated;
revoke all on public.ingestion_runs from anon, authenticated;

comment on table public.places is '標準化店家主檔；只有 is_published=true 的資料可由公開網站讀取。';
comment on table public.place_hours is '每週與特殊日期營業時段；day_of_week 使用 0=週日、6=週六。';
comment on table public.menu_items is '店家菜單品項與 TWD 價格；來源與查證時間不可省略於正式蒐集流程。';
comment on table public.sources is '可公開引用的來源名稱、網址、類型與查證時間，不存放私密管理備註。';
comment on table public.place_sources is '店家與來源關聯，標記來源能支持的欄位。';
comment on table public.ingestion_runs is '內部蒐集任務紀錄；不開放匿名 Data API 讀寫。';
