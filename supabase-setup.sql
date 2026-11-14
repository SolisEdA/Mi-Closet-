-- Mi Closet: pega todo esto en Supabase > SQL Editor > New query y presiona "Run".

create table if not exists public.cajas (
  codigo     text primary key,           -- C01, C02...
  nombre     text,
  lugar      text,
  seccion    text,
  notas      text,
  ejemplo    boolean default false,
  creado     timestamptz default now()
);

create table if not exists public.prendas (
  id          uuid primary key default gen_random_uuid(),
  nombre      text not null,
  seccion     text,
  color       text,
  talla       text,
  marca       text,
  ubicacion   text default 'closet',     -- closet, cajon, caja, lavanderia, prestada
  caja        text references public.cajas(codigo) on update cascade on delete set null,
  notas       text,
  foto        text,                       -- ruta de la foto en el bucket "fotos"
  ejemplo     boolean default false,
  creado      timestamptz default now(),
  actualizado timestamptz default now()
);

-- Solo una persona con sesion iniciada (tu) puede ver y editar.
alter table public.cajas   enable row level security;
alter table public.prendas enable row level security;

drop policy if exists "solo con sesion" on public.cajas;
drop policy if exists "solo con sesion" on public.prendas;
create policy "solo con sesion" on public.cajas   for all to authenticated using (true) with check (true);
create policy "solo con sesion" on public.prendas for all to authenticated using (true) with check (true);

-- Fotos: bucket privado, solo con sesion iniciada.
insert into storage.buckets (id, name, public) values ('fotos', 'fotos', false)
on conflict (id) do nothing;

drop policy if exists "fotos con sesion" on storage.objects;
create policy "fotos con sesion" on storage.objects for all to authenticated
  using (bucket_id = 'fotos') with check (bucket_id = 'fotos');
