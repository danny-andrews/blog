+++
title = "PureScript First Impressions"
date = 2020-04-22
draft = true

[taxonomies]
tags = ["functional-programming", "first-impressions"]
+++

## Community (4/5)
PureScript's community is Small, but lively and helpful! Head on over to the #purescript-beginners channel on functionalprogramming.slack.com and ask anything you like. However, it loses one point maybe a little unfairly because of the mere size of the community. With a smaller community, there are fewer people writing articles about it, giving talks about it, creating learning materials on it, and asking and answering questions about it on StackOverflow (the asking bit especially.) Again, not really anyone's fault since PureScript is a young language, but I still have to take a point off. 😎

## Documentation (2/5)
Although the *quality* of PureScript's language documentation is very good, it's accessibility could use some work. For starters, the purescript website doesn't contain any documentation beyond a high-level overview of the language and a short code snippet. For anything else, you have to browser a repository on GitHub. It's all well written and fairly comprehensive, but it's easy to miss important documents just by dropping in and out of folders on the GitHub web interface. It's just very clunky to use it that way. It'd be great to have all the docs hosted on GitBook or something.

Additionally, although the *language* documentation is fantastic, the standard library documentation leaves something to be desired. There are few if any examples given for many functions, and sometimes not even a basic description of fundamental modules, types, or terminology. For an example of that, read the docs for [Data.Symbol](https://pursuit.purescript.org/packages/purescript-symbols/3.0.0/docs/Data.Symbol) and tell me you understand what it is, what it's used for, or what a type-level symbol even is.[<sup>1</sup>](#user-content-1)

## Language Design (4/5)
I could go on and on about how great the core language is designed, but I'll save that for another time. The power of haskell with improved syntax, type organization, and some new features. It really feel like a language that has everything you need and nothing you don't. I hope this remains the same as adoption increases. My one concern is with custom operators.[<sup>2</sup>](#user-content-2) I tend to think Elm made the right call by keeping them out of the language, but we'll see. I could see the FP community going hog wild with those to create very concise but horribly enigmatic code. But who knows?

Another issue is with effects. It seems the story around effects is not quite fleshed out yet.

For example, many functions in the standard library throw node errors without even telling you about them! Don't believe me? Run this code.

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

Maybe I'm out of line, here, but I just don't see the utility in a function which can possibly throw an exception with no indication in the type signature (or even the docs!). Isn't this what we are trying to get away from? Shouldn't the type signature be `readTextFile :: Encoding -> FilePath -> Effect (Either Error String)`? That way, the possibilty for failure is explicit.

Maybe you want to provide a convinence function for ignoring errors, that's fine, but ignoring errors should *always* be explicit.

Redundant constructs. Why include `let-in` and `where` clauses when one would suffice? Sure, in some circumstances, one might read slightly more naturally than the other, but it adds cognative overhead, and is one more decision a programmer has to make. If I had to guess, I would say that most programmers use one or the other exclusively rather than mixing and matching, so why include both?

Too many operators. I hate aliases, and custom operators are in effect aliases. We already have a way to convert binary functions into infix operators, so why not leverage that rather than introducing a bunch of new notation for programmers to figure out? I find ``monad1 `map` monad2`` to be much more readable than ``monad1 <$> monad2``, especially to beginners. Again, reducing cognative load is a great goal in language design.

These things are somewhat minor as you can create linter rules to whitelist operators, but it doesn't shield you from learning all the operators when you are reading open source code.

Compiler messages are just brutal.

```
Could not match type

    e2

  with type

    a0


while checking that type t1
  is at least as general as type a0
while checking that expression y
  has type a0
in value declaration bindEitherT

where e2 is a rigid type variable
        bound at (line 0, column 0 - line 0, column 0)
      a0 is a rigid type variable
        bound at (line 0, column 0 - line 0, column 0)
      t1 is an unknown type
```

I wasn't doing anything too out of the ordinary when I received this error. Why can't the compiler tell me any information about `e2` and `a0`. Like what constraints they might have. They clearly have some or they could be unified. Also, why are the "bound at" locations *always* `line 0, column 0`?

## Library Support (3/5)
When you consider how easy it is to use an existing node module via PureScript's FFI, the library support is enormous (too big, in fact, the JS ecosystem is a hot mess)! However, an FFI'd-in shoddy JavaScript package is far less valuable than a package written in PureScript. And it's these types of packages which are lacking--primarily as a product of its smaller userbase. In fact, it has suprising good library support given it's smaller userbase. Still, gotta take two lashes.

## Tooling (4/5)
Purdy good.[<sup>3</sup>](#user-content-3)

## Bottom-Line
I've had a really great time with PureScript so far. I haven't attempted to publish a package of my own yet, but I'm considering doing a re-write of a JS library into PureScript as a learning exercise and also as a way of contributing to the community. Man, if I had the money, I would just write PureScript libraries all day. How amazing would that be? And why not? If languages want to gain adoption, but better way than to have people working full time on creating libraries in their language? It does seem sort of silly that we have all these compile-to-JS languages are rewritting all these npm packages in their own syntax and runtime. The good news is, I've noticed that some of the things that you tend to reach for a library to do for you become trivial enough to just do yourself in a language like PureScript.

## Suggestions for Contributors
Expand documentation for core modules. All I'm asking for is a comment explaining why a module exists and what it's use-cases are. Type signatures tell us a lot, but nothing beats one concrete example usage.

---
<span id="1">1.</span> After becoming more aquinted with the language, I think the inclusion of custom operators is essential. In fact, almost all operators are defined in the standard library somewhere, rather than being embedded in the compiler. For example, `+` and `*` are defined in the `Semiring` module.

<span id="2">2.</span> I'm a typed-fp newbie so "it's entirely possible" (-Joe Rogan) that *you could* tell me what a Symbol is for using only the information on that page, but some prose would be much appreciated for people unfamiliar with the type hierarchies at least.

<span id="3">3.</span> Hi there, sexy. Let's get into something more comfortable so we can talk about how *the whole PureScript environment* was really easy to get set up. `spago` is sort of your one-stop, shop here. It has commands for installing packages and for testing, building, and running your project. It also has a command for starting a new PureScript project. Everything I wanted to do in a tight little package, that's what you are, `spago` \*winks aggressively\*.

My one complaint is that I can't for the life of me understand how package-sets, the basis for `spago`'s package management model, work. I think the docs need to dive deeper into that concept and even explain the rationale behind it, because they idea of bundling all these packages together is very alien to anyone coming from most other package managements. package-sets are a strange, new idea and should be treated as such. Maybe some diagrams or something, I don't know.
