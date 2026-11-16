alter table public.mrt_stations add column if not exists target_place_count integer not null default 100;
alter table public.mrt_stations drop constraint if exists mrt_stations_target_place_count_check;
alter table public.mrt_stations add constraint mrt_stations_target_place_count_check check (target_place_count > 0);
