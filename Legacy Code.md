## How do I add a feature?

### Programming by difference

Nowadays, I rarely use inheritance but it's important to retain this technique precisely because of the drawbacks. Inheritance is a quick and dirty way to slightly change the behavior of a class in order to support a new feature:

- Create a test with the desired behavior.
- Create a subclass and override a concrete method.
- Make the test pass.

Take the following example:

```ruby
class MessageForwarder
  def from_address(message)
    from = message.from

    if from
      InternetAddress.new(from.first.to_s)
    else
      InternetAddress.new(default_from)
    end
  end

  # Other methods
end
```

We want to support anonymous message lists, so we create a subclass:

```ruby
class AnonymousMessageForwarder < MessageForwarder
  def from_address(_message)
    InternetAddress.new("anon-#{list_address}")
  end
end
```

Now we want to support sending cco emails to people not in the official distribution list. A subclass would work, but what if we need two subclass behaviors at the same time? Clearly, we need to stop using subclasses. For example, we can pass a configuration hash to `MessageForwarder` and delete the `AnonymousMessageForwarder` subclass:

```ruby
forwarder = MessageForwarder.new(anonymous: true)
```

Now that `MessageForwarder` has more responsibilities, we can refactor by moving some of its behavior to a new class:

```ruby
# Assume this class was called MailingConfiguration, and then
# we moved some high level behavior into it... so it's now
# called MailingList.
class MailingList
  def from_address(message)
    # ...
  end
end
```

Composition is clearly better than inheritance in most cases.

So what's the _other_ trap of "programming by difference"? It's easy to violate the Liskov Substitution Principle and thus the expectation of clients:

- Try to avoid overriding concrete methods.
- If you do so, try calling the overriden method in the substitute method.
- Code gets confusing when overriding too many concrete methods.

Liskov is all about keeping the same interface and _keeping up with client expectations_.

If we wish to keep inheritance in the above example, it's recommended that we force every client to define a `from_address` method:

```ruby
class MessageForwarder
  def from_address(_message)
    raise NotImplementedError
  end
end
```

With that, we _normalize the hierarchy_. In a normalized hierarchy, we don't need to worry about subclasses overriding inherited behavior.

## Where should I write my tests? The Effects Sketch

This process can be done informally, but some formality might help
when dealing with hairy code.

- For each functional change, there's a chain of associated effects.
- The domain does not matter when reasoning about effects.
- Pay attention to mutable values passed by reference: what methods
  would be affected by a mutation?
- Lists or hashes can also have their elements mutated.
- An effects sketch can help us understand the chain of associated
  effects. It's made of balloons and arrows pointing from cause to
  effect. Methods, variables, etc., are all included, and the balloons
  can represent methods or variables from different objects.
- Consider superclasses, subclasses, and anything that can affect a value.
- Consider all client code.
- For example, `declarations -> getDeclarationsCount` means that
  changes in the `declarations` list affects the return value of
  `getDeclarationsCount`.
- Quality measure: when complex side-effects are summed up by simple
  effects.
- Simplifying the effects sketch contributes to more comprehensible code.
- How can a change affect the results of my program? Figure out where
  to make the change and think forward from this point.
- Where can I write my tests so that my changes can be detected?
- After drawing (or imagining) the sketch, choose where to implement
  your tests.

### Effect propagation

How can effects propagate?

- Return values.
- Silent changes on objects that are passed as parameters.
- Global or static data.
- A mutating call to an external system.

Heuristic to look for effects:

- Identify the method that will be changed.
- Take a look at how its return value is used by callers.
- Examine any values changed internally by the method, and any methods
  using these values.
- Look into superclasses and subclasses using these methods or
  instance variables.
- Look into method parameters. Any objects used by the code you want
  to change?
- Look for global and static variables.
- Be aware of gotchas. For example, sometimes a variable is _meant_ to
be private but is public. The privateness is a firewall to simplify
the effect analysis.
- Ask questions like: can a variable be changed _after_ being used a
  method?
- Be aware of language-specific gotchas (or lack of gotchas).

### Simplifying the effects sketch

Removing duplication can increase the surface area covered by your
tests. For example:

- A `declarations` instance variable affects three methods:
`getDeclarationsCount`, `getInterface`, and `getDeclaration`.
- `getInterface` changes `declarations` internally.
- A test written on `getInterface` wouldn't cover `getDeclaration`
(ideally we do want to cover it), but if we make `getInterface` use
`getDeclaration` internally, the surface area of our test will be
increased.

### Interception point and pinch point

Where can I write a test that will detect many changes in one area?

An interception point is a point in your program where you can detect
the effects of a particular change. A change can have more than one
interception point.

- If you are making a private change to a module, the closest
I.P. will be the next public interface. If you write a test at this
level, however, you will be neglecting call-site coverage. Sometimes
this will your best choice though:
    - It might be hard to write a test for a distant I.P.
    - The number of steps between the changed area and the I.P. might
    make it harder to write assertions.
    - _Sometimes_, putting the call-site under test will not be
    a necessity.

**WARNING**: Always change the code at the change point to make sure tests
fail as expected.

When a change is comprised of other smaller changes, the trick is to
find an interception point that will cover all of them: the "pinch
point" - a narrowing in an effect sketch.

- Write characterization tests for the individual change points when
you can.
- Or find a high-level I.P. to focus on a wide chunk of code. The
  benefit is that by doing so, you might not need to break any
  dependencies.
- Optionally use an effect sketch to find the I.P.

What if there is more than one call-site? We can choose a single pinch
point to perform our changes, especially if the code is not being used
in distinct ways. Or two call-sites together can be seen as a single
pinch point to cover all of our changes. The question is: "will I be
able to sense the changes in this place?".

If you can't find a pinch point, write tests for the individual
changes or:

- Revisit the change points. Are you trying to do too much at once?
- Find pinch points for one or two changes at a time.

A pinch point is a natural encapsulation boundary. Encapsulation is:
we don't have to care about the internals, but when we do, we don't
have to look at the externals to understand them. Given a pinch point,
how can responsibilities be reallocated to give better encapsulation?

We can use an effect sketch to find hidden classes or modules in the
form of indirect dependencies. Are there any encapsulation boundaries
in the effect sketch?

The most important thing to keep in mind: pinch points are a way to
start some invasive work in part of a program: for example, writing
unit tests and more reasonable integration tests. Pinch point tests
will eventually go away.

Be careful for unit tests not to grow into mini-integration tests!

## Characterization tests

- Are documentation tests for the current system behavior.
- They are not about finding bugs.
- A bug can be a feature users rely on. So don't rush to change the
  behavior.
- They help us make changes: what the system does VS what it's
  supposed to do.
- Flag unexpected behavior and find out what the effect will be after
fixed.
- Given different inputs, characterization tests are a way of asking
  "what is the actual behavior?".
- When to stop: do the tests cover the changes we need to make?
- What can go wrong? How can I exploit these gotchas in my tests?
- Useful technique for monster methods: "sensing variables".
- Look for invariants, global values, and refactor them. This might
lead to new insights.
- Be aware of gotchas: a false positive can happen when the
characterization test is not thorough enough, and we might never
notice. Example: given a function using doubles, we might use "extract
method" on it and accidentally convert the double to an int.

## Library dependencies

- Avoid direct calls to libraries throughout your code.
- For languages that support interfaces, prefer libraries that define
interfaces which allow you to define fakes.
- Libraries should be test friendly.
