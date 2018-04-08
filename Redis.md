# Redis

## Redis versus memcached

Both are in-memory non-relational databases.

- Memcache is multi-threaded and only supports storing plain strings.
- Redis is single-threaded and supports strings, lists, sets, hashes, and sorted sets. It has partial transaction support.

## Features

- Master / slave replication: the slave receives a full initial copy of the data, and as writes are performed on master they are sent to all slaves.

## Characteristics

- In Redis, random reads and writes are fast in-memory operations.
    - In relational databases, INSERT writes to the end of an on-disk file.
    - In relational databases, UPDATE may cause random reads or writes.
- Queries in Redis don't need to go through a query parser/optimizer.
- Supported data structures: SET, LIST, STRING, HASH, ZSET (sorted set).

## Persistence

Redis supports:

- A point-in-time dump when certain conditions are met (e.g., a number of writes in a period).
- When dump-to-disk command is called.
- A write-ahead log (?) which logs every command to disk.

## General

```redis
> SET foo bar
OK
> GET foo
"bar"
> HSET hsh foo bar bat baz
(integer) 2
> DEL hsh foo
(integer 2)
```

## Lists

```redis
> RPUSH list foo bar bat
(integer 3)
> LRANGE list 0 -1
1) "foo"
2) "bar"
3) "bat"
> LPUSH list first
(integer) 4
> LPUSH list following
(integer) 5
> LRANGE list 0 -1
1) "following"
2) "first"
3) "foo"
4) "bar"
5) "bat"
> LINDEX list 2
"foo"
> LPOP list
"following"
> LRANGE list 0 -1
1) "first"
2) "foo"
3) "bar"
4) "bat"
```

## Sets

- Unordered: can't push or pop items from the ends.
- Add and remove items by value with `SADD` and `SREM`. Get everything with `SMEMBERS`.
    - `SADD my-set 1 2 3`
    - `SREM my-set 1 2`
    - `SMEMBERS my-set`.
- `SMEMBERS` can be slow for large sets.
- Test membership with `SISMEMBER`. Accepts just one argument.
    - `SISMEMBER my-set 1`.

## Hashes

- Similar to a document in a document store.

`HSET` returns the number of new items added to the hash.

```redis
> HSET my-hash foo bar
(integer) 1
> HSET my-hash foo bar
(integer 0)
> HSET my-hash foo bar bat baz
(integer 1)
```

`HDEL` returns the number of deleted items

```redis
> HDEL my-hash foo bar
(integer 2)
```

`HGETALL`:

```redis
> HGETALL my-set
(empty list or set)
```

## Ordered sets

- `ZRANGE` - Ascending score
- `ZREVRANGE` - Descending score

```redis
> ZADD my-o-set 100 foo
(integer) 1
> ZADD my-o-set 90 bar
(integer) 1
> ZRANGE my-o-set 0 -1
1) "bar"
2) "foo"
> ZRANGE my-o-set 0 -1 WITHSCORES
1) "bar"
2) "90"
3) "foo"
4) "100"
> ZRANGEBYSCORE my-o-set 0 99 WITHSCORES
1) "bar"
2) "90"
> ZREM my-o-set bar
(integer) 1
```

## Voting system

[On Redis playground](http://github.com/thiagoa/redis-playground)

## Use cases

To write session, temporary, or data with high-throughput needed.

```ruby
def update_token(conn, token, user, item: nil)
  timestamp = Time.now.to_i
  conn.hset 'login:', token, user
  conn.zadd 'recent:', timestamp, token

  if item
    conn.zadd "viewed:#{token}", timestamp, item

    # Keep most recent 25 viewed items
    conn.zremrangebyrank "viewed:#{token}", 0, -26
  end
end

LIMIT = 10_000_000

def clean_sessions(conn)
  loop do
    size = conn.zcard('recent:')

    if size <= LIMIT
      sleep 1
      next
    end

    end_index = [size - LIMIT, 100].min
    tokens = conn.zrange('recent:', 0, end_index - 1)
    session_keys = tokens.map { |t| "viewed:#{t}" }

    conn.delete(*session_keys)
    conn.hdel 'login:', *tokens
    conn.zrem 'recent:', *tokens
  end
end
```
