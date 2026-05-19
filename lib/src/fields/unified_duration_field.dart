import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'unified_base_text_field.dart';
import '../controllers/field_controller_sync.dart';
import '../controllers/unified_duration_field_controller.dart';
import 'unified_input_picker.dart';
import 'unified_input_brightness.dart';
import 'unified_field_decoration_context.dart';
import 'unified_input_decoration.dart';
import '../unified_date_picker_types.dart';
import '../unified_date_wheel_style.dart';
import '../unified_fields_context.dart';
import '../unified_fields_strings.dart';
import '../unified_fields_typography.dart';
import '../unified_duration_column_wheel_picker_sheet.dart';
import '../unified_duration_columns.dart';
import '../unified_time_picker_types.dart';
import 'unified_input_palette.dart';
import 'unified_input_theme.dart';

export '../unified_duration_columns.dart';
export '../unified_time_picker_types.dart'
    show UnifiedFieldsDurationPickerStyle;

/// Formats [d] for display using [pickerColumns] or [granularity].
String unifiedFormatDuration(
  Duration d, {
  UnifiedDurationGranularity? granularity,
  List<UnifiedFieldsDurationColumn>? pickerColumns,
  UnifiedFieldsCalendarKind? calendarKind,
}) {
  final columns = resolveUnifiedDurationColumns(
    pickerColumns: pickerColumns,
    granularity: granularity,
  );
  return formatUnifiedDurationColumns(d, columns, calendarKind: calendarKind);
}

/// Parses display text using [pickerColumns] or [granularity].
Duration? unifiedTryParseDuration(
  String raw, {
  UnifiedDurationGranularity? granularity,
  List<UnifiedFieldsDurationColumn>? pickerColumns,
}) {
  final columns = resolveUnifiedDurationColumns(
    pickerColumns: pickerColumns,
    granularity: granularity,
  );
  return tryParseUnifiedDurationColumns(raw, columns);
}

/// Clamps [d] inside the inclusive range `[min, max]` (each bound is optional).
Duration unifiedClampDuration(Duration d, Duration? min, Duration? max) {
  var x = d;
  if (min != null && x < min) x = min;
  if (max != null && x > max) x = max;
  return x;
}

/// Opens unified duration picker (styled wheels or legacy Cupertino sheet).
Future<Duration?> showUnifiedFieldsDurationPicker({
  required BuildContext context,
  required Duration initial,
  Duration min = Duration.zero,
  Duration max = const Duration(hours: 999),
  String? title,
  UnifiedDurationGranularity granularity =
      UnifiedDurationGranularity.hoursMinutesSeconds,
  List<UnifiedFieldsDurationColumn>? pickerColumns,
  UnifiedFieldsDurationPickerStyle pickerStyle =
      UnifiedFieldsDurationPickerStyle.wheels,
  bool showCalendarKindToggle = true,
  UnifiedFieldsCalendarKind initialCalendarKind =
      UnifiedFieldsCalendarKind.gregorian,
  UnifiedFieldsDateWheelStyle? wheelStyle,
  ValueChanged<UnifiedFieldsCalendarKind>? onConfirmedCalendarKind,
  bool? barrierDismissible,
  UnifiedPickerSheetStyle? pickerSheetStyle,
  UnifiedPickerSheetModalSettings? pickerSheetModalSettings,
}) {
  final modal = UnifiedPickerSheetModalSettings.resolve(
    context,
    pickerSheetStyle: pickerSheetStyle,
    fieldOverride: pickerSheetModalSettings,
    legacyIsDismissible: barrierDismissible,
  );
  final columns = resolveUnifiedDurationColumns(
    pickerColumns: pickerColumns,
    granularity: granularity,
  );
  final clamped = unifiedClampDuration(initial, min, max);

  if (pickerStyle == UnifiedFieldsDurationPickerStyle.cupertino) {
    return showUnifiedFieldsPickerBottomSheet<Duration?>(
      context: context,
      pickerSheetStyle: pickerSheetStyle,
      modalSettings: modal,
      builder: (ctx) {
        final palette = UnifiedInputThemeResolver.resolvePalette(context);
        return UnifiedDurationPickerSheet(
          title: title ?? UnifiedFieldsStrings.instance.defaultDurationTitle,
          palette: palette,
          initial: clamped,
          min: min,
          max: max,
          columns: columns,
          calendarKind: initialCalendarKind,
        );
      },
    ).then((d) => d == null ? null : unifiedClampDuration(d, min, max));
  }

  final sheet = UnifiedFieldsDurationColumnWheelPickerSheet(
    columns: columns,
    initial: clamped,
    maxDuration: max,
    title: title,
    showCalendarKindToggle: showCalendarKindToggle,
    initialCalendarKind: initialCalendarKind,
    wheelStyle: wheelStyle,
    confirmLabel: UnifiedFieldsStrings.instance.done,
    onConfirmedCalendarKind: onConfirmedCalendarKind,
  );

  if (context.unifiedFieldsUseDialogLayout) {
    return showDialog<Duration>(
      context: context,
      barrierDismissible: modal.isDismissible!,
      builder: (ctx) => Dialog(
        clipBehavior: Clip.antiAlias,
        insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 420,
            maxHeight: MediaQuery.sizeOf(ctx).height * 0.92,
          ),
          child: sheet,
        ),
      ),
    ).then((d) => d == null ? null : unifiedClampDuration(d, min, max));
  }

  return showUnifiedFieldsPickerBottomSheet<Duration>(
    context: context,
    pickerSheetStyle: pickerSheetStyle,
    modalSettings: modal,
    clipBehavior: Clip.antiAlias,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
      child: sheet,
    ),
  ).then((d) => d == null ? null : unifiedClampDuration(d, min, max));
}

