part of 'unified_form_more_fields.dart';

/// [FormField] + [UnifiedTimeOfDayField].
class UnifiedFormTimeOfDayField extends StatefulWidget {
  /// Creates a [Form]-aware time-of-day field.
  const UnifiedFormTimeOfDayField({
    super.key,
    this.decoration,
    this.decorationSet,
    this.brightness,
    this.binding,
    this.fieldController,
    this.value,
    this.resetValue,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.onSubmitted,
    this.locked = false,
    this.isDisabled = false,
    this.timePickerEntryMode = TimePickerEntryMode.dial,
    this.pickerStyle = UnifiedFieldsTimePickerStyle.dial,
    this.pickerTheme,
    this.datePickerStyle,
    this.presets = const [],
    this.includeNowPreset = false,
    this.shakeOnError = false,
    this.label,
    this.placeholder,
    this.isRequired = false,
  });

  /// Field label.
  final String? label;

  /// Hint text shown when empty.
  final String? placeholder;

  /// Whether the field is required. Overrides [UnifiedInputDecoration.requiredField] when set.
  final bool isRequired;

  /// Visual chrome overrides.
  final UnifiedInputDecoration? decoration;

  /// Per-state decorations (focus, error, valid, locked, disabled, â€¦).
  final UnifiedInputDecorationSet? decorationSet;

  /// Forces a brightness regardless of the ambient [Theme].
  final UnifiedInputBrightness? brightness;

  /// Optional external state binding.
  final UnifiedInputPicker<TimeOfDay>? binding;

  /// Preferred imperative handle; syncs with [binding] and [FormField] on change.
  final UnifiedTimeOfDayFieldController? fieldController;

  /// Direct value when not using [binding].
  final TimeOfDay? value;

  /// When non-null, [FormState.reset] restores `resetValue()` (may return null to clear).
  final UnifiedFormResetValue<TimeOfDay?>? resetValue;

  /// Validator passed to the underlying [FormField].
  final FormFieldValidator<TimeOfDay?>? validator;

  /// Called from [FormState.save].
  final FormFieldSetter<TimeOfDay?>? onSaved;

  /// Called when the picker yields a value.
  final ValueChanged<TimeOfDay?>? onChanged;

  /// Forwarded to the inner submit.
  final ValueChanged<String>? onSubmitted;

  /// When true, the field is non-interactive.
  final bool locked;

  /// When true, greys out the label and shows a forbid suffix icon.
  final bool isDisabled;

  /// Entry mode for the time picker.
  final TimePickerEntryMode timePickerEntryMode;

  /// Dial, wheels, or styled creative pickers.
  final UnifiedFieldsTimePickerStyle pickerStyle;

  /// Extra styling for styled time pickers.
  final UnifiedFieldsPickerTheme? pickerTheme;

  /// Merged into [UnifiedFieldsPickerTheme.resolve].
  final UnifiedInputDatePickerStyle? datePickerStyle;

  /// Quick-pick chips for styled time pickers.
  final List<TimeOfDay> presets;

  /// Prepends a "Now" chip to [presets].
  final bool includeNowPreset;

  /// When true, shakes once when validation error appears on this field.
  final bool shakeOnError;

  @override
  State<UnifiedFormTimeOfDayField> createState() =>
      _UnifiedFormTimeOfDayFieldState();
}

class _UnifiedFormTimeOfDayFieldState extends State<UnifiedFormTimeOfDayField> {
  final GlobalKey<FormFieldState<TimeOfDay?>> _formFieldKey =
      GlobalKey<FormFieldState<TimeOfDay?>>();
  late TimeOfDay? _echoWhenNoReset;
  TimeOfDay? _cachedResetTarget;

  void _onBindingChanged() {
    _applyExternalValue(widget.binding?.value);
  }

  TimeOfDay? _displayValue() => unifiedEffectiveValue(
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
    syncWidgetFormValidatorToFieldController<TimeOfDay?>(
      widget.fieldController,
      widget.validator,
    );
    widget.binding?.addListener(_onBindingChanged);
    widget.fieldController?.addListener(_onFieldControllerChanged);
  }

