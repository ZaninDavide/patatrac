#import "anchors.typ" as anchors: anchor, to-anchor

// -----------------------------> OBJECTS CREATION

/* 
An object is a collection of anchors with a specified active anchor and some metadata.
An object `οbj` is represented by a callable function such that:
 - `obj()` returns the active anchor (equivalent to `obj("anchors").at(obj("active"))`),
 - `obj("anchor-name")` returns an equivalent object but with the specified anchor as active,
 - `obj("anchors")` returns the full dictionary of anchors,
 - `obj("active")` returns the key of the active anchor,
 - `obj("type")` returns the object type (`"line"`, `"rect"`, `"circle"`, etc).
 - `obj("data")` returns the carried metadata.
 - `obj("repr")` returns a dictionary representation of the object meant only for debugging purposes.
This constructor takes three positional arguments
 - `obj-type`: a `str` that labels the kind of object described by the anchors,
 - `active`: a `str` equal to the name of the active anchor,
 - `anchors`: a `dictionary` with string valued keys and anchor valued fields that constitutes the named collection of anchors in the object.
and one named argument
  - `data` (default `none`): some metadata. `any` type is allowed but conventionally `none` and `dictionary` are preferred.

Important design choices:
 - The set of anchors an object carries is not minimal in any sense. The collection of anchors should contain 
   most of the anchors that the user may find helpful when constructing a diagram. 
 - The information encoded inside `data` is never touched by transformations of the objects, 
   e.g. rotations and translations, therefore the payload should not contain information 
   about properties of the object that change under such transformations. No function defined in this package 
   scales objects therefore geometrical properties (like angles and lengths) can be part of the information.
 - The information encoded inside `data` should not be of artistic/cosmetic nature: no colors, strokes or printed 
   labels. String ids are allowed but for internal use: not meant to be printed text inside the final image. 
 - Nothing prevents the definition of anchors named "anchors", "active", "type", "data" or "repr", nevertheless they 
   won't be accessible via the notation `obj("anchor-name")` but rather only via `obj("anchors").at("anchor-name")`.
*/
#let object(obj-type, active, anchors, data: none) = (..args) => {
  let args = args.pos()
  if args.len() == 0 { return anchors.at(active) }
  if args.len() >  1 { panic("Cannot specify more than one key") }
  if not (active in anchors.keys()) { panic("The specified active anchor \"" + repr(active) + "\" is not a valid as it is not part of the specified list of anchors in this object.") }
  
  let key = args.at(0)
  if type(key) == str {
    if key == "anchors" {
      return anchors
    } else if key == "active" {
      return active
    } else if key == "type" {
      return obj-type
    } else if key == "data" {
      return data
    } else if key == "repr" {
      return ("type": obj-type, "active": active, "anchors": anchors, "data": data)
    } else if key in anchors.keys() {
      return object(obj-type, key, anchors, data: data)
    } else {
      panic("Cannot activate anchor \"" + repr(active) + "\" as it is not part of the specified list of anchors in this object. This object contains the following anchors: " + repr(anchors.keys()))
    }
  }

  panic("Unknown argument type '" + repr(type(key)) + "', '" + repr(str) + "' was expected.")
}

// -----------------------------> STANDARD OBJECTS CONSTRUCTORS

/*
A rectangle
*/
#let rect(width, height) = object("rect", "c",
  (
    "c": anchor(width*0, height*0, 0deg), // do not use (0,0) which would assume unitless coordinates

    "tl": anchor(-width/2, +height/2, 0deg),
    "t": anchor(0*width, +height/2, 0deg),
    "tr": anchor(+width/2, +height/2, 0deg),

    "lt": anchor(-width/2, +height/2, 90deg),
    "l": anchor(-width/2, 0*height, 90deg),
    "lb": anchor(-width/2, -height/2, 90deg),
    
    "bl": anchor(-width/2, -height/2, 180deg),
    "b": anchor(0*width, -height/2, 180deg),
    "br": anchor(+width/2, -height/2, 180deg),

    "rt": anchor(+width/2, +height/2, 270deg),
    "r": anchor(+width/2, 0*height, 270deg),
    "rb": anchor(+width/2, -height/2, 270deg),
  ),
  data: ("width": width, "height": height)
)

#let circle(radius) = {
  let sqrt2 = calc.sqrt(2)
  return object("circle", "c", data: ("radius": radius), (
    "c": anchor(radius*0, radius*0, 0deg), // do not use (0,0) which would assume unitless coordinates
    
    "t": anchor(radius*0, +radius, 0deg),

    "lt": anchor(-radius/sqrt2, +radius/sqrt2, 45deg),
    "tl": anchor(-radius/sqrt2, +radius/sqrt2, 45deg),
    
    "l": anchor(-radius, radius*0, 90deg),
    
    "bl": anchor(-radius/sqrt2, -radius/sqrt2, 90deg+45deg),
    "lb": anchor(-radius/sqrt2, -radius/sqrt2, 90deg+45deg),
    
    "b": anchor(radius*0, -radius, 180deg),

    "rb": anchor(+radius/sqrt2, -radius/sqrt2, 180deg+45deg),
    "br": anchor(+radius/sqrt2, -radius/sqrt2, 180deg+45deg),
    
    "r": anchor(+radius, radius*0, 270deg),

    "tr": anchor(+radius/sqrt2, +radius/sqrt2, 270deg+45deg-360deg),
    "rt": anchor(+radius/sqrt2, +radius/sqrt2, 270deg+45deg-360deg),
  ))
}

