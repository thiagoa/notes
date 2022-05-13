# Web Accessibility

## General tips

- Use `tabindex="0"` to enable non-tabeable elements to follow the
  default order:

  ```html
  <button>Button one</button>
  <button>Button two</button>
  <div role="button" aria-label="Weird button" class="weird-button" tabindex="0">
    <i class="icon icon-menu"></i>
  </div>
  ```

- Use `keydown` events to make non-clickable items clickable (example:
  a div).
  
- Make content visible to screen readers only with a `visuallyhidden`
  class or `screen-reader`:

  ```html
  <style type="text/css">
    .visuallyhidden {
      border: 0;
      clip: rect(0 0 0 0);
      height: 1px;
      margin: -1px;
      overflow: hidden;
      padding: 0;
      position: absolute;
      width: 1px;
    }
  </style>
  
  <button>
    <span class="visuallyhidden">Help!</span>
    <i class="icon icon-help" aria-hidden="true"></i>
  </button>
  
  <!-- Or use aria-label: -->
  
  <button aria-label="Help!">
    <i class="icon icon-help" aria-hidden="true"></i>
  </button>
  
  <div class="button" role="button" tabindex="0">
    <svg width="32" height="32" viewBox="0 0 32 32" class="icon" aria-labelledby="svgtitle">
      <title id="svgtitle">Help!</title>
      <path d="M14 24h4v-4h-4v4zM16 8c-3 0-6 3-6 6h4c0-1 1-2 2-2s2 1 2 2c0 2-4 2-4 4h4c2-0.688 4-2 4-5s-3-5-6-5zM16 0c-8.844 0-16 7.156-16 16s7.156 16 16 16 16-7.156 16-16-7.156-16-16-16zM16 28c-6.625 0-12-5.375-12-12s5.375-12 12-12 12 5.375 12 12-5.375 12-12 12z"></path>
    </svg>
  </div>
 ```

P.S.: `aria-labelledby` to denote the SVG title may be outdated and no
longer necessary at least in recent versions of Chrome.

---------------

## Accessible names

- Test thoroughly
- Prefer visible text
  - Visible text is always kept in sync and one rarely forgets to
    update them
  - Always include text labels in interactive elements
- Prefer native techniques and HTML features instead of ARIA
  - Rely on HTML naming techniques - `label` for form fields and
    `caption` for tables for example
- Avoid browser fallback
  - Browser fallbacks are usually not good because the purpose of the
    attributes chosen as fallbacks is not naming (example: HTML
    `title` and `placeholder` attributes)
- Compose brief, useful names
  - Balance brevity and clarity

## Naming techniques

### Naming with child content

Example: `<a href="/">Home</a>`

- Sometimes the accessible name is derived from the content. Example:
  links and buttons.

- Sometimes it is a label that is presented in addition to the content
  of the element (for example, tables should have a `caption`)
  
- Roles that support naming with child content are
  [here](https://www.w3.org/TR/wai-aria-practices/#naming_with_child_content).

- User agents recursively walk through descendant elements, calculate
  a name for each and concatenate the resulting strings. Exception:
  `group` descendants of `treeitem` elements, `menu` descendants of
  `menuitem` elements:

```html
<ul role="tree">
  <li role="treeitem">Fruits
    <ul role="group">
      <li role="treeitem">Apples</li> <!-- Ignored -->
      <li role="treeitem">Bananas</li> <!-- Ignored -->
      <li role="treeitem">Oranges</li> <!-- Ignored -->
    </ul>
  </li>
</ul>
```

- `aria-label` and `aria-labelledby` inhibit this behavior and hide
  the element's content and its descendants' from assistive tech
  users. **They should not be used in this case**.

## Naming with aria-label

- Used to name an element with a string that is not visually rendered:
  `<button type="button" aria-label="Close">X</button>` (when there is
  no visible text content that will serve as a name)
  
- For roles that support naming from child content, do not use
  `aria-label` - except if hiding the content is beneficial

- For other roles and types of element, assistive tech renders both
  `aria-label` and the content of the element:

  ```html
  <!-- Probably read as "Product navigation region" by assistive tech
  <nav aria-label="Product">
    <!-- Will also read the links here -->
  </nav>
  ```

- [Some types of
  elements](https://www.w3.org/TR/wai-aria-practices/#naming_role_guidance)
  should not be named.

- `aria-label` should be translated to other languages if translations
  exist.

## Naming with referenced content via aria-labelledby

Example:

```html
<span id="night-mode-label">Night mode</span>
<span role="switch" aria-checked="false" tabindex="0" aria-labelledby="night-mode-label"></span>
```

`label` cannot be used with a `span` element, so that needs to be
covered by custom JS. Using a checkbox for a `switch` role (on/off) is
more robust when possible, because we can use a `label` that way:

```html
<label for="night-mode">Night mode</label>
<input type="checkbox" role="switch" id="night-mode">
```

`aria-labelledby`:

- Has the highest precedence when browsers calculate accessible names:
  overrides names from child content and other naming attributes like
  `aria-label`.
  
- Can
  [concatenate](https://www.w3.org/WAI/WCAG21/Techniques/aria/ARIA9)
  content from multiple elements into a single name string.

```html
<form>
  <p>
    <span id="timeout-label" tabindex="-1">
      <label for="timeout-duration">Extend time-out to</label>
    </span>
    
    <input
      type="text"
      size="3"
      id="timeout-duration"
      value="20"
      aria-labelledby="timeout-label timeout-duration timeout-unit">
    
    <span id="timeout-unit" tabindex="-1"> minutes</span>
  </p>
</form>
```

The output will probably be: "Extend time-out to 20 minutes".
`timeout-duration` references the input's value in the absence of a
name with higher precedence.

- Includes elements regardless of visibility, `hidden` HTML attribute,
  `display: none` or `visibility: hidden` in the calculated name
  string.
  
- Incorporates the value of input elements in the calculated name
  string.
