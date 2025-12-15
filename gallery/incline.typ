#import "../src/lib.typ" as patatrac
#import "@preview/cetz:0.3.4" as cetz: canvas

#set page(width: 10cm, height: 6cm)
#set text(size: 15pt)

#place(center + horizon, canvas(length: 0.5mm, {
  import patatrac: *
  let draw = patatrac.renderers.cetz.standard

  let sideA = 20
  let sideB = 15
  let radiusC = 5
  let hang = 15

  let I = incline(150, 25deg)

  let A = rect(sideA,sideA)
  A = stick(A("bl"), I("tl"))
  A = slide(A, -40, 0)

  let centerC = anchors.slide(I("tr")(), hang, sideA/2 - radiusC)
  let C = place(circle(radiusC), centerC)
  let L = rope(C(), I("tr"))
  
  let B = move(place(rect(sideB, sideB), C("r")), 0, -40)
  let R = rope(A("r"), C("t"), B("t"))

  draw(L, stroke: 2pt)
  draw(I, C, stroke: 2pt, fill: luma(90%))
  draw(R, stroke: 2pt + rgb("#995708"))
  
  let tension1 = arrow(A("r"), 20)
  let tension2 = arrow(B("t"), 20)
  
  draw(tension1, tension2, stroke: 2pt)
  draw(point(tension1("end"), rot: false), lx: -8, ly: 2, label: math.arrow($T_1$), align: bottom)
  draw(point(tension2("c"), rot: false), lx: 10, label: math.arrow($T_2$), align: bottom)
  draw(point(C("c")))
  
  draw(A, fill: blue, stroke: 2pt + blue.darken(60%))
  draw(B, fill: red, stroke: 2pt + red.darken(60%))
  draw(point(A("c")), label: text(fill: white, $M$))
  draw(point(B("c")), label: text(fill: white, $m$), ly: 1)
  
  let coord(a) = { let a = anchors.to-anchor(a); return (a.x, a.y) }
  cetz.angle.angle(label: $alpha$, radius: 30, label-radius: 38, stroke: 2pt, 
    coord(I("bl")), 
    coord(I("br")), 
    coord(I("tr")), 
  )
}.flatten()))