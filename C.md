# C notes

## Pointers

**Asterisk**:

- When used on the left side of an assignment, it declares a variable
  of the "pointer" kind: `*x = y` (given y is already a pointer).
- When applied to an x pointer variable - like `*x` - it gets the
  actual value stored in the `x` pointer at that memory address.
- You can't do `*x` if `x` is not a pointer because `*` takes the
value of a pointer; if `x` is a variable, there will be an error.

**Ampersand**:

- Is used for grabbing a pointer to a variable. Example: `int
  *y_address = &y;`

```c
#include <stdio.h>

int main() {
  int x = 1;

  /* Grab a pointer to x */
  int *y = &x;

  /* print the value of the pointer, which is x itself */
  printf("%i", *y);

  return 0;
}
```

Another example:

```c
#include <stdio.h>

void pass_by_value(int x, int y) {
  x = x + 1;
  y = y + 1;
}

void pass_by_reference(int *x, int *y) {
  /* On a pointer variable, the asterisk accesses its value */
  /* The asterisk can also assign a new value to the variable's address */
  *x = *x + 1;
  *y = *y + 1;
}

int main() {
  /* These variables have a memory address */
  int x = 1, y = 2;

  /* Their memory address' value is a pointer to the memory address where
     their value is stored */
  int *x_address = &x;
  int *y_address = &y;

  printf("The size of the x pointer is: %lu bytes\n", sizeof(x_address));
  printf("The size of the y pointer is: %lu bytes\n", sizeof(y_address));

  printf("x address is %p\n", x_address);
  printf("y address is %p\n", y_address);

  int x_pointer_value = *x_address;
  int y_pointer_value = *y_address;

  printf("x pointer value is %i\n", x_pointer_value);
  printf("y pointer value is %i\n", y_pointer_value);

  pass_by_value(x, y);
  printf("Same values: %i, %i\n", x, y);

  pass_by_reference(&x, &y);
  printf("Incremented values: %i, %i", x, y);

  return 0;
}
```

## I/O functions

### fgets

`fgets(array, sizeof(buffer), stdin)` - takes the full size of
the string including the null terminator.

```c
#include <stdio.h>

int main() {
  /* How many slots do we need to store "abracadabra"? */
  /* 12, because the word's size is 11 + 1 null terminator */
  char thing[12];

  fgets(thing, 12, stdin);

  printf("%s", thing);
}
```

What if the size passed to `fget` exceeds the variable? It errors, so
it should be avoided.

### scanf

`scanf(format_string, ...)` - the format string captures the size of
the string NOT including the null terminator.

```c
#include <stdio.h>

int main() {
  int number;
  char thing1[22];
  char thing2[22];

  /* "thing" string has 1 char remaining for the null terminator. */
  /* the format string captures up until a space */
  /* "2 giant oranges" puts "giant" as thing1 and "oranges" as thing2 */
  scanf("%d %21s %21s", &number, thing1, thing2);

  printf("%d\n", number);
  puts(thing1);
  puts(thing2);
}
```

## The C Memory

- Stack
- Heap (dynamic memory)
- Globals
- Constants
- Code

## Strings and Arrays

Useful link: http://www.eskimo.com/~scs/cclass/notes/sx10f.html

Literal strings are stored within "constants", so you can't modify them:

```c
/* Compiles but doesn't run (bus error) */
char *str = "2 Bananas";
str[0] = '3';
```

The above var declaration works as:

1. The program loads the string into the constants area;
2. The program loads the string into the stack, which points at the
   read-only reference from constants.

For more security, declare the string as a constant:

```c
/* Does not even compile */
const char *str = "2 Bananas";
str[0] = '3';
```

If you wish to modify a string, declare it as an array:

```c
/* Stored as 10 chars including the null terminator */
char str[] = "2 Bananas";
str[0] = '3';
```

Now it will work as:

1. The program loads the string into the constants area,
2. The program copies the string into the stack. The copy can then be
   modified.

It all boils down to how C manages the memory. In the compiled
program, array declarations vanish and get replaced with their memory
addresses.

The distinction between pointer and array is confusing. At the
function parameter level, pointers and arrays are the same thing:

