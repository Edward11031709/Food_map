-- 強化黑貓飲食指南公開 Data API 權限
-- Public / authenticated roles are read-only. Internal ingestion history is not exposed.

revoke all privileges on table
  public.places,
  public.place_hours,
  public.menu_items,
  public.sources,
  public.place_sources,
  public.ingestion_runs
from anon, authenticated;

grant select on table
  public.places,
  public.place_hours,
  public.menu_items,
  public.sources,
  public.place_sources
to anon, authenticated;

drop policy if exists "Public roles cannot access ingestion runs" on public.ingestion_runs;
create policy "Public roles cannot access ingestion runs"
  on public.ingestion_runs
  for all
  to anon, authenticated
  using (false)
  with check (false);

create index if not exists menu_items_source_id_idx on public.menu_items (source_id);
create index if not exists place_hours_source_id_idx on public.place_hours (source_id);
