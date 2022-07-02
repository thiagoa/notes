## Mount a luks drive that mysteryously does not want to mount

Still need to review these steps.

```bash
$ cat /proc/mounts # Find the drive
$ sudo umount /dev/mapper/...
$ sudo dmsetup ls --tree
$ ls -l /dev/mapper # Look for the real device, not the symlink
$ sudo dmsetup remove /dev/...
```

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

## Create luks partitions

```sh
sudo cryptsetup -v -y -c aes-xts-plain64 -s 512 -h sha512 -i 5000 --use-random luksFormat /dev/nvme0n1p2
sudo cryptsetup -v -y -c aes-xts-plain64 -s 512 -h sha512 -i 5000 --use-random luksFormat /dev/nvme0n1p3
sudo cryptsetup luksOpen /dev/nvme0n1p2 root-luks
sudo cryptsetup luksOpen /dev/nvme0n1p3 home-luks
sudo mkfs.ext4 /dev/mapper/root-luks
sudo mkfs.ext4 /dev/mapper/home-luks
```

Opening and mounting the devices:

The previous steps will implicitly open the devices, otherwise you can run these commands:

```sh
sudo cryptsetup luksOpen /dev/nvme0n1p2
sudo cryptsetup luksOpen /dev/nvme0n1p3
```

And then these ones:

```sh
sudo mount /dev/mapper/root-luks /mnt/root-luks
sudo mount /dev/mapper/home-luks /mnt/home-luks

sudo umount /mnt/root-luks
sudo umount /mnt/home-luks
sudo cryptsetup luksClose /dev/mapper/root-luks
sudo cryptsetup luksClose /dev/mapper/home-luks
```

## Problems with Redshift

Redshift keeps toggling on and off on your laptop? It might be because Automatic Brightness is on

In GNOME, go to Power -> Automatic Brightness and turn it off.

## Scaling GDM in 4k monitors

```sh
sudo apt install systemd-container
sudo machinectl shell gdm@ /bin/bash

# Or whatever scaling factor you want
settings set org.gnome.desktop.interface text-scaling-factor 1.8
```

## Install OpenSSL 1.1 on Ubuntu Impish to compile old versions of Ruby

```sh
$ sudo apt install build-essential checkinstall zlib1g-dev
$ cd ~/Downloads
$ wget https://www.openssl.org/source/openssl-1.1.1n.tar.gz
$ tar xf openssl-1.1.1n.tar.gz
$ cd ~/Downloads/openssl-1.1.1n
$ ./config --prefix=/opt/openssl-1.1.1n --openssldir=/opt/openssl-1.1.1n shared zlib
$ make
$ make test
$ sudo make install
$ sudo rm -rf /opt/openssl-1.1.1n/certs
$ sudo ln -s /etc/ssl/certs /opt/openssl-1.1.1n
$ RUBY_CONFIGURE_OPTS=--with-openssl-dir=/opt/openssl-1.1.1n rbenv install VERSION
$ export RUBY_CONFIGURE_OPTS="--with-openssl-dir=/opt/openssl-1.1.1n/"
```

Source: https://github.com/rbenv/ruby-build/discussions/1940#discussioncomment-2663209

## Fix a luks partition slow to decrypt

Change iter-time:

```sh
sudo cryptsetup -v luksChangeKey --iter-time 500 /dev/<partition>
```

## Fix full screen video with fractional scaling

When fractional scaling is enabled and running a full screen video,
GNOME keeps trying to refresh the resolution. I went through the
following threads:

https://bugs.launchpad.net/ubuntu/+source/gnome-shell/+bug/1863391
https://bugs.launchpad.net/ubuntu/+source/mutter/+bug/1862081
https://bugs.launchpad.net/ubuntu/+source/mutter/+bug/1890141

The solution was to install the "Disable unredirect fullscreen
windows" extension:

https://extensions.gnome.org/extension/1873/disable-unredirect-fullscreen-windows/