```c
/* Both things are the same thing: pointers */
void foo(char thing[])
void foo(char *thing)
```

Now, an array is a direct pointer to the memory address of the first
element.

```c
#include <stdio.h>

/* The array decays to a pointer */
void pass_pointer(char str[]) {
  /* Throws a warning regarding "sizeof":

     warning: sizeof on array function parameter will return size of
     'const char *' instead of 'const char []'

     ... and prints the size of the pointer: 8 bytes. The function
     signature could be written as "void pass_pointer(char *str)",
     which makes the warning disappear. We could keep the char str[]
     signature and use strlen for the warning to disappear. However,
     this warning is not completely clear to me because the parameter
     is compiled into a pointer. */
  printf("%lu\n", sizeof(str));

  /* This will still work because printf is smart enough to understand */
  printf("%s", str);
}

int main() {
  /* Each char is stored in a byte memory slot */
  /* C implicitly puts a null terminator char: \0 */
  char str[] = "One two three";

  /* Declares a literal integer array in contiguous memory buckets */
  int nums[] = {1, 2, 3, 4};

  /* Outputs 14, the size of the array. "lu" is unsigned long */
  /* The string size is 13 + 1 slot for the null terminator */
  printf("%lu\n", sizeof(str));

  /* Prints the third number */
  printf("%i\n", nums[2]);

  /* Still prints the third number */
  printf("%i\n", 2[nums]);

  /* Still prints the third number */
  printf("%i\n", *(2 + nums));

  /* Prints the whole string, char by char until reaching the
     null terminator: \0 */
  printf("%s\n", str);

  pass_pointer(str);

  return 0;
}
```

"str" is saved as a constant and then copied into the stack, so that
it can be modified.

For the following code:

```c
char s[] = "Some string";
char *p = s;
```

We have the following properties:

```c
/*
 * Both the array's address and the array itself point to...
 * the first element's address.
 */
&s == s

/*
 * The address pointer in memory is different from
 * the first element's location
 */
&p != p
```

### Array of strings

It's essentially the same thing as above:

```c
#include <stdio.h>

int main() {
  char *fruits_1[] = {"Banana", "Apple"};
  char fruits_2[][10] = {"Banana", "Apple"};

  /* Can't be modified (bus error). Declare the array as
     const to get a compile-time error! */
  /* fruits_1[0][0] = 'D'; */

  /* Can be modified because the strings are copied
     into the stack from the constants area when declaring
     the array */
  fruits_2[0][0] = 'C';

  puts(fruits_1[0]);
  puts(fruits_2[0]);
}
```

### Functions returning strings (pointers)

In C, we can't return a pointer to a variable allocated inside a
running function. For example, this is invalid code:

```c
#include <stdio.h>
#include <string.h>

char * reverse(char *orig) {
  int len = strlen(orig);
  char *chr = orig + len - 1;
  char dest[len];
  int i = 0;

  while(chr >= orig) {
    dest[i] = *chr;
    chr--;
    i++;
  }

  dest[i] = '\0';

  /* The dest pointer is defined inside the function */
  /* Warning: address of stack memory associated with local variable
     'dest' returned */
  return dest;
}

int main() {
  /* Compiles, but prints nothing because the variable falls out of
     scope when the stack pops off */
  puts(reverse("foo"));
}
```

What if it's an integer?

```c
#include <stdio.h>

int new_int() {
  int i = 5;
  return i;
}

int main() {
  printf("%i", new_int());
}
```

It works fine because we're not dealing with a pointer. We're dealing
with a value.

The right code for the `reverse` function would be:

```c
#include <stdio.h>
#include <string.h>

char * reverse(char *orig, char *dest) {
  char *chr = orig + strlen(orig) - 1;
  int i = 0;

  while(chr >= orig) {
    dest[i] = *chr;
    chr--;
    i++;
  }

  dest[i] = '\0';
  return dest;
}

int main() {
  /* Allocation should happen in the calling function */
  /* and the value should be passed by reference */
  char str[2];
  puts(reverse("foo", str));
}
```

## Files

