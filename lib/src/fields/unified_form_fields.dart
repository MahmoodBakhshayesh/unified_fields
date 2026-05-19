import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../controllers/field_controller_sync.dart';
import '../controllers/unified_picker_field_controller.dart';
import '../controllers/unified_text_field_controller.dart';
import 'unified_input_picker.dart';
import 'unified_base_text_field.dart';
import 'unified_input_brightness.dart';
import 'unified_field_decoration_context.dart';
import 'unified_input_decoration.dart';
import 'unified_picker_fields.dart';
import 'unified_picker_item_builders.dart';
import 'unified_input_theme.dart';

/// Optional callback used by unified form fields for [FormState.reset].
///
/// - **null** (omit the parameter): reset does **not** change this field’s value.
/// - **non-null**: each reset restores `callback()` (the return value may be **null**
///   for nullable types, e.g. clear a picker with `() => null`).
///
/// Keep callbacks cheap and predictable; returning a new [List] identity each frame can
/// disturb [FormField] if the callback reference never changes—prefer stable lists or a
/// new callback when the list contents change.
typedef UnifiedFormResetValue<T> = T Function();

/// Form-integrated unified inputs.
///
/// Wrap fields in a [Form] with a [GlobalKey<FormState>]. One key is enough for
/// [FormState.validate] and [FormState.save] on every descendant [FormField]
/// (including [UnifiedFormTextField] and [UnifiedFormSinglePickerField]).
///
/// **Reset / “clear form”:** [FormState.reset] tells each [FormField] to restore
/// its [FormField.initialValue] and clear errors. Unified wrappers take an optional
/// **[UnifiedFormResetValue]** callback (see typedef above): **null** means this field’s
/// value is unchanged on reset; **non-null** means reset restores `callback()` (return
/// value may be null for nullable fields). Flutter may still clear errors / interaction flags.
///
/// **More form wrappers:** see `unified_form_more_fields.dart` ([UnifiedFormMultiPickerField],
/// [UnifiedFormDateField], [UnifiedFormDateRangeField], [UnifiedFormTimeOfDayField],
/// [UnifiedFormDurationField], [UnifiedFormAsyncPickerField], [UnifiedFormAsyncMultiPickerField],
/// [UnifiedFormNumberField]) — each uses the same optional [UnifiedFormResetValue] callback
/// where applicable.
///
/// Optional scope so unified form fields share [AutovalidateMode] (and future flags)
/// without each widget hard-coding behavior.
///
/// Resolution order for autovalidate: [autovalidateMode] here → nearest [Form]'s
/// [Form.autovalidateMode] → [AutovalidateMode.disabled].
class UnifiedFormFieldScope extends InheritedWidget {
  /// Creates a unified form field scope.
  const UnifiedFormFieldScope({
    super.key,
    this.autovalidateMode,
    required super.child,
  });

  /// When null, falls back to the nearest [Form] (if any), then disabled.
  final AutovalidateMode? autovalidateMode;

  /// Resolves the effective [AutovalidateMode] for unified form fields under [context].
  static AutovalidateMode autovalidateModeOf(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<UnifiedFormFieldScope>();
    if (scope?.autovalidateMode != null) {
      return scope!.autovalidateMode!;
    }
    final form = context.findAncestorWidgetOfExactType<Form>();
    if (form != null) {
      return form.autovalidateMode;
    }
    return AutovalidateMode.disabled;
  }

  @override
  bool updateShouldNotify(covariant UnifiedFormFieldScope oldWidget) =>
      oldWidget.autovalidateMode != autovalidateMode;
}

/// Builds the child for [UnifiedFormField].
typedef UnifiedFormFieldBuilder<T> =
    Widget Function(BuildContext context, FormFieldState<T> field);

/// Horizontal shake when [hasError] flips from false to true (e.g. failed validation).
class _UnifiedFormShakeHost extends StatefulWidget {
  const _UnifiedFormShakeHost({required this.hasError, required this.child});

  final bool hasError;
  final Widget child;

  @override
  State<_UnifiedFormShakeHost> createState() => _UnifiedFormShakeHostState();
}

