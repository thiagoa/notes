# SQL

## Designing Databases for Performance

### Normalization

The normalization process is fundamentally based on the application of
atomicity to the world you are modeling. Keep in mind it is no silver
bullet: there are legitimate reasons to break normalization rules.

#### 1NF: Atomiticy

This form consists in identifying the atomic attributes and primary
keys in a relation.

An atomic attribute is an attribute that, in a where clause, can
always be referred to in full. If you need to refer to parts of an
attribute inside a where clause, it lacks the level of atomicity you
need.

**Example**: A text column containing important characteristics that
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
indexed or not.

**Example**: Storing addresses should be uniquely designed according
to business requirements, no matter how company X solves the problem.
On the other hand, trying to be too precise may create distracting and
potentially irrelevant problems around edge cases.

##### Primary keys

- A primary key will often be compound.
- Can't be ambiguous.
- Must be able to identify the record at different points in time.
- Whenever possible, use a unique identifier that has meaning rather
  than some obscure sequential integer (not a very standard practice,
  but this note makes sense).

#### 2NF: Dependence on the Whole key

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

**Example**: `make, model, version, style, year, mileage` is the primary
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

#### 3NF: Attribute Independence

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

**Example**: A `phone_numbers` table storing `country` and `dialing_code`.
For each repeated `country_code`, the `dialing_code` will be repeated
as well. Solution: Create a `country_info` table with `country_code`
as PK.

### Null columns

> All columns in a row should ultimately contain a value, even if
> business processes are such that various pieces of information are
> entered from more than one source and/or at different points in time.

What does NULL even mean? Its meaning is usually implicit and
ambiguous.

Possible signs of flawed DB design:

- Columns of prominent tables mostly contain NULL values: Minor
  inconvenience if the data is stored for informative purposes; bad if
  the unknown values are supposed to help defining a result set.
- Two columns can't contain a value at the same time; if one is
  defined, the other must be NULL (indicates violation of either 2NF
  or 3NF).

NULL columns imply _three-valued_ logic. In a where clause, conditions
can't be indeterminate; this is why some queries return unexpected
result sets when encountering NULL values.

- `where year in (1980, 1990, NULL)` doesn't return NULLs, but it
_might_ return 1980 and 1990.
- `where year not in (1980, 1990, NULL)` doesn't return anything. The
engine doesn't know what NULL is, so it will skip all other rows.

**Example**: 3 types of addresses are stored in the `customers` table:
official, billing, and shipping, therefore NULL values come into play.
What if we need the billing address in order to issue an invoice but
it's NULL? Some options:

- Use the official address: Not good because it requires implicit
  rules which tend to be duplicated if there is more than one
  application. The design should favor an explicit rule.
- Replicate information: Not good because it introduces overhead and
requires special processing during insert and update.

This is a scenario of semantic inconsistency. A possible solution is
to have an address table with `address_type` and `customer_id`, but
not necessarily it's the best solution. What if an order must ship to
many different branches? Does it imply a relationship with the order
itself? Should we introduce a `shipments` table? How to tag addresses
in this case?

Good usage of NULL values: queries with LEFT JOINS and filters on
NULL.

### Boolean columns

> Data for data’s sake is a path to disaster.

