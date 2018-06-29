# Emacs

Some of these commands are specific to my configuration.

## Escaping out

| Keybinding  | Description                        |                                                        |
|-------------|------------------------------------|--------------------------------------------------------|
| Esc Esc Esc | keyboard-escape-quit               | Exit interactive cmd; clear prefix arg; force 1 window |
| C-g         | keyboard-quit                      | Exit all things                                        |
| C-c Q       | kill-other-buffer-and-close-window | Kill minibuffer by the side (not accumulating cruft)   |

## Text editing

| Keybinding | Description          |   |
|------------|----------------------|---|
| M-TAB      | ispell-complete-word | - |
| M-(        | insert-parentheses   | - |

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
| C-M-f (a or n)  | -                                   | Forward sexp (vary between major mappings)     |
| C-M-b (e or p)  | -                                   | Backward sexp (vary between major mappings)    |
| C-M-d           | down-list                           | Move into balanced exp                         |
| C-M-u           | backward-up-list                    | Move out of balanced exp                       |
| C-x ;           | comment-or-uncomment-line-or-region | -                                              |

## File management

| Keybinding | Description    |                                        |
|------------|----------------|----------------------------------------|
| C-x C-d    | dired-jump     | Jump to current buffer's file in dired |
| C-x d      | dired          | Open dired                             |
| C-x C-d    | list-directory | Briefly list directory contents        |

Dired commands:

| Keybinding | Command | Description     |
|------------|---------|-----------------|
| R          | -       | Rename the file |

## Window

| Keybinding   | Description                 |                                            |
|--------------|-----------------------------|--------------------------------------------|
| C-x }        | enlarge-window-horizontally | -                                          |
| C-x {        | shrink-window-horizontally  | -                                          |
| C-x ^        | enlarge-window              | -                                          |
| C-x 0        | delete-window               | -                                          |
| C-M-v        | scroll-other-window         | -                                          |
| M-- C-M-v    | -                           | Scroll other window backwards              |
| C-x o, C-RET | other-window                | Cycle windows                              |
| C-l          | recenter-top-bottom         | Cycle screen center position               |
| C-l          | reposition-window           | Make current definition or comment visible |
| S-n          | scroll-viewport-up          | -                                          |
| S-p          | scroll-viewport-down        | -                                          |

## Buffer & navigation

| Keybinding  | Command         | Description                                      |
|-------------|-----------------|--------------------------------------------------|
| C-c <Left>  | winner-undo     | Cycle between window layouts (winner mode)       |
| C-c <Right> | winner-redo     | Cycle between window layouts (winner mode)       |
| C-c l       | next-buffer     | -                                                |
| C-c h       | previous-buffer | Previous buffer                                  |
| S-u         | revert-buffer   | Revert buffer to last save                       |
| M-i         | ido-goto-symbol | Jump to symbol (varies between modes, langs, etc |
| s-k         | kil-this-buffer | Kill buffer without prompting                    |

## Search and replace

| Keybinding | Command                 | Description |
|------------|-------------------------|-------------|
| C-s        | isearch-forward         | -           |
| C-r        | isearch-backward        | -           |
| C-M-s      | regexp-isearch-forward  | -           |
| C-M-r      | regexp-isearch-backward | -           |
| C-M-%      | query-replace-regexp    | -           |
| M-%        | query-replace           | -           |

Once in isearch:

| Keybinding | Command                   | Description                                       |
|------------|---------------------------|---------------------------------------------------|
| RET        | isearch-exit              | Non-interactive search                            |
| C-h b      | -                         | Get help on keybindings                           |
| M-e        | isearch-edit-string       | -                                                 |
| M-n        | isearch-ring-advance      | Next history item                                 |
| M-p        | isearch-ring-retreat      | Previous history item                             |
| M-r        | isearch-toggle-regexp     | Go to regex search mode (toggle modes)            |
| M-c        | isearch-toggle-case-fold  | Switch case insensitivity                         |
| RET        | isearch-exit              | -                                                 |
| C-g        | isearch-abort             | -                                                 |
| C-w        | isearch-yank-word-or-char | Yanks word from the buffer where the cursor is at |
| M-s C-e    | isearch-yank-line         | Yanks the whole line where the cursor is at       |

- When "failing isearch" appears:
  - The prompt is editable by default only with a good match. Press delete until the prompt is editable again.
  - Press `M-e` to edit the prompt with the bad match.

Once in query-replace many isearch commands apply, plus:

| Keybinding | Command | Description                       |
|------------|---------|-----------------------------------|
| !          | -       | Replace everything without asking |

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
| C-u C-SPC  | -                 |                                                    |
| C-x C-SPC  | pop-global-mark   | -                                                  |
| C-F        | -                 | Activate region forward                            |
| C-B        | -                 | Active region backward                             |
| C-x C-p    | mark-page         | -                                                  |
| C-x h      | mark-whole-buffer | -                                                  |
| C-M \      | -                 | Indent region (useful for wrapping a block of code |
| M-h        | mark-paragraph    | -                                                  |
| C-M-h      | mark-defun        | -                                                  |

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

| Keybinding             | Command | Description                                                           |
|------------------------|---------|-----------------------------------------------------------------------|
| M-n and M-p            | -       | Navigate between sections                                             |
| Tab                    | -       | Toggle section details                                                |
| g                      | -       | Refresh                                                               |
| k                      | -       | Discard file                                                          |
| cc                     | -       | Commit                                                                |
| C-c C-c                | -       | Confirm commit                                                        |
| C-c C-k                | -       | Cancel commit                                                         |
| s                      | -       | Stage                                                                 |
| ca                     | -       | Commit amend (prompts for message)                                    |
| ce                     | -       | Extend commit. Does not prompt for message                            |
| C-u C-x g or C-u C-x g | -       | Run magit status on another project                                   |
| bl                     | -       | Checkout local branch                                                 |
| bs                     | -       | Spinoff branch (create another branch                                 |
| p (-F) p               | -       | Push to corresponding remote                                          |
| p (-F) u               | -       | Push to upstream                                                      |
| fa                     | -       | Fetch all remotes                                                     |
| re                     | -       | Rebase elsewhere                                                      |
| rr                     |         | Continue rebase. `r` instead of `rr` gives a nice prompt with options |
| M-tab                  | -       | Cycle visibility of diffs in current buffer                           |
| C-tab                  | -       | Cycle visibility of current section and children                      |

Example of resolving a rebase conflict:

- `fa` - fetch all remotes
- `re` - rebase elsewhere, type out the target (example,
  `origin/develop`) or use the default one.
- Enter a conflicted file and magit will turn on `smerge-mode`. Press
  `C-c ^ o` (`smerge-keep-other`) to keep other; or `C-c ^ m`
  (`smerge-keep-mine`) to keep mine; `C-c ^ n` to move to the next
  conflicting area.
- Return to magit status (what idiomatic key is it other than `C-x g`?)
- `rr` to continue rebase.
- `P-Fp` pushes to the default upstream.

When browsing the log you can open a specific revision of a file with `magit-find-file`. Not sure how to do that from the diff screen.

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

Clojure editing tips:

- Suppose you typed the following at the REPL: `(cons [1 2] 3)`. Then you realize the arguments are in the wrong order. Place the cursor at `3`, then press `C-M-t` to swap the arguments.

References:

- [Cider - Running tests](https://github.com/clojure-emacs/cider/blob/master/doc/running_tests.md)
- [Basic emacs + cider](https://www.braveclojure.com/basic-emacs/)

## Paredit

| Command    | Description                 |                                                                |
|------------|-----------------------------|----------------------------------------------------------------|
| C-number ( | paredit-open-round          | Wraps in parenthesis. (to-regex \_str k) -> (to-regex (str k)) |
| M-s        | paredit-splice-sexp         | Splice current parenthesis                                     |
| C-)        | paredit;-backward-slurp-sexp | Expands to the next outer Sexp                                 |
| C-(        | paredit-forward-slurp-sexp  | Expands to the prev outer Sexp                                 |
| C-}        | paredit-forward-barf-sexp   | Contracts to the next Sexp - Opposite of slurping              |
| C-{        | paredit-backward-barf-sexp  | Contracts to the prev Sexp - Opposite of slurping              |
| M-S        | paredit-split-sexp          | Split sexp. (foo\_ bar) -> (foo) (bar)                         |

To bypass paredit to insert single parenthesis: `C-q (`. Use `C-q`!

References:

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

## Markdown

| Keybinding | Description          |   |
|------------|----------------------|---|
| C-TAB      | markdown-table-align | - |

## Compilation

| Keybinding | Description    |                                  |
|------------|----------------|----------------------------------|
| M-g M-n    | next-error     | Go to next compilation error     |
| M-g M-p    | previous-error | Go to previous compilation error |

## Process management

`M-x list-processes`

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

How to replace spaces with blank lines:

```elisp
["foo" "bar" "bat]
```

- Select the vector
- `M-%`
- Enter a blank space
- `C-q C-j` to enter a newline

## Search and replace

- Jump to dired
- Run `find-grep-dired` and type out the search pattern.
- Mark the files you want to run the replacement: `t`, `m`, `u` to unmark, etc.
- Press `Q` and type out the search/replacement pattern.
- Press `Y` to replace in all files, `!` to replace all occurrences of the current file, etc.
- `C-x s` runs `save-some-buffers`. Press `!` to confirm saving all files.
- Alternatively, open `ibuffer`, mark unsaved files with `*u`, `S` to save all files and `D` to close all of them.

The easiest alternative is to run `C-c p r`, `projectile-replace`.

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

### I want to rerun the last RSpec compilation

- I you are in a project file, `C-c , r`
- If you are in the compilation window, just `g`
- If you are in neither, `M-x recompile`

### Ruby console is outputting strange characters

Check out inf-ruby documentation, "Bugs" section.

### My Emacs instance does not reponse

```sh
pkill -SIGUSR2 emacs
```

### I accidentally messed up my shell and can't find the CLI

- Go to the end of the buffer
- `comint-set-process-mark`
- `comint-clear-buffer` `C-c M-o`
- `comint-kill-input` `C-c C-u`
- `comint-send-eof`
- `comint-show-output` `C-c C-r` - Show output of last command
- `comint-write-output` `C-c C-s` - Write output of last command
- `comint-next-prompt` `C-c C-n`, `comint-previous-prompt` `C-c C-p` Go to EOL, press enter to rerun command
- `comint-kill-subjob` - Kill a hanged process
- `C-c .`, `M-1 C-c .`, etc

### I want to customize shell colors

- `customize`
- `ansi-color-names-vector`
- Choose the colors

### There is a file at my cursor and I want to access it

`M-x find-file-at-point`

## Elisp

### Shortcuts

| Keybinding | Command           |                                 |
|------------|-------------------|---------------------------------|
| M-:        | eval-expression   | Evaluate a line of lisp code    |
| C-M-x      | eval-defun        | Evaluate current top-level sexp |
| C-x C-e    | eval-last-sexp    | Evaluate previous sexp          |
| -          | eval-region       | Evaluates an elisp region       |
| C-h v      | describe-variable | Query elisp variable value      |
| -          | ielm or repl      | An elisp repl                   |

### Debugging

```elisp
;; Enables debugging
(setq debug-on-error t)
```

- Or even better, `M-x toggle-debug-on-error`.
- The debugger will automatically open on errors.
- Press `e` to evaluate a lisp expression.
- Press `c` to continue.
- Press `C-h m` for help.
- Use `(debug)` to set an explicit breakpoint without having to mess
  with `(error "foo")`.

Press `C-u C-M-x` instead of just `C-M-x` to evaluate and instrument a function, so that you can use a debugger.

- Press `space` to step further.
- Press `?` for help.
- Press `q` to quit.

### To try out

- Actually read the Emacs Lisp intro. `C-h i` `m Emacs Lisp Intro`.
- ert tests.
- Use `check-parens` on save.
- `elint-current-buffer`.
- `redshank-mode` for refactoring.
- `elp-instrument-function`, call the function, run `elp-results`
- What more can `checkdoc` do?
- `elp-instrument-package` on every single function that begins with a letter. Call `elp-results` the same way.
- eless.scripter.co

### Cons cells

Represents an ordered pair: lists are built upon cons cells.

```elisp
(setq ccell '(head . tail))
(car ccell) ;; head
(cdr ccell) ;; tail
(cons 'head 'tail) ;; (head . tail)
```

### Symbols

A symbol has the following components (see symbol components in the manual):

- A name
- A value
- A function
- A property list

```elisp
(put 'h 'key 'value)
(symbol-plist 'h) ;; (key value)
(get 'h 'key) ;; value
(get 'h 'k) ;; nil

;; this is the same as using put
(setf (get 'h 'key) 'new-value)
(symbol-plist 'h) ;; (key new-value)
```

### Functions

Inline functions:

- Are faster than normal functions
- Increase the size of compiled code
- Do not behave well with debugging, tracing, and advising
- Function definition is expanded into the caller
- `defmacro` would expand into the same code, but can't be called with `apply`, `mapcar`, etc, while `defsubst` can.

```elisp
;; Both return the same results, but watch for the above details!
(defun a-number () 1)
(defsubst a-number () 1)
```

Receiving rest arguments as a list:

```elisp
(defun delegator (orig-fun &rest rest)
  (apply orig-fun rest))

(delegator (lambda (x y) (+ x y)) 1 2) ;; 3
```

And the same with optional arguments:

```elisp
(defun delegator (orig-fun &optional x y)
  (apply orig-fun `(,x ,y)))

(delegator (lambda (x y) (+ x y)) 1 2)
```

### Variables

```elisp
(defvar x 1 "a number") ;; x is 1
(defvar x 2) ;; x is still 1
(defvar y) ;; declares y

(setq z 1) ;; z is 1
(setq z 2) ;; z is 2
```

Dynamic binding:

```elisp
(setq x 1)
(defun get-x () x)

(let ((x 2)) (get-x)) ;; Returns 2
```

With `lexical-binding` the result is different:

```elisp
;; Must be declared at the first line
(setq lexical-binding t)

(setq x 1)
(defun get-x () x)

(let ((x 2)) (get-x)) ;; Returns 1
```

However, even with `lexical-binding`, things change if the variable is declared with `defvar`:

```elisp
;; Must be declared at the first line
(setq lexical-binding t)

(defvar x 1)
(defun get-x () x)

(let ((x 2)) (get-x)) ;; Returns 2
```

### General examples

```elisp
;; Printing a message
(message "prints a message")

;; Mapping over a list
(mapcar (lambda (x) (* x x)) '(1 2 3 4))

;; Use let to set up scoped bindings:
(let (x y)
  (setq x 1)
  (setq y 2)
  (+ x y)) ;; 3

;; You can also set the binding's value directly in the first form:
(let ((x 1)
      (y 2))
  (+ x y))

;; You can't reuse a binding in another binding:
(let ((x 1)
      (y (+ x 1)))
  (+ x y)) ;; error: void-variable x

;; Unless you use let*
(let* ((x 1)
      (y (+ x 1)))
  (+ x y)) ;; 3

;; You can use dolist to loop over a list
(dolist (v '("say" "these" "things"))
  (message v)) ;; nil

;; The third argument is "result", which has a default value of nil. The
;; dolist expression will always return "result" (hence the nil return value).
;;
;; dolist looks functional, but it is not. The "result" argument is only
;; useful if we use a mutable variable to update its value:
(let (reversed-list)
  (dolist (v '(1 2 3) reversed-list)
    (cons v reversed-list))) ;; nil

;; The example above will still return nil. We need to use setq to update
;; the variable's value:
(let (reversed-list)
  (dolist (v '(1 2 3) reversed-list)
    (setq reversed-list (cons v reversed-list)))) ;; '(3 2 1)

;; The message function accepts args. See the docs.
(message "%s" 1)

;; Concatenate lists by mutating them
(nconc '(1 2) '(3 4 5)) ;; (1 2 3 4 5)

;; Functional reverse
(reverse '(1 2 3 4 5))

;; Reverse in-place
(setq l '(2 2 3 4))
(nreverse l) ;; (4 3 2 2)
l ;; (2) wtf? where's the rest?
```

### Common Lisp Extensions

```elisp
;; Almost a comprehension
(cl-loop for i from 1 to 10 collect i) ;; (1 2 3 4 5 6 7 8 9 10)

;; Escaping out of a loop. Stops iteration at "2".
;; Justing requiring 'cl will "monkey patch" dolist to work this way.
(require 'cl)
(dolist (i '(1 2 3))
  (when (= 2 i) (return i)))
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
