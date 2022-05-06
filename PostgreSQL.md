# PostgreSQL

## To remember

- Pattern matching with `SIMILAR TO`: https://postgresweekly.com/link/92192/ef08820b5c

## [Full-Text Search](https://www.compose.com/articles/mastering-postgresql-tools-full-text-search-and-phrase-search/)

- `tsvector` - What you query against
- `tsquery` - What you query with

Learn about it with ad-hoc usage:

```sql
[local] thiagoaraujo@play=# SELECT to_tsvector('The quick brown fox jumped over the lazy dog') @@ to_tsquery('jumping');
 ?column?
----------
 f
 (1 row)
 Time: 0,251 ms
 [local] thiagoaraujo@play=# SELECT to_tsvector('The quick brown fox jumped over the lazy dog') @@ to_tsquery('lost');
 ?column?
----------
 f
 (1 row)
 Time: 0,291 ms
 ```

### About tsvector

It has the following format:

```sql
[local] thiagoaraujo@play=# SELECT to_tsvector('I like black coffee, green tea, and black tea');
                            to_tsvector
-------------------------------------------------------------------
 'and':7 'black':3,8 'coffee':4 'green':5 'i':1 'like':2 'tea':6,9
(1 row)

Time: 0,287 ms
```

A vector with each lexeme followed by their respective positions on
the document (can range from 1 to 16383). Positions can be used
for _proximity ranking_.

To represent whitespace or punctuation use `$$` delimiters and
surround the tokens with quotes:

```sql
[local] thiagoaraujo@play=# SELECT $$I '     ' like black coffee, green tea, and black tea '.'$$::tsvector;
                              tsvector
---------------------------------------------------------------------
 '     ' '.' 'I' 'and' 'black' 'coffee,' 'green' 'like' 'tea' 'tea,'
(1 row)

Time: 0,208 ms
```

In the above representation, the tokens were converted to `TSVECTOR`,
but weren't processed by `to_tsvector`. Therefore, we can create a
vector with an ad-hoc structure:

```sql
[local] thiagoaraujo@play=# SELECT 'the:1,4 fool:2 on:3 hill:5'::tsvector;
              tsvector
------------------------------------
 'fool':2 'hill':5 'on':3 'the':1,4
(1 row)

Time: 0,244 ms
```

Positions can be further labelled with a weight (A, B, C, or D - D is
the default and is thus not shown):

```sql
[local] thiagoaraujo@play=# SELECT 'oh:1D my:2D god:3A,4A'::tsvector;
         tsvector
---------------------------
 'god':3A,4A 'my':2 'oh':1
(1 row)

Time: 0,228 ms
```

This is useful for ranking functions to differentiate, for example,
titles, which have a higher weight, from body.

By default `tsvector` doesn't perform any normalization,
but you can specify the language as the first parameter:

```sql
[local] thiagoaraujo@play=# SELECT to_tsvector('english', 'One man, two men, three men, four men... orange and oranges');
                             to_tsvector
---------------------------------------------------------------------
 'four':7 'man':2 'men':4,6,8 'one':1 'orang':9,11 'three':5 'two':3
(1 row)

Time: 14,512 ms
[local] thiagoaraujo@play=# SELECT to_tsvector('Portuguese', 'O Rio de Janeiro continua lindo')
[more] - > ;
               to_tsvector
-----------------------------------------
 'continu':5 'janeir':4 'lind':6 'rio':2
(1 row)

Time: 6,093 ms
```

Use `\dF` to list available languages in psql.

Notice the stemmed lexemes. Stop words are automatically removed:

```sql
[local] thiagoaraujo@play=# SELECT to_tsvector('english','get in the car');
   to_tsvector
-----------------
 'car':4 'get':1
(1 row)

Time: 0,279 ms
```

### About tsquery

`tsquery` requires special syntax. This is not valid:

```sql
[local] thiagoaraujo@play=# SELECT to_tsquery('one two');
ERROR:  42601: syntax error in tsquery: "one two"
LOCATION:  makepol, tsquery.c:726
Time: 6,282 ms
```

Therefore, all tokens need to be interspersed between boolean operators:

```sql
[local] thiagoaraujo@play=# SELECT to_tsvector('The quick brown fox jumped over the lazy dog') @@ to_tsquery('over & lazy');
 ?column?
----------
 t
(1 row)

Time: 0,304 ms
```

A more involved example:

```sql
[local] thiagoaraujo@play=# SELECT to_tsvector('The quick brown fox jumped over the lazy dog') @@ to_tsquery('fox & (dog | clown) & !queen');
 ?column?
----------
 t
(1 row)

Time: 0,237 ms
```

It can also be labelled with a weight:

```sql
[local] thiagoaraujo@play=# SELECT 'oh:1D my:2D god:3A,4A'::tsvector @@ to_tsquery('god:A');
 ?column?
----------
 t
(1 row)

Time: 0,453 ms
[local] thiagoaraujo@play=# SELECT 'oh:1D my:2D god:3A,4A'::tsvector @@ to_tsquery('god:b');
 ?column?
----------
 f
(1 row)
```

And `tsquery` supports prefix matching:


```sql
[local] thiagoaraujo@play=# SELECT 'my funny valentine'::tsvector @@ 'val:*'::tsquery;
 ?column?
----------
 t
(1 row)

Time: 0,264 ms
[local] thiagoaraujo@play=# SELECT 'my funny valentine'::tsvector @@ 'val'::tsquery;
 ?column?
----------
 f
(1 row)

Time: 0,283 ms
```

### Working with tsvector

- On-the-fly: `WHERE to_tsvector(document_text) @@
  to_tsquery('jump & quick')`. This is not good for production.
- In a `TSVECTOR` column by manually handing the contents
over to `UPDATE`.
- In a `TSVECTOR` column with a trigger
- Use a generated column (PostgreSQL >= 12)

To create a `TSVECTOR` column:

```sql
CREATE TABLE documents
(
    id SERIAL NOT NULL,
    document_text TEXT NOT NULL,
    document_tokens TSVECTOR NOT NULL,

    CONSTRAINT documents_pkey PRIMARY KEY (id)
);
```

Update it manually with:

```sql
UPDATE documents SET document_tokens = to_tsvector(document_text);
```

Or automatically with a trigger:

```sql
CREATE FUNCTION documents_update() RETURNS TRIGGER AS $$
BEGIN
    NEW.document_tokens = to_tsvector('english', NEW.document_text);
    RETURN NEW;
END
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE ON documents
FOR EACH ROW EXECUTE PROCEDURE documents_update();
```

Or even with a generated column:

```sql
CREATE TABLE documents
(
    id SERIAL NOT NULL,
    document_text TEXT NOT NULL,
    document_tokens TSVECTOR NOT NULL GENERATED ALWAYS AS (to_tsvector('english', document_text)) STORED,

    CONSTRAINT documents_pkey PRIMARY KEY (id)
);
```

### More advanced features

- Search dictionaries: to deal with synonyms. Read about Dictionaries
[here](https://www.postgresql.org/docs/current/textsearch-dictionaries.html).
- Other `ts_` functions
- [Search configuration](https://www.postgresql.org/docs/current/textsearch-configuration.html)
  - The parser to break text into tokens
  - The dictionaries to use to transform each token into a lexeme
  - The stop words
  - The template for synonyms
  - Spelling and typographical errors
- [More about ranking](https://www.postgresql.org/docs/current/textsearch-controls.html)
