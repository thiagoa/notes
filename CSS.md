## CSS

### General tips

- `1 em` - 1 unit of the parent element's font size.
    - Why `em`? Taking "letter spacing" as an example and assuming
  that `1 rem =~ 16 px`, if you base the letter spacing of a 64px font
  off a 16px font, the spacing would be completely off - therefore, we
  shouldn't use `rem` for letter spacing.
- `1 rem` (root `em`) - 1 unit of the document's font size, whatever
  font size is set at the root element.

```html
<style>
  #parent {
    font-size: 16px;
  }

  #child {
    font-size: 2em;
  }
</style>

<div id="parent">
  parent div

  <div id="child">
    child div
  </div>
</div>
```

The chid div's `em` is `32px` (`16px * 2`) in this case, since the
parent's font size is 16px. It is possible to express margin and
padding with `em` so that they're relative to the font size.

```html
<style>
  #parent {
    font-size: 16px;
  }

  #child-outer {
    font-size: 2em;
  }
  
  #child-inner {
    font-size: 2em;
  }
</style>

<div id="parent">
  parent div

  <div id="child-outer">
    child outer
    
    <div id="child-inner">child inner</div>
  </div>
</div>
```

`child-inner`'s font size is `64px` in this case.


## Tailwind CSS

### General tips

- To achieve a pleasant contrast, prefer resorting to shades of the
  same color family to set both background and text color:

```html
<p class="bg-gray-900 text-gray-500 m-3 p-5">
  Some text
</div>
```

### Background classes

```
.bg-{color}-{shade}
```

| Colors                                                             | Shades  |
|:-------------------------------------------------------------------|:--------|
| black, white                                                       | -       |
| gray, red, orange, yellow, green, teal, indigo, blue, purple, pink | 100-900 |

### Width and height

- 1 rem = 4 in Tailwind

```
.{w|h}-{size}
```

| rem sizes                  |           |
|:---------------------------|:----------|
| 0, 1, 2, 3, 4, 5, 6        | 1+ rem    |
| 8, 10, 12                  | 2+ rem    |
| 16, 20, 24                 | 4+ rem    |
| 32, 40, 48, 56, 64         | 8+ rem    |

| fractional sizes           |           |
|:---------------------------|:----------|
| 1/2..., 1/{3, 4, 5, 6, 12} | Fractions |

| whole sizes  |   |
|:-------------|:--|
| screen, full |   |

### Padding and margin

```
.{p|m{l|r|t|b}}-{size}
.{p|m{x|y}}-{size}
```

Same rem sizes.

### Text

- Specify the font family directly in the body tag to apply it
  throughout the entire app.
- Prefer defining the text color in the body for the same reason
- Prefer lighter shades over pure black text, for example, `text-gray-900`

#### Font family

```
.font-{family}
```

| Families |                            |
|----------|----------------------------|
| sans     | Helvetica or similar       |
| serif    | Times New Roman or similar |
| mono     | Monospace or similar       |

#### Text size

```
.text-{size}
```

| Sizes | rem      | Pixels |
|-------|----------|--------|
| xs    | .75rem   | 12px   |
| sm    | .875rem  | 14px   |
| base  | 1 rem    | 16px   |
| lg    | 1.125rem | 18px   |
| xl    | 1.25rem  | 20px   |
| 2xl   | 1.5rem   | 24px   |
| 3xl   | 1.875rem | 30px   |
| 4xl   | 2.25rem  | 36px   |
| 5xl   | 3rem     | 48px   |
| 6xl   | 4 rem    | 64px   |

#### Text align

```
text-{align}
```

Alignments: `left`, `center`, `right`, `justify`

#### Text color

```
.text-{color}-{shade}
```

Same colors as "Background classes" up above.

#### Italics

`.italic` or `.not-italic` to undo

```html
<p class="italic">
  Some italic text <span class="not-italic">and non-italic text</span>
</p>
```

#### Font weight

