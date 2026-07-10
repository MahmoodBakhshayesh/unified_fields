part of 'unified_form_more_fields.dart';

/// [FormField] + [UnifiedAsyncPickerField].
class UnifiedFormAsyncPickerField<T> extends StatefulWidget {
  /// Creates a [Form]-aware async single-select picker field.
  const UnifiedFormAsyncPickerField({
    super.key,
    required this.itemProvider,
    required this.label,
    this.decoration,
    this.decorationSet,
    this.brightness,
    this.binding,
    this.fieldController,
    this.value,
    this.resetValue,
    this.onChanged,
    this.valueToString,
    this.searchBuilder,
    this.itemToWidget,
    this.gridItemBuilder,
    this.gridDelegate,
    this.suggestion = const [],
    this.hasSearch = true,
    this.searchAutoFocus = false,
    this.showClearButton = true,
    this.locked = false,
    this.isDisabled = false,
    this.validator,
    this.onSaved,
    this.shakeOnError = false,
    this.placeholder,
    this.isRequired = false,
    this.pickerSheetStyle,
    this.pickerSheetBackgroundColor,
    this.pickerHeaderStyle,
    this.pickerSheetModalSettings,
  });

  /// Fetched when the user opens the picker.
  final Future<List<T>> Function() itemProvider;

  /// Label for the field and sheet title fallback.
  final String label;

  /// Hint text shown when empty.
  final String? placeholder;

  /// Whether the field is required. Overrides [UnifiedInputDecoration.requiredField] when set.
  final bool isRequired;

  /// Local picker sheet chrome; overrides theme when set.
  final UnifiedPickerSheetStyle? pickerSheetStyle;

  /// Sheet background override (wins over [pickerSheetStyle] and theme).
  final Color? pickerSheetBackgroundColor;

  /// Header override (wins over [pickerSheetStyle] and theme).
  final UnifiedInputPickerHeaderStyle? pickerHeaderStyle;

  /// Modal flags override (`isScrollControlled`, `isDismissible`, â€¦).
  final UnifiedPickerSheetModalSettings? pickerSheetModalSettings;

  /// Visual chrome overrides.
  final UnifiedInputDecoration? decoration;

  /// Per-state decorations (focus, error, valid, locked, disabled, â€¦).
  final UnifiedInputDecorationSet? decorationSet;

  /// Forces a brightness regardless of the ambient [Theme].
  final UnifiedInputBrightness? brightness;

  /// Optional external state binding.
  final UnifiedInputPicker<T>? binding;

  /// Preferred imperative handle; syncs with [binding] and [FormField] on change.
  final UnifiedAsyncPickerFieldController<T>? fieldController;

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

  /// Custom row builder inside the sheet (list layout).
  final Widget Function(T value)? itemToWidget;

  /// Custom grid tile builder; when set, the sheet uses a [GridView].
  final UnifiedPickerGridItemBuilder<T>? gridItemBuilder;

  /// Grid layout when [gridItemBuilder] is set. Defaults to [unifiedPickerDefaultGridDelegate].
  final SliverGridDelegate? gridDelegate;

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

  /// When true, greys out the label and shows a forbid suffix icon.
  final bool isDisabled;

  /// Validator passed to the underlying [FormField].
  final FormFieldValidator<T?>? validator;

  /// Called from [FormState.save].
  final FormFieldSetter<T?>? onSaved;

  /// When true, shakes once when validation error appears on this field.
  final bool shakeOnError;

  @override
  State<UnifiedFormAsyncPickerField<T>> createState() =>
      _UnifiedFormAsyncPickerFieldState<T>();
}

