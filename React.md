# React

## Basics

### HTML

Assume that the code is wrapped in the following HTML:

```html
<html>
  <head>
    <title>Beginner's Guide to React</title>
    <meta charset="UTF-8" />
  </head>

  <body>
    <div id="root"></div>
    <script src="https://unpkg.com/react@16.12.0/umd/react.development.js"></script>
    <script src="https://unpkg.com/react-dom@16.12.0/umd/react-dom.development.js"></script>
    <script src="https://unpkg.com/prop-types@15.7.2/prop-types.js"></script>
    <script src="https://unpkg.com/babel-standalone@6.26.0/babel.js"></script>

    <script type="text/babel">
      // code here
    </script>
  </body>
</html>
```

- We are using the development versions of `react` and `react-dom`.
- [UNPKG](https://unpkg.com) is a content-delivery network for NPM packages.
- [babeljs.io](https://babeljs.io/repl) to see what the code transpiles to.

### JavaScript

Rendering an element to the root div without JSX:

- JSX transpiles to `React.createElement`.

```javascript
const rootElement = document.getElementById('root');
const element = React.createElement(
  'div',
  {className: 'container'},
  'Hello World',
  'Goodbye World'
);
ReactDOM.render(element, rootElement);
```

---------

Spreading props into a component:

```javascript
const rootElement = document.getElementById('root');

const props = {
  className: 'container',
  children: 'Hello World'
};

// Uses the props object above:
// const element = <div {...props} />

// Overrides 'container' (from props.className) with 'my-class':
// const element = <div {...props} className="my-class" />

// Same result as above:
const element = <div {...props}>Goodbye World</div>;

ReactDOM.render(element, rootElement);
```

--------

Rendering a simple functional component:

```javascript
const rootElement = document.getElementById('root')

// This version uses a `msg` prop
// const Message = (props) => <div>{props.msg}</div>

// const element = (
//   <div className="container">
//     <Message msg="Hello World" />
//     <Message msg="Goodbye World" />
//   </div>
// )

// This version uses the `children` prop, which allows us to
// use <Message> similarly to HTML, allowing us to nest components:

const Message = props => <div>{props.children}</div>

// <Message>Hello world</Message> transpiles to
// React.createElement(Message, null, 'Hello World');
const element = (
  <div className="container">
    <Message>
      Hello World
      <Message>Goodbye World</Message>
    </Message>
  </div>
)

ReactDOM.render(element, rootElement)
```

--------

Custom `propTypes` implemented from scratch (not using the actual
`prop-types` library).

- `React.createElement` calls the optional `propTypes` validation
  object attached to the component.

```javascript
// Outputs 2 errors:
//
// - firstName should be a string
// - lastName should be a string

const rootElement = document.getElementById('root');

class SayHello extends React.Component {
  static propTypes = {
    firstName: PropTypes.string.isRequired,
    lastName: PropTypes.string.isRequired
  }

  render() {
    const {firstName, lastName} = this.props;

    return (
      <div>
        Hello {firstName} {lastName}!
      </div>
    );
  }
}

SayHello.propTypes = {
  firstName(props, propName, componentName) {
    if (typeof props[propName] !== 'string') {
      return new Error(`${propName} Should be a string`);
    }
  },
  lastName(props, propName, componentName) {
    if (typeof props[propName] !== 'string') {
      return new Error(`${propName} Should be a string`);
    }
  }
}

const element = <SayHello firstName={true} lastName={1} />;

ReactDOM.render(element, rootElement);
```

----------

Further factoring out the repetition (exactly the same behavior):

```javascript
const rootElement = document.getElementById('root');

class SayHello extends React.Component {
  static propTypes = {
    firstName: PropTypes.string.isRequired,
    lastName: PropTypes.string.isRequired
  }

  render() {
    const {firstName, lastName} = this.props;

    return (
      <div>
        Hello {firstName} {lastName}!
      </div>
    );
  }
}

const propTypes = {
  string(props, propName, componentName) {
    if (typeof props[propName] !== 'string') {
      return new Error(`${propName} Should be a string`);
    }
  }
}

SayHello.propTypes = {
  firstName: propTypes.string,
  lastName: propTypes.string
}

const element = <SayHello firstName={true} lastName={1} />;

ReactDOM.render(element, rootElement);
```

-----------

Use `propTypes` from the `prop-types` library to get the `string`
validation (and others).

- `propTypes` requires explicitly marking an element as `required`.
- Without `required`: If a prop is provided, it will be validated; if it's
not provided, it won't be validated.
- `propTypes` can also be declared as a static property of the component's class.
- The production version of React doesn't use `propTypes`.
- `babel-plugin-transform-react-remove-prop-types` to remove
  `propTypes` when building for production.

```javascript
const rootElement = document.getElementById('root');

class SayHello extends React.Component {
  static propTypes = {
    firstName: PropTypes.string.isRequired,
    lastName: PropTypes.string.isRequired
  }

  render() {
    const {firstName, lastName} = this.props;

    return (
      <div>
        Hello {firstName} {lastName}!
      </div>
    )
  }
}

const element = <SayHello firstName='Jojo' lastName='Potatoes' />;

ReactDOM.render(element, rootElement);
```
