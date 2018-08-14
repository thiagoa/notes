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