class _UnifiedFormShakeHostState extends State<_UnifiedFormShakeHost>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
  }

  @override
  void didUpdateWidget(covariant _UnifiedFormShakeHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.hasError && !oldWidget.hasError) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _decayingShake(double t) {
    if (t <= 0 || t >= 1) return 0;
    return (1 - t) * 9 * math.sin(t * math.pi * 6);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        final dx = _decayingShake(_controller.value);
        if (dx == 0 && !_controller.isAnimating) {
          return child!;
        }
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
    );
  }
}

/// Single [FormField] shell: shared [AutovalidateMode] resolution, optional [onReset]
/// (after [FormState.reset]) and one [builder].
///
/// Set [shakeOnError] to true for a brief horizontal shake when [FormFieldState.hasError]
/// becomes true (for example after a failed [FormState.validate]).
///
/// Use this for **any** unified control (date, duration, async picker, …): wrap the
/// existing widget in [builder], call [FormFieldState.didChange] when the value
/// changes, and wire errors with [unifiedFormErrorText] / [unifiedFormPickerOverride]
/// instead of adding a new `UnifiedForm…` class per control type.
///
/// See [UnifiedFormTextField] and [UnifiedFormSinglePickerField] later in this file for
/// ready-made wrappers; everything else composes with this class.
class UnifiedFormField<T> extends StatelessWidget {
  /// Creates a unified [FormField] adapter.
  const UnifiedFormField({
    super.key,
    this.formFieldKey,
    required this.initialValue,
    this.validator,
    this.onSaved,
    this.onReset,
    this.shakeOnError = false,
    required this.builder,
  });

  /// Optional; use when you must call [FormFieldState.didChange] from outside
  /// (for example binding or controller listeners).
  final GlobalKey<FormFieldState<T>>? formFieldKey;

  /// Initial value passed to the underlying [FormField].
  final T? initialValue;

  /// Validator forwarded to the underlying [FormField].
  final FormFieldValidator<T>? validator;

  /// Callback forwarded to the underlying [FormField.onSaved].
  final FormFieldSetter<T>? onSaved;

  /// Called after [FormFieldState.reset] restores [initialValue]; use to sync
  /// [TextEditingController]s or [UnifiedInputPicker]s. See [FormField.onReset].
  final VoidCallback? onReset;

  /// When true, shakes horizontally once when [FormFieldState.hasError] becomes true.
  final bool shakeOnError;

  /// Builder that renders the actual control given the current [FormFieldState].
  final UnifiedFormFieldBuilder<T> builder;

  @override
  Widget build(BuildContext context) {
    return FormField<T>(
      key: formFieldKey,
      initialValue: initialValue,
      autovalidateMode: UnifiedFormFieldScope.autovalidateModeOf(context),
      validator: validator,
      onSaved: onSaved,
      onReset: onReset,
      builder: (fieldState) {
        final built = builder(context, fieldState);
        if (!shakeOnError) return built;
        return _UnifiedFormShakeHost(
          hasError: fieldState.hasError,
          child: built,
        );
      },
    );
  }
}

/// Error line for [UnifiedBaseTextField.validator] while the real rule lives on
/// [FormField] in a [UnifiedFormField] builder: `validator: (_) => unifiedFormErrorText(field)`.
String? unifiedFormErrorText<T>(FormFieldState<T> field) => field.errorText;

/// Drives [UnifiedSinglePickerField.validationOverrideMessage] (and similar) from
/// [FormField] state so the inner field’s string [validator] can stay null.
String? unifiedFormPickerOverride<T>(FormFieldState<T> field) =>
    field.hasError ? (field.errorText ?? '') : null;

