# Windows 11 Configuration Notes

## Preliminary settings

Having English as the default language makes it easier to troubleshoot on the web and follow this guide.

- Settings -> Time & language -> Language & Region (Configuracoes -> Hora e idioma -> Idioma & regiao)
  - Windows display language (Idioma de exibicao do Windows) -> Select "English (United States)"
    - Move English up in the priority
    - Make sure English is installed with the full language pack.
      - If not, move the English to the lower bottom, uninstall
        English, and install it with the full language pack. After that,
        move it up again.
  - Click on the three dots of "Portuguese (Brazil)" -> Click on "Language options"
    - Keyboards -> Click on the three dots of "Portuguese (Brazil ABNT)"
      - Click on "Remove" (unless using an ABNT keyboard)
    - Make sure "United States-International" is the alternate layout
      to "US". There should only be two keyboard layouts.

## Preliminary apps

- Fluent Search
  - TODO: Document
- 1Password
  - Go to Settings -> Keyboard Shortcuts
  - Set the following shortcuts (uses the same shortcuts as my Linux setup):
    - Show 1Password: `Ctrl + Alt + Shift + .`
    - Show 1Password mini: `Ctrl + Alt + /`
- Authy
- Dropbox
- aText (Microsoft Store to get Pro version)
  - Go to "Preferences"
    - Sync -> Sync location -> You know what
    - Sync -> On
    - Check "Start aText automatically when I sign in to Windows"

### Terminal installation

- Run Windows Terminal as Administrator
  - Run `wsl --list --online` to see available distros
  - Run `wsl --install -d Ubuntu` to install Ubuntu
  - Run `sudo apt update` and `sudo apt upgrade`
- Run Windows Terminal as user
  - Install dotfiles
  - Set it as the default terminal app
  - Go to "Settings -> Ubuntu
    - Go to "General" -> "Starting directory" -> Set "/home/thiago"
      - Remember that with my dotfiles setup, `Ctrl + Shift + d` opens a tab reusing the current tab's dir
    - Go to "Advanced" -> "Profile termination behavior" -> Check "Close when process exits, fails, or crashes"
    - Go to "Appearance" -> "Cursor" -> Check "Filled box""
    - Go to "Appearance" -> "Font size" -> Maybe change
    - Go to "Actions" -> "Summon Quake Window" -> Set `Win + [`
  - Go to "Settings -> Startup" -> Check "Default Profile: Ubuntu"

## General settings

Disable any startup apps not needed

- Run Windows 10 debloater UI
  - https://github.com/LeDragoX/Win10SmartDebloat
  - TODO: Add steps here
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
    - Uncheck "Tap with two fingers to right-click"
- Settings -> Click on the search bar (Find a setting) -> Type "Edit power plan" and click on the result
  - Click on "Change advanced power settings"
    - Expand "Processor power management"
    - Expand "Maximum processor state" -> On battery, type "80%" in place of "100%"
    - Expand ""Sleep" -> "Allow wake timers" -> "Plugged in: Check "Disable" (do disable "On battery" as well)
- Control Panel -> Hardware and Sound -> Power Options -> System Settings
  - Click on "Change settings that are currently unavailable"
    - Uncheck "Turn on fast startup (recommended)
  - Hit OK or Apply
- Right click on the taskbar -> Taskbar settings
  - Disable Chat
- Pin apps & organize the taskbar to leverage `Win + number` shortcuts
- System -> Power
  - Set to "Balanced" on laptop
  - Set to "Best performance" on desktop
- Settings -> Personalization -> Start -> Folders
  - Add favorite folders to start menu
- Press `Windows + v` and enable clipboard access
- Press `Windows + i` to open settings, type "Language bar" and enter
  - Click on "Input language hot keys"
  - Set: "Between input languages" -> `Left alt + shift`
  - Set everything else to `(None)`
  - This seems to free up `Ctrl + shift + 0` for Emacs
- Settings -> Display -> Night light
  - Check "Set hours", and "Turn on" at "8 00 PM" and "Turn off" at "7 00 PM"

## Apps to install or configure

All these apps can be pinned to the taskbar, except apps that are fired by shortcuts.

- Logitech Options
  - Go to the mouse
    - Set Scrolling direction "Inverted"
