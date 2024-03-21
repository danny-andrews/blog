+++
title = "Write tests, a lot, mainly unit"
description = "A Response to Kent Dodd's Testing Approach"
date = 2018-08-02

[taxonomies]
tags = ["testing", "rebuttal"]
+++

A few months ago, Kent Dodd wrote an article highlighting a maxim about testing philosophy which is I believe is unhelpful. It goes: "Write tests. Not too many. Mostly integration." On the first point, I agree. You should be writing tests for most all the code you write. It not only helps you for regression testing, but also as a tool for iterating on the design of your code. The second point ("Not too many") is where I start to scratch my head. I have yet to work at a place where too **many** tests are the problem. TDD is a discipline, and like all disciplines, it more tempting to neglect it than to overindulge. So recommending you "not write too many tests" seems like harmful advice.

<!-- more -->

As far as the "mostly integration" part goes, it just completely neglects the benefits TDD brings. Even worse, it misses an essential aspect of writing tests: helping you identify tight coupling. All of his arguments to write more integration tests assume that the only value tests have are in telling you when something is wrong with your code's _behavior_, but nothing of its _design_. Unit tests force you decouple your code, and encourage you to [isolate side-effects from the rest of your program logic](https://medium.com/javascript-scene/mocking-is-a-code-smell-944a70c90a6a#7529).

But, for the purpose of argument, let's just say that testing is only useful for preventing bugs and regressions. It would **still** be better to write more unit tests than integration tests. I'll demonstrate with a contrived example.

Let's say we need to write a program which logs a certain message if a user's favorite number is odd and another message if it is even. Let's write some tests for this...

```js
test("prints odd message when person's favorite number is odd", () => {
  const consoleSpy = (msg) => assert(msg === "Welcome, odd one.");
  const person = { favoriteNumber: 7 };

  const result = printWelcomeMessage(consoleSpy)(person);
});

test("prints normal message when person's favorite number is even", () => {
  const consoleSpy = (msg) => assert(msg === "Hey, normie.");
  const person = { favoriteNumber: 8 };

  const result = printWelcomeMessage(consoleSpy)(person);
});
```

Now let's write the code to make that test pass (I know. I should start by hard-coding the values in. w/e, I'm not a TDD purist)...

```js
export const printWelcomeMessage = (logMessage) => (person) =>
  person.favoriteNumber % 2 === 1 ? "Welcome, odd one." : "Hey, normie.";
```

This seems pretty good, and meets the requirements, so we ship the code. But a few days later, we get a complaint from a user that they set their favorite number to be -31, but still got the normie message. How can this be!? Well, it turns out there's an edge-case for negative odd numbers that we didn't handle. OK, let's write another test for this case...

```js
test("prints odd message when person's favorite number is odd", () => {
  const consoleSpy = (msg) => assert(msg === "Welcome, odd one.");
  const person = { favoriteNumber: 7 };

  const result = printWelcomeMessage(consoleSpy)(person);
});

test("prints normal message when person's favorite number is even", () => {
  const consoleSpy = (msg) => assert(msg === "Hey, normie.");
  const person = { favoriteNumber: 8 };

  const result = printWelcomeMessage(consoleSpy)(person);
});

test("prints odd message when person's favorite number is negative and odd", () => {
  const consoleSpy = (msg) => assert(msg === "Welcome, odd one.");
  const person = { favoriteNumber: -3 };

  const result = printWelcomeMessage(consoleSpy)(person);
});

// Hmmm...this makes me wonder if our code works correctly for even negative
// numbers. And what about zero!? Let's write cases for that as well.

test("prints odd message when person's favorite number is negative and even odd", () => {
  const consoleSpy = (msg) => assert(msg === "Hey, normie.");
  const person = { favoriteNumber: -4 };

  const result = printWelcomeMessage(consoleSpy)(person);
});

test("prints normal message when person's favorite number is zero", () => {
  const consoleSpy = (msg) => assert(msg === "Hey, normie.");
  const person = { favoriteNumber: 0 };

  const result = printWelcomeMessage(consoleSpy)(person);
});
```

Now, let's change to code to make these tests pass. Turns out, the math will work out if we reverse our check...

```js
export const printWelcomeMessage = (logMessage) => (person) =>
  person.favoriteNumber % 2 !== 0 ? "Welcome, odd one." : "Hey, normie.";
```

Great! All our tests pass now, but now we have an angry normie on our hands. _sigh_

Let's visit the same scenario, but from a unit tester's standpoint. Given the same requirements, you would probably recognize a unit of code right away: a function for determining a number's parity. So, you start writing the tests for it...

```js
test("returns true when number is odd", () => {
  assert(isOdd(5) === true);
});

test("returns false when number is even", () => {
  assert(isOdd(2) === false);
});
```

But now, you are thinking at the level of the unit, considering the cases to cover for determining a number's parity. Because of this, you are much more likely to consider other edge cases, such as negative numbers and zero. So, you write tests for those as well...

```js
// ...

test("returns true when number is negative and odd", () => {
  assert(isOdd(-3) === true);
});

test("returns false when number is negative and even", () => {
  assert(isOdd(-8) === false);
});

test("returns false when number is zero", () => {
  assert(isOdd(0) === false);
});
```

Now, you go ahead and write the code...

```js
export const isOdd = (n) => n % 2 === 1;
```

