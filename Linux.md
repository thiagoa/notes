## Mount a luks drive that mysteryously does not want to mount

Autokey new features:

https://github.com/autokey/autokey/blob/master/new_features.rst

Still need to review these steps.

```bash
$ cat /proc/mounts # Find the drive
$ sudo umount /dev/mapper/...
$ sudo dmsetup ls --tree
$ ls -l /dev/mapper # Look for the real device, not the symlink
$ sudo dmsetup remove /dev/...
```
