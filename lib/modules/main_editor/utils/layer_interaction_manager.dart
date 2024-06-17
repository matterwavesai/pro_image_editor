// Dart imports:
import 'dart:io';
import 'dart:math';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pro_image_editor/modules/paint_editor/utils/paint_editor_enum.dart';
import 'package:pro_image_editor/pro_image_editor.dart';

// Package imports:
import 'package:vibration/vibration.dart';

// Project imports:
import '/models/editor_configs/pro_image_editor_configs.dart';
import '/models/history/last_layer_interaction_position.dart';
import '/models/layer/layer.dart';
import '/utils/debounce.dart';

/// A helper class responsible for managing layer interactions in the editor.
///
/// The `LayerInteractionManager` class provides methods for handling various interactions
/// with layers in an image editing environment, including scaling, rotating, flipping,
/// and zooming. It also manages the display of helper lines and provides haptic feedback
/// when interacting with these lines to enhance the user experience.
class LayerInteractionManager {
  /// Debounce for scaling actions in the editor.
  late Debounce scaleDebounce;

  /// Y-coordinate of the rotation helper line.
  double rotationHelperLineY = 0;

  /// X-coordinate of the rotation helper line.
  double rotationHelperLineX = 0;

  /// Rotation angle of the rotation helper line.
  double rotationHelperLineDeg = 0;

  /// The base scale factor for the editor.
  double baseScaleFactor = 1.0;

  /// The base angle factor for the editor.
  double baseAngleFactor = 0;

  /// X-coordinate where snapping started.
  double snapStartPosX = 0;

  /// Y-coordinate where snapping started.
  double snapStartPosY = 0;

  /// Initial rotation angle when snapping started.
  double snapStartRotation = 0;

  /// Last recorded rotation angle during snapping.
  double snapLastRotation = 0;

  /// Flag indicating if vertical helper lines should be displayed.
  bool showVerticalHelperLine = false;

  /// Flag indicating if horizontal helper lines should be displayed.
  bool showHorizontalHelperLine = false;

  /// Flag indicating if rotation helper lines should be displayed.
  bool showRotationHelperLine = false;

  /// Flag indicating if the device can vibrate.
  bool deviceCanVibrate = false;

  /// Flag indicating if the device can perform custom vibration.
  bool deviceCanCustomVibrate = false;

  /// Flag indicating if rotation helper lines have started.
  bool rotationStartedHelper = false;

  /// Flag indicating if helper lines should be displayed.
  bool showHelperLines = false;

  /// Flag indicating if the remove button is hovered.
  bool hoverRemoveBtn = false;

  /// Enables or disables hit detection.
  /// When `true`, allows detecting user interactions with the painted layer.
  bool enabledHitDetection = true;

  /// Controls high-performance scaling for free-style drawing.
  /// When `true`, enables optimized scaling for improved performance.
  bool freeStyleHighPerformanceScaling = false;

  /// Controls high-performance moving for free-style drawing.
  /// When `true`, enables optimized moving for improved performance.
  bool freeStyleHighPerformanceMoving = false;

  /// Controls high-performance hero animation for free-style drawing.
  /// When `true`, enables optimized hero-animation for improved performance.
  bool freeStyleHighPerformanceHero = false;

  /// Flag indicating if the scaling tool is active.
  bool _activeScale = false;

  /// Span for detecting hits on layers.
  final double hitSpan = 10;

  /// The ID of the currently selected layer.
  String selectedLayerId = '';

  /// Helper variable for scaling during rotation of a layer.
  double? rotateScaleLayerScaleHelper;

  /// Helper variable for storing the size of a layer during rotation and scaling operations.
  Size? rotateScaleLayerSizeHelper;

  /// Last recorded X-axis position for layers.
  LayerLastPosition lastPositionX = LayerLastPosition.center;

  /// Last recorded Y-axis position for layers.
  LayerLastPosition lastPositionY = LayerLastPosition.center;

  CropRectResizeMode _resizeMode = CropRectResizeMode.none;

