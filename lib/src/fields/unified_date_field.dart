import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../unified_date_picker_sheet.dart';
import 'app_input_controller.dart';
import 'unified_base_text_field.dart';
import 'unified_input_brightness.dart';
import 'unified_input_decoration.dart';

/// Formats [dt] for display inside a [UnifiedDateField].
///
/// [valueFormat] may be a [DateFormat]; if null, a sensible default is picked
/// based on [granularity].
String formatUnifiedDateFieldText(
  DateTime? dt,
  Object? valueFormat, {
  UnifiedFieldsDatePickerGranularity granularity = UnifiedFieldsDatePickerGranularity.day,
}) {
  if (dt == null) return '';
  if (valueFormat is DateFormat) return valueFormat.format(dt);
  if (granularity == UnifiedFieldsDatePickerGranularity.year) {
    return DateFormat('yyyy').format(dt);
  }
  if (granularity == UnifiedFieldsDatePickerGranularity.month) {
    return DateFormat('MMM yyyy').format(dt);
  }
  return DateFormat('dd,MMM yyyy').format(dt);
}

/// Formats a [DateTimeRange] as `dd,MMM yyyy – dd,MMM yyyy`.
String formatUnifiedDateRangeFieldText(DateTimeRange? r) {
  if (r == null) return '';
  final f = DateFormat('dd,MMM yyyy');
  return '${f.format(r.start)} – ${f.format(r.end)}';
}

/// Single date using [UnifiedBaseTextField] + [showUnifiedFieldsDatePicker] (no legacy `App*` wrapper).
class UnifiedDateField extends StatefulWidget {
  /// Creates a single-date field.
  const UnifiedDateField({
    super.key,
    this.decoration,
    this.brightness,
    this.binding,
    this.value,
    this.controller,
    this.focusNode,
    this.validator,
    this.onChanged,
    this.onSubmit,
    this.min,
    this.max,
    this.valueFormat,
    this.mode = DatePickerEntryMode.calendar,
    this.suffixIcon,
    this.prefix,
    this.prefixIcon,
    this.label,
    this.placeholder,
    this.isRequired = false,
    this.isDisabled = false,
    this.locked = false,
    this.showClearButton = false,
    this.readOnly = true,
    this.autofocus = false,
    this.textAlign = TextAlign.start,
    this.showCalendarKindToggle = true,
    this.pickerGranularity = UnifiedFieldsDatePickerGranularity.day,
  });

  /// Visual chrome.
  final UnifiedInputDecoration? decoration;

  /// Override [Theme] brightness for the unified palette.
  final UnifiedInputBrightness? brightness;

  /// Optional external state binding.
  final AppInputController<DateTime>? binding;

  /// Direct value when not using [binding].
  final DateTime? value;

  /// External [TextEditingController] for the displayed text.
  final TextEditingController? controller;

  /// Optional focus node.
  final FocusNode? focusNode;

  /// Synchronous validator on the displayed text.
  final String? Function(String value)? validator;

  /// Called when the user picks a date.
  final ValueChanged<DateTime?>? onChanged;

  /// Forwarded to the inner text field's submit.
  final ValueChanged<String>? onSubmit;

  /// Earliest allowed date.
  final DateTime? min;

  /// Latest allowed date.
  final DateTime? max;

  /// Either a [DateFormat] or a custom format object used to render the field.
  final Object? valueFormat;

  /// Forwarded to the picker (calendar vs input).
  final DatePickerEntryMode mode;

  /// Trailing widget; defaults to a fixed-size placeholder so the field height stays stable.
  final Widget? suffixIcon;

  /// Leading widget shown before the field content.
  final Widget? prefix;

  /// Leading icon shown before the field content.
  final Widget? prefixIcon;

  /// Field label. Overrides [UnifiedInputDecoration.label] when set.
  final String? label;

  /// Hint text shown when empty. Overrides [UnifiedInputDecoration.placeholder] when set.
  final String? placeholder;

  /// Whether the field is required. Overrides [UnifiedInputDecoration.requiredField] when set.
  final bool isRequired;

  /// When true, greys out the label and shows a forbid suffix icon.
  final bool isDisabled;

  /// When true, greys out the field and shows a lock suffix icon.
  final bool locked;

  /// Whether to show the inline clear button when there is a value.
  final bool showClearButton;

  /// Whether the inner text field is read-only (the date is picked from the sheet).
  final bool readOnly;

  /// Autofocus the inner text field.
  final bool autofocus;

  /// Text alignment.
  final TextAlign textAlign;

  /// When false, the picker sheet hides the Gregorian / Shamsi switch.
  final bool showCalendarKindToggle;

  /// Precision for [showUnifiedFieldsDatePicker] (single-date field only).
  final UnifiedFieldsDatePickerGranularity pickerGranularity;

  @override
  State<UnifiedDateField> createState() => _UnifiedDateFieldState();
}

class _UnifiedDateFieldState extends State<UnifiedDateField> {
  TextEditingController? _ownedController;

