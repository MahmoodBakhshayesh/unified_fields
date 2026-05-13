import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_colors.dart';
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
  const UnifiedNumericStepField({
    super.key,
    this.controller,
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
    this.readOnly = false,
    this.autofocus = false,
    this.textInputAction,
    this.validator,
    this.showError = true,
    this.validationColor,
    this.validationIcon,
    this.onChanged,
    this.onSubmitted,
    this.fractionDigits,
  }) : assert(step != 0, 'step must be non-zero');

  final TextEditingController? controller;
  final FocusNode? focusNode;

  final String? label;
  final String? placeholder;
  final TextStyle? labelStyle;
  final EdgeInsetsGeometry? padding;
  final BorderRadius borderRadius;
  final BorderSide borderSide;
  final Color backgroundColor;
  final Color? headerBackgroundColor;
  final double? height;
  final TextStyle? style;

  final bool allowDecimals;
  final num step;

  final num? min;
  final num? max;

  final bool disabled;
  final bool readOnly;
  final bool autofocus;
  final TextInputAction? textInputAction;

  final String? Function(String value)? validator;
  final bool showError;
  final Color? validationColor;
  final IconData? validationIcon;

  final ValueChanged<num>? onChanged;
  final ValueChanged<String>? onSubmitted;

  final int? fractionDigits;

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
    _effectiveController = widget.controller ?? TextEditingController();
    _ownsController = widget.controller == null;
    _focusNode = widget.focusNode ?? FocusNode();
    _ownsFocusNode = widget.focusNode == null;
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(covariant UnifiedNumericStepField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (_ownsController) {
        _effectiveController.dispose();
      }
      _effectiveController = widget.controller ?? TextEditingController();
      _ownsController = widget.controller == null;
    }
    if (oldWidget.focusNode != widget.focusNode) {
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
    if (widget.disabled || widget.readOnly) return;

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
    final s = raw.trim();
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
    if (widget.disabled || widget.readOnly) return;

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
  }

  String _formatCommitted(num value) {
    if (!widget.allowDecimals) {
      return value.round().toString();
    }
    final fd = widget.fractionDigits;
    if (fd != null) {
      return value.toDouble().toStringAsFixed(fd);
    }
    final d = value.toDouble();
    if (!d.isFinite) return d.toString();
    if (d % 1 == 0) return d.toInt().toString();
    return d.toString();
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
    final enabled = !widget.disabled && !widget.readOnly;
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
              color: enabled ? AppColors.textColorDark.withValues(alpha: 0.85) : AppColors.textColorDark.withValues(alpha: 0.35),
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
      style: widget.style ?? TextStyle(color: AppColors.textColorDark),
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 4),
      disabled: widget.disabled,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      textInputAction: widget.textInputAction ?? TextInputAction.done,
      showError: widget.showError,
      validationColor: widget.validationColor,
      validationIcon: widget.validationIcon,
      onSubmit: (_) {
        _clampTypedValueIfOutOfRange();
        widget.onSubmitted?.call(_effectiveController.text);
      },
      prefix: _stepButton(
        icon: Icons.remove_rounded,
        delta: -widget.step,
      ),
      suffixIcon: _stepButton(
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
