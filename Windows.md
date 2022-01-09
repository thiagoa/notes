# Windows 11 Configuration Notes

### General settings

Disable any startup apps not needed

- Settings -> Time & language -> Language & Region
  - Windows display language -> English (United States)
    - If you can't select English, uninstall English and install it fully with the language pack
    - English makes it easier to troubleshoot on the web
- `Windows + R` -> type "control keyboard" and `Enter`
  - Set "Repeat delay" and "Repeat rate" to max (i.e., short / fast)
- Settings -> System -> Multitasking -> Desktops
  - On the taskbar, show all the open windows -> Select "On all desktops"
  - Show all open windows when I press Alt + Tab -> Select "On all desktops"
  - Alt + Tab -> Select "Open windows only"
- Settings -> Privacy & Security -> General
  - Uncheck "Let apps show me personalized ads by using my advertising ID"
  - Uncheck "Let websites show me locally relevant content by accessing my language list"
  - Uncheck "Show me suggested content in the Settings app"
- Settings -> Privacy & Security -> Speech
  - Uncheck "Online speech recognition"
- Settings -> Privacy & Security -> Phone Calls
  - Uncheck "Phone call access"
- Settings -> Privacy & Security -> Call history
  - Uncheck "Call history access"
- Settings -> Privacy & Security -> Messaging
  - Uncheck "Messaging access"
- Settings -> Privacy & Security -> Radios
  - Uncheck "Radio control access"
- Settings -> Privacy & Security -> App diagnostics
  - Uncheck "App diagnostic access"
- Settings -> Time & language -> Date & time
  - Uncheck "Set time automatically" (come on Microsoft, stop advancing my time... nasty bug)
  - Do Set the date and time manually
- Settings -> Gaming -> Game Mode -> Uncheck "Game Mode"
- Settings -> Bluetooth & Devices -> Touchpad -> Taps
    - Uncheck "Tap with a single finger to single-click"
    - Uncheck "Tap with a two fingers to right-click"
- Settings -> Click on the search bar (Find a setting) -> Type "Edit power plan" and click on the result
  - Click on "Change advanced power settings"
    - Expand "Processor power management"
    - Expand "Maximum processor state" -> On battery, type "80%" in place of "100%"
  - Hit OK or Apply
- Right click on the taskbar -> Taskbar settings
  - Disable Chat
- Pin apps & organize the taskbar to leverage `Win + number` shortcuts
- Settings -> Personalization -> Start -> Folders
  - Add favorite folders to start menu
- Press `Windows + v` and enable clipboard access

## Apps to install or configure

All these apps can be pinned to the taskbar, except apps that are fired by shortcuts.

- Logitech Options
  - Go to the mouse
    - Set Scrolling direction "Inverted"
    - Disable SmartShift
- Brave
  - Enable sync with "Bookmarks", "Extensions", "History", "Settings"
  - Go to `brave://extensions/shortcuts` -> "1Password - Password Manager"
    - Set "Activate the extension" -> `Alt + Period`
- 1Password
  - Go to Settings -> Keyboard Shortcuts
  - Set the following shortcuts (uses the same shortcuts as my Linux setup):
    - Show 1Password: `Ctrl + Alt + Shift + /`
    - Show 1Password mini: `Ctrl + Alt + /`
- Authy
- Slack
- VS Code
- Emacs (installed by dotfiles)
  - Explicitly define UI font in `~/.emacs.custom.before.el`:
    - `(defvar my-default-font "DejaVu Sans Mono 14")`
- Windows Calendar
  - Add in my calendars
- Dropbox
- Mailspring
  - Sign in
  - Add in my accounts
  - Go to "Preferences -> Signatures"
    - Input full name on "Name", remove default "Title"
- Microsoft Edge
  - Enable sync on the top right button
  - Go to `edge://extensions/shortcuts` and activate 1Password with `Alt + .`
  - Sign in to 1Password
  - Sign in to Grammarly
  - Go to "Settings" and click on the search bar -> Type "Address bar and search"
    - Search engine used in the address bar -> Change to "Google"
    - Search on new tabs uses search box or address bar -> Select "Address bar"
- Windows Explorer
  - Go to "Options -> View" and Uncheck "Hide extensions for known file types"
- AutoHotkey
  - See scripts below
- aText (Microsoft Store to get Pro version)
  - Go to "Preferences"
    - Sync -> Sync location -> You know what
    - Sync -> On
    - Check "Start aText automatically when I sign in to Windows"
    - Check "Request Administrator privileges when auto-start"
