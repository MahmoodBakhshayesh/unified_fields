part of 'unified_form_more_fields.dart';

/// [FormField] + [UnifiedAsyncQueryPicker].
class UnifiedFormAsyncQueryPicker<T> extends StatefulWidget {
  /// Creates a [Form]-aware async query picker field.
  const UnifiedFormAsyncQueryPicker({
    super.key,
    required this.queryFetcher,
    required this.label,
    this.queryThreshold = 3,
    this.queryDebounce = const Duration(milliseconds: 300),
    this.queryPromptMessage,
    this.resetValue,
    this.decoration,
    this.decorationSet,
    this.brightness,
    this.binding,
    this.fieldController,
    this.onChanged,
    this.onSaved,
    this.valueToString,
    this.itemToWidget,
    this.locked = false,
    this.isDisabled = false,
    this.validator,
    this.placeholder,
    this.isRequired = false,
    this.shakeOnError = false,
    this.pickerSheetStyle,
    this.pickerSheetBackgroundColor,
    this.pickerHeaderStyle,
    this.pickerSheetModalSettings,
    this.searchAutoFocus = true,
    this.showClearButton = false,
  });

  /// Remote search: `query` â†’ matching items.
  final UnifiedAsyncQueryFetcher<T> queryFetcher;

  /// Minimum characters before [queryFetcher] is called.
  final int queryThreshold;

  /// Debounce between keystrokes and fetch.
  final Duration queryDebounce;

  /// Sheet hint when the query is too short (defaults to [UnifiedFieldsStrings.asyncQueryTypeToFetch]).
  final String? queryPromptMessage;

  /// Label for the field and sheet title fallback.
  final String label;

  /// Hint text shown when empty.
  final String? placeholder;

  /// When non-null, [FormState.reset] restores `resetValue()` (`T? Function()`).
  final UnifiedFormResetValue<T?>? resetValue;

  /// Visual chrome overrides.
  final UnifiedInputDecoration? decoration;

  /// Per-state decorations (focus, error, valid, locked, disabled, â€¦).
  final UnifiedInputDecorationSet? decorationSet;

  /// Forces a brightness regardless of the ambient [Theme].
  final UnifiedInputBrightness? brightness;

  /// Optional external state binding.
  final UnifiedInputPicker<T>? binding;

  /// Preferred imperative handle; syncs with [binding] and [FormField] on change.
  final UnifiedAsyncQueryPickerFieldController<T>? fieldController;

  /// Called when the user picks (or clears) a value.
  final ValueChanged<T?>? onChanged;

  /// Called when the form is saved.
  final FormFieldSetter<T?>? onSaved;

  /// Form-level validation.
  final FormFieldValidator<T?>? validator;

  /// Renders an item to its display text.
  final String Function(T value)? valueToString;

  /// Custom row widget for each result in the sheet.
  final Widget Function(T value)? itemToWidget;

  /// When true, the field cannot be edited or opened.
  final bool locked;

  /// When true, the field is non-interactive.
  final bool isDisabled;

  /// Whether the field is required. Overrides [UnifiedInputDecoration.requiredField] when set.
  final bool isRequired;

  /// Shakes the field when validation fails.
  final bool shakeOnError;

  /// Local picker sheet chrome; overrides theme when set.
  final UnifiedPickerSheetStyle? pickerSheetStyle;

  /// Sheet background override (wins over [pickerSheetStyle] and theme).
  final Color? pickerSheetBackgroundColor;

  /// Header override (wins over [pickerSheetStyle] and theme).
  final UnifiedInputPickerHeaderStyle? pickerHeaderStyle;

  /// Modal flags override (`isScrollControlled`, `isDismissible`, â€¦).
  final UnifiedPickerSheetModalSettings? pickerSheetModalSettings;

  /// Whether the sheet search field auto-focuses on open.
  final bool searchAutoFocus;

  /// Whether the sheet shows a clear-selection control.
  final bool showClearButton;

  @override
  State<UnifiedFormAsyncQueryPicker<T>> createState() =>
      _UnifiedFormAsyncQueryPickerState<T>();
}

