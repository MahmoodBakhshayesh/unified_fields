import '../unified_fields_context.dart';
import '../unified_colors.dart';
import 'package:flutter/material.dart';


import 'app_input_controller.dart';
import 'unified_base_text_field.dart';
import 'unified_input_brightness.dart';
import 'unified_input_decoration.dart';
import 'unified_multi_picker_sheet.dart';
import 'unified_picker_sheet.dart';

/// Like [UnifiedSinglePickerField] but loads choices with [itemProvider] when the
/// field or dropdown [IconButton] is pressed (loading overlay, then sheet).
class UnifiedAsyncPickerField<T> extends StatefulWidget {
  /// Creates an async single-select picker field.
  const UnifiedAsyncPickerField({
    super.key,
    required this.itemProvider,
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
    this.isRequired = false,
  });

  /// Fetched when the user opens the picker; replaces a static [items] list.
  final Future<List<T>> Function() itemProvider;

  /// Label for the field and sheet title fallback.
  final String label;

  /// Hint text shown when no value is selected. Falls back to
  /// [UnifiedInputDecoration.placeholder] then [label].
  final String? placeholder;

  /// Visual chrome (colors, sizes, borders, etc.).
  final UnifiedInputDecoration? decoration;

  /// Override [Theme] brightness for the unified palette.
  final UnifiedInputBrightness? brightness;

  /// Optional external state binding.
  final AppInputController<T>? binding;

  /// Direct value when not using [binding].
  final T? value;

  /// Called when the user picks (or clears) a value.
  final ValueChanged<T?>? onChanged;

  /// Renders an item to its display text. Defaults to [Object.toString].
  final String Function(T value)? valueToString;

  /// Custom searchable text per item.
  final String Function(T value)? searchBuilder;

  /// Custom row builder inside the sheet.
  final Widget Function(T value)? itemToWidget;

  /// Optional suggestion list pinned above the searchable list.
  final List<T> suggestion;

  /// Whether the sheet shows a search field.
  final bool hasSearch;

  /// Autofocus the search field on open.
  final bool searchAutoFocus;

  /// Show a Clear button in the sheet header.
  final bool showClearButton;

  /// When true, the field is non-interactive.
  final bool locked;

  /// Synchronous validator on the displayed text.
  final String? Function(String value)? validator;

  /// When non-null, drives the error strip and [validator] is ignored (e.g. [FormField] errors).
  final String? validationOverrideMessage;

  /// Whether the field is required. Overrides [UnifiedInputDecoration.requiredField] when set.
  final bool isRequired;

  @override
  State<UnifiedAsyncPickerField<T>> createState() => _UnifiedAsyncPickerFieldState<T>();
}

class _UnifiedAsyncPickerFieldState<T> extends State<UnifiedAsyncPickerField<T>> {
  late final TextEditingController _txt = TextEditingController();
  List<T> _items = [];
  bool _loading = false;

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
  void didUpdateWidget(covariant UnifiedAsyncPickerField<T> oldWidget) {
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

  Future<void> _open() async {
    if (widget.locked || _loading) return;
    if (!mounted) return;

    final dec = resolveUnifiedDecoration(context, overrides: widget.decoration, brightness: widget.brightness);

    setState(() => _loading = true);
    try {
      _items = await widget.itemProvider();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
    if (!mounted) return;

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
          items: _items,
          label: dec.placeholder ?? dec.label ?? widget.label,
          itemToWidget: widget.itemToWidget,
          hasSearch: widget.hasSearch,
        ),
      ),
    );

    if (!mounted) return;

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

    final suffix = dec.suffixIcon ??
        IconButton(
          onPressed: widget.locked || _loading ? null : _open,
          icon: Icon(
            Icons.arrow_drop_down,
            color: UnifiedColors.textColorDark,
          ),
        );

