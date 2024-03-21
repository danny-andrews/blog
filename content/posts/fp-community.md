+++
title = "Daily WTF - Functional Programming Idoms"
date = 2020-05-14
draft = true
+++

1. I wish FP prorammers preferred left-to-right style, e.g. `fn1 >>> fn2` vs `fn2 <<< fn1`. It seems the former is gaining more steam, but

1. I wish the style for arrays and records wasn't ass. Look at this shit:

```purscript
{ firstName :: String
, secondNAme:: String
, age :: Int
}
```

WTF. It's worse when they're nested:

```purescript
[
  {
    firstName :: String
  , secondNAme:: String
  , age :: Int
  }
]
```

1. Unicode syntax. WTF.

1. Overuse of custom operators.
