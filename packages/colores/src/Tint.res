open Types

@ocaml.doc("
 * Tints a color by mixing it with white. `tint` can produce
 * hue shifts, where as `lighten` manipulates the luminance channel and therefore
 * doesn't produce hue shifts.
 *
 * NOTE: This implementation deviate from original polished implementation, where tint
 * would alter the alpha value of transparent colors.
 * In this implementation the alpha value is preserved.
 ")
module Impl = {
  let tint = (color: color, amount: Percent.t): color =>
    Mix.mix(RGB(RGB.fromPrimitives(255, 255, 255)), color, amount)

  let tintRGBA = (rgba: RGBA.t, amount: Percent.t): color => {
    let alpha = RGBA.alpha(rgba)
    let rgb = Utils.convertRGBAtoRGB(rgba)

    let tintdRgb = tint(RGB(rgb), amount)
    Transparentize.transparentize(tintdRgb, alpha)
  }

  let tintHSLA = (hsla: HSLA.t, amount: Percent.t): color => {
    let alpha = HSLA.alpha(hsla)
    let hsl = Utils.convertHSLAtoHSL(hsla)

    let tintedHsl = tint(HSL(hsl), amount)
    Transparentize.transparentize(tintedHsl, alpha)
  }
}

let tint = (color: color, amount: Percent.t) =>
  switch color {
  | RGB(_) | HEX(_) | HSL(_) => Impl.tint(color, amount)
  | RGBA(rgbaColor) => Impl.tintRGBA(rgbaColor, amount)
  | HSLA(hslaColor) => Impl.tintHSLA(hslaColor, amount)
  }