class _UnifiedFormAsyncPickerFieldState<T>
    extends State<UnifiedFormAsyncPickerField<T>> {
  final GlobalKey<FormFieldState<T?>> _formFieldKey =
      GlobalKey<FormFieldState<T?>>();
  late T? _echoInitialWhenNoReset;
  late T _cachedResetTarget;

  void _onBindingChanged() {
    _applyExternalValue(widget.binding?.value);
  }

  T? _displayValue() => unifiedEffectiveValue(
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
    _echoInitialWhenNoReset = _displayValue();
    if (widget.resetValue != null) {
      _cachedResetTarget = widget.resetValue!();
      _scheduleSyncDisplayWhenCurrentDiffersFromResetTarget();
    }
    syncWidgetFormValidatorToFieldController<T?>(
      widget.fieldController,
      widget.validator,
    );
    widget.binding?.addListener(_onBindingChanged);
    widget.fieldController?.addListener(_onFieldControllerChanged);
  }

  @override
  void didUpdateWidget(covariant UnifiedFormAsyncPickerField<T> oldWidget) {
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
        if (_echoInitialWhenNoReset != display) {
          setState(() => _echoInitialWhenNoReset = display);
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
        if (_echoInitialWhenNoReset != display) {
          setState(() => _echoInitialWhenNoReset = display);
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
        return UnifiedAsyncPickerField<T>(
          itemProvider: widget.itemProvider,
          label: widget.label,
          placeholder: widget.placeholder,
          isRequired: widget.isRequired,
          decoration: widget.decoration,
          decorationSet: widget.decorationSet,
          brightness: widget.brightness,
          fieldController: widget.fieldController,
          binding: null,
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
          searchBuilder: widget.searchBuilder,
          itemToWidget: widget.itemToWidget,
          gridItemBuilder: widget.gridItemBuilder,
          gridDelegate: widget.gridDelegate,
          suggestion: widget.suggestion,
          hasSearch: widget.hasSearch,
          searchAutoFocus: widget.searchAutoFocus,
          showClearButton: widget.showClearButton,
          locked: widget.locked,
          isDisabled: widget.isDisabled,
          validator: null,
          validationOverrideMessage: unifiedFormPickerOverride(fieldState),
          pickerSheetStyle: widget.pickerSheetStyle,
          pickerSheetBackgroundColor: widget.pickerSheetBackgroundColor,
          pickerHeaderStyle: widget.pickerHeaderStyle,
          pickerSheetModalSettings: widget.pickerSheetModalSettings,
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
    this.decorationSet,
    this.brightness,
    this.binding,
    this.fieldController,
    this.onChanged,
    this.valueToString,
    this.searchBuilder,
    this.itemToWidget,
    this.gridItemBuilder,
    this.gridDelegate,
    this.suggestion = const [],
    this.hasSearch = true,
    this.searchAutoFocus = false,
    this.showClearButton = true,
    this.locked = false,
    this.isDisabled = false,
    this.validator,
    this.onSaved,
    this.shakeOnError = false,
    this.placeholder,
    this.isRequired = false,
    this.pickerSheetStyle,
    this.pickerSheetBackgroundColor,
    this.pickerHeaderStyle,
    this.pickerSheetModalSettings,
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

  /// Local picker sheet chrome; overrides theme when set.
  final UnifiedPickerSheetStyle? pickerSheetStyle;

  /// Sheet background override (wins over [pickerSheetStyle] and theme).
  final Color? pickerSheetBackgroundColor;

  /// Header override (wins over [pickerSheetStyle] and theme).
  final UnifiedInputPickerHeaderStyle? pickerHeaderStyle;

  /// Modal flags override (`isScrollControlled`, `isDismissible`, â€¦).
  final UnifiedPickerSheetModalSettings? pickerSheetModalSettings;

  /// When non-null, [FormState.reset] restores `resetValue()` (e.g. `() => const []` to clear).
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
  final UnifiedAsyncMultiPickerFieldController<T>? fieldController;

  /// Called when the selection changes.
  final ValueChanged<List<T>>? onChanged;

  /// Renders an item to its display text.
  final String Function(T value)? valueToString;

  /// Custom searchable text per item.
  final String Function(T value)? searchBuilder;

  /// Custom row builder inside the sheet (list layout).
  final Widget Function(T value)? itemToWidget;

  /// Custom grid tile builder; when set, the sheet uses a [GridView].
  final UnifiedPickerMultiGridItemBuilder<T>? gridItemBuilder;

  /// Grid layout when [gridItemBuilder] is set. Defaults to [unifiedPickerDefaultGridDelegate].
  final SliverGridDelegate? gridDelegate;

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

  /// When true, greys out the label and shows a forbid suffix icon.
  final bool isDisabled;

  /// Validator passed to the underlying [FormField].
  final FormFieldValidator<List<T>>? validator;

  /// Called from [FormState.save].
  final FormFieldSetter<List<T>>? onSaved;

  /// When true, shakes once when validation error appears on this field.
  final bool shakeOnError;

  @override
  State<UnifiedFormAsyncMultiPickerField<T>> createState() =>
      _UnifiedFormAsyncMultiPickerFieldState<T>();
}

class _UnifiedFormAsyncMultiPickerFieldState<T>
    extends State<UnifiedFormAsyncMultiPickerField<T>> {
  final GlobalKey<FormFieldState<List<T>>> _formFieldKey =
      GlobalKey<FormFieldState<List<T>>>();
  late List<T> _echoWhenNoReset;
  late List<T> _frozenResetList;

  void _onBindingChanged() {
    _applyExternalList(List<T>.from(widget.binding?.value ?? const []));
  }

  List<T> _displayList() => List<T>.from(
    unifiedEffectiveListValue(
      fieldController: widget.fieldController,
      binding: widget.binding,
      direct: widget.values,
    ),
  );

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
    syncWidgetFormValidatorToFieldController<List<T>>(
      widget.fieldController,
      widget.validator,
    );
    widget.binding?.addListener(_onBindingChanged);
    widget.fieldController?.addListener(_onFieldControllerChanged);
  }

  @override
  void didUpdateWidget(
    covariant UnifiedFormAsyncMultiPickerField<T> oldWidget,
  ) {
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
    final resetFnChanged = !identical(widget.resetValue, oldWidget.resetValue);
    final resetPayloadChanged =
        widget.resetValue != null &&
        oldWidget.resetValue != null &&
        !_unifiedListsEqual(widget.resetValue!(), oldWidget.resetValue!());
    final bindingChanged = widget.binding != oldWidget.binding;
    final fieldControllerChanged =
        widget.fieldController != oldWidget.fieldController;
    if (resetFnChanged ||
        resetPayloadChanged ||
        bindingChanged ||
        fieldControllerChanged) {
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
      final oldDisplay = List<T>.from(
        unifiedEffectiveListValue(
          fieldController: oldWidget.fieldController,
          binding: oldWidget.binding,
          direct: oldWidget.values,
        ),
      );
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
      final oldDisplay = List<T>.from(
        unifiedEffectiveListValue(
          fieldController: oldWidget.fieldController,
          binding: oldWidget.binding,
          direct: oldWidget.values,
        ),
      );
      if (!_unifiedListsEqual(display, oldDisplay)) {
        final s = _formFieldKey.currentState;
        if (s != null && !_unifiedListsEqual(s.value ?? [], display)) {
          s.didChange(display);
        }
      }
    }
  }

  void _onFieldControllerChanged() {
    _applyExternalList(List<T>.from(widget.fieldController?.value ?? const []));
  }

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
        return UnifiedAsyncMultiPickerField<T>(
          itemProvider: widget.itemProvider,
          label: widget.label,
          fieldController: widget.fieldController,
          values: widget.fieldController == null
              ? (fieldState.value ?? [])
              : const [],
          placeholder: widget.placeholder,
          isRequired: widget.isRequired,
          decoration: widget.decoration,
          decorationSet: widget.decorationSet,
          brightness: widget.brightness,
          binding: null,
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
          searchBuilder: widget.searchBuilder,
          itemToWidget: widget.itemToWidget,
          gridItemBuilder: widget.gridItemBuilder,
          gridDelegate: widget.gridDelegate,
          suggestion: widget.suggestion,
          hasSearch: widget.hasSearch,
          searchAutoFocus: widget.searchAutoFocus,
          showClearButton: widget.showClearButton,
          locked: widget.locked,
          isDisabled: widget.isDisabled,
          validator: null,
          validationOverrideMessage: unifiedFormPickerOverride(fieldState),
          pickerSheetStyle: widget.pickerSheetStyle,
          pickerSheetBackgroundColor: widget.pickerSheetBackgroundColor,
          pickerHeaderStyle: widget.pickerHeaderStyle,
          pickerSheetModalSettings: widget.pickerSheetModalSettings,
        );
      },
    );
  }
}

