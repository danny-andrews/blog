+++
title = "The Finer Points of Unit Testing"
date = 2018-02-13

[taxonomies]
tags = ["back-to-basics", "testing"]
+++

What follows are a list of language-agnostic principles and best practices I have found to be quite helpful when writing unit tests. Let me know what I missed in the comments!

<!-- more -->

> This article was inspired by the [knowledge-base](https://github.com/danny-andrews/knowledge-base/blob/master/GENERAL.md) I've been developing lately. It's sort of a living career cheat-sheet. I highly recommend any developer to do the same. I can't count the number of times I've forgotten a cool trick or principle I've learned. No longer!

## Terms

**Factory** - A function which simplifies the construction of some test dependency (arguments, objects, etc.).

**Fixture** — Any form of static test data.

**Test-Driven Development (TDD)** — A programming discipline which emphasises writing tests as a part of code design, as easy of testing is a good indicator of code quality.

**Behavior-Driven Development (BDD)** — A approach to writing tests which focuses on specification and user-facing behavior.

**Unit/System Under Test (SUT)/Test Subject** — The simplest piece of self-contained functionality. It could be as simple as a method, or as complex as a class, but should be isolated sufficiently from collaborators.

**Test Case** — One atomic test (usually implemented as a function) which runs some code and makes assertions about it.

**Test Double**[\*](http://xunitpatterns.com/Test%20Double.html) — A generic term for any kind of pretend object used in place of a real object for testing purposes. Specific examples given below:

- **Fake** — A test double that actually has a working implementation, but usually takes some shortcut which makes it not suitable for production (an [in-memory database](https://martinfowler.com/bliki/InMemoryTestDatabase.html) is a good example, as is [redux-mock-store](https://github.com/arnaudbenard/redux-mock-store)).

- **Dummy** — A test double passed around but never actually used in the code path the test is exercising. Usually they are just used to fill parameter lists.

- **Stub** — A test double which provides canned answers to calls made during the test.

- **Spy** — A Stub that also records some information based on how it was called (how many times and with what parameters).

- **Mock**[\*](https://martinfowler.com/articles/mocksArentStubs.html) — A spy with pre-programmed expectations.

## Best-Practices

### Keep irrelevant data and setup out of tests

Use factories to make SUT construction easy.

#### Benefits

1. No copy-and-paste.
1. Tests which are easier to read.
1. Easy to fix entire suite when the SUT's signature changes.

#### Bad

```js
import subject from '../get-pr-status-payload';

it("sets state to 'success' when no failures", () => {
  const { state: actual } = subject({
    thresholdFailures: [],
    label: '' // Why do we have to pass this in?
  });

  expect(actual).toEqual('success');
});

it("sets state to 'failure' when there are failures", () => {
  const { state: actual } = subject({
    thresholdFailures: [{ message: 'file3 is too big' }]
    label: ''
  });

  expect(actual).toEqual('failure');
});

it('sets context to label', () => {
  const { context: actual } = subject({
    thresholdFailures: [], // Why do we have to pass this in?
    label: 'bundle sizes'
  });

  expect(actual).toEqual('bundle sizes');
});
```

#### Good

```js
import getPrStatusPayload from "../get-pr-status-payload";

const optsFac = (opts = {}) => ({
  thresholdFailures: [],
  label: "",
  // If the SUT adds any required options (e.g. delay) we can add it
  //   here, and fix all our tests!
  ...opts,
});

const subject = R.pipe(optsFac, getPrStatusPayload);

it("sets state to 'success' when no failures", () => {
  const { state: actual } = subject({ thresholdFailures: [] });

  expect(actual).toEqual("success");
});

it("sets state to 'failure' when there are failures", () => {
  const { state: actual } = subject({
    thresholdFailures: [{ message: "file3 is too big" }],
  });

  expect(actual).toEqual("failure");
});

it("sets context to label", () => {
  const { context: actual } = subject({ label: "bundle sizes" });

  expect(actual).toEqual("bundle sizes");
});
```

### Factories only provide required data[\*](https://robots.thoughtbot.com/factories-should-be-the-bare-minimum)

Factories should only provide minimal amount of data required to statisfy the SUT's interface.

#### Benefits

1. No confusing test results caused by optional data added by factory.
1. No unnecessary work performed by factory.

#### Bad

```js
import Person from "../Person";

const subject = (opts = {}) => ({
  name: "Bob",
  favoriteNumbers: [2, 4, 7], // Optional!
  ...opts,
});

it("defaults favoriteNumbers to empty list", () => {
  const person = subject();

  // Fails! Length is 3!
  expect(person.favoriteNumbers.length).toBe(0);
});
```

#### Good

```js
import Person from "../Person";

const subject = (opts = {}) => ({
  name: "Bob",
  ...opts,
});

it("defaults favoriteNumbers to empty list", () => {
  const person = subject();

  // Fails! Length is 3!
  expect(person.favoriteNumbers.length).toBe(0);
});
```

### Apply BDD Principles

Test external-facing behavior, not implementation. Don't test private APIs.

<img src="/images/unit-testing-cheatsheet.png" />

> From “[The Magic Tricks of Testing](https://youtu.be/URSWYvyc42M?t=27m52s)” by Sandi Metz

#### Benefits

1. Allows you to refactor SUT internals without breaking tests.
1. Tests what's really important (user-facing behavior). Tests SUT internals as a side-effect.

#### Bad

```js
test("tick increases count to 1 after calling tick", function () {
  const subject = Counter();

  subject.tick();

  // Tests two things! That count is incremented when tick is
  //   called, and that count is defaulted to 0. In the context of
  //   this test, the latter is an implementation detail.
  assert.equal(subject.count, 1);
});
```

#### Good

```js
it("increases count by 1 after calling tick", function () {
  const subject = Counter();
  const originalCount = subject.count;

  subject.tick();

  // Only tests one thing.
  assert.equal(subject.count, expectedCount + 1);
});
```

### Each test should only verify one behavior

Verifying one behavior != making one assertion, although this is usually the case.

#### Benefits

1. Eliminates test redundancy.
1. Makes it easier to remove/modify a behavior from the SUT, as it should require deleting/modifying one corresponding test.

#### Bad

```js
test("tick increases count to 1 after calling tick", function () {
  const subject = Counter();

  subject.tick();

  // Tests two things! That count is incremented when tick is
  //   called, and that count is defaulted to 0.
  assert.equal(subject.count, 1);
});
```

#### Good

```js
it("defaults count to 0", function () {
  const subject = Counter();

  subject.tick();

  assert.equal(subject.count, 0);
});

it("increases count by 1 after calling tick", function () {
  const subject = Counter();
  const originalCount = counter.count;

  subject.tick();

  assert.equal(subject.count, expectedCount + 1);
});
```

### Avoid fixtures

Fixtures are inflexible and necessitate a lot of redundancy. If the shape of your data changes, you have to change it in **every single fixture**. Use factories instead. Create all data/objects your test needs inside the test.

### Prefer BDD syntax

Many [testing frameworks](https://mochajs.org/#interfaces) offer an xUnit-style syntax (`suite`/`test`) and a BDD-style syntax (`describe`/`it`). The latter helps to nudge the developer in the direction of testing in terms of specifications and external behaviors rather than implementation details and read a little more naturally.

#### Good

```js
describe("thing", () => {
  it("does the thing");
});
```

#### Less Good

```js
suite("thing", () => {
  test("does the thing");
});
```

### Keep your test cases flat

1. Only use `describe` blocks to broadly categorize tests (e.g. `describe('performance')`, `describe('integration')`) never to group tests by conditions (e.g. `describe('with 1000 elements')`, `describe('when request fails')`).
1. Keep nesting to two levels deep.
1. Don't add top-level describe block. It adds unnecessary nesting. It should be clear what you are testing by the test file name.

#### Benefits

1. Easier to read test cases as all conditions are listed in the description.
1. Discourages nested `beforeEach` logic which makes test cases exponentially more difficult to reason about.
1. Reduces indentation.

#### Costs

1. Test descriptions are longer. (Big deal.)
1. More duplication in a test case since you can't do setup in a `beforeEach`. (Some duplication in tests is fine and ancillary boilerplate can be extracted into a helper method/factory.)

#### Bad

```js
describe("requestMaker", () => {
  describe("valid token given", () => {
    it("uses auth header along with passed headers", () => {
      // ...
    });
  });

  describe("expired token given", () => {
    it("generates a new token", () => {
      // ...
    });
  });
});
```

#### Good

```js
// request-maker-test.js
it("uses auth header along with passed headers when valid token given", () => {
  // ...
});

it("generates a new token when expired token given", () => {
  // ...
});
```

### Use common set of variable names

You will find yourself setting many variables which do the same thing in tests. Why try to come up with creative names for them, when you can just use one from a pre-defined set? Examples: `subject`, `expected`, `result`, `actual`, etc.

#### Benefits

1. Reduces cognitive load because naming things is hard.
1. Allows you to rename your subject without changing a bunch of variable names (or, even worse, forgetting to change them, leaving them around to confuse future readers).

### Omit `it` and `should` in test description

These are implied, and removing them keeps descriptions short.

#### Bad

```js
it("should call handler with event object", () => {
  // ...
});
```

#### Good

```js
it("calls handler with event object", () => {
  // ...
});
```

### Keep all data local to test cases

Don't rely on [shared state](https://robots.thoughtbot.com/lets-not) set up in a `before`/`beforeEach` blocks. This makes your tests easier to [reason about](https://robots.thoughtbot.com/mystery-guest) and minimizes the possibility of flaky tests.

> If you're tempted to share state for performance reasons, don't do so until you have actually identified a problematic test.[\*](http://wiki.c2.com/?PrematureOptimization) Also realize that sharing state between tests eliminates the possibility to parallelize your tests, so you may end up with slower overall test run times by introducing shared state.

### Organize tests into [stages](https://robots.thoughtbot.com/four-phase-test)

1. Setup/Arrange
1. Exercise/Act
1. Verify/Assert
1. (Teardown)\*

> \* Requiring teardown in a test is a code-smell and is usually the result of stubbing a global method which should be passed in as a dependency.

#### Example (Using React + Enzyme)

```js
it("renders stat and label of currently selected datum", () => {
  // Setup/Arrange
  const data = [
    { x: "Cats", y: 2 },
    { x: "Dogs", y: 17 },
  ];

  // Exercise/Act
  const root = mount(<DoughnutChart data={data} />);
  const subject = root.find("VictoryPie").find(HighlightableSlice).at(1);
  subject.simulate("mouseover");

  // Verify/Assert
  const stat = root.find(".highlight-stat").text();
  const label = root.find(".highlight-label").text();
  expect(stat).toBe("17");
  expect(label).toBe("Dogs");
});
```

## Benefits of following these principles

1. Better code (no reliance on global state)!
1. Determinism
1. Atomicity (no order-dependence)
1. Parallelization potential
1. Focus
1. Robustness
1. Readability
1. Reasonableness
1. Less cognitive load

## Resources

<!-- markdownlint-disable no-bare-urls -->

- https://martinfowler.com/articles/mocksArentStubs.html
- https://robots.thoughtbot.com/four-phase-test
- https://robots.thoughtbot.com/lets-not
- https://robots.thoughtbot.com/factories-should-be-the-bare-minimum
- https://robots.thoughtbot.com/mystery-guest https://www.youtube.com/watch?v=R9FOchgTtLM
- http://xunitpatterns.com/Test%20Double.html

<!-- markdownlint-disable no-bare-urls -->
