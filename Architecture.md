## Architecture

The shape given to that system by those who build it.

Goal: minimize the lifetime cost of the system and maximize programmer productivity.

## Component Cohesion

- Inclusive principles tend to make components larger.
- Exclusive principles drive components to be smaller.

### The Reuse/Release Equivalence Principle (REP)

*Inclusive principle*: group for reusers.

> The granule of reuse is the granule of release.

- To allow for reuse, components must be tracked through a release
  process.
- Based on the changes, users decide whether or not to adopt the new
  version.
- Classes and modules that are formed into a component must belong to
  a cohesive group.
- Classes and modules should be releasable together.

### The Common Closure Principle (CCP)

*Inclusive principle*: group for maintenance.

> Gather into components the classes that change for the same reason.
> Separate those things that change at different times or for
> different reasons.

- SRP stated for components.
- This principle is more about maintanability than reusability. If
  code needs to be changed, one would rather that the changes occur in
  *one* component.
- Gather together in one place all the classes that are likely to
  change for the same reasons, or that are closed to the same types of
  changes.
- Related to OCP.

### The Common Reuse Principle (CRP)

*Exclusive principle*: split to avoid unneeded releases. Specially
true for compiled languages.

> Don't force users of a component to depent on things they don't
> need.

- Classes and modules that tend to be reused together belong in the
  same component.
- Tells which classes not to keep together in a component. Classes
  that are not tightly bound to each other should not be in the same
  component.
- When we depend on a component, we want to make sure we depend on
  every class in that component.

### Tension Between Principles

- REP + CCP = Too many unneeded releases.
- REP + CRP = Too many components impacted when simple changes are
  made.
- CRP + CCP = Hard to reuse.

Early in the development of a project, the CCP is more important than the REP,
because developability is more important than reuse.

## Component Coupling

Tensions between developability and logical design.

### The Acyclic Dependencies Principle

> Allow no cycles in the component dependency graph.

#### The Weekly Build

- The problem: someone changed a component you depend on.
- The solution: developers ignore each other for the first four days
  of the week. On Friday, they integrate all their changes and build
  the system.
- Disadvantage:
       - A large integration penalty is paid on Friday.
       - The integration burden grows with the project and eventually overflows.
       - Results in schedule changes; integration and testing become
       harder; the team slowly loses the benefit of fast feedback.

#### Eliminating Dependency Cycles

- Partition the development environment into releasable components (units of work).
- Release a component with a version number for other teams to use.
- Development of the component continues in a private area.
- Teams decide whether they will adopt a new release.
- No team is at the mercy of others.
- Changes do not have an immediate effect.
- Changes happen in small increments.

Most importantly: there can be no cycles in the dependency graph,
otherwise the "morning after syndrome" won't be avoided. In other words,
we must have a _directed acyclic graph_ (DAG).

```text
 View ------------- Main ---------- Controllers
  |      |           |       |          |
  |      |           |   Authorizer     |
  |  Database-----   |    |             |
  |        |     |   |    |             |
Presenters-|---> Interactors <----------|
           |         |
           |         |
           |_____ Entities
```

In this app, each component is built and released separately.

- Main depends on everything but nothing depends on it. Releasing it has no effect on other components.
- Entities depends on nothing but some components depend on it.
- Follow the dependency arrows backward to know what will be affected by a component change.
- To run a test on Presenters, build Interactors and Entities.
- Build order: Entities, Database, Interactors, Presenters, Views, Controllers, Authorizer.

A cycle means:

- The involved components become one big component.
- They must all use exactly the same release of one another's components.
- Suppose Entities is part of a cycle. To test Entities, you will have to build additional components.
- Isolating components is difficult.
- Unit testing and releasing become difficult.
- Difficult to work out the order in which to build components.

To break a cycle and reinstate the dependency graph as a DAG:

- Apply the dependency inversion principle.
- Or create a new component in the middle. Move the classes on which
  the two components depend into the new component, thereby making the
  dependency structure grow. This implies that the component structure
  is volatile in the presence of changing requirements.

