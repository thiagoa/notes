# SQL

## Normalization

The normalization process is fundamentally based on the application of
atomicity to the world you are modeling. Keep in mind it is no silver
bullet: there are very good reasons to break normalization rules.

### 1NF: Atomiticy

This form consists in identifying the atomic attributes and primary
keys in a relation.

An atomic attribute is an attribute that, in a where clause, can
always be referred to in full. If you need to refer to parts of an
attribute inside a where clause, it lacks the level of atomicity you
need.

Example: A text column containing important characteristics that
should be broken up into different fields.

This rule affords:

- The ability to perform an efficient search: Full-text search is no
  workaround for the lack of atomiticy.
- Database-guaranteed data correctness: If an important characteristic
is buried inside a string column, it would require a complicated
function to parse and analyze the row when inserted or updated, should
we want to guarantee data correctness. Such a function would inflict a
performance penalty and possibly be a nightmare to maintain. An
example of good design would be to introduce an enum column with the
set of possible values or a boolean column to indicate the presence or
absence of the attribute.

How far should the decomposition be taken? Atomicity depends on
business requirements and whether you need some information to be
indexed or not. Example: Storing addresses should be uniquely designed
according to business requirements, no matter how company X solves the
problem. On the other hand, trying to be too precise may create
distracting and potentially irrelevant problems around edge cases.

#### Primary keys

- A primary key will often be compound.
- Can't be ambiguous.
- Must be able to identify the record at different points in time.
- Whenever possible, use a unique identifier that has meaning rather
  than some obscure sequential integer (not a very standard practice,
  but this note makes sense).

### 2NF: Dependence on the Whole key

- For a relation to be in the 2NF, it must be in 1NF.
- A relation shouldn't have attributes that depend on a subset of the
primary key.
- If the primary key is a single column, the relation is in 2NF.
However, most often the primary key will be auto-generated and the
real primary key will be implicit and hidden from view. Identifying
the latter is crucial before applying the 2NF.

Not following this rule implies:

- Data redundancy: Increases the odds of contradictory information and
storage waste.
- Bad query performance: The more bytes in the average row, the more
pages will be required to store the table and the longer it takes to
scan it. Expensive queries such as `SELECT DISTINCT` (which requires
sorting to eliminate duplicates) will be required to filter out the
data. Performance is better when the DBMS operates against a subset of
the data (e.g., a new table).

Example: `make, model, version, style, year, mileage` is the primary
key of the `cars` table. However, all cars sharing `make, model,
version, style` will have the same `seating` and `cargo_capacity`,
regardless of `year` or `mileage`. These four columns make up the "car
model". The current design requires a costly `SELECT DISTINCT` to
fetch car models from the main table. Is there a better solution?
Yes:

- Create a `car_models` table with `make, model, version, style` as
the primary key and `seating` and `cargo_capacity` as columns.
- Migrate `seating` and `cargo_capacity` from the main table and then
  remove these columns.
- Repeat the normalization process until the relation is in 2NF. For
  example, the engine and its characteristics will not depend on
  style.

### 3NF: Attribute Independence

3NF is reached when:

- 2NF is reached;
- We cannot infer the value of an attribute from any attribute other
than those in the primary key.
- "Given the value of attribute A, can the value of attribute B be determined?"
- "If I change the value of attribute A, will attribute B still make
  sense?"

Every pair of attributes in our 2NF data set should be examined in
turn to check whether one depends on the other.

The 3NF mitigates the risk of data corruption. Fields that depend on
each other require synchronization and programming traps such as
constraints, triggers, and stored procedures to avoid being corrupted
and inconsistent, whereas the 3NF simplifies this problem by design.
Even though it requires some query adjustments, it will be flexible
enough to accomodate changes.

Example: A `phone_numbers` table storing `country` and `dialing_code`.
For each repeated `country_code`, the `dialing_code` will be repeated
as well. Solution: Create a `country_info` table with `country_code`
as PK.

## Indexes

See [this link](https://gist.github.com/thiagoa/cfd5f6e95ee48e222e9f).
