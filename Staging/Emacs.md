## Cool commands:

- `2 C-x TAB` (or `2 x-SPACE TAB`) - Indent rigidly right by 2 spaces
- `M-s w` - Word isearch, or `C-s M-s w`
- `M-s h .` - Highlight symbol at point
- `M-s h u` - Unhighlight a symbol
- `C-u M-s h u` - Unhighlight all symbols
- `C-M-d` - Go to next balanced expression
- `C-M-u` - Go back to previous balanced expression. In Ruby, goes back
- in the sexp and module hierachy.
- `C-;` (custom mapping) - Go up to char. `;` goesxs to next char; `,` goes back.
- `C-M-;` (custom mapping) - Go back to char. `;` goes to next char; `,` goes back.
- `M-s o` - Occur
- `M-s o` (inside isearch) - Show isearch results in occur
- Inside occur `e`: Edit occurrences. `C-c C-c` to exit. Also works in `multi-occur-in-matching-buffers`
- Inside occur `M-n`: Next match
- Inside occur `M-p`: Previous match
- `magit-find-file` - View a file in a certain revision.
- `C-x v ~` - Emacs VC - View a file in a certain revision
- `magit-log-buffer-file` + `magit-find-file` - The first command
looks for revisions. The second one picks up the revision from the
first one.
- `delete-matching-lines` or `flush-lines` for vim's `:g/d`
- Magit reset push destination: `bu`
- `C-x c b` - `helm-resume` to resume ag search or helm search, buffer, etc, `C-u C-x c b` Select a helm search
- `key-binding` to lookup the function bound to a key - `(funcall (key-binding "\C-k"))`
- `C-h C-K` to go to function by keybinding
- Emacs regex: https://www.emacswiki.org/emacs/RegularExpression
- Replace start of word. Example: `baz_at`, `foo_bar_at` by `foo_at`: `C-M-%`, `\(\sw+\)_at → foo_at`. `\sw` stands for "word constituent"
- Swiper repeat last search: press `C-s` to fill in the last search
term after activating swiper.
- Helm `C-c o` to open match at point in vertical split
- Helm `C-u C-c o` to open match at point in horizontal split
- `delete-windows-on` - Delete window on a certain buffer
- Frame commands: `C-x 5 2` - Create a new frame, `C-x 5 o` - Switch between frames, `C-x 5 ?` - Get help on available commands
- `compare-windows` (works only if the point in both buffers is in exactly the same place), ediff
- `C-x {`, `C-x }`, `C-x ^`, `shrink-window`, `C-x +` (balance windows)
- Recursive edits - In the middle of a query replace press `C-r` and edit text. Press `C-M-c` to return to query replace
or `C-]` to abort the recursive edit _and_ query-replace.
- Search and replace tricks: https://www.oreilly.com/library/view/learning-gnu-emacs/1565921526/ch04s02.html

## Effectively editing Ruby

There might be god-mode shortcuts here.

### Replace a function

1. `G-u` or `G-b` - Press `.` until getting to the beginning of the function
2. `C-M-SPC` - Select sexp
3. `R` - Replace text
4. `def<TAB>`

### Delete a function

1. `G-u` or `G-b` - Press `.` until getting to the beginning of the function
2. `C-p`
3. `C-M-'` - Select sexp + extra line
4. `C-d` or `Backspace`

### Snippet to prepend bundle exec to Rubocop

```lisp
;; .dir-locals.el
((enh-ruby-mode . ((eval . (setq-local flycheck-command-wrapper-function
                                 (lambda (command)
                                   (append '("bundle" "exec") command)))))))
```
