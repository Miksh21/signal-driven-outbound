-- ============================================================
-- The execution warehouse next to the CRM (reference excerpt)
-- Why this exists at all: docs/consolidation.md
-- Anonymized/abbreviated — representative shape, not the live DDL.
-- ============================================================

create extension if not exists citext;

-- Companies mirror the CRM (nightly refresh); the CRM stays the
-- system of record for deals/customers — this is the execution shape.
create table companies (
  id            uuid primary key default gen_random_uuid(),
  crm_id        int unique,                 -- deterministic join to the CRM
  name          text,
  domain        citext,
  is_customer   boolean,
  rating        text,                       -- A / B / C (potential)
  owner         text,
  updated_at    timestamptz default now()
);

create table deals (
  id            uuid primary key default gen_random_uuid(),
  crm_id        int unique,
  company_id    uuid references companies(id),
  is_open       boolean,
  is_won        boolean,                    -- won deals feed the past-placement alpha signal
  amount        numeric,
  valid_from    date
);

create table contacts (
  id                  uuid primary key default gen_random_uuid(),
  email               citext unique,
  linkedin_url        text,
  first_name          text,
  last_name           text,
  first_name_vocative text,                 -- Czech 5th case — morphology service, NOT regex
  last_name_vocative  text,
  gender              char(1),              -- drives verb agreement in generated copy
  language            text,                 -- cs / sk / other
  company_id          uuid references companies(id),
  owner               text,                 -- which sender owns this relationship
  source              text,                 -- which tool/list it came from (list forensics)
  icp                 boolean,
  updated_at          timestamptz default now()
);

-- One row per send / open / reply / connect — from ANY tool, ever.
-- History from the retired tools was harvested in before switch-off,
-- so cross-tool "when did we last touch them" survives consolidation.
create table touches (
  id            bigint generated always as identity primary key,
  contact_id    uuid references contacts(id),
  source        text,                       -- current sequencer / retired tools
  campaign_id   text,
  campaign_name text,
  channel       text,                       -- email / linkedin
  event_type    text,                       -- sent/opened/replied/bounced/unsubscribed/connected
  occurred_at   timestamptz
);
create index on touches (contact_id, occurred_at desc);

-- Suppression with a REASON — "why not" matters as much as "not".
create table suppression (
  id          bigint generated always as identity primary key,
  contact_id  uuid references contacts(id),
  value       citext,                       -- email or whole domain
  match_type  text,                         -- email / domain
  reason      text,                         -- blocklist/replied/bounced/unsub/customer/deal
  source      text,
  created_at  timestamptz default now()
);

-- ============================================================
-- contact_360 — the one view every automation reads.
-- Nothing downstream re-derives any of this.
-- ============================================================
create view contact_360 as
select
  c.id, c.first_name, c.last_name,
  c.first_name_vocative, c.last_name_vocative, c.gender, c.language,
  c.email, c.linkedin_url,
  co.name                                          as company,
  c.owner, c.source, c.icp,
  -- last touch across ALL tools, retired ones included
  lt.occurred_at                                   as last_contact_date,
  lt.campaign_name                                 as last_campaign,
  lt.source                                        as last_campaign_source,
  -- commercial status (mirrored from the CRM)
  coalesce(co.is_customer, false)                  as is_customer,
  exists (select 1 from deals d
          where d.company_id = c.company_id and d.is_open) as is_open_deal,
  -- one canonical answer to "may we contact this person, and if not, why"
  case
    when exists (select 1 from suppression s where s.contact_id=c.id and s.reason='unsub')   then 'unsubscribed'
    when exists (select 1 from suppression s where s.contact_id=c.id and s.reason='bounced') then 'bounced'
    when exists (select 1 from suppression s where s.contact_id=c.id and s.reason='replied') then 'replied'
    when exists (select 1 from suppression s where s.contact_id=c.id
                   and s.reason in ('blocklist','customer','deal'))                          then 'suppressed'
    else 'active'
  end                                              as subscriber_status
from contacts c
left join companies co on co.id = c.company_id
left join lateral (
  select t.occurred_at, t.campaign_name, t.source
  from touches t where t.contact_id = c.id
  order by t.occurred_at desc limit 1
) lt on true;
