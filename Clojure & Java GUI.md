- If weird things happen when you call a java variadic method with
  `into-array` (like not finding functions, classes, etc), it might be
  that you're not being specific enough. For example, `(VBox. 5.0
  (into-array Button (Button. "Foo")))`. This variadic constructor
  accepts instances of `Node`, therefore you must do: `(VBox. 5.0
  (into-array Node (Button. "Foo")))` - even though `Button` is a
  `Node` concretion.
