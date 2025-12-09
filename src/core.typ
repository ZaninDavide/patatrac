#import "anchors.typ" as anchors
#import "objects.typ": object

/*
Apply function to the anchors of an object or a group of objects
*/
#let transform(obj, func) = {
  // Transform the anchors of a single object
  let tr = (o, f) => {
    let ancs = o("anchors")
    for anc in ancs.keys() {
      ancs.at(anc) = f(obj(anc)())
    }
    return object(o("type"), o("active"), ancs, data: o("data"))
  }

  return if type(obj) == array { 
    // Group of objects 
    obj.map(o => transform(o, func)) 
  } else { 
    // Single object 
    tr(obj, func) 
  }
}


// -----------------------------> TRANSLATIONS

/*
Translate the object in a rotated coordinate system.
If `rot` is `none`, the coordinate system rotation
is the active anchor of the object. If `rot` is a 
specified angle, it will be used as the reference frame rotation.
*/
#let slide(obj, dx, dy, rot: none) = transform(obj, a => anchors.slide(
  a, dx, dy, rot: if rot == none { anchors.to-anchor(obj).rot } else { rot } 
))


/*
Translates the object in global coordinates
*/
#let move = slide.with(rot: 0deg)

// -----------------------------> ROTATIONS

/*
Rotates the object around a given anchor by the specified angle. The anchor is taken to be the
active anchor of the object if `ref` is `none` otherwise `ref` itself is used as origin.
*/
#let rotate(obj, angle, ref: none) = {
  let origin = if ref == none { anchors.to-anchor(obj) } else { anchors.to-anchor(ref) }
  return transform(obj, a => anchors.pivot(a, origin, angle))
}


// -----------------------------> ROTO-TRANSLATIONS

/*
Translates and rotates an object to ensure that the active 
anchor of `obj` becomes equal to the `target`ed anchor.
*/
#let match(obj, target, x: true, y: true, rot: true) = {
  let delta = anchors.term-by-term-difference(target, obj)
  return move(rotate(obj, delta.rot, ref: anchors.to-anchor(obj)), delta.x, delta.y)
}

/*
Translates and rotates an object to ensure that the active anchor of the object becomes 
equal in origin and opposite in direction with respect to the `target`ed anchor.
*/
#let stick(obj, target) = match(obj, anchors.rotate(target, 180deg))