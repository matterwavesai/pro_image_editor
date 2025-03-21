/// Internationalization (i18n) settings for the Crop and Rotate Editor component.
class I18nCropRotateEditor {
  /// Text for the bottom navigation bar item that opens the Crop and Rotate Editor.
  final String bottomNavigationBarText;

  /// Text for the "Rotate" tooltip.
  final String rotate;

  /// Text for the "Flip" tooltip.
  final String flip;

  /// Text for the "Ratio" tooltip.
  final String ratio;

  /// Text for the "Back" button.
  final String back;

  /// Text for the "Cancel" button. Only available when the theme is set to `WhatsApp`.
  final String cancel;

  /// Text for the "Done" button.
  final String done;

  /// Text for the "Reset" button.
  final String reset;

  /// Text for the "Undo" button.
  final String undo;

  /// Text for the "Redo" button.
  final String redo;

  /// The tooltip text displayed for the "More" option on small screens.
  final String smallScreenMoreTooltip;

  /// Creates an instance of [I18nCropRotateEditor] with customizable internationalization settings.
  ///
  /// You can provide translations and messages for various components of the
  /// Crop and Rotate Editor in the Image Editor. Customize the text for buttons,
  /// options, and messages to suit your application's language and style.
  ///
  /// Example:
  ///
  /// ```dart
  /// I18nCropRotateEditor(
  ///   bottomNavigationBarText: 'Crop & Rotate',
  ///   rotate: 'Rotate',
  ///   ratio: 'Ratio',
  ///   back: 'Back',
  ///   done: 'Done',
  /// )
  /// ```
  const I18nCropRotateEditor({
    this.bottomNavigationBarText = 'Crop/ Rotate',
    this.rotate = 'Rotate',
    this.flip = 'Flip',
    this.ratio = 'Ratio',
    this.back = 'Back',
    this.done = 'Done',
    this.cancel = 'Cancel',
    this.undo = 'Undo',
    this.redo = 'Redo',
    this.smallScreenMoreTooltip = 'More',
    this.reset = 'Reset',
  });
}
