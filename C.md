# C notes

## Pointers

**Asterisk**:

- When used on the left side of the assignment, it declares a pointer
  variable. For example: `type *x = y` (given that y is already a
  pointer of the `type` type).
- When applied to an `x` pointer variable as `*x`, it gets the value
  stored at that memory address.
- You can't do `*x` with a normal variable because `*` is used to
  fetch the value of a pointer, and normal variables are not
  pointers. There will be an error in that case.

**Ampersand**:

- Ampersand is used for grabbing a pointer to a variable, i.e., a
  handle to the memory address where that variable is stored (whether
  the variable is stored in the stack, heap, constants, etc, is
  another story.) Example: `int *y_address = &y;`

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

`fgets(array, sizeof(buffer), stdin)` - Takes the full length of the
string including the null terminator.

```c
#include <stdio.h>

int main() {
  /* How many slots do we need for "abracadabra"? */
  /* 12, because the word's size is 11 + 1 null terminator */
  char thing[12];

  fgets(thing, 12, stdin);

  printf("%s", thing);
}
```

What if the size passed to `fgets` exceeds the size of the variable?
It errors, so it should be avoided.

### scanf

`scanf(format_string, ...)` - The format string captures the length of
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

## Operators

- `^` - XOR operator

        #include <stdio.h>

        int main() {
          // 1000001 XOR 0011111 = 1011110 (94)
          printf("%i", ('A' ^ 31)); // 94
          printf("%i", ('A' ^ 31) ^ 31); // 65 (example of XOR encryption)
        }


# The C Memory

- Stack
- Heap (dynamic memory)
- Globals
- Constants
- Code

## Strings and Arrays

Here's an [useful link](http://www.eskimo.com/~scs/cclass/notes/sx10f.html).

Literal strings are stored in the constants area, so you can't modify
them:

```c
/* Compiles but doesn't run (bus error) */
char *str = "2 Bananas";
str[0] = '3';
```

1. The program loads the string into the constants area;
2. The program allocates a pointer to the read-only reference from the
   constants area.

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
2. The program _allocates_ a modifiable copy of the string into the
   stack.

It all boils down to how C manages memory. Within the compiled
program, array declarations vanish and are replaced with their memory
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

In C, we can't return a pointer to a variable allocated inside the
stack. For example, this is invalid code:

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

## Headers, Object Files, Archives, and Dynamic Linking

### Headers and Object Files

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
for `file.h` in standard directories (`/usr/local/include`, `/usr/include` and so on).
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

Where to find header files? How to link them?

- In a standard directory: `#include <file.h>`
- Full pathname in include statement: `#include "/my/path/file.h"`
- Tell the compiler where to find them: `gcc -I/my/path file.c -o file`
- Include full path name of object files when linking: `gcc -I/my/path file.c /path/to/file1.o /path/to/file1.o -o file`

### Archives

Archive files are libraries that contain object files.

```sh
$ cd /usr/local/lib
$ ar -t libcares.a
__.SYMDEF SORTED
libcares_la-ares__close_sockets.o
libcares_la-ares__get_hostent.o
libcares_la-ares__read_line.o
libcares_la-ares__timeval.o
libcares_la-ares_android.o
libcares_la-ares_cancel.o
...
$ nm libcares.a

libcares.a(libcares_la-ares__close_sockets.o):
0000000000000000 T _ares__close_sockets
                 U _ares__socket_close
                 U _ares_free

libcares.a(libcares_la-ares__get_hostent.o):
                 U __DefaultRuneLocale
                 U ___bzero
                 U ___maskrune
                 U ___stack_chk_fail
                 U ___stack_chk_guard
0000000000000000 T _ares__get_hostent
                 U _ares__read_line
                 U _ares_free
                 U _ares_inet_pton
                 U _ares_malloc
                 U _ares_strdup
                 U _aresx_sitoss
                 U _aresx_uztoss
                 U _inet_addr

...
```

- `ar -t` to list the objects of an archive
- `nm` to detail the contents
- Among other files, this archive contains
  `libcares_la-ares__close_sockets.o` and
  `libcares_la-ares__get_hostent.o`;
- `ares__close_sockets` is a functio within
  `libcares_la-ares__close_sockets.o`. Anything prefixed with `T _` is
  a function.
- An archive file must be prefixed with `lib` because they are static
libraries;
- To extract a single object: `ar -x libcares.a libcares_la-ares__close_sockets.o`

To create a new archive we can do:

```sh
# -r: Update the file if it already exists
# -c: Create the archive silently
# -s: Create an index at the start of the .a file
$ ar -rcs libmyarchive.a file1.o file2.o
```

- Put the `.a` file in a standard directory like `/usr/local/lib` and `/usr/lib`
- Put it in your own library directory

To compile a file and link it statically to the archive:

```sh
$ gcc file.c -lmyarchive -o file
```

- `-lmyarchive` will look for libmyarchive.a
- Set several `-l` options if necessary
- Specify archive search directories with `-L`: `-L/my_dir`. Should
  appear after the source files.
