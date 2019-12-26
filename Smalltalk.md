# Pharo Smalltalk

This [cheatsheet](http://files.pharo.org/media/pharoCheatSheet.pdf) is immensenly useful.

## Basic syntax

Given the following Ruby code:

```ruby
class Person
  attr_reader :name

  def initialize(name, age)
    @name = name
    @age = age
  end

  def legal_age?
    @age >= 18
  end
end

person = Person.new('Thiago', 18)

puts "The name of the person is #{person.name}"

if person.legal_age?
  puts 'Person is of legal age'
else
  puts 'Person not yet of legal age'
end
```

The equivalent Pharo code would be:

```smalltalk
"Sending the subclass:instanceVariableNames:classVariableNames:package
message to Object creates the Person class. #Person is a symbol,
'name age' is a string. We could also have used the
shorter subclass:instanceVariableNames message.
In Smalltalk, statements end with dot."
Object subclass: #Person
    instanceVariableNames: 'name age'
    classVariableNames: ''
    package: 'User'.

"Create the name:age method. There is no return value,
so self (the Person instance) is returned by default."
Person>>name: aString age: anInteger
    name := aString.
    age := anInteger.

"Create the name method, which returns the name instance variable."
Person>>name
    ^name

"Create the isLegalAge method, which returns a boolean.
Of course, >= is a message send to the age integer."
Person>>isLegalAge
    ^age >= 18

"Create a person variable. Since name:age returns self, person
takes the Person object returned by new."
person := Person new name: 'Thiago' age: 17.

"Comma is a method used to concatenate strings.
(person name) returns the person name, which is then concatenated
to the preceding string. Semicolon is the "cascade" (in ST jargon) and
it forces the 'cr' message into the same object, 'Transcript'. Without it,
the 'cr' message would be sent to the 'name' string. cr prints a carriage
return."
Transcript show: 'The person name is ', person name; cr.

"(person isLegalAge) returns a boolean, then we send the ifFalse:ifTrue
message with two blocks that will be evaluated depending on the boolean's
value. Smalltalk has no if statements."
person isLegalAge
    ifTrue: [ Transcript show: 'Person is of legal age' ]
    ifFalse: [ Transcript show: 'Person not yet of legal age' ].
```

Ruby still has special syntax, but Smalltalk not so much. Mostly everything
in ST is a message send.

You can look at the output by going to Tools - Transcript. Or you can force
the window to open:

```smalltalk
"Or: (Transcript clear show: 'foo') open"
Transcript clear show: 'foo'; open
```

`Person>>meth` is a notation to indicate that what follows is the content
of the method `meth` in the class `Person`. It can't be evaluated with
the `Person>>` prefix. In practice, you will define a method through the
System Browser's UI, and the body of the method will be exactly the
same but without `Person>>` prefix. You could send the `compile:`
message though, which is what the UI seems to do behind the scenes:

```smalltalk
"Replace Person>> with the Person>>#compile: message and
you will be able to evaluate the code as a single chunk. The argument
to compile: is a string."
Person compile: 'name
    ^name'.
```

The notation for class methods is:

```smalltalk
Person class>>name: aString age: anInteger
    ^self new name: aString age: anInteger.

person := Person name: 'Thiago' age: 17.
person name. "Prints Thiago"
```

> Question: How to compile a class method?

### Some metaprogramming

You can grab a method reference with the `>>` or `methodNamed` message:

```smalltalk
"Or (Person methodNamed: #name)"
Person>>#name
```

And even execute the method through the `executeMethod` message:

```smalltalk
person := Person new name: 'Thiago' age: 18.
person executeMethod: Person>>#name. "Returns Thiago"
```

[Here's a great
post](https://medium.com/concerning-pharo/watch-method-calls-in-pharo-e75ce317193b)
about implementing a method proxy through the `methodDict` class
method.

### Types of messages

[There are three types of
messages](http://pharo.gforge.inria.fr/PBE1/PBE1ch5.html), _unary_,
_binary_, and _keyword_. `Person>>name` is a _unary_ message, while
`Person>>name:age` is a _keyword_ message. `1 + 2` is a binary message
send to `1`.

### Blocks

Block with no arguments:

```smalltalk
[ 'a value' ] value. "Returns 'a value'"
```

Block with up to 4 arguments:

```smalltalk
block := [ :arg1 :arg2 :arg3 :arg4 | arg1 + arg2 + arg3 + arg4 ].
block value: 1 value: 2 value: 3 value: 4. "Returns 10"
```

What about 5 arguments? It won't work. Blocks are instances of
`BlockClosure`, which implement four messages of interest: `value:`,
`value:value:`, `value:value:value:`, and `value:value:value:value:`.
If we try with 5 arguments, the block will compile, but it won't understand
`value:value:value:value:value:`. What do we do then? Send
`valueWithArguments` with an array argument.

```smalltalk
block := [ :arg1 :arg2 :arg3 :arg4 :arg5 :arg6 | arg1 + arg2 + arg3 + arg4 + arg5 + arg6 ].
block valueWithArguments: #(2 1 3 4 6 8). "Returns 24"
```

Returning from inside a block will return from the method:

```smalltalk
Person>>ageCategory
    age <= 12 ifTrue: [ ^#child ].
    age <= 18 ifTrue: [ ^#teenager ].
    age <= 60 ifTrue: [ ^#adult ].
    ^#elderly
```

Blocks with multiple statements are supported in Pharo:

```smalltalk
[
    a := 1.
    b := 2.
    a + b
] value.
```

In this example, however, variable bindings do leak and `a` and `b`
are visible outside of the block. That would also be true were the
block a single line of a single variable binding.
