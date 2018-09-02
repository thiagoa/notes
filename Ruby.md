## How to clear the sidekiq queue

```ruby
Sidekiq.redis { |r| r.flushall }
```
