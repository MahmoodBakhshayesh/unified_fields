import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../persian_jalali_calendar.dart';
import '../unified_date_picker_sheet.dart';
import '../unified_fields_typography.dart';
import '../controllers/field_controller_sync.dart';
import '../controllers/unified_date_field_controller.dart';
import '../controllers/unified_date_range_field_controller.dart';
import 'unified_input_picker.dart';
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
  UnifiedFieldsCalendarKind? calendarKind,
}) {
  if (dt == null) return '';
  final String raw;
  if (valueFormat is DateFormat) {
    raw = valueFormat.format(dt);
  } else if (calendarKind == UnifiedFieldsCalendarKind.jalali) {
    raw = PersianJalaliCalendar.formatFieldText(dt, granularity: granularity);
  } else {
    raw = granularity == UnifiedFieldsDatePickerGranularity.year
        ? DateFormat('yyyy').format(dt)
        : granularity == UnifiedFieldsDatePickerGranularity.month
            ? DateFormat('MMM yyyy').format(dt)
            : DateFormat('dd,MMM yyyy').format(dt);
  }
  return UnifiedFieldsTypography.instance.localizeDigits(raw, calendarKind: calendarKind);
}

/// Formats a [DateTimeRange] as `dd,MMM yyyy – dd,MMM yyyy` (or Shamsi equivalents).
String formatUnifiedDateRangeFieldText(
  DateTimeRange? r, {
  UnifiedFieldsCalendarKind? calendarKind,
  UnifiedFieldsDatePickerGranularity granularity = UnifiedFieldsDatePickerGranularity.day,
}) {
  if (r == null) return '';
  final start = formatUnifiedDateFieldText(
    r.start,
    null,
    granularity: granularity,
    calendarKind: calendarKind,
  );
  final end = formatUnifiedDateFieldText(
    r.end,
    null,
    granularity: granularity,
    calendarKind: calendarKind,
  );
  return '$start – $end';
}

/// Single date using [UnifiedBaseTextField] + [showUnifiedFieldsDatePicker] (no legacy `App*` wrapper).
class UnifiedDateField extends StatefulWidget {
  /// Creates a single-date field.
  const UnifiedDateField({
    super.key,
    this.decoration,
    this.brightness,
    this.binding,
    this.fieldController,
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
    this.pickerStyle = UnifiedFieldsDatePickerStyle.calendar,
    this.initialCalendarKind = UnifiedFieldsCalendarKind.gregorian,
    this.wheelStyle,
    this.showWeekdayInWheel = true,
  });

  /// Visual chrome.
  final UnifiedInputDecoration? decoration;

  /// Override [Theme] brightness for the unified palette.
  final UnifiedInputBrightness? brightness;

  /// Optional external state binding.
  final UnifiedInputPicker<DateTime>? binding;

  /// Preferred imperative handle (value, validate, [UnifiedDateFieldController.openPicker]).
  final UnifiedDateFieldController? fieldController;

  /// Direct value when not using [binding] or [fieldController].
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

  /// [UnifiedFieldsDatePickerStyle.calendar] grid vs [UnifiedFieldsDatePickerStyle.wheels] scrollers.
  final UnifiedFieldsDatePickerStyle pickerStyle;

  /// Starting calendar when the picker opens (Gregorian / Shamsi).
  final UnifiedFieldsCalendarKind initialCalendarKind;

  /// Optional wheel chrome when [pickerStyle] is [UnifiedFieldsDatePickerStyle.wheels].
  final UnifiedFieldsDateWheelStyle? wheelStyle;

  /// When [pickerStyle] is wheels, show weekday names in the day column.
  final bool showWeekdayInWheel;

  @override
  State<UnifiedDateField> createState() => _UnifiedDateFieldState();
}

class _UnifiedDateFieldState extends State<UnifiedDateField> {
  TextEditingController? _ownedController;
  late UnifiedFieldsCalendarKind _calendarKind;

  TextEditingController get _effectiveController => widget.controller ?? _ownedController!;

  UnifiedFieldsCalendarKind get _effectiveCalendarKind =>
      widget.fieldController?.calendarKind ?? _calendarKind;

  String _sheetTitle(UnifiedInputDecoration d) {
    final titleRaw = ((d.label ?? '').trim().isEmpty) ? (d.placeholder ?? d.label) : d.label;
    return titleRaw ?? '';
  }

  void _syncFieldController(UnifiedInputDecoration d) {
    final fc = widget.fieldController;
    fc?.bindPickerTitle(_sheetTitle(d));
    attachUnifiedFieldHandles(
      opener: (context) => _pickBody(context, d),
      focusNode: unifiedEffectiveFocusNode(
        fieldController: widget.fieldController,
        binding: widget.binding,
        direct: widget.focusNode,
      ),
      binding: widget.binding,
      fieldController: widget.fieldController,
    );
  }

