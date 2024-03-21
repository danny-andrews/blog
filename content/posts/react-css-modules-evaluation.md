+++
title = "React CSS Modules Evaluation"
date = 2018-01-31

[taxonomies]
tags = ["javascript", "react", "tech-assessment"]
+++

tl;dr: Use "css-loader" over "react-css-modules"/"babel-plugin-react-css-modules" because the latter relies on side-effects, adds cognitive overhead (too much magic), causes React errors in your tests, requires complex webpack config, requires an additional dependency, is slower than css-loader, and doesn't work with webpack/babel `import` aliases.

<!-- more -->

> Disclaimer: This article is in no way meant to belittle the react-css-modules project, or its author. Gajus is a smart dude and does a lot of great work for free for the JavaScript community to enjoy! ❤️ This is merely an evaluation of this particular library.

As with many popular libraries, I'm sure "react-css-modules" had a valid use-case at the time it was created, but at the present, it's drawbacks far outweigh its benefits. This article is meant to be a warning against picking it up without thinking about what you get from it.

## "PROs"[\*](https://github.com/gajus/react-css-modules#whats-the-problem)

1. Throws error when trying to use an `undefined` class name.

> Only actual pro IMHO.

---

1. You don't have to use the styles object whenever constructing a className.

> Why is explicitness a bad thing?

---

1. Mixing CSS Modules and global CSS classes is easy.

```js
// With react-css-modules
import './styles.css';

<div className="global-class" styleName="local-class">Hi</div>;

// With css-loader
import styles from './styles.css';

<div className=`${styles.localClass} global-class`>Hi</div>;
```

> Yeah, the second example is _slightly_ more involved, but if you're using the fantastic (and tiny) [classnames](https://github.com/JedWatson/classnames) lib, you can simplify the "css-modules" example to:

```js
import styles from "./styles.css";
import classnames from "classnames";

<div className={classnames(styles.localClass, "global-class")}>Hi</div>;
```

---

1. Don't have to use `camelCase` CSS class names.

> Okay, sure, but the same is true for "css-loader." It has a [`camelCase`](https://github.com/webpack-contrib/css-loader#camelcase) option which converts kabab-case'ed class names to `camelCase`.

## CONs

1. Relies on side-effects

```js
// With css-loader
import styles from "./styles.scss";

export default () => <div className={styles.myClass}>Hi</div>;

// With react-css-modules
import "./styles.scss";

export default () => <div styleName="myClass">Hi</div>;
```

> Where does `"myClass"` come from? Why am I not using the `./styles.scss` import?

---

1. Adds magic and cognitive overhead.

> What's the difference between `className` and `styleName`? Why are there both?

---

1. Causes [React errors](https://github.com/gajus/react-css-modules/issues?utf8=%E2%9C%93&q=unknown%20prop%20stylename%20) about unrecognized property name (`styleName`) for native DOM elements.

---

1. Requires pretty convoluted webpack config.

```js
{
  test: /\.(jsx?)$/,
  exclude: /node_modules/,
  use: [{
    loader: 'babel-loader',
    query: {
      plugins: [
        [
          'babel-plugin-react-css-modules',
          {
            context,
            generateScopedName: scopedPattern,
            filetypes: { '.scss': 'postcss-scss' }
          }
        ]
      ]
    }
  }]
}
```

---

1. Requires an additional dependency.

> You're already using "css-loader" if you are importing css in your app, which already works for css modules out of the box. Why add another dependency?

---

1. Slower than using css-loader directly.

> [gajus/babel-plugin-react-css-modules](https://github.com/gajus/babel-plugin-react-css-modules#performance)

---

1. Doesn't work with webpack aliases (or [babel-plugin-module-resolver](https://github.com/tleunen/babel-plugin-module-resolver)) with [no plans to support](https://github.com/gajus/babel-plugin-react-css-modules/issues/46#issuecomment-307552410).

---

1. ~~Generates random number for style map which causes changes to dist files even when there were no code changes.~~

> Fixed in [v2.8.0](https://github.com/gajus/babel-plugin-react-css-modules/commit/ab2fe0e0f1f7771a71af1acd5b36454f6b68b669).