/// Duration picker / display field with sheet editor (Cupertino-style wheels).
class UnifiedDurationField extends StatefulWidget {
  /// Creates a duration field.
  const UnifiedDurationField({
    super.key,
    this.decoration,
    this.decorationSet,
    this.brightness,
    this.binding,
    this.fieldController,
    this.value,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.granularity = UnifiedDurationGranularity.hoursMinutesSeconds,
    this.pickerColumns,
    this.pickerStyle = UnifiedFieldsDurationPickerStyle.wheels,
    this.showCalendarKindToggle = true,
    this.initialCalendarKind = UnifiedFieldsCalendarKind.gregorian,
    this.wheelStyle,
    this.min,
    this.max,
    this.locked = false,
    this.isDisabled = false,
    this.focusNode,
    this.label,
    this.placeholder,
    this.isRequired = false,
  });

  /// Visual chrome.
  final UnifiedInputDecoration? decoration;

  /// Per-state decorations (focus, error, valid, locked, disabled, …).
  final UnifiedInputDecorationSet? decorationSet;

  /// Override [Theme] brightness for the unified palette.
  final UnifiedInputBrightness? brightness;

  /// Optional external state binding.
  final UnifiedInputPicker<Duration>? binding;

  /// Preferred imperative handle ([UnifiedDurationFieldController.openPicker], validate, focus).
  final UnifiedDurationFieldController? fieldController;

  /// Direct value when not using [binding] or [fieldController].
  final Duration? value;

  /// Synchronous validator on the displayed text.
  final String? Function(String value)? validator;

  /// Called when the duration changes.
  final ValueChanged<Duration?>? onChanged;

  /// Forwarded to the inner text field's submit.
  final ValueChanged<String>? onSubmitted;

  /// Format / picker columns when [pickerColumns] is null (`h`, `h:m`, `h:m:s`, or legacy `m:s`).
  final UnifiedDurationGranularity granularity;

  /// Custom wheel columns (largest unit first), e.g.
  /// `[UnifiedFieldsDurationColumn.year, UnifiedFieldsDurationColumn.week, …]`.
  ///
  /// When set, overrides [granularity] for picker and display format.
  final List<UnifiedFieldsDurationColumn>? pickerColumns;

  /// Cupertino wheels vs unified styled wheels.
  final UnifiedFieldsDurationPickerStyle pickerStyle;

  /// When false, hides the Gregorian / Shamsi digit toggle on wheel pickers.
  final bool showCalendarKindToggle;

  /// Starting digit / label mode for wheel pickers.
  final UnifiedFieldsCalendarKind initialCalendarKind;

  /// Optional wheel chrome when [pickerStyle] is [UnifiedFieldsDurationPickerStyle.wheels].
  final UnifiedFieldsDateWheelStyle? wheelStyle;

  /// Minimum allowed duration.
  final Duration? min;

  /// Maximum allowed duration.
  final Duration? max;

  /// When true, the field is non-interactive.
  final bool locked;

  /// When true, greys out the label and shows a forbid suffix icon.
  final bool isDisabled;

