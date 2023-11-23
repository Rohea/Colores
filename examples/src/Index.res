module Transparentize = {
  module Styles = {
    open CssJs
    let getRedBox = () => style([backgroundColor(rgba(255, 0, 0, #num(1.0)))])
    let getRedBoxTransparentize = () =>
      style([backgroundColor(rgba(255, 0, 0, #percent(100.0))->ColoresCss.transparentize(0.5))])
  }

  @react.component
  let make = () => <>
    <h1> {React.string("Transparentize")} </h1>
    <div className={Styles.getRedBox()}> {React.string("RedBox RGBA")} </div>
    <div className={Styles.getRedBoxTransparentize()}>
      {React.string("RedBox RGBA transparentize")}
    </div>
  </>
}

let rgbToString = (r: int, g: int, b: int) =>
  "(" ++ (string_of_int(r) ++ ("," ++ (string_of_int(g) ++ ("," ++ (string_of_int(b) ++ ")")))))

module Readable = {
  module Styles = {
    open CssJs
    let numCols = 4.0
    let getColumn1 = (rgbVal: int) =>
      style([
        width(pct(100.0 /. numCols)),
        CssJs.float(#left),
        backgroundColor(#rgb(rgbVal, rgbVal, rgbVal)),
        color(#rgb(rgbVal, rgbVal, rgbVal)->ColoresCss.readable()),
      ])
    let getColumn2 = (rgbVal: int) => {
      let darkColor = hex("181818")
      let lightColor = hex("999999")
      let bgColor = rgb(rgbVal, rgbVal, rgbVal)
      style([
        width(pct(100.0 /. numCols)),
        CssJs.float(#left),
        backgroundColor(bgColor),
        color(bgColor->ColoresCss.readable(~onLight=darkColor, ~onDark=lightColor, ())),
      ])
    }
    let getColumn3 = (rgbVal: int) => {
      let darkColor = hex("770000")
      let lightColor = hex("ffffff")
      let bgColor = rgb(225, rgbVal - 30, rgbVal - 30)
      style([
        width(pct(100.0 /. numCols)),
        CssJs.float(#left),
        backgroundColor(bgColor),
        color(bgColor->ColoresCss.readable(~onLight=darkColor, ~onDark=lightColor, ())),
      ])
    }
    let getColumn4 = (rgbVal: int) => {
      let darkColor = hsl(deg(112.0), #percent(100.0), #percent(10.0))
      let lightColor = hsl(deg(112.0), #percent(1.0), #percent(90.0))
      let bgColor = rgb(rgbVal, rgbVal, rgbVal)
      style([
        width(pct(100.0 /. numCols)),
        CssJs.float(#left),
        backgroundColor(bgColor),
        color(bgColor->ColoresCss.readable(~onLight=darkColor, ~onDark=lightColor, ())),
      ])
    }
  }
  @react.component
  let make = () => {
    let arr = Belt.Array.make(52, ())
    let items: array<React.element> = arr->Belt.Array.mapWithIndex((index, _item) => {
      let rgbVal = index * 5
      <div key={string_of_int(index)}>
        <div className={Styles.getColumn1(rgbVal)}>
          {React.string("Default on " ++ rgbToString(rgbVal, rgbVal, rgbVal))}
        </div>
        <div className={Styles.getColumn2(rgbVal)}>
          {React.string("Darks on " ++ rgbToString(rgbVal, rgbVal, rgbVal))}
        </div>
        <div className={Styles.getColumn3(rgbVal)}> {React.string("Reds on something")} </div>
        <div className={Styles.getColumn4(rgbVal)}>
          {React.string("HSL green on " ++ rgbToString(rgbVal, rgbVal, rgbVal))}
        </div>
      </div>
    })
    <>
      <h1> {React.string("Readable")} </h1>
      {items->React.array}
    </>
  }
}

module Main = {
  @react.component
  let make = () => <>
    <Transparentize />
    <Readable />
  </>
}

switch ReactDOM.querySelector("#root") {
| Some(rootElement) => {
    let root = ReactDOM.Client.createRoot(rootElement)
    ReactDOM.Client.Root.render(root, <Main />)
  }
| None => ()
}
