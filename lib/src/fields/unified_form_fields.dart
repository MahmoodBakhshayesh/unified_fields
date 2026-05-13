import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_input_controller.dart';
import 'unified_base_text_field.dart';
import 'unified_input_brightness.dart';
import 'unified_input_decoration.dart';
import 'unified_picker_fields.dart';

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
  const UnifiedFormFieldScope({
    super.key,
    this.autovalidateMode,
    required super.child,
  });

  /// When null, falls back to the nearest [Form] (if any), then disabled.
  final AutovalidateMode? autovalidateMode;

  static AutovalidateMode autovalidateModeOf(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<UnifiedFormFieldScope>();
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
typedef UnifiedFormFieldBuilder<T> = Widget Function(
  BuildContext context,
  FormFieldState<T> field,
);

/// Horizontal shake when [hasError] flips from false to true (e.g. failed validation).
class _UnifiedFormShakeHost extends StatefulWidget {
  const _UnifiedFormShakeHost({
    required this.hasError,
    required this.child,
  });

  final bool hasError;
  final Widget child;

  @override
  State<_UnifiedFormShakeHost> createState() => _UnifiedFormShakeHostState();
}

class _UnifiedFormShakeHostState extends State<_UnifiedFormShakeHost> with SingleTickerProviderStateMixin {
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
        return Transform.translate(
          offset: Offset(dx, 0),
          child: child,
        );
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

  final T? initialValue;
  final FormFieldValidator<T>? validator;
  final FormFieldSetter<T>? onSaved;

  /// Called after [FormFieldState.reset] restores [initialValue]; use to sync
  /// [TextEditingController]s or [AppInputController]s. See [FormField.onReset].
  final VoidCallback? onReset;

  /// When true, shakes horizontally once when [FormFieldState.hasError] becomes true.
  final bool shakeOnError;

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
  const UnifiedFormTextField({
    super.key,
    this.decoration,
    this.brightness,
    this.controller,
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
    this.autofocus = false,
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

  final UnifiedInputDecoration? decoration;
  final UnifiedInputBrightness? brightness;

  /// When null, an internal [TextEditingController] is created and disposed here.
  final TextEditingController? controller;

  final String? initialValue;

  /// When non-null, [FormState.reset] restores `resetValue()` (e.g. `() => ''` to clear).
  final UnifiedFormResetValue<String>? resetValue;

  final AppInputController<String>? binding;
  final FocusNode? focusNode;

  final FormFieldValidator<String>? validator;
  final FormFieldSetter<String>? onSaved;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  final bool disabled;
  final bool readOnly;
  final bool locked;
  final bool autofocus;

  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final bool obscureText;
  final bool showClearButton;
  final TextCapitalization textCapitalization;
  final TextAlign textAlign;
  final String? placeholder;
  final String? label;
  final bool mustResolveTextDirectionByInput;
  final bool isPassword;
  final bool isRequired;

  /// When true, shakes once when validation error appears on this field.
  final bool shakeOnError;

  @override
  State<UnifiedFormTextField> createState() => _UnifiedFormTextFieldState();
}

class _UnifiedFormTextFieldState extends State<UnifiedFormTextField> {
  late TextEditingController _effectiveController;
  bool _ownsController = false;
  final GlobalKey<FormFieldState<String>> _formFieldKey = GlobalKey<FormFieldState<String>>();

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

  @override
  void initState() {
    super.initState();
    _effectiveController = widget.controller ??
        TextEditingController(text: widget.initialValue ?? '');
    _ownsController = widget.controller == null;
    final fromBinding = widget.binding?.value;
    if (fromBinding != null && fromBinding.isNotEmpty) {
      _effectiveController.text = fromBinding;
    }
    _recomputeResetBaseline();
    widget.binding?.addListener(_onBindingChanged);
  }

  @override
  void didUpdateWidget(covariant UnifiedFormTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      if (_ownsController) _effectiveController.dispose();
      _effectiveController = widget.controller ??
          TextEditingController(text: widget.initialValue ?? '');
      _ownsController = widget.controller == null;
      _formFieldKey.currentState?.didChange(_effectiveController.text);
    }
    if (oldWidget.binding != widget.binding) {
      oldWidget.binding?.removeListener(_onBindingChanged);
      widget.binding?.addListener(_onBindingChanged);
    }
    if (widget.resetValue != oldWidget.resetValue ||
        widget.binding != oldWidget.binding ||
        widget.controller != oldWidget.controller) {
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
  }

  @override
  void dispose() {
    widget.binding?.removeListener(_onBindingChanged);
    if (_ownsController) _effectiveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = resolveUnifiedDecoration(context, overrides: widget.decoration, brightness: widget.brightness);

    return UnifiedFormField<String>(
      formFieldKey: _formFieldKey,
      initialValue: _formResetBaseline,
      validator: widget.validator,
      onSaved: widget.onSaved,
      onReset: _syncControllerAndBindingFromForm,
      shakeOnError: widget.shakeOnError,
      builder: (context, fieldState) {
        return UnifiedBaseTextField(
          controller: _effectiveController,
          focusNode: widget.focusNode,
          label: widget.label ?? d.label,
          placeholder: widget.placeholder ?? d.placeholder ?? d.label,
          labelStyle: d.labelStyle,
          style: d.fieldStyle,
          backgroundColor: d.backgroundColor ?? Colors.black26,
          headerBackgroundColor: d.headerBackgroundColor ?? d.backgroundColor ?? Colors.black26,
          borderRadius: d.borderRadius ?? const BorderRadius.all(Radius.circular(18)),
          borderSide: d.borderSide,
          height: d.height,
          rowLabelRatio: d.rowLabelRatio,
          labelInRow: d.labelInRow,
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
          readOnly: widget.readOnly,
          locked: widget.locked,
          autofocus: widget.autofocus,
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
          mustResolveTextDirectionByInput: widget.mustResolveTextDirectionByInput,
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
          },
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
  const UnifiedFormSinglePickerField({
    super.key,
    required this.items,
    required this.label,
    this.decoration,
    this.brightness,
    this.value,
    this.binding,
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
    this.placeholder,
    this.validator,
    this.onSaved,
    this.shakeOnError = false,
  });

  final List<T> items;
  final String label;
  final String? placeholder;

  final UnifiedInputDecoration? decoration;
  final UnifiedInputBrightness? brightness;

  final T? value;
  final AppInputController<T>? binding;

  /// When non-null, [FormState.reset] restores `resetValue()` (`T Function()`).
  final UnifiedFormResetValue<T>? resetValue;
  final ValueChanged<T?>? onChanged;

  final String Function(T value)? valueToString;
  final String Function(T value)? searchBuilder;
  final Widget Function(T value)? itemToWidget;

  final List<T> suggestion;
  final bool hasSearch;
  final bool searchAutoFocus;
  final bool showClearButton;
  final bool locked;

  final FormFieldValidator<T?>? validator;
  final FormFieldSetter<T?>? onSaved;

  /// When true, shakes once when validation error appears on this field.
  final bool shakeOnError;

  @override
  State<UnifiedFormSinglePickerField<T>> createState() => _UnifiedFormSinglePickerFieldState<T>();
}

class _UnifiedFormSinglePickerFieldState<T> extends State<UnifiedFormSinglePickerField<T>> {
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
  void didUpdateWidget(covariant UnifiedFormSinglePickerField<T> oldWidget) {
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
        return UnifiedSinglePickerField<T>(
          items: widget.items,
          label: widget.label,
          placeholder: widget.placeholder,
          decoration: widget.decoration,
          brightness: widget.brightness,
          value: fieldState.value,
          binding: null,
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
