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