  void _applyPicked(DateTime? picked) {
    if (picked == null) {
      widget.onChanged?.call(null);
      widget.binding?.value = null;
      widget.fieldController?.value = null;
      _effectiveController.text = '';
      setState(() {});
      return;
    }
    widget.onChanged?.call(picked);
    final b = widget.binding;
    if (b != null && b.value != picked) {
      b.value = picked;
    }
    final fc = widget.fieldController;
    if (fc != null && fc.value != picked) {
      fc.value = picked;
    }
    _effectiveController.text = formatUnifiedDateFieldText(
      picked,
      widget.valueFormat,
      granularity: widget.pickerGranularity,
      calendarKind: _effectiveCalendarKind,
    );
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _calendarKind = widget.fieldController?.calendarKind ?? widget.initialCalendarKind;
    if (widget.controller == null) {
      _ownedController = TextEditingController();
    }
    _syncTextFromValue();
    widget.binding?.addListener(_onBinding);
    widget.fieldController?.addListener(_onBinding);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final d = resolveUnifiedDecoration(context, overrides: widget.decoration, brightness: widget.brightness);
    _syncFieldController(d);
  }

  @override
  void didUpdateWidget(covariant UnifiedDateField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fieldController != widget.fieldController ||
        oldWidget.binding != widget.binding) {
      detachUnifiedFieldHandles(
        binding: oldWidget.binding,
        fieldController: oldWidget.fieldController,
      );
    }
    if (oldWidget.controller != widget.controller) {
      if (oldWidget.controller == null) {
        _ownedController?.dispose();
        _ownedController = null;
      }
      if (widget.controller == null && _ownedController == null) {
        _ownedController = TextEditingController();
      }
    }
    if (oldWidget.binding != widget.binding || oldWidget.fieldController != widget.fieldController) {
      oldWidget.binding?.removeListener(_onBinding);
      oldWidget.fieldController?.removeListener(_onBinding);
      widget.binding?.addListener(_onBinding);
      widget.fieldController?.addListener(_onBinding);
    }
    if (oldWidget.initialCalendarKind != widget.initialCalendarKind &&
        widget.fieldController == null) {
      _calendarKind = widget.initialCalendarKind;
    }
    if (oldWidget.value != widget.value ||
        oldWidget.binding?.value != widget.binding?.value ||
        oldWidget.fieldController?.value != widget.fieldController?.value ||
        oldWidget.initialCalendarKind != widget.initialCalendarKind) {
      _syncTextFromValue();
    }
  }

  void _onBinding() {
    final fc = widget.fieldController;
    if (fc != null) {
      final picked = fc.value;
      widget.onChanged?.call(picked);
      final b = widget.binding;
      if (b != null && b.value != picked) {
        b.value = picked;
      }
    }
    setState(_syncTextFromValue);
  }

  DateTime? get _effectiveValue => widget.fieldController?.value ?? widget.binding?.value ?? widget.value;

  void _syncTextFromValue() {
    final dt = _effectiveValue;
    _effectiveController.text = formatUnifiedDateFieldText(
      dt,
      widget.valueFormat,
      granularity: widget.pickerGranularity,
      calendarKind: _effectiveCalendarKind,
    );
  }

  void _onPickerConfirmedCalendarKind(UnifiedFieldsCalendarKind kind) {
    final fc = widget.fieldController;
    if (fc != null) {
      fc.calendarKind = kind;
      return;
    }
    if (_calendarKind == kind) return;
    setState(() {
      _calendarKind = kind;
      final dt = _effectiveValue;
      if (dt != null) {
        _effectiveController.text = formatUnifiedDateFieldText(
          dt,
          widget.valueFormat,
          granularity: widget.pickerGranularity,
          calendarKind: kind,
        );
      }
    });
  }

  @override
  void dispose() {
    detachUnifiedFieldHandles(
      binding: widget.binding,
      fieldController: widget.fieldController,
    );
    widget.binding?.removeListener(_onBinding);
    widget.fieldController?.removeListener(_onBinding);
    _ownedController?.dispose();
    super.dispose();
  }

  Future<void> _pickBody(BuildContext context, UnifiedInputDecoration d) async {
    final fc = widget.fieldController;
    final picked = await showUnifiedFieldsDatePicker(
      context: context,
      initialDate: _effectiveValue ?? DateTime.now(),
      firstDate: widget.min ?? DateTime(1900),
      lastDate: widget.max ?? DateTime(3000),
      title: _sheetTitle(d),
      showCalendarKindToggle: widget.showCalendarKindToggle,
      granularity: widget.pickerGranularity,
      pickerStyle: fc?.pickerStyle ?? widget.pickerStyle,
      initialCalendarKind: _effectiveCalendarKind,
      wheelStyle: fc?.wheelStyle ?? widget.wheelStyle,
      showWeekdayInWheel: fc?.showWeekdayInWheel ?? widget.showWeekdayInWheel,
      onConfirmedCalendarKind: _onPickerConfirmedCalendarKind,
    );
    if (!context.mounted) return;
    _applyPicked(picked);
  }

  Future<void> _pick(BuildContext context, UnifiedInputDecoration d) async {
    if (widget.isDisabled || widget.locked) return;
    await _pickBody(context, d);
  }

  @override
  Widget build(BuildContext context) {
    final d = resolveUnifiedDecoration(context, overrides: widget.decoration, brightness: widget.brightness);
    final bg = d.backgroundColor ?? Colors.black26;
    final headerBg = d.headerBackgroundColor ?? d.backgroundColor ?? Colors.black26;

    return GestureDetector(
      onTap: widget.isDisabled || widget.locked ? null : () => _pick(context, d),
      child: UnifiedBaseTextField(
        focusNode: unifiedEffectiveFocusNode(
          fieldController: widget.fieldController,
          binding: widget.binding,
          direct: widget.focusNode,
        ),
        controller: _effectiveController,
        errorText: widget.fieldController?.errorText,
        label:widget.label?? d.label,
        placeholder: widget.placeholder ?? d.placeholder ?? d.label,
        style: UnifiedFieldsTypography.instance.mergeDigitStyle(
          d.fieldStyle ?? const TextStyle(fontSize: 14),
          calendarKind: _effectiveCalendarKind,
        ),
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
        interactionBlocked: true,
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
    this.fieldController,
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
  final UnifiedInputPicker<DateTimeRange>? binding;

  /// Preferred imperative handle ([UnifiedDateRangeFieldController.openPicker], validate, focus).
  final UnifiedDateRangeFieldController? fieldController;

  /// Direct value when not using [binding] or [fieldController].
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
    final initialText = formatUnifiedDateRangeFieldText(_effectiveValue);
    if (widget.controller == null) {
      _ownedController = TextEditingController(text: initialText);
    } else {
      widget.controller!.text = initialText;
    }
    widget.binding?.addListener(_onBinding);
    widget.fieldController?.addListener(_onBinding);
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
        _ownedController = TextEditingController(text: formatUnifiedDateRangeFieldText(_effectiveValue));
      }
    }
    if (oldWidget.binding != widget.binding || oldWidget.fieldController != widget.fieldController) {
      oldWidget.binding?.removeListener(_onBinding);
      oldWidget.fieldController?.removeListener(_onBinding);
      widget.binding?.addListener(_onBinding);
      widget.fieldController?.addListener(_onBinding);
    }
    if (oldWidget.rangeValue != widget.rangeValue ||
        oldWidget.binding?.value != widget.binding?.value ||
        oldWidget.fieldController?.value != widget.fieldController?.value) {
      _effectiveController.text = formatUnifiedDateRangeFieldText(_effectiveValue);
    }
  }

  DateTimeRange? get _effectiveValue => unifiedEffectiveValue(
        fieldController: widget.fieldController,
        binding: widget.binding,
        direct: widget.rangeValue,
      );

  void _onBinding() => setState(() {
        _effectiveController.text = formatUnifiedDateRangeFieldText(_effectiveValue);
      });

  @override
  void dispose() {
    widget.binding?.removeListener(_onBinding);
    widget.fieldController?.removeListener(_onBinding);
    _ownedController?.dispose();
    super.dispose();
  }

  Future<void> _pick(BuildContext context, UnifiedInputDecoration d) async {
    if (widget.isDisabled || widget.locked) return;
    final titleRaw = ((d.label ?? '').trim().isEmpty) ? (d.placeholder ?? d.label) : d.label;
    final title = titleRaw ?? '';

    final fc = widget.fieldController;
    final DateTimeRange? picked;
    if (fc != null) {
      picked = await fc.openPicker(context, title: title, initialRange: _effectiveValue);
    } else {
      picked = await showUnifiedFieldsDatePickerRange(
        context: context,
        initialRange: _effectiveValue,
        firstDate: widget.min ?? DateTime(1900),
        lastDate: widget.max ?? DateTime(3000),
        title: title,
        showCalendarKindToggle: widget.showCalendarKindToggle,
      );
    }
    if (!context.mounted || picked == null) return;

    widget.onRangeChanged?.call(picked);
    final b = widget.binding;
    if (b != null && b.value != picked) {
      b.value = picked;
    }
    if (fc != null && fc.value != picked) {
      fc.value = picked;
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
        focusNode: widget.fieldController?.focusNode,
        errorText: widget.fieldController?.errorText,
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
        interactionBlocked: true,
        readOnly: true,
        textAlign: widget.textAlign,
      ),
    );
  }
}
