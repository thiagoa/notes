# Notes for the book Domain Driven Design

## Repositories

### Intro

- There is no need for all objects to be interconnected or
  traversable, which would potentially make the web of objects
  unmanageable
- Reconstitution: creation of an instance from stored data
- Don't forget the focus on the model; it's easy to forget it when
  you're thinking about technical mechanisms to deal with queries in
  the infrastructure layer
- It's easy to take a shortcut and pull specific objects from the DB,
  rather than navigating from the aggregate root to obtain a certain
  relationship: *any object internal to an aggregate is prohibited
  from access except by traversal from the root*
- If you don't use a framework, the technical complexity of applying
  DB access infrastructure quickly swamps the client code, which leads
  devs to dumb down the domain layer, which makes the model
  irrelevant. Entities and value objects run the risk of becoming mere
  data containers
- No need to worry about transients like value objects. They might be
  convenient to find by traversal (example, `person#address`) as long
  as aggregate rules are followed

A subset of persistent objects corresponding to the roots of
aggregates (which are not convenient to reach by traversal) must be
globally accessible through a search based on object attributes.

Free database queries can breach the encapsulation of domain objects
and aggregates. Exposure of technical infrastructure and database
access mechanisms complicates the client and obscures model-driven
design.

Techniques for dealing with DB access:

- Encapsulating SQL into query objects
- Metadata mapping layers (Fowler 2003)
- Factories can help reconstitute stored objects

The repository pattern brings back model focus.

### What is it?

- Represents all objects of a certain type as a conceptual set
- Acts like a collection with more elaborate querying capability
- Allows the client to ask what it needs in terms of the model
- Adds or removes records, corresponding to INSERTs or DELETEs for SQL DBs.
- Clients request objects from the repo using query methods
- The repo encapsulates the machinery of database queries and metadata mapping
- They can also return summary information such as counts
- Repos can interface internally with other repos, query objects, etc.
  Question: does classic DDD allow the use of query objects outside
  the context of a repo?

For each type of object that needs global access, create an object
that can provide the illusion of an in-memory collection of all
objects of that type. Setup access through a well-known global
interface. Provide repos only for aggregate roots that need direct
access.

Advantages:

- Provide a simple model for obtaining persistent objects and managing their life cycle
- Decouple application and domain design from persistent technology
- Communicate design decisions about object access
- Allow easy stubbing, typically with in-memory collections
