module T = Color.Types
module Fn = Color.Functions

module Utils = {
  /**
   * Resulting float is always in range 0.0-1.0
   */
  let cssPercentToFloat = (percent: [< #num(float) | #percent(float)]): float =>
    switch percent {
    | #percent(f) => f *. 0.01 // TODO: Is this right?
    | #num(f) => f
    }

  let cssPercentToPercent = (percent: [< #num(float) | #percent(float)]): T.Percent.t =>
    cssPercentToFloat(percent)->T.Percent.make

  let cssAngleToDegree = (angle: CssJs.Types.Angle.t): T.Degree.t => {
    switch angle {
    | #grad(f) => T.Degree.make(f *. 0.9)
    | #turn(f) => T.Degree.make(f *. 360.0)
    | #deg(f) => T.Degree.make(f)
    | #rad(f) => T.Degree.make(f *. 180.0 /. T.pi)
    }
  }

  let cssToColor = (cssColor: CssJs.Types.Color.t): option<T.color> => {
    switch cssColor {
    | #rgb(r, g, b) => Some(RGB(T.RGB.fromPrimitives(r, g, b)))
    | #rgba(r, g, b, a) => Some(RGBA(T.RGBA.fromPrimitives(r, g, b, a->cssPercentToFloat)))
    | #hex(str) => Some(HEX(T.HEX.make(str)))
    | #hsl(h, s, l) =>
      Some(
        HSL(
          T.HSL.make(
            ~hue=cssAngleToDegree(h),
            ~saturation=T.Percent.make(cssPercentToFloat(s)),
            ~lightness=T.Percent.make(cssPercentToFloat(l)),
          ),
        ),
      )
    | #hsla(h, s, l, a) =>
      Some(
        HSLA(
          T.HSLA.make(
            ~hue=cssAngleToDegree(h),
            ~saturation=T.Percent.make(cssPercentToFloat(s)),
            ~lightness=T.Percent.make(cssPercentToFloat(l)),
            ~alpha=T.Percent.make(cssPercentToFloat(a)),
          ),
        ),
      )
    | #transparent => Some(RGBA(T.RGBA.fromPrimitives(0, 0, 0, 0.0)))
    | #currentColor => None
    }
  }

  let colorToCss = (color: T.color): CssJs.Types.Color.t => {
    switch color {
    | RGB(rgb) =>
      Css.rgb(
        T.Int8.asInt(T.RGB.red(rgb)),
        T.Int8.asInt(T.RGB.green(rgb)),
        T.Int8.asInt(T.RGB.blue(rgb)),
      )
    | RGBA(rgba) =>
      Css.rgba(
        T.Int8.asInt(T.RGBA.red(rgba)),
        T.Int8.asInt(T.RGBA.green(rgba)),
        T.Int8.asInt(T.RGBA.blue(rgba)),
        #percent(T.Percent.asFloat(T.RGBA.alpha(rgba)) *. 100.0),
      )
    | HEX(hex) => Css.hex(T.HEX.asString(hex))
    | HSL(hsl) =>
      Css.hsl(
        CssJs.Types.Angle.deg(T.Degree.asFloat(T.HSL.hue(hsl))),
        #percent(T.Percent.asFloat(T.HSL.saturation(hsl)) *. 100.0),
        #percent(T.Percent.asFloat(T.HSL.lightness(hsl)) *. 100.0),
      )
    | HSLA(hsla) =>
      Css.hsla(
        CssJs.Types.Angle.deg(T.Degree.asFloat(T.HSLA.hue(hsla))),
        #percent(T.Percent.asFloat(T.HSLA.saturation(hsla)) *. 100.0),
        #percent(T.Percent.asFloat(T.HSLA.lightness(hsla)) *. 100.0),
        #percent(T.Percent.asFloat(T.HSLA.alpha(hsla)) *. 100.0),
      )
    }
  }
} // Utils

let transparentize = (cssColor: CssJs.Types.Color.t, percentage: float): CssJs.Types.Color.t => {
  let maybeColor = Utils.cssToColor(cssColor)
  let percent = T.Percent.make(percentage)
  switch maybeColor {
  | Some(c) =>
    let tr = c->Fn.transparentize(percent)
    let newColor = Utils.colorToCss(tr)
    newColor
  | _ =>
    Js.log("Transparentize failed. Given percentage or css color was invalid")
    cssColor
  }
}

let readable = (
  cssColor: CssJs.Types.Color.t,
  ~onLight: option<CssJs.Types.Color.t>=?,
  ~onDark: option<CssJs.Types.Color.t>=?,
  (),
): CssJs.Types.Color.t =>
  switch Utils.cssToColor(cssColor) {
  | Some(color) =>
    let maybeLight = switch onLight {
    | Some(l) => Utils.cssToColor(l)
    | None => None
    }
    let maybeDark = switch onDark {
    | Some(d) => Utils.cssToColor(d)
    | None => None
    }
    let read = Fn.readable(color, ~onLight=?maybeLight, ~onDark=?maybeDark, ())
    Utils.colorToCss(read)
  | None =>
    Js.log("Readable failed. Given css color(s) was invalid")
    cssColor
  }

let opacify = (cssColor: CssJs.Types.Color.t, amount: float): CssJs.Types.Color.t =>
  switch Utils.cssToColor(cssColor) {
  | Some(color) => Fn.opacify(color, T.Percent.make(amount))->Utils.colorToCss
  | None =>
    Js.log("Opacify failed. Given css color(s) was invalid")
    cssColor
  }

let darken = (cssColor: CssJs.Types.Color.t, amount: float): CssJs.Types.Color.t =>
  switch Utils.cssToColor(cssColor) {
  | Some(color) => Fn.darken(color, T.Percent.make(amount))->Utils.colorToCss
  | None =>
    Js.log("Darken failed. Given css color(s) was invalid")
    cssColor
  }

let lighten = (cssColor: CssJs.Types.Color.t, amount: float): CssJs.Types.Color.t =>
  switch Utils.cssToColor(cssColor) {
  | Some(color) => Fn.lighten(color, T.Percent.make(amount))->Utils.colorToCss
  | None =>
    Js.log("Lighten failed. Given css color(s) was invalid")
    cssColor
  }

let desaturate = (cssColor: CssJs.Types.Color.t, amount: float): CssJs.Types.Color.t =>
  switch Utils.cssToColor(cssColor) {
  | Some(color) => Fn.desaturate(color, T.Percent.make(amount))->Utils.colorToCss
  | None =>
    Js.log("Desaturate failed. Given css color(s) was invalid")
    cssColor
  }

let invert = (cssColor: CssJs.Types.Color.t): CssJs.Types.Color.t =>
  switch Utils.cssToColor(cssColor) {
  | Some(color) => Fn.invert(color)->Utils.colorToCss
  | None =>
    Js.log("Invert failed. Given css color(s) was invalid")
    cssColor
  }

let mix = (
  cssColor: CssJs.Types.Color.t,
  cssBaseColor: CssJs.Types.Color.t,
  weight: float,
): CssJs.Types.Color.t =>
  switch (Utils.cssToColor(cssColor), Utils.cssToColor(cssBaseColor)) {
  | (Some(color), Some(baseColor)) =>
    let value = Fn.mix(color, baseColor, T.Percent.make(weight))
    Utils.colorToCss(value)
  | (Some(_), None) | (None, Some(_)) | (None, None) =>
    Js.log("Mix failed. One or both of the given css color(s) was invalid")
    cssBaseColor
  }

let shade = (cssColor: CssJs.Types.Color.t, amount: float): CssJs.Types.Color.t =>
  switch Utils.cssToColor(cssColor) {
  | Some(color) =>
    let value = Fn.shade(color, T.Percent.make(amount))
    Utils.colorToCss(value)
  | None =>
    Js.log("Shade failed. Given css color(s) was invalid")
    cssColor
  }

let tint = (cssColor: CssJs.Types.Color.t, amount: float): CssJs.Types.Color.t =>
  switch Utils.cssToColor(cssColor) {
  | Some(color) =>
    let value = Fn.tint(color, T.Percent.make(amount))
    Utils.colorToCss(value)
  | None =>
    Js.log("Shade failed. Given css color(s) was invalid")
    cssColor
  }

let setAlpha = (cssColor: CssJs.Types.Color.t, percentage: float): CssJs.Types.Color.t => {
  let maybeColor = Utils.cssToColor(cssColor)
  let percent = T.Percent.make(percentage)
  switch maybeColor {
  | Some(c) =>
    let tr = c->Fn.setAlpha(percent)
    let newColor = Utils.colorToCss(tr)
    newColor
  | _ =>
    Js.log("setAlpha failed. Given percentage or css color was invalid")
    cssColor
  }
}
