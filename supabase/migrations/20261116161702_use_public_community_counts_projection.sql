-- Publish only per-place eaten totals; individual visit records remain private.
create table public.place_community_counts (
  place_id uuid primary key references public.places(id) on delete cascade,
  eaten_count integer not null default 0 check (eaten_count >= 0),
  updated_at timestamptz not null default now()
);

alter table public.place_community_counts enable row level security;

create policy "place_community_counts_public_read_published"
  on public.place_community_counts for select
  to anon, authenticated
  using (
    exists (
      select 1 from public.places p
      where p.id = place_id and p.is_published = true
    )
  );

revoke all on public.place_community_counts from anon, authenticated;
grant select on public.place_community_counts to anon, authenticated;

create or replace function public.sync_place_community_counts()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  if tg_op = 'INSERT' then
    insert into public.place_community_counts (place_id, eaten_count, updated_at)
    values (new.place_id, 1, now())
    on conflict (place_id) do update
      set eaten_count = public.place_community_counts.eaten_count + 1,
          updated_at = now();
    return new;
  elsif tg_op = 'DELETE' then
    update public.place_community_counts
       set eaten_count = greatest(eaten_count - 1, 0),
           updated_at = now()
     where place_id = old.place_id;
    delete from public.place_community_counts
     where place_id = old.place_id and eaten_count = 0;
    return old;
  end if;
  return null;
end;
$$;

revoke all on function public.sync_place_community_counts() from public, anon, authenticated;

create trigger place_visits_increment_public_count
  after insert on public.place_visits
  for each row execute function public.sync_place_community_counts();

create trigger place_visits_decrement_public_count
  after delete on public.place_visits
  for each row execute function public.sync_place_community_counts();

insert into public.place_community_counts (place_id, eaten_count, updated_at)
select place_id, count(*)::integer, now()
from public.place_visits
group by place_id
on conflict (place_id) do update
  set eaten_count = excluded.eaten_count,
      updated_at = now();

drop function public.get_place_community_counts();