Boolean columns aren't necessarily the best alternative for your
business requirements. Aim to increase the density of your data! A
boolean `order_completed` column might miss important information
that's better modeled with columns like `completed_at` or
`completed_by`. We return to the NULL value problem :( A possible
alternative is to introduce a table to track order state.

Also, sometimes it's better to combine boolean attributes into a
single status column.

### Subtypes

Back to the NULL problem: sometimes a table will encompass more than
one subtype. For example, an `employees` table will have NULL columns
depending on whether the employee is a contractor or a permant
employee. A possible solution is to use 3 tables:

- `employees` will have a type identifier, either `contract` or `permanent`.
- `permanent`
- `contract`

All of these tables would have `employee_number` as primary key.
Assigning independent primary keys to the children tables would be a
performance disaster (remember: the primary key is sometimes implicit
and shadowed by an auto-increment column).

By splitting out subtypes into different tables, and given that the
queries are correctly written, we are more likely to plow through just
relevant information, as opposed to a greater quantity of data if
everything were in a single table.

Subtypes can be used incorrectly when there is a super-generic parent
table that is shared between many children just for the sake of
implementing inheritance.

### Types and implicit constraints

> Data semantics belong in the DBMS, not in the application programs.

**Example**: An identifier will be numeric depending on condition X,
otherwise it will be alphabetic. In that case, the optimizer will lack
the information to efficiently filter on the column. In a properly
designed database, this is unacceptable.

Avoid generic tables such as `configuration` with `parameter_name` and
`parameter_value` as strings. A better scheme is:
`configuration(parameter_id, parameter_name)`,
`configuration_numeric(parameter_id, parameter_value)` where
`parameter_value` has a numeric type.

Constraints (FKs, check, enums, etc) contribute to ensuring the
integrity of your data and provide information to the optimizer.

### Excess flexibility

> True design flexibility is born of sound data-modeling practices.

A super generic table with `entity_id`, `attribute_id`, and
`entity_value` will have no NULL values. However, queries would be
extremely hard to "design" and would performly badly, involving dozens
of joins; typing would be very weak, so integrity would be sacrificed;
and so on.

### Historical data

> Handling data that both accumulates and changes requires very
> careful design and tactics that vary according to the rate of
> change.

Proper modeling of historical data is often ignored by startups and
companies breaking into the market. There are several ways to model
historical data.

*Example*: We want to model sale price changes. There are many
alternatives, and the chosen one must match business requirements:

- A `sale_prices` table with `sale_id`, `effective_from_date`, and
`price`. Advantage: it would be possible to _program_ future prices.
    - The same table with `effective_until_date` (end date instead of
      start date), which is no improvement and it would imply one
      record whose date would be either NULL or doomsday.
    - The same table with `effective_from_date` + `number_of_days`.
      Increases query complexity when querying by the end date.
    - Denormalize the same table with `effective_from_date` and
    `effective_until_date`, which would provide more flexibility to
    design queries. Denormalization implies taking a risk with data
    integrity and requires additional checks to maintain it.
- 2 tables: a current table and a historical table, and plan a
"migration" of rows from current to historical when prices change.
This one might be complicated to maintain and programming future
prices wouldn't be possible.

### Design and Performance

> The single largest contributory factor to poor performance is a
> design that is wrong.

Tuning is about:

- Improving the overall condition of the system, according to current
CPU, memory, IO, and sometimes taking advantage of the physical
implementation of the DBMS. Rarely it surpasses 20 or 30% improvement.
- Modifying of rewriting queries for better performance.

Indexes don't really belong to the tuning of production databases.
Most indexes can and must be correctly defined from the outset as part
of the design process.

### Processing Flow

> A data model is not complete until consideration has also been taken
> of data flow.

The operating mode has a significant impact on the working system and
the design thereof:

- Asynchronous: Also called "batch programs", they are useful to
  postpone processing large amounts of data. Ever increasing volumes
  of data might require immediate processing, so good throughput and
  efficiency of queries is usually a must.
- Synchronous: A typical transaction (e.g., of a web app).

If we choose synchronous operating mode over asynchronous, it might
happen that a surge in traffic will paralyze the system at the worst
possible moment; that's when you notice something is wrong. For async
operating mode, you notice something is wrong when it takes an
eternity to complete.

Is your design ready to handle the processing flow required by your
applications?

### Centralization of Data

> The nearer you are to your data, the faster you can get at it!

Spreading data across many servers adds a considerable amount of
complexity to a system (microservices, I'm looking at you!). The more
complicated a structure, the less robust it is, due to:

- Network: Slow response times. Can be improved when DB servers are
  under the same network.
- Combining data from different data sources: Might require temp
  storage and renders DB setup (indexes, carefully thought-out
  physical layout, etc) and optimizer work ineffective.

Replication might be a better solution for data that needs to be
globally available.

### System Complexity

> Database systems are joint ventures; they need the active and
> cooperative participation of users, administrators, and developers.

One thing to keep in mind when designing is: what happens if some
piece of hardware breaks or some mistake is made with the data?

- The recovery of a huge database takes a lot of time.
- Spare duplicate DBs may help, but not at all with data mistakes
(unless sync delay is unrealistically long).
- It's even more complex with several related DBs, because one needs
  to ensure correct synchronization after recovery to avoid data
  corruption.

### Conclusion

> Successful data modeling is the disciplined application of what are,
> fundamentally, simple design principles.

It is striking to consider how much energy and intelligence can be
wasted trying to solve performance problems that are born from the
ignorance of elementary design principles.

Attempts to fix performance problems with further denormalization
might make the matter even more severe. One query might be tuned to
run faster, but (a hypothetical) nightly batch program will have more
data to plow through, so it might take twice as long to finish.

## Indexes

See [this link](https://gist.github.com/thiagoa/cfd5f6e95ee48e222e9f).

### Btree

Comprised of a sorted, balanced search-tree + a sorted, doubly linked
list of leaf nodes;

Leaf nodes:

- Each leaf node is stored in a block or page, the DB's smallest
storage unit.
- All blocks are of the same size
- The DB stores as many index entries as possible in each block.
- The doubly linked list enables the DB to read the index forward or
  backward;
- Each index entry consists of the indexed columns + the row id.
- The index is sorted, while table data is stored in a heap structure
  and not sorted at all. There is no physical relationship between the
  rows stored in the same block, nor between the blocks themselves.

Balanced search tree:

- The root node and branch nodes support quick searching among the
  leaf nodes;
- Each branch node entry has an edge to the biggest value in the
respective leaf node.
- Root nodes follow the same logic as leaf nodes.

Example: Searching for 57.


```
                           Btree sample


A root node              ... 39-83 98 ...                Path: 39, 83 / 83 is bigger than 57 so traverse the edge
                                /
                               /
                              /
                             /
A branch node          ... 46-53-57 83 ...               Path: 46, 53, 57 / 57 is equal to 57 so traverse the edge
                              /   \
                             /     \
                            /       \
                           /         \
                          /           \
2 leaf nodes    ... <-> 46 53 53 <-> 55-*57* 57 <-> ...  Path: 55, 57 - Follow the leaf node chain until finding 57.
                                                                        A bigger value means not found.
```

- The tree balance allows accessing all elements with the same number
of steps;
- Real world indexes with millions of records have a tree depth of 4 or 5.

The tree has logarithmic growth:

| Op                      | Branch node entries | Tree Depth | Index Entries |
|-------------------------|---------------------|------------|---------------|
| log(64,   base: 4) == 3 | 4                   | 3          | 64            |
| log(256 , base: 4) == 4 | 4                   | 4          | 256           |
| log(1024, base: 4) == 5 | 4                   | 5          | 1024          |
| ...                     | ...                 | ...        | ...           |

## Concatenated index

- Access column: Used to traverse the index;
- Filter column: Used as a filter along with the access column;
- Given a B-tree structure, the column order of a concatenated index
  is obviously important;
- The first column is the primary sort criteria and the second column
  can be used an additional access column _only if two or more
  secondary entries are associated with the same primary entry_.
  Otherwise, the second column would be a filter column.
- Index order is the same as ORDER BY over two or more columns,
  therefore you can fetch a sample of the index with the following
  query:

        SELECT <INDEX COLUMN LIST> FROM <TABLE>
        ORDER BY <INDEX COLUMN LIST> LIMIT 100

- A concatenated index should be useful for as many queries as
possible. Example, given two columns: `partner_id` and `partner_type`,
which index is better?

        SELECT * FROM payouts WHERE partner_id BETWEEN 1 AND 100 AND partner_type = 'Vendor'

        1. CREATE UNIQUE INDEX idx_partners ON payouts(partner_id, partner_type)
        2. CREATE UNIQUE INDEX idx_partners ON payouts(partner_type, partner_id)

    - 1 would use `partner_id` as *access* and `partner_type` as
*filter*. What if 1 processes 1000 rows because there are 10 partner
types? Performance would suffer with random access;
    - 2, on the other hand, would use both `partner_type` and
`partner_id` as *access*. It would go straight to the `Vendor` partner
type, where the IDs would already be sorted. It would process about
100 records or less.
    - 2 allows "access" search by two criterias: `partner_type`, and
`partner_type + partner_id`. This is good, since `partner_id` alone is
not a useful filter while `partner_type` is.

## Slow indexes

- A slow index lookup will almost always follow the leaf node chain
indefinitely, especially if there are repeated values.
- Accessing the table to retrieve a row means "random access", which
is slow with a high number of entries.
- UNIQUE INDEX SCAN: Performs tree traversal without following the
  leaf node chain because there is a maximum of one match in the leaf
  nodes.
- INDEX RANGE SCAN: Performs tree traversal with following the leaf
node chain. Can potentially read a large portion of the index.
- Full table scan is sometimes more efficient.

Given this query over a concatenated index on `subsidiary_id,
employee_id`:

```sql
SELECT first_name, last_name, subsidiary_id, phone_number
    FROM employees
   WHERE last_name  = 'SILVA'
     AND subsidiary_id = 30;

------------------------------------------------------------------
| Id | Operation                   | Name         | Rows | Cost  |
------------------------------------------------------------------
|  0 | SELECT STATEMENT            |              |    1  |  30  |
| *1 | TABLE ACCESS BY INDEX ROWID | EMPLOYEES    |    1  |  30  |
| *2 | INDEX RANGE SCAN            | EMPLOYEES_PK |   40  |   2  |
------------------------------------------------------------------

Predicate Information (identified by operation id):
  ---------------------------------------------------
    1 - filter("LAST_NAME"='WINAND')
    2 - access("SUBSIDIARY_ID"=30)
```

This subsidiary returns many records, and the query is slow even
though it matches only 1 row. The reason is:

- INDEX RANGE SCAN: Traverses the tree and follows the leaf node
chain. The result is a list of row ids.
- TABLE ACCESS BY INDEX ROWID: Fetches the rows one by one and applies
the `last_name` filter.

Wide index range scans followed by table access are usually slow; full
table scans might be faster because they are able to read large parts
of the table in one shot. Data distribution is an important criteria
for the optimizer, but in this example the optimizer hasn't been able
to choose the best plan because statistics were outdated after growing
the table (note the unrealistically low cost of 30). Given proper
statistics, the optimizer will prefer a full table scan. The lowest
cost wins.

The best solution to speed up this query is to create an index on
`last_name`.

## Function-based indexes (FBI or functional indexes)

Using functions on the left-hand side of a WHERE clause argument is
dangerous and might imply full table scan.

```sql
SELECT first_name FROM vendors WHERE UPPER(last_name) = UPPER('thiago');
```

> MySQL's default collation doesn't distinguish between upper and
> lower case letters.

Compile-time evaluation: The DB replaces the result of deterministic
functions (constant expressions) during compile-time. The execution
plan for the above query would therefore show:
`filter(UPPER("LAST_NAME")='THIAGO')`.

In Postgres and Oracle, we can create functional indexes:

```sql
CREATE INDEX idx_vendor_up_last_name ON vendors (UPPER(last_name));
```

Now instead of a full table scan, we would have an index range scan
traversing the B-tree and following the leaf node chain.

Note that statistics might not get updated right after creating an
index, so you might get suboptimal execution plans with a higher or
lower number of processed rows for each operation executed by the
query. [In Postgres, we would have to wait for autovacuum or kick off
a manual
analyze](https://blog.dbi-services.com/are-statistics-immediately-available-after-creating-a-table-or-an-index-in-postgresql/).

Some databases (i.e., SQL server) do not support FBI, but do support
computed columns and indexes on the computed columns.

```sql
ALTER TABLE vendors
  ADD COLUMN up_last_name varchar(255)
  GENERATED ALWAYS AS (UPPER(last_name)) STORED;

CREATE INDEX idx_vendor_up_last_name on vendors(up_last_name);
```

Function-based indexes shouldn't be based upon non-deterministic
functions, i.e., the ones depending on current time, random numbers,
etc.

In PostgreSQL, the function or expression used to create FBIs needs to
be IMMUTABLE, i.e., the function is guaranteed to return the same
result given the same arguments. The IMMUTABLE keyword gives the
function a trust sign for FBIs. However, it is possible that a
non-deterministic function still be declared IMMUTABLE.

Given this limitation, how to index a query by people's age? Re: Index
the date field then perform the calculation of the target date on the
right-hand side of the WHERE clause argument.

## Parameterized queries

Benefits:

1. Prevent SQL injection
2. Reuse of the same execution plan

Item 2, however, is a double-edged sword. Bind parameters are not
visible to the optimizer, so it can't rely on the histogram
(distribution of data) to determine the best execution plan for each
dataset. It assumes an equal distribution and always gets the same row
count estimates and cost values (i.e., assuming the same number of
distinct values and dividing it by the number of rows in the table).

So, is the cost of generating and evaluating execution plans higher
than the cost of possible performance variations due to unequal
distribution of data? Maybe it is, maybe not. Database vendors try to
solve this dilemma with heuristic methods—but with very limited
success.

> When in doubt, use bind parameters.

Cursor Sharing and Auto Parameterization: SQL server and Oracle can
enforce parameterization of queries automatically, which are
workarounds for applications that do not use bind parameters at all.

## Types of optimizers

- Cost-based optimizer: Uses statistics about tables, columns,
  indexes, histogram (data distribution), etc, to compare the cost of
  different plans.
- Rule-based optimizer: rare nowadays.