class _UnifiedFormAsyncQueryPickerState<T>
    extends State<UnifiedFormAsyncQueryPicker<T>> {
  final GlobalKey<FormFieldState<T?>> _formFieldKey =
      GlobalKey<FormFieldState<T?>>();
  late T? _echoInitialWhenNoReset;
  late T? _cachedResetTarget;

  T? _displayValue() => unifiedEffectiveValue(
    fieldController: widget.fieldController,
    binding: widget.binding,
    direct: null,
  );

  @override
  void initState() {
    super.initState();
    _echoInitialWhenNoReset = _displayValue();
    if (widget.resetValue != null) {
      _cachedResetTarget = widget.resetValue!();
    }
    syncWidgetFormValidatorToFieldController<T?>(
      widget.fieldController,
      widget.validator,
    );
    widget.binding?.addListener(_onBindingChanged);
    widget.fieldController?.addListener(_onFieldControllerChanged);
  }

  @override
  void didUpdateWidget(covariant UnifiedFormAsyncQueryPicker<T> oldWidget) {
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
      syncWidgetFormValidatorToFieldController<T?>(
        widget.fieldController,
        widget.validator,
      );
    }
    if (widget.resetValue != null &&
        (widget.resetValue != oldWidget.resetValue ||
            widget.binding != oldWidget.binding ||
            widget.fieldController != oldWidget.fieldController)) {
      _cachedResetTarget = widget.resetValue!();
    }
  }

  void _onBindingChanged() => _applyExternalValue(widget.binding?.value);

  void _onFieldControllerChanged() =>
      _applyExternalValue(widget.fieldController?.value);

  void _applyExternalValue(T? display) {
    syncFormFieldFromExternalValue<T?>(
      formState: _formFieldKey.currentState,
      value: display,
      fieldController: widget.fieldController,
    );
    if (widget.resetValue == null && _echoInitialWhenNoReset != display) {
      setState(() => _echoInitialWhenNoReset = display);
    } else {
      setState(() {});
    }
    final formState = _formFieldKey.currentState;
    if (formState != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unifiedFormClearErrorIfValid(formState);
      });
    }
  }

  @override
  void dispose() {
    widget.binding?.removeListener(_onBindingChanged);
    widget.fieldController?.removeListener(_onFieldControllerChanged);
    super.dispose();
  }

  void _syncBindingFromForm() {
    syncUnifiedFieldValue<T?>(
      value: _formFieldKey.currentState?.value,
      binding: widget.binding,
      fieldController: widget.fieldController,
    );
  }

  @override
  Widget build(BuildContext context) {
    syncWidgetFormValidatorToFieldController<T?>(
      widget.fieldController,
      widget.validator,
    );
    return UnifiedFormField<T?>(
      formFieldKey: _formFieldKey,
      initialValue: widget.resetValue != null
          ? _cachedResetTarget
          : _echoInitialWhenNoReset,
      validator: widget.validator,
      onSaved: widget.onSaved,
      onReset: _syncBindingFromForm,
      shakeOnError: widget.shakeOnError,
      builder: (context, fieldState) {
        return UnifiedAsyncQueryPicker<T>(
          queryFetcher: widget.queryFetcher,
          queryThreshold: widget.queryThreshold,
          queryDebounce: widget.queryDebounce,
          queryPromptMessage: widget.queryPromptMessage,
          label: widget.label,
          placeholder: widget.placeholder,
          isRequired: widget.isRequired,
          decoration: widget.decoration,
          decorationSet: widget.decorationSet,
          brightness: widget.brightness,
          fieldController: widget.fieldController,
          binding: widget.binding,
          value: widget.fieldController == null ? fieldState.value : null,
          onChanged: (v) {
            fieldState.didChange(v);
            if (widget.resetValue == null) {
              setState(() => _echoInitialWhenNoReset = v);
            }
            syncUnifiedFieldValue<T?>(
              value: v,
              onChanged: widget.onChanged,
              binding: widget.binding,
              fieldController: widget.fieldController,
              formFieldState: fieldState,
            );
          },
          valueToString: widget.valueToString,
          itemToWidget: widget.itemToWidget,
          locked: widget.locked,
          isDisabled: widget.isDisabled,
          validator: null,
          validationOverrideMessage: unifiedFormPickerOverride(fieldState),
          pickerSheetStyle: widget.pickerSheetStyle,
          pickerSheetBackgroundColor: widget.pickerSheetBackgroundColor,
          pickerHeaderStyle: widget.pickerHeaderStyle,
          pickerSheetModalSettings: widget.pickerSheetModalSettings,
          searchAutoFocus: widget.searchAutoFocus,
          showClearButton: widget.showClearButton,
        );
      },
    );
  }
}