  /// Determines if layers are selectable based on the configuration and device type.
  bool layersAreSelectable(ProImageEditorConfigs configs) {
    if (configs.layerInteraction.selectable ==
        LayerInteractionSelectable.auto) {
      return isDesktop;
    }
    return configs.layerInteraction.selectable ==
        LayerInteractionSelectable.enabled;
  }

  /// Calculates scaling and rotation based on user interactions.
  calculateInteractiveButtonScaleRotate({
    required ScaleUpdateDetails details,
    required Layer activeLayer,
    required Size editorSize,
    required bool configEnabledHitVibration,
    required ThemeLayerInteraction layerTheme,
  }) {
    Offset layerOffset = Offset(
      activeLayer.offset.dx,
      activeLayer.offset.dy,
    );
    Size activeSize = rotateScaleLayerSizeHelper!;

    Offset touchPositionFromCenter = Offset(
          details.focalPoint.dx - editorSize.width / 2,
          details.focalPoint.dy - editorSize.height / 2,
        ) -
        layerOffset;

    touchPositionFromCenter = Offset(
      touchPositionFromCenter.dx * (activeLayer.flipX ? -1 : 1),
      touchPositionFromCenter.dy * (activeLayer.flipY ? -1 : 1),
    );

    double newDistance = touchPositionFromCenter.distance;

    double margin = layerTheme.buttonRadius + layerTheme.strokeWidth * 2;
    var realSize = Offset(
          activeSize.width / 2 - margin,
          activeSize.height / 2 - margin,
        ) /
        rotateScaleLayerScaleHelper!;

    activeLayer.scale = newDistance / realSize.distance;
    activeLayer.rotation =
        touchPositionFromCenter.direction - atan(1 / activeSize.aspectRatio);

    checkRotationLine(
      activeLayer: activeLayer,
      editorSize: editorSize,
      configEnabledHitVibration: configEnabledHitVibration,
    );
  }

  determineResizeMode({
    required PointerDownEvent detail,
    required Layer activeLayer,
    required Offset realHitPoint,
  }) {
    if (activeLayer is PaintingLayerData) {
      final isCropRect = activeLayer.item.mode == PaintModeE.cropRect;
      if (isCropRect) {
        // Rect layerRectInLocal = Rect.fromCenter(
        //   center: Offset(
        //     activeLayer.offset.dx,
        //     activeLayer.offset.dy,
        //   ),
        //   width:
        //       activeLayer.item.offsets[1]!.dx - activeLayer.item.offsets[0]!.dx,
        //   height:
        //       activeLayer.item.offsets[1]!.dy - activeLayer.item.offsets[0]!.dy,
        // );
        // debugPrint(
        //     'current crop rect position ${layerRectInLocal.topLeft}, ${layerRectInLocal.bottomRight}');
        // debugPrint('hit point $realHitPoint');

        Rect layerRectInLocal = Rect.fromPoints(
          activeLayer.item.offsets[0]!,
          activeLayer.item.offsets[1]!,
        );

        const draggableThreshold = 24.0;

        // if the details.localFocalPoint is within the layerRectInLocal, considering the `draggableThreshold`
        // we will resize instead of moving the layer
        final nearTop =
            realHitPoint.dy >= layerRectInLocal.top - draggableThreshold &&
                realHitPoint.dy <= layerRectInLocal.top + draggableThreshold;
        final nearBottom =
            realHitPoint.dy >= layerRectInLocal.bottom - draggableThreshold &&
                realHitPoint.dy <= layerRectInLocal.bottom + draggableThreshold;
        final nearLeft =
            realHitPoint.dx >= layerRectInLocal.left - draggableThreshold &&
                realHitPoint.dx <= layerRectInLocal.left + draggableThreshold;
        final nearRight =
            realHitPoint.dx >= layerRectInLocal.right - draggableThreshold &&
                realHitPoint.dx <= layerRectInLocal.right + draggableThreshold;
        // debugPrint(
        //   'nearTop: $nearTop, nearBottom: $nearBottom, nearLeft: $nearLeft, nearRight: $nearRight',
        // );
        if (nearTop || nearBottom || nearLeft || nearRight) {
          if (nearTop && nearLeft) {
            _resizeMode = CropRectResizeMode.topLeft;
          } else if (nearTop && nearRight) {
            _resizeMode = CropRectResizeMode.topRight;
          } else if (nearBottom && nearLeft) {
            _resizeMode = CropRectResizeMode.bottomLeft;
          } else if (nearBottom && nearRight) {
            _resizeMode = CropRectResizeMode.bottomRight;
          } else if (nearTop) {
            _resizeMode = CropRectResizeMode.top;
          } else if (nearBottom) {
            _resizeMode = CropRectResizeMode.bottom;
          } else if (nearLeft) {
            _resizeMode = CropRectResizeMode.left;
          } else if (nearRight) {
            _resizeMode = CropRectResizeMode.right;
          } else {
            _resizeMode = CropRectResizeMode.none;
          }
        } else {
          _resizeMode = CropRectResizeMode.none;
        }
      }

      debugPrint('resize mode $_resizeMode');
    }
  }

