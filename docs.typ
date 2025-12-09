#import "src/lib.typ" as stack

#let draw-anchor(anc, factor) = {
  import "@preview/cetz:0.3.4"
  import cetz.draw: *
  line(
    (anc.x*factor, anc.y*factor),
    (
      (anc.x + 5*calc.cos(anc.rot+90deg))*factor, 
      (anc.y + 5*calc.sin(anc.rot+90deg))*factor
    ),
    stroke: green,
  ); // normal
  line(
    (anc.x*factor, anc.y*factor),
    (
      (anc.x + 2*calc.cos(anc.rot))*factor, 
      (anc.y + 2*calc.sin(anc.rot))*factor
    ),
    stroke: red,
  ); // tangent
}

#let draw-anchors(objs, factor) = {
  for obj in objs {
    for anc in obj("anchors").values() {
      draw-anchor(anc, factor)
    }
  }
}

#let wireframe(..objs, factor: 0.5mm, debug: false) = {
  let objs = objs.pos().flatten()
  import "@preview/cetz:0.3.4" as cetz
  cetz.canvas({
    import cetz.draw: *
    for obj in objs {
      if obj("type") == "rect" {
        line(close: true,
          (obj("tl")().x * factor, obj("tl")().y * factor),
          (obj("tr")().x * factor, obj("tr")().y * factor),
          (obj("br")().x * factor, obj("br")().y * factor),
          (obj("bl")().x * factor, obj("bl")().y * factor), 
        );
      } else if obj("type") == "line" {
        line(close: false,
          (obj("start")().x * factor, obj("start")().y * factor),
          (obj("end")().x * factor, obj("end")().y * factor),
        );
      } else if obj("type") == "circle" {
        circle((obj("c")().x*factor, obj("c")().y*factor), radius: obj("data").radius*factor);
      } else if obj("type") == "incline" {
        line(close: true,
          (obj("tr")().x * factor, obj("tr")().y * factor),
          (obj("tl")().x * factor, obj("tl")().y * factor),
          (obj("br")().x  * factor, obj("br")().y  * factor),
        );
      } else if obj("type") == "arrow" {
        line(
          (obj("start")().x * factor, obj("start")().y * factor),
          (obj("end")().x * factor, obj("end")().y * factor),
          mark: (end: "stealth", fill: black),
        );
      } else if obj("type") == "point" {
        circle((obj("c")().x*factor, obj("c")().y*factor), stroke: none, fill: black, radius: 1*factor);
      } else if obj("type") == "rope" {
        panic("TODO")
      } else {
        panic("Unknown object type: " + obj("type"))
      }
    }
    if debug { draw-anchors(objs, factor) }
  })
}

#{
  import stack: *

  let (I, A, B, C) = (none,)*4;
  I = incline(150, 20deg)
  A = rect(50, 30)
  A = stick(A("bl"), I("tl"))
  A = slide(A("c"), 30, 0)
  B = slide(stick(rect(10,10)("bl"),A("tl")), -5, 0)
  C = match(circle(10)("bl"),I("rt"), rot: false)
  C = rotate(move(C, 30, 15), -23deg)

  let weight = rotate(arrow(A("c"), 40, rot: false), -90deg)
  let friction = rotate(arrow(A("c"), 30), -90deg)
  let normal = arrow(A("c"), 25)
  let P = point(anchors.x-inter-y(A("c"), I("tr")))
  let Q = point(anchors.lerp(P, I("rt"), 50%))

  let my-rope = rope(A("r"), C("tr"), I("br"))
  repr(my-rope("repr"))

  wireframe(I, A, B, C, weight, friction, normal, P, Q, debug: true)
}

#{
  import stack: *
  let inc = rotate(incline(100, 15deg), 20deg, ref: (0,0))
  let force = arrow((0,0), 100)

  wireframe(force, debug: true)
}

#{
  import stack: *
  let block = rotate(rect(40, 20), 30deg)
  let force = arrow(block("c"), 90)

  wireframe(block, force, debug: true)
}