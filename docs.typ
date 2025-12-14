#import "src/lib.typ" as patatrac
#import "@preview/cetz:0.3.4" as cetz: canvas

#show title: it => {
  set text(size: 50pt)
  align(center, it)
}

#show quote: it => {
  set text(style: "italic", size: 15pt)
  align(center, pad(it, top: 0pt, bottom: 20pt, left: 50pt, right: 50pt))
}

#set text(size: 12pt)
#set page(margin: (left: 4cm, top: 3cm, bottom: 3cm, right: 4cm), footer:  context {
  set align(center)
  v(1fr)
  counter(page).display("1")
  v(1fr)
})
#set par(justify: true)
#set heading(numbering: "1.1")

#import "@preview/zebraw:0.6.1": zebraw
#show raw.where(block: false): set raw(lang: "typc")
#show raw.where(block: true): zebraw.with(background-color: luma(96%), numbering-separator: true, lang: false)

#let canvas = canvas.with(length: 0.5mm)
#let canvas = (..args) => {
  set text(size: 15pt)
  align(center, canvas(..args))
}

#place(top + center, scope: "parent", float: true, {
  title[patatrac]

  v(-10pt)

  canvas({
    import "src/lib.typ" as patatrac: *
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
    
  }.flatten())

  v(10pt)

  quote[
    the sound of something large and complex\ suddenly collapsing onto itself
  ]

  v(100pt)
})

= Introduction
This Typst package provides help with the typesetting of physics diagrams depicting classical mechanical systems.  The goal: 

#align(center, [_creating beautiful diagrams without doing trigonometry._])

The workflow is based on a _strict separation between the composition and the rendering_ (drawing) of the diagrams. The composition stage is 100% agnostic of the rendering engine used for drawing.

= Tutorial
In this tutorial we will assume that #link("https://typst.app/universe/package/cetz")[`cetz`] is the rendering engine of choice, which for the moment is the only one supported out of the box. The goal is to draw the figure below: two boxes connected by a spring. 

#canvas({
  import "src/lib.typ" as patatrac: *
  let draw = patatrac.renderers.cetz.standard

  let A = rect(15,15)
  let B = move(rect(15,15), 50, 0)
  let k = spring(A("r"), B("l"))
  let floor = place(rect(100, 20)("t"), (k("c")().x, A("b")().y))

  draw(floor, fill: luma(90%), stroke: none)
  draw(k, radius: 6, pitch: 4, pad: 3, stroke: 1pt)
  draw(A, stroke: 2pt, fill: red)
  draw(B, stroke: 2pt, fill: blue)
  draw(point(k("c")), label: $k$, anchor: bottom, ly: 15)
}.flatten())

Let's start with the boilerplate required to import `patatrac` and `cetz`.

```typ
#import "@preview/cetz:0.3.4" as cetz
#cetz.canvas(length: 0.5mm, {
  import "@preview/patatrac:0.0.0" as patatrac: *
  let draw = patatrac.renderers.cetz.standard

  () // Composition & Rendering
}.flatten())
```

At line 4, we take the cetz standard renderer provided by `patatrac` and call it `draw`. The renderer will take care of outputting `cetz` elements that the canvas can print. From now on, we will only show what goes in the place of line 6, but remember that the boilerplate is still there. Let's start by adding the floor to our scene.

```typc
let floor = rect(100, 20)
draw(floor)
```

Line 1 creates a new patatrac `object` of type `"rect"`, which under the hood is a special function that represents our $100 times 20$ rectangle.

#canvas({
  import patatrac: *
  let draw = patatrac.renderers.cetz.standard
  let floor = rect(100, 20)
  draw(floor)
}.flatten())

Every object carries with it a set of anchors. Every anchor is a point in space with a specified orientation. As anticipated, objects are functions. In particular, if you call an object on the string `"anchors"`, a complete dictionary of all its anchors is returned. For example, `floor("anchors")` gives

#raw(repr(patatrac.rect(100,20)("anchors")), lang: "typc")

The anchors are placed both at the vertices and at the centers of the faces of the rectangle and their rotation specify the tangent direction at every point. If you pay attention you will see that the rotation of the anchors is an angle which increases as one rotates counter-clockwise and with zero corresponding to the right direction. If you use the renderer `patatrac.renderers.cetz.debug` you will see exactly where and how the anchors are placed: red corresponds to the tangent (local-$x$) direction and green to the normal (local-$y$) direction.

