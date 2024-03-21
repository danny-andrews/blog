+++
title = "Easing into Functional Programming in JavaScript"
date = 2018-02-13

[taxonomies]
tags = ["functional-programming", "programming-language-theory"]
+++

This article is intended to help you methodically incorporate Functional Programming (FP) techniques into your everyday JavaScript.

<!-- more -->

It _will not_ try to convince you that FP is a good idea (if you want to be convinced, read anything [Eric Elliott](https://medium.com/@_ericelliott) has ever written on the subject) nor will it detail FP concepts or how to implement them. For an introduction on the problems and solutions outlined here, [watch](https://www.youtube.com/watch?v=SfWR3dKnFIo) [Brian Lonsdorf](https://medium.com/@drboolean)'s talk, of which this article is tightly based on. In fact, this article is basically an outline of his talk, but with some practical advice and dank memes sprinkled in. Let's get started!

> 🚨🚨🚨 Update: I finished a real-world project where I put these practices to use. [Check it out](https://github.com/danny-andrews/circleci-weigh-in) and let me know what you think!

## Level 1 — Eliminate Loops

The easiest way to get started with FP is by using functions the language _already provides for you_. Namely: `map`, `filter`, and `reduce`. Replace all for loops and mutating `forEach`s with their functional alternatives.

> If you've been writing JavaScript for more than a few months then you probably haven't written a `for` loop for a long, long time. Still, it's worth branching out from the native `Array` methods to avoid re-writing a bunch of utility code in every project. [Ramda](http://ramdajs.com/) is a great library when you need this extra horsepower. It's like a functional-by-design lodash.

## Level 2 — Eliminate Useless Assignment

[`pipe`](http://ramdajs.com/docs/#pipe) or [`compose`](http://ramdajs.com/docs/#compose) functions together to avoid unnecessary intermediate variable declarations. (Giving names to values is still a good idea, however.)

## Level 3 — Eliminate `null` and `undefined`

`null` is a [billion dollar mistake](https://www.infoq.com/presentations/Null-References-The-Billion-Dollar-Mistake-Tony-Hoare). It leads to all kinds of preventable runtime exceptions and breaks function contracts. And JavaScript has _two_ of them (#sadlol)! Use the [`Maybe`](https://monet.github.io/monet.js/#maybe) monad to codify the concept of nothingness.

## Level 4 — Eliminate Exceptions

You have two options here. If you are using TypeScript or a static type analyzer such as Flow, I recommend #1. If not, go with #2.

1. Return `Error`s instead. The `function` in this case will have a [union](https://guide.elm-lang.org/types/union_types.html)/[variant](https://dev.realworldocaml.org/variants.html) return type e.g. `Int | Error`.
1. Use the [`Either`](https://monet.github.io/monet.js/#either) monad.

## Level 5 — Eliminate Conditional Statements

The problem with conditionals in most languages is that they are statements, not expressions. This means you can't save the result of an if/switch statement to a value and you are left using temporary variables or wonky IIFEs instead.

Wait for the [pattern matching](https://github.com/tc39/proposal-pattern-matching) proposal to hit stage 4? :D In the meantime, use the [`Either`](https://monet.github.io/monet.js/#either) monad.

## Level 6 — Eliminate Callbacks

Use `Promise`s instead (or [better yet](https://github.com/fluture-js/Fluture/wiki/Comparison-to-Promises), [`Future`s](https://github.com/fluture-js/Fluture)).

> You almost certainly already do this one.

## Level 7 — Eliminate Side-Effects

Use the [`IO`](https://monet.github.io/monet.js/#io) Monad.

> It should be noted that FP isn't about merely eliminating things. It's about making your code more reasonable and composable. When you are given more powerful abstractions, you need fewer of them.
