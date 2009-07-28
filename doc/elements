# Architecture

## Layout

A layout is a plugin with a method `layout` taking a rectangle and a hash of
elements (board, clocks, pools...), and calling `set_geometry` on each of those
objects, disposing them inside the given rectangle.

## Board

The `Board` is the main game area, where pieces are shown and moved. A board is
a rectangular element, divided in equally sized squares, in numbers dictated by
`@game.size`.

The `Board` class includes `PointConverter`, which converts *logical*
coordinates to actual coordinates on the canvas (called *real*).
To do so, the *flipped* state of the board is taken into consideration.

`Board` is a `Qt::GraphicsItemGroup`, containing pieces (and other subelements,
like the background and square highlighting) as items, stored in the `@items`
hash. 

When the board is resized, the `set_geometry` method is called by the parent
`Layout` object, and all its items are recreated. This happens inside the
`reload_item` method, which selects how to recreate items based on their key.
Read/write access to items is provided by the `ItemBag` module.

## Pool

`Pool` is a part of the gaming area where captured pieces are shown in games
like Shogi and Crazyhouse. It is very similar in structure to `Board`, with
which it shares some of the included modules.

Items are stored in an array instead of a hash. Since `ItemBag` only works with
hashes of items, `Pool` uses a helper class `ExtraItemContainer` which mixes
`ItemBag` in and provides support for redrawing square highlighting items.

Most of the logic for moving pieces around in the pool is provided by the
`PoolAnimator` class. The main method of this class is `warp`, which takes a
pool object (a set-like object containing pieces), compares it with the current
state of the parent `Pool` object, and returns an animation that adds, removes,
and/or moves pieces around, so that they match.