- Wox (DON'T DOWNLOAD)
  - Open wox.exe (which is in portable mode) from Dropbox
    - Go to "Hotkey", set `Alt + Space`
    - Go to "General", check "Hide Wox on startup"
    - Maybe download the installer to install "Python" and "Everything" if missing
  - Change theme to "Gray" or another
- Everything -> https://www.voidtools.com/
  - Go to "Tools -> Options"
    - Check "Everything service" (to avoid Windows permission prompt)
    - Uncheck "Run as administrator"
- PowerToys
  - Still need to explore and see what I will enable or not
- Twitter (Microsoft Store)
- WhatsApp (Microsoft Store)

### Remapping the keyboard & AutoHotkey scripts

#### Caps Lock to Control

- Open Windows Terminal as Administrator
- Open a new PowerShell tab
- Run the below commands:

```powershell
$hexified = "00,00,00,00,00,00,00,00,02,00,00,00,1d,00,3a,00,00,00,00,00".Split(',') | % { "0x$_"};
$kbLayout = 'HKLM:\System\CurrentControlSet\Control\Keyboard Layout';
New-ItemProperty -Path $kbLayout -Name "Scancode Map" -PropertyType Binary -Value ([byte[]]$hexified);
```

We're not doing this mappingq via AutoHotkey because a lower level remapping is
beneficial to avoid edge cases with dual-function Enter/RCtrl and `Ctrl + [`
(i.e., dealing with caps lock state is a nightmare).

#### Dual-function Enter/RCtrl key

Save on `Dropbox\Aplicativos\AutoHotkey\dual_function_enter_control.ahk`:

```ahk
LCtrl & Enter Up::
  GetKeyState, state, Control
  if (A_PriorKey = "Enter" and state = "D") {
    Send ^{Enter}
  }
  Send {LCtrl Up}{RCtrl Up}
  Return
LAlt & Enter Up::
  GetKeyState, state, Alt
  if (A_PriorKey = "Enter" and state = "D") {
    Send !{Enter}
  }
  Send {LCtrl Up}{RCtrl Up}
  Send {LAlt Up}{RAlt Up}
  Return
Enter::RCtrl
~Enter Up::
  Send % "{RCtrl up}" ((A_PriorKey = "Enter") ? "{Enter}" : "")
```

#### Ctrl + [ for escape

Save on `Dropbox\Aplicativos\keybindings.ahk`:

```ahk
CapsLock & [::
  Send {Control Up}{Esc}
  Return

LCtrl & Enter::
  Send {Blind}^{Enter}
```

#### Autostart scripts:

- Press `Win+R` and paste `%appdata%\Microsoft\Windows\Start Menu\Programs\Startup`
- Click with the right button, "new", and "shortcut"
- Select the first script to create a shortcut for it and then repeat the process for the others

Create shortcuts for the scripts

### Terminal settings

- Run Windows Terminal as Administrator
  - Run `wsl --list --online` to see available distros
  - Run `wsl --install -d Ubuntu` to install Ubuntu
  - Run `sudo apt update` and `sudo apt upgrade`
  - Install dotfiles
  - Go to "Settings -> Ubuntu
    - Go to "General" -> "Starting directory" -> Set "/home/thiago"
      - Remember that with my dotfiles setup, `Ctrl + Shift + d` opens a tab reusing the current tab's dir
    - Go to "Advanced" -> "Profile termination behavior" -> Check "Close when process exits, fails, or crashes"
    - Go to "Appearance" -> "Cursor" -> Check "Filled box""
    - Go to "Appearance" -> "Font size" -> Maybe change
  - Go to "Settings -> Startup" -> Check "Default Profile: Ubuntu"

## Settings for XPS

### If experiencing slow UI on default 4k resolution

This is a tip for sensible people.

- System -> Display -> Display resolution: Set to 1920x1200 (snappier on 4k screen and still looks nice - DO NOT buy the 4k screen)

### If experiencing coil whine while charging

- Settings -> Click on the search bar (Find a setting) -> Type "Edit power plan" and click
  - Click on "Change advanced power settings"
  - Expand "Processor power management"
  - Expand "Maximum processor state" -> On plugged in, type "99%" in place of "100%"
  - Hit OK or Apply

## Things I want to eventually fix

- Pinning WSL GUI apps on the taskbar does not work correctly. Some
  are pinnable and others not, and the ones that are pinnable (like
  Emacs) will open a new window when clicking on the icon instead of
  switching to the existing window.

- If apps are not properly pinable, how to activate a WSL app with a
  shortcut like `Win + number`?

- Currently, there seems to be no way to change the WSL GUI penguim
  icon.

- `Ctrl+Shift+0` is taken by the OS: https://github.com/microsoft/vscode/issues/2585
Any way to unmap that keybinding so that Emacs can take it?

- WSL GUI Clipboard integration is not working. When I copy something
  from Emacs or use `xclip`, I'd expect it to work.

- No Wox plugins for: Brave bookmarks, personal GH access (only public
  browsing it seems)

- How to stop apps from installing app icons on the desktop? Answer: not possible, but I'll keep this on my list.

## Tips

### Copying and pasting

Copying:

```sh
echo Contents | clip.exe
```

Pasting:

```sh
powershell.exe Get-Clipboard
```