  TextEditingController get _effectiveController => widget.controller ?? _ownedController!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _ownedController = TextEditingController();
    }
    _syncTextFromValue();
    widget.binding?.addListener(_onBinding);
  }

  @override
  void didUpdateWidget(covariant UnifiedDateField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (oldWidget.controller == null) {
        _ownedController?.dispose();
        _ownedController = null;
      }
      if (widget.controller == null && _ownedController == null) {
        _ownedController = TextEditingController();
      }
    }
    if (oldWidget.binding != widget.binding) {
      oldWidget.binding?.removeListener(_onBinding);
      widget.binding?.addListener(_onBinding);
    }
    if (oldWidget.value != widget.value || oldWidget.binding?.value != widget.binding?.value) {
      _syncTextFromValue();
    }
  }

  void _onBinding() => setState(_syncTextFromValue);

  void _syncTextFromValue() {
    final dt = widget.binding?.value ?? widget.value;
    _effectiveController.text = formatUnifiedDateFieldText(dt, widget.valueFormat, granularity: widget.pickerGranularity);
  }

  @override
  void dispose() {
    widget.binding?.removeListener(_onBinding);
    _ownedController?.dispose();
    super.dispose();
  }

  Future<void> _pick(BuildContext context, UnifiedInputDecoration d) async {
    if (widget.isDisabled || widget.locked) return;
    final effectiveValue = widget.binding?.value ?? widget.value;
    final titleRaw = ((d.label ?? '').trim().isEmpty) ? (d.placeholder ?? d.label) : d.label;
    final title = titleRaw ?? '';

    final picked = await showUnifiedFieldsDatePicker(
      context: context,
      initialDate: effectiveValue ?? DateTime.now(),
      firstDate: widget.min ?? DateTime(1900),
      lastDate: widget.max ?? DateTime(3000),
      title: title,
      showCalendarKindToggle: widget.showCalendarKindToggle,
      granularity: widget.pickerGranularity,
    );
    if (!context.mounted || picked == null) return;

    widget.onChanged?.call(picked);
    final b = widget.binding;
    if (b != null && b.value != picked) {
      b.value = picked;
    }
    _effectiveController.text = formatUnifiedDateFieldText(picked, widget.valueFormat, granularity: widget.pickerGranularity);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final d = resolveUnifiedDecoration(context, overrides: widget.decoration, brightness: widget.brightness);
    final bg = d.backgroundColor ?? Colors.black26;
    final headerBg = d.headerBackgroundColor ?? d.backgroundColor ?? Colors.black26;

    return GestureDetector(
      onTap: widget.isDisabled || widget.locked ? null : () => _pick(context, d),
      child: UnifiedBaseTextField(
        focusNode: widget.focusNode,
        controller: _effectiveController,
        label:widget.label?? d.label,
        placeholder: widget.placeholder ?? d.placeholder ?? d.label,
        style: d.fieldStyle ?? const TextStyle(fontSize: 14),
        backgroundColor: bg,
        headerBackgroundColor: headerBg,
        borderRadius: d.borderRadius ?? const BorderRadius.all(Radius.circular(16)),
        borderSide: d.borderSide ?? BorderSide.none,
        height: d.height ?? 56,
        rowLabelRatio: d.rowLabelRatio,
        labelInRow: false,
        requiredField: widget.isRequired || d.requiredField,
        showError: true,
        validationColor: d.validationColor,
        validationIcon: d.validationIcon,
        prefix: widget.prefix ?? d.prefix,
        prefixIcon: widget.prefixIcon ?? d.prefixIcon,
        suffixIcon: widget.isDisabled || widget.locked
            ? null
            : (widget.suffixIcon ?? d.suffixIcon ?? const SizedBox(height: 22)),
        validator: widget.validator,
        isDisabled: widget.isDisabled,
        locked: widget.locked,
        readOnly: true,
        textAlign: widget.textAlign,
        autofocus: widget.autofocus,
        onSubmit: widget.onSubmit,
      ),
    );
  }
}

/// Date range using [UnifiedBaseTextField] + [showUnifiedFieldsDatePickerRange].
class UnifiedDateRangeField extends StatefulWidget {
  /// Creates a date-range field.
  const UnifiedDateRangeField({
    super.key,
    this.decoration,
    this.brightness,
    this.binding,
    this.rangeValue,
    this.controller,
    this.validator,
    this.onRangeChanged,
    this.min,
    this.max,
    this.showCalendarKindToggle = true,
    this.textAlign = TextAlign.start,
    this.label,
    this.placeholder,
    this.isRequired = false,
    this.isDisabled = false,
    this.locked = false,
  });

  /// Visual chrome.
  final UnifiedInputDecoration? decoration;

  /// Override [Theme] brightness for the unified palette.
  final UnifiedInputBrightness? brightness;

  /// Optional external state binding.
  final AppInputController<DateTimeRange>? binding;

  /// Direct value when not using [binding].
  final DateTimeRange? rangeValue;

  /// External [TextEditingController] for the displayed text.
  final TextEditingController? controller;

  /// Synchronous validator on the displayed text.
  final String? Function(String value)? validator;

