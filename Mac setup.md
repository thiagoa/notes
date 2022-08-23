# Setting up a new mac (Monterey)

- Update macOS to latest
- Download:
  - 1Password
    - Go to Safari app -> Preferences -> Extensions -> enable 1Password
    - Clear `Command + \` shorcut for Emacs, which corresponds to `Meta + \` in Emacs (because I have `Meta` mapped to `Command` in Emacs)
  - Dropbox
  - OneDrive
  - Alfred
  - iTerm
    - Preferences -> Appearance -> General -> Theme -> Minimal
    - Preferences -> Profiles -> Text -> Font -> set 14pt
    - Preferences -> Profiles -> Configure Hotkey Window
      - Hotkey: ⌥] (make sure only the two options below are checked)
      - Check: Pin hotkey window (stays open on loss of keyboard focus)
      - Check: Animate show and hiding
    - Preferences -> Profiles -> Window -> Space -> set to All spaces
  - Install SF Mono
    - Open finder, go to /Applications/Utilities/Terminal.app/Contents/Resources/Fonts/
    - Select all fonts, hit Cmd + o to install
    - Change iTerm font to SF Mono
  - Emacs (install via homebrew - see below)
    - Change Emacs icon (see dotfiles)
    - To avoid Ruby script errors:
      - `sudo chmod go-w "/Applications/Emacs.app/Contents/MacOS"`
      - `sudo chmod go-w /Applications/Emacs.app/Contents/MacOS/bin-arm64-12`
      - `sudo chmod go-w /Applications/Emacs.app/Contents`
      - `sudo chmod go-w /Applications/Emacs.app`
      - `sudo chmod go-w /Applications/Emacs.app/Contents/MacOS/libexec-arm64-12`
    - To globally install Rubocop:
      - `asdf global ruby system`
      - `sudo gem install rubocop`
  - VS Code
  - Slack
  - Spotify
  - Twillio Authy
  - Brave
  - Cheatsheet
  - TinkerTool
    - Enable "Dock -> Use dimmed icons for hidden applications"
    - Enable "Dock -> Disable animation when hiding or showing Dock"
    - Enable "Dock -> Disable delay when showing hidden Dock"
    - Enable "Applications -> Don't ask for backup disks when connecting new drives"
    - Enable "Safari -> Backspace key can be used to navigate back"
  - Google Chrome (for capybara)
  - Karabiner-elements
    - If karabiner_grabber and karabiner_observer don't show up on Security & Privacy -> Input Monitoring, add them manually:
      - `/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_grabber`
      - `/Library/Application Support/org.pqrs/Karabiner-Elements/bin/karabiner_observer`
  - Grammarly for Safari (App store)
  - Twitter (App store)
  - Xcode (App store)
  - Microsoft TODO (App store)
  - WhatsApp (App store)
  - Unclutter (App store)
  - Módulo de segurança
- Accept xcode license in the terminal:
  - sudo xcodebuild -license
- Add internet accounts
- Run git on the terminal to trigger command line tools installation
- System Preferences:
  - Trackpad 
    - More Gestures -> Enable App Exposè
    - Point & Click -> Increase Tracking speed by 1 point
  - Accessibility -> Pointer control -> Mouse & Trackpad -> Trackpad options -> Enable dragging (with drag lock)
  - Battery
    - Power adapter -> uncheck Wake for network access
  - Keyboard
    - Keyboard -> Key Repeat -> set to Fastest
    - Keyboard -> Delay Until Repeat -> set to Shortest
    - Shortcuts -> (add) App Shortcuts -> Menu title: Zoom -> Keyboard shortcut: `Cmd + Shift + =`
    - Shortcuts -> Input Sources -> Disable or remap any `Ctrl + space` (maybe disable), `Cmd + shift + 3` (maybe `Cmd + shift + 6, 8, 9`) keybindings to free that up for Emacs
    - Shortcuts -> Mission Control -> Mission Control: `Cmd + Tab`
  - Touch ID
    - Add fingerprint for the second hand
- Security & Privacy:
  - Full Disk Access -> add Emacs and `/usr/bin/ruby`
- Users -> Edit my user's picture
- Disable accented characters - **log back in to apply**
  - defaults write -g ApplePressAndHoldEnabled -bool false
- Clone and install dotfiles:
  - `git clone https://github.com/thiagoa/dotfiles.git ~/.dotfiles`
  - `~/.dotfiles/setup.sh`
- Terminal, settings
  - Basic profile
    - Text -> change font to 14 points on MacBook Air
    - Shell -> When the shell exits, close the window
    - Keyboard -> check Use Option as Meta key
- Safari, settings
  - Tabs -> check Compact
- Tuple

## Others

Emacs (if internet is bad will take a long time to clone the repo):

```sh
brew install emacs-plus@28 --with-native-comp
```

Install ruby 2.6.7 with asdf on M1:

```sh
CFLAGS="-Wno-error=implicit-function-declaration" asdf install ruby 2.6.7
```

Install nokogiri then bundle again

```sh
gem install nokogiri -v VERSION_HERE --platform=ruby -- --use-system-libraries
```

Install ruby 3.0.3 with asdf on M1:

```sh
brew uninstall --ignore-dependencies readline
brew uninstall --ignore-dependencies openssll
rm -rf /opt/homebrew/etc/openssl@1.1
rm -rf /opt/homebrew/etc/openssl@1.1/cert.pem
rm -rf /opt/homebrew/etc/openssl@1.1/certs 
rm -rf /opt/homebrew/etc/openssl@1.1/ct_log_list.cnf
rm -rf /opt/homebrew/etc/openssl@1.1/ct_log_list.cnf.dist
rm -rf /opt/homebrew/etc/openssl@1.1/misc
rm -rf /opt/homebrew/etc/openssl@1.1/misc/CA.pl
rm -rf /opt/homebrew/etc/openssl@1.1/misc/tsget
rm -rf /opt/homebrew/etc/openssl@1.1/misc/tsget.pl
rm -rf /opt/homebrew/etc/openssl@1.1/openssl.cnf
rm -rf /opt/homebrew/etc/openssl@1.1/openssl.cnf.dist
rm -rf /opt/homebrew/etc/openssl@1.1/private
brew install -s readline
brew install -s ruby-build
asdf install ruby 3.0.3
```

For problems with the `ffi` gem:

```sh
RUBY_CFLAGS=-DUSE_FFI_CLOSURE_ALLOC
```

Unofficial Chromedrivers for Linux arm64:

https://stackoverflow.com/questions/38732822/compile-chromedriver-on-arm

```ruby
Selenium::WebDriver::Chrome::Service.driver_path = "/home/thiago/.webdrivers/chromedriver"
```

Install authy plugin (Go):

```sh
go install github.com/momaek/authy@latest
asdf reshim go
```

Install [authy Alfred plugin](https://github.com/momaek/authy). Edit workflow and change executable to `~/.asdf/shims/authy`
