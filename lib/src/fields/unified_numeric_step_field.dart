import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/unified_number_field_controller.dart';
import '../unified_colors.dart';
import '../unified_date_picker_types.dart';
import '../unified_fields_typography.dart';
import 'unified_base_text_field.dart';

double _pow10(int digits) {
  var p = 1.0;
  for (var i = 0; i < digits; i++) {
    p *= 10;
  }
  return p;
}

/// When [UnifiedNumericStepField.allowDecimals] is true and [fractionDigits] is null,
/// step rounding uses this many fraction digits. Display formatting stays natural unless
/// [fractionDigits] is set explicitly.
const int _kDecimalStepQuantizeDigits = 2;

/// Numeric step field on [UnifiedBaseTextField]: +/- controls and typed entry.
///
/// [min] / [max] are enforced when the field **loses focus** and when the user
/// presses **done** (submit), not on every keystroke, so partial values like
/// `1` while typing `100` are allowed.
///
/// When [allowDecimals] is true and [fractionDigits] is set, formatting and step rounding
/// use that precision. If [fractionDigits] is null, typed values are formatted without
/// forcing trailing zeros; +/- stepping still quantizes to [_kDecimalStepQuantizeDigits]
/// fractional digits to avoid float drift.
///
/// Prefer using [UnifiedNumberField] for app styling; this is the raw unified primitive.
class UnifiedNumericStepField extends StatefulWidget {
  /// Creates a numeric step field.
  const UnifiedNumericStepField({
    super.key,
    this.controller,
    this.fieldController,
    this.focusNode,
    this.label,
    this.placeholder,
    this.labelStyle,
    this.padding,
    this.borderRadius = const BorderRadius.all(Radius.circular(18)),
    this.borderSide = const BorderSide(color: Color(0xff58514C), width: 0.5),
    this.backgroundColor = Colors.black26,
    this.headerBackgroundColor,
    this.height = 56,
    this.style,
    this.allowDecimals = false,
    this.step = 1,
    this.min,
    this.max,
    this.disabled = false,
    this.isDisabled = false,
    this.readOnly = false,
    this.locked = false,
    this.autofocus = false,
    this.textInputAction,
    this.validator,
    this.showError = true,
    this.validationColor,
    this.validationIcon,
    this.onChanged,
    this.onSubmitted,
    this.fractionDigits,
    this.requiredField = false,
    this.digitCalendarKind,
  }) : assert(step != 0, 'step must be non-zero');

  /// External [TextEditingController]; if null one is created internally.
  final TextEditingController? controller;

  /// Preferred imperative handle (numeric value + text surface).
  final UnifiedNumberFieldController? fieldController;

  /// External focus node.
  final FocusNode? focusNode;

  /// Field label.
  final String? label;

  /// Placeholder / hint shown when empty.
  final String? placeholder;

  /// Override for the label text style.
  final TextStyle? labelStyle;

  /// Inner content padding.
  final EdgeInsetsGeometry? padding;

  /// Border radius of the field box.
  final BorderRadius borderRadius;

  /// Border side of the field box.
  final BorderSide borderSide;

  /// Background color of the field.
  final Color backgroundColor;

  /// Background of the left label area when in row layout.
  final Color? headerBackgroundColor;

  /// Minimum height of the inner row.
  final double? height;

  /// Override for the editing text style.
  final TextStyle? style;

  /// When set (e.g. [UnifiedFieldsCalendarKind.jalali]), displayed digits use
  /// [UnifiedFieldsTypography] for that calendar context.
  final UnifiedFieldsCalendarKind? digitCalendarKind;

  /// When true, allow decimal values.
  final bool allowDecimals;

  /// Step applied by the +/- buttons (must be non-zero).
  final num step;

  /// Minimum allowed value (enforced on focus loss / submit).
  final num? min;

  /// Maximum allowed value (enforced on focus loss / submit).
  final num? max;

  /// When true, the field is non-editable and visually muted.
  final bool disabled;

  /// When true, greys out the label and shows a forbid suffix icon.
  final bool isDisabled;

  /// When true, greys out the field and shows a lock suffix icon.
  final bool locked;

  /// When true, the field rejects edits.
  final bool readOnly;

  /// Autofocus the field on first build.
  final bool autofocus;

  /// Keyboard action button.
  final TextInputAction? textInputAction;

  /// Synchronous validator returning the error message, or null when valid.
  final String? Function(String value)? validator;

  /// Render the inline error strip when present.
  final bool showError;

  /// Color used for error chrome.
  final Color? validationColor;

  /// Optional icon shown in the inline error strip.
  final IconData? validationIcon;

  /// Called when the numeric value changes (from typing or +/- buttons).
  final ValueChanged<num>? onChanged;

  /// Called on keyboard submit.
  final ValueChanged<String>? onSubmitted;

