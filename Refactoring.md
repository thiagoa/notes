# Refactoring

## General rules

- Don't name concepts after their implementation. Find out the domain term that
  represents the abstraction.

## Horizontal and vertical refactoring

Horizontal:

- Do what's easier
- Eliminate risk
- Quickly exploit proven opportunities
- Forget other refactoring opportunities
- Stop thinking

Vertical is the opposite.

## Flocking Rules

Unearth hidden abstractions by iteratively applying a small set of rules.
Turn difference into sameness.

1. Select the things that are most alike.
2. Find the smallest difference between them.
3. Make the simplest change that will remove that difference.
    1. Parse the new code.
    2. Parse and execute it.
    3. Parse, execute, and use its result.
    4. Delete unused code.

As you're following the rules:

- Change one line at a time.
- Run the tests after every change.
- If the tests fail, undo and make a better change.

If two concrete examples represent the same abstraction and they contain a
difference, that difference must represent a smaller abstraction within the
larger one. If you can name the difference, you’ve identified that smaller
abstraction.

## Code smells

Because you know, I always forget names.

### Primitive obsession

Using primitive data types to represent domain ideas.

```ruby
# What is 3? Is it duration in days, months, or weeks?
course.duration = 3
course.duration_in_months # 0
course.duration_in_weeks  # 3
course.duration_in_days   # 21
```

A solution is the Whole Object Pattern.

```ruby
class Duration
  def initialize(magnitude)
    @magnitude = magnitude
  end

  # ...
end

class Days < Duration; end
class Weeks < Duration; end
class Months < Duration; end
```

### Feature envy

Reveals a method that would work better on a different class.  Methods
suffering from feature envy contain logic that is difficult to reuse because
logic is trapped within a method of the wrong class.

Symptoms:

- Repeated references to the same object
- Parameters or local variables are used more than
  methods and instance variables of the class in question.
- Methods that are prefixed with a class name
- Private methods that accept the same parameter (sometimes this can be primitive obsession)

### Shotgun surgery

A change needs to be performed in several places. It usually reveals another
smell.

Example:

```erb
# app/views/users/show.html.erb
<%= current_user.first_name %> <%= current_user.last_name %>

# app/views/users/index.html.erb
<%= current_user.first_name %> <%= current_user.last_name %>

# app/views/layouts/application.html.erb
<%= current_user.first_name %> <%= current_user.last_name %>
```

The smell in question is "duplicated code".