- [TrackballScroll.exe](https://github.com/Seelge/TrackballScroll/) (find it in `~/Dropbox/bin`)
  - Add a shortcut to `%appdata%\Microsoft\Windows\Start Menu\Programs\Startup`
  - Make sure that the Forward and Back buttons are assigned to their
    original functions in Logitech Options, otherwise this app won't
    work properly
- Brave
  - Enable sync with "Bookmarks", "Extensions", "History", "Settings"
  - Go to `brave://extensions/shortcuts` -> "1Password - Password Manager"
    - Set "Activate the extension" -> `Alt + Period`
- Slack
- VS Code
  - Enable sync
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
  - Keyboard manager -> Enable Keyboard Manager -> Toggle "On"
  - Keyboard manager -> Remap a shortcut.
    - `Ctrl (Left) + Shift + 0` => `Ctrl (left) + F11` (to make `paredit-forward-slurp-sexp` work in my Emacs setup)
    - `Win (Left) + Alt (Left) + Space` => `Ctrl (left) + F12` (to make `mark-word` work in my Emacs setup)
- Twitter (Microsoft Store)
- WhatsApp (Microsoft Store)
- Security modules
- Battery Percentage Icon: https://www.microsoft.com/en-us/p/battery-percentage-icon/9pckt2b7dzmw?activetab=pivot:overviewtab
- Notepad++
  - Settings -> Preferences -> General
    - Toolbar -> Check "Hide"
    - Check "Hide menu bar" (press Alt to access)

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
#NoEnv
SendMode Input

Send {LCtrl Up}{RCtrl Up}

#!Enter::
  Send, {Alt down}{Win down}{Enter}{Alt up}{LWin up}
  Return
LShift & Enter Up::
  GetKeyState, controlState, LCtrl

  if (A_PriorKey = "Enter" and controlState = "D") {
    Send !+{Enter}
  }
  else {
    Send +{Enter}
  }
  Send {LCtrl Up}{RCtrl Up}
  Send {LShift Up}{RShift Up}
  Return
LCtrl & Enter Up::
  GetKeyState, state, Control
  GetKeyState, altState, Alt
  if (A_PriorKey = "Enter" and state = "D") {
    if (altState = "D") {
      Send ^!{Enter}
      Send {LAlt Up}{RAlt Up}
    }
    else {
      Send ^{Enter}
    }
  }
  Send {LCtrl Up}{RCtrl Up}
  Return
LAlt & Enter Up::
  GetKeyState, state, Alt
  GetKeyState, winState, LWin
  if (A_PriorKey = "Enter" and state = "D") {
    if (winState = "D") {
      Send #!{Enter}
      Send {LWin Up}{LWin Up}
    }
    else {
      Send !{Enter}
    }
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
#NoEnv
SendMode Input

Send {LCtrl Up}{RCtrl Up}
Send {LWin Up}{RWin Up}

<#q::Send !{F4}
  Return

LCtrl & [::
  Send {Blind}{Control Up}{Esc}
  Return

<#]::
  Process, Exist, notepad++.exe
  notepad_pid = %ErrorLevel%

  if notepad_pid = 0
    Run, "C:\Program files\Notepad++\notepad++.exe"

  IfWinExist, ahk_pid %notepad_pid%
  {
    WinHide, ahk_pid %notepad_pid%
    Send {Alt down}{tab}{Alt up}
  }
  Else
  {
    DetectHiddenWindows, On
    WinGet, id, list, ahk_pid %notepad_pid%

    Loop, %id%
    {
      this_ID := id%A_Index%
      WinGetTitle, title, ahk_id %this_ID%

      If (title = "")
        Continue
 
      WinGetClass, class, ahk_id %this_ID%

      if (class != "Notepad++")
        Continue

      WinGet, exStyle, exStyle, ahk_id %this_ID%

      If !(exStyle & 0x100)
        Continue

      WinShow ahk_id %this_ID%
      WinActivate ahk_id %this_ID%

      Return
    }
  }
```

### Autostart scripts:

- Press `Win+R` and paste `%appdata%\Microsoft\Windows\Start Menu\Programs\Startup`
- Click with the right button, "new", and "shortcut"
- Select the first script to create a shortcut for it and then repeat the process for the others

Create shortcuts for the scripts

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

- WSL GUI Clipboard integration is not working. When I copy something
  from Emacs or use `xclip`, I'd expect it to work.

- No Wox plugins for: Brave bookmarks, personal GH access (only public
  browsing it seems)

- How to stop apps from installing app icons on the desktop? Answer: not possible, but I'll keep this on my list.

- `Win + q` AutoHotkey shortcut does not work when MS Edge is focused

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

### Cycling between desktop's Windows

Press `Alt + esc`

### Microsoft Mail shortcuts

- `Ctrl + Shift + v` - Move message to folder
- `Ctrl + y` - Go to folder
- `Backspace` - Archive

