+++
title = "React Abstractions: Part 1"
date = 2018-02-02

[taxonomies]
tags = ["javascript", "react", "design-patterns", "higher-order-components"]
+++

Render Props, Component Injection, Higher-Order Components, and More!

This set of articles is an attempt to organize my thoughts on these constructs and hopefully help others along their journey through the wonderful world of React.

Part 1 will be concerned with the "What" and "How" of these abstractions while Part 2 will be concerned with the "When" and "Why."

<!-- more -->

## Background
If you're a part of the web-dev Twittersphere, then you've probably heard of the HoC vs. render prop "drama" (😛) created by [Michael Jackson](https://medium.com/@mjackson)'s tweet:

<blockquote class="twitter-tweet" data-conversation="none" data-lang="en"><p lang="en" dir="ltr">I can do anything you&#39;re doing with your HOC using a regular component with a render prop. Come fight me.</p>&mdash; MICHAEL JACKSON (@mjackson) <a href="https://twitter.com/mjackson/status/885910701520207872?ref_src=twsrc%5Etfw">July 14, 2017</a></blockquote>
<script async src="https://platform.twitter.com/widgets.js" charset="utf-8"></script>

> If you are unfamiliar with the concept of render props and/or haven't read Jackson's article on the subject, I would highly recommend doing so [here](https://cdb.reacttraining.com/use-a-render-prop-50de598f11ce) before continuing this article.

This tweet sparked a lot of productive debate, but it also added a lot of confusion, as there are a lot of variations of this pattern which are called different things. So, let's start with some terms.

## Definitions (a.k.a. "What")
[Render (prop/callback)](https://cdb.reacttraining.com/use-a-render-prop-50de598f11ce) - A function prop that a component uses to know what to render. Example:

```js
const LuckyNumber = ({ render }) => render({ number: Math.random() });

const App = () => (
  <LuckyNumber
    render={({number}) => <div>Your number is: {number}!</div>}
  />
);
```
---
[Function as Child Component (FaCC)](https://medium.com/merrickchristensen/function-as-child-components-5f3920a9ace9) - Really just a special case of the render prop where it is passed via `children`. Example:

```js
const LuckyNumber = ({ children }) => children({ number: Math.random() });

const App = () => (
  <LuckyNumber>
    {({number}) => <div>Your number is: {number}!</div>}
  </LuckyNumber>
);
```
---
[Component Injection](http://americanexpress.io/faccs-are-an-antipattern/#component-injection---a-better-solution): Another special case of the render prop pattern where instead of inlining the render function, you pass a previously-defined component instead. Example:

```js
const LuckyNumber = ({ component: Component }) => <Component number={Math.random()} />;

const AppBody = ({ number }) => <div>Your number is: {number}!</div>;

const App = () => <LuckyNumber component={AppBody} />;
```
---
[Component Deorator](https://reactjs.org/docs/higher-order-components.html) - A function which takes a component as an argument and returns a new component, which wraps the old one and endows it with some new functionality. Commonly, although incorrectly, known as a "higher-order component" (HoC). Example:

```js
const withLuckyNumber = Component => (props) => <Component number={Math.random()} {...props} />;

const UnconnectedApp = ({ number }) => <div>Your number is: {number}!</div>;

const App = withLuckyNumber(UnconnectedApp);
```
---
[Inheritence Inversion](https://medium.com/@franleplant/react-higher-order-components-in-depth-cf9032ee6c3e#5247) - A special case of the component decorator pattern whereby the returned (enhanced) component extends the wrapped component. Example:

```js
const withLuckyNumber = Component =>
  class Decorator extends Component {
    render() {
      return super.render({ number: Math.random() })
    }
  };

const UnconnectedApp = ({ number }) => <div>Your number is: {number}!</div>;

const App = withLuckyNumber(UnconnectedApp);
```
---
Higher-order component (HoC) - Any component which takes a render prop. So in our examples, the `LuckyNumber` component would be a HoC.

> The term "higher-order component," as it's currently used, is inaccurate because the thing it refers to is not itself a component, but a function. That's why I call them "component decorators" instead, since they're analogous to the [decorator design pattern](https://sourcemaking.com/design_patterns/decorator).

> Higher-order **function** (HoF): A **function** that takes a **function** as an argument and/or returns a function as a result. ([ref](http://wiki.c2.com/?HigherOrderFunction))  
> Higher order **component** (HoC): A **component** that takes a **component** as an argument (i.e. prop).  
> Component decorator: A **function** that takes a **component** as an argument and returns a component as a result.  

## Usage (a.k.a. "How")
Implementing component decorators has been detailed in depth in other articles, so I won't go through it here. However, there are a few subtleties around how to implement render props from both the HoC's perspective (`LuckyNumber`), and a HoC's consumer (`App`). Let's start with the former.

How should `LuckyNumber` render its render prop? Should it render it via `this.prop.render()` (as in the render prop example) or via `jsx/createElement` (as in the component injection example)? Is there a difference. Turns out there is!

> Note that `<Component {this.props} />` is equivalent to `React.createElement(Component, this.props, null)`. ([proof](http://bit.ly/2yBBHCd))

<p data-height="265" data-theme-id="0" data-slug-hash="BwWoXP" data-default-tab="js,result" data-user="danny-andrews" data-embed-version="2" data-pen-title="Rerendering HoCs" data-preview="true" class="codepen">See the Pen <a href="https://codepen.io/danny-andrews/pen/BwWoXP/">Rerendering HoCs</a> by Andrews (<a href="https://codepen.io/danny-andrews">@danny-andrews</a>) on <a href="https://codepen.io">CodePen</a>.</p>
<script async src="https://production-assets.codepen.io/assets/embed/ei.js"></script>

If you check out the above pen in the React dev extension, you'll see the following:

<img src="/images/injection-thing1.png" />
<img src="/images/injection-thing2.png" />

The component injection method actually renders the component into the virtual DOM while the render prop method simply *renders the React element the render prop returns*. I'm not sure of all the implications of this (I'd appreciate feedback from someone who does) but it's a good thing to keep in mind.

> React Router's `Route` component is a great case study for render props vs. component injection, because it actually implements both! See: https://reacttraining.com/react-router/web/api/Route/Route-render-methods.

So, how do these two methods line up from the `App`'s perspective? Well, let's expand our example to make it a little more "real-world." Let's say we pass in a `message` prop, to allow for localization down the line. Using inline render props, it'd look something like this:

```js
const LuckyNumber = ({ render }) => render({ number: Math.random() });

const App = ({ message }) => (
  <LuckyNumber
    render={({number}) => <div>{message}: {number}!</div>}
  />
);
```

Because the render prop is inline, the jsx we return from it is in the scope of the containing-component, meaning it has access to all its props (and state, if it has any).

When we try to accomplish the same thing with component injection, however, we run into some problems:

```js
const LuckyNumber = ({ component: Component }) => <Component number={Math.random()} />;

const AppBody = ({number}) => <div>{message}: {number}!</div>;

// How do I get the message prop to AppBody? 🤔🤔🤔
const App = () => <LuckyNumber component={AppBody} />;
```

Since we moved the render prop outside the outer component's scope, we no longer have access to the `message` prop. We can solve this by making it return a function instead:

```js
const LuckyNumber = ({ component: Component }) => <Component number={Math.random()} />;

// There's no general way to curry named parameters, so we have to do it
//   manually.
const AppBody = ({ message }) => ({ number }) => <div>{message}: {number}!</div>;

const App = ({ message }) => <LuckyNumber component={AppBody({ message })} />;
```

But wait! There's a subtle issue with this code. We are passing an inline-function as the `component` prop, and `LuckyNumber` is calling `createElement` on this prop. This will cause that component to be mounted/unmounted on [every render](https://github.com/facebook/react/pull/10741#discussion_r139836136)! The following pen, forked from [alexkrolic](https://codepen.io/alexkrolick/pen/WZwMYW)'s, demonstrates the issue.

<p data-height="265" data-theme-id="0" data-slug-hash="BwWoXP" data-default-tab="js,result" data-user="danny-andrews" data-embed-version="2" data-pen-title="Rerendering HoCs" data-preview="true" class="codepen">See the Pen <a href="https://codepen.io/danny-andrews/pen/BwWoXP/">Rerendering HoCs</a> by Andrews (<a href="https://codepen.io/danny-andrews">@danny-andrews</a>) on <a href="https://codepen.io">CodePen</a>.</p>
<script async src="https://production-assets.codepen.io/assets/embed/ei.js"></script>

We could pass in our component factory into a render prop, similar to the solution posted here, but that is no different than just using inline render props.

Let's try another approach:

```js
const LuckyNumber = ({ component: Component, componentProps }) => <Component number={Math.random()} {...componentProps} />;

const AppBody = ({ message, number }) => <div>{message}: {number}!</div>;

const App = ({ message }) => <LuckyNumber componentProps={{ message }} component={AppBody} />;
```

With this approach, we pass the props we want passed to our render prop through `LuckyNumber`. This is poor for two reasons. Firstly, it can result in prop name conflicts which is exactly what render props are meant to solve! And secondly, it requires adding an extraneous prop to every HoC's signature just for passing props through to the rendered component.

From these examples, the inline render prop pattern seems to be the most capable. That being said, React Router does provide a [component injection](https://reacttraining.com/react-router/web/api/Route/component) API, so it may still have its use-cases. Most times, though, you should stick with inline render props.

## Conclusion
I tried to keep it short, but it turns out there's a lot of variations and terms for React abstractions floating around, and I want this article to be comprehensive. Hopefully it has given us the base knowledge from which we can begin to assess these different abstractions and determine when and why we should use them. See you in Part 2 (coming soon) where we'll attempt to answer the following questions:


1. Should we be concerned about inlining render props, from a garbage collection standpoint? Why?
1.  Should we be concerned about inlining render props when using `PureComponent`? Why?
1. When should we use component injection?
1. Is there a major difference between render props and component decorators as far as performance is concerned?
1. Can render props be composed as elegantly as component decorators?
1. How do we test components which nest render props?
1. Are HoCs easier or more difficult to test than component decorators?
1. Are there any things component decorators can do that render props can't?

## Further Reading

https://reactjs.org/docs/higher-order-components.html
https://cdb.reacttraining.com/use-a-render-prop-50de598f11ce
https://medium.com/merrickchristensen/function-as-child-components-5f3920a9ace9
http://americanexpress.io/faccs-are-an-antipattern/
https://medium.com/@franleplant/react-higher-order-components-in-depth-cf9032ee6c3e
https://github.com/facebook/react/pull/10741
