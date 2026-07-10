part of 'unified_form_more_fields.dart';

/// [FormField] + [UnifiedDateField].
class UnifiedFormDateField extends StatefulWidget {
  /// Creates a [Form]-aware date field.
  const UnifiedFormDateField({
    super.key,
    this.decoration,
    this.decorationSet,
    this.brightness,
    this.binding,
    this.fieldController,
    this.value,
    this.resetValue,
    this.controller,
    this.focusNode,
    this.validator,
    this.onSaved,
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
    this.shakeOnError = false,
    this.placeholder,
    this.isRequired = false,
    this.isDisabled = false,
    this.locked = false,
    this.dateFormatStyle,
  });

  /// Visual chrome overrides.
  final UnifiedInputDecoration? decoration;

  /// Per-state decorations (focus, error, valid, locked, disabled, â€¦).
  final UnifiedInputDecorationSet? decorationSet;

  /// Forces a brightness regardless of the ambient [Theme].
  final UnifiedInputBrightness? brightness;

  /// Optional external state binding.
  final UnifiedInputPicker<DateTime>? binding;

  /// Preferred imperative handle; syncs with [binding] and [FormField] on change.
  final UnifiedDateFieldController? fieldController;

  /// Direct value when not using [binding].
  final DateTime? value;

  /// When non-null, [FormState.reset] restores `resetValue()` (may return null to clear).
  final UnifiedFormResetValue<DateTime?>? resetValue;

  /// External [TextEditingController] for the displayed text.
  final TextEditingController? controller;

  /// External focus node.
  final FocusNode? focusNode;

  /// Validator passed to the underlying [FormField].
  final FormFieldValidator<DateTime?>? validator;

  /// Called from [FormState.save].
  final FormFieldSetter<DateTime?>? onSaved;

  /// Called when the picker yields a value.
  final ValueChanged<DateTime?>? onChanged;

  /// Forwarded to the inner text field's submit.
  final ValueChanged<String>? onSubmit;

  /// Earliest allowed date.
  final DateTime? min;

  /// Latest allowed date.
  final DateTime? max;

  /// Either a [DateFormat] or custom format object used to render the field.
  final Object? valueFormat;

  /// Gregorian / Shamsi display patterns; overrides theme [dateFormatStyle].
  final UnifiedFieldsDateFormatStyle? dateFormatStyle;

  /// Forwarded to the picker (calendar vs input).
  final DatePickerEntryMode mode;

  /// Trailing widget.
  final Widget? suffixIcon;

  /// Leading widget shown before the field content.
  final Widget? prefix;

  /// Leading icon shown before the field content.
  final Widget? prefixIcon;

  /// Field label.
  final String? label;

  /// Hint text shown when empty.
  final String? placeholder;

  /// Whether the field is required. Overrides [UnifiedInputDecoration.requiredField] when set.
  final bool isRequired;

  /// When true, greys out the label and shows a forbid suffix icon.
  final bool isDisabled;

  /// When true, greys out the field and shows a lock suffix icon.
  final bool locked;

  /// Whether to show the inline clear button when there is a value.
  final bool showClearButton;

  /// Whether the inner text field is read-only.
  final bool readOnly;

  /// Autofocus the inner text field.
  final bool autofocus;

  /// Text alignment.
  final TextAlign textAlign;

  /// When false, the picker sheet hides the Gregorian / Shamsi switch.
  final bool showCalendarKindToggle;

  /// Precision for the picker sheet.
  final UnifiedFieldsDatePickerGranularity pickerGranularity;

  /// Calendar grid vs scroll-wheel picker.
  final UnifiedFieldsDatePickerStyle pickerStyle;

  /// Starting calendar system (Gregorian / Shamsi).
  final UnifiedFieldsCalendarKind initialCalendarKind;

  /// Optional wheel chrome when [pickerStyle] is [UnifiedFieldsDatePickerStyle.wheels].
  final UnifiedFieldsDateWheelStyle? wheelStyle;

