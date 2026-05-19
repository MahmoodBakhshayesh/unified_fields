import 'package:flutter/material.dart';

import '../time_picker_utils.dart';
import '../unified_date_picker_types.dart';
import '../unified_date_wheel_style.dart';
import '../unified_time_format.dart';
import '../unified_time_picker_types.dart';
import 'unified_base_text_field.dart';
import '../controllers/field_controller_sync.dart';
import '../controllers/unified_time_field_controller.dart';
import 'unified_input_picker.dart';
import 'unified_input_brightness.dart';
import 'unified_field_decoration_context.dart';
import 'unified_input_decoration.dart';
import 'unified_input_theme.dart';

/// Time-of-day picker using unified chrome + dial or wheel picker.
class UnifiedTimeOfDayField extends StatefulWidget {
  /// Creates a time-of-day field.
  const UnifiedTimeOfDayField({
    super.key,
    this.decoration,
    this.decorationSet,
    this.brightness,
    this.binding,
    this.fieldController,
    this.value,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.locked = false,
    this.isDisabled = false,
    this.timePickerEntryMode = TimePickerEntryMode.dial,
    this.pickerStyle = UnifiedFieldsTimePickerStyle.dial,
    this.pickerGranularity = UnifiedFieldsTimeGranularity.hoursMinutes,
    this.showCalendarKindToggle = true,
    this.initialCalendarKind = UnifiedFieldsCalendarKind.gregorian,
    this.wheelStyle,
    this.label,
    this.placeholder,
    this.isRequired = false,
  });

  /// Visual chrome.
  final UnifiedInputDecoration? decoration;

  /// Per-state decorations (focus, error, valid, locked, disabled, …).
  final UnifiedInputDecorationSet? decorationSet;

  /// Override [Theme] brightness for the unified palette.
  final UnifiedInputBrightness? brightness;

  /// Optional external state binding.
  final UnifiedInputPicker<TimeOfDay>? binding;

  /// Preferred imperative handle ([UnifiedTimeOfDayFieldController.openPicker], validate, focus).
  final UnifiedTimeOfDayFieldController? fieldController;

  /// Direct value when not using [binding] or [fieldController].
  final TimeOfDay? value;

  /// Synchronous validator on the displayed text.
  final String? Function(String value)? validator;

  /// Called when the user picks a time.
  final ValueChanged<TimeOfDay?>? onChanged;

  /// Forwarded to the inner text field's submit.
  final ValueChanged<String>? onSubmitted;

  /// When true, the field is non-interactive.
  final bool locked;

  /// When true, greys out the label and shows a forbid suffix icon.
  final bool isDisabled;

  /// Forwarded to platform dial [showTimePicker] when [pickerStyle] is [UnifiedFieldsTimePickerStyle.dial].
  final TimePickerEntryMode timePickerEntryMode;

  /// Dial vs unified scroll wheels.
  final UnifiedFieldsTimePickerStyle pickerStyle;

  /// Wheel columns: hour, hour+minute, or hour+minute+second.
  final UnifiedFieldsTimeGranularity pickerGranularity;

  /// When false, hides Gregorian / Shamsi toggle on wheel picker.
  final bool showCalendarKindToggle;

  /// Starting digit / label mode for wheels and field display.
  final UnifiedFieldsCalendarKind initialCalendarKind;

  /// Optional wheel chrome when [pickerStyle] is [UnifiedFieldsTimePickerStyle.wheels].
  final UnifiedFieldsDateWheelStyle? wheelStyle;

  /// Field label. Overrides [UnifiedInputDecoration.label] when set.
  final String? label;

  /// Hint text shown when empty. Overrides [UnifiedInputDecoration.placeholder] when set.
  final String? placeholder;

  /// Whether the field is required. Overrides [UnifiedInputDecoration.requiredField] when set.
  final bool isRequired;

  @override
  State<UnifiedTimeOfDayField> createState() => _UnifiedTimeOfDayFieldState();
}

class _UnifiedTimeOfDayFieldState extends State<UnifiedTimeOfDayField> {
  late final TextEditingController _txt = TextEditingController();
  late UnifiedFieldsCalendarKind _calendarKind;
  int _second = 0;

  UnifiedFieldsCalendarKind get _effectiveCalendarKind =>
      widget.fieldController?.calendarKind ?? _calendarKind;

  UnifiedFieldsTimeGranularity get _granularity =>
      widget.fieldController?.granularity ?? widget.pickerGranularity;

  int get _effectiveSecond => widget.fieldController?.second ?? _second;

  void _syncFieldController(BuildContext context) {
    final d = resolveUnifiedDecoration(
      context,
      overrides: widget.decoration,
      brightness: widget.brightness,
    );
    widget.fieldController?.bindPickerTitle(widget.label ?? d.label ?? '');
    attachUnifiedFieldHandles(
      opener: (context) => _pick(context),
      focusNode: unifiedEffectiveFocusNode(
        fieldController: widget.fieldController,
        binding: widget.binding,
      ),
      binding: widget.binding,
      fieldController: widget.fieldController,
    );
  }

  @override
  void initState() {
    super.initState();
    _calendarKind =
        widget.fieldController?.calendarKind ?? widget.initialCalendarKind;
    _second = widget.fieldController?.second ?? 0;
    _syncText();
    widget.binding?.addListener(_onBinding);
    widget.fieldController?.addListener(_onBinding);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncFieldController(context);
  }