```typc
draw(floor)
patatrac.renderers.cetz.debug(floor)
```
#canvas({
  import patatrac: *
  let draw = patatrac.renderers.cetz.standard
  let debug = patatrac.renderers.cetz.debug
  let floor = rect(100, 20)
  draw(floor)
  debug(floor)
}.flatten())

As you can see, the central anchor is drawn a bit bigger and thicker. The reason is that `c` is, by default, what we call the _active anchor_. We can change the active anchor of an object by calling the object itself on the name of the anchor. For example if we instead draw the anchors of the object `floor("t")` what we get is the following.

```typc
draw(floor)
patatrac.renderers.cetz.debug(floor("t"))
```
#canvas({
  import patatrac: *
  let draw = patatrac.renderers.cetz.standard
  let debug = patatrac.renderers.cetz.debug
  let floor = rect(100, 20)
  draw(floor)
  debug(floor("t"))
}.flatten())

When doing so we have to remember that Typst functions are pure: don't forget to reassign your objects if you want the active anchor to change "permanently"! 

Now, let's add in the two blocks. First of all, we need to place the blocks on top of the floor. To do so we use the `place` function which takes two objects and gives as a result the first object translated such that its active anchor location overlaps with that of the second object.
```typc
let floor = rect(100, 20)

let A = rect(15, 15)
let B = rect(15, 15)

A = place(A("bl"), floor("tl"))
B = place(B("br"), floor("tr"))

draw(floor, A, B)
```

#canvas({
  import patatrac: *
  let draw = patatrac.renderers.cetz.standard
  let floor = rect(100, 20)
  let A = rect(15, 15)
  let B = rect(15, 15)

  A = place(A("bl"), floor("tl"))
  B = place(B("br"), floor("tr"))
  
  draw(floor, A, B)
}.flatten())


Now we should move the blocks a bit closer and add the spring.
```typc
let floor = rect(100, 20)
let A = rect(15, 15)
let B = rect(15, 15)

A = place(A("bl"), floor("tl"))
B = place(B("br"), floor("tr"))

A = move(A, +20, 0)
B = move(B, -20, 0)

let k = spring(A("r"), B("l"))

draw(floor, A, B, k)
```

#canvas({
  import patatrac: *
  let draw = patatrac.renderers.cetz.standard
  let floor = rect(100, 20)
  let A = rect(15, 15)
  let B = rect(15, 15)

  A = place(A("bl"), floor("tl"))
  B = place(B("br"), floor("tr"))

  A = move(A, +20, 0)
  B = move(B, -20, 0)
  
  let k = spring(A("r"), B("l"))

  draw(floor, A, B, k)
}.flatten())


The styling is pretty self-explanatory. The only thing to notice is that objects drawn with the same call to `draw` share the same styling options, therefore multiple calls to `draw` are required for total stylistic freedom.
```typc
// ...

draw(floor, fill: luma(90%), stroke: none)
draw(k, radius: 6, pitch: 4, pad: 3)
draw(A, stroke: 2pt, fill: red)
draw(B, stroke: 2pt, fill: blue)
draw(point(k("c")), label: $k$, anchor: bottom, ly: 15)
```

#canvas({
  import patatrac: *
  let draw = patatrac.renderers.cetz.standard
  let floor = rect(100, 20)
  let A = rect(15, 15)
  let B = rect(15, 15)

  A = place(A("bl"), floor("tl"))
  B = place(B("br"), floor("tr"))

  A = move(A, +20, 0)
  B = move(B, -20, 0)
  
  let k = spring(A("r"), B("l"))

  draw(floor, fill: luma(90%), stroke: none)
  draw(k, radius: 6, pitch: 4, pad: 3)
  draw(A, stroke: 2pt, fill: red)
  draw(B, stroke: 2pt, fill: blue)
  draw(point(k("c")), label: $k$, anchor: bottom, ly: 15)
}.flatten())

#pagebreak()

= Examples

