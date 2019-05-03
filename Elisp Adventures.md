## Lists and cons cells

I thought I knew cons cells... did I? To be fair, I did at some point. But I mindlessly thought these two objects were equal:

```elisp
(equal '(1 2) '(1 . 2)) ;; nil
```

Of course they aren't. Let's get things straight:

```elisp
(equal '(1 2) '(1 . (2))) ;; t
```

Lists are not a primitive data type. Cons cells are. **A cons cell represents an ordered pair**. In a cons cell, CAR and CDR have equal weight. They are two slots, and there is nothing special about these slots.

By convention, the CAR of a list holds the element. The CDR holds the next list.

```elisp
'(1 . (2 . (3 . (4)))) ;; '(1 2 3 4)
```

Other facts:

- An empty cons cell has `nil` as both CAR and CDR.
- `nil` is an empty cons cell.
- Who comes first, the chicken or the egg? It doesn't matter, there's no inifinite loop here.

Actually, there are three types of list:

- True list: a chain of cons cells terminated by an empty list or nil. Example: `(1 . '(2))`. These are equivalent: `(1 . (2 . nil))`, `(1 . (2 . ()))`.
- Dotted list (in Erlang, improper lists): The CDR of the last element is not `nil` nor a list. Example: `(1 . (2 . 3))`
- Circular list: one of the elements is a backreference. Example: `(let ((a '(1 2))) (nconc a a))`.

## Adding to a list

### cons

The `cons` function creates a _new_ `cons` cell with CAR and CDR. For example:

```elisp
(cons 1 '(2 3)) ;; Creates '(1 2 3)
```

### nconc

Mutates the CDR of the _last_ element of a list.

```elisp
(let ((l '(1 2))) (nconc l '(3)))
```

### setcdr

Set arbitrary CDRs:

```elisp
(setq list '(one two three four))
(setq im-not-dead (cdr (cdr list)))

(setcdr (cdr list) '(two-and-a-half))
list ;; (one two two-and-a-half)
im-not-dead ;; (three four)
```

### add-to-list

This function:

- Mutates the list.
- Adds the value if it doesn't already exist.
- Is strange: you can't pass the list directly, but a symbol for the list instead.

```elisp
(let ((l '(2 3)))
  (add-to-list 'l 1)
  (add-to-list 'l 1)) ;; (1 2 3)
```

You can also append to the list with a third `t` argument:

```elisp
(let ((l '(2 3)))
  (add-to-list 'l 1 t)) ;; (2 3 1)
```

And the fourth argument changes the comparison function to something else.

## Lambdas and macros

TLDR; Pay attention to lambdas + macros. Follows a story:

To my surprise, the following code does not work:

```elisp
(let ((map (make-sparse-keymap))
      (keybinding "C-f")
      (func 'test-func))
  (define-key map (kbd keybinding) (lambda () (funcall func)))
  map)
```

It will result in:

```elisp
(keymap (6 lambda nil (funcall func)))
```

Note that `func` does not get expanded into `test-func`. Why the hell doesn't it?

Now notice what happens when we take the lambda out of the equation:

```elisp
(let ((map (make-sparse-keymap))
      (keybinding "C-f")
      (func 'test-func))
  (define-key map (kbd keybinding) func)
  map)
```

Now the `func` variable gets expanded correctly:

```elisp
(keymap (6 . test-func))
```

### Lambdas and lexical environment

I can explain why the first code sample does not work:

```elisp
(setq my-lambda
      (let ((a "will print when a is in scope")
            (l (lambda () a)))
        (print (funcall l)) ;; Works
        l))

(funcall my-lambda) ;; Fails with (void-variable a)
```

The lambda call fails because `a` is not in scope. When inside `setq`, however, the lambda works because `a` is in scope.

**Lesson**: Elisp lambdas are **not** bound to the lexical environment!
And that sucks big time. If you pass a symbol to `funcall` within a
macro, you can't simply refactor the symbol into a lambda and expect
the same results :(

### Why doesn't it work with a macro?

Let's wrap this up in a macro:

```elisp
(defmacro my-define-key (map keybinding func)
 `(define-key ,map (kbd ,keybinding) (lambda () (funcall ,func))))

 (let ((map (make-sparse-keymap))
       (keybinding "C-f")
       (func 'test-func))
   (my-define-key map keybinding func)
   map)
```

We suffer from precisely the same problem as before:

```elisp
;; Ooops... func not expanded...
(keymap (6 lambda nil (funcall func)))
```

And we can double check the expansion with `macroexpand-all`:

```elisp
 (macroexpand-all '(let ((map (make-sparse-keymap))
       (keybinding "C-f")
       (function 'test-func))
   (my-define-key map keybinding function)
   map))
```

Which gives the following result:

```elisp
(let ((map (make-sparse-keymap))
      (keybinding "C-f")
      (function (quote test-func)))
  (define-key map (kbd keybinding) (function (lambda nil (funcall function))))
  map)
```

To fix it, we must use a literal value:

```elisp
 (let ((map (make-sparse-keymap))
       (keybinding "C-f"))
   (my-define-key map keybinding 'test-func)
   map)
```

### Digging deeper

I would certainly hope that the macro call with a variable (as opposed to a literal) would work.

But I'm missing the point, and I will explain why in a second. Let's see a basic macro example:

```elisp
(defmacro create-custom-lambda (arg)
  `(let ((a ,arg)) (lambda () ,arg)))

(setq foo "foo-value")

(macroexpand-all '(create-custom-lambda foo))
```

This gets expanded into:

```elisp
(let ((a foo)) (function (lambda nil foo)))
```

And not:

```elisp
(let ((a "foo-value")) (function (lambda nil "foo-value")))
```

When passing a symbol to a macro, it does not get evaluated (`foo`
belongs to the runtime environment, not the compilation environment.)
Therefore, `foo` is expanded into a symbol.

Because `foo` exists as a global variable, our lambda works as a charm:

```elisp
(funcall (create-custom-lambda foo)) ;; Returns "foo-value"
```

Let's unset `foo` and see what happens:

```elisp
;; At this point foo exists... let's keep our lambda for future use.
(setq my-lambda (create-custom-lambda foo))

;; makunbound... what a strange way to unset a variable
(makunbound 'foo)

(funcall my-lambda) ;; Fails with (void-variable foo)
```

Awesome! `foo` is no longer in scope, so we get an error.

### A (partial) fix

There's an optional Elisp feature called "lexical binding". Unfortunately,
this feature doesn't work for global variables. Let's see:

```elisp
;; lexical-binding is a local variable
(setq lexical-binding t)

(setq foo "bar")
(setq my-lambda (create-custom-lambda foo))
(makunbound 'foo)

(funcall my-lambda) ;; Fails with the same error
```

With a `let`, however, the fix is granted:

```elisp
(let ((foo "bar"))
  (setq my-lambda (create-custom-lambda foo)))

(funcall my-lambda) ;; Returns "bar"
```

You can enable lexical binding with a comment when loading a file:

```
;;; -*- lexical-binding: t -*-
```
