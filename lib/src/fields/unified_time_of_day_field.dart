import 'package:flutter/material.dart';

import '../time_of_day_extension.dart';
import '../time_picker_utils.dart';
import 'unified_base_text_field.dart';
import '../controllers/field_controller_sync.dart';
import '../controllers/unified_time_field_controller.dart';
import 'app_input_controller.dart';
import 'unified_input_brightness.dart';
import 'unified_input_decoration.dart';

/// Time-of-day picker using unified chrome + [TimePickerUtils].
class UnifiedTimeOfDayField extends StatefulWidget {
  /// Creates a time-of-day field.
  const UnifiedTimeOfDayField({
    super.key,
    this.decoration,
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
    this.label,
    this.placeholder,
    this.isRequired = false,
  });

  /// Visual chrome.
  final UnifiedInputDecoration? decoration;

  /// Override [Theme] brightness for the unified palette.
  final UnifiedInputBrightness? brightness;

  /// Optional external state binding.
  final AppInputController<TimeOfDay>? binding;

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

  /// Forwarded to [showTimePicker].
  final TimePickerEntryMode timePickerEntryMode;

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

  void _syncFieldController(BuildContext context) {
    final d = resolveUnifiedDecoration(context, overrides: widget.decoration, brightness: widget.brightness);
    widget.fieldController?.bindPickerTitle(widget.label ?? d.label ?? '');
    attachUnifiedFieldHandles(
      opener: (ctx) => _pick(ctx),
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
    if (oldWidget.binding != widget.binding || oldWidget.fieldController != widget.fieldController) {
      oldWidget.binding?.removeListener(_onBinding);
      oldWidget.fieldController?.removeListener(_onBinding);
      widget.binding?.addListener(_onBinding);
      widget.fieldController?.addListener(_onBinding);
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
    _txt.text = t?.toJson ?? '';
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
    final initial = _effective ?? TimeOfDay.now();
    final picked = await TimePickerUtils.show(
      context,
      title: widget.label ?? widget.decoration?.label,
      initialTime: initial,
      timePickerEntryMode: widget.fieldController?.timePickerEntryMode ?? widget.timePickerEntryMode,
    );
    if (!context.mounted || picked == null) return;
    _txt.text = picked.toJson ?? '';
    syncUnifiedFieldValue(
      value: picked,
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
    final d = resolveUnifiedDecoration(context, overrides: widget.decoration, brightness: widget.brightness);

    return GestureDetector(
      onTap: widget.locked || widget.isDisabled ? null : () => _pick(context),
      child: AbsorbPointer(
        absorbing: true,
        child: UnifiedBaseTextField(
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
          backgroundColor: d.backgroundColor ?? Colors.black26,
          headerBackgroundColor: d.headerBackgroundColor ?? d.backgroundColor ?? Colors.black26,
          borderRadius: d.borderRadius ?? const BorderRadius.all(Radius.circular(18)),
          borderSide: d.borderSide,
          height: d.height,
          rowLabelRatio: d.rowLabelRatio,
          labelInRow: d.labelInRow,
          requiredField: widget.isRequired || d.requiredField,
          showError: d.showError,
          validationColor: d.validationColor,
          validationIcon: d.validationIcon,
          prefix: d.prefix,
          prefixIcon: d.prefixIcon,
          suffixIcon: widget.isDisabled || widget.locked ? null : (d.suffixIcon ?? const Icon(Icons.schedule)),
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
