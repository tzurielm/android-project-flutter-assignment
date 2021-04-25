## Dry questions:
1. The class of the controller is SnappingSheetController, it allows the developer to control the features:
  * Adjusting the position of the sheet with snapToPosition and change the SnappingSheet state.
  * Get information about the sheet location (which helped me implement the blur effect) with currentPosition.
  * define actions with state changing (like onSheetMoved)
2. The paramter that controls the snapping animation is "snappingPositions" which takes a list of objects called SnappingPosition.
   The SnappingPosition object has paramaters such as "snappingCurve" and "snappingDuration" which control the animation of the snapping sheet.
3. One advantage of InkWell:
   Inkwell allows the usage of ripple effects upon tap, indicating the user that the tap has been registered.
   Advantage of GestureDetector:
   GestureDetector provides a much broader variety of Gestures than InkWell such as "onDoubleTap" and "onLongPress" which allows better control on our app.