/// [FormField]-backed text using [UnifiedBaseTextField] chrome.
///
/// Place under a [Form] so [FormState.validate] / [save] / [reset] apply without a
/// separate [GlobalKey] per text field.
///
/// **Text state**
/// - Prefer an optional [controller] when the screen already owns a
///   [TextEditingController] (same pattern as [UnifiedTextField]); the widget does
///   not dispose a passed-in controller.
/// - If [controller] is null, an internal controller is created from [initialValue]
///   and optional [binding], and disposed with this state.
/// - [binding] still syncs both directions when used (including with a passed-in
///   [controller], matching [UnifiedTextField]).
/// **Reset**
/// - Pass **[resetValue]**: a [UnifiedFormResetValue] so [FormState.reset] restores
///   `resetValue()` (use `() => ''` to clear text). The callback may read the latest model;
///   pass a new closure when that snapshot should change.
/// - Omit [resetValue] (or pass null): reset does **not** change the text; [FormField.initialValue]
///   tracks the current controller text.
///
/// **Initial text**
/// - [initialValue] seeds the controller when [controller] is null.
class UnifiedFormTextField extends StatefulWidget {
  /// Creates a [Form]-aware text field.
  const UnifiedFormTextField({
    super.key,
    this.decoration,
    this.decorationSet,
    this.brightness,
    this.controller,
    this.fieldController,
    this.initialValue,
    this.resetValue,
    this.binding,
    this.focusNode,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.onSubmitted,
    this.disabled = false,
    this.readOnly = false,
    this.locked = false,
    this.isDisabled = false,
    this.autofocus = false,
    this.selectTextOnFocus,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.obscureText = false,
    this.showClearButton = false,
    this.textCapitalization = TextCapitalization.none,
    this.textAlign = TextAlign.start,
    this.placeholder,
    this.label,
    this.mustResolveTextDirectionByInput = false,
    this.isPassword = false,
    this.isRequired = false,
    this.shakeOnError = false,
  });

  /// Visual chrome overrides.
  final UnifiedInputDecoration? decoration;

  /// Per-state decorations (focus, error, valid, locked, disabled, …).
  final UnifiedInputDecorationSet? decorationSet;

  /// Forces a brightness regardless of the ambient [Theme].
  final UnifiedInputBrightness? brightness;

  /// When null, an internal [TextEditingController] is created and disposed here.
  final TextEditingController? controller;

  /// Preferred imperative handle; when set, the field edits [UnifiedTextFieldController.textController].
  ///
  /// If both [controller] and [fieldController] are set, pass the same
  /// [TextEditingController] into [UnifiedTextFieldController.textController] (or only
  /// use [fieldController]); otherwise [controller] is ignored for editing.
  final UnifiedTextFieldController? fieldController;

  /// Initial text when [controller] is null.
  final String? initialValue;

  /// When non-null, [FormState.reset] restores `resetValue()` (e.g. `() => ''` to clear).
  final UnifiedFormResetValue<String>? resetValue;

  /// Two-way binding for the field value.
  final UnifiedInputPicker<String>? binding;

  /// External focus node.
  final FocusNode? focusNode;

  /// Validator passed to the underlying [FormField].
  final FormFieldValidator<String>? validator;

  /// Called from [FormState.save].
  final FormFieldSetter<String>? onSaved;

  /// Called on every keystroke.
  final ValueChanged<String>? onChanged;

  /// Called on keyboard submit.
  final ValueChanged<String>? onSubmitted;

  /// When true, the field is non-editable and visually muted.
  final bool disabled;

  /// When true, the field rejects edits but still looks active.
  final bool readOnly;

  /// When true, paints the field in the "locked" style.
  final bool locked;

  /// When true, greys out the label and shows a forbid suffix icon.
  final bool isDisabled;

  /// Autofocus the field on first build.
  final bool autofocus;

  /// When true, focuses selects all text so the next keystroke replaces it.
  final bool? selectTextOnFocus;

  /// Keyboard type.
  final TextInputType? keyboardType;

  /// Keyboard action button.
  final TextInputAction? textInputAction;

  /// Custom input formatters.
  final List<TextInputFormatter>? inputFormatters;

  /// Maximum visible lines.
  final int maxLines;

  /// Minimum visible lines.
  final int? minLines;

  /// Maximum allowed characters.
  final int? maxLength;

  /// Obscure entered text.
  final bool obscureText;

  /// Show a clear button when the field has content.
  final bool showClearButton;

  /// Capitalization rule applied to typed text.
  final TextCapitalization textCapitalization;

  /// Horizontal alignment of typed text.
  final TextAlign textAlign;

  /// Placeholder text shown when empty.
  final String? placeholder;

  /// Field label.
  final String? label;

  /// Infer text direction from typed content.
  final bool mustResolveTextDirectionByInput;

  /// Render entered text as obscured and add a visibility toggle.
  final bool isPassword;

