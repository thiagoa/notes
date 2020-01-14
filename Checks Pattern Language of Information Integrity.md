# Checks Pattern Language of Information Integrity

Except where noted or quoted, this document is my own interpretation
and understanding of the [CHECKS Pattern Language of Information
Integrity](https://c2.com/ppr/checks.html) paper by Ward Cunningham.
It was written in 1994 based on the author's experience developing
financial software in Smalltalk. The code samples herein were
translated to Ruby.

This language contains ten patterns for telling good input from bad,
and modelling these concepts at the domain level. The methods are
designed to make the checks without overly complicating programs or
making them inflexible for future changes.

## Domain Model

### Whole Value

The same as "Value Object".

> When parameterizing or otherwise quantifying a business (domain)
> model there remains an overwhelming desire to express these
> parameters in the most fundamental units of computation. Not only is
> this no longer necessary (it was standard practice in languages with
> weak or no abstraction), it actually interferes with smooth and
> proper communication between the parts of your program and with its
> users. Because bits, strings and numbers can be used to represent
> almost anything, any one in isolation means almost nothing.
>
> Construct specialized values to quantify your domain model and use
> these values as the arguments of their messages and as the units of
> input and output. Make sure these objects capture the whole quantity
> with all its implications beyond merely magnitude, but, keep them
> independent of any particular domain. (The word value here implies
> that these objects do not have an identity of importance.) Include
> format converters in your user-interface (or better yet, in your
> field and cell widgets) that can correctly and reliably construct
> these objects on input and print them on output. Do not expect your
> domain model to handle string or numeric representations of the same
> information.

Whole Values shouldn't depend on other parts of the domain. They are
just plain values whose identity has no importance - in other words,
they are defined by their content rather than their identity.

> You will find that these objects will capture some of the
> irregularity and (possibly) ambiguity of the domain model. Expect
> particular classes to grow into hierarchies over time. But, do not
> extend whole values to include non-applicable or exceptional
> quantities better represented by an Exceptional Value. Also,
> avoid undue reasoning regarding inappropriate combinations of values
> so long as Meaningless Behavior will eventually result.

Whole Values afford the opportunity to model irregularity and
ambiguity, like magnets attracting relevant behavior. They are
even more useful when coupled with constructors, as follows:

```ruby
class WholeValue
  def exceptional?
    false
  end
end

class Duration < WholeValue
  attr_reader :magnitude

  def self.[](magnitude)
    new(magnitude)
  end

  def initialize(magnitude)
    @magnitude = magnitude
    freeze
  end

  def inspect
    "#{self.class}(#{magnitude})"
  end

  def to_s
    "#{magnitude} #{self.class.name.downcase}"
  end

  alias_method :to_i, :magnitude
end

class Weeks < Duration; end
class Days < Duration; end
class Months < Duration; end

def Duration(raw_value)
  case raw_value
  when Duration
    raw_value
  when /\A(\d+)\s+months\z/i
    Months[$1.to_i]
  when /\A(\d+)\s+weeks\z/i
    Weeks[$1.to_i]
  when /\A(\d+)\s+days\z/i
    Days[$1.to_i]
  else
    ExceptionalValue.new(raw_value, reason: "Unrecognized format")
  end
end
```

> These examples can be found in [Ruby Tapas
430-433](https://www.rubytapas.com/tag/whole-value/).

The `Duration` factory method provides implicit format validation. It
will only construct valid objects or Exceptional Values (which are
invalid or non-applicable objects). Basic validations are embedded
into the Whole Values themselves, and validation errors are meant to
be reported through Exceptional Values.

To save this data into the database, one would either have to:

- Save type + magnitude (e.g., Months, 3);
- Standardize magnitude in days (or other measurement) for all objects.
    - Initialize `Weeks`, `Days`, and `Months` with a magnitude in
      days.
    - Implement the `inspect` method with the proper date conversion.
      Example: convert from days to months (number of days / 30 or
      31).

### Exceptional Value

An Exceptional Value is a Value outside the range of a Whole Value,
with either:

- Domain meaning
    - The value has meaning within the domain model (even
      though it will eventually be rejected).
    - The value can be a placeholder for missing data that may appear
      later.
- Operational meaning:
    - The value is invalid/meaningless;
    - The value will thus produce Meaningless Behavior.

According to the author, Exceptional Value should be used when:

- When the inclusion of all possibilities would be confusing,
  difficult or otherwise inappropriate.
- Assuming that a certain Whole Value for a poll might take answers
  such as "agree", "strongly agree", etc, answers that defy
  quantification such as "refused" or "illegible" would be better
  represented outside the range of values.


```ruby
# Settlement Date is a securities industry term describing the date on
# which a trade (bonds, equities, foreign exchange, commodities, etc.)
# settles. That is, the actual day on which transfer of cash or assets
# is completed and is usually a few days after the trade was done.
def purchase_date
  buys = trades.select(&:purchase?)

  if buys.size >= 1
    # This should be an instance of a Whole Value
    buys.first.settle_date
  else
    ExceptionalValue.new(reporting: 'various')
  end
end
```

This is an example of Exceptional Value with domain meaning. Under
normal circumstances, a single purchase should exist within the trades
in order to return its settle date as the purchase date. More than one
purchase is a situation that's _not yet accepted_ by the domain model
(even though it can occur), so the exceptional situation is
represented with an exceptional value. It's leaving a place for this
sort of missing data for it may appear later.

This kind of information should be tagged as _exceptional_ by the
domain model with an `ExceptionalValue` object which should either:

- Accept all messages answering most with another exceptional value;
- Reject all messages via `method_missing` - with the exception of
  messages that would identify the (exceptional) nature of the object,
  such as `inspect` or `exceptional?`.

The author says:

> Domain models should accept `nil` or other exceptional values as legal
> input, at least temporarily.

The system shouldn't crash when dealing with Exceptional Values.
Sometimes EV will be compatible with non-exceptional Whole Values by
implementing one or more of its interfaces; or the system will crash
and immediately recover through error handling, which implies
Meaningless Behavior.

> In Smalltalk it is possible to make refinements of UndefinedObject
> that can carry an explanation. If you do, note that aValue == nil no
> longer means the same thing as aValue isNil.

Given that in Smalltalk `nil` is the single one instance of
`UndefinedObject`, the author suggests the possibility of representing
an exceptional value with a refinement of `UndefinedObject`. `nil` has
always been context-dependent, but without a context it may have
more than one meaning. We would thus be specializing `nil`, which is
semantically compatible with the concept of "exceptional value", to
give it further meaning within the domain. In that case, `aValue ==
nil` would be `false` while `aValue isNil` would be `true`.

> It should not be necessary to explicitly test for exceptional values
> in methods because they will either absorb messages or produce
> Meaningless Behavior.

For simplicity's sake, there should be no tests or special concessions
for exceptional values in higher-level components or policies. Inside
these policies, exceptional values will either "absorb" messages or
produce Meaningless Behavior.

> The little exceptional value handling that is required can be
> concentrated extremely close to the user interface. For example, the
> report writer needs to detect exceptional values to correctly
> compute a weighted average.

In Ward's example, the UI needs to detect an exceptional value in
order to compute and display a weighted average. I understand
"extremely close to the UI" as "not in a higher-level policy".

In [Ruby Tapas
431](https://www.rubytapas.com/2016/08/02/episode-431-exceptional-value/),
Avdi gives an example of handling exceptional values at the controller
level, closer to the UI. It explicitly checks for exceptional values
only where rendering is concerned. The presence of exceptional values
determine if it should re-render the form or persist and redirect:


```ruby
course = Course.new
course.name     = params.fetch("name")
course.duration = params.fetch("duration")

if course.values.any?(&:exceptional?)
  erb :course_form, locals: { course: course }
else
  course_list << course # Persist in-memory
  redirect to("/")
end
```

And it also checks for exceptional values in the ERB template in order
to display validation errors.

```erb
<% course.to_h.select{ |_, v| v.exceptional? }.each do |field, value| %>
  <div class="toast toast-danger"><%= field %>: <%= value.reason %></div>
<% end %>
```

### Meaningless Behavior

Exceptional values may appear throughout the computations, so it is
possible that the methods you write will stumble in circumstances you
cannot foresee.

> Keep in mind that the rules of business apply only selectively, and
> that evolution of business practice wiggles around even those rules
> that "must" apply.

A domain model applies rules selectively by nature. As we evolve it,
though, we tend to introduce conditional branches to handle special
cases, thereby drawing attention away from what's important.

> In your domain models you are chartered to express business logic
> with no more complexity than originally conceived or currently
> expressed.

This pattern suggests writing methods without concern for possible
failure. We should gracefully recover from failure and continue
processing.

> Users will interpret unexpected blanks to mean that inputs do not
> apply and/or outputs are unavailable.

 Such an output should be represented as _blank_ in the UI because we
would be dealing with meaningless behavior.

Extraneous error handling obscures business rules and increases
complexity:

```ruby
def weighted_average_cost
  unless weighted_total_cost.currency?
    return ExceptionalValue.new(reporting: 'N/A')
  end

  unless total_weight.number? && total_weight.nonzero?
    return ExceptionalValue.new(reporting: 'Empty')
  end

  weighted_total_cost / total_weight
end
```

This should simply be:

```ruby
def weighted_average_cost
  weighted_total_cost / total_weight
end
```

This is called by the author "accepting possible meaningless", while
the previous example is called "trying to be meaningful".

> Note: some readers have assumed this pattern to be about writing
> error handlers. It is not. It is about writing domain methods in the
> presence of diversity. It does assume a near trivial error handler
> to be in place in the input/output system which is not always the
> case.

This requires no explanation.

> You can view meaningless behavior as an alternate implementation of
> Exceptional Value.

This phrase made me scratch my head. So is Meaningless Behavior
another kind of object, or a specialization of Exceptional Value? No!
MB is _one way_ to handle EV.

> Choose meaningless behavior unless a condition can be anticipated
> and has domain meaning (as opposed to merely operational meaning
> such as not-yet-filled-out)

If a condition can be anticipated and has domain meaning, MB will not
be necessary because client methods will operate under expected
conditions. If the meaning is otherwise merely operational such as
not-yet-filled-out, MB will make code simpler.

This implies two kinds of Exceptional Value:

1. One that can be used in place of a Whole Value polymorphically;
2. One that will reject messages and make errors surface, which is
   where MB is concerned.

> At times there may be something very wrong inside the program so it
> is important that some clues surface.

At the development level, this means: If we get an error message
reporting an exceptional value, it will be immediately clear what's
going on. For the user, on the other hand, there will be visual clues
as a result of error handling:

> Echo Back exposes failure by echoing blank. Input screens that
> report Visible Implications can expect serious trouble to blank
> them too. Deferred Validation should demand meaningful behavior
> where corruption of records is the alternative.

## User interface

These are UI patterns to provide feedback to the user.

### Echo Back

The goal of this pattern is to provide early feedback to the user
without disrupting or breaking the flow, by immediately echoing back
the domain model's interpretation of the user's input. It can be seen
as pre-validation while the user is filling out the form.

There are two applications of this pattern:

- When dealing with input that results in Exceptional Value, either:
    - Echo back blank;
    - Echo back the meaningless value for the user to edit and fix.
- When dealing with input that can be fixed, echo back the fixed input.

> This pattern considers the domain model's modest obligation to
> explain such selection.

If the UI blanks out a field, it will be clear to the user that the
input is wrong. If the UI fixes the input or makes a reasonable
suggestion, it will be clear that something is wrong as well.

> You can expect values to be entered in small batches followed by a
> quick review looking for transcription or typing errors. This cycle
> repeats but not always with the same batch boundaries.

According to the author, EB is particularly useful when entering
values in batches.

> This pattern counters the common practice of ringing bells and
> flashing lights at the first sign of trouble. You will have plenty
> of opportunity to protest bad values in Deferred Validation.
>
> Do not expect the domain model to explain its interpretation of
> marginal or incorrect values through notifiers. Such initiative on
> the part of the model is misplaced because it breaks the small batch
> entry behavior.
>
> Our point here is not that one choice is better than another but
> that the choice once made must be visible to the user without
> disruption.

These 3 random quotes make it clear that the goal is to provide early
assistance and visual clues to the user in order to improve
usability.

The author's example is the following:

```
    user types:	5/8/94
    echo back:	05/08/94	(the whole value May 8th, 1994, standard format)

    user types:	5/5/94
    echo back:	05/08/94	(model has chosen nearest payday, always a Friday)
```

- 1º example: The model echoes back the standard print representation.
- 2º example: The model has chosen to handle bad input by choosing the
  closest legal input in its place.

> Field and cell widgits will be able to construct and deliver
> WholeValues to the domain model.

This quote implies that in Smalltalk, Whole Values should be
constructed directly by field widgets and then delivered to the domain
model.

#### Applicability on modern web applications

In Smalltalk, the UI interacts with the live program. Echo Back is a
UI pattern that interfaces with core business logic, so it would imply
some JavaScript in web applications. However, backend and frontend and
decoupled. How to make Echo Back work in web applications?

- JavaScript: The domain model would be partially or entirely written
  in JS. This works but is not an ideal solution because the backend
  needs to perform exactly the same validations as the frontend, which
  would result in duplicated logic across the stack. If both backend
  and frontend are written JS, _maybe_ sharing the value objects would
  work (as long as business rules are not sensitive).
- AJAX: This would work.
- WebSockets: Phoenix LiveView would probably work for this.

### Visible Implication

Visible Implication improves the effectiveness of visual review along
with Echo Back.

> Compute derived or redundant quantities implied by those already
> entered. Display the computed values in fields or cells along side
> those that are changed.
>
> Often there is a sense that some values are more fundamental than
> other, derived quantities. Other times the duplicate measurements
> are simply another way of looking at the thing.

For example:

```
    given quantity: 12
    and unit price: 6.50
    compute total: 78.00

    given quantity: 12
    and total: 72
    compute unit price: 6.00

    given unit price: 7.00
    and total: 77.00
    compute quantity: 11
```

On the code side:

> Write getters that try to compute missing values from other inputs.

```ruby
def unit_price
  @unit_price ? @unit_price : (@total / @quantity)
end

def total
  @unit_price ? (@total / @unit_price) : (@total / @quantity)
end
```

> Keep the domain model's implication logic simple. Also, do not try
> to encode field dependencies into the user interface. Instead simply
> refresh all fields when any one changes.

This is super important: always refresh all fields when any one
changes to avoid encoding dependencies into the UI.

> You can expect Meaningless Behavior whenever a thing is incompletely
> specified.
>
> Be sure all implications can be computed in a small fraction of a
> second. Longer calculations, or those unsafe to perform on partial
> specifications are best left to Instant Projection.

### Deferred Validation

> The Whole Values that quantify a domain model have been checked to
> ensure that they are recognizable values, may have been further
> edited for suitability by the domain model and have been Echoed Back
> to the user. All of these checks are immediate on entry. There is,
> however, a class of checking that should be deferred until the last
> possible moment.

Detailed validation of a form should be deferred until an action is
requested, and the extent of the validation should be tailored to the
specific action being requested. Assume the following scenario:

- The user can save incomplete work in a private location
- The user can finally post finished work

These 2 actions have different validation requirements. The first one
might not need validation at all. The second one certainly does.

When (deferred) validation is needed, the author recommends
making checks in passes and establishing dependencies between
different validations, from simple to complex.

> Write methods for your domain model that encode the anticipated use.

Does "anticipated use" mean "assume the basic values have already been
validated?

> Have these methods delegate to simpler validations before making
> their own checks. Checks should be made in passes so that the most
> specific problems are reported first. Check to make sure required
> quantities are present before checking that they and others are
> consistent.

And the code example for such a validation is:

```ruby
def validate_for_publication(notification_handler)
  validate_for_save(notification_handler)
  validate_for_computation(notification_handler)
  validate_variables_for_publication(notification_handler)
  validate_relations_for_publication(notification_handler)
end
```

Presumably, requirements for saving to a database are different than
requirements for "publication" (whatever that means). But before
publication, the "save validation" must succeed.

By looking at the code sample, I'm not sure how
`validate_for_computation` is skipped when `validate_for_save` doesn't
succeed. I assume it checks the notification handler with a guard
clause to make sure there aren't any notifications?

> Expect the individual validation methods to become complex and be
> subject to regular modification. As such, they may invoke systems
> designed specifically to validate business rules and restrictions.
> Check the obvious before delegating to these systems so that their
> rule bases are not polluted with trivial (but necessary) checks.

The author implies the existence of validation subsystems made out of
validator objects. More complex validations should work under the
assumption that the basic ones have already been figured out. Whole
Values, on the other hand, will handle lighter validations; as long as
the value isn't exceptional, we can make sure the Whole Value is
semantically valid and can be passed on to the validation system.
Presence validations can't be performed by Whole Value constructors,
so the first layer of validation should check for presence: by making
sure required values are not `BlankValue`.

> Deferred Validations are hurdles over which domain objects must pass
> on their way into the more public portions of a system. The system
> demands validation so that problems can be brought to the user's
> attention before publication. The user, on the other hand, may be
> aware of potential problems beyond those detectable by any strict
> validation.

I assume strict validation to be the ones performed by Whole Value
constructors, in case they return Exceptional Values that are turned
into blank by the UI.

### Instant Projection

I'm under the impression that this pattern is very specific to the
financial domain, even though it might be useful in other domains.

The goal of Echo Back and Visible Implication is to make sure
inconsistencies will be noticed. This pattern has the same goal. It
offers a projection window in the UI with no side-effects yielded to
the system.

> Now, as your user's attention shifts from entry to publication, you
> will want to carry further your prediction of that publication's
> impact.

This pattern is meant to make predictions with a likely chain of
events and carry expectations as to how things will probably work out
in the future. It further aids the ability of the user to fix any
mistakes before publication.

> Offer to project the consequences of any publication before that
> publication is actually made. You may require the entry of
> additional assumptions or offer alternatives in forecasting
> technique. Expect the interpretation of a projection to take some
> effort. Consider opening a "projection window" with various
> tabulations and summaries. Obsolete tabulations will be useful for
> observing parameter sensitivities.

I assume that Deferred Validations should be run before Instant
Projection.

### Hypothetical Publication

This is another very specific pattern that can be used when the
risks of publication are high. It's kind of like a "draft" that can be
released into the system in controlled ways by limiting their
distribution or marking them as "tentative", when forecasting tools
are available for published models.

Sometimes actions are definitive and can't be rolled back, so this
pattern is great to detect subtle inconsistencies. Also, when the
draft is released into the system, the user will have a chance to see
how it plays out with other data, and further access historical
information.

> When one publishes (or posts, or otherwise completes entry of)
> information, that information is expected to travel to many
> destinations. It may be difficult to assess the full impact of any
> piece of information out of context and independently of other, also
> questionable, data.

Within the context of a web application, there's no such worry as the
data traveling to many destinations because there will usually be a
central database.

Honestly, I can't find a good example of this pattern.

## Information integrity

In the context of financial software, these patterns are supposed to
deal with accounting integrity and questionable information.

### Forecast Confirmation

This is another specific pattern. Sometimes the system will
automatically generate data based on forecasts of events that can be
anticipated, for public use. When the event is finally confirmed, the
data must be adjusted.

> Provide a mechanism for adjusting and confirming values associated
> with mechanically published events.

```
    Thursday: we predict an automatic deposit of 187,655.47 for Friday
    Friday: we mechanically post 187,655.47 to the cash account
    Monday: bank records show 187,655.50 was deposited on Friday, we adjust accordingly
    Later: records for the month are closed showing no unusual activity
```

> What is important here is that the best information was available at
> every moment even though no one was technically accountable for the
> posting until after the fact. Forecast Confirmations look like
> original entries from the point of view of accounting integrity.

Finally, the author says that this pattern is only suitable for
"mechanically generated models", i.e., data that is generated
automatically by the system.

What's not 100% clear is whether Forecast Confirmation requires user
interaction or not. I'm assuming that if the confirmation can be
fetched automatically, it must be done so.

### Diagnostic Query

Yet another specific pattern suitable for the financial domain.

Whole Values and Exceptional Values are rich objects with information
that is sometimes omitted from the UI due to rounding and other
simplifications. This pattern suggests incorporating mechanisms for
the diagnostic tracing of every value in the system, such that it
renders tracking down a recording error unnecessary.

> Incorporate mechanisms for the diagnostic tracing of every value in
> the system. Make every display that rounds or summarizes offer the
> unprocessed values for inspection.

```
    Normal display:         67%
    Diagnostic display:     66.6454329

    Normal display:         652 MM USD EQV
    Diagnostic display:     622,456,325.07 USD + 3,624,878,450 JPY + 23,549.54 FRF
```

> Likewise, where rules and formulas have been applied, make these
> retrievable from the system itself and format them with variable
> names and the values bound in the particular calculation. Since the
> trace will ultimately lead to value entry, make sure you can report
> the date, time and identity of the source.

Where formulas are concerned, provide all the details leading up to a
result, including variable names, values, date, time, and identify of
the source.

> The correction of input errors offers another source for diagnostic
> information. Prior values and the time and identity of all sources
> should be available to diagnosis.

I suppose these diagnostic displays should be available both in forms
and visualizations.
