import 'package:flutter/material.dart';

import '../unified_date_picker_sheet.dart';
import 'app_input_controller.dart';
import 'unified_async_picker_field.dart';
import 'unified_date_field.dart';
import 'unified_duration_field.dart';
import 'unified_form_fields.dart';
import 'unified_input_brightness.dart';
import 'unified_input_decoration.dart';
import 'unified_number_field.dart';
import 'unified_picker_fields.dart';
import 'unified_time_of_day_field.dart';

bool _unifiedListsEqual<T>(List<T>? a, List<T> b) {
  if (a == null) return b.isEmpty;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

/// [FormField] + [UnifiedMultiPickerField].
class UnifiedFormMultiPickerField<T> extends StatefulWidget {
  /// Creates a [Form]-aware multi-select picker field.
  const UnifiedFormMultiPickerField({
    super.key,
    required this.items,
    required this.label,
    required this.values,
    this.resetValue,
    this.decoration,
    this.brightness,
    this.binding,
    this.onChanged,
    this.valueToString,
    this.searchBuilder,
    this.itemToWidget,
    this.suggestion = const [],
    this.hasSearch = true,
    this.searchAutoFocus = false,
    this.showClearButton = true,
    this.locked = false,
    this.validator,
    this.onSaved,
    this.shakeOnError = false,
    this.placeholder,
    this.isRequired = false,
  });

  /// Choices shown in the picker sheet.
  final List<T> items;

  /// Label for the field and sheet title fallback.
  final String label;

  /// Current selection.
  final List<T> values;

  /// Hint text shown when empty.
  final String? placeholder;

  /// Whether the field is required. Overrides [UnifiedInputDecoration.requiredField] when set.
  final bool isRequired;

  /// When non-null, [FormState.reset] restores `resetValue()` (e.g. `() => const []` to clear).
  final UnifiedFormResetValue<List<T>>? resetValue;

  /// Visual chrome overrides.
  final UnifiedInputDecoration? decoration;

  /// Forces a brightness regardless of the ambient [Theme].
  final UnifiedInputBrightness? brightness;

  /// Optional external state binding.
  final AppInputController<List<T>>? binding;

  /// Called when the selection changes.
  final ValueChanged<List<T>>? onChanged;

  /// Renders an item to its display text.
  final String Function(T value)? valueToString;

  /// Custom searchable text per item.
  final String Function(T value)? searchBuilder;

  /// Custom row builder inside the sheet.
  final Widget Function(T value)? itemToWidget;

  /// Suggestion list pinned above the searchable list.
  final List<T> suggestion;

  /// Whether the sheet shows a search field.
  final bool hasSearch;

  /// Autofocus the search field on open.
  final bool searchAutoFocus;

  /// Show a Clear button in the sheet header.
  final bool showClearButton;

  /// When true, the field is non-interactive.
  final bool locked;

  /// Validator passed to the underlying [FormField].
  final FormFieldValidator<List<T>>? validator;

  /// Called from [FormState.save].
  final FormFieldSetter<List<T>>? onSaved;

  /// When true, shakes once when validation error appears on this field.
  final bool shakeOnError;

  @override
  State<UnifiedFormMultiPickerField<T>> createState() => _UnifiedFormMultiPickerFieldState<T>();
}

class _UnifiedFormMultiPickerFieldState<T> extends State<UnifiedFormMultiPickerField<T>> {
  final GlobalKey<FormFieldState<List<T>>> _formFieldKey = GlobalKey<FormFieldState<List<T>>>();
  late List<T> _echoWhenNoReset;
  late List<T> _frozenResetList;

  List<T> _displayList() => List<T>.from(widget.binding?.value ?? widget.values);

  void _scheduleSyncDisplayWhenCurrentDiffersFromResetTarget() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final resetFn = widget.resetValue;
      if (resetFn == null) return;
      final reset = resetFn();
      final display = _displayList();
      if (!_unifiedListsEqual(reset, display)) {
        final s = _formFieldKey.currentState;
        if (s != null && !_unifiedListsEqual(s.value ?? [], display)) {
          s.didChange(display);
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _echoWhenNoReset = _displayList();
    if (widget.resetValue != null) {
      _frozenResetList = List<T>.from(widget.resetValue!());
      _scheduleSyncDisplayWhenCurrentDiffersFromResetTarget();
    } else {
      _frozenResetList = [];
    }
  }

  @override
  void didUpdateWidget(covariant UnifiedFormMultiPickerField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final resetFnChanged = !identical(widget.resetValue, oldWidget.resetValue);
    final resetPayloadChanged = widget.resetValue != null &&
        oldWidget.resetValue != null &&
        !_unifiedListsEqual(widget.resetValue!(), oldWidget.resetValue!());
    final bindingChanged = widget.binding != oldWidget.binding;
    if (resetFnChanged || resetPayloadChanged || bindingChanged) {
      if (widget.resetValue != null) {
        if (resetFnChanged || resetPayloadChanged) {
          _frozenResetList = List<T>.from(widget.resetValue!());
        }
        _scheduleSyncDisplayWhenCurrentDiffersFromResetTarget();
      } else {
        final display = _displayList();
        if (!_unifiedListsEqual(_echoWhenNoReset, display)) {
          setState(() => _echoWhenNoReset = List<T>.from(display));
        }
        final s = _formFieldKey.currentState;
        if (s != null && !_unifiedListsEqual(s.value ?? [], display)) {
          s.didChange(display);
        }
      }
    } else if (widget.resetValue == null) {
      final display = _displayList();
      final oldDisplay = List<T>.from(oldWidget.binding?.value ?? oldWidget.values);
      if (!_unifiedListsEqual(display, oldDisplay)) {
        if (!_unifiedListsEqual(_echoWhenNoReset, display)) {
          setState(() => _echoWhenNoReset = List<T>.from(display));
        }
        final s = _formFieldKey.currentState;
        if (s != null && !_unifiedListsEqual(s.value ?? [], display)) {
          s.didChange(display);
        }
      }
    } else {
      final display = _displayList();
      final oldDisplay = List<T>.from(oldWidget.binding?.value ?? oldWidget.values);
      if (!_unifiedListsEqual(display, oldDisplay)) {
        final s = _formFieldKey.currentState;
        if (s != null && !_unifiedListsEqual(s.value ?? [], display)) {
          s.didChange(display);
        }
      }
    }
  }

  void _syncBindingFromForm() {
    final b = widget.binding;
    if (b == null) return;
    final v = _formFieldKey.currentState?.value ?? <T>[];
    if (!_unifiedListsEqual(b.value, v)) {
      b.value = List<T>.from(v);
    }
  }

  @override
  Widget build(BuildContext context) {
    return UnifiedFormField<List<T>>(
      formFieldKey: _formFieldKey,
      initialValue: widget.resetValue != null ? _frozenResetList : _echoWhenNoReset,
      validator: widget.validator,
      onSaved: widget.onSaved,
      onReset: _syncBindingFromForm,
      shakeOnError: widget.shakeOnError,
      builder: (context, fieldState) {
        return UnifiedMultiPickerField<T>(
          items: widget.items,
          label: widget.label,
          values: fieldState.value ?? [],
          placeholder: widget.placeholder,
          isRequired: widget.isRequired,
          decoration: widget.decoration,
          brightness: widget.brightness,
          binding: null,
          onChanged: (next) {
            fieldState.didChange(next);
            if (widget.resetValue == null) {
              setState(() => _echoWhenNoReset = List<T>.from(next));
            }
            widget.onChanged?.call(next);
            final b = widget.binding;
            if (b != null && !_unifiedListsEqual(b.value, next)) {
              b.value = List<T>.from(next);
            }
          },
          valueToString: widget.valueToString,
          searchBuilder: widget.searchBuilder,
          itemToWidget: widget.itemToWidget,
          suggestion: widget.suggestion,
          hasSearch: widget.hasSearch,
          searchAutoFocus: widget.searchAutoFocus,
          showClearButton: widget.showClearButton,
          locked: widget.locked,
          validator: null,
          validationOverrideMessage: unifiedFormPickerOverride(fieldState),
        );
      },
    );
  }
}

/// [FormField] + [UnifiedDateField].
class UnifiedFormDateField extends StatefulWidget {
  /// Creates a [Form]-aware date field.
  const UnifiedFormDateField({
    super.key,
    this.decoration,
    this.brightness,
    this.binding,
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
    this.shakeOnError = false,
    this.placeholder,
    this.isRequired = false,
  });

  /// Visual chrome overrides.
  final UnifiedInputDecoration? decoration;

  /// Forces a brightness regardless of the ambient [Theme].
  final UnifiedInputBrightness? brightness;

  /// Optional external state binding.
  final AppInputController<DateTime>? binding;

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

  /// When true, shakes once when validation error appears on this field.
  final bool shakeOnError;

  @override
  State<UnifiedFormDateField> createState() => _UnifiedFormDateFieldState();
}

class _UnifiedFormDateFieldState extends State<UnifiedFormDateField> {
  final GlobalKey<FormFieldState<DateTime?>> _formFieldKey = GlobalKey<FormFieldState<DateTime?>>();
  late DateTime? _echoWhenNoReset;
  DateTime? _cachedResetTarget;

  void _scheduleSyncDisplayWhenCurrentDiffersFromResetTarget() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final resetFn = widget.resetValue;
      if (resetFn == null) return;
      final reset = resetFn();
      final display = widget.value ?? widget.binding?.value;
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
    _echoWhenNoReset = widget.value ?? widget.binding?.value;
    if (widget.resetValue != null) {
      _cachedResetTarget = widget.resetValue!();
      _scheduleSyncDisplayWhenCurrentDiffersFromResetTarget();
    }
  }

  @override
  void didUpdateWidget(covariant UnifiedFormDateField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final resetChanged = widget.resetValue != oldWidget.resetValue;
    final bindingChanged = widget.binding != oldWidget.binding;
    if (resetChanged || bindingChanged) {
      if (widget.resetValue != null) {
        _cachedResetTarget = widget.resetValue!();
        _scheduleSyncDisplayWhenCurrentDiffersFromResetTarget();
      } else {
        final display = widget.value ?? widget.binding?.value;
        if (_echoWhenNoReset != display) {
          setState(() => _echoWhenNoReset = display);
        }
        final s = _formFieldKey.currentState;
        if (s != null && s.value != display) {
          s.didChange(display);
        }
      }
    } else if (widget.resetValue == null) {
      final display = widget.value ?? widget.binding?.value;
      final oldDisplay = oldWidget.value ?? oldWidget.binding?.value;
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
      final display = widget.value ?? widget.binding?.value;
      final oldDisplay = oldWidget.value ?? oldWidget.binding?.value;
      if (display != oldDisplay) {
        final s = _formFieldKey.currentState;
        if (s != null && s.value != display) {
          s.didChange(display);
        }
      }
    }
  }

  void _syncControllerAndBindingFromForm() {
    final dt = _formFieldKey.currentState?.value;
    final b = widget.binding;
    if (b != null && b.value != dt) {
      b.value = dt;
    }
    final c = widget.controller;
    if (c != null) {
      final text = formatUnifiedDateFieldText(dt, widget.valueFormat, granularity: widget.pickerGranularity);
      if (c.text != text) {
        c.text = text;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return UnifiedFormField<DateTime?>(
      formFieldKey: _formFieldKey,
      initialValue: widget.resetValue != null ? _cachedResetTarget : _echoWhenNoReset,
      validator: widget.validator,
      onSaved: widget.onSaved,
      onReset: _syncControllerAndBindingFromForm,
      shakeOnError: widget.shakeOnError,
      builder: (context, fieldState) {
        return UnifiedDateField(
          decoration: widget.decoration,
          brightness: widget.brightness,
          binding: null,
          value: fieldState.value,
          controller: widget.controller,
          focusNode: widget.focusNode,
          placeholder: widget.placeholder,
          isRequired: widget.isRequired,
          validator: (_) => unifiedFormErrorText(fieldState),
          onChanged: (dt) {
            fieldState.didChange(dt);
            if (widget.resetValue == null) {
              setState(() => _echoWhenNoReset = dt);
            }
            widget.onChanged?.call(dt);
            final b = widget.binding;
            if (b != null && b.value != dt) {
              b.value = dt;
            }
          },
          onSubmit: widget.onSubmit,
          min: widget.min,
          max: widget.max,
          valueFormat: widget.valueFormat,
          mode: widget.mode,
          suffixIcon: widget.suffixIcon,
          prefix: widget.prefix,
          prefixIcon: widget.prefixIcon,
          label: widget.label,
          showClearButton: widget.showClearButton,
          readOnly: widget.readOnly,
          autofocus: widget.autofocus,
          textAlign: widget.textAlign,
          showCalendarKindToggle: widget.showCalendarKindToggle,
          pickerGranularity: widget.pickerGranularity,
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
    this.brightness,
    this.binding,
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
  });

  /// Visual chrome overrides.
  final UnifiedInputDecoration? decoration;

  /// Forces a brightness regardless of the ambient [Theme].
  final UnifiedInputBrightness? brightness;

  /// Optional external state binding.
  final AppInputController<DateTimeRange>? binding;

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

  /// When true, shakes once when validation error appears on this field.
  final bool shakeOnError;

  @override
  State<UnifiedFormDateRangeField> createState() => _UnifiedFormDateRangeFieldState();
}

class _UnifiedFormDateRangeFieldState extends State<UnifiedFormDateRangeField> {
  final GlobalKey<FormFieldState<DateTimeRange?>> _formFieldKey = GlobalKey<FormFieldState<DateTimeRange?>>();
  late DateTimeRange? _echoWhenNoReset;
  DateTimeRange? _cachedResetTarget;

  void _scheduleSyncDisplayWhenCurrentDiffersFromResetTarget() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final resetFn = widget.resetValue;
      if (resetFn == null) return;
      final reset = resetFn();
      final display = widget.rangeValue ?? widget.binding?.value;
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
    _echoWhenNoReset = widget.rangeValue ?? widget.binding?.value;
    if (widget.resetValue != null) {
      _cachedResetTarget = widget.resetValue!();
      _scheduleSyncDisplayWhenCurrentDiffersFromResetTarget();
    }
  }

  @override
  void didUpdateWidget(covariant UnifiedFormDateRangeField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final resetChanged = widget.resetValue != oldWidget.resetValue;
    final bindingChanged = widget.binding != oldWidget.binding;
    if (resetChanged || bindingChanged) {
      if (widget.resetValue != null) {
        _cachedResetTarget = widget.resetValue!();
        _scheduleSyncDisplayWhenCurrentDiffersFromResetTarget();
      } else {
        final display = widget.rangeValue ?? widget.binding?.value;
        if (_echoWhenNoReset != display) {
          setState(() => _echoWhenNoReset = display);
        }
        final s = _formFieldKey.currentState;
        if (s != null && s.value != display) {
          s.didChange(display);
        }
      }
    } else if (widget.resetValue == null) {
      final display = widget.rangeValue ?? widget.binding?.value;
      final oldDisplay = oldWidget.rangeValue ?? oldWidget.binding?.value;
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
      final display = widget.rangeValue ?? widget.binding?.value;
      final oldDisplay = oldWidget.rangeValue ?? oldWidget.binding?.value;
      if (display != oldDisplay) {
        final s = _formFieldKey.currentState;
        if (s != null && s.value != display) {
          s.didChange(display);
        }
      }
    }
  }

  void _syncControllerAndBindingFromForm() {
    final r = _formFieldKey.currentState?.value;
    final b = widget.binding;
    if (b != null && b.value != r) {
      b.value = r;
    }
    final c = widget.controller;
    if (c != null) {
      final text = formatUnifiedDateRangeFieldText(r);
      if (c.text != text) {
        c.text = text;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return UnifiedFormField<DateTimeRange?>(
      formFieldKey: _formFieldKey,
      initialValue: widget.resetValue != null ? _cachedResetTarget : _echoWhenNoReset,
      validator: widget.validator,
      onSaved: widget.onSaved,
      onReset: _syncControllerAndBindingFromForm,
      shakeOnError: widget.shakeOnError,
      builder: (context, fieldState) {
        return UnifiedDateRangeField(
          decoration: widget.decoration,
          brightness: widget.brightness,
          binding: null,
          rangeValue: fieldState.value,
          controller: widget.controller,
          label: widget.label,
          placeholder: widget.placeholder,
          isRequired: widget.isRequired,
          validator: (_) => unifiedFormErrorText(fieldState),
          onRangeChanged: (r) {
            fieldState.didChange(r);
            if (widget.resetValue == null) {
              setState(() => _echoWhenNoReset = r);
            }
            widget.onRangeChanged?.call(r);
            final b = widget.binding;
            if (b != null && b.value != r) {
              b.value = r;
            }
          },
          min: widget.min,
          max: widget.max,
          showCalendarKindToggle: widget.showCalendarKindToggle,
          textAlign: widget.textAlign,
        );
      },
    );
  }
}

/// [FormField] + [UnifiedTimeOfDayField].
class UnifiedFormTimeOfDayField extends StatefulWidget {
  /// Creates a [Form]-aware time-of-day field.
  const UnifiedFormTimeOfDayField({
    super.key,
    this.decoration,
    this.brightness,
    this.binding,
    this.value,
    this.resetValue,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.onSubmitted,
    this.locked = false,
    this.timePickerEntryMode = TimePickerEntryMode.dial,
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

  /// Forces a brightness regardless of the ambient [Theme].
  final UnifiedInputBrightness? brightness;

  /// Optional external state binding.
  final AppInputController<TimeOfDay>? binding;

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

  /// Entry mode for the time picker.
  final TimePickerEntryMode timePickerEntryMode;

  /// When true, shakes once when validation error appears on this field.
  final bool shakeOnError;

  @override
  State<UnifiedFormTimeOfDayField> createState() => _UnifiedFormTimeOfDayFieldState();
}

class _UnifiedFormTimeOfDayFieldState extends State<UnifiedFormTimeOfDayField> {
  final GlobalKey<FormFieldState<TimeOfDay?>> _formFieldKey = GlobalKey<FormFieldState<TimeOfDay?>>();
  late TimeOfDay? _echoWhenNoReset;
  TimeOfDay? _cachedResetTarget;

  void _scheduleSyncDisplayWhenCurrentDiffersFromResetTarget() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final resetFn = widget.resetValue;
      if (resetFn == null) return;
      final reset = resetFn();
      final display = widget.value ?? widget.binding?.value;
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
    _echoWhenNoReset = widget.value ?? widget.binding?.value;
    if (widget.resetValue != null) {
      _cachedResetTarget = widget.resetValue!();
      _scheduleSyncDisplayWhenCurrentDiffersFromResetTarget();
    }
  }

  @override
  void didUpdateWidget(covariant UnifiedFormTimeOfDayField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final resetChanged = widget.resetValue != oldWidget.resetValue;
    final bindingChanged = widget.binding != oldWidget.binding;
    if (resetChanged || bindingChanged) {
      if (widget.resetValue != null) {
        _cachedResetTarget = widget.resetValue!();
        _scheduleSyncDisplayWhenCurrentDiffersFromResetTarget();
      } else {
        final display = widget.value ?? widget.binding?.value;
        if (_echoWhenNoReset != display) {
          setState(() => _echoWhenNoReset = display);
        }
        final s = _formFieldKey.currentState;
        if (s != null && s.value != display) {
          s.didChange(display);
        }
      }
    } else if (widget.resetValue == null) {
      final display = widget.value ?? widget.binding?.value;
      final oldDisplay = oldWidget.value ?? oldWidget.binding?.value;
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
      final display = widget.value ?? widget.binding?.value;
      final oldDisplay = oldWidget.value ?? oldWidget.binding?.value;
      if (display != oldDisplay) {
        final s = _formFieldKey.currentState;
        if (s != null && s.value != display) {
          s.didChange(display);
        }
      }
    }
  }

  void _syncBindingFromForm() {
    final b = widget.binding;
    if (b == null) return;
    final v = _formFieldKey.currentState?.value;
    if (b.value != v) {
      b.value = v;
    }
  }

  @override
  Widget build(BuildContext context) {
    return UnifiedFormField<TimeOfDay?>(
      formFieldKey: _formFieldKey,
      initialValue: widget.resetValue != null ? _cachedResetTarget : _echoWhenNoReset,
      validator: widget.validator,
      onSaved: widget.onSaved,
      onReset: _syncBindingFromForm,
      shakeOnError: widget.shakeOnError,
      builder: (context, fieldState) {
        return UnifiedTimeOfDayField(
          decoration: widget.decoration,
          brightness: widget.brightness,
          binding: null,
          value: fieldState.value,
          label: widget.label,
          placeholder: widget.placeholder,
          isRequired: widget.isRequired,
          validator: (_) => unifiedFormErrorText(fieldState),
          onChanged: (t) {
            fieldState.didChange(t);
            if (widget.resetValue == null) {
              setState(() => _echoWhenNoReset = t);
            }
            widget.onChanged?.call(t);
            final b = widget.binding;
            if (b != null && b.value != t) {
              b.value = t;
            }
          },
          onSubmitted: widget.onSubmitted,
          locked: widget.locked,
          timePickerEntryMode: widget.timePickerEntryMode,
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
    this.brightness,
    this.binding,
    this.value,
    this.resetValue,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.onSubmitted,
    this.granularity = UnifiedDurationGranularity.hoursMinutesSeconds,
    this.min,
    this.max,
    this.locked = false,
    this.focusNode,
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

  /// Forces a brightness regardless of the ambient [Theme].
  final UnifiedInputBrightness? brightness;

  /// Optional external state binding.
  final AppInputController<Duration>? binding;

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

  /// Granularity of the duration picker.
  final UnifiedDurationGranularity granularity;

  /// Minimum allowed duration.
  final Duration? min;

  /// Maximum allowed duration.
  final Duration? max;

  /// When true, the field is non-interactive.
  final bool locked;

  /// External focus node.
  final FocusNode? focusNode;

  /// When true, shakes once when validation error appears on this field.
  final bool shakeOnError;

  @override
  State<UnifiedFormDurationField> createState() => _UnifiedFormDurationFieldState();
}

class _UnifiedFormDurationFieldState extends State<UnifiedFormDurationField> {
  final GlobalKey<FormFieldState<Duration?>> _formFieldKey = GlobalKey<FormFieldState<Duration?>>();
  late Duration? _echoWhenNoReset;
  Duration? _cachedResetTarget;

  void _scheduleSyncDisplayWhenCurrentDiffersFromResetTarget() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final resetFn = widget.resetValue;
      if (resetFn == null) return;
      final reset = resetFn();
      final display = widget.value ?? widget.binding?.value;
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
    _echoWhenNoReset = widget.value ?? widget.binding?.value;
    if (widget.resetValue != null) {
      _cachedResetTarget = widget.resetValue!();
      _scheduleSyncDisplayWhenCurrentDiffersFromResetTarget();
    }
  }

  @override
  void didUpdateWidget(covariant UnifiedFormDurationField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final resetChanged = widget.resetValue != oldWidget.resetValue;
    final bindingChanged = widget.binding != oldWidget.binding;
    if (resetChanged || bindingChanged) {
      if (widget.resetValue != null) {
        _cachedResetTarget = widget.resetValue!();
        _scheduleSyncDisplayWhenCurrentDiffersFromResetTarget();
      } else {
        final display = widget.value ?? widget.binding?.value;
        if (_echoWhenNoReset != display) {
          setState(() => _echoWhenNoReset = display);
        }
        final s = _formFieldKey.currentState;
        if (s != null && s.value != display) {
          s.didChange(display);
        }
      }
    } else if (widget.resetValue == null) {
      final display = widget.value ?? widget.binding?.value;
      final oldDisplay = oldWidget.value ?? oldWidget.binding?.value;
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
      final display = widget.value ?? widget.binding?.value;
      final oldDisplay = oldWidget.value ?? oldWidget.binding?.value;
      if (display != oldDisplay) {
        final s = _formFieldKey.currentState;
        if (s != null && s.value != display) {
          s.didChange(display);
        }
      }
    }
  }

  void _syncBindingFromForm() {
    final b = widget.binding;
    if (b == null) return;
    final v = _formFieldKey.currentState?.value;
    if (b.value != v) {
      b.value = v;
    }
  }

  @override
  Widget build(BuildContext context) {
    return UnifiedFormField<Duration?>(
      formFieldKey: _formFieldKey,
      initialValue: widget.resetValue != null ? _cachedResetTarget : _echoWhenNoReset,
      validator: widget.validator,
      onSaved: widget.onSaved,
      onReset: _syncBindingFromForm,
      shakeOnError: widget.shakeOnError,
      builder: (context, fieldState) {
        return UnifiedDurationField(
          decoration: widget.decoration,
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
            widget.onChanged?.call(d);
            final b = widget.binding;
            if (b != null && b.value != d) {
              b.value = d;
            }
          },
          onSubmitted: widget.onSubmitted,
          granularity: widget.granularity,
          min: widget.min,
          max: widget.max,
          locked: widget.locked,
          focusNode: widget.focusNode,
        );
      },
    );
  }
}

/// [FormField] + [UnifiedAsyncPickerField].
class UnifiedFormAsyncPickerField<T> extends StatefulWidget {
  /// Creates a [Form]-aware async single-select picker field.
  const UnifiedFormAsyncPickerField({
    super.key,
    required this.itemProvider,
    required this.label,
    this.decoration,
    this.brightness,
    this.binding,
    this.value,
    this.resetValue,
    this.onChanged,
    this.valueToString,
    this.searchBuilder,
    this.itemToWidget,
    this.suggestion = const [],
    this.hasSearch = true,
    this.searchAutoFocus = false,
    this.showClearButton = true,
    this.locked = false,
    this.validator,
    this.onSaved,
    this.shakeOnError = false,
    this.placeholder,
    this.isRequired = false,
  });

  /// Fetched when the user opens the picker.
  final Future<List<T>> Function() itemProvider;

  /// Label for the field and sheet title fallback.
  final String label;

  /// Hint text shown when empty.
  final String? placeholder;

  /// Whether the field is required. Overrides [UnifiedInputDecoration.requiredField] when set.
  final bool isRequired;

  /// Visual chrome overrides.
  final UnifiedInputDecoration? decoration;

  /// Forces a brightness regardless of the ambient [Theme].
  final UnifiedInputBrightness? brightness;

  /// Optional external state binding.
  final AppInputController<T>? binding;

  /// Direct value when not using [binding].
  final T? value;

  /// When non-null, [FormState.reset] restores `resetValue()` (`T Function()`).
  final UnifiedFormResetValue<T>? resetValue;

  /// Called when the user picks (or clears) a value.
  final ValueChanged<T?>? onChanged;

  /// Renders an item to its display text.
  final String Function(T value)? valueToString;

  /// Custom searchable text per item.
  final String Function(T value)? searchBuilder;

  /// Custom row builder inside the sheet.
  final Widget Function(T value)? itemToWidget;

  /// Suggestion list pinned above the searchable list.
  final List<T> suggestion;

  /// Whether the sheet shows a search field.
  final bool hasSearch;

  /// Autofocus the search field on open.
  final bool searchAutoFocus;

  /// Show a Clear button in the sheet header.
  final bool showClearButton;

  /// When true, the field is non-interactive.
  final bool locked;

  /// Validator passed to the underlying [FormField].
  final FormFieldValidator<T?>? validator;

  /// Called from [FormState.save].
  final FormFieldSetter<T?>? onSaved;

  /// When true, shakes once when validation error appears on this field.
  final bool shakeOnError;

  @override
  State<UnifiedFormAsyncPickerField<T>> createState() => _UnifiedFormAsyncPickerFieldState<T>();
}

class _UnifiedFormAsyncPickerFieldState<T> extends State<UnifiedFormAsyncPickerField<T>> {
  final GlobalKey<FormFieldState<T?>> _formFieldKey = GlobalKey<FormFieldState<T?>>();
  late T? _echoInitialWhenNoReset;
  late T _cachedResetTarget;

  void _scheduleSyncDisplayWhenCurrentDiffersFromResetTarget() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final resetFn = widget.resetValue;
      if (resetFn == null) return;
      final reset = resetFn();
      final display = widget.value ?? widget.binding?.value;
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
    _echoInitialWhenNoReset = widget.value ?? widget.binding?.value;
    if (widget.resetValue != null) {
      _cachedResetTarget = widget.resetValue!();
      _scheduleSyncDisplayWhenCurrentDiffersFromResetTarget();
    }
  }

  @override
  void didUpdateWidget(covariant UnifiedFormAsyncPickerField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final resetChanged = widget.resetValue != oldWidget.resetValue;
    final bindingChanged = widget.binding != oldWidget.binding;
    if (resetChanged || bindingChanged) {
      if (widget.resetValue != null) {
        _cachedResetTarget = widget.resetValue!();
        _scheduleSyncDisplayWhenCurrentDiffersFromResetTarget();
      } else {
        final display = widget.value ?? widget.binding?.value;
        if (_echoInitialWhenNoReset != display) {
          setState(() => _echoInitialWhenNoReset = display);
        }
        final s = _formFieldKey.currentState;
        if (s != null && s.value != display) {
          s.didChange(display);
        }
      }
    } else if (widget.resetValue == null) {
      final display = widget.value ?? widget.binding?.value;
      final oldDisplay = oldWidget.value ?? oldWidget.binding?.value;
      if (display != oldDisplay) {
        if (_echoInitialWhenNoReset != display) {
          setState(() => _echoInitialWhenNoReset = display);
        }
        final s = _formFieldKey.currentState;
        if (s != null && s.value != display) {
          s.didChange(display);
        }
      }
    } else {
      final display = widget.value ?? widget.binding?.value;
      final oldDisplay = oldWidget.value ?? oldWidget.binding?.value;
      if (display != oldDisplay) {
        final s = _formFieldKey.currentState;
        if (s != null && s.value != display) {
          s.didChange(display);
        }
      }
    }
  }

  void _syncBindingFromForm() {
    final b = widget.binding;
    if (b == null) return;
    final v = _formFieldKey.currentState?.value;
    if (b.value != v) {
      b.value = v;
    }
  }

  @override
  Widget build(BuildContext context) {
    return UnifiedFormField<T?>(
      formFieldKey: _formFieldKey,
      initialValue: widget.resetValue != null ? _cachedResetTarget : _echoInitialWhenNoReset,
      validator: widget.validator,
      onSaved: widget.onSaved,
      onReset: _syncBindingFromForm,
      shakeOnError: widget.shakeOnError,
      builder: (context, fieldState) {
        return UnifiedAsyncPickerField<T>(
          itemProvider: widget.itemProvider,
          label: widget.label,
          placeholder: widget.placeholder,
          isRequired: widget.isRequired,
          decoration: widget.decoration,
          brightness: widget.brightness,
          binding: null,
          value: fieldState.value,
          onChanged: (v) {
            fieldState.didChange(v);
            if (widget.resetValue == null) {
              setState(() => _echoInitialWhenNoReset = v);
            }
            widget.onChanged?.call(v);
            final b = widget.binding;
            if (b != null && b.value != v) {
              b.value = v;
            }
          },
          valueToString: widget.valueToString,
          searchBuilder: widget.searchBuilder,
          itemToWidget: widget.itemToWidget,
          suggestion: widget.suggestion,
          hasSearch: widget.hasSearch,
          searchAutoFocus: widget.searchAutoFocus,
          showClearButton: widget.showClearButton,
          locked: widget.locked,
          validator: null,
          validationOverrideMessage: unifiedFormPickerOverride(fieldState),
        );
      },
    );
  }
}

/// [FormField] + [UnifiedAsyncMultiPickerField].
class UnifiedFormAsyncMultiPickerField<T> extends StatefulWidget {
  /// Creates a [Form]-aware async multi-select picker field.
  const UnifiedFormAsyncMultiPickerField({
    super.key,
    required this.itemProvider,
    required this.label,
    required this.values,
    this.resetValue,
    this.decoration,
    this.brightness,
    this.binding,
    this.onChanged,
    this.valueToString,
    this.searchBuilder,
    this.itemToWidget,
    this.suggestion = const [],
    this.hasSearch = true,
    this.searchAutoFocus = false,
    this.showClearButton = true,
    this.locked = false,
    this.validator,
    this.onSaved,
    this.shakeOnError = false,
    this.placeholder,
    this.isRequired = false,
  });

  /// Fetched when the user opens the picker.
  final Future<List<T>> Function() itemProvider;

  /// Label for the field and sheet title fallback.
  final String label;

  /// Current selection.
  final List<T> values;

  /// Hint text shown when empty.
  final String? placeholder;

  /// Whether the field is required. Overrides [UnifiedInputDecoration.requiredField] when set.
  final bool isRequired;

  /// When non-null, [FormState.reset] restores `resetValue()` (e.g. `() => const []` to clear).
  final UnifiedFormResetValue<List<T>>? resetValue;

  /// Visual chrome overrides.
  final UnifiedInputDecoration? decoration;

  /// Forces a brightness regardless of the ambient [Theme].
  final UnifiedInputBrightness? brightness;

  /// Optional external state binding.
  final AppInputController<List<T>>? binding;

  /// Called when the selection changes.
  final ValueChanged<List<T>>? onChanged;

  /// Renders an item to its display text.
  final String Function(T value)? valueToString;

  /// Custom searchable text per item.
  final String Function(T value)? searchBuilder;

  /// Custom row builder inside the sheet.
  final Widget Function(T value)? itemToWidget;

  /// Suggestion list pinned above the searchable list.
  final List<T> suggestion;

  /// Whether the sheet shows a search field.
  final bool hasSearch;

  /// Autofocus the search field on open.
  final bool searchAutoFocus;

  /// Show a Clear button in the sheet header.
  final bool showClearButton;

  /// When true, the field is non-interactive.
  final bool locked;

  /// Validator passed to the underlying [FormField].
  final FormFieldValidator<List<T>>? validator;

  /// Called from [FormState.save].
  final FormFieldSetter<List<T>>? onSaved;

  /// When true, shakes once when validation error appears on this field.
  final bool shakeOnError;

  @override
  State<UnifiedFormAsyncMultiPickerField<T>> createState() => _UnifiedFormAsyncMultiPickerFieldState<T>();
}

class _UnifiedFormAsyncMultiPickerFieldState<T> extends State<UnifiedFormAsyncMultiPickerField<T>> {
  final GlobalKey<FormFieldState<List<T>>> _formFieldKey = GlobalKey<FormFieldState<List<T>>>();
  late List<T> _echoWhenNoReset;
  late List<T> _frozenResetList;

  List<T> _displayList() => List<T>.from(widget.binding?.value ?? widget.values);

  void _scheduleSyncDisplayWhenCurrentDiffersFromResetTarget() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final resetFn = widget.resetValue;
      if (resetFn == null) return;
      final reset = resetFn();
      final display = _displayList();
      if (!_unifiedListsEqual(reset, display)) {
        final s = _formFieldKey.currentState;
        if (s != null && !_unifiedListsEqual(s.value ?? [], display)) {
          s.didChange(display);
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _echoWhenNoReset = _displayList();
    if (widget.resetValue != null) {
      _frozenResetList = List<T>.from(widget.resetValue!());
      _scheduleSyncDisplayWhenCurrentDiffersFromResetTarget();
    } else {
      _frozenResetList = [];
    }
  }

  @override
  void didUpdateWidget(covariant UnifiedFormAsyncMultiPickerField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final resetFnChanged = !identical(widget.resetValue, oldWidget.resetValue);
    final resetPayloadChanged = widget.resetValue != null &&
        oldWidget.resetValue != null &&
        !_unifiedListsEqual(widget.resetValue!(), oldWidget.resetValue!());
    final bindingChanged = widget.binding != oldWidget.binding;
    if (resetFnChanged || resetPayloadChanged || bindingChanged) {
      if (widget.resetValue != null) {
        if (resetFnChanged || resetPayloadChanged) {
          _frozenResetList = List<T>.from(widget.resetValue!());
        }
        _scheduleSyncDisplayWhenCurrentDiffersFromResetTarget();
      } else {
        final display = _displayList();
        if (!_unifiedListsEqual(_echoWhenNoReset, display)) {
          setState(() => _echoWhenNoReset = List<T>.from(display));
        }
        final s = _formFieldKey.currentState;
        if (s != null && !_unifiedListsEqual(s.value ?? [], display)) {
          s.didChange(display);
        }
      }
    } else if (widget.resetValue == null) {
      final display = _displayList();
      final oldDisplay = List<T>.from(oldWidget.binding?.value ?? oldWidget.values);
      if (!_unifiedListsEqual(display, oldDisplay)) {
        if (!_unifiedListsEqual(_echoWhenNoReset, display)) {
          setState(() => _echoWhenNoReset = List<T>.from(display));
        }
        final s = _formFieldKey.currentState;
        if (s != null && !_unifiedListsEqual(s.value ?? [], display)) {
          s.didChange(display);
        }
      }
    } else {
      final display = _displayList();
      final oldDisplay = List<T>.from(oldWidget.binding?.value ?? oldWidget.values);
      if (!_unifiedListsEqual(display, oldDisplay)) {
        final s = _formFieldKey.currentState;
        if (s != null && !_unifiedListsEqual(s.value ?? [], display)) {
          s.didChange(display);
        }
      }
    }
  }

  void _syncBindingFromForm() {
    final b = widget.binding;
    if (b == null) return;
    final v = _formFieldKey.currentState?.value ?? <T>[];
    if (!_unifiedListsEqual(b.value, v)) {
      b.value = List<T>.from(v);
    }
  }

  @override
  Widget build(BuildContext context) {
    return UnifiedFormField<List<T>>(
      formFieldKey: _formFieldKey,
      initialValue: widget.resetValue != null ? _frozenResetList : _echoWhenNoReset,
      validator: widget.validator,
      onSaved: widget.onSaved,
      onReset: _syncBindingFromForm,
      shakeOnError: widget.shakeOnError,
      builder: (context, fieldState) {
        return UnifiedAsyncMultiPickerField<T>(
          itemProvider: widget.itemProvider,
          label: widget.label,
          values: fieldState.value ?? [],
          placeholder: widget.placeholder,
          isRequired: widget.isRequired,
          decoration: widget.decoration,
          brightness: widget.brightness,
          binding: null,
          onChanged: (next) {
            fieldState.didChange(next);
            if (widget.resetValue == null) {
              setState(() => _echoWhenNoReset = List<T>.from(next));
            }
            widget.onChanged?.call(next);
            final b = widget.binding;
            if (b != null && !_unifiedListsEqual(b.value, next)) {
              b.value = List<T>.from(next);
            }
          },
          valueToString: widget.valueToString,
          searchBuilder: widget.searchBuilder,
          itemToWidget: widget.itemToWidget,
          suggestion: widget.suggestion,
          hasSearch: widget.hasSearch,
          searchAutoFocus: widget.searchAutoFocus,
          showClearButton: widget.showClearButton,
          locked: widget.locked,
          validator: null,
          validationOverrideMessage: unifiedFormPickerOverride(fieldState),
        );
      },
    );
  }
}

/// [FormField] + [UnifiedNumberField] (string snapshot matches [TextEditingController] text).
class UnifiedFormNumberField extends StatefulWidget {
  /// Creates a [Form]-aware number field.
  const UnifiedFormNumberField({
    super.key,
    this.decoration,
    this.brightness,
    this.controller,
    this.focusNode,
    this.binding,
    this.initialText = '',
    this.resetValue,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.onSubmitted,
    this.disabled = false,
    this.readOnly = false,
    this.autofocus = false,
    this.allowDecimals = false,
    this.step = 1,
    this.min,
    this.max,
    this.fractionDigits,
    this.textInputAction,
    this.label,
    this.shakeOnError = false,
    this.placeholder,
    this.isRequired = false,
  });

  /// Hint text shown when empty.
  final String? placeholder;

  /// Whether the field is required. Overrides [UnifiedInputDecoration.requiredField] when set.
  final bool isRequired;

  /// Visual chrome overrides.
  final UnifiedInputDecoration? decoration;

  /// Forces a brightness regardless of the ambient [Theme].
  final UnifiedInputBrightness? brightness;

  /// External [TextEditingController].
  final TextEditingController? controller;

  /// External focus node.
  final FocusNode? focusNode;

  /// Two-way binding for the displayed text.
  final AppInputController<String>? binding;

  /// Used when [controller] is null to seed the field.
  final String initialText;

  /// When non-null, [FormState.reset] restores `resetValue()` (e.g. `() => ''` to clear).
  final UnifiedFormResetValue<String>? resetValue;

  /// Validator passed to the underlying [FormField].
  final FormFieldValidator<String>? validator;

  /// Called from [FormState.save].
  final FormFieldSetter<String>? onSaved;

  /// Called when the numeric value changes.
  final ValueChanged<num>? onChanged;

  /// Called on keyboard submit.
  final ValueChanged<String>? onSubmitted;

  /// When true, the field is non-editable.
  final bool disabled;

  /// When true, the field rejects edits.
  final bool readOnly;

  /// Autofocus the field on first build.
  final bool autofocus;

  /// When true, allow decimal values in the field.
  final bool allowDecimals;

  /// Step amount used by the +/- buttons.
  final num step;

  /// Minimum allowed value.
  final num? min;

  /// Maximum allowed value.
  final num? max;

  /// Number of decimal digits to render.
  final int? fractionDigits;

  /// Keyboard action button.
  final TextInputAction? textInputAction;

  /// Field label.
  final String? label;

  /// When true, shakes once when validation error appears on this field.
  final bool shakeOnError;

  @override
  State<UnifiedFormNumberField> createState() => _UnifiedFormNumberFieldState();
}

class _UnifiedFormNumberFieldState extends State<UnifiedFormNumberField> {
  late TextEditingController _effectiveController;
  bool _ownsController = false;
  final GlobalKey<FormFieldState<String>> _formFieldKey = GlobalKey<FormFieldState<String>>();

  /// Stable [FormField.initialValue] for [FormState.reset]; not live controller text each build.
  late String _formResetBaseline;

  void _recomputeResetBaseline() {
    if (widget.resetValue != null) {
      _formResetBaseline = widget.resetValue!();
    } else {
      _formResetBaseline = _effectiveController.text;
    }
  }

  void _bumpBaselineFromControllerIfNoResetValue() {
    if (widget.resetValue != null) return;
    final t = _effectiveController.text;
    if (t == _formResetBaseline) return;
    setState(() => _formResetBaseline = t);
  }

  @override
  void initState() {
    super.initState();
    _effectiveController = widget.controller ?? TextEditingController(text: widget.binding?.value ?? widget.initialText);
    _ownsController = widget.controller == null;
    _recomputeResetBaseline();
    widget.binding?.addListener(_onBindingChanged);
  }

  @override
  void didUpdateWidget(covariant UnifiedFormNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (_ownsController) _effectiveController.dispose();
      _effectiveController = widget.controller ?? TextEditingController(text: widget.binding?.value ?? widget.initialText);
      _ownsController = widget.controller == null;
      _formFieldKey.currentState?.didChange(_effectiveController.text);
    }
    if (oldWidget.binding != widget.binding) {
      oldWidget.binding?.removeListener(_onBindingChanged);
      widget.binding?.addListener(_onBindingChanged);
    }
    if (widget.binding != oldWidget.binding ||
        widget.controller != oldWidget.controller ||
        widget.initialText != oldWidget.initialText ||
        !identical(widget.resetValue, oldWidget.resetValue)) {
      _recomputeResetBaseline();
    }
  }

  void _onBindingChanged() {
    final v = widget.binding?.value ?? '';
    if (v == _effectiveController.text) return;
    _effectiveController.text = v;
    _formFieldKey.currentState?.didChange(v);
    if (widget.resetValue == null) {
      _formResetBaseline = v;
    }
    setState(() {});
  }

  void _syncControllerAndBindingFromForm() {
    final v = _formFieldKey.currentState?.value ?? '';
    if (_effectiveController.text != v) {
      _effectiveController.text = v;
    }
    final b = widget.binding;
    if (b != null && b.value != v) {
      b.value = v;
    }
  }

  @override
  void dispose() {
    widget.binding?.removeListener(_onBindingChanged);
    if (_ownsController) _effectiveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return UnifiedFormField<String>(
      formFieldKey: _formFieldKey,
      initialValue: _formResetBaseline,
      validator: widget.validator,
      onSaved: widget.onSaved,
      onReset: _syncControllerAndBindingFromForm,
      shakeOnError: widget.shakeOnError,
      builder: (context, fieldState) {
        return UnifiedNumberField(
          decoration: widget.decoration,
          brightness: widget.brightness,
          controller: _effectiveController,
          focusNode: widget.focusNode,
          placeholder: widget.placeholder,
          isRequired: widget.isRequired,
          validator: (_) => unifiedFormErrorText(fieldState),
          onChanged: (n) {
            fieldState.didChange(_effectiveController.text);
            _bumpBaselineFromControllerIfNoResetValue();
            widget.onChanged?.call(n);
            final b = widget.binding;
            final s = _effectiveController.text;
            if (b != null && b.value != s) {
              b.value = s;
            }
          },
          onSubmitted: widget.onSubmitted,
          disabled: widget.disabled,
          readOnly: widget.readOnly,
          autofocus: widget.autofocus,
          allowDecimals: widget.allowDecimals,
          step: widget.step,
          min: widget.min,
          max: widget.max,
          fractionDigits: widget.fractionDigits,
          textInputAction: widget.textInputAction,
          label: widget.label,
        );
      },
    );
  }
}
