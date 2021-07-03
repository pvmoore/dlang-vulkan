
## Handle depth by moving rectangles to fron or back of the list etc.

## uint indexes returned from 'add' functions need to be unique keys

Rectangles - partially implemented
RoundRectangles
Text
Quads



## Respond to property changes

GUIProps needs to implement toHash so that a Widget can tell if any properties have
been changed since it last configured it's layout/UI

In the update method, a Widget needs to check whether or not the properties have been modified
and, if so, update the UI.
