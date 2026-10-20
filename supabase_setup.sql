-- ============================================================
--  おめでと島ぐらし — Supabase 初期設定（何度実行しても大丈夫）
--  Supabase の画面 → 左メニュー「SQL Editor」→ 「New query」→
--  この内容をぜんぶ貼りつけて「Run」
-- ============================================================

-- 1) ふたりだけを通す関数（ログイン中のメールアドレスで判定）
create or replace function public.is_futari()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(auth.jwt() ->> 'email', '') in (
    'sai@futari-shimagurashi.app',
    'yui@futari-shimagurashi.app'
  );
$$;

-- 2) データの保存先（予定・日記・ミッション・写真の一覧など、ぜんぶここ）
create table if not exists public.docs (
  collection  text        not null,
  id          text        not null,
  data        jsonb       not null default '{}'::jsonb,
  updated_at  timestamptz not null default now(),
  primary key (collection, id)
);

alter table public.docs enable row level security;
alter table public.docs replica identity full;   -- 削除もリアルタイムで相手に届くように

grant select, insert, update, delete on public.docs to authenticated;

drop policy if exists "futari read"   on public.docs;
drop policy if exists "futari insert" on public.docs;
drop policy if exists "futari update" on public.docs;
drop policy if exists "futari delete" on public.docs;

create policy "futari read"   on public.docs for select to authenticated using (public.is_futari());
create policy "futari insert" on public.docs for insert to authenticated with check (public.is_futari());
create policy "futari update" on public.docs for update to authenticated using (public.is_futari()) with check (public.is_futari());
create policy "futari delete" on public.docs for delete to authenticated using (public.is_futari());

-- 3) リアルタイム更新（相手の変更がすぐ画面に出る）
do $$
begin
  alter publication supabase_realtime add table public.docs;
exception when duplicate_object then
  null; -- すでに追加済み
end $$;

-- 4) 写真の保存場所（非公開バケット photos）
insert into storage.buckets (id, name, public)
values ('photos', 'photos', false)
on conflict (id) do nothing;

drop policy if exists "futari photos read"   on storage.objects;
drop policy if exists "futari photos insert" on storage.objects;
drop policy if exists "futari photos update" on storage.objects;
drop policy if exists "futari photos delete" on storage.objects;

create policy "futari photos read"   on storage.objects for select to authenticated using (bucket_id = 'photos' and public.is_futari());
create policy "futari photos insert" on storage.objects for insert to authenticated with check (bucket_id = 'photos' and public.is_futari());
create policy "futari photos update" on storage.objects for update to authenticated using (bucket_id = 'photos' and public.is_futari()) with check (bucket_id = 'photos' and public.is_futari());
create policy "futari photos delete" on storage.objects for delete to authenticated using (bucket_id = 'photos' and public.is_futari());

-- 5) 確認用：ここまでエラーなく終われば OK
select 'ok' as setup, count(*) as docs from public.docs;
