import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import 'two_fingers_scale_move_controller.dart';

class GestureDetectorTwoFingersScaleMov extends GestureDetector {
  GestureDetectorTwoFingersScaleMov({
    this.constScaleThreshold = 0.1,
    this.constMovThreshold = 20,
    required this.controller,
    super.key,
    super.child,
    super.onTapDown,
    super.onTapUp,
    super.onTap,
    super.onTapCancel,
    super.onSecondaryTap,
    super.onSecondaryTapDown,
    super.onSecondaryTapUp,
    super.onSecondaryTapCancel,
    super.onTertiaryTapDown,
    super.onTertiaryTapUp,
    super.onTertiaryTapCancel,
    super.onDoubleTapDown,
    super.onDoubleTap,
    super.onDoubleTapCancel,
    super.onLongPressDown,
    super.onLongPressCancel,
    super.onLongPress,
    super.onLongPressStart,
    super.onLongPressMoveUpdate,
    super.onLongPressUp,
    super.onLongPressEnd,
    super.onSecondaryLongPressDown,
    super.onSecondaryLongPressCancel,
    super.onSecondaryLongPress,
    super.onSecondaryLongPressStart,
    super.onSecondaryLongPressMoveUpdate,
    super.onSecondaryLongPressUp,
    super.onSecondaryLongPressEnd,
    super.onTertiaryLongPressDown,
    super.onTertiaryLongPressCancel,
    super.onTertiaryLongPress,
    super.onTertiaryLongPressStart,
    super.onTertiaryLongPressMoveUpdate,
    super.onTertiaryLongPressUp,
    super.onTertiaryLongPressEnd,
    super.onVerticalDragDown,
    super.onVerticalDragStart,
    super.onVerticalDragUpdate,
    super.onVerticalDragEnd,
    super.onVerticalDragCancel,
    super.onHorizontalDragDown,
    super.onHorizontalDragStart,
    super.onHorizontalDragUpdate,
    super.onHorizontalDragEnd,
    super.onHorizontalDragCancel,
    super.onForcePressStart,
    super.onForcePressPeak,
    super.onForcePressUpdate,
    super.onForcePressEnd,
    super.onPanDown,
    super.onPanStart,
    super.onPanUpdate,
    super.onPanEnd,
    super.onPanCancel,
    this.onScaleMovStart,
    this.onScaleMovUpdate,
    this.onScaleMovEnd,
    super.behavior,
    super.excludeFromSemantics = false,
    super.dragStartBehavior = DragStartBehavior.start,
    super.trackpadScrollCausesScale = false,
    super.trackpadScrollToScaleFactor = kDefaultTrackpadScrollToScaleFactor,
    super.supportedDevices,
  }) : assert(() {
          final bool haveVerticalDrag = onVerticalDragStart != null ||
              onVerticalDragUpdate != null ||
              onVerticalDragEnd != null;
          final bool haveHorizontalDrag = onHorizontalDragStart != null ||
              onHorizontalDragUpdate != null ||
              onHorizontalDragEnd != null;
          final bool havePan =
              onPanStart != null || onPanUpdate != null || onPanEnd != null;
          final bool haveScale = onScaleMovStart != null ||
              onScaleMovUpdate != null ||
              onScaleMovEnd != null;
          if (havePan || haveScale) {
            if (havePan && haveScale) {
              throw FlutterError.fromParts(<DiagnosticsNode>[
                ErrorSummary('Incorrect GestureDetector arguments.'),
                ErrorDescription(
                  'Having both a pan gesture recognizer and a scale gesture recognizer is redundant; scale is a superset of pan.',
                ),
                ErrorHint('Just use the scale gesture recognizer.'),
              ]);
            }
            final String recognizer = havePan ? 'pan' : 'scale';
            if (haveVerticalDrag && haveHorizontalDrag) {
              throw FlutterError(
                'Incorrect GestureDetector arguments.\n'
                'Simultaneously having a vertical drag gesture recognizer, a horizontal drag gesture recognizer, and a $recognizer gesture recognizer '
                'will result in the $recognizer gesture recognizer being ignored, since the other two will catch all drags.',
              );
            }
          }
          return true;
        }()) {
    debugPrint("---- update widget");
  }

  /// The pointers in contact with the screen have established a focal point and
  final GestureTwoFingersScaleMovStartCallback? onScaleMovStart;

  /// The pointers in contact with the screen have indicated a new focal point
  /// and/or scale or mov.
  final GestureTwoFingersScaleMovUpdateCallback? onScaleMovUpdate;

  /// The pointers are no longer in contact with the screen.
  final GestureTwoFingersScaleMovEndCallback? onScaleMovEnd;

  /// If the scale value is bigger than constScaleThreshold
  /// the action will be regcorgnized as scale gesture
  final double constScaleThreshold;