/// [FormField] + [UnifiedAsyncQueryMultiPicker].
class UnifiedFormAsyncQueryMultiPicker<T> extends StatefulWidget {
  /// Creates a [Form]-aware async query multi-picker field.
  const UnifiedFormAsyncQueryMultiPicker({
    super.key,
    required this.queryFetcher,
    required this.label,
    required this.values,
    this.queryThreshold = 3,
    this.queryDebounce = const Duration(milliseconds: 300),
    this.queryPromptMessage,
    this.resetValue,
    this.decoration,
    this.decorationSet,
    this.brightness,
    this.binding,
    this.fieldController,
    this.onChanged,
    this.onSaved,
    this.valueToString,
    this.itemToWidget,
    this.locked = false,
    this.isDisabled = false,
    this.validator,
    this.placeholder,
    this.isRequired = false,
    this.shakeOnError = false,
    this.pickerSheetStyle,
    this.pickerSheetBackgroundColor,
    this.pickerHeaderStyle,
    this.pickerSheetModalSettings,
    this.searchAutoFocus = true,
    this.showClearButton = true,
  });

  /// Remote search: `query` â†’ matching items.
  final UnifiedAsyncQueryFetcher<T> queryFetcher;

  /// Minimum characters before [queryFetcher] is called.
  final int queryThreshold;

  /// Debounce between keystrokes and fetch.
  final Duration queryDebounce;

  /// Sheet hint when the query is too short (defaults to [UnifiedFieldsStrings.asyncQueryTypeToFetch]).
  final String? queryPromptMessage;

  /// Label for the field and sheet title fallback.
  final String label;

  /// Current selection when not using [fieldController].
  final List<T> values;

  /// Hint text shown when empty.
  final String? placeholder;

  /// When non-null, [FormState.reset] restores `resetValue()` (e.g. `() => const []`).
  final UnifiedFormResetValue<List<T>>? resetValue;

  /// Visual chrome overrides.
  final UnifiedInputDecoration? decoration;

  /// Per-state decorations (focus, error, valid, locked, disabled, â€¦).
  final UnifiedInputDecorationSet? decorationSet;

  /// Forces a brightness regardless of the ambient [Theme].
  final UnifiedInputBrightness? brightness;

  /// Optional external state binding.
  final UnifiedInputPicker<List<T>>? binding;

  /// Preferred imperative handle; syncs with [binding] and [FormField] on change.
  final UnifiedAsyncQueryMultiPickerFieldController<T>? fieldController;

  /// Called when the user confirms (or clears) the selection.
  final ValueChanged<List<T>>? onChanged;

  /// Called when the form is saved.
  final FormFieldSetter<List<T>>? onSaved;

  /// Form-level validation.
  final FormFieldValidator<List<T>>? validator;

  /// Renders an item to its display text.
  final String Function(T value)? valueToString;

  /// Custom row widget for each result in the sheet.
  final Widget Function(T value)? itemToWidget;

  /// When true, the field cannot be edited or opened.
  final bool locked;

  /// When true, the field is non-interactive.
  final bool isDisabled;

  /// Whether the field is required. Overrides [UnifiedInputDecoration.requiredField] when set.
  final bool isRequired;

  /// Shakes the field when validation fails.
  final bool shakeOnError;

  /// Local picker sheet chrome; overrides theme when set.
  final UnifiedPickerSheetStyle? pickerSheetStyle;

  /// Sheet background override (wins over [pickerSheetStyle] and theme).
  final Color? pickerSheetBackgroundColor;

  /// Header override (wins over [pickerSheetStyle] and theme).
  final UnifiedInputPickerHeaderStyle? pickerHeaderStyle;

  /// Modal flags override (`isScrollControlled`, `isDismissible`, â€¦).
  final UnifiedPickerSheetModalSettings? pickerSheetModalSettings;

  /// Whether the sheet search field auto-focuses on open.
  final bool searchAutoFocus;

  /// Whether the sheet shows a clear-selection control in the header.
  final bool showClearButton;

  @override
  State<UnifiedFormAsyncQueryMultiPicker<T>> createState() =>
      _UnifiedFormAsyncQueryMultiPickerState<T>();
}

