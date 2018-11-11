## Lambdas and macros

TLDR; Pay attention when combining lambdas with macros. Follows a story:

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

Note that `func` does not get expanded into `test-func`.

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

### Lambdas and lexical scope

I can explain why the first code sample does not work:

```elisp
(setq my-lambda
      (let ((a "will print when a is in scope")
            (l (lambda () a)))
        (print (funcall l)) ;; Works
        l))

(funcall my-lambda) ;; Fails with (void-variable a)
```

The lambda call fails because `a` is not in scope. When inside `setq`, however, the lambda will work because `a` is in scope.

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

To fix it we must use a literal value:

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

This gets expanded to:

```elisp
(let ((a foo)) (function (lambda nil foo)))
```

And not:

```elisp
(let ((a "foo-value")) (function (lambda nil "foo-value")))
```

When passing a symbol to a macro, it does not get evaluated (`foo`
belongs to the runtime environment, not the expansion environment.)
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

**Lesson**: Elisp lambdas do not capture the lexical scope! And that
sucks big time. If you pass a symbol to `funcall` within a macro, you
can't simply refactor the symbol into a lambda and expect the same
results :(