  resetResizeMode() {
    _resizeMode = CropRectResizeMode.none;
  }

  /// Calculates movement of a layer based on user interactions, considering various conditions such as hit areas and screen boundaries.
  Layer calculateMovementAndResize({
    required BuildContext context,
    required ScaleUpdateDetails detail,
    required Layer activeLayer,
    required Offset realHitPoint,
  }) {
    if (_activeScale) return activeLayer;

    if (activeLayer is PaintingLayerData) {
      final isCropRect = activeLayer.item.mode == PaintModeE.cropRect;
      if (isCropRect && _resizeMode != CropRectResizeMode.none) {
        final rectBeforeResize = Rect.fromCenter(
          center: Offset(
            activeLayer.offset.dx,
            activeLayer.offset.dy,
          ),
          width:
              activeLayer.item.offsets[1]!.dx - activeLayer.item.offsets[0]!.dx,
          height:
              activeLayer.item.offsets[1]!.dy - activeLayer.item.offsets[0]!.dy,
        );

        final topLeft = rectBeforeResize.topLeft;
        final bottomRight = rectBeforeResize.bottomRight;

        final bool resizingLeft = _resizeMode == CropRectResizeMode.left ||
            _resizeMode == CropRectResizeMode.topLeft ||
            _resizeMode == CropRectResizeMode.bottomLeft;
        final bool resizingTop = _resizeMode == CropRectResizeMode.top ||
            _resizeMode == CropRectResizeMode.topLeft ||
            _resizeMode == CropRectResizeMode.topRight;
        final bool resizingRight = _resizeMode == CropRectResizeMode.right ||
            _resizeMode == CropRectResizeMode.topRight ||
            _resizeMode == CropRectResizeMode.bottomRight;
        final bool resizingBottom = _resizeMode == CropRectResizeMode.bottom ||
            _resizeMode == CropRectResizeMode.bottomLeft ||
            _resizeMode == CropRectResizeMode.bottomRight;

        final newTopLeft = Offset(
          topLeft.dx + (resizingLeft ? detail.focalPointDelta.dx : 0),
          topLeft.dy + (resizingTop ? detail.focalPointDelta.dy : 0),
        );

        final newBottomRight = Offset(
          bottomRight.dx + (resizingRight ? detail.focalPointDelta.dx : 0),
          bottomRight.dy + (resizingBottom ? detail.focalPointDelta.dy : 0),
        );

        // Ensure the new width and height are at least 50
        final newWidth =
            (newBottomRight.dx - newTopLeft.dx).clamp(50, double.infinity);
        final newHeight =
            (newBottomRight.dy - newTopLeft.dy).clamp(50, double.infinity);

        final adjustedTopLeft = Offset(
          resizingLeft ? newBottomRight.dx - newWidth : newTopLeft.dx,
          resizingTop ? newBottomRight.dy - newHeight : newTopLeft.dy,
        );

        final adjustedBottomRight = Offset(
          resizingRight ? newTopLeft.dx + newWidth : newBottomRight.dx,
          resizingBottom ? newTopLeft.dy + newHeight : newBottomRight.dy,
        );

        // new offset should be at the center of the resized rect
        activeLayer.offset = Offset(
          (adjustedTopLeft.dx + adjustedBottomRight.dx) / 2,
          (adjustedTopLeft.dy + adjustedBottomRight.dy) / 2,
        );

        activeLayer.item.offsets[1] = Offset(
          adjustedBottomRight.dx - adjustedTopLeft.dx,
          adjustedBottomRight.dy - adjustedTopLeft.dy,
        );

        final activeLayerMap = activeLayer.toMap();
        activeLayerMap['rawSize'] = {
          'w': adjustedBottomRight.dx - adjustedTopLeft.dx,
          'h': adjustedBottomRight.dy - adjustedTopLeft.dy,
        };

        // debugPrint('rawsize: ${activeLayerMap['rawSize']}');
        return Layer.fromMap(activeLayerMap, []);
      }
    }

    // debugPrint(
    //     'item size before ${(activeLayer as PaintingLayerData).item.offsets[1]!}');

    // activeLayer = (Layer.fromMap(activeLayer.toMap(), []) as PaintingLayerData)
    //   ..item.offsets[1] = Offset(
    //     (activeLayer as PaintingLayerData).item.offsets[1]!.dx +
    //         detail.focalPointDelta.dx,
    //     activeLayer.item.offsets[1]!.dy + detail.focalPointDelta.dy,
    //   );

    // debugPrint('item size, ${activeLayer.item.offsets[1]}');

    activeLayer.offset = Offset(
      activeLayer.offset.dx + detail.focalPointDelta.dx,
      activeLayer.offset.dy + detail.focalPointDelta.dy,
    );
    return activeLayer;
  }

