import 'package:flutter/material.dart';

import '../controllers/field_controller_sync.dart';
import '../controllers/unified_async_picker_field_controller.dart';
import 'unified_input_picker.dart';
import 'unified_base_text_field.dart';
import 'unified_input_brightness.dart';
import 'unified_field_decoration_context.dart';
import 'unified_input_decoration.dart';
import 'unified_input_theme.dart';
import 'unified_multi_picker_sheet.dart';
import 'unified_picker_item_builders.dart';
import 'unified_picker_keyboard.dart';
import 'unified_picker_sheet.dart';

/// Like [UnifiedSinglePickerField] but loads choices with [itemProvider] when the
/// field or dropdown [IconButton] is pressed (suffix spinner while loading, then sheet).
class UnifiedAsyncPickerField<T> extends StatefulWidget {
  /// Creates an async single-select picker field.
  const UnifiedAsyncPickerField({
    super.key,
    required this.itemProvider,
    required this.label,
    this.decoration,
    this.decorationSet,
    this.brightness,
    this.binding,
    this.fieldController,
    this.value,
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
    this.validationOverrideMessage,
    this.placeholder,
    this.isRequired = false,
    this.pickerSheetStyle,
    this.pickerSheetBackgroundColor,
    this.pickerHeaderStyle,
    this.pickerSheetModalSettings,
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

  /// Per-state decorations (focus, error, valid, locked, disabled, …).
  final UnifiedInputDecorationSet? decorationSet;

  /// Override [Theme] brightness for the unified palette.
  final UnifiedInputBrightness? brightness;

  /// Optional external state binding.
  final UnifiedInputPicker<T>? binding;

  /// Preferred imperative handle ([UnifiedAsyncPickerFieldController.openPickerAsync], validate, focus).
  final UnifiedAsyncPickerFieldController<T>? fieldController;

  /// Direct value when not using [binding] or [fieldController].
  final T? value;

  /// Called when the user picks (or clears) a value.
  final ValueChanged<T?>? onChanged;

  /// Renders an item to its display text. Defaults to [Object.toString].
  final String Function(T value)? valueToString;

  /// Custom searchable text per item.
  final String Function(T value)? searchBuilder;

  /// Custom row builder inside the sheet.
  final Widget Function(T value)? itemToWidget;

  /// Custom grid tile builder; when set, the sheet uses a [GridView].
  final UnifiedPickerGridItemBuilder<T>? gridItemBuilder;

  /// Grid layout when [gridItemBuilder] is set. Defaults to [unifiedPickerDefaultGridDelegate].
  final SliverGridDelegate? gridDelegate;

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

  /// When true, greys out the label and shows a forbid suffix icon.
  final bool isDisabled;

  /// Synchronous validator on the displayed text.
  final String? Function(String value)? validator;

  /// When non-null, drives the error strip and [validator] is ignored (e.g. [FormField] errors).
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

  @override
  State<UnifiedAsyncPickerField<T>> createState() =>
      _UnifiedAsyncPickerFieldState<T>();
}

class _UnifiedAsyncPickerFieldState<T>
    extends State<UnifiedAsyncPickerField<T>> {
  late final TextEditingController _txt = TextEditingController();
  List<T> _items = [];
  bool _loading = false;

  String _display(T? v) {
    if (v == null) return '';
    return unifiedPickerItemLabel(v, valueToString: widget.valueToString);
  }

  T? get _effective => unifiedEffectiveValue(
    fieldController: widget.fieldController,
    binding: widget.binding,
    direct: widget.value,
  );

  void _syncText() {
    _txt.text = _display(_effective);
  }

  void _syncFieldController() {
    final dec = resolveUnifiedDecoration(
      context,
      overrides: widget.decoration,
      brightness: widget.brightness,
    );
    widget.fieldController?.bindPickerLabel(
      dec.placeholder ?? dec.label ?? widget.label,
    );
    if (widget.validationOverrideMessage == null) {
      syncPickerStringValidatorToFieldController(
        widget.fieldController,
        widget.validator,
        _display,
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
  void didUpdateWidget(covariant UnifiedAsyncPickerField<T> oldWidget) {
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
        oldWidget.validator != widget.validator) {
      _syncFieldController();
    }
    if (oldWidget.value != widget.value ||
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
      syncUnifiedFieldValue<T>(
        value: fc.value,
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
    if (widget.locked || widget.isDisabled || _loading) return;
    if (!mounted) return;

    final dec = resolveUnifiedDecoration(
      context,
      overrides: widget.decoration,
      brightness: widget.brightness,
    );

    setState(() => _loading = true);
    try {
      _items = await widget.itemProvider();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
    if (!mounted) return;
    if (!context.mounted) return;

    final sheetChrome = resolvePickerSheetStyleOverrides(
      pickerSheetStyle: widget.pickerSheetStyle,
      pickerSheetBackgroundColor: widget.pickerSheetBackgroundColor,
      pickerHeaderStyle: widget.pickerHeaderStyle,
    );
    unifiedUnfocusBeforeModal(context);
    final dynamic result = await showUnifiedFieldsPickerBottomSheet<dynamic>(
      context: context,
      pickerSheetStyle: widget.pickerSheetStyle,
      modalSettings: widget.pickerSheetModalSettings,
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
          valueToString: widget.valueToString,
          itemToWidget: widget.itemToWidget,
          hasSearch: widget.hasSearch,
          gridItemBuilder: widget.gridItemBuilder,
          gridDelegate: widget.gridDelegate,
          sheetBackgroundColor: sheetChrome.sheetBackgroundColor,
          pickerHeaderStyle: sheetChrome.pickerHeaderStyle,
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

  Future<void> _open() async {
    if (!mounted) return;
    await _presentPicker(context);
  }

  void _commit(T? v) {
    syncUnifiedFieldValue<T>(
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

    final palette = UnifiedInputThemeResolver.resolvePalette(context);
    final Widget? suffix = widget.isDisabled || widget.locked || _loading
        ? dec.suffixIcon
        : (dec.suffixIcon ??
              UnifiedInputThemeResolver.defaultSuffixIcon(
                context,
                UnifiedInputFieldSuffixKind.picker,
                palette,
                onPressed: _open,
              ));

    final field = GestureDetector(
      onTap: widget.locked || widget.isDisabled || _loading ? null : _open,
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
        interactionBlocked: true,
        loading: _loading,
        label: dec.label ?? widget.label,
        placeholder: widget.placeholder ?? dec.placeholder ?? widget.label,
        labelStyle: dec.labelStyle,
        style: dec.fieldStyle,
        placeholderStyle: dec.placeholderStyle,
        backgroundColor: dec.backgroundColor,
        headerBackgroundColor:
          dec.headerBackgroundColor ?? dec.backgroundColor,
        borderRadius:
            dec.borderRadius,
        borderSide: dec.borderSide,
        height: dec.height,
        rowLabelRatio: dec.optionalRowLabelRatio,
        labelMode: dec.labelMode,
        requiredField: widget.isRequired || dec.requiredField,
        showError: dec.showError,
        validationColor: dec.validationColor,
        validationIcon: dec.validationIcon,
        prefix: dec.prefix,
        prefixIcon: dec.prefixIcon,
        suffixIcon: suffix,
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
    );
    return UnifiedPickerKeyboardActivator(
      enabled: !widget.locked && !widget.isDisabled && !_loading,
      onActivate: _open,
      child: field,
    );
  }
}

/// Like [UnifiedMultiPickerField] but loads choices with [itemProvider] when the
/// field or dropdown [IconButton] is pressed (suffix spinner while loading, then sheet).
class UnifiedAsyncMultiPickerField<T> extends StatefulWidget {
  /// Creates an async multi-select picker field.
  const UnifiedAsyncMultiPickerField({
    super.key,
    required this.itemProvider,
    required this.label,
    required this.values,
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
    this.validationOverrideMessage,
    this.placeholder,
    this.isRequired = false,
    this.pickerSheetStyle,
    this.pickerSheetBackgroundColor,
    this.pickerHeaderStyle,
    this.pickerSheetModalSettings,
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

  /// Per-state decorations (focus, error, valid, locked, disabled, …).
  final UnifiedInputDecorationSet? decorationSet;

  /// Override [Theme] brightness for the unified palette.
  final UnifiedInputBrightness? brightness;

  /// Optional external state binding.
  final UnifiedInputPicker<List<T>>? binding;

  /// Preferred imperative handle ([UnifiedAsyncMultiPickerFieldController.openPickerAsync], validate, focus).
  final UnifiedAsyncMultiPickerFieldController<T>? fieldController;

  /// Called when the selection changes.
  final ValueChanged<List<T>>? onChanged;

  /// Renders an item to its display text.
  final String Function(T value)? valueToString;

  /// Custom searchable text per item.
  final String Function(T value)? searchBuilder;

  /// Custom row builder inside the sheet.
  final Widget Function(T value)? itemToWidget;

  /// Custom grid tile builder; when set, the sheet uses a [GridView].
  final UnifiedPickerMultiGridItemBuilder<T>? gridItemBuilder;

  /// Grid layout when [gridItemBuilder] is set. Defaults to [unifiedPickerDefaultGridDelegate].
  final SliverGridDelegate? gridDelegate;

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

  /// When true, greys out the label and shows a forbid suffix icon.
  final bool isDisabled;

  /// Synchronous validator on the displayed text.
  final String? Function(String value)? validator;

  /// When non-null, drives the error strip and [validator] is ignored (e.g. [FormField] errors).
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

  @override
  State<UnifiedAsyncMultiPickerField<T>> createState() =>
      _UnifiedAsyncMultiPickerFieldState<T>();
}

class _UnifiedAsyncMultiPickerFieldState<T>
    extends State<UnifiedAsyncMultiPickerField<T>> {
  late final TextEditingController _txt = TextEditingController();
  List<T> _items = [];
  bool _loading = false;

  List<T> get _effective => unifiedEffectiveListValue(
    fieldController: widget.fieldController,
    binding: widget.binding,
    direct: widget.values,
  );

  String _display(List<T> vs) => vs
      .map(
        (e) => unifiedPickerItemLabel(e, valueToString: widget.valueToString),
      )
      .join(', ');

  void _syncText() {
    _txt.text = _display(_effective);
  }

  void _syncFieldController(UnifiedInputDecoration dec) {
    widget.fieldController?.bindPickerLabel(
      dec.placeholder ?? dec.label ?? widget.label,
    );
    if (widget.validationOverrideMessage == null) {
      syncMultiPickerStringValidatorToFieldController(
        widget.fieldController,
        widget.validator,
        (values) => _display(values ?? const []),
      );
    }
    attachUnifiedFieldHandles(
      opener: (context) => _presentPicker(context, dec),
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
    final dec = resolveUnifiedDecoration(
      context,
      overrides: widget.decoration,
      brightness: widget.brightness,
    );
    _syncFieldController(dec);
  }

  @override
  void didUpdateWidget(covariant UnifiedAsyncMultiPickerField<T> oldWidget) {
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
        oldWidget.validator != widget.validator) {
      final dec = resolveUnifiedDecoration(
        context,
        overrides: widget.decoration,
        brightness: widget.brightness,
      );
      _syncFieldController(dec);
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

  Future<void> _presentPicker(
    BuildContext context,
    UnifiedInputDecoration dec,
  ) async {
    if (widget.locked || widget.isDisabled || _loading) return;
    if (!mounted) return;

    setState(() => _loading = true);
    try {
      _items = await widget.itemProvider();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
    if (!mounted) return;
    if (!context.mounted) return;

    final sheetChrome = resolvePickerSheetStyleOverrides(
      pickerSheetStyle: widget.pickerSheetStyle,
      pickerSheetBackgroundColor: widget.pickerSheetBackgroundColor,
      pickerHeaderStyle: widget.pickerHeaderStyle,
    );
    unifiedUnfocusBeforeModal(context);
    final dynamic result = await showUnifiedFieldsPickerBottomSheet<dynamic>(
      context: context,
      pickerSheetStyle: widget.pickerSheetStyle,
      modalSettings: widget.pickerSheetModalSettings,
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
          valueToString: widget.valueToString,
          itemToWidget: widget.itemToWidget,
          hasSearch: widget.hasSearch,
          gridItemBuilder: widget.gridItemBuilder,
          gridDelegate: widget.gridDelegate,
          sheetBackgroundColor: sheetChrome.sheetBackgroundColor,
          pickerHeaderStyle: sheetChrome.pickerHeaderStyle,
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

  Future<void> _open(UnifiedInputDecoration dec) async {
    if (!mounted) return;
    await _presentPicker(context, dec);
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

    final palette = UnifiedInputThemeResolver.resolvePalette(context);
    final Widget? suffix = widget.isDisabled || widget.locked || _loading
        ? dec.suffixIcon
        : (dec.suffixIcon ??
              UnifiedInputThemeResolver.defaultSuffixIcon(
                context,
                UnifiedInputFieldSuffixKind.multiPicker,
                palette,
                onPressed: () => _open(dec),
              ));

    final field = GestureDetector(
      onTap: widget.locked || widget.isDisabled || _loading
          ? null
          : () => _open(dec),
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
        interactionBlocked: true,
        loading: _loading,
        label: dec.label ?? widget.label,
        placeholder: widget.placeholder ?? dec.placeholder ?? widget.label,
        labelStyle: dec.labelStyle,
        style: dec.fieldStyle,
        placeholderStyle: dec.placeholderStyle,
        backgroundColor: dec.backgroundColor,
        headerBackgroundColor:
          dec.headerBackgroundColor ?? dec.backgroundColor,
        borderRadius:
            dec.borderRadius,
        borderSide: dec.borderSide,
        height: dec.height,
        rowLabelRatio: dec.optionalRowLabelRatio,
        labelMode: dec.labelMode,
        requiredField: widget.isRequired || dec.requiredField,
        showError: dec.showError,
        validationColor: dec.validationColor,
        validationIcon: dec.validationIcon,
        prefix: dec.prefix,
        prefixIcon: dec.prefixIcon,
        suffixIcon: suffix,
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
    );
    return UnifiedPickerKeyboardActivator(
      enabled: !widget.locked && !widget.isDisabled && !_loading,
      onActivate: () => _open(dec),
      child: field,
    );
  }
}
