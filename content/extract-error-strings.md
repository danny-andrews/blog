+++
title = "Extract Error Strings"
date = 2018-02-13

[taxonomies]
tags = ["TIL"]
+++

Virtually every program you write will have to deal with errors somehow. And doing so almost always requires recording a message which describes what went wrong. Most often, people will construct those messages inline like the following:

<!-- more -->

> The code examples in this article are written in JavaScript because that's what I'm most familiar with, but the principle applies to any language.

handle-user-input.js:

```js
const handleUserInput = (input) => {
  const num = Number(input);
  if (isNaN(num)) {
    throw new Error(
      `I expected a number, but you gave me: "${input}." ` + "Please try again."
    );
  }

  return num * 10;
};
```

However, there are a few issues with this code:

1. Error messages can't be easily changed. If the error is displayed to the user, then a designer may want to change the error copy. Doing so requires scouring the code to find where that error was thrown.
2. If the same error case is encountered in another part of your code, the message string will have to by copy and pasted.
3. Error messages can't be internationalized.
4. Error messages can get long and they require either making an exception in your linter to allow them to extend past your max line length or resorting to ugly string concatenation.

The root cause of all these problems is the same: mixing concerns. Copy, whether displayed to the user in an error panel, or written to a stack trace, is a separate concern from your business logic. To solve these problems, you can extract error strings into a separate file (or files) and importing them where the errors are encountered.

But Danny! Most error strings aren't static text! Even the one in your example relies on runtime information, so how can we extract the messages to a static file!?

The answer is simple: `printf`. `printf` strings are like dynamic template strings in JavaScript. You can encode where you want the dynamic bits to go and then fill them in at runtime! So, our previous example would become:

errors.js:

```js
const makeError = (format) => (...args) => new Error(sprintf(format, ...args));

/* eslint-disable max-len */
export const UserInputNotNumericError = makeError(
  'I expected a number, but you gave me: "%s." Please try again.'
);
```

handle-user-input.js:

```js
const sprintf from 'sprintf';
const {UserInputNotNumericError} from './errors';

const handleUserInput = input => {
  const num = Number(input);
  if(isNaN(num)) {
    throw UserInputNotNumericError(input);
  }

  return num * 10;
}
```

With this change:

1. Error messages can be easily changed.
2. If the same error case is encountered in another part of your code, just import the same error message.
3. Error messages can be internationalized.
4. No ugly string concatenation.
