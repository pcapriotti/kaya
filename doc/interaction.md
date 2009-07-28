# Component interaction

## Event handling architecture

Event handling is initiated by the scene. Elements react to clicks, drags and drops simply by emitting the corresponding event with appropriate information.

At the moment, the controller is responsible for intercepting those events and reacting appropriately, by performing moves and drops.

The controller is coupled with the board and pool as far as event handling is concerned, and that makes the architecture non-modular: to add a new element to the mix, the controller must be modified to account for its events.

This will be addressed in future releases.

## Examples

### Clicking on a square

* Click on a square;
* `Scene#mouseReleaseEvent` scans its element to find the recipient   for the click event;
* `Board#on_click` emits a *click* event;
* `Controller#on_board_click` receives the event, and acts appropriately.

### Dragging a piece

* A piece is dragged from the board;
* `Scene#mousePressEvent` creates a `@drag_data` hash containing the position where the dragging started;
* `Scene#mouseMoveEvent` calls `Board#on_drag` right after a minimal distance from the starting point is reached;
* `Board#on_drag` finds the dragged item and emits a *drag* event;
* `Controller#on_board_drag` receives the event, and:
  * prepares the item for being dragged (raise and remove from the board group),
  * calles `Scene#on_drag` passing the dragged item;
* `Scene#on_drag` adds the item to the `@drag_data` hash, so that the following `mouseMoveEvent` invocations can actually move the item along with the pointer.

### Dropping a piece on the board

* A piece is dropped on the board
* `Scene#mouseReleaseEvent` calls `Board#on_drop`
* `Board#on_drop` emits a *drop* event with the source and destination coordinates.
* `Controller#on_board_drop` receives the event and performs the corresponding move.

## History

The history widget is always kept synchronized with the `History` object of the corresponding controller.

Changes in the underlying history are propagated to the widget, which proceeds to update itself to reflect those changes.

User interaction with the widget (i.e. selection of a move) results in the history object being modified.

Updates in the elements are performed by the controller in the `refresh` method, which is called in response to history update events. The controller maintains an internal index representing which state in the history is currently displayed.

The internal controller index is generally synchronized with the history index, but it can differ momentarily between a user navigation event (clicking on the history widget or activating navigation actions) and the corresponding `refresh`.

Inside `refresh`, the difference between the internal index and the history index is used to schedule an animation.

For this reason, it is important that the history index is never changed in such a way that the interval between the old value and the new value contains states which are not in the history anymore. In case it is necessary to remove states from the history, be sure to update the index *first*, then cause `refresh` to be run when the states are still in the history, and *then* remove them.

## Performing moves

Performing moves is not essentially different for navigation. When the controller logic determines that a new move has been made it calls `Match#move`, which proceeds to update the history.

The resulting change in the history causes `refresh` to be called, so that the move is actually displayed.

## The `Match` object

The `Match` object is responsible for coordinating different players playing in a given game.

### Players

There are several kinds of players:

* the **controller**, which represents the user interacting with Kaya. The controller is a somewhat special player, in that it can **control** other players (more on this later);
* **`ICSPlayer`**: represents an opponent on ICS;
* **subclasses of `Engine`**: represents an engine running as an external program;
* **`DummyPlayer`**: a player with no specific logic, usually controlled.

### Controlled players

*Controlled players* are, as the name suggests, taken over by the controller, that can play moves on their behalf.

For example, when editing a chess game, one of the player is the controller (white by convention), and the other is a controlled dummy player.

### Playing moves

Moves can be played by calling `Match#move`. It is not enforced that moves are played by the correct player, since this would complicate move handling in certain cases (e.g. controlled players, or ICS examination).

`Match#move` validates the move, adds it to the history and informs all the other players by *broadcasting* a *move* event.

### Starting a match

To start a match, all players must be registered by calling `Match#register`, and after that, all players must be marked as ready, by calling `Match#start`.

When all the players are ready, `Match` emits a *start* event, which should be intercepted to call `Controller#reset`.

See `MainWindow#create_game` to see an example of such a procedure.