  /// Calculates movement of a layer based on user interactions, considering various conditions such as hit areas and screen boundaries.
  calculateMovement({
    required BuildContext context,
    required ScaleUpdateDetails detail,
    required Layer activeLayer,
    required bool configEnabledHitVibration,
    required Function(bool) onHoveredRemoveBtn,
  }) {
    if (_activeScale) return;

    activeLayer.offset = Offset(
      activeLayer.offset.dx + detail.focalPointDelta.dx,
      activeLayer.offset.dy + detail.focalPointDelta.dy,
    );

    bool hoveredRemoveBtn = detail.focalPoint.dx <= kToolbarHeight &&
        detail.focalPoint.dy <=
            kToolbarHeight + MediaQuery.of(context).viewPadding.top;
    if (hoverRemoveBtn != hoveredRemoveBtn) {
      hoverRemoveBtn = hoveredRemoveBtn;
      onHoveredRemoveBtn.call(hoverRemoveBtn);
    }

    bool vibarate = false;
    double posX = activeLayer.offset.dx;
    double posY = activeLayer.offset.dy;

    bool hitAreaX = detail.focalPoint.dx >= snapStartPosX - hitSpan &&
        detail.focalPoint.dx <= snapStartPosX + hitSpan;
    bool hitAreaY = detail.focalPoint.dy >= snapStartPosY - hitSpan &&
        detail.focalPoint.dy <= snapStartPosY + hitSpan;

    bool helperGoNearLineLeft =
        posX >= 0 && lastPositionX == LayerLastPosition.left;
    bool helperGoNearLineRight =
        posX <= 0 && lastPositionX == LayerLastPosition.right;
    bool helperGoNearLineTop =
        posY >= 0 && lastPositionY == LayerLastPosition.top;
    bool helperGoNearLineBottom =
        posY <= 0 && lastPositionY == LayerLastPosition.bottom;

    /// Calc vertical helper line
    if ((!showVerticalHelperLine &&
            (helperGoNearLineLeft || helperGoNearLineRight)) ||
        (showVerticalHelperLine && hitAreaX)) {
      if (!showVerticalHelperLine) {
        vibarate = true;
        snapStartPosX = detail.focalPoint.dx;
      }
      showVerticalHelperLine = true;
      activeLayer.offset = Offset(0, activeLayer.offset.dy);
      lastPositionX = LayerLastPosition.center;
    } else {
      showVerticalHelperLine = false;
      lastPositionX =
          posX <= 0 ? LayerLastPosition.left : LayerLastPosition.right;
    }

    /// Calc horizontal helper line
    if ((!showHorizontalHelperLine &&
            (helperGoNearLineTop || helperGoNearLineBottom)) ||
        (showHorizontalHelperLine && hitAreaY)) {
      if (!showHorizontalHelperLine) {
        vibarate = true;
        snapStartPosY = detail.focalPoint.dy;
      }
      showHorizontalHelperLine = true;
      activeLayer.offset = Offset(activeLayer.offset.dx, 0);
      lastPositionY = LayerLastPosition.center;
    } else {
      showHorizontalHelperLine = false;
      lastPositionY =
          posY <= 0 ? LayerLastPosition.top : LayerLastPosition.bottom;
    }

    if (configEnabledHitVibration && vibarate) {
      _lineHitVibrate();
    }
  }