  /// Number of decimal digits to render when [allowDecimals] is true.
  final int? fractionDigits;

  /// Shows the required marker next to [label].
  final bool requiredField;

  @override
  State<UnifiedNumericStepField> createState() => _UnifiedNumericStepFieldState();
}

class _UnifiedNumericStepFieldState extends State<UnifiedNumericStepField> {
  late TextEditingController _effectiveController;
  bool _ownsController = false;

  late FocusNode _focusNode;
  bool _ownsFocusNode = false;

  Timer? _holdInitialDelayTimer;
  Timer? _holdRepeatTimer;

  static const Duration _holdRepeatInitialDelay = Duration(milliseconds: 450);
  static const Duration _holdRepeatInterval = Duration(milliseconds: 55);

  int get _quantizeFractionDigits => widget.fractionDigits ?? _kDecimalStepQuantizeDigits;

  @override
  void initState() {
    super.initState();
    _initControllers();
    widget.fieldController?.addListener(_onFieldController);
  }

  void _initControllers() {
    _effectiveController =
        widget.fieldController?.text.textController ?? widget.controller ?? TextEditingController();
    _ownsController = widget.fieldController == null && widget.controller == null;
    _focusNode = widget.fieldController?.focusNode ?? widget.focusNode ?? FocusNode();
    _ownsFocusNode = widget.fieldController == null && widget.focusNode == null;
    _focusNode.addListener(_onFocusChanged);
  }

  void _onFieldController() => setState(() {});

