# JavaScript

## Iterators

- Iterators can be automatically iterated with `for..of`

Assigning an iterator to an object through `Symbol.iterator`:

```js
const obj = {
  a: 1,
  b: 2,
  [Symbol.iterator]: function() {
    let i = 0;
    const keys = Object.keys(this);

    return {
      next: () => {
        const key = keys[i++];

        return {
          value: [key, this[key]],
          done: i > keys.length
        };
      }
    };
  }
};

for (const item of obj) {
  console.log(item);
}

// Or:

const it = obj[Symbol.iterator]();

console.log(it.next()); // { value: [ 'a', 1 ], done: false }
console.log(it.next()); // { value: [ 'b', 2 ], done: false }
console.log(it.next()); // { value: [ undefined, undefined ], done: true }
```

With an array, it works the same. Default iterator for arrays is `[].values()`:

```js
const ar = [1, 2, 3];

ar[Symbol.iterator] = function() {
  let i = this.length - 1;

  return {
    next: () => {
      const next = { value: this[i], done: i < 0 };
      i--;
      return next;
    }
  };
};

console.log("Starting el");

for (const i of ar) {
  console.log(i);
}
```

## Async generators

```js
// Making setTimeout an awaitable function
function timeout(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

async function* generator() {
  for (let i = 0; i < 4; i++) {
    yield await timeout(2000).then(() => i);
  }
}

for (let i = 0; i < 6; i++) {
  console.log(gen.next().then(i => console.log(i)));
}
```

Output:

```
Promise { <pending> }
Promise { <pending> }
Promise { <pending> }
Promise { <pending> }
Promise { <pending> }
Promise { <pending> }
{ value: 0, done: false }
{ value: 1, done: false }
{ value: 2, done: false }
{ value: 3, done: false }
{ value: undefined, done: true }
{ value: undefined, done: true }
```

It is also possible to iterate through the generator with `for await...`:

```js
// Wrap in an async function to call "await" at the top level of
// the main file. Await is allowed at the top level of a module
// though.
async function getItems() {
  for await (const num of generator()) {
    console.log(num);
  }
}

getItems(); // Async call without await
```

Output:

```
0
1
2
3
```

Assigning a generator as the iterator. `for..of` also works:

```js
const collection = {
  a: 10,
  b: 20,
  c: 30,
  [Symbol.iterator]: function*() {
    for (let key in this) {
      yield this[key];
    }
  }
};

for (const i of collection) {
  console.log(i);
}
```

Output:

```
10
20
30
```