#canvas({
  import "src/lib.typ" as patatrac: *
  let draw = patatrac.renderers.cetz.standard

  let A = rect(50*1.6, 50)
  let B = place(rect(25,25)("bl"), A("br"))
  let F = place(arrow((0,0), 50, angle: 0deg)("end"), A("l"))
  let floor = move(place(rect(200, 30)("t"), A("b")), 10, 0)
  
  draw(floor, fill: luma(90%), stroke: none)
  draw(A, fill: blue, stroke: 2pt + blue.darken(60%))
  draw(B, fill: red, stroke: 2pt + red.darken(60%))
  draw(point(A("c")), label: text(fill: white, $M$), fill: white)
  draw(point(B("c")), label: text(fill: white, $m$), fill: white, align: center, ly: 1.5)
  draw(F, stroke: 2pt)
  draw(point(F("c"), rot: false), align: bottom, label: math.arrow($F$), ly: 5)

}.flatten())


#let stripes(fill, stroke, width, angle: 60deg) = {
  assert(angle >  0deg)
  assert(angle < 90deg)
  return tiling(
    size: (width, width*calc.tan(angle)), {
      place(rect(width: 100%, height: 100%, fill: fill))
      place(line(start: (0%, 0%), end: (100%, 100%), stroke: stroke))
      place(line(start: (100%, 0%), end: (200%, 100%), stroke: stroke))
      place(line(start: (0%, 100%), end: (100%, 200%), stroke: stroke))
      place(line(start: (-100%, 0%), end: (0%, 100%), stroke: stroke))
      place(line(start: (0%, -100%), end: (100%, 0%), stroke: stroke))
    }
  )
}

#canvas(length: 0.5mm, {
  import "src/lib.typ" as patatrac: *
  let draw = patatrac.renderers.cetz.standard

  let ceiling = move(rect(130, 20), 30, 5)
  let radius = 15

  let C1 = move(circle(radius), 50, -30)
  let A = move(place(rect(15, 15), C1("r")), 0, -60)
  let L1 = rope(C1, anchors.y-inter-x(C1, ceiling("bl")))

  let C2 = circle(radius)
  C2 = stick(C2("r"), C1("l"))
  C2 = move(C2, 0, -50)

  let C3 = circle(radius)
  C3 = place(C3("r"), C2("c"))
  C3 = move(C3, 0, -50)

  let rope23 = rope(C2("c"), C3, (C3("l")().x, 0))
  let rope12 = rope(A("c"), C1("r"), C2("r"), (C2("l")().x, 0))

  let B = rect(20, 20)
  B = place(B, C3("c"))
  B = move(B, 0, -40)
  let ropeB = rope(B, C3("c"))

  draw(C1, C2, C3, stroke: 2pt)
  draw(rope12, stroke: 2pt + red.darken(30%))
  draw(rope23, stroke: 2pt + blue.darken(30%))
  draw(L1, ropeB, stroke: 2pt)
  draw(A, fill: red, stroke: 2pt + red.darken(30%))
  draw(B, fill: blue, stroke: 2pt + blue.darken(30%))

  let tensionA1 = arrow(A("t"), 20)
  let tensionA2 = arrow(C1("r"), 20, angle: -90deg)
  draw(stroke: 2pt + red.darken(30%),
    tensionA1, tensionA2,
    place(tensionA1, C2("r")),
    place(tensionA1, C2("l")),
    place(tensionA2, rope12("end")),
    place(tensionA2, C1("l")),
  )

  let tensionB1 = arrow(rope23("start"), 20, angle: -90deg)
  let tensionB2 = arrow(C3("r"), 20, angle: +90deg)
  draw(stroke: 2pt + blue.darken(30%),
    tensionB1,
    place(tensionB1, rope23("end")),
    tensionB2,
    place(tensionB2, C3("l"))
  )

  draw(point(rope23("end"), rot: false), label: math.arrow($T_1$), align: top + right, lx: -3, ly: -10)
  draw(point(tensionA1("end"), rot: false), label: math.arrow($T_2$), align: left, lx: 5, ly: -5)
  draw(point(C1("c")), point(C2("c")), point(C3("c")), radius: 2)
  draw(point(A("c")), label: text(fill: white, $m$), ly: 1)
  draw(point(B("c")), label: text(fill: white, $M$))
  draw(ceiling, fill: stripes(luma(90%), 7pt + luma(85%), 20pt), stroke: none)

}.flatten())

/*
#canvas(length: 0.5mm, {
  import "src/lib.typ" as patatrac: *
  let draw = patatrac.renderers.cetz.standard

  draw(circle(20), fill: tiling(image("wheel.png"), size: (20mm, 20mm)))
  draw(arrow((0,0, -90deg), 40), stroke: 3pt + red)

}.flatten()) 
*/

#outline(title: "Index")