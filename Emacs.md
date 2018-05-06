# Emacs

Some commands are bound to my specific setup.

## Commands

| Command        | Description                      |
|----------------|----------------------------------|
| eval-buffer    | Evaluates an elisp buffer        |
| eval-region    | Evaluates an elisp region        |
| describe-variable  | Query elisp variable value |
| ansi-term      | Opens up ansi term shell |
| eshell-here | For quick commands. Then C-x 0 to delete window. |

## Keybindings

| Command        | Description                      |
|----------------|----------------------------------|
| C-x t          | Helm mode |
| C-c l          | Next buffer        |
| C-c h          | Previous buffer        |
| M-H            | Mark paragraph |
| M-i            | Jump to symbol |
| M-r            | Cycle between top, middle, and bottom |
| M-g g          | Go to line |
| C-c pf         | Fuzzy find file |
| C-M-s          | Regex search |
| M-S-%          | Query replace |
| C-x }          | Increase window width |
| C-x {          | Decrease window width |
| C-x ^          | Increase window height |
| M-- M-r        | Go to bottom of the window |
| C-x h          | Select entire buffer |
| C-x 0          | Delete window |
| C-c <Left>     | Cycle between window layouts |
| C-c <Right>     | Cycle between window layouts |

## Magit

- `magit-status` or `m-stat`
- In status window, `cc` - commit
- In status window, `C-c C-c` - confirm commit
- In status window, `s` for stage
- In status window, `ca` - commit amend


## Interactive buffer area

Command: `C-x C-b`

- Mark buffers for deletion with `d`
- Confirm with `x`

## Elisp

```elisp
(message "prints a message")
```