  /// Marks the field as required (visual hint only).
  final bool isRequired;

  /// When true, shakes once when validation error appears on this field.
  final bool shakeOnError;

  @override
  State<UnifiedFormTextField> createState() => _UnifiedFormTextFieldState();
}

class _UnifiedFormTextFieldState extends State<UnifiedFormTextField> {
  late TextEditingController _effectiveController;
  bool _ownsController = false;
  final GlobalKey<FormFieldState<String>> _formFieldKey =
      GlobalKey<FormFieldState<String>>();

  /// Passed to [UnifiedFormField.initialValue]. When [resetValue] is non-null, holds the
  /// last `resetValue()` snapshot; otherwise mirrors controller text for reset no-op.
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

  void _initEffectiveController() {
    final fc = widget.fieldController;
    if (fc != null) {
      _effectiveController = fc.textController;
      _ownsController = false;
      return;
    }
    _effectiveController =
        widget.controller ??
        TextEditingController(text: widget.initialValue ?? '');
    _ownsController = widget.controller == null;
  }

  @override
  void initState() {
    super.initState();
    _initEffectiveController();
    final external = widget.controller;
    final fc = widget.fieldController;
    if (fc != null && external != null && external != fc.textController) {
      fc.textController.text = external.text;
    }
    final fromExternal = fc?.value ?? widget.binding?.value;
    if (fromExternal != null && fromExternal.isNotEmpty) {
      _effectiveController.text = fromExternal;
    }
    _recomputeResetBaseline();
    syncWidgetStringValidatorToFieldController(
      widget.fieldController,
      widget.validator,
    );
    widget.binding?.addListener(_onBindingChanged);
    widget.fieldController?.addListener(_onFieldControllerChanged);
  }

