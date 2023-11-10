module Utils = {
  /**
   * Resulting float is always in range 0.0-1.0
   */
  let cssPercentToFloat = (percent: [< #num(float) | #percent(float)]): float =>
    switch percent {
    | #percent(f) => f *. 0.01 // TODO: Is this right?
    | #num(f) => f
    }

  let cssPercentToPercent = (percent: [< #num(float) | #percent(float)]): Color.Types.Percent.t =>
    cssPercentToFloat(percent)->Color.Types.Percent.make

  let cssAngleToDegree = (angle: Css.Types.Angle.t): Color.Types.Degree.t => {
    open Color.Types
    switch angle {
    | #grad(f) => Degree.make(f *. 0.9)
    | #turn(f) => Degree.make(f *. 360.0)
    | #deg(f) => Degree.make(f)
    | #rad(f) => Degree.make(f *. 180.0 /. pi)
    }
  }

  let cssToColor = (cssColor: Css.Types.Color.t): option<Color.Types.color> => {
    open Color.Types
    switch cssColor {
    | #rgb(r, g, b) => Some(RGB(RGB.fromPrimitives(r, g, b)))
    | #rgba(r, g, b, a) => Some(RGBA(RGBA.fromPrimitives(r, g, b, a->cssPercentToFloat)))
    | #hex(str) => Some(HEX(HEX.make(str)))
    | #hsl(h, s, l) =>
      Some(
        HSL(
          HSL.make(
            ~hue=cssAngleToDegree(h),
            ~saturation=Color.Types.Percent.make(cssPercentToFloat(s)),
            ~lightness=Color.Types.Percent.make(cssPercentToFloat(l)),
          ),
        ),
      )
    | #hsla(h, s, l, a) =>
      Some(
        HSLA(
          HSLA.make(
            ~hue=cssAngleToDegree(h),
            ~saturation=Color.Types.Percent.make(cssPercentToFloat(s)),
            ~lightness=Color.Types.Percent.make(cssPercentToFloat(l)),
            ~alpha=Color.Types.Percent.make(cssPercentToFloat(a)),
          ),
        ),
      )
    | #transparent => Some(RGBA(RGBA.fromPrimitives(0, 0, 0, 0.0)))
    | #currentColor => None
    }
  }

  let colorToCss = (color: Color.Types.color): Css.Types.Color.t => {
    open Color.Types
    switch color {
    | RGB(rgb) =>
      Css.rgb(Int8.asInt(RGB.red(rgb)), Int8.asInt(RGB.green(rgb)), Int8.asInt(RGB.blue(rgb)))
    | RGBA(rgba) =>
      Css.rgba(
        Int8.asInt(RGBA.red(rgba)),
        Int8.asInt(RGBA.green(rgba)),
        Int8.asInt(RGBA.blue(rgba)),
        #percent(Percent.asFloat(RGBA.alpha(rgba)) *. 100.0),
      )
    | HEX(hex) => Css.hex(HEX.asString(hex))
    | HSL(hsl) =>
      Css.hsl(
        Css.Types.Angle.deg(Degree.asFloat(HSL.hue(hsl))),
        #percent(Percent.asFloat(HSL.saturation(hsl)) *. 100.0),
        #percent(Percent.asFloat(HSL.lightness(hsl)) *. 100.0),
      )
    | HSLA(hsla) =>
      Css.hsla(
        Css.Types.Angle.deg(Degree.asFloat(HSLA.hue(hsla))),
        #percent(Percent.asFloat(HSLA.saturation(hsla)) *. 100.0),
        #percent(Percent.asFloat(HSLA.lightness(hsla)) *. 100.0),
        #percent(Percent.asFloat(HSLA.alpha(hsla)) *. 100.0),
      )
    }
  }
} // Utils

let transparentize = (cssColor: Css.Types.Color.t, percentage: float): Css.Types.Color.t => {
  let maybeColor = Utils.cssToColor(cssColor)
  let percent = Color.Types.Percent.make(percentage)
  switch maybeColor {
  | Some(c) =>
    let tr = c->Color.transparentize(percent)
    let newColor = Utils.colorToCss(tr)
    newColor
  | _ =>
    Js.log("Transparentize failed. Given percentage or css color was invalid")
    cssColor
  }
}

let readable = (
  cssColor: Css.Types.Color.t,
  ~onLight: option<Css.Types.Color.t>=?,
  ~onDark: option<Css.Types.Color.t>=?,
  (),
): Css.Types.Color.t =>
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
    let read = Color.readable(color, ~onLight=?maybeLight, ~onDark=?maybeDark, ())
    Utils.colorToCss(read)
  | None =>
    Js.log("Readable failed. Given css color(s) was invalid")
    cssColor
  }

let opacify = (cssColor: Css.Types.Color.t, amount: float): Css.Types.Color.t =>
  switch Utils.cssToColor(cssColor) {
  | Some(color) => Color.opacify(color, Color.Types.Percent.make(amount))->Utils.colorToCss
  | None =>
    Js.log("Opacify failed. Given css color(s) was invalid")
    cssColor
  }

let darken = (cssColor: Css.Types.Color.t, amount: float): Css.Types.Color.t =>
  switch Utils.cssToColor(cssColor) {
  | Some(color) => Color.darken(color, Color.Types.Percent.make(amount))->Utils.colorToCss
  | None =>
    Js.log("Darken failed. Given css color(s) was invalid")
    cssColor
  }

let lighten = (cssColor: Css.Types.Color.t, amount: float): Css.Types.Color.t =>
  switch Utils.cssToColor(cssColor) {
  | Some(color) => Color.lighten(color, Color.Types.Percent.make(amount))->Utils.colorToCss
  | None =>
    Js.log("Lighten failed. Given css color(s) was invalid")
    cssColor
  }

let desaturate = (cssColor: Css.Types.Color.t, amount: float): Css.Types.Color.t =>
  switch Utils.cssToColor(cssColor) {
  | Some(color) => Color.desaturate(color, Color.Types.Percent.make(amount))->Utils.colorToCss
  | None =>
    Js.log("Desaturate failed. Given css color(s) was invalid")
    cssColor
  }

let invert = (cssColor: Css.Types.Color.t): Css.Types.Color.t =>
  switch Utils.cssToColor(cssColor) {
  | Some(color) => Color.invert(color)->Utils.colorToCss
  | None =>
    Js.log("Invert failed. Given css color(s) was invalid")
    cssColor
  }

let mix = (
  cssColor: Css.Types.Color.t,
  cssBaseColor: Css.Types.Color.t,
  weight: float,
): Css.Types.Color.t =>
  switch (Utils.cssToColor(cssColor), Utils.cssToColor(cssBaseColor)) {
  | (Some(color), Some(baseColor)) =>
    let value = Color.mix(color, baseColor, Color.Types.Percent.make(weight))
    Utils.colorToCss(value)
  | (Some(_), None) | (None, Some(_)) | (None, None) =>
    Js.log("Mix failed. One or both of the given css color(s) was invalid")
    cssBaseColor
  }

let shade = (cssColor: Css.Types.Color.t, amount: float): Css.Types.Color.t =>
  switch Utils.cssToColor(cssColor) {
  | Some(color) =>
    let value = Color.shade(color, Color.Types.Percent.make(amount))
    Utils.colorToCss(value)
  | None =>
    Js.log("Shade failed. Given css color(s) was invalid")
    cssColor
  }

let tint = (cssColor: Css.Types.Color.t, amount: float): Css.Types.Color.t =>
  switch Utils.cssToColor(cssColor) {
  | Some(color) =>
    let value = Color.tint(color, Color.Types.Percent.make(amount))
    Utils.colorToCss(value)
  | None =>
    Js.log("Shade failed. Given css color(s) was invalid")
    cssColor
  }

let setAlpha = (cssColor: Css.Types.Color.t, percentage: float): Css.Types.Color.t => {
  let maybeColor = Utils.cssToColor(cssColor)
  let percent = Color.Types.Percent.make(percentage)
  switch maybeColor {
  | Some(c) =>
    let tr = c->Color.setAlpha(percent)
    let newColor = Utils.colorToCss(tr)
    newColor
  | _ =>
    Js.log("setAlpha failed. Given percentage or css color was invalid")
    cssColor
  }
}
