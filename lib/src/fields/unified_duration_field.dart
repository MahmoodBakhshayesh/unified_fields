import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'unified_base_text_field.dart';
import 'app_input_controller.dart';
import 'unified_input_brightness.dart';
import 'unified_input_decoration.dart';
import 'unified_input_palette.dart';
import 'unified_input_theme.dart';

/// How [UnifiedDurationField] formats and edits values.
enum UnifiedDurationGranularity {
  /// `HH:MM:SS`
  hoursMinutesSeconds,

  /// Total `MM:SS` (minutes can exceed 59).
  minutesSeconds,
}

/// Formats [d] using the rules of [g] (`HH:MM:SS` or `MM:SS`).
String unifiedFormatDuration(Duration d, UnifiedDurationGranularity g) {
  String two(int n) => n.clamp(0, 999999).toString().padLeft(2, '0');

  switch (g) {
    case UnifiedDurationGranularity.hoursMinutesSeconds:
      final h = d.inHours;
      final m = d.inMinutes.remainder(60);
      final s = d.inSeconds.remainder(60);
      return '${two(h)}:${two(m)}:${two(s)}';
    case UnifiedDurationGranularity.minutesSeconds:
      final m = d.inMinutes;
      final s = d.inSeconds.remainder(60);
      return '${m.toString()}:${two(s)}';
  }
}

/// Parses [raw] according to [g]; returns null when the string is malformed.
Duration? unifiedTryParseDuration(String raw, UnifiedDurationGranularity g) {
  final p = raw.trim().split(':');
  try {
    switch (g) {
      case UnifiedDurationGranularity.hoursMinutesSeconds:
        if (p.length != 3) return null;
        final h = int.parse(p[0]);
        final m = int.parse(p[1]);
        final s = int.parse(p[2]);
        return Duration(hours: h, minutes: m, seconds: s);
      case UnifiedDurationGranularity.minutesSeconds:
        if (p.length != 2) return null;
        final m = int.parse(p[0]);
        final s = int.parse(p[1]);
        return Duration(minutes: m, seconds: s);
    }
  } catch (_) {
    return null;
  }
}

/// Clamps [d] inside the inclusive range `[min, max]` (each bound is optional).
Duration unifiedClampDuration(Duration d, Duration? min, Duration? max) {
  var x = d;
  if (min != null && x < min) x = min;
  if (max != null && x > max) x = max;
  return x;
}

/// Duration picker / display field with sheet editor (Cupertino-style wheels).
class UnifiedDurationField extends StatefulWidget {
  /// Creates a duration field.
  const UnifiedDurationField({
    super.key,
    this.decoration,
    this.brightness,
    this.binding,
    this.value,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.granularity = UnifiedDurationGranularity.hoursMinutesSeconds,
    this.min,
    this.max,
    this.locked = false,
    this.focusNode,
    this.label,
    this.placeholder,
    this.isRequired = false,
  });

  /// Visual chrome.
  final UnifiedInputDecoration? decoration;

  /// Override [Theme] brightness for the unified palette.
  final UnifiedInputBrightness? brightness;

  /// Optional external state binding.
  final AppInputController<Duration>? binding;

  /// Direct value when not using [binding].
  final Duration? value;

  /// Synchronous validator on the displayed text.
  final String? Function(String value)? validator;

  /// Called when the duration changes.
  final ValueChanged<Duration?>? onChanged;

  /// Forwarded to the inner text field's submit.
  final ValueChanged<String>? onSubmitted;

  /// Format and editing granularity (h:m:s vs m:s).
  final UnifiedDurationGranularity granularity;

  /// Minimum allowed duration.
  final Duration? min;

  /// Maximum allowed duration.
  final Duration? max;

  /// When true, the field is non-interactive.
  final bool locked;

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

  Duration get _effective => unifiedClampDuration(widget.binding?.value ?? widget.value ?? Duration.zero, widget.min, widget.max);

  @override
  void initState() {
    super.initState();
    _fn = widget.focusNode ?? FocusNode();
    _ownsFn = widget.focusNode == null;
    _fn.addListener(_onFocus);
    _syncText();
    widget.binding?.addListener(_onBinding);
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
    final d = widget.binding?.value ?? widget.value;
    _txt.text = d == null ? '' : unifiedFormatDuration(d, widget.granularity);
  }

  void _onFocus() {
    if (!_fn.hasFocus) _commitParsedIfPossible();
  }

  void _commitParsedIfPossible() {
    final parsed = unifiedTryParseDuration(_txt.text, widget.granularity);
    if (parsed == null) return;
    final clamped = unifiedClampDuration(parsed, widget.min, widget.max);
    final formatted = unifiedFormatDuration(clamped, widget.granularity);
    if (formatted != _txt.text) {
      _txt.value = TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }
    widget.onChanged?.call(clamped);
    final b = widget.binding;
    if (b != null && b.value != clamped) {
      b.value = clamped;
    }
  }

  @override
  void dispose() {
    widget.binding?.removeListener(_onBinding);
    _fn.removeListener(_onFocus);
    if (_ownsFn) _fn.dispose();
    _txt.dispose();
    super.dispose();
  }

