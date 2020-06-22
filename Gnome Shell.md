# Gnome Shell

Extension dir: `$HOME/.local/share/gnome-shell/extensions`

- [Gnome Shell Extensions](https://wiki.gnome.org/Projects/GnomeShell/Extensions)
- [Stack Overflow](https://stackoverflow.com/questions/8425616/how-to-test-debug-gnome-shell-extensions-is-there-any-tool-for-that).
- [Medium Blog Post](https://medium.com/@baymac/using-sqlite-in-gnome-extension-c499661d9bd5)
- [Looking Glass](https://wiki.gnome.org/Projects/GnomeShell/LookingGlass)
- [Spawn Flags](https://developer.gnome.org/pygobject/stable/glib-constants.html#glib-spawn-flag-constants). NOTE: Access through `GLib.SpawnFlags`.

## Debugging:

Debugging resources:

- Looking glass: `M-F2` => `lg`
- View debugging messages: `journalctl /usr/bin/gnome-shell -f -o cat`

## Running shell commands

Imports:

```js
const GLib = imports.gi.GLib
```

Sync shell commands:

```js
let [success, winid] = GLib.spawn_command_line_sync('xdotool getactivewindow')
```

Async shell commands:

```
GLib.spawn_async('/', ['/home/thiago/bin/dummy'], null, GLib.SpawnFlags.SEARCH_PATH, null)
```
