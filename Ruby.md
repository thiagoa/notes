## How to clear the Sidekiq queue

```ruby
Sidekiq.redis { |r| r.flushall }
```

## Tracing the origin of a query with Rails

```ruby
ActiveSupport::Notifications.subscribe('sql.active_record') do |_, _, _, _, details|
  if details[:sql] =~ query_regex
    puts '*' * 50
    puts details[:sql]
    puts caller.join("\n")
    puts '*' * 50
  end
end
```