  Future<void> _openSheet(BuildContext context, UnifiedInputDecoration d) async {
    final palette = widget.brightness != null ? UnifiedInputThemeResolver.paletteFor(widget.brightness!) : UnifiedInputThemeResolver.resolvePalette(context);

    final result = await showModalBottomSheet<Duration?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: palette.sheetBackground,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) {
        return _DurationPickerSheet(
          title: widget.placeholder ?? d.placeholder ?? widget.label ?? d.label ?? 'Duration',
          palette: palette,
          initial: _effective,
          min: widget.min ?? Duration.zero,
          max: widget.max ?? const Duration(hours: 999),
          granularity: widget.granularity,
        );
      },
    );

    if (!context.mounted) return;
    if (result == null) return;
    final clamped = unifiedClampDuration(result, widget.min, widget.max);
    _txt.text = unifiedFormatDuration(clamped, widget.granularity);
    widget.onChanged?.call(clamped);
    final b = widget.binding;
    if (b != null && b.value != clamped) {
      b.value = clamped;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final d = resolveUnifiedDecoration(context, overrides: widget.decoration, brightness: widget.brightness);

    return GestureDetector(
      onTap: widget.locked ? null : () => _openSheet(context, d),
      child: AbsorbPointer(
        absorbing: true,
        child: UnifiedBaseTextField(
          controller: _txt,
          focusNode: _fn,
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
          suffixIcon: d.suffixIcon ?? const Icon(Icons.timer),
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

class _DurationPickerSheet extends StatefulWidget {
  const _DurationPickerSheet({
    required this.title,
    required this.palette,
    required this.initial,
    required this.min,
    required this.max,
    required this.granularity,
  });

  final String title;
  final UnifiedInputPalette palette;
  final Duration initial;
  final Duration min;
  final Duration max;
  final UnifiedDurationGranularity granularity;

  @override
  State<_DurationPickerSheet> createState() => _DurationPickerSheetState();
}

class _DurationPickerSheetState extends State<_DurationPickerSheet> {
  late int _h;
  late int _m;
  late int _s;

  late final int _maxHIndex;
  late final int _maxMIndex;

  FixedExtentScrollController? _hCtrl;
  late FixedExtentScrollController _mCtrl;
  late FixedExtentScrollController _sCtrl;

  @override
  void initState() {
    super.initState();
    final maxDur = widget.max;

    switch (widget.granularity) {
      case UnifiedDurationGranularity.hoursMinutesSeconds:
        _maxHIndex = maxDur.inHours.clamp(0, 999);
        _maxMIndex = 59;
        break;
      case UnifiedDurationGranularity.minutesSeconds:
        _maxHIndex = 0;
        _maxMIndex = maxDur.inMinutes.clamp(0, 99999);
        break;
    }

    final d = unifiedClampDuration(widget.initial, widget.min, widget.max);
    _h = d.inHours.clamp(0, _maxHIndex);
    _m = d.inMinutes.remainder(60);
    _s = d.inSeconds.remainder(60);
    if (widget.granularity == UnifiedDurationGranularity.minutesSeconds) {
      _m = d.inMinutes.clamp(0, _maxMIndex);
      _s = d.inSeconds.remainder(60);
    } else {
      _m = _m.clamp(0, 59);
    }
    _s = _s.clamp(0, 59);

    if (widget.granularity == UnifiedDurationGranularity.hoursMinutesSeconds) {
      _hCtrl = FixedExtentScrollController(initialItem: _h);
    }
    _mCtrl = FixedExtentScrollController(initialItem: _m);
    _sCtrl = FixedExtentScrollController(initialItem: _s);
  }

  @override
  void dispose() {
    _hCtrl?.dispose();
    _mCtrl.dispose();
    _sCtrl.dispose();
    super.dispose();
  }

  Duration _compose() {
    switch (widget.granularity) {
      case UnifiedDurationGranularity.hoursMinutesSeconds:
        return Duration(hours: _h, minutes: _m, seconds: _s);
      case UnifiedDurationGranularity.minutesSeconds:
        return Duration(minutes: _m, seconds: _s);
    }
  }

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
          Text(suffix, style: TextStyle(fontSize: 12, color: pal.fieldTextColor.withValues(alpha: 0.7))),
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
                (i) => Center(child: Text('$i', style: TextStyle(color: pal.fieldTextColor))),
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

    final minuteMax = widget.granularity == UnifiedDurationGranularity.minutesSeconds ? _maxMIndex : 59;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: pal.sheetHeaderBackground,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                  Expanded(
                    child: Text(
                      widget.title,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.w600, color: pal.fieldTextColor),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      final composed = unifiedClampDuration(_compose(), minDur, maxDur);
                      Navigator.pop(context, composed);
                    },
                    child: const Text('Done'),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 220,
              child: Row(
                children: [
                  if (widget.granularity == UnifiedDurationGranularity.hoursMinutesSeconds && _hCtrl != null)
                    _wheel(
                      flex: 2,
                      maxIndex: _maxHIndex,
                      controller: _hCtrl!,
                      onPick: (i) => _h = i,
                      suffix: 'h',
                      pal: pal,
                    ),
                  _wheel(
                    flex: widget.granularity == UnifiedDurationGranularity.hoursMinutesSeconds ? 2 : 3,
                    maxIndex: minuteMax,
                    controller: _mCtrl,
                    onPick: (i) => _m = i,
                    suffix: 'm',
                    pal: pal,
                  ),
                  _wheel(
                    flex: 2,
                    maxIndex: 59,
                    controller: _sCtrl,
                    onPick: (i) => _s = i,
                    suffix: 's',
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