- Pair it with an `-I` option if headers are not in standard directories

A common example:

```sh
$ gcc file.c -I. -L. -lmyarchive -o file
```

### Building a statically linked program from parts

Example:

```c
# -c: create the object file but don't link it
$ gcc -I./includes -c lib.c -o lib.o
$ gcc -I./includes -c exec.c -o exec.o
$ ar -rcs ./libs/libmyarchive.a lib1.o
$ gcc exec.o -L./libs -lhfmyarchive -o exec
$ ./exec
```

### Dynamic linking

- An archive file is built from several `.o` files;
- A dynamic library has `.o` files linked together into a single
  object;
- Linking to dynamic library happens at runtime
- The dynamic library contains extra information needed for linking

```c
$ gcc -I/includes -fPIC -c mylib.c -o mylib.o
$ gcc -shared mylib.o -o libs/libmylib.so
$ gcc -I./include -c exec.c -o exec.o
$ gcc exec.o -L./libs -lmylib -o exec
```

- `-fPIC` is unnecessary on most systems. It tells `gcc` to create
  position-independent code in order for the OS to decide at runtime
  where they want to load it into memory;
- The command with `-shared` asks the OS to convert the object into a
  dynamic library;
- Dynamic library extensions change depending on platform:
    - Linux: `libmylib.so`
    - Mac: `libmylib.dylib`
    - Windows: `mylib.dll`
- You can't rename a dynamic library file because the library name is
recorded into the dynamic library itself;
- From half onward, there are basically the same commands as static
  linking with archive files, but it will work differently because the
  `lib` file is not an archive; it is a dynamic library;
- The library code won't be stored in the executable file.
- On the Mac, the full path to `/libs/libmylib.dylib` will be stored
in the executable file;
- On Linux, the executable file will hold just `libmylib.so`, so it
needs to be in standard `lib` directories. An alternative is to use
the `LD_LIBRARY_PATH` env variable.

The advantage of dynamic linking is that you can link to different
libraries at runtime, as long as they follow the same interface.

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

## Data Structures / Dynamic Memory