```
.font-{weight}
```

| Weights   | Font weight |
|-----------|-------------|
| hairline  | 100         |
| thin      | 200         |
| light     | 300         |
| normal    | 400         |
| medium    | 500         |
| semibold  | 600         |
| bold      | 700         |
| extrabold | 800         |
| black     | 900         |

#### Letter spacing

```
.tracking-{spacing}
```

| Spacings | Font Weight |
|----------|-------------|
| tighter  | -0.05em     |
| tight    | -0.025em    |
| normal   | 0           |
| wide     | 0.025em     |
| wider    | 0.05em      |
| widest   | 0.1em       |

#### Line height

```
.leading-{spacing}
```

| Spacings | Font weight |
|----------|-------------|
| none     | 1           |
| tight    | 1.25        |
| snug     | 1.375       |
| normal   | 1.5         |
| relaxed  | 1.625       |
| loose    | 2           |

#### Text decoration

`.underline`, `.no-underline`, `.line-through`

#### Text transform

`.uppercase`, `.lowercase`, `.capitalize`, `.normal-case`

#### Text wrap-up

```html
<html>
  <head>
    <link href="https://unpkg.com/tailwindcss@^1.0/dist/tailwind.min.css" rel="stylesheet">
  </head>

  <body>
    <h1 class="capitalize text-gray-900 text-xl font-bold">Lorem ipsum dolor sit amet consecteur.</h1>

    <p class="leading-loose tracking-wide mt-4">
      Lorem ipsum dolor, sit amet, consecteur adipiscing elit. Nullam suscipit arci ac nisl
      varius varius. Nullam actor finibus pulvinar. Morbi porttitor placerat enim nec
      consequet.
    </p>

    <div class="mx-4 p-6 bg-gray-900 text-gray-200 mt-4">
      <p>
        Lorem ipsum dolor, sit amet, consecteur adipiscing elit. Nullam suscipit arci ac nisl
        varius varius. Nullam actor finibus pulvinar. Morbi porttitor placerat enim nec
        consequet.
      </p>
      <p class="mt-4 text-blue-400">- Thiago Araujo, <span class="italic">instructor</span></p>
    </div>

    <button class="p-4 mt-4 uppercase bg-blue-500 text-blue-100">Enroll Now</button>
  </body>
</html>
```

### Borders

There is also "outline", which usually indicates focus or active state
of buttons, links, form fields, etc. How is an outline different than
a border?

- Outlines do not take up space;
- Outlines don't allow us to set each edge to a different width, color, etc;
- Outlines do not have an impact on surrounding elements; instad, they overlap;
- Outlines do not change the dize or position of the element;
- You can't create circular outlines, although you can create non-rectangular ones.

```
.border-{thickness}
.border-{side}-{thickness}
```

Sides: `t` (top), `b` (bottom), `l` (left), `r` (right)

| Thicknesses | Pixel |
|-------------|-------|
| 0           | 0px   |
| [EMPTY]     | 1px   |
| 2           | 2px   |
| 4           | 4px   |
| 8           | 8px   |

#### Border colors

```
.border-{color}-{shade}
```

Ex: `border-blue-900`

Same colors as "Background classes" up above.

#### Border styles

`solid`, `dashed`, `dotted`, `double`, `none`

#### Border radius

```
.rounded-{radius}
.rounded-{side}-{radius}
```

Sides: `t`, `r`, `b`, `l`, `tl`, `tr`, `br`, `bl`

| Radiuses | rems    | Pixels |
|----------|---------|--------|
| sm       | .125rem | 2px    |
| [EMPTY]  | .25rem  | 4px    |
| lg       | .5rem   | 8px    |
| full     | -       | 9999px |
| none     | 0       | 0px    |

#### Border wrap-up