  @override
  void didUpdateWidget(covariant UnifiedFormTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller ||
        oldWidget.fieldController != widget.fieldController) {
      if (_ownsController) _effectiveController.dispose();
      _initEffectiveController();
      _formFieldKey.currentState?.didChange(_effectiveController.text);
    }
    if (oldWidget.binding != widget.binding) {
      oldWidget.binding?.removeListener(_onBindingChanged);
      widget.binding?.addListener(_onBindingChanged);
    }
    if (oldWidget.fieldController != widget.fieldController) {
      oldWidget.fieldController?.removeListener(_onFieldControllerChanged);
      widget.fieldController?.addListener(_onFieldControllerChanged);
    }
    if (widget.resetValue != oldWidget.resetValue ||
        widget.binding != oldWidget.binding ||
        widget.controller != oldWidget.controller ||
        widget.fieldController != oldWidget.fieldController) {
      _recomputeResetBaseline();
    }
    if (oldWidget.validator != widget.validator ||
        oldWidget.fieldController != widget.fieldController) {
      syncWidgetStringValidatorToFieldController(
        widget.fieldController,
        widget.validator,
      );
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

  void _onFieldControllerChanged() {
    final fc = widget.fieldController;
    if (fc == null) return;
    final v = fc.value ?? '';
    if (v != _effectiveController.text) {
      _effectiveController.text = v;
      _formFieldKey.currentState?.didChange(v);
      if (widget.resetValue == null) {
        _formResetBaseline = v;
      }
    }
    // Rebuild when [errorText] changes too ([validate] / [UnifiedFieldValidation]).
    setState(() {});
    final formState = _formFieldKey.currentState;
    if (formState != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) unifiedFormClearErrorIfValid(formState);
      });
    }
  }

  /// [FormField.onReset]: align [TextEditingController] + optional [binding] with form state.
  void _syncControllerAndBindingFromForm() {
    final v = _formFieldKey.currentState?.value ?? '';
    if (_effectiveController.text != v) {
      _effectiveController.text = v;
    }
    final b = widget.binding;
    if (b != null && b.value != v) {
      b.value = v;
    }
    final fc = widget.fieldController;
    if (fc != null) {
      final next = v.isEmpty ? null : v;
      if (fc.value != next) {
        fc.value = next;
      }
    }
  }

  @override
  void dispose() {
    widget.binding?.removeListener(_onBindingChanged);
    widget.fieldController?.removeListener(_onFieldControllerChanged);
    if (_ownsController) _effectiveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    syncWidgetStringValidatorToFieldController(
      widget.fieldController,
      widget.validator,
    );
    final chrome = resolveUnifiedFieldDecorationContext(
      context,
      decoration: widget.decoration,
      decorationSet: widget.decorationSet,
      brightness: widget.brightness,
    );
    final d = chrome.resolved;

    Widget buildField(FormFieldState<String> fieldState) {
        return UnifiedBaseTextField(
          decorationSet: chrome.activeSet,
          brightness: widget.brightness,
          controller: _effectiveController,
          focusNode: unifiedEffectiveFocusNode(
            fieldController: widget.fieldController,
            binding: widget.binding,
            direct: widget.focusNode,
          ),
          errorText:
              widget.fieldController?.errorText ?? fieldState.errorText,
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
          rowLabelRatio: d.optionalRowLabelRatio,
          labelMode: d.labelMode,
          requiredField: widget.isRequired,
          showError: d.showError,
          validationColor: d.validationColor,
          validationIcon: d.validationIcon,
          prefix: d.prefix,
          prefixIcon: d.prefixIcon,
          suffixIcon: d.suffixIcon,
          padding: d.contentPadding,
          autovalidateMode: AutovalidateMode.always,
          validator: (_) => unifiedFormErrorText(fieldState),
          disabled: widget.disabled,
          isDisabled: widget.isDisabled,
          readOnly: widget.readOnly,
          locked: widget.locked,
          autofocus: widget.autofocus,
          selectTextOnFocus: widget.selectTextOnFocus,
          keyboardType: widget.keyboardType,
          textInputAction: widget.textInputAction ?? TextInputAction.done,
          inputFormatters: widget.inputFormatters,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          maxLength: widget.maxLength,
          isPassword: widget.isPassword || widget.obscureText,
          showClearButton: widget.showClearButton,
          textCapitalization: widget.textCapitalization,
          textAlign: widget.textAlign,

          mustResolveTextDirectionByInput:
              widget.mustResolveTextDirectionByInput,
          initialValue: widget.controller != null ? null : widget.initialValue,
          onSubmit: widget.onSubmitted,
          onChanged: (s) {
            fieldState.didChange(s);
            _bumpBaselineFromControllerIfNoResetValue();
            widget.onChanged?.call(s);
            final b = widget.binding;
            if (b != null && b.value != s) {
              b.value = s;
            }
            final fc = widget.fieldController;
            if (fc != null) {
              final next = s.isEmpty ? null : s;
              if (fc.value != next) {
                fc.value = next;
              }
            }
            unifiedFormClearErrorIfValid(fieldState);
          },
        );
    }

    final fc = widget.fieldController;
    return UnifiedFormField<String>(
      formFieldKey: _formFieldKey,
      initialValue: _formResetBaseline,
      validator: widget.validator,
      onSaved: widget.onSaved,
      onReset: _syncControllerAndBindingFromForm,
      shakeOnError: widget.shakeOnError,
      builder: (context, fieldState) {
        if (fc == null) return buildField(fieldState);
        return ListenableBuilder(
          listenable: fc,
          builder: (context, _) => buildField(fieldState),
        );
      },
    );
  }
}

/// [FormField] wrapper for [UnifiedSinglePickerField] with typed validation on `T?`.
///
/// Error chrome matches other unified fields via [validationOverrideMessage].
/// Prefer [UnifiedFormField] for custom layouts; this is a thin convenience wrapper.
///
/// **Reset vs display**
/// - [value] / [binding] are the **current** selection.
/// - Optional **[resetValue]**: when non-null, [FormState.reset] restores `resetValue()`
///   (a `T Function()`). Use a nullable [T] (e.g. `RoastLevel?`) when the reset snapshot may
///   be null (clear selection with `() => null`).
/// - When [resetValue] is null, reset does **not** change the selection.
/// - When the reset target differs from the current [value]/[binding], the picker still
///   shows the current value until reset (post-frame sync), unless both are null.
class UnifiedFormSinglePickerField<T> extends StatefulWidget {
  /// Creates a [Form]-aware single-select picker field.
  const UnifiedFormSinglePickerField({
    super.key,
    required this.items,
    required this.label,
    this.decoration,
    this.decorationSet,
    this.brightness,
    this.value,
    this.binding,
    this.fieldController,
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
    this.placeholder,
    this.isRequired = false,
    this.validator,
    this.onSaved,
    this.shakeOnError = false,
    this.pickerSheetStyle,
    this.pickerSheetBackgroundColor,
    this.pickerHeaderStyle,
    this.pickerSheetModalSettings,
  });

