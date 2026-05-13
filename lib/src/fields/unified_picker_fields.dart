import '../app_colors.dart';
import 'package:flutter/material.dart';

import 'app_input_controller.dart';
import 'unified_base_text_field.dart';
import 'unified_input_brightness.dart';
import 'unified_input_decoration.dart';
import 'unified_multi_picker_sheet.dart';
import 'unified_picker_sheet.dart';

/// Single-select field backed by [PickerSheetWidget] (search + scroll-to-item list).
class UnifiedSinglePickerField<T> extends StatefulWidget {
  const UnifiedSinglePickerField({
    super.key,
    required this.items,
    required this.label,
    this.decoration,
    this.brightness,
    this.binding,
    this.value,
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
    this.validationOverrideMessage,
    this.placeholder,
  });

  final List<T> items;
  final String label;
  final String? placeholder;

  final UnifiedInputDecoration? decoration;
  final UnifiedInputBrightness? brightness;

  final AppInputController<T>? binding;
  final T? value;
  final ValueChanged<T?>? onChanged;

  final String Function(T value)? valueToString;
  final String Function(T value)? searchBuilder;
  final Widget Function(T value)? itemToWidget;

  final List<T> suggestion;
  final bool hasSearch;
  final bool searchAutoFocus;
  final bool showClearButton;
  final bool locked;
  final String? Function(String value)? validator;

  /// When non-null, drives the error strip and [validator] is ignored (e.g. [FormField] errors).
  final String? validationOverrideMessage;

  @override
  State<UnifiedSinglePickerField<T>> createState() => _UnifiedSinglePickerFieldState<T>();
}

class _UnifiedSinglePickerFieldState<T> extends State<UnifiedSinglePickerField<T>> {
  late final TextEditingController _txt = TextEditingController();

  String _display(T? v) {
    if (v == null) return '';
    return widget.valueToString?.call(v) ?? v.toString();
  }

  T? get _effective => widget.binding?.value ?? widget.value;

  void _syncText() {
    _txt.text = _display(_effective);
  }

  @override
  void initState() {
    super.initState();
    _syncText();
    widget.binding?.addListener(_onBinding);
  }

  @override
  void didUpdateWidget(covariant UnifiedSinglePickerField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.binding != widget.binding) {
      oldWidget.binding?.removeListener(_onBinding);
      widget.binding?.addListener(_onBinding);
    }
    if (oldWidget.value != widget.value || oldWidget.binding?.value != widget.binding?.value) {
      _syncText();
    }
    if (oldWidget.validationOverrideMessage != widget.validationOverrideMessage) {
      setState(() {});
    }
  }

  void _onBinding() => setState(_syncText);

  @override
  void dispose() {
    widget.binding?.removeListener(_onBinding);
    _txt.dispose();
    super.dispose();
  }

  Future<void> _open(BuildContext context) async {
    if (widget.locked) return;
    final dec = resolveUnifiedDecoration(context, overrides: widget.decoration, brightness: widget.brightness);
    FocusScope.of(context).requestFocus(FocusNode());
    final dynamic result = await showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      builder: (c) => Padding(
        padding: EdgeInsets.zero,
        child: PickerSheetWidget<T>(
          suggestion: widget.suggestion,
          value: _effective,
          searchAutoFocus: widget.searchAutoFocus,
          hasClear: widget.showClearButton,
          searchBuilder: widget.searchBuilder,
          items: widget.items,
          label: dec.placeholder ?? dec.label ?? widget.label,
          itemToWidget: widget.itemToWidget,
          hasSearch: widget.hasSearch,
        ),
      ),
    );

    if (!context.mounted) return;

    if (result == Null) {
      _commit(null);
    } else if (result != null) {
      _commit(result as T);
    }
  }

  void _commit(T? v) {
    widget.onChanged?.call(v);
    final b = widget.binding;
    if (b != null && b.value != v) {
      b.value = v;
    }
    _syncText();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final dec = resolveUnifiedDecoration(context, overrides: widget.decoration, brightness: widget.brightness);

    return GestureDetector(
      onTap: widget.locked ? null : () => _open(context),
      child: AbsorbPointer(
        child: UnifiedBaseTextField(
          controller: _txt,
          readOnly: true,
          label: dec.label ?? widget.label,
          placeholder: widget.placeholder??dec.placeholder ?? widget.label,
          labelStyle: dec.labelStyle,
          style: dec.fieldStyle,
          backgroundColor: dec.backgroundColor ?? Colors.black26,
          headerBackgroundColor: dec.headerBackgroundColor ?? dec.backgroundColor ?? Colors.black26,
          borderRadius: dec.borderRadius ?? const BorderRadius.all(Radius.circular(18)),
          borderSide: dec.borderSide,
          height: dec.height,
          rowLabelRatio: dec.rowLabelRatio,
          labelInRow: dec.labelInRow,
          requiredField: dec.requiredField,
          showError: dec.showError,
          validationColor: dec.validationColor,
          validationIcon: dec.validationIcon,
          prefix: dec.prefix,
          prefixIcon: dec.prefixIcon,
          suffixIcon: dec.suffixIcon ??  Icon(Icons.arrow_drop_down,color: AppColors.textColorDark,),
          padding: dec.contentPadding,
          validator: (value) {
            final o = widget.validationOverrideMessage;
            if (o != null) {
              return o.isEmpty ? null : o;
            }
            return widget.validator?.call(value);
          },
        ),
      ),
    );
  }
}

