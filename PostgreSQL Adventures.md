## Importing the chinook database

Install [`pgloader`](https://www.google.com.br/url?sa=t&rct=j&q=&esrc=s&source=web&cd=1&cad=rja&uact=8&ved=2ahUKEwj91JSDgdvlAhUqzlkKHfH9BEAQFjAAegQIABAB&url=https%3A%2F%2Fgithub.com%2Fdimitri%2Fpgloader&usg=AOvVaw2XVIjman1N1SPPgZt7IC95) and then run:

```sh
$ createdb chinook
$ pgloader https://github.com/lerocha/chinook-database/raw/master/ChinookDatabase/DataSources/Chinook_Sqlite_AutoIncrementPKs.sqlite pgsql:///chinook
```

## About Functions

Prefer SQL language over PL/pgSQL for stored procedures _when
possible_. The latter might lead to misuse of control structures,
while the former favors more optimized control structures that can be
expressed in pure SQL.

```sql
-- chinook database
-- Example usage: SELECT * FROM get_all_albums('AC/DC');
CREATE OR REPLACE FUNCTION get_all_albums(
  IN name TEXT,
  OUT album TEXT,
  OUT duration INTERVAL
)
  RETURNS SETOF RECORD AS $$
DECLARE
  rec RECORD;
BEGIN
  FOR rec IN SELECT albumid
             FROM album
             JOIN artist USING(artistid)
             WHERE artist.name = get_all_albums.name
  LOOP
    SELECT title, SUM(milliseconds) * INTERVAL '1ms'
    INTO album, duration
    FROM ALBUM
    LEFT JOIN track USING(albumid)
    WHERE albumid = rec.albumid
    GROUP BY title
    ORDER BY title;

    RETURN NEXT;
  END LOOP;
END;
$$ LANGUAGE plpgsql;
```


This function is, of course, a waste. A `JOIN` + parameterization with
SQL function would solve the problem - or even no SQL function.

## RETURN NEXT and RETURN QUERY

`RETURN next` and `RETURN query` work for functions declared to return
`SETOF sometype` and with `OUT` function parameters (as per the last
example). The former assumes you've already gave values to the `OUT`
variables and will accumulate the current values into the result set.
The latter lets you do the same but is more explicit because the
query's result set is directly passed to `RETURN QUERY`. For instance,
we could do:

```sql
RETURN QUERY SELECT album.name, album.duration FROM album ....
```

This works exactly as `RETURN NEXT` but is more explicit. Note that
`RETURN NEXT` and `RETURN QUERY` can be mixed and matched.

## JOIN statement with more than one table

I haven't found documentation for this, but it's possible to do:

```sql
JOIN tbl1 ON ..., tbl2
```

This will join the entirety of `tbl2` records into the result set.
This is even more useful when paired with a lateral join. You could
join the 5 top results:

```sql
JOIN tbl1 ON ...,
     LATERAL (SELECT ... FROM tbl3
              ORDER BY ...
              WHERE tbl1.foo = tbl3.bar
              LIMIT 5) tbl2
```

Example:

```sql
-- chinook database
-- Functions are allowed in lateral joins
WITH four_albums AS(
  SELECT artist.artistid
  FROM album
  JOIN artist USING(artistid)
  GROUP BY artist.artistid
  HAVING COUNT(*) = 4
)

SELECT artist.name, album.album, album.duration
FROM four_albums
JOIN artist USING(artistid),
     LATERAL get_all_albums(artistid) album;
```

## Functions, Triggers, Listen and Notify - A short case study

How about I stop hacking over functions and triggers, and actually
build a mental framework about how they work?

First, create the following table:

```sql
CREATE TABLE accounts(id SERIAL PRIMARY KEY, name text);
```

Now let's see some code:

```sql
CREATE OR REPLACE FUNCTION accounts_changed()
  RETURNS trigger AS $DELIMITER$
DECLARE
  row RECORD;
BEGIN
  SELECT NEW.id, NEW.name, NEW.description INTO row;

  PERFORM pg_notify(
    'channel_name',
    json_build_object(
      'operation', TG_OP,
      'record', row_to_json(row)
    )::text
  );

  RETURN NULL;
END;
$DELIMITER$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS accounts_changed ON accounts;

CREATE TRIGGER accounts_changed
  AFTER INSERT OR UPDATE
  ON accounts
  FOR EACH ROW
    EXECUTE PROCEDURE accounts_changed();
```

Here we have a trigger function. The things to notice are:

- Trigger functions don't take explicit arguments.
- Special variables are created automatically in the top-level block.
- `NEW` is a special variable and it holds the new database row for
  INSERT/UPDATE operations. A complete list can be found
  [here](https://www.postgresql.org/docs/9.2/plpgsql-trigger.html).
- `TG_OP` is the operation: `INSERT` or `UPDATE`.
- `PERFORM` instead of `SELECT` discards the query results. If it was
  `SELECT` instead, there would have been an error.
- `RETURN NEW` could have been `RETURN NULL` as well. Why? Because this
is an `AFTER` trigger, so the return value of the trigger does not
matter.
- I'm selecting the columns that will get sent to the notification
channel. Why? Because `pg_notify` can send a payload of up to 8 kb.
Note that, even then, text columns can be big and surpass this limit.
- `$DELIMITER$` can be anything. Most commonly it is `$$`.
- We can listen to notifications with the `LISTEN channel_name;`
command.

Let's listen to the notifications:

```sql
[local] thiagoaraujo@pgpubsub=# [local] thiagoaraujo@pgpubsub=# LISTEN channel_name;
LISTEN
[local] thiagoaraujo@pgpubsub=# INSERT INTO accounts(name) VALUES('foo');
INSERT 0 1
Asynchronous notification "channel_name" with payload "{"operation" : "INSERT", "record" : {"id":722,"name":"foo","description":null}}" received from server process with PID 12169.
```

Awesome, the notification was sent!

Regarding the `RETURN NULL`, let's see what happens when we use it
along with a `BEFORE` trigger instead of `AFTER`:

```sql
CREATE OR REPLACE FUNCTION accounts_changed()
  RETURNS trigger AS $DELIMITER$
DECLARE
  row RECORD;
BEGIN
  SELECT NEW.id, NEW.name, NEW.description INTO row;

  PERFORM pg_notify(
    'channel_name',
    json_build_object(
      'operation', TG_OP,
      'record', row_to_json(row)
    )::text
  );

  RETURN NULL;
END;
$DELIMITER$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS accounts_changed ON accounts;

CREATE TRIGGER accounts_changed
  BEFORE INSERT OR UPDATE
  ON accounts
  FOR EACH ROW
    EXECUTE PROCEDURE accounts_changed();
```

Now let's try an `INSERT`:

```sql
[local] thiagoaraujo@pgpubsub=# INSERT INTO accounts(name) VALUES('foo');
INSERT 0 0
```

Right, 0 rows inserted. Now change to `RETURN NEW` and rerun:

```sql
[local] thiagoaraujo@pgpubsub=# INSERT INTO accounts(name) VALUES('foo');
INSERT 0 1
[local] thiagoaraujo@pgpubsub=# SELECT * FROM accounts;
 id  | name | description
-----+------+-------------
 715 | foo  | [NULL]
(1 row)

[local] thiagoaraujo@pgpubsub=#
```

Great. `NEW` is a `RECORD` kind and we can modify what ends up inserted:

```sql
CREATE OR REPLACE FUNCTION accounts_changed()
  RETURNS trigger AS $DELIMITER$
BEGIN
  IF NEW.name = 'fruit' THEN
    NEW.name := CONCAT(NEW.name, ' is a banana');
    NEW.description := 'or an orange? this is nonsense';
  END IF;

  RETURN NEW;
END;
$DELIMITER$ LANGUAGE plpgsql;
```

... and the values of `name` and `description` get modified only if
`name` is fruit (that's so weird... no better example right now):

```sql
[local] thiagoaraujo@pgpubsub=# INSERT INTO accounts(name) VALUES('fruit');
INSERT 0 1
[local] thiagoaraujo@pgpubsub=# SELECT * FROM accounts ORDER BY id DESC LIMIT 1;
 id  |       name        |          description
-----+-------------------+--------------------------------
 1   | fruit is a banana | or an orange? this is nonsense
(1 row)
```

### Nice URLs

- [Official docs](https://www.postgresql.org/docs/9.2/plpgsql-trigger.html)
- [SQL: PostgreSQL trigger for updating last modified timestamp](https://www.the-art-of-web.com/sql/trigger-update-timestamp/)
- [How to use LISTEN and NOTIFY PostgreSQL commands in Elixir?](https://blog.lelonek.me/listen-and-notify-postgresql-commands-in-elixir-187c49597851)
- [Random gist with some cool insights](https://gist.github.com/colophonemes/9701b906c5be572a40a84b08f4d2fa4e)
- [Trabalhando com Triggers no PostgreSQL](https://www.devmedia.com.br/trabalhando-com-triggers-no-postgresql/33531) (portuguese)