  @override
  void didUpdateWidget(covariant UnifiedTimeOfDayField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fieldController != widget.fieldController ||
        oldWidget.binding != widget.binding) {
      detachUnifiedFieldHandles(
        binding: oldWidget.binding,
        fieldController: oldWidget.fieldController,
      );
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
        oldWidget.fieldController?.value != widget.fieldController?.value) {
      _syncText();
    }
  }

  void _onBinding() {
    _syncText();
    setState(() {});
  }

  void _syncText() {
    final t = unifiedEffectiveValue(
      fieldController: widget.fieldController,
      binding: widget.binding,
      direct: widget.value,
    );
    _txt.text = formatUnifiedTimeOfDayText(
      t,
      granularity: _granularity,
      second: _effectiveSecond,
      calendarKind: _effectiveCalendarKind,
    );
  }

  void _onPickerConfirmedCalendarKind(UnifiedFieldsCalendarKind kind) {
    widget.fieldController?.calendarKind = kind;
    if (widget.fieldController == null && _calendarKind != kind) {
      setState(() => _calendarKind = kind);
    }
    _syncText();
  }

  @override
  void dispose() {
    detachUnifiedFieldHandles(
      binding: widget.binding,
      fieldController: widget.fieldController,
    );
    widget.binding?.removeListener(_onBinding);
    widget.fieldController?.removeListener(_onBinding);
    _txt.dispose();
    super.dispose();
  }

  Future<void> _pick(BuildContext context) async {
    if (widget.isDisabled || widget.locked) return;
    final fc = widget.fieldController;
    final initial = _effective ?? TimeOfDay.now();
    final picked = await TimePickerUtils.show(
      context,
      title: widget.label ?? widget.decoration?.label,
      initialTime: initial,
      initialSecond: _effectiveSecond,
      timePickerEntryMode:
          fc?.timePickerEntryMode ?? widget.timePickerEntryMode,
      pickerStyle: fc?.pickerStyle ?? widget.pickerStyle,
      granularity: _granularity,
      showCalendarKindToggle: widget.showCalendarKindToggle,
      initialCalendarKind: _effectiveCalendarKind,
      wheelStyle: fc?.wheelStyle ?? widget.wheelStyle,
      onConfirmedCalendarKind: (kind) {
        _onPickerConfirmedCalendarKind(kind);
        if (fc != null &&
            _granularity == UnifiedFieldsTimeGranularity.hoursMinutesSeconds) {
          // second updated when pick completes
        }
      },
    );
    if (!context.mounted || picked == null) return;
    if (fc != null) {
      fc.second = picked.second;
    } else {
      _second = picked.second;
    }
    _txt.text = formatUnifiedPickedTimeText(
      picked,
      granularity: _granularity,
      calendarKind: _effectiveCalendarKind,
    );
    syncUnifiedFieldValue(
      value: picked.toTimeOfDay(),
      onChanged: widget.onChanged,
      binding: widget.binding,
      fieldController: widget.fieldController,
    );
    setState(() {});
  }

  TimeOfDay? get _effective => unifiedEffectiveValue(
    fieldController: widget.fieldController,
    binding: widget.binding,
    direct: widget.value,
  );

  @override
  Widget build(BuildContext context) {
    final chrome = resolveUnifiedFieldDecorationContext(
      context,
      decoration: widget.decoration,
      decorationSet: widget.decorationSet,
      brightness: widget.brightness,
    );
    final d = chrome.resolved;

    return GestureDetector(
      onTap: widget.locked || widget.isDisabled ? null : () => _pick(context),
      child: AbsorbPointer(
        absorbing: true,
        child: UnifiedBaseTextField(
          decorationSet: chrome.activeSet,
          brightness: widget.brightness,
          controller: _txt,
          focusNode: unifiedEffectiveFocusNode(
            fieldController: widget.fieldController,
            binding: widget.binding,
          ),
          errorText: widget.fieldController?.errorText,
          isDisabled: widget.isDisabled,
          locked: widget.locked,
          readOnly: true,
          label: widget.label ?? d.label,
          placeholder: widget.placeholder ?? d.placeholder ?? d.label,
          labelStyle: d.labelStyle,
          style: d.fieldStyle,
          placeholderStyle: d.placeholderStyle,
          backgroundColor: d.backgroundColor,
          headerBackgroundColor:
          d.headerBackgroundColor ?? d.backgroundColor,
          borderRadius:
              d.borderRadius,
          borderSide: d.borderSide,
          height: d.height,
          rowLabelRatio: d.rowLabelRatio,
          labelInRow: d.labelInRow,
          labelMode: d.labelMode,
          requiredField: widget.isRequired || d.requiredField,
          showError: d.showError,
          validationColor: d.validationColor,
          validationIcon: d.validationIcon,
          prefix: d.prefix,
          prefixIcon: d.prefixIcon,
          suffixIcon: widget.isDisabled || widget.locked
              ? null
              : (d.suffixIcon ??
                    UnifiedInputThemeResolver.defaultSuffixIcon(
                      context,
                      UnifiedInputFieldSuffixKind.time,
                      UnifiedInputThemeResolver.resolvePalette(context),
                    )),
          padding: d.contentPadding,
          validator: widget.validator,
          textAlign: TextAlign.center,
          textInputAction: TextInputAction.done,
          onSubmit: widget.onSubmitted,
        ),
      ),
    );
  }
}