  /// Optional focus node.
  final FocusNode? focusNode;

  /// Field label. Overrides [UnifiedInputDecoration.label] when set.
  final String? label;

  /// Hint text shown when empty. Overrides [UnifiedInputDecoration.placeholder] when set.
  final String? placeholder;

  /// Whether the field is required. Overrides [UnifiedInputDecoration.requiredField] when set.
  final bool isRequired;

  @override
  State<UnifiedDurationField> createState() => _UnifiedDurationFieldState();
}

class _UnifiedDurationFieldState extends State<UnifiedDurationField> {
  late final TextEditingController _txt = TextEditingController();
  late FocusNode _fn;
  bool _ownsFn = false;
  late UnifiedFieldsCalendarKind _calendarKind;

  UnifiedFieldsCalendarKind get _effectiveCalendarKind =>
      widget.fieldController?.calendarKind ?? _calendarKind;

  List<UnifiedFieldsDurationColumn> get _effectiveColumns =>
      resolveUnifiedDurationColumns(
        pickerColumns:
            widget.pickerColumns ?? widget.fieldController?.pickerColumns,
        granularity: widget.granularity,
      );

  Duration get _effective => unifiedClampDuration(
    unifiedEffectiveValue(
          fieldController: widget.fieldController,
          binding: widget.binding,
          direct: widget.value,
        ) ??
        Duration.zero,
    widget.min,
    widget.max,
  );

  @override
  void initState() {
    super.initState();
    _calendarKind =
        widget.fieldController?.calendarKind ?? widget.initialCalendarKind;
    _fn = widget.focusNode ?? FocusNode();
    _ownsFn = widget.focusNode == null;
    _fn.addListener(_onFocus);
    _syncText();
    widget.binding?.addListener(_onBinding);
    widget.fieldController?.addListener(_onBinding);
  }

  @override
  void didUpdateWidget(covariant UnifiedDurationField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      _fn.removeListener(_onFocus);
      if (_ownsFn) _fn.dispose();
      _fn = widget.focusNode ?? FocusNode();
      _ownsFn = widget.focusNode == null;
      _fn.addListener(_onFocus);
    }
    if (oldWidget.binding != widget.binding ||
        oldWidget.fieldController != widget.fieldController) {
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
    final d = unifiedEffectiveValue(
      fieldController: widget.fieldController,
      binding: widget.binding,
      direct: widget.value,
    );
    _txt.text = d == null
        ? ''
        : unifiedFormatDuration(
            d,
            granularity: widget.granularity,
            pickerColumns: _effectiveColumns,
            calendarKind: _effectiveCalendarKind,
          );
  }

  void _onPickerConfirmedCalendarKind(UnifiedFieldsCalendarKind kind) {
    widget.fieldController?.calendarKind = kind;
    if (widget.fieldController == null && _calendarKind != kind) {
      setState(() => _calendarKind = kind);
    }
    _syncText();
  }

  void _onFocus() {
    if (!_fn.hasFocus) _commitParsedIfPossible();
  }

