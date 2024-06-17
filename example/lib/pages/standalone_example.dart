// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:pro_image_editor/pro_image_editor.dart';

// Project imports:
import '../utils/example_constants.dart';
import '../utils/example_helper.dart';

class StandaloneExample extends StatefulWidget {
  const StandaloneExample({super.key});

  @override
  State<StandaloneExample> createState() => _StandaloneExampleState();
}

class _StandaloneExampleState extends State<StandaloneExample>
    with ExampleHelperState<StandaloneExample> {
  final _cropRotateEditorKey = GlobalKey<CropRotateEditorState>();
  final _zoomableMainEditorKey = GlobalKey<ZoomableMainEditorState>();
  final _cropPaintEditorKey = GlobalKey<CropPaintEditorState>();

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext _) {
            return ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 20),
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Editor',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Painting-Editor'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    Navigator.pop(context);
                    await precacheImage(
                        AssetImage(ExampleConstants.of(context)!.demoAssetPath),
                        context);
                    if (!context.mounted) return;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => _buildPaintingEditor()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.zoom_in),
                  title: const Text('Zoomable-Main-Editor'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    Navigator.pop(context);
                    await precacheImage(
                        AssetImage(ExampleConstants.of(context)!.demoAssetPath),
                        context);
                    if (!context.mounted) return;

                    bool inited = false;

                    final List<Rect> rects = await Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) {
                        if (!inited) {
                          inited = true;
                          Future.delayed(const Duration(milliseconds: 1), () {
                            _zoomableMainEditorKey
                                .currentState!.enableFakeHero = true;
                            setState(() {});
                          });
                        }
                        return _buildZoomableMainEditor();
                      }),
                    );
                    debugPrint('rects: $rects');
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.crop_rotate_rounded),
                  title: const Text('Crop-Rotate-Editor'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    Navigator.pop(context);
                    await precacheImage(
                        AssetImage(ExampleConstants.of(context)!.demoAssetPath),
                        context);
                    if (!context.mounted) return;

                    bool inited = false;

                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) {
                        if (!inited) {
                          inited = true;
                          Future.delayed(const Duration(milliseconds: 1), () {
                            _cropRotateEditorKey.currentState!.enableFakeHero =
                                true;
                            setState(() {});
                          });
                        }
                        return _buildCropRotateEditor();
                      }),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.car_rental),
                  title: const Text('Crop-Paint-Editor'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    Navigator.pop(context);
                    await precacheImage(
                        AssetImage(ExampleConstants.of(context)!.demoAssetPath),
                        context);
                    if (!context.mounted) return;

                    bool inited = false;

                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) {
                        if (!inited) {
                          inited = true;
                          Future.delayed(const Duration(milliseconds: 1), () {
                            _cropPaintEditorKey.currentState!.enableFakeHero =
                                true;
                            setState(() {});
                          });
                        }
                        return _buildCropPaintEditor();
                      }),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.filter),
                  title: const Text('Filter-Editor'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    Navigator.pop(context);
                    await precacheImage(
                        AssetImage(ExampleConstants.of(context)!.demoAssetPath),
                        context);
                    if (!context.mounted) return;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => _buildFilterEditor()),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.blur_on),
                  title: const Text('Blur-Editor'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    Navigator.pop(context);
                    await precacheImage(
                        AssetImage(ExampleConstants.of(context)!.demoAssetPath),
                        context);
                    if (!context.mounted) return;
                    Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (context) => _buildBlurEditor()),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
      leading: const Icon(Icons.view_in_ar_outlined),
      title: const Text('Standalone Sub-Editor'),
      trailing: const Icon(Icons.chevron_right),
    );
  }

  Widget _buildPaintingEditor() {
    return PaintingEditor.asset(
      ExampleConstants.of(context)!.demoAssetPath,
      initConfigs: PaintEditorInitConfigs(
        theme: ThemeData.dark(),
        enableFakeHero: true,
        convertToUint8List: true,
        configs: ProImageEditorConfigs(
          designMode: platformDesignMode,
          imageGenerationConfigs: const ImageGeneratioConfigs(

              /// If your users paint a lot in a short time, you should disable this
              /// flag because it will overload the isolated thread which delay the final result
              /// generateImageInBackground: true,
              ),
        ),
        onImageEditingStarted: onImageEditingStarted,
        onImageEditingComplete: onImageEditingComplete,
        onCloseEditor: onCloseEditor,
      ),
    );
  }

  Widget _buildCropPaintEditor() {
    return CropPaintEditor.asset(
      ExampleConstants.of(context)!.demoAssetPath,
      key: _cropPaintEditorKey,
      initConfigs: CropRotateEditorInitConfigs(
        theme: ThemeData.dark(),
        convertToUint8List: true,
        configs: ProImageEditorConfigs(
          cropRotateEditorConfigs: const CropRotateEditorConfigs(
            canFlip: false,
            canChangeAspectRatio: false,
          ),
          designMode: platformDesignMode,
          imageGenerationConfigs: const ImageGeneratioConfigs(

              /// If your users change a lot stuff in a short time, you should disable this
              /// flag because it will overload the isolated thread which delay the final result.
              /// generateImageInBackground: true,
              ),
        ),
        onImageEditingStarted: onImageEditingStarted,
        onImageEditingComplete: onImageEditingComplete,
        onCloseEditor: onCloseEditor,
      ),
    );
  }

  Widget _buildZoomableMainEditor() {
    return ZoomableMainEditor.asset(
      ExampleConstants.of(context)!.demoAssetPath,
      key: _zoomableMainEditorKey,
      onDone: (rects) {},
      initConfigs: CropRotateEditorInitConfigs(
        layers: [
          Layer.fromMap({
            'x': 0.0,
            'y': 0.0,
            'rawSize': {
              'w': 100.0,
              'h': 100.0,
            },
            'rotation': 0.0,
            'scale': 1.0,
            'flipX': false,
            'flipY': false,
            'type': 'painting',
            'item': {
              'mode': 'cropRect',
              'offsets': [
                {'x': 0.0, 'y': 0.0},
                {'x': 100.0, 'y': 100.0}
              ],
              'color': Colors.red.value,
              'strokeWidth': 5.0,
              'text': 'test',
              // 'fill': true,
            }
          }, []),
          Layer.fromMap({
            'x': 0.0,
            'y': 300.0,
            'rawSize': {
              'w': 100.0,
              'h': 100.0,
            },
            'rotation': 0.0,
            'scale': 1.0,
            'flipX': false,
            'flipY': false,
            'type': 'painting',
            'item': {
              'mode': 'cropRect',
              'offsets': [
                {'x': 0.0, 'y': 0.0},
                {'x': 100.0, 'y': 100.0}
              ],
              'color': Colors.red.value,
              'strokeWidth': 5.0,
              // 'fill': true,
            }
          }, []),
        ],
        theme: ThemeData.dark(),
        convertToUint8List: true,
        configs: ProImageEditorConfigs(
          designMode: platformDesignMode,
          imageGenerationConfigs: const ImageGeneratioConfigs(

              /// If your users change a lot stuff in a short time, you should disable this
              /// flag because it will overload the isolated thread which delay the final result.
              /// generateImageInBackground: true,
              ),
        ),
        onImageEditingStarted: onImageEditingStarted,
        onImageEditingComplete: onImageEditingComplete,
        onCloseEditor: onCloseEditor,
      ),
    );
  }

  Widget _buildCropRotateEditor() {
    return CropRotateEditor.asset(
      ExampleConstants.of(context)!.demoAssetPath,
      key: _cropRotateEditorKey,
      initConfigs: CropRotateEditorInitConfigs(
        theme: ThemeData.dark(),
        convertToUint8List: true,
        configs: ProImageEditorConfigs(
          designMode: platformDesignMode,
          imageGenerationConfigs: const ImageGeneratioConfigs(

              /// If your users change a lot stuff in a short time, you should disable this
              /// flag because it will overload the isolated thread which delay the final result.
              /// generateImageInBackground: true,
              ),
        ),
        onImageEditingStarted: onImageEditingStarted,
        onImageEditingComplete: onImageEditingComplete,
        onCloseEditor: onCloseEditor,
      ),
    );
  }

  Widget _buildFilterEditor() {
    return FilterEditor.asset(
      ExampleConstants.of(context)!.demoAssetPath,
      initConfigs: FilterEditorInitConfigs(
        theme: ThemeData.dark(),
        convertToUint8List: true,
        onImageEditingStarted: onImageEditingStarted,
        onImageEditingComplete: onImageEditingComplete,
        onCloseEditor: onCloseEditor,
        configs: ProImageEditorConfigs(
          designMode: platformDesignMode,
        ),
      ),
    );
  }

  Widget _buildBlurEditor() {
    return BlurEditor.asset(
      ExampleConstants.of(context)!.demoAssetPath,
      initConfigs: BlurEditorInitConfigs(
        theme: ThemeData.dark(),
        convertToUint8List: true,
        onImageEditingStarted: onImageEditingStarted,
        onImageEditingComplete: onImageEditingComplete,
        onCloseEditor: onCloseEditor,
        configs: ProImageEditorConfigs(
          designMode: platformDesignMode,
        ),
      ),
    );
  }
}
