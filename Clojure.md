# Clojure

## Interesting links

- [On Clojure Equality](https://github.com/jafingerhut/thalia/blob/master/doc/other-topics/equality.md)
- [Cambium - Nice Clojure blog](https://cambium.consulting/articles/)
- [Clojure workflow](https://clojureverse.org/t/share-the-nitty-gritty-details-of-your-clojure-workflow/1208)
- [Isolating external deps](http://blog.josephwilk.net/clojure/isolating-external-dependencies-in-clojure.html)
- [Leiningen Docs](https://github.com/technomancy/leiningen/tree/master/doc)
- [Gen class](https://kotka.de/blog/2010/02/gen-class_how_it_works_and_how_to_use_it.html)
- [Clojure compilation](https://blog.ndk.io/clojure-compilation2.html)
- [clojure.core Cheatsheet](https://world-in-atom.com/posts/2016-05-26-clojure-cheat-sheet/)
- [Clojure cheatsheet](http://jafingerhut.github.io/cheatsheet/clojuredocs/cheatsheet-tiptip-cdocs-summary.html)
- [20 cool Clojure functions](https://blog.djy.io/20-cool-clojure-functions/)

## Packages to check out

- clj-http

## Web Development

### Ring

Ring has 3 basic concepts:

- Adapters: make existing JVM webservers (like jetty) compatible
  with the Ring specification. They take an HTTP request, convert it into a
  standard ring request, and pass it to a handler.
- Handlers: receive a ring request and return a ring response. The adapter converts the ring response into
  an HTTP response.
- Middleware: take a handler and return *another* handler. The signature is `[hdlr & options]`.

#### Tips

Connect to a running server in Leiningen with:

```sh
lein repl :connect 7000
```

Avoid jetty blocking the main thread (and thus the repl) with:

```clj
(require '[ring.adapter.jetty :refer [run-jetty]])

(defn handler [req]
  {:status 200
   :headers {}
   :body "Some body"})

;; This line already runs the server.
;; defonce ensures jetty is only run once
(defonce server
  (run-jetty handler {:port 3000, :join? false}))

;; This line stops the server using the server reference
(.stop server)
```

Make the handler's code automatically reloadable by passing in a var reference instead of the function value:

```clj
(run-jetty #'handler {:port 3000, :join? false})
```

Since vars implement `IFn`, they behave as functions.

### Compojure

Compojure is useful for:

- Routing.
- HTTP method switching.
- Making Ring responses easier to generate.

### Databases

Use JDBC, a Java package. There's a clojure wrapper called `clojure.java.jdbc`.

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

The key to Clojure's immutable data structures is "persistent".

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

You can press `C-c M-n` in Emacs to switch namespaces, and `C-c C-k` to compile
the file. And in the repl:

```clj
;; *ns* refers to the current namespace
(test-ns *ns*)
```

Or you can `C-c C-t n`.

What if you delete a test? The test will still be in memory, therefore you must
unload the namespace to get rid of the ghost:

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

### Switch to namespace

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

## Testing

You can have different contexts within a single test:

```clj
(ns my-app.core-test
  (:require [clojure.test :refer :all]))

(deftest test-suite-name
  (testing "Set 1"
    (is (= 1 1)))
  (testing "Set 2"
    (is (= 2 1))))
```

`deftest` generates a function under the curtains:

```clj
(require '[my-app.core-test :as ct])

;; Throws exception on failure / returns nil on success
(ct/test-suite-name)
```

To run tests for a namespace:

```clj
(run-tests 'my-app.core-test)
```

You can run parameterized tests with `are`:

```clj

(deftest test-add
  (are [x y] (= x y)
    (+) 0
    (+ 1) 1
    (+ 1 2) 3))
```

### Property-Based testing

First, Install the `core.clojure/test.check` package. Then import the `generators` namespace:

```clj
(require '[clojure.test.check.generators :as gen])

(gen/sample gen/pos-int 20) ;; Generates 20 random positive integers
(gen/sample gen/string-alphanumeric) ;; Generates 10 random alnum strings
```

Other generators:

- `gen/boolean`
- `gen/int`
- `gen/keyword`
- etc.

You can plug in predicates to create custom generators:

```clj
(def numbers-greater-than-zero
  (gen/such-that (complement zero?) gen/pos-int))

(gen/sample  numbers-greater-than-zero) ;; Generates 10 numbers
```

You can even generate maps:

```clj
(def numbers-greater-than-zero
  (gen/such-that (complement zero?) gen/pos-int))

(def non-empty-string-gen
  (gen/such-that not-empty gen/string-alphanumeric))

(def books-map-gen
  (gen/hash-map
   :title non-empty-string-gen
   :author non-empty-string-gen
   :copies numbers-greater-than-zero))

(gen/sample books-map-gen)
```

Or vectors with a random number of non-empty maps:

```clj
(def inventory-gen
  (gen/not-empty (gen-vector books-map-gen)))
```

Pick a random book from each vector:

```clj
;; gen/elements picks a random item
(def inventory-each-with-a-random-book-gen
  (gen/let [inventory inventory-gen
            book (gen/elements inventory)]
    { :inventory inventory, :book book }))

(gen/sample inventory-each-with-a-random-book)
```

With that, you can test a function that finds a book by title:

```clj
(ns inventory.other-test
  (:require [clojure.test :refer :all]
            [clojure.test.check.properties :as prop]
            [clojure.test.check.clojure-test :as ctest]
            [clojure.test.check.generators :as gen]))

(def numbers-greater-than-zero-gen
  (gen/such-that (complement zero?) gen/pos-int))

(def non-empty-string-gen
  (gen/such-that not-empty gen/string-alphanumeric))

(def books-map-gen
  (gen/hash-map
   :title non-empty-string-gen
   :author non-empty-string-gen
   :copies numbers-greater-than-zero-gen))

(def inventory-gen
  (gen/not-empty (gen/vector books-map-gen)))

(def inventory-each-with-a-random-book-gen
  (gen/let [inventory inventory-gen
            book (gen/elements inventory)]
    { :inventory inventory, :book book }))

(defn find-by-title
  "Given a books hash-map vector, finds a book by title"
  [title books]
  (some
   #(when (= (:title %) title) %)
   books))

(defn find-by-title-in-sample-data
  [sample]
  (find-by-title (-> sample :book :title) (:inventory sample)))

;; Generates 50 samples to test against
(ctest/defspec find-by-title-finds-books 50
  (prop/for-all [sample inventory-each-with-a-random-book-gen]
                (= (find-by-title-in-sample-data sample)
                   (:book sample))))
```

Or you can do a quick sanity check:

```clj
(require '[clojure.test.check :as tc])

;; Returns {:result true, :number-of-tests 50, :seed 23432423
;; Otherwise, returns a false result along with the failed tests)
(tc/quick-check
 50
 (prop/for-all [sample inventory-each-with-a-random-book-gen]
               (= (find-by-title-in-sample-data sample)
                  (:book sample))))
```

## Clojure spec

```clj
(ns playground.core
  (:require [clojure.spec.alpha :as s]
            [orchestra.spec.test :as st]))

(defn slice
  [m ks]
  (reduce (fn [acc k]
            (if-let [v (get m k)]
              (assoc acc k v)
              acc))
          {}
          ks))

(s/fdef slice
        :args (s/cat :m map?
                     :ks (s/coll-of any?))
        :fn (fn [ctx]
              (= (into #{} (-> ctx :args :ks))
                 (into #{} (-> ctx :ret keys))))
        :ret map?)

(st/instrument `slice)

(slice {:a false :b 1} [:a])
```

The last line will reveal a bug in the function:

```
ExceptionInfo Call to #'playground.core/slice did not conform to spec:
val: {:ret {}, :args {:m {:a false}, :ks [:a]}} fails at: [:fn] predicate: (fn [ctx] (= (into #{} (-> ctx :args :ks)) (into #{} (-> ctx :ret keys))))
  clojure.core/ex-info (core.clj:4739)
```

It will not extract the value for `:a` because `false` is not truthy. Replace `if-let` with `if-some` to fix it.

`clojure.spec` instrumentation only validates incoming `:args`. To validate `:fn` and `:ret`, use `orchestra`.

A better spec for the `slice` function would be:

```clj
(defn slice [m ks]
  (reduce (fn [acc k]
            (if-some [v (get m k)]
              (assoc acc k v)
              acc))
          {}
          ks))

(defn slice-ret-keys-validator [ctx]
  (let [intersect
        (se/intersection
         (-> ctx :args :ks set)
         (-> ctx :args :m keys set))]
    (= intersect (-> ctx :ret keys set))))

(s/fdef slice
        :args (s/cat :m map?
                     :ks (s/coll-of any?))
        :fn slice-ret-keys-validator
        :ret map?)
```

It accounts for the case when the map does not have the input keys.

And given that we have a specification, we can run a property-based test for it automatically:

```clj
(st/check 'playground.core/slice)
```

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

;; reload-all forces reload of transitive dependencies
(require :reload-all 'clojure.data)

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

To check for the presence of an element in a Vector use `some`.

```clj
;; With a set function
;;
;; Runs through each element: (#{2} 1), then (#{2} 2)... Found!
;; Remember: sets implement the Runnable interface.
(some #{2} [1 2 3 4]) ;; 2
(some #{5} [1 2 3 4]) ;; nil

;; With a function
;;
;; Note: some returns the first non-nil value returned by the higher order function:
(some #(= % 2) [1 2 3 4]) ;; true
(some #(= % 5) [1 2 3 4]) ;; false
```

Extracting arbitrary items from a map with `map`:

```clj
(map {:one 1 :two 2 :three 3} [:one :three]) ;; (1 3)
```

Or from a vector:

```clj
(map [1 2 3] [0 1]) ;; (1 2)
```

As a Rubyist, it often confuses me that one can `map` like this:

```clj
(map + [0 1] [1 0]) ;; (1 1)
```

`keep` is map + filter:

```clj
(let [matrix [[0 1 nil 3] [4 nil 5 6]]]
  (keep #(get-in matrix %) [[0 0] [0 2] [1 2]])) ; (0 5)
```

### Metadata

```clj
(defn ^:private ^:dynamic sum [& args] (apply + args))
```

Same as any of these:

```clj
(defn ^{:private true :dynamic true} sum [& args] (apply + args))
(defn sum {:private true :dynamic true} [& args] (apply + args))
(defn sum ([& args] (apply + args)) ^:private})
```

You can store any arbitrary metadata:

```clj
(defn join
  {:test #(assert (= (join "," [1 2 3]) "1,2,3"))}
  [sep s]
  (apply str (interpose sep s))
```

Retrieve the metadata with:

```clj
(:test (meta #'join)) ;; #object[user$fn__372 0x3ec2ecea "user$fn__372@3ec2ecea"]
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

Partial is more of a curry:

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

### conj and into

Implementing `into` with `conj`:

```clj
(defn my-into [left right]
  (apply conj left right))

(my-into {:a "b"} {:c "d"} {:e "f"}) ;; {:a "b", :c "d", :e "f"}
```

Implementing `conj` with `into`:

```clj
(defn my-conj [first & rest]
  (into first rest))

(my-conj {:a "b"} {:c "d"} {:e "f"}) ;; {:a "b", :c "d", :e "f"}
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

(#(* % 2) 2) ; 4

;; And we can also use the "rest" syntax
(#(- (apply + %&) %) 1 2 3 4 5) ; 13
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

Implement the `fnil` function with the `with-defaults` name:

```clj
;; v1
(defn with-defaults [f & defaults]
  (let [merge-vec (partial map #(or %1 %2))
        filler (replicate (count defaults) nil)]
    (fn [& args]
      (let [args (merge-vec args filler)
            args (merge-vec args defaults filler)]
        (apply f args)))))

;; v2
(defn with-defaults [f & defaults]
  (let [filler (replicate (count defaults) nil)]
    (fn [& args]
      (let [args (map #(or %1 %2 %3) args defaults filler)]
        (apply f args)))))

;; v3 - lazy is great! did not know concat returned a lazy sequence
(defn with-defaults [f & defaults]
  (fn [& args]
    (let [args
          (map #(or %1 %2) args (concat defaults (repeat nil)))]
      (apply f args))))

;; Using:

(defn favs [age food]
  (format "I'm %d years old and my favorite food is %s." age food))

(def favs-with-defaults (with-defaults favs 28 "waffles"))

;; "I'm 64 years old and my favorite food is waffles."
(favs-with-defaults 64 nil)

(def favs-with-defaults (with-defaults favs nil "waffles"))

;; "I'm 64 years old and my favorite food is waffles."
(favs-with-defaults 64 nil)

"I'm 28 years old and my favorite food is cookies."
((with-defaults favs 28) nil "cookies")
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

## Collections

`for` and `doseq` and cousins, but the former returns a mapped vector. The latter is for side-effects.

## Printing to stdout

- `pr` prints objects to `*out*` in a way that they can be read by the reader.
- `prn` is the same as `pr` but with a newline.
- `prn-str` prints to a string intead of `*out*`.

## Filesystem

Example of listing the contents of a directory in Clojure: `(-> (clojure.java.io/file ".") .list sort)`.

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

It's also possible to define multimethods with symbol inheritance behavior.

```clj
(defmulti os-name ::os)
(defmethod os-name ::unix [m] (:name1 m))

;; Error: no method in multimethod 'os-name' for dispatch value: :my-ns/mac-os
(os-name {::os ::mac-os, :name1 "MacOS", :name2 "Darwin"})

;; Let's make mac-os inherit from Unix
(derive ::mac-os ::unix)

(os-name {::os ::mac-os, :name1 "MacOS", :name2 "Darwin"}) ;; "MacOS"

;; Now defining a specific implementation for mac-os,
;; so that it doesn't inherit from Unix
(defmethod os-name ::mac-os [m] (str (:name1 m) " " (:name2 m)))

(os-name {::os ::mac-os, :name1 "MacOS", :name2 "Darwin"}) ;; "MacOS Darwin"
```

You can make a few interesting queries:

```clj
(parents ::mac-os) ;; #{:my-ns/unix}
(ancestors ::mac-os) ;; #{:my-ns/unix}
(derive ::mac-os ::next)
(ancestors ::mac-os) ;; #{:my-ns/unix :my-ns/next}
(descendants ::unix) ;;#{:joy.udp/mac-os}
(isa? ::next ::unix) ;; false
(isa? ::mac-os ::unix) ;; true
(isa? ::mac-os ::next) ;; true (not so true actually...)
```

You can also avoid polluting the global namespace with symbol
hierarchy information by passing the hierarchy information directly to
`defmulti`:

```clj
(def os-hierarchy
  (-> (make-hierarchy)
      (derive ::mac-os ::unix)))

(defmulti os-release :os :hierarchy #'os-hierarchy)
(defmethod os-release ::unix [m] (:release m))

(os-release {:os ::mac-os, :release "10.4"}) ;; 10.4

(isa? ::mac-os ::unix) ;; false
(isa? os-hierarchy ::mac-os ::unix) ;; true
```

### Records and Protocols

Given the following record definition:

```clj
(defrecord Person [name age])
```

It generates two new functions:

```clj
(def thiago (->Person "Thiago" 25))
(def robert (map->Person {:name "Robert", :age 75}))
```

You can have *other* fields in a record instance. But they will not have optimized access:

```clj
(def wtf (map->Person {:name "WTF", :age 10, :wtf "included!"}))
(:wtf wtf) ; "included!"
```

A record works like a map:

```clj
(def older-robert (assoc robert :age 76))
(def wtf-bro (assoc wtf :yes "It's true"))

(count wtf) ;; 3
(keys wtf) ;; (:name :age :wtf)
```

A record has a class:


```clj
(class wtf) ;; my-ns.Person
(instance? Person wtf) ;; true
```

Given the following protocol:

```clj
(defprotocol Being
  (identification [this])
  (description [this])
  (greeting [this message]))
```

We can define a record-specific implementation for it:

```clj
(defrecord Animal [name type age wild? sound]
  Being
  (identification [this]
    ;; Woops! We can call `name` instead of `(:name this)`
    (str name " is a " type))
  (description [this]
    (if (:wild? this)
      "Is a wild animal"
      "Is not a wild animal"))
  (greeting [this message]
    (str type " says " message)))

(defrecord Person [name age good-boy?]
  Being
  (identification [this]
    (str name " has " (:age this) " years"))
  (description [this]
    (if (:good-boy? this)
      "Is a good boy"
      "Is not a good boy"))
  (greeting [this message]
    (str name " says " message)))
```

> P.S.: We can define more than one protocol per record definition at once (syntax omitted for brevity).

To use the protocol functions:

```clj
(def thiago (->Person "Thiago" 18 true))
(def cow (->Animal "Milky", "Cow", 5, false, "Moo!"))

(identification thiago) ;; Thiago has 18 years
(description thiago) ;; Is a good boy
(greeting cow "Moo!") ;; Cow says Moo!
```

You can extend a record with another Protocol without having to alter the original definition:

```clj
;; Nonsense example
(defprotocol Ageable
  (next-age [this]))

(extend-protocol Ageable
  Person
  (next-age [this] (+ (:age this) 1))
  Animal
  (next-age [this] (+ (:age this) 5)))

(next-age thiago) ; 19
(next-age cow) ; 10
```

Protocols can be used for any types, even built-in types:

```clj
(defprotocol ToUrl (to-url [x]))

(extend-protocol ToUrl
  java.io.File
  (to-url [f] (.toString f)))
```

You can have one-off implementations of protocols (useful for testing):

```clj
;; Note: reify does not require implementing the whole protocol
(def one-off-impl (reify Ageable (next-age [this] 25)))
(next-age one-off-impl)
```

You can also use `extend-type` instead of `extend-protocol`. It's the
same thing, but the type comes as the first argument:

```clj
(extend-type java.io.File
  ToUrl
  (to-url [f] (.toString f)))
```

`deftype` is the more generic version of `defrecord`. `deftype` is for
programming constructs, and `defrecord` for domain
constructs. `defrecord` implements record-specific methods, while
`deftype` defines just the functionality implemented by the user. For
example:

```clj
(deftype APerson [name age])

(:name (->APerson "Thiago" 18)) ;; nil... with a record this would return the name.
(map->APerson {:name "Thiago" :age 18}) ;; Unable to resolve symbol: map->APerson in this context
```

We can explicitly define methods on the type:


```clj
(defprotocol Nameable
  (who [this]))

(deftype APerson [name age]
  Nameable
  (who [this] (.-name this)))

(who (->APerson "Thiago" 18)) ;; Thiago
```

We could also have accessed the field directly, since it is public.

Field access can actually be simplified. No need to go through `this`:

```clj
(defprotocol Nameable
  (who [this]))

(deftype APerson [name age]
  Nameable
  (who [_] name))

(who (->APerson "Thiago" 18)) ;; Thiago
```

We can also make fields mutable:

```clj
(defprotocol MutableNameable
  (set-name [this name])
  (get-name [this]))

(deftype APerson [^:volatile-mutable name age]
  MutableNameable
  (set-name [this name] (set! (.-name this) name))
  (get-name [this] (.-name this)))

(def p (->APerson "Thiago" 18))

(set-name p "Ogaiht")
(get-name p) ;; "Ogaiht"

(.-age p) ;; 18
(.-name p) ;; No matching field found: name for class user.APerson
```

Mutable fields become private and require a special type hint. Note
that we are using the `set!` special form the mutate the `name` field.

Or implement equality through a Java interface:

```clj
(deftype A [x y]
  java.lang.Comparable
  (equals [left right]
    (and (= (type left) (type right))
         (= (.-x left) (.-x right))
         (= (.-y left) (.-y right)))))

(= (->A 1 2) (->A 1 2)) ;; true
(= (->A 1 2) (->A 3 4)) ;; false
```

Misc:

- You can think of records as hashmaps but with their own class. Which
  means they have equality and hash semantics, and you can use
  `assoc`, `get`, `count`, etc. Ref:
  https://lispcast.com/deftype-vs-defrecord
- If you don't need polymorphism, don't use records and stick with a
  hashmap.
- Protocols and multimethods are much the same, but multimethods are
  more generic: they apply to anything and allow defining a custom
  dispatch function.
- Be careful with function name collisions!
- Types are Java classes and can also be instantiate with the `.` Java
  syntax: `(APerson. "Thiago" 18)`

## Error handling

### Pre and post conditions

```clj
;; % stands for the function's return value.
(defn book-title [book]
  {:pre [(:title book)]
   :post [(not (= "None" %))]}

  (:title book))
```

You can use pre and post conditions with higher-order functions for
more flexibility:

```clj
(defn self-help-book-title! [book f]
  {:pre [(= (:genre book) "Self-help")]}
  (f book))

(self-help-book-title! {:genre "Self-help"
                        :title "The Power of Now"}
                       title)
```

### Exceptions

```clj
(defn foo [] (throw (ex-info "ok" {})))

;; can pass more catches
(try (foo) (catch RuntimeException e (println "foo")))

;; Generates an exception of type RuntimeException
(ex-info "An exception" {:type java.lang.RuntimeException})

;; java style
(throw (IllegalArgumentException. "needs an even number of forms"))
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

A cool example: building a lazy and infinite sequence. Example, even numbers:

```clj
(defn even-numbers
  ([] (even-numbers 0))
  ([n] (cons n (lazy-seq (even-numbers (+ n 2))))))
```

- Lazy sequences are chunked: Clojure preemptivively realizes N
  elements of the sequence. That's bad for side-effects.
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

```clj
(subvec v 1) ; [2 3 4]
(subvec v 1 2) ; [2]
```

We can use `some` to check if a value is present in a vector:

```clj
(some #{Ringo} ["John" "Paul" "George" "Ringo"]) ;; "Ringo"
```

Be careful when checking for false or nil values! `some` relies on truthiness, so you must be explicit:

```clj
(some #(= nil %) [1 nil]) ;; true
```

You may think that `contains?` would work for checking membership, but it does not. It merely checks if the index exists in the vector, which is more useful with a map:

```clj
(contains? [1] 0) ;; true
```

`contains?` works on associative collections like vectors and maps:

```clj
(associative? []) ;; true
(associative? {}) ;; true
(associative? #{}) ;; false
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

Among others, this section is a reminder of Clojure [concurrency primitives](https://purelyfunctional.tv/guide/clojure-concurrency/).

### Threads

Example of instantiating and joining threads:

```clj
(map
  #(do (.start %1) (.join %1))
  [(Thread. #(do (Thread/sleep 5000) (println "After 5 seconds...")))
   (Thread. #(do (Thread/sleep 4000) (println "After 4 seconds...")))])
```

Note: You can't `(.start (.join thread))` because the return values are `nil`.

"Bare" threads are low-level and should be avoided. Favor abstractions
such as futures and thread pools.

```clj
(import java.util.concurrent.Executors)

(def fixed-pool (Executors/newFixedThreadPool 3))

(.execute fixed-pool heavy-work-1)
(.execute fixed-pool heavy-work-2)
```

Note: the JVM will refuse to stop if there are any threads still
running. Ensure your threads are dead and cleaned up before your
program terminates. Another option is to run the threads as daemons:

```clj
(def t (Thread. #(Thread/sleep 5000)))
(.setDaemon t true)
(.start t)
```

Be aware that daemon threads will be killed without warning when the
program terminates.

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

A call to a deref'ed promise will block until there is a value.

### Futures

> Please calculate this in another thread
> Or... A promise that brings along its own thread

Prefer futures to promises when possible.

```clj
(def pizza (future (do (Thread/sleep 5000) "Pizza is ready!")))

(println (str "Good news: " @pizza))
```

`pmap` will execute a parallel mapping based on futures. A foolish
example:

```clj
(defn expensive-work [value] (println (str "Took me ages to compute " value)))
(pmap expensive-work [1 2 3 4])
```

Of course, `pmap` is slower than `map` unless doing intense computing.

Here's a basic implementation of `pmap`:

```clj
(defn my-pmap [func coll]
  (let [futures (doall (map #(future (func %1)) coll))]
    (map deref futures)))
```

### Deref

With timeout:

```clj
(def value (promise))
(deref value 2000 :timed-out)
```

It's a best practice to always supply a timeout and a default value.

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

- Never use side-effectful code within a `swap!` because atoms make
  use of transactions!
- `swap!` is synchronous. When it returns, it means the atom has been
  updated (remember GenServer `call` VS `cast`).

Let's reimplement `clojure.core/memoize` and see how we can use atoms
from within closures:

```clj
(defn fact
  ([x] (fact x 1))
  ([x, acc]
    (if (= x 1)
      acc
      (recur (dec x) (* acc x)))))

(defn my-memoize [f]
  (let [cache (atom {})]
    (fn [& args]
      (if-let [cached (find @cache args)]
        (val cached)
        (let [res (apply f args)]
          (swap! cache assoc args res)
          res)))))

(def memoized-fact fact)
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

`ref-set` will always overwrite the value. With `alter`, you can
change the value with a function:

```clj
(defn increase-temp-by [i]
  (dosync
    (let [v (alter c + i)]
      (ref-set f (c->f v)))))
```

Or use an anonymous function:

```clj
(defn increase-temp-by [i]
  (dosync
    (let [v (alter c #(+ % i))]
      (ref-set f (c->f v)))))
```

And you can use `commute` when the order of operations does not
matter. For two operations that increment a counter, if we switch both
the end result will be the same. We could rewrite the previous example
as:

```clj
(defn increase-temp-by [i]
  (dosync
    (let [v (commute c + i)]
      (ref-set f (c->f v)))))
```

Always avoid refs when you can, even if it implies in keeping a map
within an atom. Atoms are simpler to manage.

### Agents

Agents are useful for when the update function is side-effectful. The
update function will get called exactly once:

```clj
(def people (agent {}))

(defn notify-add-person [name]
  (println (str name " has been added")))

(defn add-person [name age]
  (let [person {:name name :age age}]
    (send
      people
      (fn [people-map]
        (assoc people-map name person)
        (notify-add-person name)))))
```

- Agent is async; it might return before executing the operation. You
  can also use it when the update function is slow.
- It sends the function to a queue created especially for the agent.

If a function call is falty, the agent will raise on the second call:

```clj
(send people + 1)
(send people assoc name {:name "Foo" age 20}) ;; cannot be cast to java.lang.Number
```

We can check the agent state with `agent-error` and restart it:

```clj
(agent-error people) ;; returns nil if no errors, or the error otherwise
(restart-agent people {} :clear-actions true)
```

And we can shutdown any agents with `(shutdown-agent)`

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

### Redefs

Good for mocking functions and other vars.

**Warning! Visible in all threads!**

```clj
(with-redefs [send-http-request (fn [] (println "Fake request being sent"))]
  (run-code))
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

## Recursive macros

```clj
(defmacro my-and
  ([] true)
  ([x] x)
  ([x & next]
   `(let [and# ~x]
      (if and# (my-and ~@next) and#))))
```

## Java interop

Instantiating and calling an object:

```clj
(def file (java.io.File. "README.md"))
(.exists file) ;; true
(. file exists) ;; true
```

Remember that "1" is an object, thus we can call methods on it:

```clj
; Calls compareTo java method on "1"
(.compareTo 1 2)
```

Something that Clojure generates, like an anonymous function, also has Java methods:

```clj
(. (fn [x y] (+ x y)) (applyTo '(1 2))) ;; 3
(. (fn [x y] (+ x y)) applyTo '(1 2)) ;; 3

(.count [1 2]) ;; 2

(def person "Thiago")
(.get #'person) ;; "Thiago"
```

You can look up the Clojure source and explore further.

To access a public field, use `-.` syntax:

```clj
(def rect (java.awt.Rectangle. 0 0 10 20))
(.-width rect) ;; 10
```

To import a class:

```clj
;; No quoting needed
(import java.io.File)

;; Importing along with ns declaration
(ns read-authors
  (:import java.io.File))

;; Many from java.io at once
(ns read-authors
  (:import java.io File InputStream))

;; Or even
(import '(java.io File InputStream))
(import [java.io File InputStream])

;; Now refer to the class without the fully qualified namespace
(​def​ authors (File. ​"authors.txt"​))
```

You don't need to import `java.lang`. Classes like `String` and `Boolean` are already available.

To call a static field:

```clj
File/separator
```

Or static method:

```clj
(File/separator) ;; "/"
```

Importing Java libraries is the same as importing Clojure
libraries. For example, `com.google.gson/json`; Clojure libraries
generally start with `org.clojure`.

Note that you can't use java interop methods as first class functions.

```clj
(map .exists [(File. "foo.txt")]) ;; Does not work
(map (memfn exists) [(File. "foo.txt")]) ;; Works with memfn!
```

Of course, do avoid using Java mutable objects.

You can also do a chained call with `..`:

```clj
(.. obj meth1 meth2)
```

Or

```clj
(.. obj (meth1) (meth2 arg1))
```

Or just use `doto`:

```clj
(doto "a" (println) (println)) ;; Prints "a" "a", returns "a"
```

Good to use with java interop where there are side-effects:

```clj
(doto stage
      (.setTitle "My JavaFX Application")
      (.setScene scene)
      (.show))
```