A file is a pointer and can be used similarly to streams such as
`stdin` or `stdout`. Here's a very basic program to create a file:

```c
#include <stdio.h>

int main() {
  FILE *file = fopen("file.txt", "w");

  fprintf(file, "line %i\n", 1);
  fprintf(file, "line %i\n", 2);
}
```

`fprintf` is the low-level version of `printf` and takes a stream as
the first argument. `printf`, of course, implicitly takes `stdout`.

The consequence is that we can also read a file with `fscanf`, the
sibling of `scanf`:

```c
#include <stdio.h>

int main() {
  /* w+ opens the file for both read and write, and
     creates it if it doesn't exist */
  FILE *file = fopen("file.txt", "w+");
  char line[7];

  fprintf(file, "line %i\n", 1);
  fprintf(file, "line %i\n", 2);

  rewind(file);

  while(fscanf(file, "%7[^\n]\n", line) == 1) {
    puts(line);
  }
}
```

How could this program _not_ work? With either of these LOC:

- `char line[6]`: Would print just "line 1". Not enough chars to
  include the new line, which would make the second call to `fscanf`
  return 0.
- `while(fscanf(file, "%7[^\n]", line) == 1) {`: Would print just
  "line 1" because the string pattern must end with `\n`, like this
  `%7[^\n]\n`
-  `FILE *file = fopen("file.txt", "r");`: Would segfault before
writing to the file.
-  `FILE *file = fopen("file.txt", "w");`: Would finish successfully
but wouldn't print anything.

