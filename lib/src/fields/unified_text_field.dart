import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_input_controller.dart';
import 'unified_base_text_field.dart';
import 'unified_input_brightness.dart';
import 'unified_input_decoration.dart';

/// Text input using shared unified decoration + optional external [AppInputController] binding.
class UnifiedTextField extends StatefulWidget {
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

  final UnifiedInputDecoration? decoration;
  final UnifiedInputBrightness? brightness;

  final TextEditingController? controller;
  final AppInputController<String>? binding;
  final FocusNode? focusNode;

  final String? Function(String value)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  final bool disabled;
  final bool readOnly;
  final bool locked;
  final bool autofocus;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool obscureText;
  final bool showClearButton;
  final TextCapitalization textCapitalization;
  final TextAlign textAlign;
  final String? initialValue;
  final String? placeholder;
  final String? label;
  final bool mustResolveTextDirectionByInput;
  final bool isPassword;
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