  /// If the moving distance is bigger than constMovThreshold
  /// the action will be recorgnized as mov gesture
  final double constMovThreshold;

  /// scale move controller
  final TwoFingerScaleMoveController controller;

  @override
  Widget build(BuildContext context) {
    final Map<Type, GestureRecognizerFactory> gestures =
        <Type, GestureRecognizerFactory>{};
    final DeviceGestureSettings? gestureSettings =
        MediaQuery.maybeGestureSettingsOf(context);

    final TwoFingerScaleMoveGesture scaleMove = TwoFingerScaleMoveGesture(
        constMovThreshold: constMovThreshold,
        constScaleThreshold: constScaleThreshold,
        onScaleMovStart: onScaleMovStart,
        onScaleMovUpdate: onScaleMovUpdate,
        onScaleMovEnd: onScaleMovEnd,
        controller: controller);

    if (onTapDown != null ||
        onTapUp != null ||
        onTap != null ||
        onTapCancel != null ||
        onSecondaryTap != null ||
        onSecondaryTapDown != null ||
        onSecondaryTapUp != null ||
        onSecondaryTapCancel != null ||
        onTertiaryTapDown != null ||
        onTertiaryTapUp != null ||
        onTertiaryTapCancel != null) {
      gestures[TapGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<TapGestureRecognizer>(
        () => TapGestureRecognizer(
            debugOwner: this, supportedDevices: supportedDevices),
        (TapGestureRecognizer instance) {
          instance
            ..onTapDown = onTapDown
            ..onTapUp = onTapUp
            ..onTap = onTap
            ..onTapCancel = onTapCancel
            ..onSecondaryTap = onSecondaryTap
            ..onSecondaryTapDown = onSecondaryTapDown
            ..onSecondaryTapUp = onSecondaryTapUp
            ..onSecondaryTapCancel = onSecondaryTapCancel
            ..onTertiaryTapDown = onTertiaryTapDown
            ..onTertiaryTapUp = onTertiaryTapUp
            ..onTertiaryTapCancel = onTertiaryTapCancel
            ..gestureSettings = gestureSettings
            ..supportedDevices = supportedDevices;
        },
      );
    }

    if (onDoubleTap != null ||
        onDoubleTapDown != null ||
        onDoubleTapCancel != null) {
      gestures[DoubleTapGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<DoubleTapGestureRecognizer>(
        () => DoubleTapGestureRecognizer(
            debugOwner: this, supportedDevices: supportedDevices),
        (DoubleTapGestureRecognizer instance) {
          instance
            ..onDoubleTapDown = onDoubleTapDown
            ..onDoubleTap = onDoubleTap
            ..onDoubleTapCancel = onDoubleTapCancel
            ..gestureSettings = gestureSettings
            ..supportedDevices = supportedDevices;
        },
      );
    }

    if (onLongPressDown != null ||
        onLongPressCancel != null ||
        onLongPress != null ||
        onLongPressStart != null ||
        onLongPressMoveUpdate != null ||
        onLongPressUp != null ||
        onLongPressEnd != null ||
        onSecondaryLongPressDown != null ||
        onSecondaryLongPressCancel != null ||
        onSecondaryLongPress != null ||
        onSecondaryLongPressStart != null ||
        onSecondaryLongPressMoveUpdate != null ||
        onSecondaryLongPressUp != null ||
        onSecondaryLongPressEnd != null ||
        onTertiaryLongPressDown != null ||
        onTertiaryLongPressCancel != null ||
        onTertiaryLongPress != null ||
        onTertiaryLongPressStart != null ||
        onTertiaryLongPressMoveUpdate != null ||
        onTertiaryLongPressUp != null ||
        onTertiaryLongPressEnd != null) {
      gestures[LongPressGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<LongPressGestureRecognizer>(
        () => LongPressGestureRecognizer(
            debugOwner: this, supportedDevices: supportedDevices),
        (LongPressGestureRecognizer instance) {
          instance
            ..onLongPressDown = onLongPressDown
            ..onLongPressCancel = onLongPressCancel
            ..onLongPress = onLongPress
            ..onLongPressStart = onLongPressStart
            ..onLongPressMoveUpdate = onLongPressMoveUpdate
            ..onLongPressUp = onLongPressUp
            ..onLongPressEnd = onLongPressEnd
            ..onSecondaryLongPressDown = onSecondaryLongPressDown
            ..onSecondaryLongPressCancel = onSecondaryLongPressCancel
            ..onSecondaryLongPress = onSecondaryLongPress
            ..onSecondaryLongPressStart = onSecondaryLongPressStart
            ..onSecondaryLongPressMoveUpdate = onSecondaryLongPressMoveUpdate
            ..onSecondaryLongPressUp = onSecondaryLongPressUp
            ..onSecondaryLongPressEnd = onSecondaryLongPressEnd
            ..onTertiaryLongPressDown = onTertiaryLongPressDown
            ..onTertiaryLongPressCancel = onTertiaryLongPressCancel
            ..onTertiaryLongPress = onTertiaryLongPress
            ..onTertiaryLongPressStart = onTertiaryLongPressStart
            ..onTertiaryLongPressMoveUpdate = onTertiaryLongPressMoveUpdate
            ..onTertiaryLongPressUp = onTertiaryLongPressUp
            ..onTertiaryLongPressEnd = onTertiaryLongPressEnd
            ..gestureSettings = gestureSettings
            ..supportedDevices = supportedDevices;
        },
      );
    }

    if (onVerticalDragDown != null ||
        onVerticalDragStart != null ||
        onVerticalDragUpdate != null ||
        onVerticalDragEnd != null ||
        onVerticalDragCancel != null) {
      gestures[VerticalDragGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<VerticalDragGestureRecognizer>(
        () => VerticalDragGestureRecognizer(
            debugOwner: this, supportedDevices: supportedDevices),
        (VerticalDragGestureRecognizer instance) {
          instance
            ..onDown = onVerticalDragDown
            ..onStart = onVerticalDragStart
            ..onUpdate = onVerticalDragUpdate
            ..onEnd = onVerticalDragEnd
            ..onCancel = onVerticalDragCancel
            ..dragStartBehavior = dragStartBehavior
            ..gestureSettings = gestureSettings
            ..supportedDevices = supportedDevices;
        },
      );
    }

    if (onHorizontalDragDown != null ||
        onHorizontalDragStart != null ||
        onHorizontalDragUpdate != null ||
        onHorizontalDragEnd != null ||
        onHorizontalDragCancel != null) {
      gestures[HorizontalDragGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<HorizontalDragGestureRecognizer>(
        () => HorizontalDragGestureRecognizer(
            debugOwner: this, supportedDevices: supportedDevices),
        (HorizontalDragGestureRecognizer instance) {
          instance
            ..onDown = onHorizontalDragDown
            ..onStart = onHorizontalDragStart
            ..onUpdate = onHorizontalDragUpdate
            ..onEnd = onHorizontalDragEnd
            ..onCancel = onHorizontalDragCancel
            ..dragStartBehavior = dragStartBehavior
            ..gestureSettings = gestureSettings
            ..supportedDevices = supportedDevices;
        },
      );
    }

    if (onPanDown != null ||
        onPanStart != null ||
        onPanUpdate != null ||
        onPanEnd != null ||
        onPanCancel != null) {
      gestures[PanGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<PanGestureRecognizer>(
        () => PanGestureRecognizer(
            debugOwner: this, supportedDevices: supportedDevices),
        (PanGestureRecognizer instance) {
          instance
            ..onDown = onPanDown
            ..onStart = onPanStart
            ..onUpdate = onPanUpdate
            ..onEnd = onPanEnd
            ..onCancel = onPanCancel
            ..dragStartBehavior = dragStartBehavior
            ..gestureSettings = gestureSettings
            ..supportedDevices = supportedDevices;
        },
      );
    }

    /// scale gesture for two scale and move
    if (onScaleMovStart != null ||
        onScaleMovUpdate != null ||
        onScaleMovEnd != null) {
      gestures[ScaleGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<ScaleGestureRecognizer>(
        () => ScaleGestureRecognizer(
            debugOwner: this, supportedDevices: supportedDevices),
        (ScaleGestureRecognizer instance) {
          instance
            ..onStart = scaleMove.scaleStartListener
            ..onUpdate = scaleMove.scaleUpdateListener
            ..onEnd = scaleMove.scaleEndLisener
            ..dragStartBehavior = dragStartBehavior
            ..gestureSettings = gestureSettings
            ..trackpadScrollCausesScale = trackpadScrollCausesScale
            ..trackpadScrollToScaleFactor = trackpadScrollToScaleFactor
            ..supportedDevices = supportedDevices;
        },
      );
    }

    if (onForcePressStart != null ||
        onForcePressPeak != null ||
        onForcePressUpdate != null ||
        onForcePressEnd != null) {
      gestures[ForcePressGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<ForcePressGestureRecognizer>(
        () => ForcePressGestureRecognizer(
            debugOwner: this, supportedDevices: supportedDevices),
        (ForcePressGestureRecognizer instance) {
          instance
            ..onStart = onForcePressStart
            ..onPeak = onForcePressPeak
            ..onUpdate = onForcePressUpdate
            ..onEnd = onForcePressEnd
            ..gestureSettings = gestureSettings
            ..supportedDevices = supportedDevices;
        },
      );
    }

    return RawGestureDetector(
      gestures: gestures,
      behavior: behavior,
      excludeFromSemantics: excludeFromSemantics,
      child: child,
    );
  }
}
