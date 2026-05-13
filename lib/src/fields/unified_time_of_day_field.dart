import 'package:flutter/material.dart';

import '../time_of_day_extension.dart';
import '../time_picker_utils.dart';
import 'unified_base_text_field.dart';
import 'app_input_controller.dart';
import 'unified_input_brightness.dart';
import 'unified_input_decoration.dart';

/// Time-of-day picker using unified chrome + [TimePickerUtils].
class UnifiedTimeOfDayField extends StatefulWidget {
  const UnifiedTimeOfDayField({
    super.key,
    this.decoration,
    this.brightness,
    this.binding,
    this.value,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.locked = false,
    this.timePickerEntryMode = TimePickerEntryMode.dial,
  });

  final UnifiedInputDecoration? decoration;
  final UnifiedInputBrightness? brightness;

  final AppInputController<TimeOfDay>? binding;
  final TimeOfDay? value;

  final String? Function(String value)? validator;
  final ValueChanged<TimeOfDay?>? onChanged;
  final ValueChanged<String>? onSubmitted;

  final bool locked;
  final TimePickerEntryMode timePickerEntryMode;

  @override
  State<UnifiedTimeOfDayField> createState() => _UnifiedTimeOfDayFieldState();
}

class _UnifiedTimeOfDayFieldState extends State<UnifiedTimeOfDayField> {
  late final TextEditingController _txt = TextEditingController();

  @override
  void initState() {
    super.initState();
    _syncText();
    widget.binding?.addListener(_onBinding);
  }

  @override
  void didUpdateWidget(covariant UnifiedTimeOfDayField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.binding != widget.binding) {
      oldWidget.binding?.removeListener(_onBinding);
      widget.binding?.addListener(_onBinding);
    }
    if (oldWidget.value != widget.value || oldWidget.binding?.value != widget.binding?.value) {
      _syncText();
    }
  }

  void _onBinding() {
    _syncText();
    setState(() {});
  }

  void _syncText() {
    final t = widget.binding?.value ?? widget.value;
    _txt.text = t?.toJson ?? '';
  }

  @override
  void dispose() {
    widget.binding?.removeListener(_onBinding);
    _txt.dispose();
    super.dispose();
  }

  Future<void> _pick(BuildContext context) async {
    final initial = widget.binding?.value ?? widget.value ?? TimeOfDay.now();
    final picked = await TimePickerUtils.show(
      context,
      title: widget.decoration?.label,
      initialTime: initial,
      timePickerEntryMode: widget.timePickerEntryMode,
    );
    if (!context.mounted) return;
    if (picked == null) return;
    _txt.text = picked.toJson ?? '';
    widget.onChanged?.call(picked);
    final b = widget.binding;
    if (b != null && b.value != picked) {
      b.value = picked;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final d = resolveUnifiedDecoration(context, overrides: widget.decoration, brightness: widget.brightness);

    return GestureDetector(
      onTap: widget.locked ? null : () => _pick(context),
      child: AbsorbPointer(
        absorbing: true,
        child: UnifiedBaseTextField(
          controller: _txt,
          locked: widget.locked,
          readOnly: true,
          label: d.label,
          placeholder: d.placeholder ?? d.label,
          labelStyle: d.labelStyle,
          style: d.fieldStyle,
          backgroundColor: d.backgroundColor ?? Colors.black26,
          headerBackgroundColor: d.headerBackgroundColor ?? d.backgroundColor ?? Colors.black26,
          borderRadius: d.borderRadius ?? const BorderRadius.all(Radius.circular(18)),
          borderSide: d.borderSide,
          height: d.height,
          rowLabelRatio: d.rowLabelRatio,
          labelInRow: d.labelInRow,
          requiredField: d.requiredField,
          showError: d.showError,
          validationColor: d.validationColor,
          validationIcon: d.validationIcon,
          prefix: d.prefix,
          prefixIcon: d.prefixIcon,
          suffixIcon: d.suffixIcon ?? const Icon(Icons.schedule),
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
