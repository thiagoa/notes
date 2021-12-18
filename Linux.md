## Mount a luks drive that mysteryously does not want to mount

## Nautilus shortcuts

- F6 - Alternate between sidebar and main pane

## Restart network

- `ifconfig` - Get the name of the network interface
- `sudo wpa_cli -i wlp61s0 terminate` - Use the network interface as argument. This command kills wpa_supplicant.
- `sudo systemctl restart NetworkManager.service`

## Thunderbird shortcuts

- C+F: Search
- C+G: Select link
- Enter: Open link after select link

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

## Pinning a window to all workspaces

```sh
wmctrl -i -r 0x07c00010 -b add,sticky
```

### Gnome Emoji Shortcut

`C-S-e Space`

### GNOME extensions:

What if extensions are installed, in INITIALIZED state, but they can't be
ENABLED? Most likely `disable-user-extensions` is activated:
`/org/gnome/shell/disable-user-extensions` dconf key.

Check if an extension is ENABLED with the following command:

```sh
gnome-extensions info "clipboard-indicator@tudmotu.com"
```

If it is in INITIALIZED status and shows up in the Extensions app, you most
likely have to turn off the above dconf key.

#### system-monitor

#### Clipboard indicator

Check the following options:

- Move item to top after selection
- Toggle the menu: Alt + Super + ;
- What to show in top bar: Both
- History Size: 500
- Remove down arrow in top bar

### Fixing Ulauncher extensions

Edit `main.py` and put the following requires at the very top:

```py
import gi
gi.require_version('Gdk', '3.0')
```
