import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'two_fingers_scale_mov_detail.dart';

typedef GestureTwoFingersScaleMovStartCallback = void Function(
    TwoFingersScaleAndMovStartDetails details);

typedef GestureTwoFingersScaleMovUpdateCallback = void Function(
    TwoFingersScaleAndMovUpdateDetails details);

typedef GestureTwoFingersScaleMovEndCallback = void Function(
    TwoFingersScaleAndMovEndDetails details);

/// Sale or Move gesture gesture param controller
class TwoFingerScaleMoveController {
  /// accumulated distance for recorgnizing gesture
  double accumulatedX = 0;
  double accumulatedY = 0;

  /// 0 unrecorgnize mode, 1 zoom update, 2 moving update.
  TwoTouchMode type = TwoTouchMode.twoTouchUnknownMode;
}

class TwoFingerScaleMoveGesture {
  TwoFingerScaleMoveGesture(
      {this.constScaleThreshold = 0.1,
      this.constMovThreshold = 20,
      this.onScaleMovStart,
      this.onScaleMovUpdate,
      this.onScaleMovEnd,
      required this.controller});

  /// If the scale value is bigger than constScaleThreshold
  /// the action will be regcorgnized as scale gesture
  final double constScaleThreshold;

  /// If the moving distance is bigger than constMovThreshold
  /// the action will be recorgnized as mov gesture
  final double constMovThreshold;

  /// The pointers in contact with the screen have established a focal point and
  final GestureTwoFingersScaleMovStartCallback? onScaleMovStart;

  /// The pointers in contact with the screen have indicated a new focal point
  /// and/or scale or mov.
  final GestureTwoFingersScaleMovUpdateCallback? onScaleMovUpdate;

  /// The pointers are no longer in contact with the screen.
  final GestureTwoFingersScaleMovEndCallback? onScaleMovEnd;

  final TwoFingerScaleMoveController controller;

  void scaleStartListener(ScaleStartDetails details) {
    if (details.pointerCount >= 2) {
      controller.accumulatedX = 0;
      controller.accumulatedY = 0;
      controller.type = TwoTouchMode.twoTouchUnknownMode;
    }

    if (onScaleMovStart != null) {
      onScaleMovStart!(TwoFingersScaleAndMovStartDetails(
          focalPoint: details.focalPoint,
          localFocalPoint: details.localFocalPoint,
          pointerCount: details.pointerCount));
    }
  }

  void scaleUpdateListener(ScaleUpdateDetails details) {
    if (details.pointerCount >= 2) {
      if (controller.type == TwoTouchMode.twoTouchUnknownMode) {
        controller.type = checkTwoTouchesMoveMode(details);
      }
    } else {
      controller.type = TwoTouchMode.twoTouchUnknownMode;
    }

    if (onScaleMovUpdate != null) {
      onScaleMovUpdate!(TwoFingersScaleAndMovUpdateDetails(
          focalPoint: details.focalPoint,
          localFocalPoint: details.localFocalPoint,
          type: controller.type,
          scale: details.scale,
          horizontalScale: details.horizontalScale,
          verticalScale: details.verticalScale,
          rotation: details.rotation,
          pointerCount: details.pointerCount,
          focalPointDelta: details.focalPointDelta));
    }
  }

  void scaleEndLisener(ScaleEndDetails details) {
    if (onScaleMovEnd != null) {
      onScaleMovEnd!(TwoFingersScaleAndMovEndDetails(
          velocity: details.velocity,
          scaleVelocity: details.scaleVelocity,
          pointerCount: details.pointerCount,
          type: controller.type));
    }
  }

  TwoTouchMode checkTwoTouchesMoveMode(ScaleUpdateDetails touches) {
    if ((1 - touches.scale).abs() >= constScaleThreshold) {
      //  debugPrint("two touch scale mode:${(1 - touches.scale).abs()}");
      /// scale gesture
      return TwoTouchMode.twoTouchZoomMode;
    }

    controller.accumulatedX += touches.focalPointDelta.dx;
    controller.accumulatedY += touches.focalPointDelta.dy;

    if (controller.accumulatedX.abs() >= constMovThreshold ||
        controller.accumulatedY.abs() >= constMovThreshold) {
      //   debugPrint(
      //       "two touch move mode dx:${_accumulatedX.abs()} , dy:${_accumulatedY.abs()}");

      /// mov gesture
      return TwoTouchMode.twoTouchMoveMode;
    }

    return TwoTouchMode.twoTouchUnknownMode;
  }
}
