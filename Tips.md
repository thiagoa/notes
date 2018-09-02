## What process is using a port?

```sh
sudo lsof -i tcp:5000
```

## Know the parent of a process

```sh
ps -o ppid= PID
```
