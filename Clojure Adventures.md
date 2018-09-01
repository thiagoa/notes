## 2018-09-02 - Error messages

A Clojure programmer needs to be good at figuring out cryptic errors. This is currently being improved in the language, but the advice still applies. For example, I had my tests setup with the following hook:

```clj
(use-fixtures
  :once
  (fn [f]
    (binding [*db* (connect-to-db)]
      (migrations/migrate ["migrate"] db-url)
      (f)
      (disconnect-db *db*))))
```

Compiling and running the tests with CIDER gave me the following error:

```
Exception in thread "nREPL-worker-8"
java.lang.NullPointerException
    at clojure.lang.Symbol.intern(Symbol.java:59)
    at clojure.core$symbol.invokeStatic(core.clj:579)
    at clojure.core$symbol.invoke(core.clj:574)
    at cider.nrepl.middleware.test$report_fixture_error.invokeStatic(test.clj:184)
    at cider.nrepl.middleware.test$report_fixture_error.invoke(test.clj:174)
    at cider.nrepl.middleware.test$test_vars.invokeStatic(test.clj:221)
    at cider.nrepl.middleware.test$test_vars.invoke(test.clj:210)
    at cider.nrepl.middleware.test$test_ns.invokeStatic(test.clj:232)
    at cider.nrepl.middleware.test$test_ns.invoke(test.clj:223)
    at cider.nrepl.middleware.test$test_var_query.invokeStatic(test.clj:243)
    at cider.nrepl.middleware.test$test_var_query.invoke(test.clj:236)
    at cider.nrepl.middleware.test$handle_test_var_query_op$fn__30654$fn__30655$fn__30656.invoke(test.clj:288)
    at cider.nrepl.middleware.test$handle_test_var_query_op$fn__30654$fn__30655.invoke(test.clj:287)
    at clojure.lang.AFn.applyToHelper(AFn.java:152)
    at clojure.lang.AFn.applyTo(AFn.java:144)
    at clojure.core$apply.invokeStatic(core.clj:657)
    at clojure.core$with_bindings_STAR_.invokeStatic(core.clj:1965)
    ...........
```

What is going on there? The stack trace doesn't even mention the test file! Before the explosion, something went on in CIDER nRepl middleware. Turns out the stack trace is being muddled with CIDER stuff. Alternatively, I can try running the tests in the REPL to reproduce the error and get a purer stack trace:

```clj
;; Switch to the test ns before
(run-tests)
```

And here's the stack trace:

```
1. Unhandled java.lang.ClassCastException
   java.base/java.lang.Character cannot be cast to
   java.base/java.util.Map$Entry

       APersistentMap.java:   42  clojure.lang.APersistentMap/cons
                   RT.java:  670  clojure.lang.RT/conj
                  core.clj:   85  clojure.core/conj
                  core.clj: 3041  clojure.core/merge/fn
                  core.clj:  936  clojure.core/reduce1
                  core.clj:  926  clojure.core/reduce1
                  core.clj: 3040  clojure.core/merge
                  core.clj: 3033  clojure.core/merge
               RestFn.java:  421  clojure.lang.RestFn/invoke
                  core.clj:   96  luminus-migrations.core/migrate
                  core.clj:   83  luminus-migrations.core/migrate
               ...
```

That's much better. By looking at it, I can tell the code is _almost_ getting past the migrations function, but it dies somewhere along the way. I click on the stack trace and CIDER takes me to the right line at the right file (Luminus source code):

```clj
(defn migrate
  "args - vector of arguments, e.g: [\"migrate\" \"201506104553\"]
   opts - map of options specifying the database configuration.
   supported options are:
   :database-url - URL of the application database
   :migration-dir - string specifying the directory of the migration files
   :migration-table-name - string specifying the migration table name"
  [args opts]
  (when-not (migration? args)
    (throw
     (IllegalArgumentException.
      (str "unrecognized option: " (first args)
           ", valid options are:" (join ", " (keys migrations))))))
  (let [config (merge {:store :database} (parse-url opts))]
    ((get migrations (first args)) config args)))
```

The stack trace points at line 96: `(let [config ...)`. I change it to insert a debugger breakpoint like so:

```clj
(let [config (merge {:store :database} #break (parse-url opts))]
```

I try to reevaluate the function with `C-M-x`, but it's not connected to the CIDER REPL (the project is not recognized by CIDER). It seems to have been extracted off a JAR file. Well, I can still evaluate the function, but it would be better if I figured out a way to connect to the REPL and reevaluate the function directly in the Emacs buffer. No problem; in the REPL, I can do:

```clj
(in-ns 'luminus-migrations.core)
```

The yank the modified function with the breakpoint, which makes the REPL reevaluate it. Now run the tests:

```clj
(in-ns 'some-ns.db.core)
(run-tests)
```

Boom! Now I can press `e` to evaluate an expression. I notice `opts` is a string, the DB URL. Very strange. `opts` implies a map. By looking at the docs, it mentions a `:database-url` argument. So, there's our problem: I should have passed a map: `{:database-url db-url}`.

A deeper analysis: the `(parse-url opts)` line returns an unmodified string. This is clearly wrong: it should fail if the argument is not a map. Then it tries to do a merge: `(merge {:store :database} "db-url-str")`. What happens then?

