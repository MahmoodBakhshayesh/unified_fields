import 'package:flutter/material.dart';

import '../controllers/field_controller_sync.dart';
import '../controllers/unified_async_query_multi_picker_field_controller.dart';
import 'unified_async_query_picker_sheet.dart';
import 'unified_input_picker.dart';
import 'unified_base_text_field.dart';
import 'unified_input_brightness.dart';
import 'unified_field_decoration_context.dart';
import 'unified_input_decoration.dart';
import 'unified_input_theme.dart';
import 'unified_picker_item_builders.dart';

/// Read-only multi-picker: tap opens a sheet with header search, remote results,
/// and a temp selection list (confirm to apply).
///
/// Each search keeps prior picks in the in-sheet temp list; tap toggles add/remove.
class UnifiedAsyncQueryMultiPicker<T> extends StatefulWidget {
  /// Creates an async query multi-picker field.
  const UnifiedAsyncQueryMultiPicker({
    super.key,
    required this.queryFetcher,
    required this.label,
    required this.values,
    this.queryThreshold = 3,
    this.queryDebounce = const Duration(milliseconds: 300),
    this.queryPromptMessage,
    this.decoration,
    this.decorationSet,
    this.brightness,
    this.binding,
    this.fieldController,
    this.onChanged,
    this.valueToString,
    this.itemToWidget,
    this.locked = false,
    this.isDisabled = false,
    this.validator,
    this.validationOverrideMessage,
    this.placeholder,
    this.isRequired = false,
    this.pickerSheetStyle,
    this.pickerSheetBackgroundColor,
    this.pickerHeaderStyle,
    this.pickerSheetModalSettings,
    this.searchAutoFocus = true,
    this.showClearButton = true,
  });

  /// Remote search: `query` → matching items.
  final UnifiedAsyncQueryFetcher<T> queryFetcher;

  /// Label for the field and sheet title fallback.
  final String label;

  /// Current committed selection.
  final List<T> values;

  /// Minimum characters before [queryFetcher] is called.
  final int queryThreshold;

  /// Debounce between keystrokes and fetch.
  final Duration queryDebounce;

  /// Sheet hint when the query is too short (defaults to [UnifiedFieldsStrings.asyncQueryTypeToFetch]).
  final String? queryPromptMessage;

  /// Hint text shown when empty.
  final String? placeholder;

  /// Visual chrome overrides.
  final UnifiedInputDecoration? decoration;

  /// Per-state decorations (focus, error, valid, locked, disabled, …).
  final UnifiedInputDecorationSet? decorationSet;

  /// Forces a brightness regardless of the ambient [Theme].
  final UnifiedInputBrightness? brightness;

  /// Optional external state binding.
  final UnifiedInputPicker<List<T>>? binding;

  /// Preferred imperative handle; syncs with [binding] on change.
  final UnifiedAsyncQueryMultiPickerFieldController<T>? fieldController;

  /// Called when the user confirms (or clears) the selection.
  final ValueChanged<List<T>>? onChanged;

  /// Renders an item to its display text.
  final String Function(T value)? valueToString;

  /// Custom row widget for each result in the sheet.
  final Widget Function(T value)? itemToWidget;

  /// When true, the field cannot be edited or opened.
  final bool locked;

  /// When true, the field is non-interactive.
  final bool isDisabled;

  /// Synchronous validation on the display string.
  final String? Function(String value)? validator;

  /// Forces an error message regardless of [validator].
  final String? validationOverrideMessage;

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

  /// Whether the sheet search field auto-focuses on open.
  final bool searchAutoFocus;

  /// Whether the sheet shows a clear-selection control in the header.
  final bool showClearButton;

  @override
  State<UnifiedAsyncQueryMultiPicker<T>> createState() =>
      _UnifiedAsyncQueryMultiPickerState<T>();
}

