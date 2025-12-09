#import "renderer.typ": renderer
#import "@preview/cetz:0.3.4" as cetz

#let wireframe = {

  let draw-rect = (obj, stroke: 1pt) => {
    let points = obj("anchors")
    cetz.draw.line(close: true, stroke: stroke,
      (points.tl.x, points.tl.y),
      (points.tr.x, points.tr.y),
      (points.br.x, points.br.y),
      (points.bl.x, points.bl.y), 
    )
  }

  let draw-circle = (obj, stroke: 1pt) => {
    let points = obj("anchors")
    cetz.draw.circle(stroke: stroke,
      (points.c.x, points.c.y), 
      radius: obj("data").radius
    )
  }
  
  let draw-incline = (obj, stroke: 1pt) => {
    let points = obj("anchors")
    cetz.draw.line(close: true, stroke: stroke,
      (points.tr.x, points.tr.y),
      (points.tl.x, points.tl.y),
      (points.br.x, points.br.y),
    )
  }
  
  let draw-arrow = (obj, stroke: 1pt) => {
    let points = obj("anchors")
    cetz.draw.line(stroke: stroke,
      (points.start.x, points.start.y),
      (points.end.x, points.end.y),
      mark: (end: "stealth", fill: black),
    )
  }
  
  let draw-point = (obj, fill: black) => {
    let points = obj("anchors")
    cetz.draw.circle(stroke: none, fill: fill, radius: 1,
      (points.c.x, points.c.y)
    );
  }
  
  let draw-rope = (obj) => {
    panic("TODO")
  }

  renderer((
    "rect": draw-rect,
    "circle": draw-circle,
    "incline": draw-incline,
    "arrow": draw-arrow,
    "point": draw-point,
    "rope": draw-rope,
  ))
}

#let debug = {
  let draw-anchors(obj) = {
    for anc in obj("anchors").values() {
      // normal
      cetz.draw.line(
        (anc.x, anc.y),
        (
          (anc.x + 5*calc.cos(anc.rot+90deg)), 
          (anc.y + 5*calc.sin(anc.rot+90deg))
        ),
        stroke: 1pt + green,
      )
      // tangent
      cetz.draw.line(
        (anc.x, anc.y),
        (
          (anc.x + 2*calc.cos(anc.rot)), 
          (anc.y + 2*calc.sin(anc.rot))
        ),
        stroke: 1pt + red,
      )
    }
  };

  renderer((
    "rect": draw-anchors,
    "circle": draw-anchors,
    "incline": draw-anchors,
    "arrow": draw-anchors,
    "point": draw-anchors,
    "rope": draw-anchors,
  ))
}