```
ClassCastException java.base/java.lang.Character cannot be cast to java.base/java.util.Map$Entry  clojure.lang.APersistentMap.cons (APersistentMap.java:42)
```

And there's our error. It is trying to cast a string to a map entry.

## 2018-09-02 - CIDER/REPL Tests

When I run DB tests in a CIDER REPL, it uses the development database. The `lein test` command, on the other hand, uses the test database. I want to use the test database in CIDER.

The solution is a bit clunky and consists in dynamically overriding the `*db*` variable when running the tests. However, I lose the convenience of CIDER shortcuts. The first step is to define a dynamic variable that references the test DB:

```clj
;; Assumes an application generated with the Luminus template
(defstate ^:dynamic *test-db*
  :start (let [url (:database-url (load-file "test-config.edn"))]
           (conman/connect! {:jdbc-url url}))
  :stop (conman/disconnect! *test-db*))
```

Second, switch to the test namespace and run the tests:

```clj
(with-redefs [*db* some-ns/*test-db*] (run-tests))
```

Even better for this case is to use `binding`:

```clj
(binding [*db* some-ns/*test-db*] (run-tests))
```

That was fun, but there's something more effective that solves the above issues: _hardcode the test db_. This is still not ideal because we will be using a mixture of test env and dev env. Here's how I'm setting up my tests:

```clj
(def ^:dynamic *db*)
(def db-url (:database-url (load-file "test-config.edn")))

(defn connect-to-db []
  (conman/connect! {:jdbc-url db-url}))

(defn disconnect-db [db]
  (conman/disconnect! db))

(use-fixtures
  :once
  (fn [f]
    (binding [*db* (connect-to-db)]
      (migrations/migrate ["migrate"] db-url)
      (f)
      (disconnect-db *db*))))
```

Still looking for a better solution, but for now I'm sticking with the latter.

## 2018-09-01 - hugsql

https://stackoverflow.com/questions/40420408/handling-nil-parameters-with-clojure-hugsql

## 2018-09-01 - gen-class

I want to play with `javafx`, so I need to know how `gen-class` works. The following docs have proven to be useful for `gen-class`:

[Ahead-of-time Compilation and Class Generation](https://clojure.org/reference/compilation)

It explains how compilation works on Clojure, and it has a simple and an advanced example of `gen-class`. I tried to run the following example from scratch:

```clj
(ns clojure.examples.hello
  (:gen-class))

(defn -main
  [greetee]
  (println (str "Hello " greetee "!")))
```

Here's what I found out:

- Create a new project directory.
- Save the code in `clojure/examples/hello.clj`
- Run `clj` and then `(compile 'clojure.examples.hello)`.
-  The compilation fails with a mysteryous `IOError`. After googling, a solution: create a `classes` directory. Can be tuned with `*compile-path*` Clojure variable.
- Try to `(compile 'clojure.examples.hello)` again. Notice the newly introduced `.class` files in `classes/clojure/examples`.
- Now use `java` to run the class. `java -cp ./classes clojure.examples.hello fooinput` fails with: `java.lang.NoClassDefFoundError: clojure/lang/Var`.
- We clearly need to include `clojure.jar` in the classpath.
- The `clj` CLI tool already has it, right? It has the class path already configured.
- Googled, and found out we can query the class path with: `(filter #(= (key %) "java.class.path") (System/getProperties))`.
- First, I tried to include _only_ `clojure.jar` in the classpath, and it complained that `spec` is missing. I googled and found out that spec is now a dependency for Clojure 1.9.
- Now grab the **whole** class path and run the glorious command: `java -cp ./classes:/Users/thiagoaraujo/.m2/repository/org/clojure/clojure/1.9.0/clojure-1.9.0.jar:/Users/thiagoaraujo/.m2/repository/org/clojure/spec.alpha/0.1.143/spec.alpha-0.1.143.jar:/Users/thiagoaraujo/.m2/repository/org/clojure/core.specs.alpha/0.1.24/core.specs.alpha-0.1.24.jar clojure.examples.hello fooinput`

The command above works for _running_. For compile, as an alternative to the Clojure repl, you can use java to run the Clojure compiler:

```sh
java -cp ./src:/Users/thiagoaraujo/.m2/repository/org/clojure/clojure/1.9.0/clojure-1.9.0.jar:/Users/thiagoaraujo/.m2/repository/org/clojure/spec.alpha/0.1.143/spec.alpha-0.1.143.jar:/Users/thiagoaraujo/.m2/repository/org/clojure/core.specs.alpha/0.1.24/core.specs.alpha-0.1.24.jar -Dclojure.compile.path=classes clojure.lang.Compile clojure.examples.hello
```

I was not able to run the second (more complex) example. The `-main` function references classes generated by `gen-class` in the same Clojure namespace, but I get a `java.lang.ClassNotFoundException` when the compiler hits the `-main` function. If I remove the references, the class compiles though. Not sure how to solve this yet.

### Using leiningen

With leiningen, things seem to work as expected. Just make sure to declare your module in an `:aot` vector within `project.clj`. You can either declare `:aot :all` or `:aot [ns1 ns2 ...]`.

When using CIDER and recompiling the file, sometimes changes are not picked up by the REPL. So I do:

```sh
lein clean
lein compile
```

```elisp
M-x cider-quit
M-x cider-jack-in (in a proj buffer)
```

Not sure if there's a better way.