  /// Picker sheet chrome; merged with [UnifiedInputThemeData.datePickerStyle].
  final UnifiedInputDatePickerStyle? datePickerStyle;

  /// When [pickerStyle] is wheels, show weekday names in the day column.
  final bool showWeekdayInWheel;

  /// Per-day decorations for styled pickers.
  final UnifiedFieldsCalendarDayInfoBuilder? dayInfoBuilder;

  /// Extra styling for styled pickers.
  final UnifiedFieldsPickerTheme? pickerTheme;

  /// When true, shakes once when validation error appears on this field.
  final bool shakeOnError;

  @override
  State<UnifiedFormDateField> createState() => _UnifiedFormDateFieldState();
}

class _UnifiedFormDateFieldState extends State<UnifiedFormDateField> {
  final GlobalKey<FormFieldState<DateTime?>> _formFieldKey =
      GlobalKey<FormFieldState<DateTime?>>();
  late DateTime? _echoWhenNoReset;
  DateTime? _cachedResetTarget;

  DateTime? _displayValue() => unifiedEffectiveValue(
    fieldController: widget.fieldController,
    binding: widget.binding,
    direct: widget.value,
  );

  void _scheduleSyncDisplayWhenCurrentDiffersFromResetTarget() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final resetFn = widget.resetValue;
      if (resetFn == null) return;
      final reset = resetFn();
      final display = _displayValue();
      if (display != reset) {
        final s = _formFieldKey.currentState;
        if (s != null && s.value != display) {
          s.didChange(display);
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _echoWhenNoReset = _displayValue();
    if (widget.resetValue != null) {
      _cachedResetTarget = widget.resetValue!();
      _scheduleSyncDisplayWhenCurrentDiffersFromResetTarget();
    }
    syncWidgetFormValidatorToFieldController<DateTime?>(
      widget.fieldController,
      widget.validator,
    );
    widget.binding?.addListener(_onBindingChanged);
    widget.fieldController?.addListener(_onFieldControllerChanged);
  }

  @override
  void didUpdateWidget(covariant UnifiedFormDateField oldWidget) {
    super.didUpdateWidget(oldWidget);
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
      syncWidgetFormValidatorToFieldController<DateTime?>(
        widget.fieldController,
        widget.validator,
      );
    }
    final resetChanged = widget.resetValue != oldWidget.resetValue;
    final bindingChanged = widget.binding != oldWidget.binding;
    final fieldControllerChanged =
        widget.fieldController != oldWidget.fieldController;
    if (resetChanged || bindingChanged || fieldControllerChanged) {
      if (widget.resetValue != null) {
        _cachedResetTarget = widget.resetValue!();
        _scheduleSyncDisplayWhenCurrentDiffersFromResetTarget();
      } else {
        final display = _displayValue();
        if (_echoWhenNoReset != display) {
          setState(() => _echoWhenNoReset = display);
        }
        final s = _formFieldKey.currentState;
        if (s != null && s.value != display) {
          s.didChange(display);
        }
      }
    } else if (widget.resetValue == null) {
      final display = _displayValue();
      final oldDisplay = unifiedEffectiveValue(
        fieldController: oldWidget.fieldController,
        binding: oldWidget.binding,
        direct: oldWidget.value,
      );
      if (display != oldDisplay) {
        if (_echoWhenNoReset != display) {
          setState(() => _echoWhenNoReset = display);
        }
        final s = _formFieldKey.currentState;
        if (s != null && s.value != display) {
          s.didChange(display);
        }
      }
    } else {
      final display = _displayValue();
      final oldDisplay = unifiedEffectiveValue(
        fieldController: oldWidget.fieldController,
        binding: oldWidget.binding,
        direct: oldWidget.value,
      );
      if (display != oldDisplay) {
        final s = _formFieldKey.currentState;
        if (s != null && s.value != display) {
          s.didChange(display);
        }
      }
    }
  }

  void _onBindingChanged() {
    _applyExternalValue(widget.binding?.value);
  }

