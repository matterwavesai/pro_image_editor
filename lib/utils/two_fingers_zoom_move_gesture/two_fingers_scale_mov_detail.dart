import 'package:flutter/gestures.dart';

class TwoFingersScaleAndMovStartDetails extends ScaleStartDetails {
  TwoFingersScaleAndMovStartDetails({
    super.focalPoint,
    super.localFocalPoint,
    super.pointerCount,
  });
}

enum TwoTouchMode {
  twoTouchUnknownMode, // unknown mode
  twoTouchZoomMode,
  twoTouchMoveMode,
}

/// Details for [GestureScaleUpdateCallback].
class TwoFingersScaleAndMovUpdateDetails {
  /// Creates details for [GestureScaleUpdateCallback].
  ///
  /// The [focalPoint], [scale], [horizontalScale], [verticalScale], [rotation]
  /// arguments must not be null. The [scale], [horizontalScale], and [verticalScale]
  /// argument must be greater than or equal to zero.
  TwoFingersScaleAndMovUpdateDetails({
    this.focalPoint = Offset.zero,
    Offset? localFocalPoint,
    this.type = TwoTouchMode.twoTouchUnknownMode,
    this.scale = 1.0,
    this.horizontalScale = 1.0,
    this.verticalScale = 1.0,
    this.rotation = 0.0,
    this.pointerCount = 0,
    this.focalPointDelta = Offset.zero,
  })  : assert(scale >= 0.0),
        assert(horizontalScale >= 0.0),
        assert(verticalScale >= 0.0),
        localFocalPoint = localFocalPoint ?? focalPoint;

  /// The amount the gesture's focal point has moved in the coordinate space of
  /// the event receiver since the previous update.
  ///
  /// Defaults to zero if not specified in the constructor.
  final Offset focalPointDelta;

  /// The focal point of the pointers in contact with the screen.
  ///
  /// Reported in global coordinates.
  ///
  /// See also:
  ///
  ///  * [localFocalPoint], which is the same value reported in local
  ///    coordinates.
  final Offset focalPoint;

  /// The focal point of the pointers in contact with the screen.
  ///
  /// Reported in local coordinates. Defaults to [focalPoint] if not set in the
  /// constructor.
  ///
  /// See also:
  ///
  ///  * [focalPoint], which is the same value reported in global
  ///    coordinates.
  final Offset localFocalPoint;

  /// The type of the update
  /// The type is determined after start according to users action and once detected
  /// the action type, this is same from start to end.
  ///
  /// 0 unrecorgnize mode,1 zoom update, 2 moving update.
  final TwoTouchMode type;

  /// The scale implied by the average distance between the pointers in contact
  /// with the screen.
  ///
  /// This value must be greater than or equal to zero.
  ///
  /// See also:
  ///
  ///  * [horizontalScale], which is the scale along the horizontal axis.
  ///  * [verticalScale], which is the scale along the vertical axis.
  final double scale;

  /// The scale implied by the average distance along the horizontal axis
  /// between the pointers in contact with the screen.
  ///
  /// This value must be greater than or equal to zero.
  ///
  /// See also:
  ///
  ///  * [scale], which is the general scale implied by the pointers.
  ///  * [verticalScale], which is the scale along the vertical axis.
  final double horizontalScale;

  /// The scale implied by the average distance along the vertical axis
  /// between the pointers in contact with the screen.
  ///
  /// This value must be greater than or equal to zero.
  ///
  /// See also:
  ///
  ///  * [scale], which is the general scale implied by the pointers.
  ///  * [horizontalScale], which is the scale along the horizontal axis.
  final double verticalScale;

  /// The angle implied by the first two pointers to enter in contact with
  /// the screen.
  ///
  /// Expressed in radians.
  final double rotation;

  /// The number of pointers being tracked by the gesture recognizer.
  ///
  /// Typically this is the number of fingers being used to pan the widget using the gesture
  /// recognizer.
  final int pointerCount;

  @override
  String toString() => 'TwoFingersScaleAndMovUpdateDetails('
      'focalPoint: $focalPoint,'
      ' localFocalPoint: $localFocalPoint,'
      ' type: $type'
      ' scale: $scale,'
      ' horizontalScale: $horizontalScale,'
      ' verticalScale: $verticalScale,'
      ' rotation: $rotation,'
      ' pointerCount: $pointerCount,'
      ' focalPointDelta: $focalPointDelta)';
}

/// Details for [GestureScaleEndCallback].
class TwoFingersScaleAndMovEndDetails {
  /// Creates details for [GestureScaleEndCallback].
  ///
  /// The [velocity] argument must not be null.
  TwoFingersScaleAndMovEndDetails(
      {this.velocity = Velocity.zero,
      this.scaleVelocity = 0,
      this.pointerCount = 0,
      this.type = TwoTouchMode.twoTouchUnknownMode});

  /// The velocity of the last pointer to be lifted off of the screen.
  final Velocity velocity;

  /// The final velocity of the scale factor reported by the gesture.
  final double scaleVelocity;

  /// The number of pointers being tracked by the gesture recognizer.
  ///
  /// Typically this is the number of fingers being used to pan the widget using the gesture
  /// recognizer.
  final int pointerCount;

  /// 0 the scale or zoom gesture is not enough to recorgnize, 1 zoom update, 2 moving update.
  ///
  final TwoTouchMode type;

  @override
  String toString() =>
      'TwoFingersScaleAndMovEndDetails(velocity: $velocity, scaleVelocity: $scaleVelocity, pointerCount: $pointerCount)';
}
