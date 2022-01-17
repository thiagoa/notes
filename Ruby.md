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

## libffi error on Ubuntu 20.04 (WSL)

Example:

```
rails aborted!
LoadError: libffi.so.8: cannot open shared object file: No such file or directory - /home/thiago/.asdf/installs/ruby/3.0.2/lib/ruby/gems/3.0.0/gems/ffi-1.15.4/lib/ffi_c.so
/home/thiago/Code/thoughtbot/xxxxxxx/config/application.rb:7:in `<main>'
/home/thiago/Code/thoughtbot/xxxxxxx/Rakefile:4:in `<main>'
/home/thiago/Code/thoughtbot/xxxxxxx/bin/rails:5:in `<top (required)>'
<internal:/home/thiago/.asdf/installs/ruby/3.0.2/lib/ruby/3.0.0/rubygems/core_ext/kernel_require.rb>:85:in `require'
<internal:/home/thiago/.asdf/installs/ruby/3.0.2/lib/ruby/3.0.0/rubygems/core_ext/kernel_require.rb>:85:in `require'
/home/thiago/Code/thoughtbot/xxxxxxx/bin/spring:10:in `block in <top (required)>'
<internal:kernel>:90:in `tap'
/home/thiago/Code/thoughtbot/xxxxxxx/bin/spring:7:in `<top (required)>'
bin/rails:2:in `load'
bin/rails:2:in `<main>'

Caused by:
LoadError: cannot load such file -- 3.0/ffi_c
/home/thiago/Code/thoughtbot/xxxxxxx/config/application.rb:7:in `<main>'
/home/thiago/Code/thoughtbot/xxxxxxx/Rakefile:4:in `<main>'
/home/thiago/Code/thoughtbot/xxxxxxx/bin/rails:5:in `<top (required)>'
<internal:/home/thiago/.asdf/installs/ruby/3.0.2/lib/ruby/3.0.0/rubygems/core_ext/kernel_require.rb>:85:in `require'
<internal:/home/thiago/.asdf/installs/ruby/3.0.2/lib/ruby/3.0.0/rubygems/core_ext/kernel_require.rb>:85:in `require'
/home/thiago/Code/thoughtbot/xxxxxxx/bin/spring:10:in `block in <top (required)>'
<internal:kernel>:90:in `tap'
/home/thiago/Code/thoughtbot/xxxxxxx/bin/spring:7:in `<top (required)>'
bin/rails:2:in `load'
bin/rails:2:in `<main>'
(See full trace by running task with --trace)
```

The solution is described [here](https://stackoverflow.com/questions/70081693/how-to-install-webp-ffi-using-ruby-gems).

Download and install `libffi8_3.4.2-1ubuntu5_amd64.deb` from [here](https://packages.ubuntu.com/impish/amd64/libffi8/download).

## Debugging gems to try

- `Rack::Bug`
- `MemoryLogic`
- `Oink`

Article: https://blog.engineyard.com/thats-not-a-memory-leak-its-bloat