  void _onFieldControllerChanged() {
    _applyExternalValue(widget.fieldController?.value);
  }

  void _applyExternalValue(DateTime? display) {
    syncFormFieldFromExternalValue<DateTime?>(
      formState: _formFieldKey.currentState,
      value: display,
      fieldController: widget.fieldController,
    );
    if (widget.resetValue == null && _echoWhenNoReset != display) {
      setState(() => _echoWhenNoReset = display);
    } else {
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.binding?.removeListener(_onBindingChanged);
    widget.fieldController?.removeListener(_onFieldControllerChanged);
    super.dispose();
  }

  void _syncControllerAndBindingFromForm() {
    final dt = _formFieldKey.currentState?.value;
    syncUnifiedFieldValue<DateTime?>(
      value: dt,
      binding: widget.binding,
      fieldController: widget.fieldController,
    );
    final c = widget.controller;
    if (c != null) {
      final text = formatUnifiedDateFieldText(
        dt,
        widget.valueFormat,
        granularity: widget.pickerGranularity,
        calendarKind:
            widget.fieldController?.calendarKind ?? widget.initialCalendarKind,
        formatStyle: UnifiedInputThemeResolver.dateFormatStyle(
          context,
          field:
              widget.dateFormatStyle ?? widget.fieldController?.dateFormatStyle,
        ),
      );
      if (c.text != text) {
        c.text = text;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    syncWidgetFormValidatorToFieldController<DateTime?>(
      widget.fieldController,
      widget.validator,
    );
    return UnifiedFormField<DateTime?>(
      formFieldKey: _formFieldKey,
      initialValue: widget.resetValue != null
          ? _cachedResetTarget
          : _echoWhenNoReset,
      validator: widget.validator,
      onSaved: widget.onSaved,
      onReset: _syncControllerAndBindingFromForm,
      shakeOnError: widget.shakeOnError,
      builder: (context, fieldState) {
        return UnifiedDateField(
          decoration: widget.decoration,
          decorationSet: widget.decorationSet,
          brightness: widget.brightness,
          fieldController: widget.fieldController,
          binding: null,
          value: widget.fieldController == null ? fieldState.value : null,
          controller: widget.controller,
          focusNode: widget.focusNode,
          placeholder: widget.placeholder,
          isRequired: widget.isRequired,
          isDisabled: widget.isDisabled,
          locked: widget.locked,
          validator: (_) => unifiedFormErrorText(fieldState),
          onChanged: (dt) {
            fieldState.didChange(dt);
            if (widget.resetValue == null) {
              setState(() => _echoWhenNoReset = dt);
            }
            syncUnifiedFieldValue<DateTime?>(
              value: dt,
              onChanged: widget.onChanged,
              binding: widget.binding,
              fieldController: widget.fieldController,
              formFieldState: fieldState,
            );
          },
          onSubmit: widget.onSubmit,
          min: widget.min ?? widget.fieldController?.min,
          max: widget.max ?? widget.fieldController?.max,
          valueFormat:
              widget.valueFormat ?? widget.fieldController?.valueFormat,
          dateFormatStyle:
              widget.dateFormatStyle ?? widget.fieldController?.dateFormatStyle,
          mode: widget.fieldController?.mode ?? widget.mode,
          suffixIcon: widget.suffixIcon,
          prefix: widget.prefix,
          prefixIcon: widget.prefixIcon,
          label: widget.label,
          showClearButton: widget.showClearButton,
          readOnly: widget.readOnly,
          autofocus: widget.autofocus,
          textAlign: widget.textAlign,
          showCalendarKindToggle:
              widget.fieldController?.showCalendarKindToggle ??
              widget.showCalendarKindToggle,
          pickerGranularity:
              widget.fieldController?.pickerGranularity ??
              widget.pickerGranularity,
          pickerStyle:
              widget.fieldController?.pickerStyle ?? widget.pickerStyle,
          initialCalendarKind:
              widget.fieldController?.calendarKind ??
              widget.initialCalendarKind,
          wheelStyle: widget.fieldController?.wheelStyle ?? widget.wheelStyle,
          datePickerStyle:
              widget.fieldController?.datePickerStyle ?? widget.datePickerStyle,
          showWeekdayInWheel:
              widget.fieldController?.showWeekdayInWheel ??
              widget.showWeekdayInWheel,
          dayInfoBuilder:
              widget.fieldController?.dayInfoBuilder ?? widget.dayInfoBuilder,
          pickerTheme:
              widget.fieldController?.pickerTheme ?? widget.pickerTheme,
        );
      },
    );
  }
}

/// [FormField] + [UnifiedDateRangeField].
class UnifiedFormDateRangeField extends StatefulWidget {
  /// Creates a [Form]-aware date range field.
  const UnifiedFormDateRangeField({
    super.key,
    this.decoration,
    this.decorationSet,
    this.brightness,
    this.binding,
    this.fieldController,
    this.rangeValue,
    this.resetValue,
    this.controller,
    this.validator,
    this.onSaved,
    this.onRangeChanged,
    this.min,
    this.max,
    this.showCalendarKindToggle = true,
    this.textAlign = TextAlign.start,
    this.shakeOnError = false,
    this.label,
    this.placeholder,
    this.isRequired = false,
    this.isDisabled = false,
    this.locked = false,
    this.dateFormatStyle,
    this.pickerStyle = UnifiedFieldsDatePickerStyle.verticalMonths,
    this.datePickerStyle,
    this.dayInfoBuilder,
    this.pickerTheme,
    this.initialCalendarKind = UnifiedFieldsCalendarKind.gregorian,
  });

  /// Visual chrome overrides.
  final UnifiedInputDecoration? decoration;

  /// Per-state decorations (focus, error, valid, locked, disabled, â€¦).
  final UnifiedInputDecorationSet? decorationSet;

  /// Forces a brightness regardless of the ambient [Theme].
  final UnifiedInputBrightness? brightness;

  /// Optional external state binding.
  final UnifiedInputPicker<DateTimeRange>? binding;

  /// Preferred imperative handle; syncs with [binding] and [FormField] on change.
  final UnifiedDateRangeFieldController? fieldController;

  /// Direct value when not using [binding].
  final DateTimeRange? rangeValue;

  /// When non-null, [FormState.reset] restores `resetValue()` (may return null to clear).
  final UnifiedFormResetValue<DateTimeRange?>? resetValue;

  /// External [TextEditingController].
  final TextEditingController? controller;

  /// Validator passed to the underlying [FormField].
  final FormFieldValidator<DateTimeRange?>? validator;

  /// Called from [FormState.save].
  final FormFieldSetter<DateTimeRange?>? onSaved;

  /// Called when the picker yields a range.
  final ValueChanged<DateTimeRange?>? onRangeChanged;

  /// Earliest allowed date.
  final DateTime? min;

  /// Latest allowed date.
  final DateTime? max;

  /// When false, the picker sheet hides the Gregorian / Shamsi switch.
  final bool showCalendarKindToggle;

  /// Text alignment.
  final TextAlign textAlign;

  /// Field label.
  final String? label;

  /// Hint text shown when empty.
  final String? placeholder;

  /// Whether the field is required. Overrides [UnifiedInputDecoration.requiredField] when set.
  final bool isRequired;

  /// When true, greys out the label and shows a forbid suffix icon.
  final bool isDisabled;

  /// When true, greys out the field and shows a lock suffix icon.
  final bool locked;

  /// Gregorian / Shamsi display patterns; overrides theme [dateFormatStyle].
  final UnifiedFieldsDateFormatStyle? dateFormatStyle;

  /// Styled range picker layout.
  final UnifiedFieldsDatePickerStyle pickerStyle;

  /// Picker sheet chrome.
  final UnifiedInputDatePickerStyle? datePickerStyle;

  /// Per-day decorations for styled range pickers.
  final UnifiedFieldsCalendarDayInfoBuilder? dayInfoBuilder;

  /// Extra styling for styled range pickers.
  final UnifiedFieldsPickerTheme? pickerTheme;

  /// Calendar kind for formatting and digit localization.
  final UnifiedFieldsCalendarKind initialCalendarKind;

  /// When true, shakes once when validation error appears on this field.
  final bool shakeOnError;

  @override
  State<UnifiedFormDateRangeField> createState() =>
      _UnifiedFormDateRangeFieldState();
}

class _UnifiedFormDateRangeFieldState extends State<UnifiedFormDateRangeField> {
  final GlobalKey<FormFieldState<DateTimeRange?>> _formFieldKey =
      GlobalKey<FormFieldState<DateTimeRange?>>();
  late DateTimeRange? _echoWhenNoReset;
  DateTimeRange? _cachedResetTarget;

  void _onBindingChanged() {
    _applyExternalValue(widget.binding?.value);
  }

  DateTimeRange? _displayValue() => unifiedEffectiveValue(
    fieldController: widget.fieldController,
    binding: widget.binding,
    direct: widget.rangeValue,
  );

  void _scheduleSyncDisplayWhenCurrentDiffersFromResetTarget() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final resetFn = widget.resetValue;
      if (resetFn == null) return;
      final reset = resetFn();
      final display = _displayValue();
      if (display != reset) {
        final s = _formFieldKey.currentState;
        if (s != null && s.value != display) {
          s.didChange(display);
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _echoWhenNoReset = _displayValue();
    if (widget.resetValue != null) {
      _cachedResetTarget = widget.resetValue!();
      _scheduleSyncDisplayWhenCurrentDiffersFromResetTarget();
    }
    syncWidgetFormValidatorToFieldController<DateTimeRange?>(
      widget.fieldController,
      widget.validator,
    );
    widget.binding?.addListener(_onBindingChanged);
    widget.fieldController?.addListener(_onFieldControllerChanged);
  }

  @override
  void didUpdateWidget(covariant UnifiedFormDateRangeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.validator != widget.validator ||
        oldWidget.fieldController != widget.fieldController) {
      syncWidgetFormValidatorToFieldController<DateTimeRange?>(
        widget.fieldController,
        widget.validator,
      );
    }
    if (oldWidget.binding != widget.binding) {
      oldWidget.binding?.removeListener(_onBindingChanged);
      widget.binding?.addListener(_onBindingChanged);
    }
    if (oldWidget.fieldController != widget.fieldController) {
      oldWidget.fieldController?.removeListener(_onFieldControllerChanged);
      widget.fieldController?.addListener(_onFieldControllerChanged);
    }
    final resetChanged = widget.resetValue != oldWidget.resetValue;
    final bindingChanged = widget.binding != oldWidget.binding;
    final fieldControllerChanged =
        widget.fieldController != oldWidget.fieldController;
    if (resetChanged || bindingChanged || fieldControllerChanged) {
      if (widget.resetValue != null) {
        _cachedResetTarget = widget.resetValue!();
        _scheduleSyncDisplayWhenCurrentDiffersFromResetTarget();
      } else {
        final display = _displayValue();
        if (_echoWhenNoReset != display) {
          setState(() => _echoWhenNoReset = display);
        }
        final s = _formFieldKey.currentState;
        if (s != null && s.value != display) {
          s.didChange(display);
        }
      }
    } else if (widget.resetValue == null) {
      final display = _displayValue();
      final oldDisplay = unifiedEffectiveValue(
        fieldController: oldWidget.fieldController,
        binding: oldWidget.binding,
        direct: oldWidget.rangeValue,
      );
      if (display != oldDisplay) {
        if (_echoWhenNoReset != display) {
          setState(() => _echoWhenNoReset = display);
        }
        final s = _formFieldKey.currentState;
        if (s != null && s.value != display) {
          s.didChange(display);
        }
      }
    } else {
      final display = _displayValue();
      final oldDisplay = unifiedEffectiveValue(
        fieldController: oldWidget.fieldController,
        binding: oldWidget.binding,
        direct: oldWidget.rangeValue,
      );
      if (display != oldDisplay) {
        final s = _formFieldKey.currentState;
        if (s != null && s.value != display) {
          s.didChange(display);
        }
      }
    }
  }

  void _onFieldControllerChanged() {
    _applyExternalValue(widget.fieldController?.value);
  }

  void _applyExternalValue(DateTimeRange? display) {
    syncFormFieldFromExternalValue<DateTimeRange?>(
      formState: _formFieldKey.currentState,
      value: display,
      fieldController: widget.fieldController,
    );
    if (widget.resetValue == null && _echoWhenNoReset != display) {
      setState(() => _echoWhenNoReset = display);
    } else {
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.binding?.removeListener(_onBindingChanged);
    widget.fieldController?.removeListener(_onFieldControllerChanged);
    super.dispose();
  }

  void _syncControllerAndBindingFromForm() {
    final r = _formFieldKey.currentState?.value;
    syncUnifiedFieldValue<DateTimeRange?>(
      value: r,
      binding: widget.binding,
      fieldController: widget.fieldController,
    );
    final c = widget.controller;
    if (c != null) {
      final text = formatUnifiedDateRangeFieldText(
        r,
        calendarKind:
            widget.fieldController?.calendarKind ?? widget.initialCalendarKind,
        formatStyle: UnifiedInputThemeResolver.dateFormatStyle(
          context,
          field:
              widget.dateFormatStyle ?? widget.fieldController?.dateFormatStyle,
        ),
      );
      if (c.text != text) {
        c.text = text;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    syncWidgetFormValidatorToFieldController<DateTimeRange?>(
      widget.fieldController,
      widget.validator,
    );
    return UnifiedFormField<DateTimeRange?>(
      formFieldKey: _formFieldKey,
      initialValue: widget.resetValue != null
          ? _cachedResetTarget
          : _echoWhenNoReset,
      validator: widget.validator,
      onSaved: widget.onSaved,
      onReset: _syncControllerAndBindingFromForm,
      shakeOnError: widget.shakeOnError,
      builder: (context, fieldState) {
        return UnifiedDateRangeField(
          decoration: widget.decoration,
          decorationSet: widget.decorationSet,
          brightness: widget.brightness,
          binding: null,
          rangeValue: fieldState.value,
          controller: widget.controller,
          label: widget.label,
          placeholder: widget.placeholder,
          isRequired: widget.isRequired,
          isDisabled: widget.isDisabled,
          locked: widget.locked,
          validator: (_) => unifiedFormErrorText(fieldState),
          onRangeChanged: (r) {
            fieldState.didChange(r);
            if (widget.resetValue == null) {
              setState(() => _echoWhenNoReset = r);
            }
            syncUnifiedFieldValue<DateTimeRange?>(
              value: r,
              onChanged: widget.onRangeChanged,
              binding: widget.binding,
              fieldController: widget.fieldController,
              formFieldState: fieldState,
            );
          },
          min: widget.min,
          max: widget.max,
          showCalendarKindToggle: widget.showCalendarKindToggle,
          textAlign: widget.textAlign,
          dateFormatStyle:
              widget.dateFormatStyle ?? widget.fieldController?.dateFormatStyle,
          pickerStyle:
              widget.fieldController?.pickerStyle ?? widget.pickerStyle,
          datePickerStyle:
              widget.fieldController?.datePickerStyle ?? widget.datePickerStyle,
          dayInfoBuilder:
              widget.fieldController?.dayInfoBuilder ?? widget.dayInfoBuilder,
          pickerTheme:
              widget.fieldController?.pickerTheme ?? widget.pickerTheme,
          initialCalendarKind:
              widget.fieldController?.calendarKind ?? widget.initialCalendarKind,
        );
      },
    );
  }
}

