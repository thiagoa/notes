# Tracing syscalls

Example: looking for opened files.

```bash
$ strace bundle | less # Does not work.. strace dumps to stderr
$ strace bundle 2>&1 | less
```

Narrowing down the list to specific syscalls:

```bash
$ strace -e open bundle 2>&1 # Does not include subprocesses
$ strace -f -e open bundle 2&1 # Includes subprocesses
```

If there are no results, it might happen that Linux uses "open"
variants such as `openat`.

```bash
$ strace -f -e openat bundle 2>&1 | tail
```

Lots of results, and it does not include ALL operations with files,
like checking for the existence of a file before opening it.

Make it include all operations with files with the `%file` shorthand:

```bash
$ strace -f -e %file bundle 2>&1 | tail
```

From this point on, try to use `grep` to narrow down the list further,
excluding matches we're not interested in:

```bash
$ strace -f -e %file bundle 2>&1 | grep -v -e /lib -e /usr | less
```

# Tracing library calls

```bash
$ ltrace -e getenv bundle
"/usr/local/bin/bundle" is not an ELF file
```

Needs an ELF executable, a binary file:

```bash
$ ltrace -e getenv ruby /usr/local/bin/bundle
libruby.so.2.7->getenv("RUBY_THREAD_VM_STACK_SIZE") = nil
libruby.so.2.7->getenv("RUBY_THREAD_MACHINE_STACK_SIZE") = nil
libruby.so.2.7->getenv("RUBY_FIBER_VM_STACK_SIZE") = nil
libruby.so.2.7->getenv("RUBY_FIBER_MACHINE_STACK_SIZE") = nil
libruby.so.2.7->getenv("RUBY_GLOBAL_METHOD_CACHE_SIZE") = nil
...
```

`getenv` is from the C standard library, and it was linked into `libruby.so.2.7`.

## What process is using a port?

Scan internet sockets:

```bash
$ sudo lsof -i
```

And with port 5000:

```bash
$ sudo lsof -i :3000
```

Or be specific about the protocol:

```bash
$ sudo lsof -i tcp:5000
```

The above commands, however, do not show the complete command name. To
do that, include the `+c0` flag:

```bash
$ sudo lsof -i tcp:5000 +c0
```

`+` is to turn flags on. `c` stands for "command", and `0` is a length to
signal "no limit".

## Know the parent of a process

```sh
ps -o ppid= PID
```
