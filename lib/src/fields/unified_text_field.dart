import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/field_controller_sync.dart';
import '../controllers/unified_text_field_controller.dart';
import 'unified_input_picker.dart';
import 'unified_base_text_field.dart';
import 'unified_input_brightness.dart';
import 'unified_field_decoration_context.dart';
import 'unified_input_decoration.dart';

/// Text input using shared unified decoration + optional external [UnifiedInputPicker] binding.
class UnifiedTextField extends StatefulWidget {
  /// Creates a unified text input.
  const UnifiedTextField({
    super.key,
    this.decoration,
    this.decorationSet,
    this.brightness,
    this.controller,
    this.fieldController,
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
    this.selectTextOnFocus,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.obscureText = false,
    this.showClearButton,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.start,
    this.initialValue,
    this.placeholder,
    this.label,
    this.mustResolveTextDirectionByInput,
    this.isPassword = false,
    this.isRequired = false,
  });

  /// Visual chrome overrides; merged on top of palette defaults.
  final UnifiedInputDecoration? decoration;

  /// Per-state decorations (focus, error, valid, locked, disabled, …).
  final UnifiedInputDecorationSet? decorationSet;

  /// Forces a brightness regardless of the ambient [Theme].
  final UnifiedInputBrightness? brightness;

  /// External [TextEditingController]; if null one is created internally.
  final TextEditingController? controller;

  /// Preferred imperative handle (value, validate, focus). When set, overrides
  /// [controller] and [focusNode] and syncs with [binding] if present.
  final UnifiedTextFieldController? fieldController;

  /// Two-way binding to a [String] value.
  final UnifiedInputPicker<String>? binding;

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

  /// When true, focuses selects all text so the next keystroke replaces it.
  final bool? selectTextOnFocus;

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

  /// Show an "x" suffix to clear the field when it has content (`null` → theme).
  final bool? showClearButton;

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

  /// If true, the text direction is inferred from the typed content (`null` → theme).
  final bool? mustResolveTextDirectionByInput;

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

  UnifiedTextFieldController? get _fc => widget.fieldController;

  @override
  void initState() {
    super.initState();
    _initController();
    _syncBindingFromExternal();
    widget.binding?.addListener(_onBindingChanged);
    _fc?.addListener(_onFieldControllerChanged);
  }

  void _syncFieldControllerValidator() {
    syncWidgetStringValidatorToFieldController(_fc, widget.validator);
  }

  void _initController() {
    if (_fc != null) {
      _effectiveController = _fc!.textController;
      _ownsController = false;
      _syncFieldControllerValidator();
      return;
    }
    _effectiveController =
        widget.controller ??
        TextEditingController(text: widget.initialValue ?? '');
    _ownsController = widget.controller == null;
  }

  void _syncBindingFromExternal() {
    final bound = widget.binding?.value ?? _fc?.value;
    if (bound != null &&
        bound.isNotEmpty &&
        bound != _effectiveController.text) {
      _effectiveController.text = bound;
    }
  }

  void _syncFocusTarget() {
    attachUnifiedFieldHandles(
      opener: null,
      focusNode: unifiedEffectiveFocusNode(
        fieldController: widget.fieldController,
        binding: widget.binding,
        direct: widget.focusNode,
      ),
      binding: widget.binding,
      fieldController: widget.fieldController,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncFocusTarget();
  }

  @override
  void didUpdateWidget(covariant UnifiedTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fieldController != widget.fieldController ||
        oldWidget.binding != widget.binding ||
        oldWidget.focusNode != widget.focusNode) {
      detachUnifiedFieldHandles(
        binding: oldWidget.binding,
        fieldController: oldWidget.fieldController,
      );
      _syncFocusTarget();
    }
    if (oldWidget.fieldController != widget.fieldController ||
        oldWidget.controller != widget.controller) {
      if (_ownsController) _effectiveController.dispose();
      _initController();
    }
    if (oldWidget.binding != widget.binding) {
      oldWidget.binding?.removeListener(_onBindingChanged);
      widget.binding?.addListener(_onBindingChanged);
    }
    if (oldWidget.fieldController != widget.fieldController) {
      oldWidget.fieldController?.removeListener(_onFieldControllerChanged);
      widget.fieldController?.addListener(_onFieldControllerChanged);
    }
    if (oldWidget.validator != widget.validator ||
        oldWidget.fieldController != widget.fieldController) {
      _syncFieldControllerValidator();
    }
  }

