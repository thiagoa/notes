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
  BEFORE INSERT OR UPDATE
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
INSERT 0 0
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

  RETURN NEW;
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
