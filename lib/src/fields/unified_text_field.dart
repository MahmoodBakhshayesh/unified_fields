import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_input_controller.dart';
import 'unified_base_text_field.dart';
import 'unified_input_brightness.dart';
import 'unified_input_decoration.dart';

/// Text input using shared unified decoration + optional external [AppInputController] binding.
class UnifiedTextField extends StatefulWidget {
  /// Creates a unified text input.
  const UnifiedTextField({
    super.key,
    this.decoration,
    this.brightness,
    this.controller,
    this.binding,
    this.focusNode,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.disabled = false,
    this.isDisabled = false,
    this.readOnly = false,
    this.locked = false,
    this.autofocus = false,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.obscureText = false,
    this.showClearButton = false,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.start,
    this.initialValue,
    this.placeholder,
    this.label,
    this.mustResolveTextDirectionByInput = false,
    this.isPassword = false,
    this.isRequired = false,
  });

  /// Visual chrome overrides; merged on top of palette defaults.
  final UnifiedInputDecoration? decoration;

  /// Forces a brightness regardless of the ambient [Theme].
  final UnifiedInputBrightness? brightness;

  /// External [TextEditingController]; if null one is created internally.
  final TextEditingController? controller;

  /// Two-way binding to a [String] value.
  final AppInputController<String>? binding;

  /// External focus node; if null one is created by the inner widget.
  final FocusNode? focusNode;

  /// Synchronous validator returning the error message, or null when valid.
  final String? Function(String value)? validator;

  /// Called on every keystroke.
  final ValueChanged<String>? onChanged;

  /// Called when the user submits via the keyboard action button.
  final ValueChanged<String>? onSubmitted;

  /// When true, the field is non-editable and visually muted.
  final bool disabled;

  /// When true, greys out the label and shows a forbid suffix icon.
  final bool isDisabled;

  /// When true, the field rejects edits but still looks active.
  final bool readOnly;

  /// When true, greys out the field and shows a lock suffix icon.
  final bool locked;

  /// Whether the field should request focus on first build.
  final bool autofocus;

  /// Keyboard type.
  final TextInputType? keyboardType;

  /// Keyboard action button.
  final TextInputAction? textInputAction;

  /// Custom input formatters applied to user keystrokes.
  final List<TextInputFormatter>? inputFormatters;

  /// Maximum visible lines.
  final int? maxLines;

  /// Minimum visible lines.
  final int? minLines;

  /// Maximum number of characters (also enforces a counter when set).
  final int? maxLength;

  /// Render entered text as obscured (alias for [isPassword]).
  final bool obscureText;

  /// Show an "x" suffix to clear the field when it has content.
  final bool showClearButton;

  /// Capitalization rule applied to typed text.
  final TextCapitalization textCapitalization;

  /// Horizontal alignment of typed text.
  final TextAlign textAlign;

  /// Initial text when [controller] is null.
  final String? initialValue;

  /// Placeholder / hint text shown when the field is empty.
  final String? placeholder;

  /// Field label.
  final String? label;

  /// If true, the text direction is inferred from the typed content.
  final bool mustResolveTextDirectionByInput;

  /// When true, the field obscures content and adds a visibility toggle.
  final bool isPassword;

  /// When true, marks the field as required (visual hint only).
  final bool isRequired;

  @override
  State<UnifiedTextField> createState() => _UnifiedTextFieldState();
}

class _UnifiedTextFieldState extends State<UnifiedTextField> {
  late TextEditingController _effectiveController;
  bool _ownsController = false;

  @override
  void initState() {
    super.initState();
    _effectiveController = widget.controller ?? TextEditingController(text: widget.initialValue ?? '');
    _ownsController = widget.controller == null;
    final bound = widget.binding?.value;
    if (bound != null && bound.isNotEmpty) {
      _effectiveController.text = bound;
    }
    widget.binding?.addListener(_onBindingChanged);
  }

  @override
  void didUpdateWidget(covariant UnifiedTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (_ownsController) _effectiveController.dispose();
      _effectiveController = widget.controller ?? TextEditingController(text: widget.initialValue ?? '');
      _ownsController = widget.controller == null;
    }
    if (oldWidget.binding != widget.binding) {
      oldWidget.binding?.removeListener(_onBindingChanged);
      widget.binding?.addListener(_onBindingChanged);
    }
  }

  void _onBindingChanged() {
    final v = widget.binding?.value ?? '';
    if (v == _effectiveController.text) return;
    _effectiveController.text = v;
    setState(() {});
  }

  void _forwardChanged(String s) {
    widget.onChanged?.call(s);
    final b = widget.binding;
    if (b != null && b.value != s) {
      b.value = s;
    }
  }

  @override
  void dispose() {
    widget.binding?.removeListener(_onBindingChanged);
    if (_ownsController) _effectiveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = resolveUnifiedDecoration(context, overrides: widget.decoration, brightness: widget.brightness);

    return UnifiedBaseTextField(
      controller: _effectiveController,
      focusNode: widget.focusNode,
      label: widget.label??d.label,
      placeholder: widget.placeholder??d.placeholder ?? d.label,
      labelStyle: d.labelStyle,
      style: d.fieldStyle,
      backgroundColor: d.backgroundColor ?? Colors.black26,
      headerBackgroundColor: d.headerBackgroundColor ?? d.backgroundColor ?? Colors.black26,
      borderRadius: d.borderRadius ?? const BorderRadius.all(Radius.circular(18)),
      borderSide: d.borderSide,
      height: d.height,
      rowLabelRatio: d.rowLabelRatio,
      labelInRow: d.labelInRow,
      requiredField:widget.isRequired,
      showError: d.showError,
      validationColor: d.validationColor,
      validationIcon: d.validationIcon,
      prefix: d.prefix,
      prefixIcon: d.prefixIcon,
      suffixIcon: d.suffixIcon,
      padding: d.contentPadding,
      validator: widget.validator,
      disabled: widget.disabled,
      isDisabled: widget.isDisabled,
      readOnly: widget.readOnly,
      locked: widget.locked,
      autofocus: widget.autofocus,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction ?? TextInputAction.done,
      inputFormatters: widget.inputFormatters,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      isPassword: widget.isPassword || widget.obscureText,
      showClearButton: widget.showClearButton,
      textCapitalization: widget.textCapitalization,
      textAlign: widget.textAlign,
      mustResolveTextDirectionByInput: widget.mustResolveTextDirectionByInput,
      initialValue: widget.controller != null ? null : widget.initialValue,
      onSubmit: widget.onSubmitted,
      onChanged: _forwardChanged,
    );
  }
}
