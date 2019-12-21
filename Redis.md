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

## HyperLogLog

This is great for frequency cap and the count-distinct problem
(counting unique elements in a set). A great example is a counter for
unique users based on session data. Note, however, that the count
is O(1) and might have a small error rate.

> Cardinality of the set: number of unique items.

```redis
> PFADD users id1
(integer) 1
> PFADD users id2
(integer) 1
> PFADD users id1
(integer) 0
> PFCOUNT users
(integer) 2
> PFADD other foo
(integer) 1
> PFCOUNT users other
(integer) 3
```

When the cardinality of the set changes, `PFADD` returns 1, otherwise 0.

## Voting system

[On Redis playground](http://github.com/thiagoa/redis-playground)

## Use cases

- Write session data
- Write temporary data
- Write data with high-throughput requirements

Example:

```ruby
def logged_in?(conn, token)
  conn.hget('login:', token)
end

def login(conn, token, user, item: nil)
  timestamp = Time.now.to_i

  # Store logged in user by token
  conn.hset 'login:', token, user

  # Add token to an ordered set to keep track of
  # the most recent tokens ordered by timestamp.
  # ZRANGE gets tokens ordered by ASC
  # ZREVRANGE gets tokens ordered by DESC
  conn.zadd 'recent:', timestamp, token

  if item
    # Keep track of the most recent viewed items by token
    conn.zadd "viewed:#{token}", timestamp, item

    # Keep most recent 25 viewed items
    conn.zremrangebyrank "viewed:#{token}", 0, -26
  end
end

LIMIT = 10_000_000

# This should run in a daemon to clean sessions
def clean_sessions(conn)
  loop do
    # Return cardinality of the sorted set
    size = conn.zcard('recent:')

    if size <= LIMIT
      sleep 1
      next
    end

    # When past LIMIT, clean at most 100 oldest items per iteration
    end_index = [size - LIMIT, 100].min
    tokens = conn.zrange('recent:', 0, end_index - 1)
    session_keys = tokens.map { |t| "viewed:#{t}" }

    conn.delete(*session_keys)
    conn.hdel 'login:', *tokens
    conn.zrem 'recent:', *tokens
  end
end
```