```html
<html>
  <head>
    <link href="https://unpkg.com/tailwindcss@^1.0/dist/tailwind.min.css" rel="stylesheet">
  </head>

  <body>
    <div><button class="bg-blue-800 text-gray-400 text-sm rounded-lg p-4 border-l-8 m-4">Submit</button></div>
    <div><button class="text-red-500 border-2 border-red-500 border-dashed rounded p-4 m-4">Cancel</button></div>
    <div><button class="bg-indigo-800 text-indigo-200 border-b-4 p-4 m-4">Save</button></div>
    <div><button class="rounded-full border-4 px-16 py-3 uppercase font-bold text-sm bg-orange-600 border-orange-800">Buy Now</button></div>
    <div><button class="border font-serif uppercase rounded-lg p-2 text-xs m-4">Send Postcard</button></div>
  </body>
</html>
```

### Display modes

```
.{display}
```

- `block`
- `inline`
- `inline-block`
- `flex`
- `inline-flex`
- `table`
- `table-row`
- `table-cell`
- `hidden` (`display: none`)

### Flexbox

#### Horizontal flex direction

```
.justify-{alignment}
```

- `start`, `center`, `end`, `between`, `around`

#### Vertical flex direction

When vertical alignment does not apply, remember that the container should have a height. Tip: put a background in the div and define a height. Example:

```html
    <div class="bg-blue-500 flex justify-around h-screen items-stretch">
      <div class="bg-yellow-600 w-16 h-16">1</div>
      <div class="bg-teal-200 w-16 h-16">2</div>
      <div class="bg-red-700 w-16 h-16">3</div>
    </div>
```

```
.items-{alignment}
```

- `stretch`, `start`, `center`, `end`, `baseline`

Difference between `stretch` and `start`: with `start`, the child
containers do not take up the full height:

```html
  <body>
    <div class="flex items-start h-32">
      <div class="text-2xl bg-blue-600">&bull;</div>
      <div class="text-5xl bg-blue-800">Hello there.</div>
    </div>
```

While with `stretch`, it does:

```html
  <body>
    <div class="flex items-stretch h-32">
      <div class="text-2xl bg-blue-600">&bull;</div>
      <div class="text-5xl bg-blue-800">Hello there.</div>
    </div>
```

#### Flexbox direction

In what direction should the grid go?

```
.flex-{direction}
```

- `row`, `row-reverse`, `col`, `col-reverse`

When flipping the direction of the flex, it also flips the horizontal and vertical alignments.

#### Flexbox wrap

```
.flex-{wrap}
```

Wraps:`no-wrap` (default), `wrap`, `wrap-reverse`

In the following example, note how we had to wrap each inner div in an
outer div so as to hit a responsive 3-column grid. With that, we're
able to apply a margin to each innermost div without breaking the
3-column grid, and the trick to that is making the width 100% with
`w-full`.

```html
<html>
  <head>
    <link href="https://unpkg.com/tailwindcss@^1.0/dist/tailwind.min.css" rel="stylesheet">
  </head>

  <body>
    <div class="h-screen flex flex-wrap">
      <div class="flex w-1/3 h-1/3">
        <div class="bg-teal-100 m-2 w-full flex justify-center items-center">A</div>
      </div>

      <div class="flex w-1/3 h-1/3">
        <div class="bg-teal-100 m-2 w-full flex justify-center items-center">B</div>
      </div>
      
      <div class="flex w-1/3 h-1/3">
        <div class="bg-teal-100 m-2 w-full flex justify-center items-center">C</div>
      </div>
      
      <div class="flex w-1/3 h-1/3">
        <div class="bg-teal-100 m-2 w-full flex justify-center items-center">D</div>
      </div>
      
      <div class="flex w-1/3 h-1/3">
        <div class="bg-teal-100 m-2 w-full flex justify-center items-center">E</div>
      </div>
      
      <div class="flex w-1/3 h-1/3">
        <div class="bg-teal-100 m-2 w-full flex justify-center items-center">F</div>
      </div>
      
      <div class="flex w-1/3 h-1/3">
        <div class="bg-teal-100 m-2 w-full flex justify-center items-center">G</div>
      </div>
      
      <div class="flex w-1/3 h-1/3">
        <div class="bg-teal-100 m-2 w-full flex justify-center items-center">H</div>
      </div>
      
      <div class="flex w-1/3 h-1/3">
        <div class="bg-teal-100 m-2 w-full flex justify-center items-center">I</div>
      </div>
    </div>
  </body>
</html>
```