Here's a [good
link](https://www.geeksforgeeks.org/dynamic-memory-allocation-in-c-using-malloc-calloc-free-and-realloc/)
about dynamic memory allocation.

[Why is calloc slower than
malloc?](https://www.quora.com/Is-calloc-really-slower-than-malloc-because-it-initializes-memory-to-0-initialization-takes-time-whereas-malloc-doesnt-Is-the-performance-difference-between-these-2-functions-significant)

### Linked lists

Arrays are fixed-size. How to implement a "dynamic array" in C? With
a linked list.

Here's the code for a simple linked list:

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct ll_node {
  char *contents;
  struct ll_node *next;
} ll_node;

ll_node *create_node(const char *contents) {
  ll_node *node = malloc(sizeof(ll_node));

  node->contents = strdup(contents);
  node->next = NULL;

  return node;
}

ll_node *create_list() {
  char contents[80];
  ll_node *root = NULL;
  ll_node *prev = NULL;

  while (fgets(contents, 80, stdin) != NULL) {
    contents[strlen(contents) - 1] = '\0'; // Strip off new line
    ll_node *node = create_node(contents);

    if (root == NULL) root = node;
    if (prev != NULL) prev->next = node;

    prev = node;
  }

  return root;
}

void print_list(ll_node *node) {
  for (; node != NULL; node = node->next) {
    puts(node->contents);
  }

  puts("");
}

ll_node *insert_node(ll_node *root, ll_node *node) {
  if (root == NULL)
    return NULL;

  node->next = root;

  return node;
}

void free_list(ll_node *node) {
  if (node == NULL)
    return;

  if (node->next)
    free_list(node->next);

  free(node->contents);
  free(node);
}

int main() {
  ll_node *root = create_list();

  print_list(root);

  root = insert_node(root, create_node("Zero"));
  root = insert_node(root, create_node("Minus One"));

  print_list(root);

  free_list(root);
}
```

Assume the following `file.txt`:

```
One
Two
Three
Four
Five
```

And the command:

```sh
$ ./linked_list < file.txt
```

Some notes:

- We're using dynamic heap allocation with `malloc`and `free`.
  Remember: the stack drops allocated variables after a function returns;
- `malloc` returns a general-purpose pointer with type `void*`;
- The struct is recursive. The only way to declare a recursive struct
  is with a `struct ll_node *next` field; Just `ll_node *next` (with
  type instead of struct name) won't work;
- The `next` field must be a pointer; it can't be a copy of the struct
  because C must know the quantity of memory beforehand;
- When collecting input with a single temporary string variable,
 `strdup` is necessary because otherwise all strings would be the same
 and point at the same memory address;
- Depending on the C implementation, `strdup` will allocate heap
  memory. Therefore, you must remember to free it up;
- You could connect nodes manually with something like:

        ll_node *node1 = create_node("One");
        ll_node *node2 = create_node("Two");
        node1->next = &node2;

- Always initialize empty pointers to `NULL`, otherwise C will point
  at memory garbage.

A subtle memory leak may occur in the following operation:

```c
ll_node *replace_node(ll_node *node, ll_node *new_node, int pos) {
  int i = 0;

  ll_node *prev = NULL;
  ll_node *root = node;

  for (; node != NULL; node = node->next) {
    if (i == pos) {
      if (prev == NULL) {
        root = new_node;
      }
      else {
        prev->next = new_node;
      }

      new_node->next = node->next;
      break;
    }

    prev = node;
    i++;
  }

  return root;
}

int main() {
  ll_node *root = create_list();

  print_list(root);

  root = insert_node(root, create_node("Zero"));
  root = insert_node(root, create_node("Minus One"));

  print_list(root);

  root = replace_node(root, create_node("Replacement"), 1);

  print_list(root);

  free_list(root);
}
```

If we run valgrind, which intercepts calls to `malloc` and `free`, it indeed shows a problem:

```sh
==25463==
==25463== HEAP SUMMARY:
==25463==     in use at exit: 27,725 bytes in 172 blocks
==25463==   total heap usage: 207 allocs, 35 frees, 36,331 bytes allocated
==25463==
==25463== 21 (16 direct, 5 indirect) bytes in 1 blocks are definitely lost in loss record 5 of 47
==25463==    at 0x1000D5CF5: malloc (in /usr/local/Cellar/valgrind/HEAD-fc32b97/lib/valgrind/vgpreload_memcheck-amd64-darwin.so)
==25463==    by 0x100000B7A: create_node (linked_list.c:11)
==25463==    by 0x100000E90: main (linked_list.c:101)
==25463==
==25463== 48 bytes in 2 blocks are possibly lost in loss record 22 of 47
==25463==    at 0x1000D6350: calloc (in /usr/local/Cellar/valgrind/HEAD-fc32b97/lib/valgrind/vgpreload_memcheck-amd64-darwin.so)
==25463==    by 0x1005DE742: map_images_nolock (in /usr/lib/libobjc.A.dylib)
==25463==    by 0x1005F155F: __objc_personality_v0 (in /usr/lib/libobjc.A.dylib)
==25463==    by 0x10000847A: dyld::notifyBatchPartial(dyld_image_states, bool, char const* (*)(dyld_image_states, unsigned int, dyld_image_info const*), bool, bool) (in /usr/lib/dyld)
==25463==    by 0x10000862D: dyld::registerObjCNotifiers(void (*)(unsigned int, char const* const*, mach_header const* const*), void (*)(char const*, mach_header const*), void (*)(char const*, mach_header const*)) (in /usr/lib/dyld)
==25463==    by 0x100239A26: _dyld_objc_notify_register (in /usr/lib/system/libdyld.dylib)
==25463==    by 0x1005DE233: environ_init (in /usr/lib/libobjc.A.dylib)
==25463==    by 0x1001D0E35: _os_object_init (in /usr/lib/system/libdispatch.dylib)
==25463==    by 0x1001DCAD1: libdispatch_init (in /usr/lib/system/libdispatch.dylib)
==25463==    by 0x1000E09C4: libSystem_initializer (in /usr/lib/libSystem.B.dylib)
==25463==    by 0x10001B591: ImageLoaderMachO::doModInitFunctions(ImageLoader::LinkContext const&) (in /usr/lib/dyld)
==25463==    by 0x10001B797: ImageLoaderMachO::doInitialization(ImageLoader::LinkContext const&) (in /usr/lib/dyld)
==25463==
==25463== LEAK SUMMARY:
==25463==    definitely lost: 16 bytes in 1 blocks
==25463==    indirectly lost: 5 bytes in 1 blocks
==25463==      possibly lost: 48 bytes in 2 blocks
==25463==    still reachable: 8,392 bytes in 8 blocks
==25463==         suppressed: 19,264 bytes in 160 blocks
==25463== Reachable blocks (those to which a pointer was found) are not shown.
==25463== To see them, rerun with: --leak-check=full --show-leak-kinds=all
```

Note the debug info with the line numbers at the top; If the
executable is compiled with the `-g` flag, Valgrind will tell which
lines in the source code put the problematic data on the heap. Also
note "definitely lost".

What's the problem with `replace_node`? It replaces a node but it does
not free up the replaced node. To fix let's break up `free_list`:

```c
void free_node(ll_node *node) {
  if (node == NULL)
    return;

  free(node->contents);
  free(node);
}

void free_list(ll_node *node) {
  if (node != NULL && node->next)
    free_list(node->next);

  free_node(node);
}
```

Now we add the code to free up the replaced node:

```c
ll_node *replace_node(ll_node *node, ll_node *new_node, int pos) {
  int i = 0;

  ll_node *prev = NULL;
  ll_node *root = node;

  for (; node != NULL; node = node->next) {
    if (i == pos) {
      if (prev == NULL) {
        root = new_node;
      }
      else {
        prev->next = new_node;
      }

      new_node->next = node->next;
      free_node(node); // This!
      break;
    }

    prev = node;
    i++;
  }

  return root;
}
```

### Other data structures

Among others, you can build the following data structures using structs:

- Doubly linked list (with recursive structs)
- Binary tree (with recursive structs)
- Hash map (requires other data structures such as arrays)

## Function pointers

We want to make a generic function to iterate over a linked list. We
can use a function pointer, which is always declared along with its
return type and argument types. Every function name is a pointer to a
function.

The notation for a function pointer is:

```
return_type (* name_of_new_var)(...parameter_types)
```

Here's an example:


```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

typedef struct ll_node {
  char *contents;
  struct ll_node *next;
} ll_node;

ll_node *create_node(const char *contents) {
  ll_node *node = malloc(sizeof(ll_node));

  node->contents = strdup(contents);
  node->next = NULL;

  return node;
}

// Takes a function pointer as the last argument
void walk_list(ll_node *node, void (*action)(ll_node*)) {
  for (; node != NULL; node = node->next) {
    action(node); // (*action)(node) would also work
  }
}

void print_node(ll_node *node) {
  puts(node->contents);
}

void unlink_node(ll_node *node) {
  node->next = NULL;
}

int main() {
  ll_node *one = create_node("One");
  ll_node *two = create_node("Two");
  ll_node *three = create_node("Three");

  one->next = two;
  two->next = three;

  walk_list(one, print_node); // Could've been *print_node or &print_node
  walk_list(one, unlink_node);
  walk_list(one, print_node); // Prints only "One" because the nodes were unlinked
}
```

Function pointers are great, but they are still pretty limited. There
are no lambdas or closures in C.

What if we wanted to find a node using a variable condition (node
pointer, contents, position)? In most languages I would use closures
and higher order functions to achieve it. It is possible in C, but
it's pretty limited and you would have to duplicate the code from
`walk_list`. Let's see how to achieve that:

```c
#include <stdlib.h>
#include <string.h>

typedef struct ll_node {
  char *contents;
  struct ll_node *next;
} ll_node;

ll_node *create_node(const char *contents) {
  ll_node *node = malloc(sizeof(ll_node));

  node->contents = strdup(contents);
  node->next = NULL;

  return node;
}

ll_node* find_node(ll_node *node, void* cond, short (*filter)(ll_node*, int, void*)) {
  int i = 0;

  for (; node != NULL; node = node->next) {
    if (filter(node, i, cond)) {
      return node;
    }

    i++;
  }

  return NULL;
}

short find_by_contents(ll_node *node, int i, void* contents) {
  (void) i;
  return strcmp(node->contents, (char*) contents) == 0;
}

short find_by_position(ll_node *node, int i, void* pos) {
  (void) node;
  return i == *(int*) pos;
}

short find_by_node(ll_node *node, int i, void *target_node) {
  (void) i;
  return node == target_node;
}

int main() {
  ll_node *one = create_node("One");
  ll_node *two = create_node("Two");
  ll_node *three = create_node("Three");

  one->next = two;
  two->next = three;

  int search_pos = 1;

  ll_node *nodes[] = {
    find_node(one, "Three", find_by_contents),
    find_node(one, &search_pos, find_by_position),
    find_node(one, two, find_by_node)
  };

  for (int i = 0; i < (int) (sizeof(nodes) / sizeof(nodes[0])); i++) {
    if (nodes[i]) {
      puts(nodes[i]->contents);
    }
  }
}
```

In C, we wouldn't declare functions for every banal condition, like
`find_by_two`, `find_by_third_pos`, etc, even though we could. That
would be overly verbose.

Above, we can see that:

- The `cond` argument goes into `find_node`, and not `find_by_`. In
Ruby, that would be something like: `one.find_node { |node, _i|
node.contents == "Two" }`
- The lack of lambdas and function composition means that any extra
arguments used by subsequent function pointers must be delegated
through the main function.
- We are using a generic `void*` pointer argument to relax on accepted
types, so that we can delegate the pointer argument to any filter
function.
- Since `void*` is a pointer, we had to bear the inconvenience of
allocating `search_pos` in the stack so that it can be passed as a
pointer. Imagine doing that for multiple searches in the same
function... it would not be pretty.
- We are silencing unused variable warnings with `(void) var`. We
could make a macro for that: `#define UNUSED(x) (void)(x)`.
- Not a big deal, but we had to repeat the code to walk the linked
list. I can't see how to combine functions in this case.

You can declare function pointers like any other variables:

```c
#include <stdio.h>

int int_identity(int n) {
  return n;
}

// Super silly examples here...

char** char_array_identity(char** ar) {
  return ar;
}

int main() {
  int (*identity1)(int) = int_identity;
  char** (*identity2)(char**) = char_array_identity;

  char* list[] = {"Foo"};

  printf("%i", identity1(2));
  printf("%s", identity2(list)[0]);
}
```

There are built-in functions that take advantage of this feature:

```c
#include <stdio.h>
#include <stdlib.h>

int compare_scores(const void* a, const void* b) {
  return *(int*) a - *(int*) b;
}

int main() {
  int scores[] = {5, 10, 2, 1, 20, 8};
  int nlen = sizeof(scores[0]);
  int len = sizeof(scores) / nlen;

  qsort(scores, len, nlen, compare_scores);

  for (int i = 0; i < len; i++) {
    printf("%i ", scores[i]);
  }
}
```

And they can be even more complex in the case of strings:

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int compare_names(const void* a, const void* b) {
  // Why char**? qsort converts a string, which is already a pointer,
  // into a void pointer, so we have to dereference the pointer-to
  // pointer-to-char reference with **
  char** left = (char**) a;
  char** right = (char**) b;

  // To get the value of the char pointer,  we have to dereference it again;
  return strcmp(*left, *right);
}

int main() {
  const char* names[] = {"d", "a", "F", "C"};
  int nlen = sizeof(names[0]);
  int len = sizeof(names) / nlen;

  qsort(names, len, nlen, compare_names);

  for (int i = 0; i < len; i++) {
    printf("%s ", names[i]); // C F a d
  }
}
```

There can be arrays of function pointers as well. How to refactor the
following example and kill the `switch` statement?

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

enum print_type {INT, STRING};
typedef struct {
  enum print_type type;
  void* value;
} printable;

void print_int(printable item) {
  printf("%i\n", *((int*) item.value));
}

void print_string(printable item) {
  printf("%s\n", (char*) item.value);
}

void print(printable item) {
  switch (item.type) {
  case INT:
    print_int(item);
    break;
  case STRING:
    print_string(item);
  }
}

int main() {
  int n = 2;
  printable to_print[] = {{INT, &n}, {STRING, "Thiago"}, {STRING, "..."}};
  int len = sizeof(to_print) / sizeof(to_print[0]);

  for (int i = 0; i < len; i++) {
    print(to_print[i]); // 2, Thiago, ... (each in its own line)
  }
}
```

Easy:

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// This looks a lot like polymorphism...

enum print_type {INT, STRING};
typedef struct {
  enum print_type type;
  void* value;
} printable;

void print_int(printable item) {
  printf("%i\n", *((int*) item.value));
}

void print_string(printable item) {
  printf("%s\n", (char*) item.value);
}

void (*printable_fns[])(printable) = {print_int, print_string};

int main() {
  int n = 2;
  printable to_print[] = {{INT, &n}, {STRING, "Thiago"}, {STRING, "..."}};
  int len = sizeof(to_print) / sizeof(to_print[0]);

  for (int i = 0; i < len; i++) {
    printable_fns[to_print[i].type](to_print[i]);
  }
}
```

The array must be declared in the same order as the enum to take
advantage of this trick. Enum values start at 0, and so do arrays;

## Variadic functions

Let's take the previous example as a starting point. We want to have a
`print_all` function with variadic arguments that prints whatever
variadic args are passed in.

```c
#include <stdio.h>
#include <stdarg.h>

enum print_type {INT, STRING};
typedef struct {
  enum print_type type;
  void* value;
} printable;

void print_int(printable item) {
  printf("%i\n", *((int*) item.value));
}

void print_string(printable item) {
  printf("%s\n", (char*) item.value);
}

void (*printable_fns[])(printable) = {print_int, print_string};

void print_all(int args, ...) {
  va_list ap;
  va_start(ap, args); // args is the name of the last fixed argument

  printable item;

  for (int i = 0; i < args; i++) {
    item = va_arg(ap, printable);
    printable_fns[item.type](item);
  }

  va_end(ap);
}

int main() {
  int n = 3;
  print_all(2, (printable) {INT, &n}, (printable) {STRING, "Thiago"});
}
```

- You need to include `stdarg.h`;
- There should always be at least one fixed argument;
- `va_start`, `va_arg`, and `va_end` are pre-processed macros (before
   compilation), even though they look like normal functions;
- Random errors will happen if you try to read more arguments than
  were passed in or read a variable with a non-matching type;
- That's how `printf` works. It knows how many arguments to process and
  their types by parsing the format string.

## System calls

### system

System runs a program in a separate process. Here's a program that's
not very useful:


```c
#include <stdio.h>
#include <stdlib.h>

void fail(char *message) {
  fprintf(stderr, "%s\n", message);
  exit(1);
}

int main(int argc, char *argv[]) {
  if (argc < 3) {
    fail("Needs at least two arguments");
  }

  char *prefix = argv[1];
  char *file = argv[2];
  char command[120];
  short result;

  // Remember: sprintf is C's string concatenation
  sprintf(command, "grep -r '%s_%s' .", prefix, file);

  result = system(command);

  if (result == -1) {
    puts("The system call has failed");
  }
  else if (result > 0) {
    fail("The command has failed to find matches");
  }
}
```

It has many flaws:

- It's susceptible to command injection
- It doesn't escape the input strings, so it might not work with input
  strings containing quotes
- No way to set instance variables

### exec

The `exec` function replaces the current process, which remains with
the same pid after the replacement. It also escapes the input
arguments, which must be split as separate arguments.

```c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>

void fail(char *message) {
  fprintf(stderr, "%s\n", message);
  exit(1);
}

int main(int argc, char *argv[]) {
  if (argc < 3) {
    fail("Needs at least two arguments");
  }

  char pattern[120];

  sprintf(pattern, "%s_%s", argv[1], argv[2]);

  // The name of the program needs to appear in the first and second arguments
  execl("/usr/bin/grep", "/usr/bin/grep", "-r", pattern, ".", NULL);

  // Gets to this line when the system call fails
  // errno is a global variable with the last error.
  // With no NULL closing the argument list, the error would be "Bad address"
  fail(strerror(errno));
}
```

`errno` returns an integer and `strerror` translates the error code into
a readable string. There are many possible errors, like `EPERM=1`,
`ENOENT=2` (no such file or directory), `ESRCH=3`, etc.

Now, what happens when there is no `NULL` argument to terminate the
argument list? The system call will fail. And [why do we pass the
program name
twice?](https://unix.stackexchange.com/questions/187666/why-do-we-have-to-pass-the-file-name-twice-in-exec-functions)
Because the second argument is the `argv[0]` that's passed down to the
executed program. For `grep`, `"bananas"` would also work as that
argument because `grep` doesn't care about `argv[0]`. If the second
argument is `NULL`, however, strange things will happen...

`exec` functions have a return value that can be checked, which is
useful especially when paired with `fork`. When the syscall fails, the
return value is `-1`.

There is also a version of `exec` that takes a vector for convenience.
In Lisp, one would use a single function for `exec` and circumvent the
limitation with `apply`.

```c
  char pattern[120];
  sprintf(pattern, "%s_%s", argv[1], argv[2]);
  char *args[] = {"/usr/bin/grep", "-r", pattern, ".", NULL};

  execv("/usr/bin/grep", args);
  fail("System call failed");
```

The family of functions is:

- `execl` - Takes a list of arguments.

        execl("/path/to/program", "/program", "opt1", "opt2", NULL);

- `execlp` - Takes a list of arguments and has path search

        execlp("program", "program", "opt1", "opt2", NULL);

- `execle` - Takes a list of arguments and environment variables (NULL
  terminated array of strings)

        execle("/path/to/program", "program", "opt1", "opt2", NULL, env_vars);

- `execv` - Takes a vector of arguments.

        execv("/path/to/program", args);

- `execve` - Takes a vector of arguments and environment variables

        execve("/path/to/program", args, env_vars);

- `execvp` - Takes a vector of arguments and has path search

        execvp("program", args);

- `execvpe` - Takes a vector of arguments and environment variables,
  and has path search

        execvp("program", args, env_vars);

## fork + exec

Let's illustrate fork + exec with a super stupid and nonsense program:

```c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>

#define ARRAY_SIZE(a)                               \
  (sizeof(a) / sizeof(a[0]))

char *folders[] = {"/usr/local/include", "/etc"};

int main(int argc, char *argv[]) {
  if (argc < 3) {
    fprintf(stderr, "Needs at least 2 arguments\n");
    exit(1);
  }

  char pattern[120];
  sprintf(pattern, "%s_%s", argv[1], argv[2]);

  for (size_t i = 0; i <= ARRAY_SIZE(folders); i++) {
    // Different OSes use different kinds of integers to store pids
    pid_t pid = fork();

    if (pid == -1) {
      fprintf(stderr, "Can't fork: %s\n", strerror(errno));
      return 1;
    }

    if (pid == 0) { // pid == 0 means it's the child... > 0 means it's the parent
      if (execl("/usr/bin/grep", "/usr/bin/grep", "-r", pattern, folders[i], NULL) == -1) {
        fprintf(stderr, "Can't run: %s\n", strerror(errno));
        return 1;
      }
    }
  }
}
```

- Fork uses copy-on-write on Linux
- The processes run at the same time
- Output from both processes will be mixed up, but each string will be
printed completely.
- The parent will exit before the children finish. Needs `wait` (we'll
see it afterward.)

## Interprocess communication

### File descriptors

- A file descriptor is a number that represents a data stream;
- The process stores file descriptors in a table with slots ranging
  from 0 to 255. The number of slots is configurable;
- FD are not necessarily files; they are generally data streams;
- The first three slots are always the same: 0 `stdin`, 1 `stdout`, 2
`stderr`. Hence:

        foo 2> error.log
        foo 1> output.txt
        foo 2>&1

- A file descriptor is an integer;
- Get a file descriptor with `fileno`:

        FILE *my_file = fopen("errors.log", "r");
        int descriptor = fileno(my_file);

- `fileno` doesn't return `-1` on error;
- Use `dup2` to duplicate data streams, for example: `dup2(4, 3)`. If
`4` is an open file, then `stderr` will now point at that file.

Here's an example of all that:

```c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>

#define ARRAY_SIZE(a)                               \
  (sizeof(a) / sizeof(a[0]))

char *folders[] = {"/usr/local/include", "/etc"};

void error(char* message) {
  fprintf(stderr, "%s: %s\n", message, strerror(errno));
}

int main(int argc, char *argv[]) {
  if (argc < 3) {
    fprintf(stderr, "Needs at least 2 arguments\n");
    exit(1);
  }

  FILE *f = fopen("output.txt", "w");
  char pattern[120];
  sprintf(pattern, "%s_%s", argv[1], argv[2]);

  for (size_t i = 0; i <= ARRAY_SIZE(folders); i++) {
    pid_t pid = fork();

    if (pid == -1) {
      error("Can't fork process");
    }

    if (pid == 0) {
      // Redirects output to file. 1 instead of fileno(stdout) also works
      if (dup2(fileno(f), fileno(stdout)) == -1) {
        error("Can't redirect to stdout");
      }

      if (execl("/usr/bin/grep", "/usr/bin/grep", "-r", pattern, folders[i], NULL) == -1) {
        error("Can't run program");
      }
    }
  }
}
```

### Waiting for a process

It might happen that `output.txt` won't get any lines because the
parent process exited before the child had a chance to record the
output. The parent can `wait` for the child processes in order to
circumvent that.

```
waitpid(pid, &pid_status, options);
```

- `waitpid` is able to wait for _any_ processses.
- `pid_status` stores exit information about the process.
- `pid_status` contains several pieces of information. The first 8
  bits represent exit status, which can be read by the `WEXITSTATUS`
  macro. `WIFSIGNALED(pid_status)` returns `0` if a process ended
  naturally or `1` if it was killed.
- There are several possible `options` (`man waitpid`). `0`, for
  instance, tells `waitpid` to wait until the process finishes.

Here's an example:


```c
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <sys/wait.h> // This header is not necessary in macOS

#define ARRAY_SIZE(a)                               \
  (sizeof(a) / sizeof(a[0]))

char *folders[] = {"a", "b"};

void error(char* message) {
  fprintf(stderr, "%s: %s\n", message, strerror(errno));
}

int main(int argc, char *argv[]) {
  if (argc < 3) {
    fprintf(stderr, "Needs at least 2 arguments\n");
    exit(1);
  }

  pid_t pids[ARRAY_SIZE(folders)]; // Array to store the pids
  FILE *f = fopen("output.txt", "w");
  char pattern[120];
  sprintf(pattern, "%s_%s", argv[1], argv[2]);

  for (size_t i = 0; i <= ARRAY_SIZE(folders); i++) {
    pids[i] = fork(); // Store each pid

    if (pids[i] == -1) {
      error("Can't fork process");
    }

    if (pids[i] == 0) {
      if (dup2(fileno(f), fileno(stdout)) == -1) {
        error("Can't redirect to stdout");
      }

      if (execl("/usr/bin/grep", "/usr/bin/grep", "-r", pattern, folders[i], NULL) == -1) {
        error("Can't run program");
      }
    }
  }

  // At this point, processes are running in parallel

  int pid_status;

  for (size_t i = 0; i < ARRAY_SIZE(pids); i++) {
    if (waitpid(pids[i], &pid_status, 0) == -1) { // Wait for each child to exit
      error("Error waiting for child process");
    }

    if (WEXITSTATUS(pid_status)) {
      puts("Error status was non 0");
    }
  }
}
```

### Pipes

- Pipes are not files, they are stored in memory. But it's possible to
create file-based pipes called FIFO pipes (see `mkfifo`).
- Pipes are unidirectional, but you can create two pipes: one from
  parent to child and another from child to parent.

The following program is equivalent to `ls -1 -F | grep
"/$"`. It shows only directories:

```c
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>

#define LEN 255

void error(char* message) {
  fprintf(stderr, "%s: %s\n", message, strerror(errno));
}

int main() {
  int fd[2];

  // Gotcha: always open the pipe BEFORE forking because both parent and
  // child need to inherit the same file descriptors. Otherwise, nothing
  // happens (blank output).
  if (pipe(fd) == -1) {
    error("Unable to create pipe");
  }

  pid_t pid = fork();

  if (!pid) { // Child process
    close(fd[0]); // Close the pipe's read end
    dup2(fd[1], fileno(stdout)); // Redirect the pipe's write-end to stdout

    if (execl("/bin/ls", "-1", "-F", NULL) == -1) {
      error("Unable to run command");
    }
  }
  else { // Parent process
    close(fd[1]); // Close the pipe's write end
    dup2(fd[0], fileno(stdin)); // Redirect the pipe's read-end to stdin

    char line[LEN];

    while (fgets(line, LEN, stdin)) {
      if (line[strlen(line) - 2] == '/') {
        printf("%s", line);
      }
    }
  }
}
```

When the child process dies, the pipe is closed and `fgets` gets an
`EOF` and then returns `0`.

In the next example, we open the file descriptors as file streams and
avoid using `dup2`. However, we are no longer running an external
program. To redirect the output of an external program, we necessarily
need to use `dup2`.

```c
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <errno.h>

#define LEN 255

void error(char* message) {
  fprintf(stderr, "%s: %s\n", message, strerror(errno));
}

int main() {
  int fd[2];
  pid_t pid;

  if (pipe(fd) == -1) {
    error("Unable to create pipe");
  }

  pid = fork();

  if (!pid) {
    close(fd[0]);

    FILE *write_end = fdopen(fd[1], "w");

    fprintf(write_end, "I will travel to the other side\n");
    fprintf(write_end, "And I will too");

    fclose(write_end);
  }
  else {
    close(fd[1]);
    dup2(fd[0], fileno(stdin));

    FILE *read_end = fdopen(fd[0], "r");

    char line[LEN];

    // Prints the two phrases above
    while (fgets(line, LEN, read_end)) {
      printf("%s", line);
    }

    fclose(read_end);
  }
}
```

## Pointer arithmetic

TODO:


```c
  ll_node *nodes[] = {
    find_node(one, "Three", find_by_contents),
    find_node(one, &search_pos, find_by_position),
    find_node(one, two, find_by_node)
  };

  ll_node **ptr = nodes;

  puts((*(ptr + 0))->contents);
```

## Common tasks

### Filtering an array

Filtering an array in C might be a tricky task because one has to
decide on the best trade-off.

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

const char *list[] = {"One", "Two", "Three", "Tic", "Other", "Time", "Nada"};

const char** filter(const char *pattern) {
  int len = (sizeof(list) / sizeof(list[0]));
  int i = 0, j = 0;
  const char **acc = malloc(len * sizeof(char*));

  if (acc == NULL) {
    puts("Failed to allocate");
    exit(1);
  }

  for (; i < len; i++) {
    if (strstr(list[i], pattern)) {
      acc[j] = list[i];
      j++;
    }
  }
  acc[j] = NULL; // A smart way to avoid returning the array size

  acc = realloc(acc, j * sizeof(char*));

  return acc;
}

int main() {
  const char** filtered = filter("T");

  for (int i = 0; filtered[i] != NULL; i++) { // Iterate without knowing array size
    puts(filtered[i]);
  }
}
```

In this example, we allocate the full size of the original array,
which corresponds to the worst-case scenario. It will certainly fit
all of the possible filtered elements. In the end, we `realloc` to
free up unused memory. Is this good for small arrays? Probably not.
Allocation is expensive, so we'll pay the price twice every time we
call `filter`. Another valid option is to allocate a fixed, smaller
quantity of memory. When the array size reaches a certain threshold,
double it down. Do not reallocate. Here we are trading memory for
speed. In the previous example, we trade speed for memory.

Since the source array is global and is stored in the [Initialized
Data
Segment](https://www.hackerearth.com/pt-br/practice/notes/memory-layout-of-c-program/),
we were able to determine its size with `(sizeof(list) /
sizeof(list[0]))`. If we can't know its size, however, we must pass it
to the `filter` function as an argument. Let's see how that works:

```c
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// Arrays will come in as pointers, so we can't know its size.
const char** filter(const char *list[], int len, const char *pattern) {
  int i = 0, j = 0;
  const char **acc = malloc(len * sizeof(char*));

  if (acc == NULL) {
    puts("Failed to allocate");
    exit(1);
  }

  for (; i < len; i++) {
    if (strstr(list[i], pattern)) {
      acc[j] = list[i];
      j++;
    }
  }
  acc[j] = NULL;

  acc = realloc(acc, j * sizeof(char*));

  return acc;
}

int main() {
  const char *list[] = {"One", "Two", "Three", "Tic", "Other", "Time", "Nada"};
  int len = (sizeof(list) / sizeof(list[0]));
  const char** lst = filter(list, len, "T");

  for (int i = 0; lst[i] != NULL; i++) {
    puts(lst[i]);
  }
}
```

What if the result array can have `NULL`s in between? We have a few options:

- Return a struct from `filter` with `length` and `array`;
- Pass an array argument with 2 slots for `filled` and `array` over to
  `filter`.


### Getting the current time

```c
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

// The first time I read this function I was surprised that we didn't
// have to allocate the return string. The answer is down below.
char* now() {
  time_t ts; // time_t is a long (depending on platform) that stores a
             // timestamp.

  time(&ts); // Records the timestamp to the time_t pointer.

  struct tm *t = localtime(&ts); // Converts from timestamp to
                                 // calendar time, returning a pointer
                                 // to a tm struct. The tm struct has
                                 // fields such as t->tm_hour, etc.

  return asctime(t); // Converts calendar time to textual
                     // representation
}

int main() {
  char *curtime1 = now();

  printf("The current time is: %s\n", curtime1);

  system("sleep 2");

  char *curtime2 = now();

  // WAT? curtime1 should be two seconds behind, but it's equal to
  // curtime2. What's going on? The answer is in asctime's docs:
  //
  // Return value - "pointer to a **static** null-terminated character
  // string holding the textual representation of date and time as
  // described above"
  printf("2 seconds later, the current time is: %s\n", curtime2);
  printf("Let's print the time two seconds before: %s\n", curtime1);
}
```