/// Multi-select field backed by [MultiPickerSheetWidget].
class UnifiedMultiPickerField<T> extends StatefulWidget {
  const UnifiedMultiPickerField({
    super.key,
    required this.items,
    required this.label,
    required this.values,
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
    this.validationOverrideMessage,
  });

  final List<T> items;
  final String label;
  final List<T> values;

  final UnifiedInputDecoration? decoration;
  final UnifiedInputBrightness? brightness;

  final AppInputController<List<T>>? binding;
  final ValueChanged<List<T>>? onChanged;

  final String Function(T value)? valueToString;
  final String Function(T value)? searchBuilder;
  final Widget Function(T value)? itemToWidget;

  final List<T> suggestion;
  final bool hasSearch;
  final bool searchAutoFocus;
  final bool showClearButton;
  final bool locked;
  final String? Function(String value)? validator;

  /// When non-null, drives the error strip and [validator] is ignored (e.g. [FormField] errors).
  final String? validationOverrideMessage;

  @override
  State<UnifiedMultiPickerField<T>> createState() => _UnifiedMultiPickerFieldState<T>();
}

class _UnifiedMultiPickerFieldState<T> extends State<UnifiedMultiPickerField<T>> {
  late final TextEditingController _txt = TextEditingController();

  List<T> get _effective => widget.binding?.value ?? widget.values;

  String _display(List<T> vs) => vs.map((e) => widget.valueToString?.call(e) ?? e.toString()).join(', ');

  void _syncText() {
    _txt.text = _display(_effective);
  }

  @override
  void initState() {
    super.initState();
    _syncText();
    widget.binding?.addListener(_onBinding);
  }

  @override
  void didUpdateWidget(covariant UnifiedMultiPickerField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.binding != widget.binding) {
      oldWidget.binding?.removeListener(_onBinding);
      widget.binding?.addListener(_onBinding);
    }
    if (oldWidget.values != widget.values || oldWidget.binding?.value != widget.binding?.value) {
      _syncText();
    }
    if (oldWidget.validationOverrideMessage != widget.validationOverrideMessage) {
      setState(() {});
    }
  }

  void _onBinding() => setState(_syncText);

  @override
  void dispose() {
    widget.binding?.removeListener(_onBinding);
    _txt.dispose();
    super.dispose();
  }

  Future<void> _open(BuildContext context, UnifiedInputDecoration dec) async {
    if (widget.locked) return;
    FocusScope.of(context).requestFocus(FocusNode());
    final dynamic result = await showModalBottomSheet<dynamic>(
      context: context,
      isScrollControlled: true,
      builder: (c) => Padding(
        padding: EdgeInsets.zero,
        child: MultiPickerSheetWidget<T>(
          suggestion: widget.suggestion,
          values: List<T>.from(_effective),
          searchAutoFocus: widget.searchAutoFocus,
          hasClear: widget.showClearButton,
          searchBuilder: widget.searchBuilder,
          items: widget.items,
          label: dec.placeholder ?? dec.label ?? widget.label,
          itemToWidget: widget.itemToWidget,
          hasSearch: widget.hasSearch,
        ),
      ),
    );

    if (!context.mounted) return;

    if (result == Null) {
      _commit(<T>[]);
    } else if (result != null) {
      final raw = result as List;
      _commit(raw.cast<T>().toList());
    }
  }

  void _commit(List<T> v) {
    widget.onChanged?.call(v);
    final b = widget.binding;
    if (b != null) {
      b.value = v;
    }
    _syncText();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final dec = resolveUnifiedDecoration(context, overrides: widget.decoration, brightness: widget.brightness);

    return GestureDetector(
      onTap: widget.locked ? null : () => _open(context, dec),
      child: AbsorbPointer(
        child: UnifiedBaseTextField(
          controller: _txt,
          readOnly: true,
          label: dec.label ?? widget.label,
          placeholder: dec.placeholder ?? widget.label,
          labelStyle: dec.labelStyle,
          style: dec.fieldStyle,
          backgroundColor: dec.backgroundColor ?? Colors.black26,
          headerBackgroundColor: dec.headerBackgroundColor ?? dec.backgroundColor ?? Colors.black26,
          borderRadius: dec.borderRadius ?? const BorderRadius.all(Radius.circular(18)),
          borderSide: dec.borderSide,
          height: dec.height,
          rowLabelRatio: dec.rowLabelRatio,
          labelInRow: dec.labelInRow,
          requiredField: dec.requiredField,
          showError: dec.showError,
          validationColor: dec.validationColor,
          validationIcon: dec.validationIcon,
          prefix: dec.prefix,
          prefixIcon: dec.prefixIcon,
          suffixIcon: dec.suffixIcon ??  Icon(Icons.arrow_drop_down,color: AppColors.textColorDark,),
          padding: dec.contentPadding,
          validator: (value) {
            final o = widget.validationOverrideMessage;
            if (o != null) {
              return o.isEmpty ? null : o;
            }
            return widget.validator?.call(value);
          },
        ),
      ),
    );
  }
}