  /// Calculates scaling and rotation of a layer based on user interactions.
  calculateScaleRotate({
    required ScaleUpdateDetails detail,
    required Layer activeLayer,
    required Size editorSize,
    required EdgeInsets screenPaddingHelper,
    required bool configEnabledHitVibration,
  }) {
    _activeScale = true;

    activeLayer.scale = baseScaleFactor * detail.scale;
    activeLayer.rotation = baseAngleFactor + detail.rotation;

    checkRotationLine(
      activeLayer: activeLayer,
      editorSize: editorSize,
      configEnabledHitVibration: configEnabledHitVibration,
    );

    scaleDebounce(() => _activeScale = false);
  }

  /// Checks the rotation line based on user interactions, adjusting rotation accordingly.
  checkRotationLine({
    required Layer activeLayer,
    required Size editorSize,
    required bool configEnabledHitVibration,
  }) {
    double rotation = activeLayer.rotation - baseAngleFactor;
    double hitSpanX = hitSpan / 2;
    double deg = activeLayer.rotation * 180 / pi;
    double degChange = rotation * 180 / pi;
    double degHit = (snapStartRotation + degChange) % 45;

    bool hitAreaBelow = degHit <= hitSpanX;
    bool hitAreaAfter = degHit >= 45 - hitSpanX;
    bool hitArea = hitAreaBelow || hitAreaAfter;

    if ((!showRotationHelperLine &&
            ((degHit > 0 && degHit <= hitSpanX && snapLastRotation < deg) ||
                (degHit < 45 &&
                    degHit >= 45 - hitSpanX &&
                    snapLastRotation > deg))) ||
        (showRotationHelperLine && hitArea)) {
      if (rotationStartedHelper) {
        activeLayer.rotation =
            (deg - (degHit > 45 - hitSpanX ? degHit - 45 : degHit)) / 180 * pi;
        rotationHelperLineDeg = activeLayer.rotation;

        double posY = activeLayer.offset.dy;
        double posX = activeLayer.offset.dx;

        rotationHelperLineX = posX + editorSize.width / 2;
        rotationHelperLineY = posY + editorSize.height / 2;
        if (configEnabledHitVibration && !showRotationHelperLine) {
          _lineHitVibrate();
        }
        showRotationHelperLine = true;
      }
      snapLastRotation = deg;
    } else {
      showRotationHelperLine = false;
      rotationStartedHelper = true;
    }
  }

  /// Handles cleanup and resets various flags and states after scaling interaction ends.
  onScaleEnd() {
    enabledHitDetection = true;
    freeStyleHighPerformanceScaling = false;
    freeStyleHighPerformanceMoving = false;
    showHorizontalHelperLine = false;
    showVerticalHelperLine = false;
    showRotationHelperLine = false;
    showHelperLines = false;
    hoverRemoveBtn = false;
  }

