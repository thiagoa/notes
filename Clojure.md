# Clojure

## Emacs

- [Cider - Running tests](https://github.com/clojure-emacs/cider/blob/master/doc/running_tests.md)
- [Animated paredit](http://danmidwood.com/content/2014/11/21/animated-paredit.html)
- [Basic emacs + cider](https://www.braveclojure.com/basic-emacs/)
- [Paredit cheatsheet](https://www.emacswiki.org/emacs/PareditCheatsheet)

### General

| Command        | Description                      |
|----------------|----------------------------------|
| C-x C-k        | Kill region                      |
| C-c C-h        | Kill line                        |
| M-w            | Copy region                      |
| C-x Ret m      | Help                             |
| C-c Left/Right | Alternate between window layouts |

### Cider

| Command   | Description                       |
|-----------|-----------------------------------|
| C-c C-k   | Compile current file              |
| C-c C-z   | Alternate between repl and buffer |
| C-c M-j   | Cider jack in                     |
| C-c M-n   | Switch to current namespace       |
| C-l       | Center screen                     |
| q         | Quit cider-error                  |
| C-c C-t n | Run all NS tests                  |
| C-c C-t t | Run one test                      |

### Paredit

| Command | Description                                                   |
|---------|---------------------------------------------------------------|
| C-( (   | Wraps in parenthesis. (to-regex _str k) -> (to-regex (str k)) |
| M-s     | Splice current parenthesis                                    |
| C-S-0   | Slurps (expands) the next outer Sexp                          |
| C-S-9   | Slurps the prev outer Sexp                                    |
| C-S-]   | Barfs out (contracts) the next Sexp - Opposite of slurping    |
| C-S-[   | Barfs out the prev Sexp - Opposite of slurping                |

## Vim

| Command     | Description                      |
|-------------|----------------------------------|
| cpaF        | Evaluate nearest def             |
| :Console    | Console                          |
| opt + jk    | Move functions/lists up and down |
| c1m{motion} | Expands macros 1 time            |
| cm{motion}  | Expands macros                   |

## Workflow

### Installing packages

Add the package to `project.clj` and run:

```sh
lein deps
```


## Misc

In Clojure, keywords can be casted to functions. In the following example, the
`:a` keyword behaves like a function:

```clj
;; Returns 1
(:a {:a 1})
```

The interface for a function is `clojure.lang.IFn`. Some values can't be coerced to functions:

```clj
;; ClassCastException java.base/java.lang.String cannot be cast to clojure.lang.IFn
("exec" "this")
```

And data structures can also be casted to functions:

```clj
;; Returns 1
({:a 1} :a)
```

A vector is a `clojure.lang.PersistentVector`. A list is a `clojure.lang.PersistentList`:

```clj
(type []) ; clojure.lang.PersistentVector
(type '()) ; clojure.lang.PersistentList$EmptyList
(type '(1)) ; clojure.lang.PersistentList
(type '#{}) ; clojure.lang.PersistentHashSet
(type '(1)) ; clojure.lang.PersistentList
```

The key name to Clojure's immutable data structures is "persistent".

## General tips

### Weird characters

Check [this](https://yobriefca.se/blog/2014/05/19/the-weird-and-wonderful-characters-of-clojure) out.

### Testing tips

Given the following code:

```clj
(ns clojure-noob.run-tests
  (require [clojure.test :refer :all]))

(deftest testing-something
  (is (= 1 2)))
```

You can press `C-c M-n` in Emacs to switch namespaces, and `C-c C-k` to compile the file. And in the repl:

```clj
;; *ns* refers to the current namespace
(test-ns *ns*)
```

What if you remove a test from the file and no longer want to run it? The test
will still be in memory, so you must unload the testing namespace:

```clj
(remove-ns 'clojure-noob.run-tests)
```

Then recompile and run the tests again.

## REPL tips

### Require documentation

Grabbing the `doc` function:

```clj
(use 'clojure.repl)
(doc map)
```

### Switch namespace

```clj
(in-ns 'foo)
```

### Change the print length of collections
  
```clj
;; *print-length* is a dynamic var. Default value is 100.
(set! *print-length* 2)
[1 2 3] ;; Prints [1 2 ...] in the REPL
```

### Last commands

`*1`, `*2`, `*3`, `*e` for last exception

## Web Development

### Ring

Ring has 3 basic concepts:

- Adapters: They adapt existing JVM webserver libraries (like jetty) to be compatible
  with the Ring specification. They take an HTTP request, convert it into a standard ring request, and pass it
  to a handler.
- Handlers: They receive a ring request and return a ring response. The adapter converts the ring response into
  an HTTP response.
- Middleware: They take a handler and return *another* handler. The signature is `[hdlr & options]`.

### Compojure

Compojure is useful for:

- Routing.
- HTTP method switching.
- Making Ring responses easier to generate.

## Namespaces & Require

- Namespaces are just big name/value lookup tables.
- Two or more namespaces with the same prefix have no hierarchy relationship.
- By default, `require` will load a namespace only once (like in Ruby).

```clj
;; Requires the namespace to be used.
;; Now you can use "(clojure.data/diff ...)"
(require 'clojure.data)

;; Requires the namespace + forces a reload. It will read
;; and evaluate the source file again.
;;
;; - Does not clear out the contents of the namespace.
;; - Does not reload "defonce" bindings... unless you
;;   "ns-unmap" the binding before this command
(require :reload 'clojure.data)
 
;; Clears out a namespace binding
(ns-unmap 'my-ns 'leftover-binding)

;; Require with an alias.
;; Now you can call "(d/diff ...)"
(require 'clojure.data :as 'd)

;; Switch to "my-ns" and require "clojure.data" 
;; Now you can call "(clojure.data/diff ...)"
(ns my-ns
  (:require clojure.data))

;; Switch to "my-ns" and require "clojure.data" aliased to "data"
;; Now you can call "(data.diff ...)"
(ns my-ns
  (:require [clojure.data :as data]))

;; Switch to "my-ns" and require "clojure.data". Import the "diff"
;; binding into the current namespace.
;; Now you can call "(diff ...)"
(ns my-ns
  (:require [clojure.data :refer [diff]]))

;; Same as above, but pulls in all "clojure.data" symbols.
;; Dangerous!
(ns my-ns
  (:require [clojure.data :refer :all]))

;; Equivalent to "require" with ":refer :all"
(use 'my-ns)
  
;; Get the current namespace object
*ns*

;; Lists symbol table for a namespace
;; Returns everything visible to the namespace, including
;; what's in other namespaces
;;
;; "find-ns" returns a namespace object
(ns-map (find-ns 'clojure.data))

;; The code above can be abbreviated to...
(ns-map 'clojure.data)

;; Use "keys" to extract just the function names
(keys (ns-map 'clojure.data))

;; Extracts the namespace portion as a string.
;; Returns "clojure.data"
(namespace 'clojure.data/diff)

;; A keyword with a double colon is namespaced to prevent collisions
;; Returns :my-ns/author
::author

;; Clojure requires "clojure.core" automatically in all namespaces
“(require '[clojure.core :refer :all])”
```

## Functions

### Common functionality

Joining a vector into a delimited string:

```clj
(def coll [1 2 3 4 5])
(apply str (interpose ", " coll)) ; "1, 2, 3, 4, 5"
```

### Loops

Recur rebinds values declared at the beginning of a loop:

```clj
; Recur must be at the tail
(defn new-sequence-with-length-of-passed-list
  [lst]
  (loop [i 0, res []]
    (if
      (>= i (count lst))
      res
      (recur (+ i 1) (conj res i)))))
```


### Higher order functions

Partial:

```clj
(defn my-inc (partial + 1))
(my-inc 2 3) ; 6
```

Complement:

```clj
;; Negate the result of a function. Relies on truthiness.
(defn cheap? [price] (< price 5))
(cheap? 4) ; true
(def expensive? (complement cheap?))
(expensive? 5) ; true
```

Composing predicates:

```clj
;; AND predicate composition
(def person {:age 51, :qi 180})
(defn old? [person] (> (:age person) 50))
(defn smart? [person] (>= qi 180))
(def old-and-smart? (every-pred old? smart?))
(old-and-smart? person) ; true
```

Composing functions:

```clj
;; Functions are applied backwards
((comp inc #(* % %)) 2) ; 5
```

### Misc

All these functions accept any data structure and return sequences:

```clj
(interleave [:one :two] [1 2]) ; (:one 1 :two 2)
(interleave [:one :two :three] [1 2]) ; (:one 1 :two 2)

(interpose "and" [:one :two :three]) ; (:one "and" :two "and" :three)

(partition 2 [1 2 3 4]) ; ((1 2) (3 4))
(partition 2 [1 2 3 4 5]) ; ((1 2) (3 4))
(partition 2 [1 2 3 4 5 6]) ; ((1 2) (3 4) (5 6))

(sort (reverse [2 5 7 1])) ; [7 5 2 1]]

(filter neg? [-1 -2 3 4]) ; (-1 -2)

(some neg? [-1 2 -3]) ; true
(some neg? [2]) ; nil
```

### Recursion

```clj
; Eats up stack space
(defn sum-copies
  ([books] (sum-copies books 0))
  ([books total]
   (if (empty? books)
     total
     (sum-copies
      (rest books)
      (+ total (:copies-sold (first books)))))))

; Does not eat up stack space due to recur. recur needs to be called last
(defn sum-copies-good
  ([books] (sum-copies books 0))
  ([books total]
   (if (empty? books)
     total
     (recur
      (rest books)
      (+ total (:copies-sold (first books)))))))

; Avoids multiple arity and uses loop
(defn sum-copies-better [books]
  (loop [books books, total 0]
   (if (empty? books)
     total
     (recur
      (rest books)
      (+ total (:copies-sold (first books)))))))

; Does not use loop or recursion at all. Recursion is low-level
(defn sum-copies-best
  "This is a docstring"
  [books]
  (apply + (map :copies-sold books)))
```

### Defs

One thing to remember: `def` is evaluated at compile-time, which means `defn` is as well. To avoid evaluation at compile-time, use `delay` or do:

```clj
(def foo (when-not *compile-files* "bar"))
```

### Private defs

```clj
(defn- func [] 1)

; Must declare an unbound variable first to
; use it inside an interface implementation
(declare func-two)

; This record is nonsense just to illustrate the point
(defrecord Shit
  [poop]
  java.lang.Comparable
  (compareTo [one two] (compare (func-two) (func-two))))

(defn- func-two [] 2)
```

### Anonymous functions

```clj
;; An anonymous function "in full"
(map (fn [x] (* x x)) [2 3])

;; An anonymous function shortcut (same function as above).
;; We could have used just % without a number, since there
;; is a single parameter.
(map #(* %1 %1) [2 3])

(#(* % 2) 2) ;4
```

### Let

A few useful variations:

```clj
;; if-let is able to run one list, and can have an "else" list
(defn uppercase-author [book]
  (if-let [author (:author book)]
    (.toUpperCase author)))

;; when-let - is able to run more than one list, and no "else" list
(defn uppercase-author [book]
  (when-let [author (:author book)]
    (.toUpperCase author)))

```

### Apply

Apply is different from what I initially expected. Given this function:

```clj
(defn foo [x y z] (+ x y z))

(apply foo 1 [2 3]) ; Returns 6
```

I would expect `apply` to take in a single vector argument like in JavaScript, but it can take any number of positional arguments *before the vector*. It works as long as there is a vector toward the end.

```clj
(apply foo 1 [2 3]) ; Returns 6
(apply foo [1 2 3]) ; Returns 6

(apply foo 1 2 3) ; Does not work
```

### Exercises

Implement `map` over `reduce`:

```clj
(defn- my-map-reducer [f]
  (fn [coll x]
   (->> x
        (apply f)
        (conj coll))))

(defn my-map [f & colls]
  (let [zipped-colls (apply map vector colls)
        reducer (my-map-reducer f)]
   (reduce reducer [] zipped-colls)))
```

## Threading

```clj
;; Thread-first
(-> {1 2 3 4}
  (conj {5 6})
  (update 3 (fn [x] (+ x 5))) ; {1 2, 3 9, 5 6}

;; Thread-last
(->> :c
  {:a [2] :b [3]}
  (map (fn [x] (* x x)))) ; ()

;; Thread-last + stop the chain (short-circuits) as soon as it hits nil
(some->> :c
  {:a [2] :b [3]}
  (map (fn [x] (* x x)))) ; nil

;; Equivalent to some->> (only binds list and runs the block
;; when value is not nil):
(when-let [list (:c {:a [2], :b [3]})]
  (map (fn [x] (* x x)) list))

;; Executes all matching conditions in a loop by passing
;; the first argument to each one.
(defn describe-number [n]
  (cond-> []
    (odd? n) (conj "odd")
    (even? n) (conj "even")
    (zero? n) (conj "zero")
    (pos? n) (conj "positive")))
```

## Destructuring

Destructuring vectors:

```clj
; Also works on function signatures
(let [[a b] [1 2]] [a b]) ; [1 2]
```

Any `ISeq` will work with destructuring. There doesn't need to be a 1-1
correspondence:

```clj
(let [[a] [1 2]] a) ; 1
```

Map destructuring is tricky:

```clj
;; Keys and values need to be inverted!
(defn func [{foo :foo bar :bar}] [foo bar])
(func {:foo 1 :bar 2}) ; [1 2]

(defn func [{:foo foo bar :bar}] [foo bar]) ;; RuntimeException

;; Destructuring a nested map
(defn func [{{bar :bar} :foo}] [bar])
(func {:foo {:bar 1}}) ; 1

;; We can use the ":keys" syntax as a shortcut to destructure a map.
;; This is special clojure syntax that won't class with a possible
;; key of the same name (remember: keys and values need to be inverted)
(defn func [{:keys [:bar]}] bar)
(func {:bar 1}) ; 1

;; We can mix and match map destructure syntaxes
(defn character-desc [{:keys [name gender] age-in-years :age}]
  [name gender age-in-years])

(character-desc {:name "Thiago", :gender "M", :age 20}) ;; ["Thiago" "M" 20]

;; We can get the whole value with ":as"
(defn func [{{bar :bar} :foo :as m}]
  (println "bar is" bar "and the whole map is" m))

(defn func [[one two :as full-vector]] full-vector)

;; Given the following readers, how to get to ["Jane" "Austen"]? With
;; destructuring it would be an unreadable mess.
(def readers [
  {:name "Charlie", :fav-book {:title "Carrie", :author ["Stephen" "King"]}}
  {:name "Jennifer", :fav-book {:title "Emma", :author ["Jane" "Austen"]}}])

;; How about this?
(get-in st [1 :fav-book :author])

;; Or this
(let [[_ second-reader] readers]
  (get-in second-reader [:fav-book :author]))

;; What about default values? There you have it
(defn func-with-default-opts [arg1 & {:keys [arg2] :or {arg2 10}}]
  (println arg1 arg2))

(func-with-default-opts 20) ; Prints 20 10
(func-with-default-opts 20 :arg2 30) ; Prints 20 30
```

IMPORTANT: Destructuring does not work with `def`. Instead, you should use `def` + `let`
and bind `def` to an already destructured value.

You can mix and match `:as` with `:or`, etc.

## Polymorphism

### Multimethods

```clj
(defmulti pick-a-book :genre)

(defmethod pick-a-book :drama [book] (println "Drama" book))
(defmethod pick-a-book :horror [book] (println "Horror" book))

(pick-a-book {:name "Monsters and Aliens" :genre :horror})
;; Horror {:name Monsters and Aliens, :genre :horror}
```

We are using `:genre` as a dispatcher function, but any dispatcher function will do.

### Protocols

```clj
(defprotocol ToUrl (to-url [x]))

(extend-protocol ToUrl java.io.File (to-url [f] (.toString f)))
```

## Error handling

### Pre and post conditions

```clj
;; % stands as the function's return value.
(defn foo [book]
  {:pre [(:title book)]
   :post [(= "nada" %)]}

  (:title book))
```

### Exceptions

```clj
(defn foo [] (throw (ex-info "ok" {})))

;; can pass more catches
(try (foo) (catch RuntimeException e (println "foo")))

;; Generates an exception of type RuntimeException
(ex-info "An exception" {:type java.lang.RuntimeException})
```

## Types


### Hash maps

Commas are interpreted as white-space and help with readability:

```clj
{:um 1, :dois 2}
```

Insert values with `assoc`:

```clj
(assoc {:um 1} :dois 2) ; {:um 1, :dois 2}
```

Invert a hash map with `map` and `into`:

```clj
(def hm {:a 1, :b 2, :c 3, :n nil, 1 "one", 'sym "value"})

(->>
  (map (fn [[k v]] [v k]) hm)
  (into {}))
```

A sorted hash map is also possible:

```clj
(def sm (sorted-map :b 2, :a 1))
(assoc sm :c 3) ; {:a 1, :b 2, :c 3} ; {:a 1, :b 2, :c 3}
(type sm) ; clojure.lang.PersistentTreeMap
(type {}) ; clojure.lang.PersistentArrayMap
```

Update a value in a map with a function:

```clj
(def book {:copies 1000})
(update book :copies inc)

(def by-author
  {:name "Jane"
   :book {:title "Emma", :copies 1000}})

(update-in by-author [:book :copies] inc)
```

### Sets

```clj
(def my-set #{1 2 3})

(my-set 1) ; 1
(my-set 5) ; nil

(1 my-set) ; ClassCastException Long cannot be cast to IFn

(contains? my-set 1) ; true
(contains? my-set 5) ; false

(disj my-set 2) ; #{1 3}

(def my-set #{:some-keyword})

(:some-keyword my-set) ; :some-keyword
(my-set :some-keyword) ; :some-keyword

("str" my-set) ; ClassCastException String cannot be cast to IFn
```

### Keywords

- Use keywords as identifiers for values in data structures (say, a map).
- Keywords can also be casted to functions that extract values off most Clojure data structures.
- Keywords always refer to themselves.

```clj
:um
:dois
```

### Variables and symbols

Symbols are identifiers that represent the "left hand side" of a binding, and they also stand as first-class values. While keywords refer to themselves, symbols can refer to any value.

`Var` is a binding between a `Symbol` and a value, established by `def`.

```clj
(def a 1) ; #'my-ns/a
a ; This is a variable. Returns 1
'a ; This is the symbol, not the value. Returns a

(type 'a) ; clojure.lang.Symbol

;; Use #' when you want to refer to the var,
;; not to its value
(type #'my-ns/a) ; clojure.lang.Var

(.get #'my-ns/a) ; Returns 1
(.-sym #'my-ns/a) ; Returns a

; Resolve a symbol to a variable
(resolve 'a) ; #'my-ns/a

'a ; This is a symbol. Returns the symbol.
(type 'a) ; clojure.lang.Symbol
```

### Sequences

A [sequence](https://clojure.org/reference/sequences) is a logical linked list.

```clj
(def my-seq '(1 2))
(def my-seq (seq [1 2]))

(= '(1 2) (seq [1 2])) ;; true
```

Convert any data structure to a sequence:

```clj
(seq ["one" "two"]) ; Returns ("one" "two")
(seq {:one "one", :two "two"}) ; Returns ([:one "one"] [:two "two"])
```

Empty data structure arguments will return nil:

```clj
(seq []) ; Returns nil
(seq '()) ; Returns nil
(seq {}) ; Returns nil
```

Add stuff to a sequence:

```clj
(cons 1 '(2 3 4 5)) ; Returns '(1 2 3 4 5)
```

Extract head and tail off the sequence:

```clj
(def s (seq '(1 2 3)))
(first s) ; 1
(rest s) ; [2 3]

;; Works with any data structure.
;; Always converts to a sequence internally.
(first [1 2 3]) ; 1
(rest [1 2 3]) ; (2 3)
```

There's also `next`. It's the same as `rest` but returns `nil` when the sequence is empty:

```clj
(next '()) ; nil
(rest '()) ; ()
```

`cons` will *always* return a sequence and add to the head of the sequence (characteristic of the linked list data structure). If you pass in a vector, it will be converted to a sequence because vectors implement `ISeq`:

```clj
(cons 1 [2 3 4 5]) ; Returns '(1 2 3 4 5)
```

We can use the generic `conj` function (which works on other data structures) with the same effect:

```clj
(conj '(2 3 4 5) 1) ; Returns '(1 2 3 4 5)
```

### Lazy sequences

```clj
;; repeat is lazy
(first (repeat "value")) ;; "value"
(nth (repeat "value") 1000 ;; "value"

;; take is lazy; cycle and iterate are lazy.
(take 3 (repeat value)) ;; ("value" "value" "value")
(take 7 (cycle [1 2 3]) ;; (1 2 3 1 2 3 1)
(take 3 (iterate inc 1)) ;; (1 2 3)
(take 3 (iterate inc 2)) ;; (2 3 4)

; prints seq of 1 until 20; only 20 iterations!
(println (take 20 (take 1000000000 (iterate inc 1))))

;; map is lazy
(take 10 (map #(* % %) (iterate inc 1))) ; (1 4 9 16 25 36 49 64 81 100)

;; A lot of lazy computing combined!
(def first-names ["Bob" "Joe" "Mike"])
(def last-names ["Armstrong" "Bolanos" "Tyson"])
(defn name-for [first last] (str first " " last))
(def authors (map name-for (cycle first-names) (cycle last-names)))
(def titles (map #(str "Wheel of time, Book " %) (iterate inc 1)))
(defn make-book [title author] {:author author :title title})
(def books (map make-book titles authors))
(take 2 books)
;; ({:author "Bob Armstrong", :title "Wheel of time, Book 1"}
;;  {:author "Joe Bolanos", :title "Wheel of time, Book 2"})

(lazy-seq [1 2 3]) ;; Holds off evaluation

;; Building repeat, iterate, and map from scratch:
(defn my-repeat [x] (cons x (lazy-seq (my-repeat x))))
(defn my-iterate [f x] (cons x (lazy-seq (my-iterate f (f x)))))
(defn my-map [f col]
  (when-not (empty? col)
    (cons
	  (f (first col))
	  (lazy-seq (my-map f (rest col))))))

;; Seq and doall force evaluation of the lazy sequence. Useful for side-effects.
(seq (map slurp (map #(str "file" %) (range 1 10))))
(doall (map slurp (map #(str "file" %) (range 1 10))))

;; But why is this?
(class (doall (take 5 (repeat "5")))) ;; clojure.lang.LazySeq

(def foo (map println [1 2 3])) ;; does not consume the sequence
(def foo (doall (map println [1 2 3]))) ;; consumes the sequence and prints stuff

(take 4 (repeatedly (println "oi")))
(take 5 (repeatedly (fn [] 1)))
```

- `for` is similar to `doseq`, but `for` is lazy and `doseq` is eager.
- Not all lazy sequences are unbounded. They can be finite or infinite.
- Do not `count` nor `sort` nor `reduce` over a lazy sequence. These functions
  are eager.


### Vectors

Vectors are collections of values indexed by contiguous integers.

```clj
(def v [1 2 3 4])
(def v (vector 1 2 3 4))

;; Adds to the tail
(conj v 5) ; Returns [1 2 3 4 5]

(get v 0) ; 1
(get v 5) ; nil
(get v 5 :default-value) ; :default-value

(v 0) ; 1
(v 5) ; IndexOutOfBoundsException
(v 5 :default) ; ArityException

(0 v) ; ClassCastException Long cannot be cast to IFn

(nth v 0) ; 1
(nth v 5) ; IndexOutOfBoundsException
(nth v 5 :default) ; :default
```

We can convert the vector to a sequence, which we can then pattern match to obtain the head and the tail:

```clj
(seq v) ; '(1 2 3 4)
(let [[h & t] v] [h t]) ; Returns [1 (2 3 4)]
```

The vector gets implicitly converted to a sequence when we pattern against it. A sequence is the perfect data structure for this kind of pattern matching due to its linked list nature.

We can add or replace elements with `assoc`:

```clj
(assoc v, 2 10, 3 20) ; [1 2 10 20]
```

Or extract subvectors:

```
(subvec v 1) ; [2 3 4]
(subvec v 1 2) ; [2]
```

### Dates

`inst` stands for for "instant":

```clj
(def date #inst "1940-10-10")
```

### Regexes

`re-find` returns a string with the full match when a match is found:

```clj
(re-find #"[0-9]+", "12345") ; "12345"
```

When using groups, an array is returned. The first element is the full match, and the rest are matches for each group:

```clj
(re-find #"([0-9]{2})([0-9]{3})", "12345") ; ["12345" "12" "345"]
```

## Concurrency

This section is a reminder of Clojure [concurrency primitives](https://purelyfunctional.tv/guide/clojure-concurrency/).

### Delay

> I may not need to calculate this

[Delays](http://danlebrero.com/2017/06/12/delay-clojure-forgotten-concurrency-primitive/) are read-through caches that are computed once but can be accessed concurrently by many threads.

```clj
(def value-computed-only-once-then-cached
  (delay (println "side effect") {:a 1}))

(deref value-computed-only-once-then-cached)
;; Prints "side effect"
;; Returns {:a 1}

(deref value-computed-only-once-then-cached)
;; Does NOT print "side effect"
;; Returns {:a 1}
```

Threads block until the value is available:


```clj
;; Imagine many threads trying to access the same value
;; @ is a shortcut for deref
(.start
  (Thread.
    (fn [] (println @value-computed-only-once-then-cached))))
```

### Promises

> I'll check back here for the answer

```clj
(def some-value (promise))

(.start
  (Thread.
    (fn [] (Thread/sleep 2000) (deliver some-value "Pizza is ready!"))))

(println (str "Good news: " @some-value))
```

### Futures

> Please calculate this in another thread

```clj
(def pizza (future (do (Thread/sleep 5000) "Pizza is ready!")))

(println (str "Good news: " @pizza))
```

### Deref

With timeout:

```clj
(def value (promise))
(deref value 2000 :timed-out)
```

### Atoms

> Keeping a single value consistent over time

You should never use `reset!` with atoms. Use `swap!`.

```clj
(def counter (atom 0))

(add-watch counter :printer
  (fn [key atom old-value new-value]
    (when (zero? (mod new-value 100000))
     (println old-value new-value))))

(dotimes [n 2]
  (.start
    (Thread.
      (fn [] (dotimes [n 1000000] (swap! counter inc))))))

(Thread/sleep 2000)
@counter ; 2000000

(reset! counter 0) ; 0
(remove-watch counter :printer)
```

### Refs

> Keep multiple values in a consistent relationship

```clj
(def c (ref 0))
(def f (ref 0))

(defn c->f [val]
  (+ 32 (* val 1.8)))

(defn change-temp [val]
  (dosync
   (ref-set c val)
   (ref-set f (c->f val))))

(change-temp 40)
(println @c)
(println @f)
```

### Vars

```clj
;; "def" interns a var
(def a 1)

;; The value got overwritten
(def a 4)

;; defonce is "find or create"
(defonce b 2)

;; Useful to get a reference to the var
;; instead of the value, which enables
;; dynamic development
(var a) ; returns the var, not the value
#'a ; returns the var, not the value
```

### Dynamic vars

Each thread can have its own value of the same var:

```clj
;; Dynamic vars are surrounded by earmuffs
(def ^:dynamic *db*)

;; Get metadata about the variable. Output
;; hash map has {:dynamic true}
(meta #'*db*)
```

### Bindings

```clj
(def ^:dynamic *debug-on* false)
(defn do-debug []
  (if *debug-on*
    (println "True")
	(println "False")))
	
(do-debug) ; Prints false

;; Only works with dynamic var
(binding [*debug-on* true]
  (do-debug)) ; Prints true
```

## Macros

### Quote and unquote

See this [great link](https://8thlight.com/blog/colin-jones/2012/05/22/quoting-without-confusion.html#footnote_5).

Single quotes are a shortcut to the `quote` function:

```clj
(= 'a (quote a)) ; true
```

The `quote` function returns the symbols of a form without evaluating it. Backticks (syntax-quote) are also a shortcut to `quote`, but they expand symbol namespaces. And there's no longhand analog to quote for syntax-quote! Which means this does not exist: `(syntax-quote (a b))`. Only the backtick syntax exists.

A quoted list returns the symbols exactly as you enter them:

```clj
'(a b 1) ; Returns (a b 1)
```

A syntax-quoted (backtick) list will try to resolve the function's namespace, otherwise it will fallback to the current namespace:

```clj
`(a b 1 map) ; Returns (my-ns/a my-ns/b 1 clojure.core/map)
```

Inside a quoted list, quoted symbols and syntax-quoted symbols will expand respectively to:

- A `(quote symbol)` list
- A `(quote my-ns/symbol)` list

```clj
'('a `b) ; Returns ((quote a) (quote my-ns/b))
(= '('a `b) '((quote a) (quote my-ns/b))) ; true
```

Inside a syntax-quoted list, quoted symbols and syntax-quoted symbols will expand to the same thing: `(quote my-ns/sym)`:

```clj
`(a 'b' `c) ; Returns (my-ns/a (quote my-ns/b) (quote my-ns/c))
```

Inside a syntax-quoted list, `~` (unquote) will simply insert the symbol's value:

```clj
(def b 3)
`(a ~b c) ; Returns (my-ns/a 3 my-ns/b)
```

Which means the symbol gets evaluated. Anything you pass to `unquote` will be evaluated, even an expression that returns a symbol.

```clj
`(a ~(symbol (str "unquote-" "this"))) ; Returns (my-ns/a unquote-this)
```

Therefore you can use `unquote` on syntax-quoted lists. When you unquote on quoted lists, on the other hand, the backtick will simply expand to a list as always:

```clj
'(a ~b) ; Returns (a (clojure.core/unquote b))
```

With a syntax-quoted list, if we quote a symbol prior to unquoting it, the symbol's namespace does not get resolved. This can be understood as "quoting the symbol to avoid expansion then unquoting it". The resulting value is the symbol itself:

```clj
`(a ~'b) ; Returns (my-ns/a b)
```

Unsurprisingly, backtick + single quote yields:

```clj
`(a ~`b) ; (my-ns/a my-ns/b)
```

### General example

```clj
(defmacro when* [test & body] `(if ~test (do ~@body)))
```

```clj
(when* true (println "oi") (+ 5 6))
```

The body is received as a list of `'((println "oi") (+ 5 6))`. Let's see this macro call being expanded:

```clj
 (macroexpand '(when* true (println "oi") (+ 5 6)))
 ;; (if true (do (println "oi") (+ 5 6)))
```

`~` is the unquote operator. It must precede the whole expression.  
`@` is the splice operator (`Macro.unquote_splicing` in Elixir). It "unrolls" the list into the outer list.

Not useful, but we could evaluate just the first sublist:

```clj
(defmacro when* [test & body] `(if ~test (do ~(first body))))

(macroexpand '(when* true (println "oi") (+ 5 6)))
; (if true (do (println "oi")))
```

### Making symbols available to the macro body

```clj
(defmacro regex [re s & body]
  `(let [match# (re-find ~re ~s)]
     (when match#
       (let [[~'%0 ~'%1 ~'%2]
             (if (string? match#)
               [match#]
               match#)]
         ~@body))))
```

To use this macro:

```clj
(regex #"([a-z])([a-z])" "ab" (println %0 %1 %2)
;; Outputs ab a b
```

Explanations:

- `~'` is "unquote quote". It produces an unqualified symbol.
- Symbols are expanded to the fully qualified namespace within the macro. Example: `x` => `my-ns/x`. To get around that, we can generate symbol names with auto-gensyms by appending a pound to the var name: `x#`. This syntax unquotes a symbol with an auto-generated name and is only available within macros.

```clj
(defmacro foo []
  (let [x (gensym)]
    `(let [~x 5] ~@(repeat 3 `(println ~x)))))

(foo)
; 5
; 5
; 5
```

### Why use gensyms with let?

`let` bindings are scoped and do not leak, so why can't we just use `~'` instead of auto-gensyms? In fact, we can:

```clj
(defmacro regex [re s & body]
  `(let [~'match (re-find ~re ~s)]
     (when ~'match
       (let [[~'%0 ~'%1 ~'%2]
             (if (string? ~'match)
               [~'match]
               ~'match)]
         ~@body))))
```

The problem with this approach is that our macro body will be able to access the value of the `match` symbol:

```clj
(regex #"abc" "abc" (println %0) (println match))
;; Prints abc\nabc
```

Therefore our macro is not hygienic. Hadn't our macro received user-supplied code, we could have avoided auto-gensyms and sticked to `~'`.

With an auto-gensym, there is no such possibility. It makes our macro hygienic.

### Examples

This is a simplified implementation of the `for` macro that's similar to `map`:

```clj
(defmacro map-for [v & body]
  (let [bindings (vec (take-nth 2 v))
        values (take-nth 2 (rest v))]
    `(loop [iter# (apply map vector '~values) acc# '()]
      (if (seq iter#)
        (let [~bindings (first iter#)]
          (recur (rest iter#) (cons ~@body acc#)))
        (reverse acc#)))))

(map-for [x [1 2] y [3 4]] (+ x y)) ; (4 6)
```

### Expanding macros

- `(macroexpand '(macro-func))`: expands top-level macros until there are no top-level macros
- `(macroexpand-1 '(macro-func))`: expands top-level macro just one time
- `(clojure.walk/macroexpand-all '(macro-func))`: full expand


## Java interop

```clj
; Calls compareTo java method on "1"
(.compareTo 1 2)
```

Another way to call a method on an object:

```clj
(. (fn [x y] (+ x y)) (applyTo '(1 2)))
```