  @override
  void didUpdateWidget(covariant UnifiedNumericStepField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fieldController != widget.fieldController || oldWidget.controller != widget.controller) {
      _focusNode.removeListener(_onFocusChanged);
      if (_ownsFocusNode) _focusNode.dispose();
      if (_ownsController) _effectiveController.dispose();
      oldWidget.fieldController?.removeListener(_onFieldController);
      widget.fieldController?.addListener(_onFieldController);
      _initControllers();
    } else if (oldWidget.focusNode != widget.focusNode) {
      _focusNode.removeListener(_onFocusChanged);
      if (_ownsFocusNode) {
        _focusNode.dispose();
      }
      _focusNode = widget.focusNode ?? FocusNode();
      _ownsFocusNode = widget.focusNode == null;
      _focusNode.addListener(_onFocusChanged);
    }
  }

  @override
  void dispose() {
    _endStepHold();
    widget.fieldController?.removeListener(_onFieldController);
    _focusNode.removeListener(_onFocusChanged);
    if (_ownsFocusNode) {
      _focusNode.dispose();
    }
    if (_ownsController) {
      _effectiveController.dispose();
    }
    super.dispose();
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) {
      _clampTypedValueIfOutOfRange();
    }
  }

  void _clampTypedValueIfOutOfRange() {
    final raw = _effectiveController.text;
    final parsed = _tryParse(raw);
    if (parsed == null) return;

    final clamped = _clamp(parsed);
    if (clamped != parsed) {
      final formatted = _formatCommitted(clamped);
      _effectiveController.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
      widget.onChanged?.call(clamped);
      return;
    }

    if (widget.allowDecimals && _hasTrailingDecimalPointForTyping(raw)) {
      final formatted = _formatCommitted(parsed);
      if (formatted != raw) {
        _effectiveController.value = TextEditingValue(
          text: formatted,
          selection: TextSelection.collapsed(offset: formatted.length),
        );
        widget.onChanged?.call(parsed);
      }
    }
  }

  bool _hasTrailingDecimalPointForTyping(String raw) {
    final s = raw.trim();
    if (s.isEmpty || !widget.allowDecimals) return false;
    return s.endsWith('.') && !s.endsWith('..');
  }

  void _beginStepHold(num delta) {
    _endStepHold();
    if (widget.disabled || widget.isDisabled || widget.locked || widget.readOnly) return;

    _applyDelta(delta);

    _holdInitialDelayTimer = Timer(_holdRepeatInitialDelay, () {
      _holdInitialDelayTimer = null;
      _holdRepeatTimer = Timer.periodic(_holdRepeatInterval, (_) => _applyDelta(delta));
    });
  }

  void _endStepHold() {
    _holdInitialDelayTimer?.cancel();
    _holdInitialDelayTimer = null;
    _holdRepeatTimer?.cancel();
    _holdRepeatTimer = null;
  }

  num? _tryParse(String raw) {
    final s = UnifiedFieldsTypography.fromPersianDigits(raw.trim());
    if (s.isEmpty || s == '-' || s == '+' || s == '.' || s == '-.' || s == '+.') {
      return null;
    }
    if (widget.allowDecimals) {
      return num.tryParse(s);
    }
    return int.tryParse(s);
  }

  num _clamp(num value) {
    var v = value;
    final minV = widget.min;
    final maxV = widget.max;
    if (minV != null && v < minV) v = minV;
    if (maxV != null && v > maxV) v = maxV;
    return v;
  }

  num _baselineForStep() {
    final parsed = _tryParse(_effectiveController.text);
    if (parsed != null) return parsed;
    return 0;
  }

  void _applyDelta(num delta) {
    if (widget.disabled || widget.isDisabled || widget.locked || widget.readOnly) return;

    num next = _baselineForStep() + delta;
    next = _clamp(next);

    if (!widget.allowDecimals) {
      next = next.round();
    } else if (widget.fractionDigits != null) {
      final factor = _pow10(widget.fractionDigits!);
      next = (next * factor).round() / factor;
    } else {
      final factor = _pow10(_quantizeFractionDigits);
      next = (next * factor).round() / factor;
    }

    final formatted = _formatCommitted(next);
    _effectiveController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
    widget.onChanged?.call(next);
    final fc = widget.fieldController;
    if (fc != null && fc.value != next) {
      fc.value = next;
    }
  }

  String _formatCommitted(num value) {
    final String raw;
    if (!widget.allowDecimals) {
      raw = value.round().toString();
    } else {
      final fd = widget.fractionDigits;
      if (fd != null) {
        raw = value.toDouble().toStringAsFixed(fd);
      } else {
        final d = value.toDouble();
        if (!d.isFinite) {
          raw = d.toString();
        } else if (d % 1 == 0) {
          raw = d.toInt().toString();
        } else {
          raw = d.toString();
        }
      }
    }
    return UnifiedFieldsTypography.instance.localizeDigits(
      raw,
      calendarKind: widget.digitCalendarKind,
    );
  }

  List<TextInputFormatter> get _formatters {
    if (widget.allowDecimals) {
      return [
        FilteringTextInputFormatter.allow(RegExp(r'^[-+]?\d*\.?\d*')),
      ];
    }
    return [
      FilteringTextInputFormatter.allow(RegExp(r'^[-+]?\d*')),
    ];
  }

  TextInputType get _keyboardType {
    return widget.allowDecimals ? const TextInputType.numberWithOptions(decimal: true, signed: true) : const TextInputType.numberWithOptions(decimal: false, signed: true);
  }

  Widget _stepButton({required IconData icon, required num delta}) {
    final enabled = !widget.disabled && !widget.isDisabled && !widget.locked && !widget.readOnly;
    final h = widget.height != null ? (widget.height! - 8).clamp(32.0, 56.0).toDouble() : 40.0;

    return ExcludeFocus(
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: enabled ? (_) => _beginStepHold(delta) : null,
          onTapUp: enabled ? (_) => _endStepHold() : null,
          onTapCancel: enabled ? _endStepHold : null,
          child: SizedBox(
            width: 40,
            height: h,
            child: Icon(
              icon,
              size: 22,
              color: enabled ? UnifiedColors.textColorDark.withValues(alpha: 0.85) : UnifiedColors.textColorDark.withValues(alpha: 0.35),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final placeholder = widget.placeholder ?? widget.label;

    return UnifiedBaseTextField(
      label: widget.label,
      labelStyle: widget.labelStyle,
      focusNode: _focusNode,
      controller: _effectiveController,
      errorText: widget.fieldController?.errorText,
      placeholder: placeholder,
      borderRadius: widget.borderRadius,
      backgroundColor: widget.backgroundColor,
      headerBackgroundColor: widget.headerBackgroundColor ?? widget.backgroundColor,
      borderSide: widget.borderSide,
      validator: widget.validator,
      height: widget.height,
      keyboardType: _keyboardType,
      inputFormatters: _formatters,
      textAlign: TextAlign.center,
      style: widget.style ?? TextStyle(color: UnifiedColors.textColorDark),
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 4),
      disabled: widget.disabled,
      isDisabled: widget.isDisabled,
      locked: widget.locked,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      textInputAction: widget.textInputAction ?? TextInputAction.done,
      requiredField: widget.requiredField,
      showError: widget.showError,
      validationColor: widget.validationColor,
      validationIcon: widget.validationIcon,
      onSubmit: (_) {
        _clampTypedValueIfOutOfRange();
        widget.onSubmitted?.call(_effectiveController.text);
      },
      prefix: widget.isDisabled || widget.disabled || widget.locked
          ? null
          : _stepButton(
              icon: Icons.remove_rounded,
              delta: -widget.step,
            ),
      suffixIcon: widget.isDisabled || widget.disabled || widget.locked
          ? null
          : _stepButton(
              icon: Icons.add_rounded,
              delta: widget.step,
            ),
      onChanged: (_) {
        final text = _effectiveController.text;
        if (_hasTrailingDecimalPointForTyping(text)) return;
        final parsed = _tryParse(text);
        if (parsed != null) widget.onChanged?.call(parsed);
      },
    );
  }
}