### Responsive design

```
.{breakpoint}:{...classes}
```

| Breakpoints | Starts at |
|-------------|-----------|
| [ALL]       | 0px       |
| sm:         | 640px     |
| md:         | 768px     |
| lg:         | 1024px    |
| xl:         | 1280px    |

Responsive classes:

| Responsive classes |                  |
|--------------------|------------------|
| .{sm}:bg-*         | background color |
| .{sm}:w-*          | width            |
| .{sm}:h-*          | height           |
| .{sm}:p-*          | padding          |
| .{sm}:m-*          | margin           |
| etc...             |                  |

Classes that are stackable end up getting stacked. For example, the
`md` breakpoint down below gets both bold and italic:

```html
<div class="p-4 sm:font-bold md:italic">
  ...
</div>
```

Example: on mobile, HTML elements could get stacked on top of each
other with `flex-col` due to space contraints, but when hitting a
certain breakpoint they could switch to `flex-row`:

```html
<body class="bg-blue-500 flex flex-col sm:flex-row">
  <div class="w-32 h-32 bg-gray-200 border">A</div>
  <div class="w-32 h-32 bg-gray-200 border">B</div>
</body>
```

### Hover modifier

```
.hover:{class}
```

Example: `hover:bg-blue-500`.

Classes available for hover:

| Hover classes                 |                  |
|-------------------------------|------------------|
| .hover:bg-*                   | background color |
| .hover:text-{color}-{shade}   | text color       |
| .hover:font-bold              | font weight      |
| .hover:border-{color}-{shade} | border color     |

```html
<html>
  <head>
    <link href="https://unpkg.com/tailwindcss@^1.0/dist/tailwind.min.css" rel="stylesheet">
  </head>

  <body class="h-screen fex justify-center items-center">
    <button class="bg-blue-500 hover:bg-blue-600 hover:text-blue-500 text-white font-bold py-2 px-4 rounded">Submit</button>
  </body>
</html>
```

By default, Tailwind puts an outline on this element but you can
remove it with `outline-none` (and not `hover:outline-none`!).

### Focus modifier

```
.focus-{...classes}
```

Available classes: same classes from hover.

### Combination modifier

```
.{breakpoint}:{mod}:{...classes}
```

Examples: `.md:hover:bg-blue-500`, `.md:focus:bg-gray-200`, `md:hover:text-orange-300`, etc.

-----------------

## Other tips

### Display inline

With display inline:

- `width` and `height` will no longer be efective
- Elements turn into words and there will be word spacing between them

### Display block

With display block

- When you don't set a width, the element occupies 100%

### Display inline-block

- Allows setting width and height.

- Can use `text-align: justify` to center a line of elements
  proportionally. However, `justify` will never justify the last line,
  which is the case when there is only one line. How to solve it? Add
  an extra invisible line with CSS occupying the full width:

```css
.container {
  text-align: justify;
}

.container::after {
  content: '';
  display: inline-block;
  width: 100%;
}

.item {
  display: inline-block;
  width: 25%;
}
```

This could be solved by adding another `.item` with HTML, but it is
not a good thing to do.

### Margin

- `margin-left: auto` will pull the element to the outmost right. 

- If you have a block element with `width: 50%`, you can use
  `margin-left: 50%` with the same effect. However, if you change
  `width` to something else you will have to adjust `margin-left`.
  That's the value of `auto`.

- `margin-left: auto` and `margin-right: auto` together will center
  the block element (if it has a width).
