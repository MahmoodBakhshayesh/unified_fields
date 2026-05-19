import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/field_controller_sync.dart';
import '../controllers/unified_number_field_controller.dart';
import '../unified_colors.dart';
import '../unified_date_picker_types.dart';
import '../unified_fields_typography.dart';
import 'unified_base_text_field.dart';
import 'unified_input_brightness.dart';
import 'unified_input_decoration.dart';
import 'unified_numeric_step_buttons.dart';
import 'unified_suffix_icon.dart';

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
    this.placeholderStyle,
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
    this.selectTextOnFocus,
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
    this.decorationSet,
    this.brightness,
    this.prefix,
    this.prefixIcon,
    this.suffixIcon,
    this.suffixWidth,
    this.suffixHeight,
    this.stepButtons = UnifiedNumericStepButtons.both,
    this.stepButtonPlacement = UnifiedNumericStepButtonPlacement.split,
    this.decrementIcon = Icons.remove_rounded,
    this.incrementIcon = Icons.add_rounded,
    this.textAlign = TextAlign.center,
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

  /// Placeholder / hint text style.
  final TextStyle? placeholderStyle;

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

  /// Per-state decorations for the inner [UnifiedBaseTextField].
  final UnifiedInputDecorationSet? decorationSet;

  /// Brightness used when resolving [decorationSet].
  final UnifiedInputBrightness? brightness;

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

  /// When true, focuses selects all text so the next keystroke replaces it.
  final bool? selectTextOnFocus;

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

  /// Leading adornment before step buttons (from [UnifiedInputDecoration.prefix]).
  final Widget? prefix;

  /// Leading icon adornment (from [UnifiedInputDecoration.prefixIcon]).
  final Widget? prefixIcon;

  /// Trailing adornment after step buttons (from [UnifiedInputDecoration.suffixIcon]).
  final Widget? suffixIcon;

  /// Slot width for [suffixIcon]; see [UnifiedInputDecoration.suffixWidth].
  final double? suffixWidth;

  /// Slot height for [suffixIcon]; see [UnifiedInputDecoration.suffixHeight].
  final double? suffixHeight;

  /// Which +/- buttons to show.
  final UnifiedNumericStepButtons stepButtons;

  /// Where step buttons are placed relative to adornments.
  final UnifiedNumericStepButtonPlacement stepButtonPlacement;

  /// Icon for the decrement button.
  final IconData decrementIcon;

  /// Icon for the increment button.
  final IconData incrementIcon;

  /// Horizontal alignment of the numeric value.
  final TextAlign textAlign;

  @override
  State<UnifiedNumericStepField> createState() =>
      _UnifiedNumericStepFieldState();
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

  int get _quantizeFractionDigits =>
      widget.fractionDigits ?? _kDecimalStepQuantizeDigits;

  @override
  void initState() {
    super.initState();
    _initControllers();
    widget.fieldController?.addListener(_onFieldController);
  }

  void _initControllers() {
    _effectiveController =
        widget.fieldController?.text.textController ??
        widget.controller ??
        TextEditingController();
    _ownsController =
        widget.fieldController == null && widget.controller == null;
    _focusNode =
        widget.fieldController?.focusNode ?? widget.focusNode ?? FocusNode();
    _ownsFocusNode = widget.fieldController == null && widget.focusNode == null;
    _focusNode.addListener(_onFocusChanged);
    syncNumberDisplayValidatorToFieldController(
      widget.fieldController,
      widget.validator,
    );
  }

  void _onFieldController() => setState(() {});

  @override
  void didUpdateWidget(covariant UnifiedNumericStepField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fieldController != widget.fieldController ||
        oldWidget.controller != widget.controller) {
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
    if (oldWidget.validator != widget.validator ||
        oldWidget.fieldController != widget.fieldController) {
      syncNumberDisplayValidatorToFieldController(
        widget.fieldController,
        widget.validator,
      );
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
    if (widget.disabled ||
        widget.isDisabled ||
        widget.locked ||
        widget.readOnly) {
      return;
    }

    _applyDelta(delta);

    _holdInitialDelayTimer = Timer(_holdRepeatInitialDelay, () {
      _holdInitialDelayTimer = null;
      _holdRepeatTimer = Timer.periodic(
        _holdRepeatInterval,
        (_) => _applyDelta(delta),
      );
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
    if (s.isEmpty ||
        s == '-' ||
        s == '+' ||
        s == '.' ||
        s == '-.' ||
        s == '+.') {
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
    if (widget.disabled ||
        widget.isDisabled ||
        widget.locked ||
        widget.readOnly) {
      return;
    }

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
      return [FilteringTextInputFormatter.allow(RegExp(r'^[-+]?\d*\.?\d*'))];
    }
    return [FilteringTextInputFormatter.allow(RegExp(r'^[-+]?\d*'))];
  }

  TextInputType get _keyboardType {
    return widget.allowDecimals
        ? const TextInputType.numberWithOptions(decimal: true, signed: true)
        : const TextInputType.numberWithOptions(decimal: false, signed: true);
  }

  bool get _stepButtonsActive =>
      !widget.disabled &&
      !widget.isDisabled &&
      !widget.locked &&
      !widget.readOnly;

  bool get _showDecrementButton =>
      _stepButtonsActive &&
      widget.stepButtons != UnifiedNumericStepButtons.none &&
      widget.stepButtons != UnifiedNumericStepButtons.incrementOnly;

  bool get _showIncrementButton =>
      _stepButtonsActive &&
      widget.stepButtons != UnifiedNumericStepButtons.none &&
      widget.stepButtons != UnifiedNumericStepButtons.decrementOnly;

  List<Widget> _decrementStepWidgets() =>
      _showDecrementButton
          ? [
              _stepButton(
                icon: widget.decrementIcon,
                delta: -widget.step,
              ),
            ]
          : const [];

  List<Widget> _incrementStepWidgets() =>
      _showIncrementButton
          ? [_stepButton(icon: widget.incrementIcon, delta: widget.step)]
          : const [];

  List<Widget> _stepWidgetsForSide({required bool leading}) {
    switch (widget.stepButtonPlacement) {
      case UnifiedNumericStepButtonPlacement.split:
        return leading ? _decrementStepWidgets() : _incrementStepWidgets();
      case UnifiedNumericStepButtonPlacement.leading:
        if (!leading) return const [];
        return [..._decrementStepWidgets(), ..._incrementStepWidgets()];
      case UnifiedNumericStepButtonPlacement.trailing:
        if (leading) return const [];
        return [..._decrementStepWidgets(), ..._incrementStepWidgets()];
    }
  }

  List<Widget> _decorationLeadingWidgets() {
    final widgets = <Widget>[];
    if (widget.prefixIcon != null) {
      widgets.add(UnifiedSuffixIconChrome.normalize(widget.prefixIcon!));
    }
    if (widget.prefix != null) {
      widgets.add(UnifiedSuffixIconChrome.normalize(widget.prefix!));
    }
    return widgets;
  }

  Widget? _decorationTrailingWidget() {
    final suffix = widget.suffixIcon;
    if (suffix == null) return null;
    return UnifiedSuffixIconChrome.normalize(
      suffix,
      width: widget.suffixWidth,
      height: widget.suffixHeight,
    );
  }

  Widget? _joinRow(List<Widget> children) {
    if (children.isEmpty) return null;
    if (children.length == 1) return children.first;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: children,
    );
  }

  /// Leading edge: decoration prefix at intrinsic size, then step buttons.
  Widget? _composePrefix() {
    return _joinRow([
      ..._decorationLeadingWidgets(),
      ..._stepWidgetsForSide(leading: true),
    ]);
  }

  /// Trailing edge: step buttons, then decoration suffix at intrinsic size.
  Widget? _composeTrailingSuffixIcon() {
    final trailing = _decorationTrailingWidget();
    return _joinRow([
      ..._stepWidgetsForSide(leading: false),
      ?trailing,
    ]);
  }

  Widget _stepButton({required IconData icon, required num delta}) {
    final enabled =
        !widget.disabled &&
        !widget.isDisabled &&
        !widget.locked &&
        !widget.readOnly;
    final h = widget.height != null
        ? (widget.height! - 8).clamp(32.0, 56.0).toDouble()
        : 40.0;

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
              color: enabled
                  ? UnifiedColors.textColorDark.withValues(alpha: 0.85)
                  : UnifiedColors.textColorDark.withValues(alpha: 0.35),
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
      decorationSet: widget.decorationSet,
      brightness: widget.brightness,
      digitCalendarKind: widget.digitCalendarKind,
      label: widget.label,
      labelStyle: widget.labelStyle,
      placeholderStyle: widget.placeholderStyle,
      focusNode: _focusNode,
      controller: _effectiveController,
      errorText: widget.fieldController?.errorText,
      placeholder: placeholder,
      borderRadius: widget.borderRadius,
      backgroundColor: widget.backgroundColor,
      headerBackgroundColor:
          widget.headerBackgroundColor ?? widget.backgroundColor,
      borderSide: widget.borderSide,
      validator: widget.validator,
      height: widget.height,
      keyboardType: _keyboardType,
      inputFormatters: _formatters,
      textAlign: widget.textAlign,
      style: widget.style,
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 4),
      disabled: widget.disabled,
      isDisabled: widget.isDisabled,
      locked: widget.locked,
      readOnly: widget.readOnly,
      autofocus: widget.autofocus,
      selectTextOnFocus: widget.selectTextOnFocus,
      textInputAction: widget.textInputAction ?? TextInputAction.done,
      requiredField: widget.requiredField,
      showError: widget.showError,
      validationColor: widget.validationColor,
      validationIcon: widget.validationIcon,
      onSubmit: (_) {
        _clampTypedValueIfOutOfRange();
        widget.onSubmitted?.call(_effectiveController.text);
      },
      prefix: _composePrefix(),
      suffixIcon: _composeTrailingSuffixIcon(),
      onChanged: (_) {
        final text = _effectiveController.text;
        if (_hasTrailingDecimalPointForTyping(text)) return;
        final parsed = _tryParse(text);
        if (parsed != null) widget.onChanged?.call(parsed);
      },
    );
  }
}
