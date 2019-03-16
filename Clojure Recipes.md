# Clojure Recipes

## Play with a library without creating a project

Assume the following library: [clojure/algo.monads](https://github.com/clojure/algo.monads)

Look at the GitHub page (or any other for the matter) for algo.monads and note its maven dependency:

```xml
<dependency>
  <groupId>org.clojure</groupId>
  <artifactId>algo.monads</artifactId>
  <version>0.1.6</version>
</dependency>
```

Run:

```sh
clj -Sdeps '{:deps {:org.clojure/algo.monads {:mvn/version "0.1.6"}}}'
```

In the REPL, run:

```clj
(require '[clojure.algo.monads :as monads])
```

Now you can play. Check out the [official Clojure page](https://clojure.org/guides/deps_and_cli) for more options.

In Emacs, run `M-:` and type:

```elisp
(cider-add-to-alist 'cider-jack-in-lein-plugins "org.clojure/algo.monads" "0.1.6")
```

If not already, don't forget to setup cider with:

```clj
(cider-allow-jack-in-without-project t)
```

Open a buffer (can be in-memory) in `clojure-mode` and `C-c M-j` or `cider-jack-in`. The repl will be connected to your buffer.

## if-let with more than one parameter

In Clojure, you can't `if-let` with more than one parameter.

```clj
(if-let [a 1, b nil] a) ;; Syntax error macroexpanding clojure.core/if-let
```

For that purpose, you can use a maybe monad from `clojure.algo.monads`:

```clj
(require '[clojure.algo.monads :as monads])

(monads/domonad monads/maybe-m [a 2 b nil] a) ;; nil
(monads/domonad monads/maybe-m [a 2 b 3] a) ;; 2
```

Forgive me for my poor example.

Or you can roll your own macro!
