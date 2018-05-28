# Emacs

Some of these commands are specific to my configuration.

## Movement

| Keybinding      | Description                         |                                                |
|-----------------|-------------------------------------|------------------------------------------------|
| M-r             | move-to-window-line-top-bottom      | Cycle between top, middle, and bottom          |
| M-g g           | goto-line                           | -                                              |
| M-- M-r         | -                                   | Go to bottom of the window                     |
| M-0 M-r         | -                                   | Go to top of the window                        |
| M-+ M-r         | -                                   | Go to middle of the window                     |
| M-3 M-r         | -                                   | Go to the 3rd visible line (use any number)    |
| M-/             | dabbrev-expand                      | Auto-complete words                            |
| M-\             | -                                   | Hippie expand (compl lines and lisp symbols    |
| C-s C-w C-w ... | isearch-forward                     | Search for word under cursor, expand selection |
| C-M-f (a or n)  | -                                   | Forward sexp (vary between major mappings)     |
| C-M-b (e or p)  | -                                   | Backward sexp (vary between major mappings)    |
| C-M-d           | down-list                           | Move into balanced exp                         |
| C-M-u           | backward-up-list                    | Move out of balanced exp                       |
| C-x ;           | comment-or-uncomment-line-or-region | -                                              |
| C-s RET         |                                     | Non-incremental search                         |
| C-M-s           | -                                   | Regex search                                   |
| M-S-%           | -                                   | Query replace                                  |

## File management

| Keybinding | Description |                                        |
|------------|-------------|----------------------------------------|
| C-x C-j    | dired-jump  | Jump to current buffer's file in dired |

Dired commands:

| Keybinding | Command | Description     |
|------------|---------|-----------------|
| r          | -       | Rename the file |

## Window

| Keybinding   | Description                 |                               |
|--------------|-----------------------------|-------------------------------|
| C-x }        | enlarge-window-horizontally | -                             |
| C-x {        | shrink-window-horizontally  | -                             |
| C-x ^        | enlarge-window              | -                             |
| C-x 0        | delete-window               | -                             |
| C-M-v        | scroll-other-window         | -                             |
| M-- C-M-v    | -                           | Scroll other window backwards |
| C-x o, C-RET | other-window                | Cycle windows                 |
| C-l          | recenter-top-bottom         | Cycle screen center position  |
| S-n          | scroll-viewport-up          | -                             |
| S-p          | scroll-viewport-down        | -                             |

## Buffer & navigation

| Keybinding  | Command         | Description                                      |
|-------------|-----------------|--------------------------------------------------|
| C-c <Left>  | winner-undo     | Cycle between window layouts (winner mode)       |
| C-c <Right> | winner-redo     | Cycle between window layouts (winner mode)       |
| C-c l       | next-buffer     | -                                                |
| C-c h       | previous-buffer | Previous buffer                                  |
| S-u         | revert-buffer   | Revert buffer to last save                       |
| M-i         | ido-goto-symbol | Jump to symbol (varies between modes, langs, etc |

Searching in all open buffers:

- Run `M-x` `multi-occur-in-matching-buffers`
- In the first dialog, put `.`
- In the second, type out your search term

## Mark & Region

| Keybinding | Description       |                                                    |
|------------|-------------------|----------------------------------------------------|
| C-w        | kill-region       | -                                                  |
| M-w        | kill-ring-save    | Save region in kill ring                           |
| C-c C-h    | kill-whole-line   | -                                                  |
| C-x h      | mark-whole-buffer | -                                                  |
| C-u C-SPC  | pop-global-mark   | -                                                  |
| C-F        | -                 | Activate region forward                            |
| C-B        | -                 | Active region backward                             |
| C-x C-p    | mark-page         | -                                                  |
| C-x h      | mark-whole-buffer | -                                                  |
| C-M \      | -                 | Indent region (useful for wrapping a block of code |
| M-h        | mark-paragraph    | -                                                  |

## Terminal

| Keybinding | Command     | Description                                      |
|------------|-------------|--------------------------------------------------|
| C-c t      | ansi-term   | Ansi term shell                                  |
| -          | eshell-here | For quick commands. Then C-x 0 to delete window. |

## Help

| Keybinding | Command           | Description                                    |
|------------|-------------------|------------------------------------------------|
| C-h k      | describe-key      | Describe key                                   |
| C-h f      | describe-function | Describe function (can go to source)           |
| C-h w      | where-is          | Describe keybinding for function (whereis cmd) |
| C-h b      | describe-bindings | Show keybindings for current buffer            |
| C-h m      | describe-mode     | Show current buffer modes                      |
| C-h l      | find-library      | Goto a library source code (ex: window)        |
| -          | eval-buffer       | Evaluates an elisp buffer                      |

## Emacs Lisp

| Keybinding | Command           |                                 |
|------------|-------------------|---------------------------------|
| M-:        | eval-expression   | Evaluate a line of lisp code    |
| C-M-x      | eval-defun        | Evaluate current top-level sexp |
| C-x C-e    | eval-last-sexp    | Evaluate previous sexp          |
| -          | eval-region       | Evaluates an elisp region       |
| C-h v      | describe-variable | Query elisp variable value      |

## Finding files

| Keybinding | Command | Description       |
|------------|---------|-------------------|
| C-x t      | recentf | Open recent files |

## Projectile

| Keybinding    | Description                                       |                            |
|---------------|---------------------------------------------------|----------------------------|
| C-c p t       | projectile-toggle-between-implementation-and-test | -                          |
| C-c p f       | projectile-find-file                              | -                          |
| C-u C-c p f   | -                                                 | Find file refreshing cache |
| C-c p x s     | projectile-run-shell                              | -                          |
| C-c p s s     | projectile-ag                                     | -                          |
| C-u C-c p s s | -                                                 | Projectile ag regex        |
| C-c p w       | projectile-rails-console                          | -                          |

## Text editing

| Keybinding | Description    |                  |
|------------|----------------|------------------|
| M-q        | fill-paragraph | Reflow paragraph |

## Magit

| Keybinding | Command      | Description                              |
|------------|--------------|------------------------------------------|
| C-x g      | magit-status | Status window (key must be map globally) |

In status window:

| Keybinding             | Command | Description                           |
|------------------------|---------|---------------------------------------|
| M-n and M-p            | -       | Navigate between sections             |
| Tab                    | -       | Toggle section details                |
| g                      | -       | Refresh                               |
| k                      | -       | Discard file                          |
| cc                     | -       | Commit                                |
| C-c C-c                | -       | Confirm commit                        |
| C-c C-k                | -       | Cancel commit                         |
| s                      | -       | Stage                                 |
| ca                     | -       | Commit amend                          |
| C-u C-x g or C-u C-x g | -       | Run magit status on another project   |
| bl                     | -       | Checkout local branch                 |
| bs                     | -       | Spinoff branch (create another branch |
| p (-F) p               | -       | Push to corresponding remote          |
| p (-F) u               | -       | Push to upstream                      |

## Rectangles

Question: How to activate rectangle keymappings?

| Keybinding | Command                 | Description |
|------------|-------------------------|-------------|
| -          | delete-rectangle        | -           |
| -          | string-insert-rectangle | -           |

## Ansi term

| Keybinding | Command        | Description           |
|------------|----------------|-----------------------|
| C-c C-j    | term-line-mode | Escape from ansi term |
| C-c C-k    | term-char-mode | Return to term        |

To paste in ansi-term:

- First escape from ansi term
- Paste with whatever method
- Return to char mode

## macOS

| Keybinding | Command             | Description               |
|------------|---------------------|---------------------------|
| -          | ns-popup-font-panel | Open macOS font selection |

## Ibuffer

Command: `C-x C-b`

| Keybinding | Command | Description  |
|------------|---------|--------------|
| C-x C-b    | ibuffer | Open ibuffer |

Once in ibuffer;

| Keybinding | Command | Description                 |
|------------|---------|-----------------------------|
| d          | -       | Mark buffers for deletion   |
| g          | -       | Regenerate list of buffers  |
| x          | -       | Confirm action              |
| / m        | -       | Filter files by major mode  |
| u or DEL   | -       | Unselect buffer             |
| M-DEL      | -       | Unselect all                |
| S          | -       | Save selected buffers       |
| D          | -       | Delete all selected buffers |

## Cider

| Command     | Description                   |                                            |
|-------------|-------------------------------|--------------------------------------------|
| C-c C-k     | cider-load-buffer             | Compile current file                       |
| C-c C-z     | cider-switch-to-repl-buffer   | Alternate between repl and buffer          |
| C-c M-j     | cider-jack-in                 | Open up repl                               |
| C-c M-n     | cider-repl-set-ns             | Switch to current namespace                |
| C-c C-t n   | cider-test-run-ns-tests       | -                                          |
| C-c C-t t   | cider-test-run-test           | Run one test                               |
| C-c C-t r   | cider-test-rerun-failed-tests | -                                          |
| C-x C-e     | cider-eval-last-sexp          | Eval last sexp                             |
| C-u C-x C-e | -                             | Eval last sexp and insert results          |
| M-.         | cider-find-var                | Jump to definition (redef all the things!) |
| C-c C-d C-d | cider-doc                     | Jump to docs                               |

Some references:

- [Cider - Running tests](https://github.com/clojure-emacs/cider/blob/master/doc/running_tests.md)
- [Basic emacs + cider](https://www.braveclojure.com/basic-emacs/)

## Paredit

| Command    | Description                 |                                                                |
|------------|-----------------------------|----------------------------------------------------------------|
| C-number ( | paredit-open-round          | Wraps in parenthesis. (to-regex \_str k) -> (to-regex (str k)) |
| M-s        | paredit-splice-sexp         | Splice current parenthesis                                     |
| C-)        | paredit-backward-slurp-sexp | Expands to the next outer Sexp                                 |
| C-(        | paredit-forward-slurp-sexp  | Expands to the prev outer Sexp                                 |
| C-}        | paredit-forward-barf-sexp   | Contracts to the next Sexp - Opposite of slurping              |
| C-{        | paredit-backward-barf-sexp  | Contracts to the prev Sexp - Opposite of slurping              |
| M-S        | paredit-split-sexp          | Split sexp. (foo\_ bar) -> (foo) (bar)                         |

Some references:

- [Animated paredit](http://danmidwood.com/content/2014/11/21/animated-paredit.html)
- [Paredit cheatsheet](https://www.emacswiki.org/emacs/PareditCheatsheet)

## Ruby

| Keybinding | Command                | Description                        |
|------------|------------------------|------------------------------------|
| -          | inf-ruby-console-auto  | Figure out console for the project |
| C-c C-z    | ruby-switch-to-inf     | Toggles buffer and terminal        |
| C-x C-e    | ruby-send-last-sexp    | -                                  |
| C-x C-b    | ruby-send-block        | -                                  |
| C-x M-b    | ruby-send-block-and-go | -                                  |
| C-x C-q    | -       | Insert mode in pry breakpoint (see README) |

## Package management

This can improve a lot:

| Keybinding | Command             | Description                                |
|------------|---------------------|--------------------------------------------|
| -          | package-auto-remove | Remember to delete package from Cask first |


## Text editing tricks

How to wrap code with code, the manual way:

- Type out the top line, `C-SPC C-SPC` to set mark.
- Move to the end of the code block (maybe `C-M-n`, `C-n`, etc)
- Type out the bottom line, `C-M-\` to indent region.

## Point and mark

- Mark is is a buffer location that you set.
- Point is where your cursor is at.
- Region is the space between the mark and the point.
- A region can be activated or not (`C-space`).
- Some commands do set the mark automatically, for example:
  - `beginning-of-buffer`
  - `end-of-buffer`
  - `isearch`
- About [`transient-mark-mode`](https://www.gnu.org/software/emacs/manual/html_node/emacs/Disabled-Transient-Mark.html#Disabled-Transient-Mark):
  - Setting the mark does not highlight the region.
  - Temporarily enable mark with `C-SPC C-SPC`.
  - Some commands operate from point to the end of the buffer, and not on the region - example, `M-%`.

## Problems

### RSpec is dying with a strange error

- I've tried to run specs with `C-c , a`, but bundler was dying because it could not find a local gem.
- The solution was to set an environment variable pointing to the local gem: `$BUNDLE_LOCAL__MY_GEM`.

### Ruby console is outputting strange characters

Check out inf-ruby documentation, "Bugs" section.


## Elisp

### General examples

```elisp
;; Printing a message
(message "prints a message")

;; Mapping over a list
(mapcar (lambda (x) (* x x)) '(1 2 3 4))
```

### Interactive functions:

Prompting for buffers:

```elisp
(defun two-b (b1 b2)
  "Select two existing buffers.
   Put them into two windows, selecting the last one."
  (interactive "bBuffer1:\nbBuffer2:")
  (delete-other-windows) ; Same as C-x 1
  (split-window (selected-window) 8) ; Splits a window setting its size to 8
  (switch-to-buffer b1)
  (other-window 1) ; Same as C-x o
  (split-window (selected-window) 8)
  (switch-to-buffer b2))
```

Prompting for numbers:

```elisp
(defun grab-a-number (n)
  (interactive "nGo Ahead: ")
  (print (concat "You gave me " (number-to-string n))))
```

### Tricks

Compilation:

```elisp
(let ((default-directory "/Users/thiagoaraujo/Code/stack/stack-development/stack-api"))
	  (compile "bundle exec rspec" 'rspec-compilation-mode))
```
