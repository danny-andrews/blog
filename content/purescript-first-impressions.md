+++
title = "PureScript First Impressions"
date = 2020-11-02

[taxonomies]
tags = ["functional-programming", "first-impressions"]
+++

## Community (4/5)

PureScript's community is Small, but lively and helpful! Head on over to the #purescript-beginners channel on functionalprogramming.slack.com and ask anything you like. However, it loses one point maybe a little unfairly because of the mere size of the community. With a smaller community, there are fewer people writing articles about it, giving talks about it, creating learning materials about it, and asking and answering questions about it on StackOverflow (the asking bit especially). Again, not really anyone's fault since PureScript is a young language, but I still have to take a point off. 😎

## Documentation (2/5)

Although the _quality_ of PureScript's language documentation is very good, it's accessibility could use some work. For starters, the purescript website doesn't contain any documentation beyond a high-level overview of the language and a short code snippet. For anything else, you have to browse a repository on GitHub. It's all well written and fairly comprehensive, but it's easy to miss important documents just by dropping in and out of folders on the GitHub web interface. It's just very clunky to use it that way. It'd be great to have all the docs hosted on GitBook or something.

Additionally, although the _language_ documentation is fantastic, the standard library documentation leaves something to be desired. There are few if any examples given for many functions, and sometimes not even a basic description of fundamental modules, types, or terminology. For an example of that, read the docs for [Data.Symbol](https://pursuit.purescript.org/packages/purescript-symbols/3.0.0/docs/Data.Symbol) and tell me you understand what it is, what it's used for, or what a type-level symbol even is.

## Language Design (4/5)

I could go on and on about how great the core language is designed, but I'll save that for another time. In short, it gives you the power of haskell with improved syntax, type organization, and some new features. It really feels like a language that has everything you need and nothing you don't. I hope this remains the same as adoption increases. I do have a few issues, however:

### Too Many Operators

Having lots of operators is problematic for many reasons.

1. Operators add more cognative load than regular functions. Because to use them confidently you not only need to learn what they do, but what their associativity and presendence is. For this reason, operators carry at least three times the cognative load that regular functions do.
2. Operators are essentially aliases -- for every operator, there is a corresponding function which does the same thing.
3. Operators are difficult to search for. Although package documentation website, Pursuit, supports searching with sepcial characters (ex: <https://pursuit.purescript.org/search?q=%3E%3E>), you still can't search Google for them.

I do think operators have utility, but they should only be used for fundamental operations (e.g. `>>>` for funnction piping). Beyond that, I feel the cost of them outweights the benefit, especially for beginners, and especially when considering that we already have a way to convert binary functions into infix operators. Why not leverage that rather than introducing a bunch of new notation for programmers to figure out? With basic knowledge of monads, I can read `` monad1 `map` monad2 `` and immediately understand what is going on. I can't say the same for `monad1 <$> monad2`.

### Redundant Constructs

This is an admittedly minor issue, but why include `let-in` and `where` clauses when one would suffice? Sure, in some circumstances, one might read slightly more naturally than the other, but it adds cognative overhead, and is one more decision a programmer has to make. If I had to guess, I would say that most programmers use one or the other exclusively rather than mixing and matching, so why include both?

## Standard Library (3/5)

The standard library is pretty good overall, but the effects situation is a bit confusing. There seem to be lots of different ways to effects, and many of the standard wrappers for node.js effects throw node errors without even telling you about them! Don't believe me? Run this code:

```purescript
module Main where

import Prelude

import Effect (Effect)
import Effect.Console (log)
import Node.FS.Sync as (readTextFile)
import Node.Encoding as Encoding

main :: Effect Unit
main = do
   contents <- readTextFile Encoding.UTF8 "message.txt"
   log contents
```

I just don't see the utility in a function which can possibly throw an exception with no indication in the type signature (or even the docs!). Isn't this what we are trying to get away from with pure functional programming? It seems the type signature should be `readTextFile :: Encoding -> FilePath -> Effect (Either Error String)`? That way, the possibilty for failure is explicit. If you want to provide a convinence function for ignoring errors, that's fine, but ignoring errors should _always_ be explicit.

## Library Support (3/5)

When you consider how easy it is to use an existing node module via PureScript's FFI, the library support is enormous! (Too big, in fact; the JS ecosystem is a hot mess.) However, a shoddy JavaScript package which is called via FFI is far less valuable than a package written in PureScript. And it's these types of packages which are lacking--primarily as a product of its smaller userbase.

## Tooling (4/5)

`spago` is sort of your one-stop, shop here. It has commands for installing packages and for testing, building, and running your project. It also has a command for starting a new PureScript project. Bravo!

My one complaint is that I can't for the life of me understand how package-sets, the basis for `spago`'s package management model, work. I think the docs need to dive deeper into that concept and even explain the rationale behind it, because they idea of bundling all these packages together is very alien to anyone coming from most other package managements, especially npm. package-sets are a strange, new idea and should be treated as such. Maybe some diagrams or something, I don't know.

## Bottom-Line

I've had a really great time with PureScript so far. I haven't attempted to publish a package of my own yet, but I'm considering doing a re-write of a JS library into PureScript as a learning exercise and also as a way of contributing to the community.

## My PureScript Wishlist

<!-- markdownlint-disable no-bare-urls -->

1. Expanded documentation for core modules. All I'm asking for is a comment explaining why a module exists and what it's use-cases are. Type signatures tell us a lot, but nothing beats even just one concrete example usage.
2. Web version of https://github.com/purescript/documentation. GitHub isn't ideal for consuming content.
3. Simplified effect handling. No runtime errors by default from standard libraries like `FS.readFile`.
4. Cool it with the custom operators. 😎 It really hurts adoption...just ask the Scala community.

<!-- markdownlint-restore -->
