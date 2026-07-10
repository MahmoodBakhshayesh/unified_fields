import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../unified_date_picker_sheet.dart';
import '../unified_fields_picker_theme.dart';
import '../unified_fields_styled_calendar_picker.dart';
import '../unified_fields_date_format_style.dart';
import '../unified_fields_typography.dart';
import '../controllers/field_controller_sync.dart';
import '../controllers/unified_date_field_controller.dart';
import '../controllers/unified_date_range_field_controller.dart';
import 'unified_input_picker.dart';
import 'unified_base_text_field.dart';
import 'unified_input_brightness.dart';
import 'unified_field_decoration_context.dart';
import 'unified_input_decoration.dart';
import 'unified_input_theme.dart';

/// Formats [dt] for display inside a [UnifiedDateField].
///
/// [valueFormat] may be a [DateFormat]; if null, a sensible default is picked
/// based on [granularity].
String formatUnifiedDateFieldText(
  DateTime? dt,
  Object? valueFormat, {
  UnifiedFieldsDatePickerGranularity granularity =
      UnifiedFieldsDatePickerGranularity.day,
  UnifiedFieldsCalendarKind? calendarKind,
  UnifiedFieldsDateFormatStyle? formatStyle,
}) {
  if (dt == null) return '';
  if (valueFormat is DateFormat) {
    final raw = valueFormat.format(dt);
    return UnifiedFieldsTypography.instance.localizeDigits(
      raw,
      calendarKind: calendarKind,
    );
  }
  final kind = calendarKind ?? UnifiedFieldsCalendarKind.gregorian;
  return (formatStyle ?? UnifiedFieldsDateFormatStyle.standard).format(
    dt,
    calendarKind: kind,
    granularity: granularity,
  );
}

/// Formats a [DateTimeRange] as `dd,MMM yyyy – dd,MMM yyyy` (or Shamsi equivalents).
String formatUnifiedDateRangeFieldText(
  DateTimeRange? r, {
  UnifiedFieldsCalendarKind? calendarKind,
  UnifiedFieldsDatePickerGranularity granularity =
      UnifiedFieldsDatePickerGranularity.day,
  UnifiedFieldsDateFormatStyle? formatStyle,
}) {
  if (r == null) return '';
  final kind = calendarKind ?? UnifiedFieldsCalendarKind.gregorian;
  return (formatStyle ?? UnifiedFieldsDateFormatStyle.standard).formatRange(
    r,
    calendarKind: kind,
    granularity: granularity,
  );
}

/// Single date using [UnifiedBaseTextField] + [showUnifiedFieldsDatePicker] (no legacy `App*` wrapper).
class UnifiedDateField extends StatefulWidget {
  /// Creates a single-date field.
  const UnifiedDateField({
    super.key,
    this.decoration,
    this.decorationSet,
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
    this.datePickerStyle,
    this.showWeekdayInWheel = true,
    this.dayInfoBuilder,
    this.pickerTheme,
    this.style,
    this.dateFormatStyle,
  });

  /// Visual chrome.
  final UnifiedInputDecoration? decoration;

  /// Per-state decorations (focus, error, valid, locked, disabled, …).
  final UnifiedInputDecorationSet? decorationSet;

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

  /// Gregorian / Shamsi display patterns; overrides [UnifiedInputThemeData.dateFormatStyle].
  final UnifiedFieldsDateFormatStyle? dateFormatStyle;

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

  /// Picker sheet chrome (calendar days, sheet background, header, toggles, buttons).
  ///
  /// Merged with [UnifiedInputThemeData.datePickerStyle]. [wheelStyle] on this object
  /// is combined with [wheelStyle] on the field.
  final UnifiedInputDatePickerStyle? datePickerStyle;

  /// When [pickerStyle] is wheels, show weekday names in the day column.
  final bool showWeekdayInWheel;

  /// Per-day price / event decorations for styled pickers
  /// ([pickerStyle] [UnifiedFieldsDatePickerStyle.isStyledPicker]).
  final UnifiedFieldsCalendarDayInfoBuilder? dayInfoBuilder;

  /// Extra styling for styled pickers; merged with [datePickerStyle] and theme.
  final UnifiedFieldsPickerTheme? pickerTheme;

  /// Value text style; overrides theme [UnifiedInputFieldDefaults.textStyle] when set.
  final TextStyle? style;

  @override
  State<UnifiedDateField> createState() => _UnifiedDateFieldState();
}

class _UnifiedDateFieldState extends State<UnifiedDateField> {
  TextEditingController? _ownedController;
  late UnifiedFieldsCalendarKind _calendarKind;
  UnifiedFieldsDateFormatStyle? _cachedDateFormatStyle;