  void _commitParsedIfPossible() {
    final parsed = unifiedTryParseDuration(
      _txt.text,
      granularity: widget.granularity,
      pickerColumns: _effectiveColumns,
    );
    if (parsed == null) return;
    final clamped = unifiedClampDuration(parsed, widget.min, widget.max);
    final formatted = unifiedFormatDuration(
      clamped,
      granularity: widget.granularity,
      pickerColumns: _effectiveColumns,
      calendarKind: _effectiveCalendarKind,
    );
    if (formatted != _txt.text) {
      _txt.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    syncUnifiedFieldValue(
      value: clamped,
      onChanged: widget.onChanged,
      binding: widget.binding,
      fieldController: widget.fieldController,
    );
  }

  @override
  void dispose() {
    widget.binding?.removeListener(_onBinding);
    widget.fieldController?.removeListener(_onBinding);
    _fn.removeListener(_onFocus);
    if (_ownsFn) _fn.dispose();
    _txt.dispose();
    super.dispose();
  }

  Future<void> _openSheet(
    BuildContext context,
    UnifiedInputDecoration d,
  ) async {
    if (widget.isDisabled || widget.locked) return;
    final fc = widget.fieldController;
    if (fc != null) {
      final title =
          widget.placeholder ??
          d.placeholder ??
          widget.label ??
          d.label ??
          UnifiedFieldsStrings.instance.defaultDurationTitle;
      final picked = await fc.openPicker(
        context,
        title: title,
        initial: _effective,
      );
      if (!context.mounted || picked == null) return;
      _txt.text = unifiedFormatDuration(
        picked,
        granularity: widget.granularity,
        pickerColumns: _effectiveColumns,
        calendarKind: _effectiveCalendarKind,
      );
      syncUnifiedFieldValue(
        value: picked,
        onChanged: widget.onChanged,
        binding: widget.binding,
        fieldController: widget.fieldController,
      );
      setState(() {});
      return;
    }
    final palette = widget.brightness != null
        ? UnifiedInputThemeResolver.paletteFor(widget.brightness!)
        : UnifiedInputThemeResolver.resolvePalette(context);

    final title =
        widget.placeholder ??
        d.placeholder ??
        widget.label ??
        d.label ??
        UnifiedFieldsStrings.instance.defaultDurationTitle;
    final minDur = widget.min ?? Duration.zero;
    final maxDur = widget.max ?? const Duration(hours: 999);
    final pickerStyle =
        widget.fieldController?.pickerStyle ?? widget.pickerStyle;

    final Duration? result;
    if (pickerStyle == UnifiedFieldsDurationPickerStyle.wheels) {
      result = await showUnifiedFieldsDurationPicker(
        context: context,
        title: title,
        initial: _effective,
        min: minDur,
        max: maxDur,
        granularity: widget.granularity,
        pickerColumns: _effectiveColumns,
        showCalendarKindToggle: widget.showCalendarKindToggle,
        initialCalendarKind: _effectiveCalendarKind,
        wheelStyle: widget.fieldController?.wheelStyle ?? widget.wheelStyle,
        onConfirmedCalendarKind: _onPickerConfirmedCalendarKind,
      );
    } else {
      result = await showModalBottomSheet<Duration?>(
        context: context,
        isScrollControlled: true,
        backgroundColor: palette.sheetBackground,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (ctx) {
          return UnifiedDurationPickerSheet(
            title: title,
            palette: palette,
            initial: _effective,
            min: minDur,
            max: maxDur,
            columns: _effectiveColumns,
            calendarKind: _effectiveCalendarKind,
          );
        },
      );
    }

    if (!context.mounted) return;
    if (result == null) return;
    final clamped = unifiedClampDuration(result, widget.min, widget.max);
    _txt.text = unifiedFormatDuration(
      clamped,
      granularity: widget.granularity,
      pickerColumns: _effectiveColumns,
      calendarKind: _effectiveCalendarKind,
    );
    syncUnifiedFieldValue(
      value: clamped,
      onChanged: widget.onChanged,
      binding: widget.binding,
      fieldController: widget.fieldController,
    );
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
    final d = chrome.resolved;

    return GestureDetector(
      onTap: widget.locked || widget.isDisabled
          ? null
          : () => _openSheet(context, d),
      child: AbsorbPointer(
        absorbing: true,
        child: UnifiedBaseTextField(
          decorationSet: chrome.activeSet,
          brightness: widget.brightness,
          controller: _txt,
          focusNode: widget.fieldController?.focusNode ?? _fn,
          errorText: widget.fieldController?.errorText,
          isDisabled: widget.isDisabled,
          locked: widget.locked,
          readOnly: true,
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
          rowLabelRatio: d.rowLabelRatio,
          labelInRow: d.labelInRow,
          labelMode: d.labelMode,
          requiredField: widget.isRequired || d.requiredField,
          showError: d.showError,
          validationColor: d.validationColor,
          validationIcon: d.validationIcon,
          prefix: d.prefix,
          prefixIcon: d.prefixIcon,
          suffixIcon: widget.isDisabled || widget.locked
              ? null
              : (d.suffixIcon ??
                    UnifiedInputThemeResolver.defaultSuffixIcon(
                      context,
                      UnifiedInputFieldSuffixKind.duration,
                      UnifiedInputThemeResolver.resolvePalette(context),
                    )),
          padding: d.contentPadding,
          validator: widget.validator,
          textAlign: TextAlign.center,
          textInputAction: TextInputAction.done,
          onSubmit: (s) {
            _commitParsedIfPossible();
            widget.onSubmitted?.call(_txt.text);
          },
        ),
      ),
    );
  }
}

/// Legacy Cupertino-style duration editor (supports custom [columns]).
class UnifiedDurationPickerSheet extends StatefulWidget {
  /// Creates the duration picker sheet content.
  const UnifiedDurationPickerSheet({
    super.key,
    required this.title,
    required this.palette,
    required this.initial,
    required this.min,
    required this.max,
    required this.columns,
    this.calendarKind,
  });

