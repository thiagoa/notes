# Emacs

Some commands are bound to my specific setup.

## Commands

| Command           | Description                                      |
|-------------------|--------------------------------------------------|
| eval-buffer       | Evaluates an elisp buffer                        |
| eval-region       | Evaluates an elisp region                        |
| describe-variable | Query elisp variable value                       |
| ansi-term         | Opens up ansi term shell                         |
| eshell-here       | For quick commands. Then C-x 0 to delete window. |

## Keybindings

| Command        | Description                           |
|----------------|---------------------------------------|
| C-x C-k        | Kill region                           |
| C-c C-h        | Kill line                             |
| M-w            | Copy region                           |
| C-x Ret m      | Help                                  |
| C-c Left/Right | Alternate between window layouts      |
| C-x t          | Helm mode                             |
| C-c l          | Next buffer                           |
| C-c h          | Previous buffer                       |
| M-H            | Mark paragraph                        |
| M-i            | Jump to symbol                        |
| M-r            | Cycle between top, middle, and bottom |
| M-g g          | Go to line                            |
| C-c pf         | Fuzzy find file                       |
| C-M-s          | Regex search                          |
| M-S-%          | Query replace                         |
| C-x }          | Increase window width                 |
| C-x {          | Decrease window width                 |
| C-x ^          | Increase window height                |
| M-- M-r        | Go to bottom of the window            |
| C-x h          | Select entire buffer                  |
| C-x 0          | Delete window                         |
| C-c <Left>     | Cycle between window layouts          |
| C-c <Right>    | Cycle between window layouts          |
| C-x g          | Magit status                          |

## Projectile

| Command        | Description                      |
|----------------|----------------------------------|
| C-c p t        | Switch between test and impl     |

## Magit

- `magit-status` or `m-stat` or `C-x g`

In status window:

- `M-n` and `M-p` to navigate between sections
- `Tab` to toggle details
- press `g` to refresh
- `cc` - commit
- `C-c C-c` - confirm commit
- `s` for stage
- `ca` - commit amend

## Seeing is believing

`gem install seeing_is_believing`

- Clear output: `C-c ? c`
- Run code at cursor: `C-c ? x`


## Interactive buffer area

Command: `C-x C-b`

- Mark buffers for deletion with `d`
- Confirm with `x`
- `g` to regenerate the list of buffers
- `/ m` to filter files by major mode
- `u` or `DEL` to unselect buffer
- `M DEL` + `return` to unselect all.
- `S` to save selected buffers.

Deleting all buffers:

- With all buffers unselected, press `t` to toggle selection and thus select all.
- Press `D` to delete all buffers.

### Compilation

```elisp
(let ((default-directory "/Users/thiagoaraujo/Code/stack/stack-development/stack-api"))
      (compile "bundle exec rspec" 'rspec-compilation-mode))
```

## Elisp

```elisp
(message "prints a message")
```

## Problems

I've tried to run specs with `C-c , a`, but bundler was dying. The solution was to set the environment variable `$BUNDLE_LOCAL__STACK_FOUNDATION`.
