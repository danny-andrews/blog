+++
title = "Use Semicolons"
date = 2018-02-13

[taxonomies]
tags = ["javascript"]
+++

I was going to write a sprawling article about how eschewing semicolon usage in JavaScript is objectively wrong, but then I found [this article](https://hackernoon.com/an-open-letter-to-javascript-leaders-regarding-no-semicolons-82cec422d67d) which makes pretty much every point I was going to make.

I'll summarize the argument: using semicolons consistently (with linter enforcement) eliminates potential errors which arise from omitting them.

If you don't use semicolons in JavaScript, you're wrong.

It's true that you can run into edge-cases even if you use semicolons, but **not** if you use a linter to enforce their use. Since 99.9% of JavaScript programmers use a linter (and if you don't, Godspeed to you) this is the common case.

I hate to even wade into such a contentious and relatively mundane argument, but it illustrates a trend I see often in the software industry: "Settling" arguments by saying "it's just a matter of opinion" when there is a clear winner. Semicolons vs. not is not merely about asthetics. Omitting semicolons opens up the possibility for bugs which aren't even possible when including them. Sure, you may have the rules of ASI memorized like the back of your hand, but the junior programmer who's still trying to master the fundamentals? Now she has another stupid thing to learn. I personally don't like wasting time learning stupid things that I can offload to a static checker.

Arguments for:
- Difficult for beginners to learn edge-cases
```js
console.log(111)
;(myVar && yourVar) ? console.log(3) : console.log(7); // WTF is this? A hack, that's what.
```
- You have to add "hacks" in edge-cases.
- You can have 100% certainty that semicolon issues won't bite

https://maurobringolf.ch/2017/06/automatic-semicolon-insertion-edge-cases-in-javascript/
```js
function a() {
  return
  "Nope, I am sorry!"
}

a() // undefined

const b = 1
(function() { console.log('Old school module pattern!') })()

const c = 3
[1,2].map(e => e*2)
```

(The full list is: `[`, `(`, \`, `+`, `*`, `/`, `-`, `,`, `.`, but most of these will never appear at the start of a line in real code.)

* I realize I just quoted a man whom most semii
