# ReScript-Color

A color manipulation library written in ReScript. Provides manipulation functions and internal types for different types of color values.

There are also bindings to `bs-css` to make usage of this library easy with color types from it.

## Installation with bs-css

```
yarn add @rohea/rescript-color-bs-css
```

Then add `@rohea/rescript-color` and `@rohea/rescript-color-bs-css` to `bs-dependencies` in your `rescript.json`.

## Usage with bs-css

```
let myClass = CssJs.style([
    CssJs.backgroundColor(#hex("ff0000")->ColorCssJs.darken(0.5))
])
```

## Installation (without bs-css)

```
yarn add @rohea/rescript-color
```

Then add `@rohea/rescript-color` to `bs-dependencies` in your `rescript.json`.

## Supported functions

- darken
- desaturate
- invert
- lighten
- mix
- opacify
- readable
- shade
- tint
- transparentize
- setAlpha

New functions are added as soon as we need them or someone makes a nice pull request :)

## Development

1. Checkout the repository
2. Run `yarn install` (using Yarn version 1.22.x)
3. Run `yarn res-build` to make a full ReScript build
4. Run `yarn examples` to start example page with Parcel
5. Run `yarn watch` in a separate console to start watching ReScript file changes

## Prior work and inspirations

- [@rohea/re-polished]()
- [Polished](https://polished.js.org/)