  /// Called when the user picks a range.
  final ValueChanged<DateTimeRange?>? onRangeChanged;

  /// Earliest allowed date.
  final DateTime? min;

  /// Latest allowed date.
  final DateTime? max;

  /// When false, the picker sheet hides the Gregorian / Shamsi switch.
  final bool showCalendarKindToggle;

  /// Text alignment.
  final TextAlign textAlign;

  /// Field label. Overrides [UnifiedInputDecoration.label] when set.
  final String? label;

  /// Hint text shown when empty. Overrides [UnifiedInputDecoration.placeholder] when set.
  final String? placeholder;

  /// Whether the field is required. Overrides [UnifiedInputDecoration.requiredField] when set.
  final bool isRequired;

  /// When true, greys out the label and shows a forbid suffix icon.
  final bool isDisabled;

  /// When true, greys out the field and shows a lock suffix icon.
  final bool locked;

  @override
  State<UnifiedDateRangeField> createState() => _UnifiedDateRangeFieldState();
}

class _UnifiedDateRangeFieldState extends State<UnifiedDateRangeField> {
  TextEditingController? _ownedController;

  TextEditingController get _effectiveController => widget.controller ?? _ownedController!;

  @override
  void initState() {
    super.initState();
    final initialText = formatUnifiedDateRangeFieldText(widget.binding?.value ?? widget.rangeValue);
    if (widget.controller == null) {
      _ownedController = TextEditingController(text: initialText);
    } else {
      widget.controller!.text = initialText;
    }
    widget.binding?.addListener(_onBinding);
  }

  @override
  void didUpdateWidget(covariant UnifiedDateRangeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (oldWidget.controller == null) {
        _ownedController?.dispose();
        _ownedController = null;
      }
      if (widget.controller == null && _ownedController == null) {
        _ownedController = TextEditingController(text: formatUnifiedDateRangeFieldText(widget.binding?.value ?? widget.rangeValue));
      }
    }
    if (oldWidget.binding != widget.binding) {
      oldWidget.binding?.removeListener(_onBinding);
      widget.binding?.addListener(_onBinding);
    }
    if (oldWidget.rangeValue != widget.rangeValue || oldWidget.binding?.value != widget.binding?.value) {
      _effectiveController.text = formatUnifiedDateRangeFieldText(widget.binding?.value ?? widget.rangeValue);
    }
  }

  void _onBinding() => setState(() {
        _effectiveController.text = formatUnifiedDateRangeFieldText(widget.binding?.value ?? widget.rangeValue);
      });

  @override
  void dispose() {
    widget.binding?.removeListener(_onBinding);
    _ownedController?.dispose();
    super.dispose();
  }

  Future<void> _pick(BuildContext context, UnifiedInputDecoration d) async {
    if (widget.isDisabled || widget.locked) return;
    final effective = widget.binding?.value ?? widget.rangeValue;
    final titleRaw = ((d.label ?? '').trim().isEmpty) ? (d.placeholder ?? d.label) : d.label;
    final title = titleRaw ?? '';

    final picked = await showUnifiedFieldsDatePickerRange(
      context: context,
      initialRange: effective,
      firstDate: widget.min ?? DateTime(1900),
      lastDate: widget.max ?? DateTime(3000),
      title: title,
      showCalendarKindToggle: widget.showCalendarKindToggle,
    );
    if (!context.mounted || picked == null) return;

    widget.onRangeChanged?.call(picked);
    final b = widget.binding;
    if (b != null && b.value != picked) {
      b.value = picked;
    }
    _effectiveController.text = formatUnifiedDateRangeFieldText(picked);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final d = resolveUnifiedDecoration(context, overrides: widget.decoration, brightness: widget.brightness);
    final bg = d.backgroundColor ?? Colors.black26;
    final headerBg = d.headerBackgroundColor ?? d.backgroundColor ?? Colors.black26;

    return GestureDetector(
      onTap: widget.isDisabled || widget.locked ? null : () => _pick(context, d),
      child: UnifiedBaseTextField(
        controller: _effectiveController,
        label: widget.label ?? d.label,
        placeholder: widget.placeholder ?? d.placeholder ?? d.label,
        style: d.fieldStyle ?? const TextStyle(fontSize: 14),
        backgroundColor: bg,
        headerBackgroundColor: headerBg,
        borderRadius: d.borderRadius ?? const BorderRadius.all(Radius.circular(16)),
        borderSide: d.borderSide ?? BorderSide.none,
        height: d.height ?? 56,
        rowLabelRatio: d.rowLabelRatio,
        labelInRow: false,
        requiredField: widget.isRequired || d.requiredField,
        showError: true,
        validationColor: d.validationColor,
        validationIcon: d.validationIcon,
        suffixIcon: widget.isDisabled || widget.locked ? null : const SizedBox(height: 22),
        validator: widget.validator,
        isDisabled: widget.isDisabled,
        locked: widget.locked,
        readOnly: true,
        textAlign: widget.textAlign,
      ),
    );
  }
}