  /// Rotate a layer.
  ///
  /// This method rotates a layer based on various factors, including flip and angle.
  void rotateLayer({
    required Layer layer,
    required bool beforeIsFlipX,
    required double newImgW,
    required double newImgH,
    required double rotationScale,
    required double rotationRadian,
    required double rotationAngle,
  }) {
    if (beforeIsFlipX) {
      layer.rotation -= rotationRadian;
    } else {
      layer.rotation += rotationRadian;
    }

    if (rotationAngle == 90) {
      layer.scale /= rotationScale;
      layer.offset = Offset(
        newImgW - layer.offset.dy / rotationScale,
        layer.offset.dx / rotationScale,
      );
    } else if (rotationAngle == 180) {
      layer.offset = Offset(
        newImgW - layer.offset.dx,
        newImgH - layer.offset.dy,
      );
    } else if (rotationAngle == 270) {
      layer.scale /= rotationScale;
      layer.offset = Offset(
        layer.offset.dy / rotationScale,
        newImgH - layer.offset.dx / rotationScale,
      );
    }
  }

  /// Handles zooming of a layer.
  ///
  /// This method calculates the zooming of a layer based on the specified parameters.
  /// It checks if the layer should be zoomed and performs the necessary transformations.
  ///
  /// Returns `true` if the layer was zoomed, otherwise `false`.
  bool zoomedLayer({
    required Layer layer,
    required double scale,
    required double scaleX,
    required double oldFullH,
    required double oldFullW,
    required double pixelRatio,
    required Rect cropRect,
    required bool isHalfPi,
  }) {
    var paddingTop = cropRect.top / pixelRatio;
    var paddingLeft = cropRect.left / pixelRatio;
    var paddingRight = oldFullW - cropRect.right;
    var paddingBottom = oldFullH - cropRect.bottom;

    // important to check with < 1 and >-1 cuz crop-editor has rounding bugs
    if (paddingTop > 0.1 ||
        paddingTop < -0.1 ||
        paddingLeft > 0.1 ||
        paddingLeft < -0.1 ||
        paddingRight > 0.1 ||
        paddingRight < -0.1 ||
        paddingBottom > 0.1 ||
        paddingBottom < -0.1) {
      var initialIconX = (layer.offset.dx - paddingLeft) * scaleX;
      var initialIconY = (layer.offset.dy - paddingTop) * scaleX;
      layer.offset = Offset(
        initialIconX,
        initialIconY,
      );

      layer.scale *= scale;
      return true;
    }
    return false;
  }

  /// Flip a layer horizontally or vertically.
  ///
  /// This method flips a layer either horizontally or vertically based on the specified parameters.
  void flipLayer({
    required Layer layer,
    required bool flipX,
    required bool flipY,
    required bool isHalfPi,
    required double imageWidth,
    required double imageHeight,
  }) {
    if (flipY) {
      if (isHalfPi) {
        layer.flipY = !layer.flipY;
      } else {
        layer.flipX = !layer.flipX;
      }
      layer.offset = Offset(
        imageWidth - layer.offset.dx,
        layer.offset.dy,
      );
    }
    if (flipX) {
      layer.flipX = !layer.flipX;
      layer.offset = Offset(
        layer.offset.dx,
        imageHeight - layer.offset.dy,
      );
    }
  }

  /// Vibrates the device briefly if enabled and supported.
  ///
  /// This function checks if helper lines hit vibration is enabled in the widget's
  /// configurations (`widget.configs.helperLines.hitVibration`) and whether the
  /// device supports vibration. If both conditions are met, it triggers a brief
  /// vibration on the device.
  ///
  /// If the device supports custom vibrations, it uses the `Vibration.vibrate`
  /// method with a duration of 3 milliseconds to produce the vibration.
  ///
  /// On older Android devices, it initiates vibration using `Vibration.vibrate`,
  /// and then, after 3 milliseconds, cancels the vibration using `Vibration.cancel`.
  ///
  /// This function is used to provide haptic feedback when helper lines are interacted
  /// with, enhancing the user experience.
  void _lineHitVibrate() {
    if (deviceCanVibrate && deviceCanCustomVibrate) {
      Vibration.vibrate(duration: 3);
    } else if (!kIsWeb && Platform.isAndroid) {
      // On old android devices we can stop the vibration after 3 milliseconds
      // iOS: only works for custom haptic vibrations using CHHapticEngine.
      // This will set `deviceCanCustomVibrate` anyway to true so it's impossible to fake it.
      Vibration.vibrate();
      Future.delayed(const Duration(milliseconds: 3)).whenComplete(() {
        Vibration.cancel();
      });
    }
  }
}
