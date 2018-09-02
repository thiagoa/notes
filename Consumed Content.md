# 2017-07-24

## Setting up a Fast, Comprehensive Search Routine with PostgreSQL

Link: https://rob.conery.io/2018/07/23/setting-up-a-fast-comprehensive-search-routine-with-postgresql/

Interesting article about how to implement a PG search across tables with:

- UNION
- Materialized views
- Full-text indexing

The materialized view queries all three tables. Running the `UNION`
query against a live data set is slow and makes three sequential
scans.

The first workaround is to use regex queries, which turn out to be
slow:

```sql
where blob ~* 'joe'
```

And it still is a sequential scan.

The materialized view is refreshed via a simple cron job with:

```sql
refresh materialized view concurrently admin_view;
```

The second approach is to use a GIN index:

```sql
SELECT ... UNION SELECT ... to_tsvector(concat(name,' ',email)) as search, ...
```

And:

```sql
create index idx_search on admin_view using GIN(search);
```

In the query:

```sql
WHERE search @@ to_tsquery('joe') order by ts_rank(serch, to_tsquery('joe')) desc;
```

This query does a much more efficient bitmap heap scan. And a
full-text index is of course not a perfect solution for the text we
are searching on.

For the most part, this article had no effect in my repertoire, but it
reminded me of PG's full text engine.

## Ruby Tapas 537 - The Messaging Myth

Link: https://www.rubytapas.com/2018/07/23/rubytapas_apple_crumb_tarts_with_avdi/

- OO has been envisioned by Alan Key with a message metaphor.
- OO thinks they program with "messages".
- Cognitive dissonance is dangerous
- Differences between real messages and OO messages:

|                       | Real Message | OO Message   |
| --------------------  | ----------   | ----------   |
| **Content**           | Information  | References   |
| **Concurrency**       | Async        | Sync         |
| **Bad Content**       | Benign       | Catastrophic |
| **Missing Recipient** | Benign       | Catastrophic |