  /// Choices shown in the picker sheet.
  final List<T> items;

  /// Label for the field and sheet title fallback.
  final String label;

  /// Placeholder shown when empty.
  final String? placeholder;

  /// Whether the field is required. Overrides [UnifiedInputDecoration.requiredField] when set.
  final bool isRequired;

  /// Local picker sheet chrome; overrides theme when set.
  final UnifiedPickerSheetStyle? pickerSheetStyle;

  /// Sheet background override (wins over [pickerSheetStyle] and theme).
  final Color? pickerSheetBackgroundColor;

  /// Header override (wins over [pickerSheetStyle] and theme).
  final UnifiedInputPickerHeaderStyle? pickerHeaderStyle;

  /// Modal flags override (`isScrollControlled`, `isDismissible`, …).
  final UnifiedPickerSheetModalSettings? pickerSheetModalSettings;

  /// Visual chrome overrides.
  final UnifiedInputDecoration? decoration;

  /// Per-state decorations (focus, error, valid, locked, disabled, …).
  final UnifiedInputDecorationSet? decorationSet;

  /// Forces a brightness regardless of the ambient [Theme].
  final UnifiedInputBrightness? brightness;

  /// Direct value when not using [binding].
  final T? value;

  /// Optional external state binding.
  final UnifiedInputPicker<T>? binding;

  /// Preferred imperative handle; syncs with [binding] and [FormField] on change.
  final UnifiedPickerFieldController<T>? fieldController;

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
  State<UnifiedFormSinglePickerField<T>> createState() =>
      _UnifiedFormSinglePickerFieldState<T>();
}

class _UnifiedFormSinglePickerFieldState<T>
    extends State<UnifiedFormSinglePickerField<T>> {
  final GlobalKey<FormFieldState<T?>> _formFieldKey =
      GlobalKey<FormFieldState<T?>>();
  late T? _echoInitialWhenNoReset;
  late T _cachedResetTarget;

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
    syncWidgetValidatorToFieldController(
      widget.fieldController,
      widget.validator,
    );
    widget.binding?.addListener(_onBindingChanged);
    widget.fieldController?.addListener(_onFieldControllerChanged);
  }

  @override
  void didUpdateWidget(covariant UnifiedFormSinglePickerField<T> oldWidget) {
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
      syncWidgetValidatorToFieldController(
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

  void _onBindingChanged() {
    _applyExternalValue(widget.binding?.value);
  }

  void _onFieldControllerChanged() {
    _applyExternalValue(widget.fieldController?.value);
  }

  void _applyExternalValue(T? display) {
    syncFormFieldFromExternalValue(
      formState: _formFieldKey.currentState,
      value: display,
      fieldController: widget.fieldController,
    );
    setState(() {
      if (widget.resetValue == null && _echoInitialWhenNoReset != display) {
        _echoInitialWhenNoReset = display;
      }
    });
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
    final v = _formFieldKey.currentState?.value;
    syncUnifiedFieldValue(
      value: v,
      binding: widget.binding,
      fieldController: widget.fieldController,
    );
  }

  @override
  Widget build(BuildContext context) {
    syncWidgetValidatorToFieldController(
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
        return UnifiedSinglePickerField<T>(
          items: widget.items,
          label: widget.label,
          placeholder: widget.placeholder,
          isRequired: widget.isRequired,
          decoration: widget.decoration,
          decorationSet: widget.decorationSet,
          brightness: widget.brightness,
          fieldController: widget.fieldController,
          value: widget.fieldController == null ? fieldState.value : null,
          binding: null,
          onChanged: (v) {
            fieldState.didChange(v);
            if (widget.resetValue == null) {
              setState(() => _echoInitialWhenNoReset = v);
            }
            syncUnifiedFieldValue(
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
