+++
title = "Writing Pure, Testable, Effectful Programs: A Saga"
date = 2020-04-29
draft = true

[taxonomies]
tags = ["functional-programming", "javascript"]
+++

## Prerequisites
This post assumes basic knowledge of monads. How they are defined, how they are used, etc.

In this post, I'll try to walk you through my journey in writing a testable, pure, effectful program in JavaScript. Hopefully it will be useful in illustrating the types of problems more advanced techniques like monad transformers, free monads, and bifunctor IO try to solve. Here goes:

Let's say we need to write a program which reads a string from a file ("message.txt") appends a signature and writes the resulting string out to the console. Here's an example of how that might look in purescript:

```purescript
module Main where

import Prelude

import Effect (Effect)
import Effect.Console (log)
import Node.FS.Sync as FS
import Node.Encoding (Encoding(..))

getSignedMessage :: String -> Effect String
getSignedMessage signature = do
  result <- FS.readTextFile UTF8 "message.txt"
  pure $ result <> signature

main :: Effect Unit
main = do
   result <- getSignedMessage " - Danny Andrews"
   log result
```

This gets us through the happy case, but if the file "message.txt" doesn't exist, our program crashes. Fortunately, PureScript provides a method for converting a function which returns an `Effect a` to one which returns an `Effect (Either Error a)` called `try` defined in [Effect.Exception](https://pursuit.purescript.org/packages/purescript-exceptions/4.0.0/docs/Effect.Exception#v:try). So let's use that.

```purescript
module Main2 where

import Prelude

import Effect (Effect)
import Effect.Console (log)
import Node.FS.Sync as FS
import Node.Encoding (Encoding(..))
import Effect.Exception (try, Error)
import Data.Either (Either(..))

getSignedMessage :: String -> Effect (Either Error String)
getSignedMessage signature = do
  result <- try $ FS.readTextFile UTF8 "message.txt" 
  pure $ map (_ <> signature) result

main :: Effect Unit
main = do
   result <- getSignedMessage " - Danny Andrews"
   case result of
    Right a -> log a
    Left err -> log "Uh oh"
```

This program runs just fine, but there are two problems with it.

1. It's untestable. The output type of our `getSignedMessage` function is `Effect (Either Error String)` and as you may or may not know, `Effect` types are not comparable. (This follows from the fact that functions are not comparable.) I'll present a solution to this later on.
2. In order to append the signature, value, we have to do a `map` since we have a structure which is two-monads deep (`Effect -> Either`). This isn't *too* bad, especially when you use `do`-notation, but it's still annoying, and gets even worse when you have monads nested more than two levels deep.

As it turns out, this scenerio is so common when working with monads, that there's a canonical solution for it in the haskell community called a "monad transformer."

The canonical solution to this problem in the haskell community is monad transformers. I won't go into detail on them here, but they do exactly what they say they do. They sort of allow you to combine the functionality of two monads together and they remove the nested `map`s.

The problem with this solution is that monad transformers require a lot of wrapping and unwrapping of values, which in a language like haskell which is optimized for running and composing functions very quickly, this isn't a problem. But in a language like JavaScript and Scala, it is. This demonstrates the fundamental problem with bringing monadic IO to languages outside of haskell. A possible solution is simply to create a more powerful IO monad which has error-handling baked-in. To make IO bifunctor. Let's try this out.