    return GestureDetector(
      onTap: widget.locked || _loading ? null : _open,
      child: Stack(
        alignment: Alignment.center,
        children: [
          UnifiedBaseTextField(
            controller: _txt,
            readOnly: true,
            label: dec.label ?? widget.label,
            placeholder: widget.placeholder ?? dec.placeholder ?? widget.label,
            labelStyle: dec.labelStyle,
            style: dec.fieldStyle,
            backgroundColor: dec.backgroundColor ?? Colors.black26,
            headerBackgroundColor: dec.headerBackgroundColor ?? dec.backgroundColor ?? Colors.black26,
            borderRadius: dec.borderRadius ?? const BorderRadius.all(Radius.circular(18)),
            borderSide: dec.borderSide,
            height: dec.height,
            rowLabelRatio: dec.rowLabelRatio,
            labelInRow: dec.labelInRow,
            requiredField: widget.isRequired || dec.requiredField,
            showError: dec.showError,
            validationColor: dec.validationColor,
            validationIcon: dec.validationIcon,
            prefix: dec.prefix,
            prefixIcon: dec.prefixIcon,
            suffixIcon: suffix,
            padding: dec.contentPadding,
            validator: (value) {
              final o = widget.validationOverrideMessage;
              if (o != null) {
                return o.isEmpty ? null : o;
              }
              return widget.validator?.call(value);
            },
          ),
          if (_loading)
            Positioned.fill(
              child: AbsorbPointer(
                child: Material(
                  color: Colors.black.withValues(alpha: 0.05),
                  child: Center(
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: context.mainColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Like [UnifiedMultiPickerField] but loads choices with [itemProvider] when the
/// field or dropdown [IconButton] is pressed (loading overlay, then sheet).
class UnifiedAsyncMultiPickerField<T> extends StatefulWidget {
  /// Creates an async multi-select picker field.
  const UnifiedAsyncMultiPickerField({
    super.key,
    required this.itemProvider,
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
    this.placeholder,
    this.isRequired = false,
  });

  /// Fetched when the user opens the picker; replaces a static items list.
  final Future<List<T>> Function() itemProvider;

  /// Label for the field and sheet title fallback.
  final String label;

  /// Current selection.
  final List<T> values;

  /// Hint text shown when no value is selected. Falls back to
  /// [UnifiedInputDecoration.placeholder] then [label].
  final String? placeholder;

  /// Visual chrome.
  final UnifiedInputDecoration? decoration;

  /// Override [Theme] brightness for the unified palette.
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

  /// Optional suggestion list pinned above the searchable list.
  final List<T> suggestion;

  /// Whether the sheet shows a search field.
  final bool hasSearch;

  /// Autofocus the search field on open.
  final bool searchAutoFocus;

  /// Show a Clear button in the sheet header.
  final bool showClearButton;

  /// When true, the field is non-interactive.
  final bool locked;

  /// Synchronous validator on the displayed text.
  final String? Function(String value)? validator;

  /// When non-null, drives the error strip and [validator] is ignored (e.g. [FormField] errors).
  final String? validationOverrideMessage;

  /// Whether the field is required. Overrides [UnifiedInputDecoration.requiredField] when set.
  final bool isRequired;

  @override
  State<UnifiedAsyncMultiPickerField<T>> createState() => _UnifiedAsyncMultiPickerFieldState<T>();
}

class _UnifiedAsyncMultiPickerFieldState<T> extends State<UnifiedAsyncMultiPickerField<T>> {
  late final TextEditingController _txt = TextEditingController();
  List<T> _items = [];
  bool _loading = false;

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
  void didUpdateWidget(covariant UnifiedAsyncMultiPickerField<T> oldWidget) {
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

  Future<void> _open(UnifiedInputDecoration dec) async {
    if (widget.locked || _loading) return;
    if (!mounted) return;

    setState(() => _loading = true);
    try {
      _items = await widget.itemProvider();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
    if (!mounted) return;

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
          items: _items,
          label: dec.placeholder ?? dec.label ?? widget.label,
          itemToWidget: widget.itemToWidget,
          hasSearch: widget.hasSearch,
        ),
      ),
    );

    if (!mounted) return;

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

    final suffix = dec.suffixIcon ??
        IconButton(
          onPressed: widget.locked || _loading ? null : () => _open(dec),
          icon: Icon(
            Icons.arrow_drop_down,
            color: UnifiedColors.textColorDark,
          ),
        );

    return GestureDetector(
      onTap: widget.locked || _loading ? null : () => _open(dec),
      child: Stack(
        alignment: Alignment.center,
        children: [
          UnifiedBaseTextField(
            controller: _txt,
            readOnly: true,
            label: dec.label ?? widget.label,
            placeholder: widget.placeholder ?? dec.placeholder ?? widget.label,
            labelStyle: dec.labelStyle,
            style: dec.fieldStyle,
            backgroundColor: dec.backgroundColor ?? Colors.black26,
            headerBackgroundColor: dec.headerBackgroundColor ?? dec.backgroundColor ?? Colors.black26,
            borderRadius: dec.borderRadius ?? const BorderRadius.all(Radius.circular(18)),
            borderSide: dec.borderSide,
            height: dec.height,
            rowLabelRatio: dec.rowLabelRatio,
            labelInRow: dec.labelInRow,
            requiredField: widget.isRequired || dec.requiredField,
            showError: dec.showError,
            validationColor: dec.validationColor,
            validationIcon: dec.validationIcon,
            prefix: dec.prefix,
            prefixIcon: dec.prefixIcon,
            suffixIcon: suffix,
            padding: dec.contentPadding,
            validator: (value) {
              final o = widget.validationOverrideMessage;
              if (o != null) {
                return o.isEmpty ? null : o;
              }
              return widget.validator?.call(value);
            },
          ),
          if (_loading)
            Positioned.fill(
              child: AbsorbPointer(
                child: Material(
                  color: Colors.black.withValues(alpha: 0.05),
                  child: Center(
                    child: SizedBox(
                      width: 36,
                      height: 36,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: context.mainColor,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