#### Top Down Design

- The component structure cannot be designed from the top down. It
  evolves as the system grows and changes.
- Component dependency diagrams are a map to the buildability and
  maintanability of an application.
- When a project starts we want to keep changes localized, so we
  resort to SRP and CCP.
- The component dependency graph protects stable components from
  volatile components.
- As the app grows, we start to be concerned with reusable
  elements. CRP begins to influence the composition of the components.
- As cycles appear, the ADP is applied and the component dependency
  graph jitters and grows.

### The Stable Dependencies Principle (SDP)

> Depend in the direction of stability

Stable components (which are difficult to change) should not depend on
volatile components. Otherwise, the volatile component will also be
difficult to change.

#### Stability

- Has nothing to do with frequency of change.
- Is related to the amount of work required to make a change.
- A component is difficult to change if lots of other components
  depend on it. It requires a great deal of work to reconcile changes
  with the dependent components.
- Independent component (stable): it depends on no other, but others
  depend on it. It has no external influence to make it change.
- Dependent component (unstable): no components depend on it, but it
  depends on other components. Changes may come from all its
  dependencies.

Count the number of dependencies that enter and leave the component to
calculate its positional stability.

- Fan-in, incoming dependencies: number of external classes which
  depend on the component.
- Fan-out, outgoing dependencies: number of component classes which
  depend on external classes.
- Instability: `I = fanout / (fanin + fanout)`.
- `I = 1` is unstable, dependent; means fanin = 0 and fanout > 0. The
  component has no reason to change; the components it depends on give
  it ample reason to change.
- `I = 0` is stable, independent; means fanin > 0 and fanout
  = 0. Dependents make it hard to change the component, but no
  dependencies might force it to change.

If all components of a system were stable, the system would be
unchangeable.

```
Instable c. (I = 1)        Instable c. (I = 1)
   |                                |
   |_________          _____________|
            |          |
          Stable c. (I = 0)
                 |
                 |
            Instable c.
```

Hang an instable component at the bottom to violate SDP! To fix this
situation, apply DIP. The newly introduced component/interface must be
stable, and dependencies on both sides will flow toward decreasing I
(instead of increasing).

#### The Stable Abstractions Principle (SAP)

> A component should be as abstract as it is stable.

What shouldn't change often - the high-level policies - should be
placed into stable components. But that could make the architecture
inflexible and hard to change. For a stable component to withstand
change, there's OCP and abstract classes.

- A stable component should be abstract so that its stability does not
prevent it from being extended.
- An unstable component should be concrete since its instability
  allows the concrete code within it to be be easily changed.

SAP + SDP = DIP for components.

> Dependencies run in the direction of abstraction.

Measuring abstractness: `number_of_abstract_classes_or_interfaces /
number_of_classes`.  0 implies that the component has no abstract
classes. 1 implies the components only has abstract classes.

Stability versus abstractness:

- Good: maximally stable, maximally abstract (0, 1).
- Good: maximally unstable, maximally concrete (1, 0).
- Bad: maximally stable, maximally concrete (0, 0).
    - Too rigid.
    - Hard to change because it's not abstract and very stable.
    - Example 1: database schemas - volatile, concrete, depended on. Schema updates are painful.
    - Example 2: string - non-volatile. Changing it would create chaos. Since it's non-volatile, it's harmless.
    - The more volatile, the more painful.
- Useless: maximally unstable, maximally abstract (1, 1).
    - Maximally abstract, yet has no dependents.
    - Leftover abstract classes.

The **Main Sequence** is the line that connects (1, 0) and (0, 1). The
most desirable position for components is at one of those endpoints.

Distance from the main sequence: `D = A + I - 1`.

- 0 indicates that the component is on the Main Sequence.
- 1 indicates that the component is as far away as possible from the Main Sequence.
- More than 1: very abstract with few dependents or very concrete with
  many dependents.