  void _onBindingChanged() {
    final v = widget.binding?.value ?? '';
    if (v == _effectiveController.text) return;
    _effectiveController.text = v;
    _fc?.silentSetValue(v.isEmpty ? null : v);
    setState(() {});
  }

  void _onFieldControllerChanged() => setState(() {});

  void _forwardChanged(String s) {
    widget.onChanged?.call(s);
    final b = widget.binding;
    if (b != null && b.value != s) {
      b.value = s;
    }
    final fc = _fc;
    if (fc != null) {
      final next = s.isEmpty ? null : s;
      if (fc.value != next) {
        fc.value = next;
      }
    }
  }

  @override
  void dispose() {
    detachUnifiedFieldHandles(
      binding: widget.binding,
      fieldController: widget.fieldController,
    );
    widget.binding?.removeListener(_onBindingChanged);
    _fc?.removeListener(_onFieldControllerChanged);
    if (_ownsController) _effectiveController.dispose();
    super.dispose();
  }

  Widget _buildField(
    BuildContext context,
    UnifiedInputDecoration d,
    UnifiedInputDecorationSet? activeDecorationSet,
  ) {
    return UnifiedBaseTextField(
      decorationSet: activeDecorationSet,
      brightness: widget.brightness,
      controller: _effectiveController,
      focusNode: unifiedEffectiveFocusNode(
        fieldController: widget.fieldController,
        binding: widget.binding,
        direct: widget.focusNode,
      ),
      errorText: _fc?.errorText,
      label: widget.label ?? d.label,
      placeholder: widget.placeholder ?? d.placeholder,
      labelStyle: d.labelStyle,
      style: d.fieldStyle,
      placeholderStyle: d.placeholderStyle,
      backgroundColor: d.backgroundColor,
      headerBackgroundColor: d.headerBackgroundColor ?? d.backgroundColor,
      borderRadius: d.borderRadius,
      borderSide: d.borderSide,
      height: d.height,
      rowLabelRatio: d.rowLabelRatio.isNotEmpty ? d.rowLabelRatio : null,
      labelMode: d.labelMode,
      requiredField: widget.isRequired,
      showError: d.showError,
      validationColor: d.validationColor,
      validationIcon: d.validationIcon,
      prefix: d.prefix,
      prefixIcon: d.prefixIcon,
      suffixIcon: d.suffixIcon,
      padding: d.contentPadding,
      validator: _fc != null
          ? (v) {
              final err =
                  _fc!.validator?.call(v.isEmpty ? null : v) ??
                  widget.validator?.call(v);
              if (err != null && err.isNotEmpty) {
                _fc!.setError(err);
              } else {
                _fc!.clearError();
              }
              return err;
            }
          : widget.validator,
      disabled: widget.disabled,
      isDisabled: widget.isDisabled,
      readOnly: widget.readOnly,
      locked: widget.locked,
      autofocus: widget.autofocus,
      selectTextOnFocus: widget.selectTextOnFocus,
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

  @override
  Widget build(BuildContext context) {
    _syncFieldControllerValidator();
    final chrome = resolveUnifiedFieldDecorationContext(
      context,
      decoration: widget.decoration,
      decorationSet: widget.decorationSet,
      brightness: widget.brightness,
    );
    final d = chrome.resolved;

    final field = _buildField(context, d, chrome.activeSet);
    final fc = _fc;
    if (fc == null) return field;
    return ListenableBuilder(
      listenable: fc,
      builder: (context, _) => _buildField(context, d, chrome.activeSet),
    );
  }
}
