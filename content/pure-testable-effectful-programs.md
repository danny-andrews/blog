+++
title = "Writing Pure, Testable, Effectful Programs: A Saga"
date = 2020-11-02

[taxonomies]
tags = ["functional-programming", "purescript"]
+++

Note: This post assumes basic knowledge of monadic effects. How they are defined, how they are used, etc.

In this post, I'll try to walk you through my journey in writing a testable, pure, effectful program in PureScript. Hopefully it will be useful in illustrating the types of problems more advanced techniques like monad transformers, free monads, and bifunctor IO try to solve. Here goes:

Let's say we need to write a program with the following requirements:

1. Read a string from a file ("message.txt")
1. Append a signature to the message string read from file (" - Danny Andrews")
1. Write the message + signature out to the console
1. If file read fails, writes a custom error message telling you what happened
1. The program is completely testable, allowing us to pass [doubles](http://xunitpatterns.com/Test%20Double.html) in place of the actual effectful functions (in this case, Fs.readTextFile.)

Seems simple enough, right? Well, buckle up.

Here's my first pass:

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

This gets us through the happy case, but it doesn't satisfy requirement #4. If the file "message.txt" doesn't exist, our program crashes with a generic file read error. Fortunately, PureScript provides a method for converting a function which returns an `Effect a` to one which returns an `Effect (Either Error a)` called `try` defined in [Effect.Exception](https://pursuit.purescript.org/packages/purescript-exceptions/4.0.0/docs/Effect.Exception#v:try). So let's use that.

```purescript
module Main2 where

import Prelude

import Effect (Effect)
import Effect.Console (log)
import Node.FS.Sync as FS
import Node.Encoding (Encoding(..))
import Effect.Exception (try)
import Data.Either (Either(..))
import Data.Bifunctor (lmap)

data MessageFileReadError = MessageFileReadError

instance showMessageFileReadError :: Show MessageFileReadError where
  show s = "Could not read message file 'message.txt.' Does it exist?"

readMessageFile :: Effect (Either MessageFileReadError String)
readMessageFile = do
  result <- try $ FS.readTextFile UTF8 "message.txt"
  pure $ lmap (const MessageFileReadError) result

getSignedMessage :: String -> Effect (Either MessageFileReadError String)
getSignedMessage signature = do
  result <- readMessageFile
  pure $ map (_ <> signature) result

main :: Effect Unit
main = do
   result <- getSignedMessage " - Danny Andrews"
   case result of
    Right a -> log a
    Left err -> log $ show err
```

This code runs great, but it's annoying that we have to do an extra `map` operation to append the signature (`pure $ map (_ <> signature) result`). As it turns out, working with nested monads is a common occurance, and the canonical solution to this problem in the haskell and scala community is to use monad transformers. I won't explain monad transformers in detail here, but I'll show you how to use `ExceptT` which is _sort of_ analogous to `EitherT` or `OptionT` if you're familiar with those.

Here's our example one more time:

```purescript
module Main3 where

import Prelude

import Effect (Effect)
import Effect.Console (log)
import Node.FS.Sync as FS
import Node.Encoding (Encoding(..))
import Effect.Exception (try, Error)
import Data.Either (Either(..))
import Control.Monad.Except.Trans (ExceptT(..), runExceptT)

readTextFile :: Encoding -> String -> ExceptT Error Effect String
readTextFile encoding path = ExceptT $ try $ FS.readTextFile encoding path

getSignedMessage :: String -> ExceptT Error Effect String
getSignedMessage signature = do
  result <- readTextFile UTF8 "message.txt"
  pure $ result <> signature

main :: Effect Unit
main = do
  result <- runExceptT $ getSignedMessage " - Danny Andrews"
  case result of
    Left err -> log "oh no"
    Right message -> log message
```

What we've done here is changed our functions to return `ExceptT`, parameterized with the types we're interested in, which allows us to call `map` and `bind` once, and transform the underlying value. Awesome!

This code meets requirements 1-4. However, there is still one issue:

It's completely untestable. The output type of our `getSignedMessage` function is `Effect (Either Error String)` and as you may or may not know, `Effect` types are not comparable. (This follows from the fact that functions are not comparable.) So there's no way for us to make assertions about it. The solution to this problem is where things get pretty wild.

When looking for a solution, you will hear people throwing around terms like "mtl," "extensible effects," "finally-tagless," "free monad," "free(er) monad," and the like. It's all pretty overwhelming.<sup>[1](#user-content-1)</sup>

This is where I'll leave this post. Hopefully someone more experienced with functional programming can clue me in on how to do this, or convince me that I shouldn't worry so much about integration testing in a pure, strongly-typed functional language. I'd love to hear people's opinions on the matter.

<span id="1">1</span> It blows me away that trying to write a testable program in a pure functional language is so complex. I'm not claiming it's a trivial problem, but it seems like there's so many vastly different ways to accomplish this, many of them requiring you to structure your application in a very specific way, and it is very overwhelming for a beginner. But, I guess no one ever said pure functional programming was easy.