**NOTE**: `rw` mode doesn't seem to be a valid mode. It opens the file
only if it exists, otherwise it segfaults. If it manages to open the
file, then writes won't work; only reads will. See available modes in [this
link](https://www.programiz.com/c-programming/c-file-input-output).

Here's a more complete example with good practices:

```c
#include <stdlib.h>
#include <stdio.h>

int main() {
  FILE *file;
  char line[7];

  file = fopen("files.txt", "r");

  /* Is the file open? */
  if (file == NULL) {
    puts("Error!");
    exit(1);
  }

  while(fscanf(file, "%7[^\n]\n", line) == 1) {
    puts(line);
  }

  /* Close the file */
  fclose(file);
}
```

## Parsing command line options

```c
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
  char *name, *gender, ch;

  /* getopt will return either a char or EOF */
  while((ch = getopt(argc, argv, "n:mf")) != EOF) {
    switch(ch) {
    case 'n':
      name = optarg;
      break;
    case 'm':
      gender = "male";
      break;
    case 'f':
      gender = "female";
      break;
    default:
      fprintf(stderr, "Invalid option: '%s'\n", optarg);
      return 1;
    }
  }

  if(name == NULL) {
    puts("Please, give a name with -n");
    exit(1);
  }

  if(gender == NULL) {
    puts("Please, give a gender with either -m or -f");
    exit(1);
  }

  printf("Hi %s! You are a %s\n", name, gender);
}
```

Example:

```sh
$ ./prog -n Thiago -m
Hi Thiago! You are a male
```

Noteworthy:

- `optarg` is created by `getopt` as a local variable to the current
  function.
- When a command line option has an argument, use a colon after the
option (hence `n:`).
- To assign a string to a variable at a later time, use a pointer
  variable. An array won't work, even though it has the same behavior
  as a pointer. Error: `array type 'char [N]' is not assignable`,
  where N is the array's length.

What if we want to use the remaining arguments? Then we have to shift them off the arguments:

```c
#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>

int main(int argc, char *argv[]) {
  char *name, *gender, ch;
  int count;

  while((ch = getopt(argc, argv, "n:mf")) != EOF) {
    switch(ch) {
    case 'n':
      name = optarg;
      break;
    case 'm':
      gender = "male";
      break;
    case 'f':
      gender = "female";
      break;
    default:
      fprintf(stderr, "Invalid option: '%s'\n", optarg);
      return 1;
    }

    printf("%c", argc);
  }

  /* optind is also created by getopt */
  argc -= optind;
  argv += optind;

  if(name == NULL) {
    puts("Please, give a name with -n");
    exit(1);
  }

  if(gender == NULL) {
    puts("Please, give a gender with either -m or -f");
    exit(1);
  }

  printf("Hi %s! You are a %s\n", name, gender);

  for(count = 0; count < argc; count++) {
    printf("Oh, is %s your friend?\n", argv[count]);
  }
}
```

Example:

```sh
$ ./prog -m -n Thiago Alice
Hi Thiago! You are a male
Oh, is Alice your friend?
```

## Types

A few integer types:

- `short`
- `int`
- `long`
- `long long`
- `char`

A few numeric types:

- `float`
- `double` (better precision and capacity)

## Headers

In C, a function definition must be declared _before_ the function
that contains the function reference. When C doesn't know about a function
(when it's not declared up to a point), it will assume that:

- The function will be declared later;
- Its return type is `int` (errors like "type mismatch" or
  "conflicting type" can happen when functions are out of order).

Header files (`.h`) exempt programmers from explicitly ordering their
functions.

```c
/* reverse.h */
char *reverse(char *orig, char *dest);
```

```c
/* main.c */
#include <stdio.h>
#include <string.h>
#include "reverse.h"

int main() {
  char str[2];
  puts(reverse("foo", str));
}

char *reverse(char *orig, char *dest) {
  char *chr = orig + strlen(orig) - 1;
  int i = 0;

  while(chr >= orig) {
    dest[i] = *chr;
    chr--;
    i++;
  }

  dest[i] = '\0';
  return dest;
}
```

- Because of our header file, `reverse` can now be declared after
  `main`.
- `#include "reverse.h"` is a relative preprocessor include. It will
look for `reverse.h` in the current directory, while `<file.h>` will look
for `file.h` in standard directories.
- `#include` will insert the file contents as if it had been written
to the same source file.

We can also split the `reverse` function out into its own file:

```c
/* main.c */
#include <stdio.h>
#include "reverse.h"

int main() {
  char str[2];
  puts(reverse("foo", str));
}
```

```c
/* reverse.h */
char *reverse(char *orig, char *dest);
```

```c
/* reverse.c */
#include <string.h>

char *reverse(char *orig, char *dest) {
  char *chr = orig + strlen(orig) - 1;
  int i = 0;

  while(chr >= orig) {
    dest[i] = *chr;
    chr--;
    i++;
  }

  dest[i] = '\0';
  return dest;
}
```

We could compile the program with the following command:

```bash
$ gcc main.c reverse.c -o reverse
```

Or we could create an object file with the output of the compilation
phase for the respective source file:

```bash
$ gcc -c reverse.c
$ ls reverse.o
reverse.o
```

The `-c` flag means "just compile, don't link".

> An object file is the real output from the compilation phase. It's
> mostly machine code, but has info that allows a linker to see what
> symbols are in it as well as symbols it requires in order to work.
> (For reference, "symbols" are basically names of global objects,
> functions, etc.)

We can link the final executable with a mix of C and O files:

```bash
$ gcc main.c reverse.o -o reverse
```

Or purely with O files:

```bash
$ gcc -c main.c
$ gcc main.o reverse.o -o reverse
```

## Structs, Unions, and Enums

### Structs

Declaring and using a struct:

```c
#include <stdio.h>

struct person_likes {
  const char *favorite_food;
  const char *favorite_language;
};

struct person {
  const char *first_name;
  const char *last_name;
  int height;
  int age;
  struct person_likes likes;
};

// The struct gets copied over
void print_person_info(struct person p) {
  printf("%s %s, %i years, height %i\n", p.first_name, p.last_name, p.age, p.height);
  printf("Favorite food: %s", p.likes.favorite_food);
  printf("Favorite language: %s", p.likes.favorite_language);
}

int main() {
  struct person thiago = {"Thiago", "Silva", 70, 18, {"Vegan", "Clojure"}};
  print_person_info(thiago);
}
```

Give the struct a type with `typedef`:

```c
#include <stdio.h>

// it is possible to omit the struct name (person) and only declare the type below
typedef struct person {
  const char *first_name;
  const char *last_name;
} struct_alias; // alias (type) can have the same name as the struct

void print_person_info(struct_alias p) {
  printf("%s %s\n", p.first_name, p.last_name);
}

int main() {
  // can declare the type with either the alias or the struct itself
  struct_alias thiago = {"Thiago", "Silva"};
  struct person other = {"Fulano", ""};

  print_person_info(thiago);
  print_person_info(other);
}
```

Data is stored in the same order as it's declared, in chunks of 64
bits (depends on computer architecture). It will try to fit several
fields into a single word, but sometimes there will be gaps to avoid
fields from being split over word boundaries.

**In C, all assignments copy data, unless you use a pointer. Parameters are passed by value.**

The `print_person_info` function will clone the struct argument and
drop it when the function finishes, so if we reassign a member, like
`p.first_name = "Other";`, it won't modify the original struct.
Therefore, we must do this:

```c
// Only works with parentheses! *p.first_name would be
// the same as `(*p.first_name)`, whereas (*p).first_name
// would be correct. The dot operator is evaluated before *.
void print_person_info(struct_alias *p) {
  (*p).first_name = "Other";
  printf("%s %s\n", (*p).first_name, (*p).last_name);
}
```

Instead of this:

```c
void print_person_info(struct_alias p) {
  // Does not modify original!
  p.first_name = "Other";
  printf("%s %s\n", p.first_name, p.last_name);
}
```

Let's do a super weird modification to `print_person_info` just to prove a point:

```c
#include <stdio.h>

// it is possible to omit the struct name (person) and only declare the type below
typedef struct person {
  const char *first_name;
  const char *last_name;
} struct_alias; // alias (type) can have the same name as the struct

void print_person_info(struct_alias *p) {
  p->first_name = "Other";
  printf("%s %s\n", p->first_name, p->last_name);
}

int main() {
  // can declare the type with either the alias or the struct itself
  struct_alias thiago = {"Thiago", "Silva"};
  struct person other = {"Fulano", ""};

  print_person_info(&thiago);
  print_person_info(&other);
}
```

Note the `->` syntax, where `p->first_name = "Other";` is a more
readable shortcut to `(*p).first_name = "Other";`

Nested struct access goes like this:

```c
#include <stdio.h>

// Read declarations bottom-up

typedef struct {
  // Finally, this is a string pointer.
  const char *element;
} one;

typedef struct {
  // This is a pointer
  one *element;
} two;

typedef struct {
  // This is not a pointer, so the value gets copied over into "element"
  two element;
} three;

int main() {
  one number_one = {"Here I am!"};
  two number_two = {&number_one};

  // Number two gets copied over into number_three.element
  three number_three = {number_two};

  printf("Where am I? %s\n", number_three.element.element->element);
}
```

If `three` had a pointer `element`, nested access would work like this:

```c
#include <stdio.h>

typedef struct {
  const char *element;
} one;

typedef struct {
  one *element;
} two;

typedef struct {
  // This is now a pointer
  two *element;
} three;

int main() {
  one number_one = {"Here I am!"};
  two number_two = {&number_one};

  // Now we'll pass in the number_two's address. No copy happens here.
  three number_three = {&number_two};

  printf("Where am I? %s\n", number_three.element->element->element);
}
```

And there's a much better way to initialize a struct. Analog to
keyword arguments, it is called "designated initializer":

```c
#include <stdio.h>

typedef struct {
  const char *element;
} one;

typedef struct {
  one *element;
} two;

typedef struct {
  two *element;
} three;

int main() {
  // Uuuh! Much better
  // To declare more than one member, use comma
  one number_one = {.element="Here I am!"};
  two number_two = {.element=&number_one};
  three number_three = {.element=&number_two};

  printf("Where am I? %s\n", number_three.element->element->element);
}
```

### Unions and Enums

A union allows you to store one value with one of several different
data types in the same memory location. They are similar to structs,
but there will only ever be one piece of data stored.

```c
#include <stdio.h>

// - Looks like a struct, but it uses the "union" keyword
// - float takes 4 bytes and short takes 2 bytes; the union will be 4 bytes long.
typedef union {
  short count;  // Count oranges
  float weight; // Weigh grapes
  float volume; // Measure juice
} quantity;

int main() {
  quantity q1 = {5};
  quantity q2 = {.weight=7.5};
  quantity q3;

  q3.volume = 5.1;

  printf("What's the count? %i oranges\n", q1.count);
  printf("What's the weight of the grapes? %fkg\n", q2.weight);
  printf("What's the volume of the juice? %fl\n", q3.volume);
}
```

Using unions with structs:

```c
#include <stdio.h>

typedef union {
  short count;
  float weight;
  float volume;
} quantity;

typedef struct {
  const char *name;
  const char *country;
  quantity amount;
} order;

int main() {
  // Declare all at once!
  order apples = {"apples", "Brazil", .amount.weight=4.2};
  printf("This order contains %2.2f lbs of %s\n", apples.amount.weight, apples.name);
}
```

What if `quantity` were a pointer? Then the declaration syntax would
be more verbose [with a compound
literal](http://nickdesaulniers.github.io/blog/2013/07/25/designated-initialization-with-pointers-in-c/):

```c
#include <stdio.h>

typedef union {
  short count;
  float weight;
  float volume;
} quantity;

typedef struct {
  const char *name;
  const char *country;
  quantity *amount;
} order;

int main() {
  // More verbose
  order apples = {"apples", "Brazil", .amount=&((quantity) {.weight=5})};
  printf("This order contains %2.2f lbs of %s\n", apples.amount->weight, apples.name);
}
```

There are some important subtleties to be aware of, for example:

```c
order o;
o = {"apples", "Brazil", .amount=&((quantity) {.weight=5})};
```

This line does not compile because the compiler will think it's an
array. When declared on the same line, however, the compiler can infer
the type.

It's a good practice to tag a union with an enum when used with
structs because referencing unused union fields seem to be undefined
behavior:

```c
#include <stdio.h>

typedef enum {
  EARNING, ADJUSTMENT
} ledger_type;

typedef union {
  int sale_id;
  const char *adjustment_type;
} ledger_id;

typedef struct {
  ledger_type type;
  ledger_id id;
  int amount;
} ledger_record;

void print_ledger(ledger_record record) {
  if(record.type == EARNING) {
    printf("Earning with sale id %i cents\n", record.id.sale_id);
  }
  else if(record.type == ADJUSTMENT) {
    printf("Adjustment with type %s\n", record.id.adjustment_type);
  }

  printf("Amount: %i cents\n", record.amount);
  puts("--------------------");
}

int main() {
  ledger_record record1 = {.type=EARNING, .id.sale_id=5, .amount=10000};
  ledger_record record2 = {.type=ADJUSTMENT, .id.adjustment_type="Other", .amount=5000};

  print_ledger(record1);
  print_ledger(record2);
}
```

Enums can also be declared "ad-hoc", without `typedef`:

```c
enum colors {BLACK, WHITE, BLUE};
enum color favorite = BLUE;
```

At a super basic level, how do enums work internally? They store
numbers behind the scenes for each item.

### Structs with Bitfields

```c
typedef struct {
  short salad;
  short fruits;
} side_dishes;
```

What's the problem this struct? We want boolean-like flags but each
`short` takes up many bits.

> C doesn't support binary literals, but it does support hexadecimal
> literals like `int x = 0x54;`. Each hexa number can be converted to
> its binary counterpart, matching a binary digit of length 4: (0101
> 0100).

Here's how we fix this struct:

```c
#include <stdio.h>

typedef struct {
  // bitfields should be declared as unsigned int
  unsigned int salad:1;
  unsigned int fruits:1;
} side_dishes;

int main() {
  side_dishes extras = {.fruits=0, .salad=1};

  if(extras.fruits) {
    puts("Great, you've asked for fruits!");
  }
  else {
    puts("Great, you've asked for salad!");
  }
}
```

Unfortunately, that only seems to work with structs because the
computer can squash the fields together to save space. This doesn't compile:

```c
unsigned int foo:1 = 2;
```

We can also have a higher number of bits. For storing months, for
example, we'd need 4 bits because 4 bits can store 0-15 while while 3
bits can store 0-7.
