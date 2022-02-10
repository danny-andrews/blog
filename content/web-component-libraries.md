+++
title = "Web Component Libraries: Why?"
date = 2021-02-28

[taxonomies]
tags = ["web-components"]
+++

Why are so many web component libraries popping up. Weren't web components supposed to free us from these walled gardens? What are they trying to solve, and are they really necessary? Let's dig in.

<!-- more -->

## 1. Declarative Rendering

One of the drawbacks of using the CustomElement API directly is that the only way to update the DOM is through imperative APIs, such as `.(add/remove)EventListener`, `.innerHTML`, and `.setAttribute`. Additionally, there is some ceremony involved in setting up an HTML template object and using it in your component, as you can see below.

Libraries such as [uhtml](https://github.com/WebReflection/uhtml) and [lit-html](https://lit-html.polymer-project.org/guide) provide you with a declarative rendering approach without the burden of a virtual DOM implementation or the need for extra tooling (e.g. JSX for React, and the Svelte compiler for Svelte components). It uses JavaScript template literals to separate the static parts of the template from the dynamic parts so it can update just the parts of the DOM which changed.

Declarative rendering turns this...

```js
const template = document.createElement("template");
template.innerHTML = `
  <button>+</button>
`;

class MyCounter extends HTMLElement {
  constructor() {
    super();
    this.shadowRoot.appendChild(template.content.cloneNode(true));
    this.button = this.shadowRoot.querySelector("button");
  }
  // ...
  connectedCallback() {
    this.button.addEventListener("click", this.increment);
  }

  disconnectedCallback() {
    this.button.removeEventListener("click", this.increment);
  }
}
```

Into this...

```js
class MyCounter extends HTMLElement {
  // ...
  render() {
    return html`<button onclick=${this.increment}>+</button>`;
  }
}
```

Much easier to read, and no unneded DOM querying or manual adding and removing of event listeners.

## 2. Dealing with Attributes

Web components have two ways of recieving data from parents: properties and attributes.
- Attributes are the values passed in declaratively through HTML. They must be strings.
- Properties are values stored on the object prototype. They can be any valid JavaScript value, but they must be set on the component imperatively.

If you're confused, you're not alone. To get an intuitive feel for this, consider the following example:

```html
<input class="my-input" maxlength="4" />
<script>
  const input = document.querySelector(".my-input");
  input.getAttribute("maxlength");  // attribute "maxlength" = "4"
  input.maxLength;                  // property "maxLength" = 4

  input.setAttribute("maxlength", "3");
  input.maxLength;                  // property "maxLength" = 3

  input.maxLength = 2;
  input.getAttribute("maxlength");  // attribute "maxlength" = "2"

  input.removeAttribute("maxlength");
  input.maxLength;                  // property "maxLength" = -1
  input.getAttribute("maxlength");  // attribute "maxlegnth" = null
</script>
```

From this example, we can see that the input element implementation must handle the following:
1. Create a camelcased property (`.maxLength`) for the attribute `maxlength`.
1. Set the property `.maxLength` to the value of the `maxlength` attribute, parsed as a `Number`.
1. Reflect changes to the `maxlength` attribute to the `.maxLength` property, and vice-versa.
1. Default `.maxLength` to `-1` when no `maxlength` attribute exists on the element.

Let's see how the code would look using raw web components:

```js
class MyInput extends HTMLElement {
  set maxLength(value) {
    if(value) {
      this.setAttribute('maxlength', Number(value));
    } else {
      this.removeAttribute('maxlength')
    }
  }

  get maxLength() {
    return this.hasAttribute('maxlength')
      ? Number(this.getAttribute('maxlength'))
      : -1;
  }
}
```

This may not look to bad, and it isn't, but multiply this boilerplate by the number of attribute/property pairs you have in your component, and it becomes arduous and error-prone. Let's see how this code would look with a library like `LitElement`:

```js
class MyElement extends LitElement {
  static get properties() {
    return {
      maxLength: {type: Number, reflect: true},
    };
  }

  constructor() {
    super();
    this.maxLength = -1;
  }
}
```

or with decorators:

```js
class MyElement extends LitElement {
  @property({ type: Number, reflect: true })
  maxLength = -1;
}
```

Much nicer. All of these constraints are provided declaratively.

This is the bare minimum required to get a counter working.

```js
const template = document.createElement("template");
template.innerHTML = `
  <button class="decrement">-</button>
  <button class="increment">+</button>
  <div>Count: <span class="count"></span></div>
`;

class MyCounter extends HTMLElement {
  static get observedAttributes() {
    return ["count"];
  }

  constructor() {
    super();
    this.attachShadow({ mode: "open" });
    this.shadowRoot.appendChild(template.content.cloneNode(true));
    this.countEl = this.shadowRoot.querySelector(".count");

    this.incrButton = this.shadowRoot.querySelector(".increment");
    this.decrButton = this.shadowRoot.querySelector(".decrement");
  }

  set count(value) {
    this.setAttribute("count", value);
  }

  get count() {
    return Number(this.getAttribute("count"));
  }

  increment = () => {
    this.count++;
  }

  decrement = () => {
    this.count--;
  }

  connectedCallback() {
    this.count = this.count || 0;
    this.incrButton.addEventListener("click", this.increment);
    this.decrButton.addEventListener("click", this.decrement);
  }

  disconnectedCallback() {
    this.incrButton.removeEventListener("click", this.increment);
    this.decrButton.removeEventListener("click", this.decrement);
  }

  attributeChangedCallback(name, oldValue, newValue) {
    switch (name) {
      case "count":
        this.countEl.innerText = this.count;
        break;
    }
  }
}
```

Now let's compare with LitElement:

```js
import { LitElement, html } from 'lit-element';

class Counter extends LitElement {
  static get properties() {
    return {
      count: { type: Number, reflect: true },
    };
  }

  constructor() {
    super();
    this.count = 0;
  }

  setCount = count => {
    this.count = count;
  };

  render() {
    const { count } = this;
    return html`
      <button type="button" @click=${() => this.setCount(count - 1)}>-</button>
      <button type="button" @click=${() => this.setCount(count + 1)}>+</button>
      <div>Count: ${count}</div>
    `;
  }
}
```