  /// Sheet title shown in the header.
  final String title;

  /// Palette for sheet chrome.
  final UnifiedInputPalette palette;

  /// Initial duration when the sheet opens.
  final Duration initial;

  /// Minimum selectable duration.
  final Duration min;

  /// Maximum selectable duration.
  final Duration max;

  /// Wheel columns (largest unit first).
  final List<UnifiedFieldsDurationColumn> columns;

  /// Persian vs Western digits on wheel labels.
  final UnifiedFieldsCalendarKind? calendarKind;

  @override
  State<UnifiedDurationPickerSheet> createState() =>
      _UnifiedDurationPickerSheetState();
}

class _UnifiedDurationPickerSheetState
    extends State<UnifiedDurationPickerSheet> {
  late List<int> _values;
  late List<FixedExtentScrollController> _controllers;

  UnifiedFieldsCalendarKind? get _digitKind => widget.calendarKind;

  String _suffixFor(UnifiedFieldsDurationColumn col) {
    return switch (col) {
      UnifiedFieldsDurationColumn.year => 'y',
      UnifiedFieldsDurationColumn.month => 'mo',
      UnifiedFieldsDurationColumn.week => 'w',
      UnifiedFieldsDurationColumn.day => 'd',
      UnifiedFieldsDurationColumn.hour => 'h',
      UnifiedFieldsDurationColumn.minute => 'm',
      UnifiedFieldsDurationColumn.second => 's',
    };
  }

  @override
  void initState() {
    super.initState();
    final d = unifiedClampDuration(widget.initial, widget.min, widget.max);
    _values = decomposeUnifiedDuration(d, widget.columns);
    _controllers = List.generate(widget.columns.length, (i) {
      final col = widget.columns[i];
      final max = unifiedDurationColumnMaxIndex(
        col,
        widget.columns,
        widget.max,
      );
      final initial = _values[i].clamp(0, max);
      _values[i] = initial;
      return FixedExtentScrollController(initialItem: initial);
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  Duration _compose() => composeUnifiedDuration(widget.columns, _values);

  Widget _wheel({
    required int flex,
    required int maxIndex,
    required FixedExtentScrollController controller,
    required ValueChanged<int> onPick,
    required String suffix,
    required UnifiedInputPalette pal,
  }) {
    return Expanded(
      flex: flex,
      child: Column(
        children: [
          Text(
            suffix,
            style: TextStyle(
              fontSize: 12,
              color: pal.fieldTextColor.withValues(alpha: 0.7),
            ),
          ),
          Expanded(
            child: CupertinoPicker(
              scrollController: controller,
              itemExtent: 36,
              onSelectedItemChanged: (i) {
                if (i < 0 || i > maxIndex) return;
                setState(() => onPick(i));
              },
              children: List.generate(
                maxIndex + 1,
                (i) => Center(
                  child: Text(
                    UnifiedFieldsTypography.instance.localizeDigits(
                      '$i',
                      calendarKind: _digitKind,
                    ),
                    style: UnifiedFieldsTypography.instance.mergeDigitStyle(
                      TextStyle(color: pal.fieldTextColor),
                      calendarKind: _digitKind,
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

  @override
  Widget build(BuildContext context) {
    final pal = widget.palette;
    final minDur = widget.min;
    final maxDur = widget.max;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: pal.sheetHeaderBackground,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(UnifiedFieldsStrings.instance.cancel),
                  ),
                  Expanded(
                    child: Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: pal.fieldTextColor,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      final composed = unifiedClampDuration(
                        _compose(),
                        minDur,
                        maxDur,
                      );
                      Navigator.pop(context, composed);
                    },
                    child: Text(UnifiedFieldsStrings.instance.done),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 220,
              child: Row(
                children: [
                  for (var i = 0; i < widget.columns.length; i++)
                    _wheel(
                      flex: 2,
                      maxIndex: unifiedDurationColumnMaxIndex(
                        widget.columns[i],
                        widget.columns,
                        maxDur,
                      ),
                      controller: _controllers[i],
                      onPick: (v) => _values[i] = v,
                      suffix: _suffixFor(widget.columns[i]),
                      pal: pal,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
