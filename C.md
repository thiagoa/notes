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

## Printing functions

`fgets(array, sizeof(buffer), stdin)` - fgets takes the full size of
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

What if the size passed to `fget` exceeds the variable? It errors.

## Arrays

- Variables are stored in memory.
- An array is not referenced by a variable.
- An array is a direct pointer to the memory address of the first element.

```c
#include <stdio.h>

/* The array decays to a pointer */
void pass_pointer(char str[]) {
  /* Throws a warning and prints the size of the pointer: 8 bytes */
  /* The function signature could be written as "void pass_pointer(char *str)" */
  /* The warning disappears with this new signature */
  printf("%lu\n", sizeof(str));

  /* This will still work because printf is smart enough to understand */
  printf("%s", str);
}

int main() {
  /* Each char is stored in a byte / memory position */
  /* C implicitly puts a null terminator char: \0 */
  char str[] = "One two three";

  /* Declares a literal integer array in contiguous memory buckets */
  int nums[] = {1, 2, 3, 4};

  /* Outputs 14, the size of the array. "lu" is unsigned long */
  /* The string size is 13 + 1 of the null terminator */
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
 * The pointer address in memory is different from
 * the first element's location
 */
&p != p
```

## Stdio

```c
int main() {
  char answer1[40];
  char answer2[40];

  fgets(answer1, 80, stdin);

  printf("%s", answer1);
}
```