  TextEditingController get _effectiveController =>
      widget.controller ?? _ownedController!;

  UnifiedFieldsCalendarKind get _effectiveCalendarKind =>
      widget.fieldController?.calendarKind ?? _calendarKind;

  UnifiedFieldsDateFormatStyle? get _fieldDateFormatStyle =>
      widget.dateFormatStyle ?? widget.fieldController?.dateFormatStyle;

  UnifiedFieldsDateFormatStyle get _effectiveDateFormatStyle =>
      _cachedDateFormatStyle ??
      resolveUnifiedDateFormatStyle(field: _fieldDateFormatStyle);

  void _updateCachedDateFormatStyle() {
    _cachedDateFormatStyle = UnifiedInputThemeResolver.dateFormatStyle(
      context,
      field: _fieldDateFormatStyle,
    );
  }

  String _sheetTitle(UnifiedInputDecoration d) {
    final titleRaw = ((d.label ?? '').trim().isEmpty)
        ? (d.placeholder ?? d.label)
        : d.label;
    return titleRaw ?? '';
  }

  void _syncFieldController(UnifiedInputDecoration d) {
    final fc = widget.fieldController;
    fc?.bindPickerTitle(_sheetTitle(d));
    syncDisplayStringValidatorToFieldController<DateTime>(
      fieldController: fc,
      widgetValidator: widget.validator,
      displayFor: (dt) => formatUnifiedDateFieldText(
        dt,
        widget.valueFormat,
        granularity: widget.pickerGranularity,
        calendarKind: _effectiveCalendarKind,
        formatStyle: _effectiveDateFormatStyle,
      ),
    );
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
      formatStyle: _effectiveDateFormatStyle,
    );
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _calendarKind =
        widget.fieldController?.calendarKind ?? widget.initialCalendarKind;
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
    final previousStyle = _cachedDateFormatStyle;
    _updateCachedDateFormatStyle();
    final d = resolveUnifiedDecoration(
      context,
      overrides: widget.decoration,
      brightness: widget.brightness,
    );
    _syncFieldController(d);
    if (previousStyle != _cachedDateFormatStyle) {
      _syncTextFromValue();
    }
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
    if (oldWidget.binding != widget.binding ||
        oldWidget.fieldController != widget.fieldController) {
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
    if (oldWidget.validator != widget.validator ||
        oldWidget.valueFormat != widget.valueFormat ||
        oldWidget.dateFormatStyle != widget.dateFormatStyle ||
        oldWidget.pickerGranularity != widget.pickerGranularity ||
        oldWidget.fieldController?.dateFormatStyle !=
            widget.fieldController?.dateFormatStyle) {
      _updateCachedDateFormatStyle();
      final d = resolveUnifiedDecoration(
        context,
        overrides: widget.decoration,
        brightness: widget.brightness,
      );
      _syncFieldController(d);
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

  DateTime? get _effectiveValue =>
      widget.fieldController?.value ?? widget.binding?.value ?? widget.value;

  void _syncTextFromValue() {
    final dt = _effectiveValue;
    _effectiveController.text = formatUnifiedDateFieldText(
      dt,
      widget.valueFormat,
      granularity: widget.pickerGranularity,
      calendarKind: _effectiveCalendarKind,
      formatStyle: _effectiveDateFormatStyle,
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
          formatStyle: _effectiveDateFormatStyle,
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
      datePickerStyle: fc?.datePickerStyle ?? widget.datePickerStyle,
      showWeekdayInWheel: fc?.showWeekdayInWheel ?? widget.showWeekdayInWheel,
      dayInfoBuilder: fc?.dayInfoBuilder ?? widget.dayInfoBuilder,
      pickerTheme: fc?.pickerTheme ?? widget.pickerTheme,
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
    final chrome = resolveUnifiedFieldDecorationContext(
      context,
      decoration: widget.decoration,
      decorationSet: widget.decorationSet,
      brightness: widget.brightness,
    );
    final d = chrome.resolved;
    final bg = d.backgroundColor ?? Colors.black26;
    final headerBg =
        d.headerBackgroundColor ?? d.backgroundColor ?? Colors.black26;

    return GestureDetector(
      onTap: widget.isDisabled || widget.locked
          ? null
          : () => _pick(context, d),
      child: UnifiedBaseTextField(
        decorationSet: chrome.activeSet,
        brightness: widget.brightness,
        focusNode: unifiedEffectiveFocusNode(
          fieldController: widget.fieldController,
          binding: widget.binding,
          direct: widget.focusNode,
        ),
        controller: _effectiveController,
        errorText: widget.fieldController?.errorText,
        label: widget.label ?? d.label,
        placeholder: widget.placeholder ?? d.placeholder,
        placeholderStyle: d.placeholderStyle,
        style: widget.style ?? d.fieldStyle,
        digitCalendarKind: _effectiveCalendarKind,
        backgroundColor: bg,
        headerBackgroundColor: headerBg,
        borderRadius:
            d.borderRadius ?? const BorderRadius.all(Radius.circular(16)),
        borderSide: d.borderSide ?? BorderSide.none,
        height: d.height,
        rowLabelRatio: d.optionalRowLabelRatio,
        labelMode: d.labelMode,
        requiredField: widget.isRequired || d.requiredField,
        showError: true,
        validationColor: d.validationColor,
        validationIcon: d.validationIcon,
        prefix: widget.prefix ?? d.prefix,
        prefixIcon: widget.prefixIcon ?? d.prefixIcon,
        suffixIcon: widget.isDisabled || widget.locked
            ? null
            : (widget.suffixIcon ??
                  d.suffixIcon ??
                  UnifiedInputThemeResolver.defaultSuffixIcon(
                    context,
                    UnifiedInputFieldSuffixKind.date,
                    UnifiedInputThemeResolver.resolvePalette(context),
                  )),
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
    this.decorationSet,
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
    this.style,
    this.datePickerStyle,
    this.pickerStyle = UnifiedFieldsDatePickerStyle.verticalMonths,
    this.dayInfoBuilder,
    this.pickerTheme,
    this.initialCalendarKind = UnifiedFieldsCalendarKind.gregorian,
    this.dateFormatStyle,
  });

  /// Visual chrome.
  final UnifiedInputDecoration? decoration;

  /// Per-state decorations (focus, error, valid, locked, disabled, …).
  final UnifiedInputDecorationSet? decorationSet;

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

  /// Value text style; overrides theme [UnifiedInputFieldDefaults.textStyle] when set.
  final TextStyle? style;

  /// Picker sheet chrome; merged with [UnifiedInputThemeData.datePickerStyle].
  final UnifiedInputDatePickerStyle? datePickerStyle;

  /// Styled range picker layout (defaults to [verticalMonths]).
  final UnifiedFieldsDatePickerStyle pickerStyle;

  /// Per-day decorations for styled range pickers.
  final UnifiedFieldsCalendarDayInfoBuilder? dayInfoBuilder;

  /// Extra styling for styled range pickers.
  final UnifiedFieldsPickerTheme? pickerTheme;

  /// Calendar kind for digit localization and Persian [textStylePersian].
  final UnifiedFieldsCalendarKind initialCalendarKind;

  /// Gregorian / Shamsi display patterns; overrides [UnifiedInputThemeData.dateFormatStyle].
  final UnifiedFieldsDateFormatStyle? dateFormatStyle;

  @override
  State<UnifiedDateRangeField> createState() => _UnifiedDateRangeFieldState();
}

class _UnifiedDateRangeFieldState extends State<UnifiedDateRangeField> {
  TextEditingController? _ownedController;
  UnifiedFieldsDateFormatStyle? _cachedDateFormatStyle;

  TextEditingController get _effectiveController =>
      widget.controller ?? _ownedController!;

  UnifiedFieldsDateFormatStyle? get _fieldDateFormatStyle =>
      widget.dateFormatStyle ?? widget.fieldController?.dateFormatStyle;

  UnifiedFieldsDateFormatStyle get _effectiveDateFormatStyle =>
      _cachedDateFormatStyle ??
      resolveUnifiedDateFormatStyle(field: _fieldDateFormatStyle);

  void _updateCachedDateFormatStyle() {
    _cachedDateFormatStyle = UnifiedInputThemeResolver.dateFormatStyle(
      context,
      field: _fieldDateFormatStyle,
    );
  }

  UnifiedFieldsCalendarKind get _effectiveCalendarKind =>
      widget.fieldController?.calendarKind ?? widget.initialCalendarKind;

  String _formatRange(DateTimeRange? range) => formatUnifiedDateRangeFieldText(
        range,
        calendarKind: _effectiveCalendarKind,
        formatStyle: _effectiveDateFormatStyle,
      );

  void _syncFieldControllerValidator() {
    syncDisplayStringValidatorToFieldController<DateTimeRange>(
      fieldController: widget.fieldController,
      widgetValidator: widget.validator,
      displayFor: (r) => _formatRange(r),
    );
  }

  @override
  void initState() {
    super.initState();
    final initialText = _formatRange(_effectiveValue);
    if (widget.controller == null) {
      _ownedController = TextEditingController(text: initialText);
    } else {
      widget.controller!.text = initialText;
    }
    _syncFieldControllerValidator();
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
        _ownedController = TextEditingController(text: _formatRange(_effectiveValue));
      }
    }
    if (oldWidget.binding != widget.binding ||
        oldWidget.fieldController != widget.fieldController) {
      oldWidget.binding?.removeListener(_onBinding);
      oldWidget.fieldController?.removeListener(_onBinding);
      widget.binding?.addListener(_onBinding);
      widget.fieldController?.addListener(_onBinding);
    }
    if (oldWidget.rangeValue != widget.rangeValue ||
        oldWidget.binding?.value != widget.binding?.value ||
        oldWidget.fieldController?.value != widget.fieldController?.value) {
      _effectiveController.text = _formatRange(_effectiveValue);
    }
    if (oldWidget.validator != widget.validator ||
        oldWidget.dateFormatStyle != widget.dateFormatStyle ||
        oldWidget.initialCalendarKind != widget.initialCalendarKind ||
        oldWidget.fieldController != widget.fieldController ||
        oldWidget.fieldController?.dateFormatStyle !=
            widget.fieldController?.dateFormatStyle) {
      _updateCachedDateFormatStyle();
      _syncFieldControllerValidator();
      _effectiveController.text = _formatRange(_effectiveValue);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final previousStyle = _cachedDateFormatStyle;
    _updateCachedDateFormatStyle();
    _syncFieldControllerValidator();
    if (previousStyle != _cachedDateFormatStyle) {
      _effectiveController.text = _formatRange(_effectiveValue);
    }
  }

  DateTimeRange? get _effectiveValue => unifiedEffectiveValue(
    fieldController: widget.fieldController,
    binding: widget.binding,
    direct: widget.rangeValue,
  );

  void _onBinding() => setState(() {
        _effectiveController.text = _formatRange(_effectiveValue);
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
    final titleRaw = ((d.label ?? '').trim().isEmpty)
        ? (d.placeholder ?? d.label)
        : d.label;
    final title = titleRaw ?? '';

    final fc = widget.fieldController;
    final DateTimeRange? picked;
    if (fc != null) {
      picked = await fc.openPicker(
        context,
        title: title,
        initialRange: _effectiveValue,
      );
    } else {
      picked = await showUnifiedFieldsDatePickerRange(
        context: context,
        initialRange: _effectiveValue,
        firstDate: widget.min ?? DateTime(1900),
        lastDate: widget.max ?? DateTime(3000),
        title: title,
        showCalendarKindToggle: widget.showCalendarKindToggle,
        pickerStyle: widget.pickerStyle,
        datePickerStyle: widget.datePickerStyle,
        dayInfoBuilder: widget.dayInfoBuilder,
        pickerTheme: widget.pickerTheme,
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
    _effectiveController.text = _formatRange(picked);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final chrome = resolveUnifiedFieldDecorationContext(
      context,
      decoration: widget.decoration,
      decorationSet: widget.decorationSet,
      brightness: widget.brightness,
    );
    final d = chrome.resolved;
    final bg = d.backgroundColor ?? Colors.black26;
    final headerBg =
        d.headerBackgroundColor ?? d.backgroundColor ?? Colors.black26;

    return GestureDetector(
      onTap: widget.isDisabled || widget.locked
          ? null
          : () => _pick(context, d),
      child: UnifiedBaseTextField(
        decorationSet: chrome.activeSet,
        brightness: widget.brightness,
        controller: _effectiveController,
        focusNode: widget.fieldController?.focusNode,
        errorText: widget.fieldController?.errorText,
        label: widget.label ?? d.label,
        placeholder: widget.placeholder ?? d.placeholder,
        placeholderStyle: d.placeholderStyle,
        style: widget.style ?? d.fieldStyle,
        digitCalendarKind: widget.initialCalendarKind,
        backgroundColor: bg,
        headerBackgroundColor: headerBg,
        borderRadius:
            d.borderRadius ?? const BorderRadius.all(Radius.circular(16)),
        borderSide: d.borderSide ?? BorderSide.none,
        height: d.height,
        rowLabelRatio: d.optionalRowLabelRatio,
        labelMode: d.labelMode,
        requiredField: widget.isRequired || d.requiredField,
        showError: true,
        validationColor: d.validationColor,
        validationIcon: d.validationIcon,
        suffixIcon: widget.isDisabled || widget.locked
            ? null
            : (d.suffixIcon ??
                  UnifiedInputThemeResolver.defaultSuffixIcon(
                    context,
                    UnifiedInputFieldSuffixKind.date,
                    UnifiedInputThemeResolver.resolvePalette(context),
                  )),
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