  @override
  void didUpdateWidget(covariant UnifiedFormTimeOfDayField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.validator != widget.validator ||
        oldWidget.fieldController != widget.fieldController) {
      syncWidgetFormValidatorToFieldController<TimeOfDay?>(
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

  void _onFieldControllerChanged() {
    _applyExternalValue(widget.fieldController?.value);
  }

  void _applyExternalValue(TimeOfDay? display) {
    syncFormFieldFromExternalValue<TimeOfDay?>(
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

  void _syncBindingFromForm() {
    syncUnifiedFieldValue<TimeOfDay?>(
      value: _formFieldKey.currentState?.value,
      binding: widget.binding,
      fieldController: widget.fieldController,
    );
  }

  @override
  Widget build(BuildContext context) {
    syncWidgetFormValidatorToFieldController<TimeOfDay?>(
      widget.fieldController,
      widget.validator,
    );
    return UnifiedFormField<TimeOfDay?>(
      formFieldKey: _formFieldKey,
      initialValue: widget.resetValue != null
          ? _cachedResetTarget
          : _echoWhenNoReset,
      validator: widget.validator,
      onSaved: widget.onSaved,
      onReset: _syncBindingFromForm,
      shakeOnError: widget.shakeOnError,
      builder: (context, fieldState) {
        return UnifiedTimeOfDayField(
          decoration: widget.decoration,
          decorationSet: widget.decorationSet,
          brightness: widget.brightness,
          fieldController: widget.fieldController,
          binding: null,
          value: widget.fieldController == null ? fieldState.value : null,
          label: widget.label,
          placeholder: widget.placeholder,
          isRequired: widget.isRequired,
          validator: (_) => unifiedFormErrorText(fieldState),
          onChanged: (t) {
            fieldState.didChange(t);
            if (widget.resetValue == null) {
              setState(() => _echoWhenNoReset = t);
            }
            syncUnifiedFieldValue<TimeOfDay?>(
              value: t,
              onChanged: widget.onChanged,
              binding: widget.binding,
              fieldController: widget.fieldController,
              formFieldState: fieldState,
            );
          },
          onSubmitted: widget.onSubmitted,
          locked: widget.locked,
          isDisabled: widget.isDisabled,
          timePickerEntryMode:
              widget.fieldController?.timePickerEntryMode ??
              widget.timePickerEntryMode,
          pickerStyle:
              widget.fieldController?.pickerStyle ?? widget.pickerStyle,
          pickerTheme:
              widget.fieldController?.pickerTheme ?? widget.pickerTheme,
          datePickerStyle:
              widget.fieldController?.datePickerStyle ?? widget.datePickerStyle,
          presets: widget.fieldController?.presets ?? widget.presets,
          includeNowPreset:
              widget.fieldController?.includeNowPreset ?? widget.includeNowPreset,
        );
      },
    );
  }
}

/// [FormField] + [UnifiedDurationField].
class UnifiedFormDurationField extends StatefulWidget {
  /// Creates a [Form]-aware duration field.
  const UnifiedFormDurationField({
    super.key,
    this.decoration,
    this.decorationSet,
    this.brightness,
    this.binding,
    this.fieldController,
    this.value,
    this.resetValue,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.onSubmitted,
    this.granularity = UnifiedDurationGranularity.hoursMinutesSeconds,
    this.pickerColumns,
    this.pickerStyle = UnifiedFieldsDurationPickerStyle.wheels,
    this.showCalendarKindToggle = true,
    this.initialCalendarKind = UnifiedFieldsCalendarKind.gregorian,
    this.min,
    this.max,
    this.locked = false,
    this.isDisabled = false,
    this.focusNode,
    this.shakeOnError = false,
    this.label,
    this.placeholder,
    this.isRequired = false,
    this.durationFormatStyle,
  });

  /// Field label.
  final String? label;

  /// Hint text shown when empty.
  final String? placeholder;

  /// Whether the field is required. Overrides [UnifiedInputDecoration.requiredField] when set.
  final bool isRequired;

  /// Visual chrome overrides.
  final UnifiedInputDecoration? decoration;

  /// Per-state decorations (focus, error, valid, locked, disabled, â€¦).
  final UnifiedInputDecorationSet? decorationSet;

  /// Forces a brightness regardless of the ambient [Theme].
  final UnifiedInputBrightness? brightness;

  /// Optional external state binding.
  final UnifiedInputPicker<Duration>? binding;

  /// Preferred imperative handle; syncs with [binding] and [FormField] on change.
  final UnifiedDurationFieldController? fieldController;

  /// Direct value when not using [binding].
  final Duration? value;

  /// When non-null, [FormState.reset] restores `resetValue()` (may return null to clear).
  final UnifiedFormResetValue<Duration?>? resetValue;

  /// Validator passed to the underlying [FormField].
  final FormFieldValidator<Duration?>? validator;

  /// Called from [FormState.save].
  final FormFieldSetter<Duration?>? onSaved;

  /// Called when the picker yields a value.
  final ValueChanged<Duration?>? onChanged;

  /// Forwarded to the inner submit.
  final ValueChanged<String>? onSubmitted;

  /// Granularity of the duration picker when [pickerColumns] is null.
  final UnifiedDurationGranularity granularity;

  /// Custom wheel columns (largest unit first); overrides [granularity] when set.
  final List<UnifiedFieldsDurationColumn>? pickerColumns;

  /// Cupertino vs unified styled wheels.
  final UnifiedFieldsDurationPickerStyle pickerStyle;

  /// When false, hides the Gregorian / Shamsi digit toggle on wheel pickers.
  final bool showCalendarKindToggle;

  /// Starting digit / label mode for wheel pickers.
  final UnifiedFieldsCalendarKind initialCalendarKind;

  /// Minimum allowed duration.
  final Duration? min;

  /// Maximum allowed duration.
  final Duration? max;

  /// Colon-separated display style; overrides theme [durationFormatStyle].
  final UnifiedFieldsDurationFormatStyle? durationFormatStyle;

  /// When true, the field is non-interactive.
  final bool locked;

  /// When true, greys out the label and shows a forbid suffix icon.
  final bool isDisabled;

  /// External focus node.
  final FocusNode? focusNode;

  /// When true, shakes once when validation error appears on this field.
  final bool shakeOnError;

  @override
  State<UnifiedFormDurationField> createState() =>
      _UnifiedFormDurationFieldState();
}

class _UnifiedFormDurationFieldState extends State<UnifiedFormDurationField> {
  final GlobalKey<FormFieldState<Duration?>> _formFieldKey =
      GlobalKey<FormFieldState<Duration?>>();
  late Duration? _echoWhenNoReset;
  Duration? _cachedResetTarget;

  void _onBindingChanged() {
    _applyExternalValue(widget.binding?.value);
  }

  Duration? _displayValue() => unifiedEffectiveValue(
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
    syncWidgetFormValidatorToFieldController<Duration?>(
      widget.fieldController,
      widget.validator,
    );
    widget.binding?.addListener(_onBindingChanged);
    widget.fieldController?.addListener(_onFieldControllerChanged);
  }

  @override
  void didUpdateWidget(covariant UnifiedFormDurationField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.validator != widget.validator ||
        oldWidget.fieldController != widget.fieldController) {
      syncWidgetFormValidatorToFieldController<Duration?>(
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

  void _onFieldControllerChanged() {
    _applyExternalValue(widget.fieldController?.value);
  }

  void _applyExternalValue(Duration? display) {
    syncFormFieldFromExternalValue<Duration?>(
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

  void _syncBindingFromForm() {
    syncUnifiedFieldValue<Duration?>(
      value: _formFieldKey.currentState?.value,
      binding: widget.binding,
      fieldController: widget.fieldController,
    );
  }

  @override
  Widget build(BuildContext context) {
    syncWidgetFormValidatorToFieldController<Duration?>(
      widget.fieldController,
      widget.validator,
    );
    return UnifiedFormField<Duration?>(
      formFieldKey: _formFieldKey,
      initialValue: widget.resetValue != null
          ? _cachedResetTarget
          : _echoWhenNoReset,
      validator: widget.validator,
      onSaved: widget.onSaved,
      onReset: _syncBindingFromForm,
      shakeOnError: widget.shakeOnError,
      builder: (context, fieldState) {
        return UnifiedDurationField(
          decoration: widget.decoration,
          decorationSet: widget.decorationSet,
          brightness: widget.brightness,
          binding: null,
          value: fieldState.value,
          label: widget.label,
          placeholder: widget.placeholder,
          isRequired: widget.isRequired,
          validator: (_) => unifiedFormErrorText(fieldState),
          onChanged: (d) {
            fieldState.didChange(d);
            if (widget.resetValue == null) {
              setState(() => _echoWhenNoReset = d);
            }
            syncUnifiedFieldValue<Duration?>(
              value: d,
              onChanged: widget.onChanged,
              binding: widget.binding,
              fieldController: widget.fieldController,
              formFieldState: fieldState,
            );
          },
          onSubmitted: widget.onSubmitted,
          granularity: widget.granularity,
          pickerColumns: widget.pickerColumns,
          pickerStyle: widget.pickerStyle,
          showCalendarKindToggle: widget.showCalendarKindToggle,
          initialCalendarKind: widget.initialCalendarKind,
          min: widget.min,
          max: widget.max,
          locked: widget.locked,
          isDisabled: widget.isDisabled,
          focusNode: widget.focusNode,
          durationFormatStyle: widget.durationFormatStyle ??
              widget.fieldController?.durationFormatStyle,
        );
      },
    );
  }
}