class _UnifiedAsyncQueryMultiPickerState<T>
    extends State<UnifiedAsyncQueryMultiPicker<T>> {
  late final TextEditingController _txt = TextEditingController();

  List<T> get _effective => unifiedEffectiveListValue(
    fieldController: widget.fieldController,
    binding: widget.binding,
    direct: widget.values,
  );

  String _display(List<T> vs) =>
      vs
          .map(
            (e) => unifiedPickerItemLabel(e, valueToString: widget.valueToString),
          )
          .join(', ');

  void _syncText() => _txt.text = _display(_effective);

  void _syncFieldController() {
    final dec = resolveUnifiedDecoration(
      context,
      overrides: widget.decoration,
      brightness: widget.brightness,
    );
    widget.fieldController?.bindAsyncQueryPicker(
      label: dec.placeholder ?? dec.label ?? widget.label,
      queryFetcher: widget.queryFetcher,
      queryThreshold: widget.queryThreshold,
      queryDebounce: widget.queryDebounce,
      queryPromptMessage: widget.queryPromptMessage,
    );
    if (widget.validationOverrideMessage == null) {
      syncMultiPickerStringValidatorToFieldController(
        widget.fieldController,
        widget.validator,
        (values) => _display(values ?? const []),
      );
    }
    attachUnifiedFieldHandles(
      opener: _presentPicker,
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
    _syncFieldController();
  }

  @override
  void didUpdateWidget(covariant UnifiedAsyncQueryMultiPicker<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fieldController != widget.fieldController ||
        oldWidget.binding != widget.binding) {
      detachUnifiedFieldHandles(
        binding: oldWidget.binding,
        fieldController: oldWidget.fieldController,
      );
    }
    if (oldWidget.binding != widget.binding ||
        oldWidget.fieldController != widget.fieldController) {
      oldWidget.binding?.removeListener(_onBinding);
      oldWidget.fieldController?.removeListener(_onBinding);
      widget.binding?.addListener(_onBinding);
      widget.fieldController?.addListener(_onBinding);
    }
    if (oldWidget.fieldController != widget.fieldController ||
        oldWidget.label != widget.label ||
        oldWidget.decoration != widget.decoration ||
        oldWidget.validator != widget.validator ||
        oldWidget.queryFetcher != widget.queryFetcher) {
      _syncFieldController();
    }
    if (oldWidget.values != widget.values ||
        oldWidget.binding?.value != widget.binding?.value ||
        oldWidget.fieldController?.value != widget.fieldController?.value) {
      _syncText();
    }
    if (oldWidget.validationOverrideMessage !=
        widget.validationOverrideMessage) {
      setState(() {});
    }
  }

  void _onBinding() {
    final fc = widget.fieldController;
    if (fc != null) {
      syncUnifiedFieldListValue<T>(
        value: List<T>.from(fc.value ?? const []),
        onChanged: widget.onChanged,
        binding: widget.binding,
      );
    }
    setState(_syncText);
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

  Future<void> _presentPicker(BuildContext context) async {
    if (widget.locked || widget.isDisabled) return;
    if (!mounted || !context.mounted) return;

    final dec = resolveUnifiedDecoration(
      context,
      overrides: widget.decoration,
      brightness: widget.brightness,
    );
    final sheetChrome = resolvePickerSheetStyleOverrides(
      pickerSheetStyle: widget.pickerSheetStyle,
      pickerSheetBackgroundColor: widget.pickerSheetBackgroundColor,
      pickerHeaderStyle: widget.pickerHeaderStyle,
    );

    final result = await showUnifiedAsyncQueryMultiPickerSheet<T>(
      context: context,
      label: dec.placeholder ?? dec.label ?? widget.label,
      queryFetcher: widget.queryFetcher,
      queryThreshold: widget.queryThreshold,
      queryDebounce: widget.queryDebounce,
      queryPromptMessage: widget.queryPromptMessage,
      values: List<T>.from(_effective),
      valueToString: widget.valueToString,
      itemToWidget: widget.itemToWidget,
      searchAutoFocus: widget.searchAutoFocus,
      showClearButton: widget.showClearButton,
      sheetBackgroundColor: sheetChrome.sheetBackgroundColor,
      pickerHeaderStyle: sheetChrome.pickerHeaderStyle,
      pickerSheetStyle: widget.pickerSheetStyle,
      pickerSheetModalSettings: widget.pickerSheetModalSettings,
    );

    if (!mounted || result == null) return;

    _commit(result);
  }

  void _commit(List<T> v) {
    syncUnifiedFieldListValue<T>(
      value: v,
      onChanged: widget.onChanged,
      binding: widget.binding,
      fieldController: widget.fieldController,
    );
    _syncText();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final chrome = resolveUnifiedFieldDecorationContext(
      context,
      decoration: widget.decoration,
      decorationSet: widget.decorationSet,
      brightness: widget.brightness,
    );
    final dec = chrome.resolved;

    return GestureDetector(
      onTap: widget.locked || widget.isDisabled
          ? null
          : () => _presentPicker(context),
      child: AbsorbPointer(
        child: UnifiedBaseTextField(
          decorationSet: chrome.activeSet,
          brightness: widget.brightness,
          controller: _txt,
          focusNode: unifiedEffectiveFocusNode(
            fieldController: widget.fieldController,
            binding: widget.binding,
          ),
          errorText: widget.fieldController?.errorText,
          readOnly: true,
          label: dec.label ?? widget.label,
          placeholder: widget.placeholder ?? dec.placeholder ?? widget.label,
          labelStyle: dec.labelStyle,
          style: dec.fieldStyle,
          placeholderStyle: dec.placeholderStyle,
          backgroundColor: dec.backgroundColor,
          headerBackgroundColor:
              dec.headerBackgroundColor ?? dec.backgroundColor,
          borderRadius: dec.borderRadius,
          borderSide: dec.borderSide,
          height: dec.height,
          rowLabelRatio: dec.optionalRowLabelRatio,
          labelInRow: dec.labelInRow,
          labelMode: dec.labelMode,
          requiredField: widget.isRequired || dec.requiredField,
          showError: dec.showError,
          validationColor: dec.validationColor,
          validationIcon: dec.validationIcon,
          prefix: dec.prefix,
          prefixIcon: dec.prefixIcon,
          suffixIcon:
              dec.suffixIcon ??
              (widget.isDisabled || widget.locked
                  ? null
                  : UnifiedInputThemeResolver.defaultSuffixIcon(
                      context,
                      UnifiedInputFieldSuffixKind.picker,
                      UnifiedInputThemeResolver.resolvePalette(context),
                    )),
          padding: dec.contentPadding,
          isDisabled: widget.isDisabled,
          locked: widget.locked,
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
