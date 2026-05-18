import 'package:flutter/widgets.dart';

import 'base_unified_field_controller.dart';

/// Controller for [UnifiedTextField] — owns [textController] and [focusNode].
class UnifiedTextFieldController extends BaseUnifiedFieldController<String> {
  /// Creates a text field controller.
  UnifiedTextFieldController({
    String? initialValue,
    super.validator,
    FocusNode? focusNode,
    TextEditingController? textController,
  }) : textController =
           textController ?? TextEditingController(text: initialValue ?? ''),
       _ownsTextController = textController == null,
       super(
         initialValue: initialValue == null || initialValue.isEmpty
             ? null
             : initialValue,
         focusNode: focusNode,
       ) {
    this.textController.addListener(_onTextChanged);
  }

  /// Underlying text controller passed to the field widget.
  final TextEditingController textController;

  final bool _ownsTextController;

  static String? _emptyToNull(String? s) => (s == null || s.isEmpty) ? null : s;

  void _onTextChanged() {
    applyValueFromUser(_emptyToNull(textController.text));
  }

  @override
  String? get value => _emptyToNull(textController.text);

  @override
  set value(String? next) {
    final text = next ?? '';
    if (textController.text != text) {
      textController.text = text;
    }
    applyValueFromUser(_emptyToNull(text));
  }

  @override
  String? validate() {
    final err = validator?.call(
      textController.text.isEmpty ? null : textController.text,
    );
    if (err != null && err.isNotEmpty) {
      setError(err);
      return err;
    }
    clearError();
    return null;
  }

  @override
  void clear() {
    textController.clear();
    clearError();
    silentSetValue(null);
    notifyListeners();
  }

  @override
  void dispose() {
    textController.removeListener(_onTextChanged);
    if (_ownsTextController) {
      textController.dispose();
    }
    super.dispose();
  }
}