#let incline(width, angle) = {
  if angle > 90deg or angle < -90deg {
    panic("Incline angle must be between -90deg and 90deg")
  } else if angle > 0deg {
    return object("incline", "bl", 
      (
        "tl": anchor(width*0, width*0, angle),
        "t":  anchor(width/2, width/2*calc.tan(angle), angle),
        "tr": anchor(width, width*calc.tan(angle), angle),
        
        "rt": anchor(width, width*calc.tan(angle), -90deg),
        "r":  anchor(width, width/2*calc.tan(angle), -90deg),
        "rb": anchor(width, width*0, -90deg),
        
        "bl": anchor(width*0, width*0, 180deg),
        "b": anchor(width/2, width*0, 180deg),
        "br": anchor(width, width*0, 180deg),
      ), 
      data: (
        "width": width, 
        "height": width*calc.tan(angle), 
        "angle": angle
      )
    ) 
  } else if angle < 0deg {
    panic("TODO")
  }
}

#let arrow(start, length, rot: true) = {
  let start = to-anchor(start) 
  if not rot { start = anchor(start.x, start.y, 0deg) }
  return object("arrow", "start", 
    (
      "start": start,
      "end": anchors.slide(start, length*0, length),
    ),
    data: ("length": length)
  )
}

#let point(at, rot: true) = {
  let anc = to-anchor(at)
  if not rot { anc = anchor(anc.x, anc.y, 0deg) }
  return object("point", "c", ("c": anc))
}

/*
A `rope` is an objects that represents a one dimensional string that wraps around
points and circles. 

Abstractly, a `rope` is completely specified by its anchors
and an associated list of non-negative radii associated with each anchor. The anchors 
location specify the points the rope wraps around and the associated radii specify 
the distance the rope keeps from the before mentioned points. The anchors rotation is
used to determine in which direction the rope must go around the points. If the anchor
has a zero radii that the rope passes through the anchor's location. If the anchor is 
the first or last anchor, the rope passes through the anchor's location even if a 
non-zero radii is specified. If the rope can wrap around an anchors' location with 
positive radii in two ways than the rotation of the anchor dictates the direction in 
which the rope wraps around it. The anchor specifies a coordinate system in which we
can measure angle from 0 to 2pi. Every wrap-around direction is associated with a 
unique range of angles between 0 and 2pi that describes the arc of circumference 
traveled by the rope. The wrap-around direction chosen is the one whose associate 
range of angles has the lowest median angle. _Intuitively, the rope wants to wrap
from the top of the local coordinate system_.
The heavy lifting of computing the wrapping is done by whatever drawing function
will create the drawing: the rope object itself is just a container of information.

This `rope(...)` function takes an arbitrary number of parameters. Every argument
specifies an anchor and its associated radii. In order to specify an anchor with 
an associated radii of zero, anything that can be converted to an anchor is fine, 
but if an anchor of non-zero radii is desired than a `circle` is required: the 
anchor's location is taken to be the circles center, the anchor's rotation is taken 
to be the rotation of the active anchor of the circle and the wrap-around radius 
is taken to be the circle's radius. The function returns an object of type `"rope"` with the 
inputted anchors as anchors and the associated radii stored in the metadata. 
The anchors names are consecutive numbers, starting from 0, converted to string. 
The first and last anchors appear twice: also renamed "start" and "end" respectively.
*/
#let rope(..args) = {
  let nodes = args.pos()

  if nodes.len() < 2 { panic("The function `rope` expects at least 2 positional arguments") }

  let ancs = (:)
  let radii = (:)

  for (i, node) in nodes.enumerate() {
    if type(node) == function and node("type") == "circle" {
      // this is a circle
      let anchor = node("anchors").at("c") // located at the circle's center
      anchor.rot = node().rot // rotated as the active anchor
      ancs.insert(str(i), anchor)
      radii.insert(str(i), node("data").radius)
    } else {
      // assume this can be converted to an anchor (radius = 0)
      let anc = anchors.to-anchor(node)
      ancs.insert(str(i), anc)
      radii.insert(str(i), anc.x*0)
    }
  }

  ancs.insert("start", ancs.at("0"))
  radii.insert("start", radii.at("0"))
  ancs.insert("end", ancs.at(str(nodes.len() - 1)))
  radii.insert("end", radii.at(str(nodes.len() - 1)))

  return object("rope", "start", ancs, data: ("count": nodes.len(), "radii": radii))
}