class _UnifiedFormAsyncQueryMultiPickerState<T>
    extends State<UnifiedFormAsyncQueryMultiPicker<T>> {
  final GlobalKey<FormFieldState<List<T>>> _formFieldKey =
      GlobalKey<FormFieldState<List<T>>>();
  late List<T> _echoWhenNoReset;
  late List<T> _frozenResetList;

  List<T> _displayList() => List<T>.from(
    unifiedEffectiveListValue(
      fieldController: widget.fieldController,
      binding: widget.binding,
      direct: widget.values,
    ),
  );

  @override
  void initState() {
    super.initState();
    _echoWhenNoReset = _displayList();
    if (widget.resetValue != null) {
      _frozenResetList = List<T>.from(widget.resetValue!());
    } else {
      _frozenResetList = [];
    }
    syncWidgetFormValidatorToFieldController<List<T>>(
      widget.fieldController,
      widget.validator,
    );
    widget.binding?.addListener(_onBindingChanged);
    widget.fieldController?.addListener(_onFieldControllerChanged);
  }

  @override
  void didUpdateWidget(covariant UnifiedFormAsyncQueryMultiPicker<T> oldWidget) {
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
      syncWidgetFormValidatorToFieldController<List<T>>(
        widget.fieldController,
        widget.validator,
      );
    }
    if (widget.resetValue != null &&
        (widget.resetValue != oldWidget.resetValue ||
            widget.binding != oldWidget.binding ||
            widget.fieldController != oldWidget.fieldController)) {
      _frozenResetList = List<T>.from(widget.resetValue!());
    }
  }

  void _onBindingChanged() =>
      _applyExternalList(List<T>.from(widget.binding?.value ?? const []));

  void _onFieldControllerChanged() =>
      _applyExternalList(List<T>.from(widget.fieldController?.value ?? const []));

  void _applyExternalList(List<T> display) {
    syncFormFieldFromExternalList<T>(
      formState: _formFieldKey.currentState,
      value: display,
      fieldController: widget.fieldController,
    );
    if (widget.resetValue == null &&
        !_unifiedListsEqual(_echoWhenNoReset, display)) {
      setState(() => _echoWhenNoReset = List<T>.from(display));
    } else {
      setState(() {});
    }
    final formState = _formFieldKey.currentState;
    if (formState != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unifiedFormClearErrorIfValid(formState);
      });
    }
  }

  @override
  void dispose() {
    widget.binding?.removeListener(_onBindingChanged);
    widget.fieldController?.removeListener(_onFieldControllerChanged);
    super.dispose();
  }

  void _syncBindingFromForm() {
    final v = _formFieldKey.currentState?.value ?? <T>[];
    syncUnifiedFieldListValue<T>(
      value: List<T>.from(v),
      binding: widget.binding,
      fieldController: widget.fieldController,
    );
  }

  @override
  Widget build(BuildContext context) {
    syncWidgetFormValidatorToFieldController<List<T>>(
      widget.fieldController,
      widget.validator,
    );
    return UnifiedFormField<List<T>>(
      formFieldKey: _formFieldKey,
      initialValue: widget.resetValue != null
          ? _frozenResetList
          : _echoWhenNoReset,
      validator: widget.validator,
      onSaved: widget.onSaved,
      onReset: _syncBindingFromForm,
      shakeOnError: widget.shakeOnError,
      builder: (context, fieldState) {
        return UnifiedAsyncQueryMultiPicker<T>(
          queryFetcher: widget.queryFetcher,
          queryThreshold: widget.queryThreshold,
          queryDebounce: widget.queryDebounce,
          queryPromptMessage: widget.queryPromptMessage,
          label: widget.label,
          placeholder: widget.placeholder,
          isRequired: widget.isRequired,
          decoration: widget.decoration,
          decorationSet: widget.decorationSet,
          brightness: widget.brightness,
          fieldController: widget.fieldController,
          binding: widget.binding,
          values: widget.fieldController == null
              ? (fieldState.value ?? [])
              : const [],
          onChanged: (next) {
            fieldState.didChange(next);
            if (widget.resetValue == null) {
              setState(() => _echoWhenNoReset = List<T>.from(next));
            }
            syncUnifiedFieldListValue<T>(
              value: next,
              onChanged: widget.onChanged,
              binding: widget.binding,
              fieldController: widget.fieldController,
              formFieldState: fieldState,
            );
          },
          valueToString: widget.valueToString,
          itemToWidget: widget.itemToWidget,
          locked: widget.locked,
          isDisabled: widget.isDisabled,
          validator: null,
          validationOverrideMessage: unifiedFormPickerOverride(fieldState),
          pickerSheetStyle: widget.pickerSheetStyle,
          pickerSheetBackgroundColor: widget.pickerSheetBackgroundColor,
          pickerHeaderStyle: widget.pickerHeaderStyle,
          pickerSheetModalSettings: widget.pickerSheetModalSettings,
          searchAutoFocus: widget.searchAutoFocus,
          showClearButton: widget.showClearButton,
        );
      },
    );
  }
}
