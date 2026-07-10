part of 'unified_form_more_fields.dart';

/// [FormField] + [UnifiedNumberField] (string snapshot matches [TextEditingController] text).
class UnifiedFormNumberField extends StatefulWidget {
  /// Creates a [Form]-aware number field.
  const UnifiedFormNumberField({
    super.key,
    this.decoration,
    this.decorationSet,
    this.brightness,
    this.controller,
    this.fieldController,
    this.focusNode,
    this.binding,
    this.initialText = '',
    this.resetValue,
    this.validator,
    this.onSaved,
    this.onChanged,
    this.onSubmitted,
    this.disabled = false,
    this.isDisabled = false,
    this.locked = false,
    this.readOnly = false,
    this.autofocus = false,
    this.selectTextOnFocus,
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
    this.stepButtons = UnifiedNumericStepButtons.both,
    this.stepButtonPlacement = UnifiedNumericStepButtonPlacement.split,
    this.decrementIcon = Icons.remove_rounded,
    this.incrementIcon = Icons.add_rounded,
    this.textAlign = TextAlign.center,
  });

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

  /// External [TextEditingController].
  final TextEditingController? controller;

  /// Preferred imperative handle; when set, uses [UnifiedNumberFieldController.text].
  final UnifiedNumberFieldController? fieldController;

  /// External focus node.
  final FocusNode? focusNode;

  /// Two-way binding for the displayed text.
  final UnifiedInputPicker<String>? binding;

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

  /// When true, greys out the label and shows a forbid suffix icon.
  final bool isDisabled;

  /// When true, greys out the field and shows a lock suffix icon.
  final bool locked;

  /// When true, the field rejects edits.
  final bool readOnly;

  /// Autofocus the field on first build.
  final bool autofocus;

  /// When true, focuses selects all text so the next keystroke replaces it.
  final bool? selectTextOnFocus;

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

  /// Which +/- buttons to show.
  final UnifiedNumericStepButtons stepButtons;

  /// Where step buttons sit relative to [decoration] prefix/suffix.
  final UnifiedNumericStepButtonPlacement stepButtonPlacement;

  /// Icon for the decrement button.
  final IconData decrementIcon;

  /// Icon for the increment button.
  final IconData incrementIcon;

  /// Horizontal alignment of the numeric value.
  final TextAlign textAlign;

  @override
  State<UnifiedFormNumberField> createState() => _UnifiedFormNumberFieldState();
}

class _UnifiedFormNumberFieldState extends State<UnifiedFormNumberField> {
  late TextEditingController _effectiveController;
  bool _ownsController = false;
  final GlobalKey<FormFieldState<String>> _formFieldKey =
      GlobalKey<FormFieldState<String>>();

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

  void _initEffectiveController() {
    final fc = widget.fieldController;
    if (fc != null) {
      _effectiveController = fc.text.textController;
      _ownsController = false;
      return;
    }
    _effectiveController =
        widget.controller ??
        TextEditingController(
          text: widget.binding?.value ?? widget.initialText,
        );
    _ownsController = widget.controller == null;
  }

  @override
  void initState() {
    super.initState();
    _initEffectiveController();
    _recomputeResetBaseline();
    syncNumberFormStringValidatorToFieldController(
      widget.fieldController,
      widget.validator,
    );
    widget.binding?.addListener(_onBindingChanged);
    widget.fieldController?.addListener(_onFieldControllerChanged);
  }

  @override
  void didUpdateWidget(covariant UnifiedFormNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.validator != widget.validator ||
        oldWidget.fieldController != widget.fieldController) {
      syncNumberFormStringValidatorToFieldController(
        widget.fieldController,
        widget.validator,
      );
    }
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
    if (widget.binding != oldWidget.binding ||
        widget.controller != oldWidget.controller ||
        widget.fieldController != oldWidget.fieldController ||
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

  void _onFieldControllerChanged() {
    final v = widget.fieldController?.text.textController.text ?? '';
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
    final fc = widget.fieldController;
    if (fc != null) {
      final parsed = num.tryParse(v.trim()) ?? double.tryParse(v.trim());
      if (fc.value != parsed) {
        fc.value = parsed;
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
    syncNumberFormStringValidatorToFieldController(
      widget.fieldController,
      widget.validator,
    );
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
          decorationSet: widget.decorationSet,
          brightness: widget.brightness,
          controller: _effectiveController,
          focusNode: widget.fieldController?.text.focusNode ?? widget.focusNode,
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
            final fc = widget.fieldController;
            if (fc != null && fc.value != n) {
              fc.value = n;
            }
          },
          onSubmitted: widget.onSubmitted,
          disabled: widget.disabled,
          isDisabled: widget.isDisabled,
          locked: widget.locked,
          readOnly: widget.readOnly,
          autofocus: widget.autofocus,
          selectTextOnFocus: widget.selectTextOnFocus,
          allowDecimals: widget.allowDecimals,
          step: widget.step,
          min: widget.min,
          max: widget.max,
          fractionDigits: widget.fractionDigits,
          textInputAction: widget.textInputAction,
          label: widget.label,
          stepButtons: widget.stepButtons,
          stepButtonPlacement: widget.stepButtonPlacement,
          decrementIcon: widget.decrementIcon,
          incrementIcon: widget.incrementIcon,
          textAlign: widget.textAlign,
        );
      },
    );
  }
}