Boom! You get a failed test. So, you find this problem instead of letting your users do it for you. So, you Google the answer and fix it the way you did in the first case...

```js
export const isOdd = (n) => n % 2 !== 0;
```

Now that you're confident about this unit, you're ready to write an integration test which puts it to use...

```js
test("prints odd message when person's favorite number is odd", () => {
  const consoleSpy = (msg) => assert(msg === "Welcome, odd one.");
  const person = { favoriteNumber: 7 };

  const result = printWelcomeMessage(consoleSpy)(person);
});

test("prints normal message when person's favorite number is even", () => {
  const consoleSpy = (msg) => assert(msg === "Hey, normie.");
  const person = { favoriteNumber: 8 };

  const result = printWelcomeMessage(consoleSpy)(person);
});
```

Notice we didn't concern ourselves with the low-level edge-cases of determining a number's parity in the integration test. We can focus on the high-level activity of printing different messages to the screen based on the person's favorite number.

And the code to make the tests pass...

```js
export const isOdd = (n) => n % 2 !== 0;

export const printWelcomeMessage = (logMessage) => (person) =>
  isOdd(person.favoriteNumber) ? "Welcome, odd one." : "Hey, normie.";
```

Let's compare this to the solution we arrived at with only integration tests...

```js
export const printWelcomeMessage = (logMessage) => (person) =>
  person.favoriteNumber % 2 !== 0 ? "Welcome, odd one." : "Hey, normie.";
```

I think we can all agree that the first solution is simpler to read and understand. We've given a name to the parity calculation (`isOdd`) resulting in self-documenting code. But our tests are simpler as well!

## Unit-test method

```js
test("returns true when number is odd", () => {
  assert(isOdd(5) === true);
});

test("returns false when number is even", () => {
  assert(isOdd(2) === false);
});

test("returns true when number is negative and odd", () => {
  assert(isOdd(-3) === true);
});

test("returns false when number is negative and even", () => {
  assert(isOdd(-8) === false);
});

test("returns false when number is zero", () => {
  assert(isOdd(0) === false);
});

test("prints odd message when person's favorite number is odd", () => {
  const consoleSpy = (msg) => assert(msg === "Welcome, odd one.");
  const person = { favoriteNumber: 7 };

  const result = printWelcomeMessage(consoleSpy)(person);
});

test("prints normal message when person's favorite number is even", () => {
  const consoleSpy = (msg) => assert(msg === "Hey, normie.");
  const person = { favoriteNumber: 8 };

  const result = printWelcomeMessage(consoleSpy)(person);
});
```

## Integration-test method

```js
test("prints odd message when person's favorite number is odd", () => {
  const consoleSpy = (msg) => assert(msg === "Welcome, odd one.");
  const person = { favoriteNumber: 7 };

  const result = printWelcomeMessage(consoleSpy)(person);
});

test("prints normal message when person's favorite number is even", () => {
  const consoleSpy = (msg) => assert(msg === "Hey, normie.");
  const person = { favoriteNumber: 8 };

  const result = printWelcomeMessage(consoleSpy)(person);
});

test("prints odd message when person's favorite number is negative and odd", () => {
  const consoleSpy = (msg) => assert(msg === "Welcome, odd one.");
  const person = { favoriteNumber: -3 };

  const result = printWelcomeMessage(consoleSpy)(person);
});

test("prints odd message when person's favorite number is negative and even odd", () => {
  const consoleSpy = (msg) => assert(msg === "Hey, normie.");
  const person = { favoriteNumber: -4 };

  const result = printWelcomeMessage(consoleSpy)(person);
});

test("prints normal message when person's favorite number is zero", () => {
  const consoleSpy = (msg) => assert(msg === "Hey, normie.");
  const person = { favoriteNumber: 0 };

  const result = printWelcomeMessage(consoleSpy)(person);
});
```

Notice how despite the unit-test method requiring more tests to achieve the same case coverage as the integration test method (7 vs 5) it resulted in slightly fewer lines of code (33 vs 34). This is because testing the edge-cases of number parity calculation in the context of the integrated whole required boilerplate setup of creating a mock console logging function. This savings will be even greater in a real-world application which has more dependencies. Additionally, if you had another function down the line needed to calculate parity, you could easily duplicate test cases, because that integration test would likely add tests for some or all edge-cases as well. ALSO, if you found out you're already including a math library which includes an `isOdd` function, you can delete its tests! Then you're down to 2 tests to cover all cases. (In the integration test method, those parity calcuation edge-case tests would most likely end up sticking around, along with whatever integration tests also overlapped with it.)

> Sidenote: I realize the examples given are ultra simplistic and that extracting easily-testable units for real business needs is hardly so trivial, but the principle remains. And to those who want to bring up "Test-induced design damage," you are missing the point. TDD only provides the diagnosis (tight coupoling), you still have to come up with a proper treatment plan (DI, pub/sub, monadic I/O, more pure functions, etc.). TDD isn't to blame for horrendously over-abstracted messes. It's just the messanger. :)

## Conclusion

Any given integration test _does_ provide you with more confidence than a given unit test. But only confidence in the single code path it takes. Unit tests are what give you confidence that your logic is _correct_.

So, no. Don't write fewer tests. Don't write more integration tests than unit tests. Don't throw decades of industry experience and research out the window because of a tweet and Medium article. 😉
