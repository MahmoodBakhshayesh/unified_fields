import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'fields/unified_input_theme.dart';
import 'fields/unified_picker_keyboard.dart';
import 'fields/unified_picker_presentation.dart';
import 'unified_fields_strings.dart';
import 'unified_time_format.dart';

// ---------------------------------------------------------------------------
// Typed entry
// ---------------------------------------------------------------------------

/// Digits-only formatter that inserts the literal separators of [pattern]
/// (`yyyy-MM-dd` → `2026-10-15`, `HH:mm` → `09:30`).
class UnifiedMaskedDigitsFormatter extends TextInputFormatter {
  /// Creates a formatter for [pattern] (letters are digit slots, the rest literals).
  UnifiedMaskedDigitsFormatter(this.pattern);

  /// Mask source, e.g. `yyyy-MM-dd`.
  final String pattern;

  bool _slot(String c) => RegExp('[A-Za-z]').hasMatch(c);

  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final out = StringBuffer();
    var di = 0;
    for (var i = 0; i < pattern.length && di < digits.length; i++) {
      final c = pattern[i];
      if (_slot(c)) {
        out.write(digits[di++]);
      } else {
        out.write(c);
      }
    }
    var text = out.toString();
    // Drop a trailing separator when the user is deleting.
    if (newValue.text.length < oldValue.text.length && text.isNotEmpty && !_slot(pattern[text.length - 1])) {
      text = text.substring(0, text.length - 1);
    }
    return TextEditingValue(text: text, selection: TextSelection.collapsed(offset: text.length));
  }
}

/// Parses a typed duration: `1:30`, `01:30:15`, `90m`, `1h30`, `1h 30m`, `2h`, `45` (minutes).
Duration? unifiedParseTypedDuration(String raw) {
  final t = raw.trim().toLowerCase();
  if (t.isEmpty) return null;
  final colon = RegExp(r'^(\d{1,3}):(\d{1,2})(?::(\d{1,2}))?$').firstMatch(t);
  if (colon != null) {
    final m = int.parse(colon.group(2)!);
    final s = int.parse(colon.group(3) ?? '0');
    if (m > 59 || s > 59) return null;
    return Duration(hours: int.parse(colon.group(1)!), minutes: m, seconds: s);
  }
  final units = RegExp(r'^(?:(\d+)\s*h)?\s*(?:(\d+)\s*m?)?\s*(?:(\d+)\s*s)?$').firstMatch(t);
  if (units != null && (units.group(1) != null || units.group(2) != null || units.group(3) != null)) {
    return Duration(
      hours: int.parse(units.group(1) ?? '0'),
      minutes: int.parse(units.group(2) ?? '0'),
      seconds: int.parse(units.group(3) ?? '0'),
    );
  }
  return null;
}

/// Typed-entry box at the top of compact pickers (mono, focus ring, error tint).
class UnifiedTypedEntryField extends StatelessWidget {
  /// Creates a typed-entry field.
  const UnifiedTypedEntryField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.focusNode,
    this.error,
    this.onChanged,
    this.onSubmitted,
    this.inputFormatters,
    this.autofocus = true,
  });

  /// Text controller.
  final TextEditingController controller;

  /// Placeholder (the expected pattern).
  final String hint;

  /// Leading icon.
  final IconData icon;

  /// Focus node.
  final FocusNode? focusNode;

  /// Error message (red outline + caption) or null.
  final String? error;

  /// Change handler.
  final ValueChanged<String>? onChanged;

  /// Enter handler.
  final ValueChanged<String>? onSubmitted;

  /// Formatters (mask).
  final List<TextInputFormatter>? inputFormatters;

  /// Focus on open so the user can type immediately.
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final s = UnifiedResolvedPickerSurface.of(context);
    final errorColor = UnifiedInputThemeResolver.resolvePalette(context).validationColor;
    OutlineInputBorder border(Color c, double w) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(s.searchBorderRadius),
          borderSide: c.a == 0 ? BorderSide.none : BorderSide(color: c, width: w),
        );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: s.searchHeight,
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            autofocus: autofocus,
            onChanged: onChanged,
            onSubmitted: onSubmitted,
            inputFormatters: inputFormatters,
            keyboardType: TextInputType.datetime,
            style: s.monoTextStyle,
            cursorColor: s.accentColor,
            cursorWidth: 1.5,
            expands: true,
            maxLines: null,
            minLines: null,
            textAlignVertical: TextAlignVertical.center,
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: s.searchBackgroundColor,
              hintText: hint,
              hintStyle: s.monoTextStyle.copyWith(color: s.searchPlaceholderStyle.color),
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              prefixIcon: Icon(icon, size: 17, color: error != null ? errorColor : s.searchPlaceholderStyle.color),
              prefixIconConstraints: const BoxConstraints(minWidth: 34, minHeight: 17),
              suffixIcon: Padding(
                padding: const EdgeInsetsDirectional.only(end: 10),
                child: Text('↵', style: s.mutedTextStyle),
              ),
              suffixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
              border: border(s.searchBorderColor, 1),
              enabledBorder: border(error != null ? errorColor : s.searchBorderColor, error != null ? 1.5 : 1),
              focusedBorder: border(error != null ? errorColor : s.searchFocusedBorderColor, 1.5),
            ),
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 2),
            child: Text(error!, style: s.mutedTextStyle.copyWith(color: errorColor)),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Presenter
// ---------------------------------------------------------------------------

/// Presents compact picker content per [UnifiedInputThemeData.pickerPresentation]
/// (anchored popover / dialog / bottom sheet).
Future<T?> showUnifiedCompactPicker<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  UnifiedPickerPresentation? presentation,
  UnifiedPickerSurfaceStyle? surfaceStyle,
  double width = 312,
  bool barrierDismissible = true,
}) {
  unifiedUnfocusBeforeModal(context);
  final p = resolveUnifiedPickerPresentation(context, override: presentation);
  Widget wrap(BuildContext c) => UnifiedPickerModalScope(child: builder(c));
  switch (p) {
    case UnifiedPickerPresentation.anchored:
      return showUnifiedAnchoredPopover<T>(
        context: context,
        minWidth: width,
        width: width,
        maxHeight: 520,
        surfaceStyle: surfaceStyle,
        barrierDismissible: barrierDismissible,
        builder: wrap,
      );
    case UnifiedPickerPresentation.dialog:
      return showUnifiedPickerDialog<T>(
        context: context,
        width: width + 24,
        surfaceStyle: surfaceStyle,
        barrierDismissible: barrierDismissible,
        builder: wrap,
      );
    case UnifiedPickerPresentation.bottomSheet:
    case UnifiedPickerPresentation.adaptive:
      final s = UnifiedResolvedPickerSurface.of(context, override: surfaceStyle);
      return showModalBottomSheet<T>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        isDismissible: barrierDismissible,
        backgroundColor: s.backgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(s.borderRadius * 1.5))),
        builder: (c) => UnifiedPickerPresentationScope(
          presentation: UnifiedPickerPresentation.bottomSheet,
          maxHeight: MediaQuery.sizeOf(c).height * 0.9,
          child: Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(c).bottom),
            child: Center(
              heightFactor: 1,
              child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 420), child: wrap(c)),
            ),
          ),
        ),
      );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.onPressed, this.tooltip});

  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final s = UnifiedResolvedPickerSurface.of(context);
    final radius = BorderRadius.circular(s.actionRadius);
    final child = Material(
      color: s.secondaryActionColor,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onPressed,
        child: SizedBox(
          width: 28,
          height: 28,
          child: Icon(icon, size: 18, color: s.secondaryActionTextColor.withValues(alpha: onPressed == null ? 0.3 : 1)),
        ),
      ),
    );
    return tooltip == null ? child : Tooltip(message: tooltip!, child: child);
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.leading, required this.onCancel, required this.onDone});

  final Widget? leading;
  final VoidCallback onCancel;
  final VoidCallback? onDone;

  @override
  Widget build(BuildContext context) {
    final strings = UnifiedFieldsStrings.instance;
    return Row(
      children: [
        ?leading,
        const Spacer(),
        UnifiedPickerActionButton(label: strings.cancel, onPressed: onCancel),
        const SizedBox(width: 6),
        UnifiedPickerActionButton(primary: true, label: strings.done, onPressed: onDone),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Date
// ---------------------------------------------------------------------------

/// Compact calendar: typed entry (`yyyy-MM-dd` by default), month grid with a
/// month / year switcher, keyboard navigation (arrows, PageUp / PageDown, Enter).
///
/// In an anchored popover a day click commits immediately; in dialogs /
/// sheets it selects and Done commits. Pops the picked [DateTime].
class UnifiedFieldsCompactDatePicker extends StatefulWidget {
  /// Creates a compact date picker.
  const UnifiedFieldsCompactDatePicker({
    super.key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    this.title,
    this.typedPattern,
    this.commitOnDayTap,
  });

  /// Initially selected date (null = none, month of today shown).
  final DateTime? initialDate;

  /// Earliest selectable date.
  final DateTime firstDate;

  /// Latest selectable date.
  final DateTime lastDate;

  /// Title shown in dialog / sheet mode.
  final String? title;

  /// Typed pattern; defaults to theme `typedDateFormat` or `yyyy-MM-dd`.
  final String? typedPattern;

  /// Commit on day tap; defaults to true when anchored.
  final bool? commitOnDayTap;

  @override
  State<UnifiedFieldsCompactDatePicker> createState() => _UnifiedFieldsCompactDatePickerState();
}

class _UnifiedFieldsCompactDatePickerState extends State<UnifiedFieldsCompactDatePicker> {
  late DateTime? _sel = widget.initialDate == null ? null : DateUtils.dateOnly(widget.initialDate!);
  late DateTime _month = DateUtils.dateOnly(DateTime(
    (_sel ?? _clampDate(DateTime.now())).year,
    (_sel ?? _clampDate(DateTime.now())).month,
  ));
  bool _monthsView = false;
  final _typed = TextEditingController();
  final _gridFocus = FocusNode(debugLabel: 'compact-date-grid');
  String? _error;
  String _pattern = 'yyyy-MM-dd';
  bool _patternReady = false;

  DateTime _clampDate(DateTime d) {
    final x = DateUtils.dateOnly(d);
    if (x.isBefore(DateUtils.dateOnly(widget.firstDate))) return DateUtils.dateOnly(widget.firstDate);
    if (x.isAfter(DateUtils.dateOnly(widget.lastDate))) return DateUtils.dateOnly(widget.lastDate);
    return x;
  }

  bool _enabled(DateTime d) =>
      !d.isBefore(DateUtils.dateOnly(widget.firstDate)) && !d.isAfter(DateUtils.dateOnly(widget.lastDate));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_patternReady) return;
    _patternReady = true;
    _pattern = widget.typedPattern ?? UnifiedInputThemeScope.themeDataOf(context).typedDateFormat ?? 'yyyy-MM-dd';
    final seed = UnifiedPickerTypeAhead.take();
    if (seed != null) {
      _typed.text = seed;
      _typed.selection = TextSelection.collapsed(offset: seed.length);
    } else if (_sel != null) {
      _typed.text = DateFormat(_pattern).format(_sel!);
      _typed.selection = TextSelection(baseOffset: 0, extentOffset: _typed.text.length);
    }
  }

  @override
  void dispose() {
    _typed.dispose();
    _gridFocus.dispose();
    super.dispose();
  }

  void _onTyped(String t) {
    if (t.length < _pattern.length) {
      setState(() => _error = null);
      return;
    }
    DateTime? d;
    try {
      d = DateFormat(_pattern).parseStrict(t);
    } catch (_) {
      d = null;
    }
    if (d == null) {
      setState(() => _error = 'Use ${_pattern.toLowerCase()}');
    } else if (!_enabled(DateUtils.dateOnly(d))) {
      setState(() => _error = 'Out of range');
    } else {
      setState(() {
        _error = null;
        _sel = DateUtils.dateOnly(d!);
        _month = DateTime(d.year, d.month);
      });
    }
  }

  void _commit([DateTime? d]) {
    final v = d ?? _sel;
    if (v == null || !_enabled(v) || _error != null) return;
    Navigator.of(context).pop(v);
  }

  void _select(DateTime d, {bool fromTap = false}) {
    if (!_enabled(d)) return;
    setState(() {
      _sel = d;
      _month = DateTime(d.year, d.month);
      _error = null;
      _typed.text = DateFormat(_pattern).format(d);
    });
    final commit = widget.commitOnDayTap ?? UnifiedPickerPresentationScope.isAnchoredOf(context);
    if (fromTap && commit) _commit(d);
  }

  KeyEventResult _onGridKey(FocusNode node, KeyEvent e) {
    if (e is! KeyDownEvent && e is! KeyRepeatEvent) return KeyEventResult.ignored;
    final base = _sel ?? _clampDate(DateTime.now());
    DateTime? next;
    final k = e.logicalKey;
    if (k == LogicalKeyboardKey.arrowLeft) next = base.subtract(const Duration(days: 1));
    if (k == LogicalKeyboardKey.arrowRight) next = base.add(const Duration(days: 1));
    if (k == LogicalKeyboardKey.arrowUp) next = base.subtract(const Duration(days: 7));
    if (k == LogicalKeyboardKey.arrowDown) next = base.add(const Duration(days: 7));
    if (k == LogicalKeyboardKey.pageUp) next = DateUtils.addMonthsToMonthDate(base, -1);
    if (k == LogicalKeyboardKey.pageDown) next = DateUtils.addMonthsToMonthDate(base, 1);
    if (next != null) {
      _select(DateUtils.dateOnly(_clampDate(next)));
      return KeyEventResult.handled;
    }
    if (k == LogicalKeyboardKey.enter || k == LogicalKeyboardKey.numpadEnter || k == LogicalKeyboardKey.space) {
      _commit();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final s = UnifiedResolvedPickerSurface.of(context);
    final loc = MaterialLocalizations.of(context);
    final compact = UnifiedPickerPresentationScope.isAnchoredOf(context);
    final title = _monthsView ? '${_month.year}' : DateFormat.yMMMM().format(_month);
    final canPrev = _monthsView
        ? _month.year > widget.firstDate.year
        : !DateTime(_month.year, _month.month).isBefore(DateTime(widget.firstDate.year, widget.firstDate.month + 1));
    final canNext = _monthsView
        ? _month.year < widget.lastDate.year
        : DateTime(_month.year, _month.month).isBefore(DateTime(widget.lastDate.year, widget.lastDate.month));
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!compact && widget.title != null) ...[
            Text(widget.title!, style: s.itemTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
          ],
          UnifiedTypedEntryField(
            controller: _typed,
            hint: _pattern.toLowerCase(),
            icon: Icons.calendar_today_rounded,
            error: _error,
            inputFormatters: [UnifiedMaskedDigitsFormatter(_pattern)],
            onChanged: _onTyped,
            onSubmitted: (_) => _commit(),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(s.actionRadius),
                child: InkWell(
                  borderRadius: BorderRadius.circular(s.actionRadius),
                  onTap: () => setState(() => _monthsView = !_monthsView),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(title, style: s.itemTextStyle.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(width: 2),
                        Icon(
                          _monthsView ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                          size: 18,
                          color: s.mutedTextStyle.color,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const Spacer(),
              _NavButton(
                icon: Icons.chevron_left_rounded,
                tooltip: _monthsView ? null : loc.previousMonthTooltip,
                onPressed: canPrev
                    ? () => setState(() => _month = _monthsView
                        ? DateTime(_month.year - 1, _month.month)
                        : DateUtils.addMonthsToMonthDate(_month, -1))
                    : null,
              ),
              const SizedBox(width: 6),
              _NavButton(
                icon: Icons.chevron_right_rounded,
                tooltip: _monthsView ? null : loc.nextMonthTooltip,
                onPressed: canNext
                    ? () => setState(() => _month = _monthsView
                        ? DateTime(_month.year + 1, _month.month)
                        : DateUtils.addMonthsToMonthDate(_month, 1))
                    : null,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Focus(
            focusNode: _gridFocus,
            onKeyEvent: _onGridKey,
            child: _monthsView ? _buildMonths(s) : _buildDays(s, loc),
          ),
          const SizedBox(height: 10),
          _Footer(
            leading: UnifiedPickerActionButton(
              label: loc.currentDateLabel,
              onPressed: _enabled(DateUtils.dateOnly(DateTime.now()))
                  ? () => _select(DateUtils.dateOnly(DateTime.now()), fromTap: true)
                  : null,
            ),
            onCancel: () => Navigator.of(context).maybePop(),
            onDone: _sel == null || _error != null ? null : _commit,
          ),
        ],
      ),
    );
  }

  Widget _buildDays(UnifiedResolvedPickerSurface s, MaterialLocalizations loc) {
    final firstWeekday = loc.firstDayOfWeekIndex; // 0 = Sunday
    final first = DateTime(_month.year, _month.month);
    final lead = (first.weekday % 7 - firstWeekday + 7) % 7;
    final start = first.subtract(Duration(days: lead));
    final today = DateUtils.dateOnly(DateTime.now());
    final weekdays = [for (var i = 0; i < 7; i++) loc.narrowWeekdays[(firstWeekday + i) % 7]];
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            for (final w in weekdays)
              Expanded(child: Center(child: Text(w, style: s.sectionTextStyle))),
          ],
        ),
        const SizedBox(height: 4),
        for (var r = 0; r < 6; r++)
          Row(
            children: [
              for (var c = 0; c < 7; c++)
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final d = DateUtils.dateOnly(DateTime(start.year, start.month, start.day + r * 7 + c));
                      return _DayCell(
                        date: d,
                        inMonth: d.month == _month.month,
                        selected: _sel != null && DateUtils.isSameDay(d, _sel),
                        today: DateUtils.isSameDay(d, today),
                        enabled: _enabled(d),
                        onTap: () => _select(d, fromTap: true),
                      );
                    },
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildMonths(UnifiedResolvedPickerSurface s) {
    final fmt = DateFormat.MMM();
    return SizedBox(
      height: 6 * 36.0 + 18,
      child: GridView.count(
        crossAxisCount: 3,
        childAspectRatio: 2.1,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          for (var m = 1; m <= 12; m++)
            Builder(
              builder: (context) {
                final enabled = !DateTime(_month.year, m + 1).isBefore(DateTime(widget.firstDate.year, widget.firstDate.month + 1)) &&
                    !DateTime(_month.year, m).isAfter(widget.lastDate);
                final selected = _month.month == m;
                return _ChipCell(
                  label: fmt.format(DateTime(2000, m)),
                  selected: selected,
                  enabled: enabled,
                  onTap: () => setState(() {
                    _month = DateTime(_month.year, m);
                    _monthsView = false;
                  }),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.inMonth,
    required this.selected,
    required this.today,
    required this.enabled,
    required this.onTap,
  });

  final DateTime date;
  final bool inMonth;
  final bool selected;
  final bool today;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = UnifiedResolvedPickerSurface.of(context);
    final radius = BorderRadius.circular(s.rowRadius);
    final color = selected
        ? s.onAccentColor
        : (!enabled
            ? s.mutedTextStyle.color!.withValues(alpha: 0.35)
            : (inMonth ? s.itemTextStyle.color : s.mutedTextStyle.color));
    return Padding(
      padding: const EdgeInsets.all(1.5),
      child: Material(
        color: selected ? s.accentColor : Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: today && !selected ? BorderSide(color: s.todayColor, width: 1.2) : BorderSide.none,
        ),
        child: InkWell(
          canRequestFocus: false,
          borderRadius: radius,
          hoverColor: s.rowHoverColor,
          onTap: enabled ? onTap : null,
          child: SizedBox(
            height: 34,
            child: Center(
              child: Text(
                '${date.day}',
                style: s.monoTextStyle.copyWith(
                  fontSize: 13,
                  color: color,
                  fontWeight: selected || today ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChipCell extends StatelessWidget {
  const _ChipCell({required this.label, required this.selected, required this.onTap, this.enabled = true});

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = UnifiedResolvedPickerSurface.of(context);
    final radius = BorderRadius.circular(s.rowRadius);
    return Material(
      color: selected ? s.accentColor : s.secondaryActionColor,
      borderRadius: radius,
      child: InkWell(
        canRequestFocus: false,
        borderRadius: radius,
        hoverColor: s.rowHoverColor,
        onTap: enabled ? onTap : null,
        child: Center(
          child: Text(
            label,
            style: s.monoTextStyle.copyWith(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected
                  ? s.onAccentColor
                  : s.itemTextStyle.color!.withValues(alpha: enabled ? 1 : 0.35),
            ),
          ),
        ),
      ),
    );
  }
}

/// Opens [UnifiedFieldsCompactDatePicker] anchored to [context] (or as dialog / sheet).
Future<DateTime?> showUnifiedFieldsCompactDatePicker({
  required BuildContext context,
  DateTime? initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  String? title,
  String? typedPattern,
  UnifiedPickerPresentation? presentation,
  UnifiedPickerSurfaceStyle? surfaceStyle,
  bool barrierDismissible = true,
}) {
  return showUnifiedCompactPicker<DateTime>(
    context: context,
    presentation: presentation,
    surfaceStyle: surfaceStyle,
    barrierDismissible: barrierDismissible,
    builder: (_) => UnifiedFieldsCompactDatePicker(
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      title: title,
      typedPattern: typedPattern,
    ),
  );
}

// ---------------------------------------------------------------------------
// Value columns (time / duration)
// ---------------------------------------------------------------------------

class _ValueColumn extends StatefulWidget {
  const _ValueColumn({
    required this.label,
    required this.count,
    required this.value,
    required this.onChanged,
    this.step = 1,
    this.format,
  });

  final String label;
  final int count;
  final int value;
  final int step;
  final ValueChanged<int> onChanged;
  final String Function(int)? format;

  @override
  State<_ValueColumn> createState() => _ValueColumnState();
}

class _ValueColumnState extends State<_ValueColumn> {
  static const _extent = 30.0;
  static const _visible = 7;
  late final ScrollController _c = ScrollController(initialScrollOffset: _offsetFor(widget.value));

  List<int> get _values => [for (var v = 0; v < widget.count; v += widget.step) v];

  double _offsetFor(int v) {
    final i = _values.indexWhere((x) => x >= v);
    return math.max(0, (i < 0 ? 0 : i) - _visible ~/ 2) * _extent;
  }

  @override
  void didUpdateWidget(covariant _ValueColumn old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value && _c.hasClients) {
      final target = _offsetFor(widget.value).clamp(0.0, _c.position.maxScrollExtent);
      final visibleTop = _c.offset;
      final pos = _values.indexWhere((x) => x >= widget.value) * _extent;
      if (pos < visibleTop || pos > visibleTop + (_visible - 1) * _extent) {
        _c.animateTo(target, duration: const Duration(milliseconds: 160), curve: Curves.easeOut);
      }
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = UnifiedResolvedPickerSurface.of(context);
    final values = _values;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(widget.label, style: s.sectionTextStyle),
        const SizedBox(height: 4),
        Container(
          height: _extent * _visible,
          decoration: BoxDecoration(
            color: s.searchBackgroundColor,
            borderRadius: BorderRadius.circular(s.searchBorderRadius),
          ),
          child: ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: ListView.builder(
              controller: _c,
              padding: const EdgeInsets.symmetric(vertical: 2),
              itemExtent: _extent,
              itemCount: values.length,
              itemBuilder: (context, i) {
                final v = values[i];
                final selected = v == widget.value;
                final radius = BorderRadius.circular(s.rowRadius - 2);
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                  child: Material(
                    color: selected ? s.accentColor : Colors.transparent,
                    borderRadius: radius,
                    child: InkWell(
                      canRequestFocus: false,
                      borderRadius: radius,
                      hoverColor: s.rowHoverColor,
                      onTap: () => widget.onChanged(v),
                      child: Center(
                        child: Text(
                          widget.format?.call(v) ?? v.toString().padLeft(2, '0'),
                          style: s.monoTextStyle.copyWith(
                            fontSize: 13,
                            color: selected ? s.onAccentColor : null,
                            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({required this.label, required this.onTap, this.selected = false});

  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final s = UnifiedResolvedPickerSurface.of(context);
    final radius = BorderRadius.circular(s.actionRadius);
    return Material(
      color: selected ? s.rowSelectedColor : s.secondaryActionColor,
      borderRadius: radius,
      child: InkWell(
        canRequestFocus: false,
        borderRadius: radius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Text(
            label,
            style: s.monoTextStyle.copyWith(
              fontSize: 12.5,
              color: selected ? s.rowSelectedTextColor : null,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Time
// ---------------------------------------------------------------------------

/// Compact time picker: typed `HH:mm` (or `HH:mm:ss`), hour / minute / second
/// columns, presets (Now + custom). Pops [UnifiedFieldsPickedTime].
class UnifiedFieldsCompactTimePicker extends StatefulWidget {
  /// Creates a compact time picker.
  const UnifiedFieldsCompactTimePicker({
    super.key,
    required this.initialTime,
    this.initialSecond = 0,
    this.showSeconds = false,
    this.minuteStep = 1,
    this.presets = const [],
    this.includeNowPreset = true,
    this.title,
  });

  /// Initial time.
  final TimeOfDay initialTime;

  /// Initial seconds.
  final int initialSecond;

  /// Seconds column + `HH:mm:ss` entry.
  final bool showSeconds;

  /// Minute column step (typed entry accepts any minute).
  final int minuteStep;

  /// Quick picks.
  final List<TimeOfDay> presets;

  /// Prepend a "Now" chip.
  final bool includeNowPreset;

  /// Title shown in dialog / sheet mode.
  final String? title;

  @override
  State<UnifiedFieldsCompactTimePicker> createState() => _UnifiedFieldsCompactTimePickerState();
}

class _UnifiedFieldsCompactTimePickerState extends State<UnifiedFieldsCompactTimePicker> {
  late int _h = widget.initialTime.hour;
  late int _m = widget.initialTime.minute;
  late int _s = widget.initialSecond;
  final _typed = TextEditingController();
  String? _error;

  String get _pattern => widget.showSeconds ? 'HH:mm:ss' : 'HH:mm';

  String _fmt() =>
      '${_h.toString().padLeft(2, '0')}:${_m.toString().padLeft(2, '0')}${widget.showSeconds ? ':${_s.toString().padLeft(2, '0')}' : ''}';

  @override
  void initState() {
    super.initState();
    final seed = UnifiedPickerTypeAhead.take();
    _typed.text = seed ?? _fmt();
    _typed.selection = seed != null
        ? TextSelection.collapsed(offset: seed.length)
        : TextSelection(baseOffset: 0, extentOffset: _typed.text.length);
  }

  @override
  void dispose() {
    _typed.dispose();
    super.dispose();
  }

  void _onTyped(String t) {
    if (t.length < _pattern.length) {
      setState(() => _error = null);
      return;
    }
    final parts = t.split(':').map(int.tryParse).toList();
    final h = parts.isNotEmpty ? parts[0] : null;
    final m = parts.length > 1 ? parts[1] : null;
    final sec = parts.length > 2 ? parts[2] : 0;
    if (h == null || m == null || sec == null || h > 23 || m > 59 || sec > 59) {
      setState(() => _error = 'Use ${_pattern.toLowerCase()} (00–23)');
      return;
    }
    setState(() {
      _error = null;
      _h = h;
      _m = m;
      _s = sec;
    });
  }

  void _set({int? h, int? m, int? s}) {
    setState(() {
      _h = h ?? _h;
      _m = m ?? _m;
      _s = s ?? _s;
      _error = null;
      _typed.text = _fmt();
    });
  }

  void _commit() {
    if (_error != null) return;
    Navigator.of(context).pop(UnifiedFieldsPickedTime(hour: _h, minute: _m, second: _s));
  }

  @override
  Widget build(BuildContext context) {
    final s = UnifiedResolvedPickerSurface.of(context);
    final strings = UnifiedFieldsStrings.instance;
    final anchored = UnifiedPickerPresentationScope.isAnchoredOf(context);
    String label(TimeOfDay t) => '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!anchored && widget.title != null) ...[
            Text(widget.title!, style: s.itemTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
          ],
          UnifiedTypedEntryField(
            controller: _typed,
            hint: _pattern.toLowerCase(),
            icon: Icons.schedule_rounded,
            error: _error,
            inputFormatters: [UnifiedMaskedDigitsFormatter(_pattern)],
            onChanged: _onTyped,
            onSubmitted: (_) => _commit(),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _ValueColumn(label: strings.hourLabel, count: 24, value: _h, onChanged: (v) => _set(h: v)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ValueColumn(
                  label: strings.minuteLabel,
                  count: 60,
                  step: widget.minuteStep,
                  value: _m,
                  onChanged: (v) => _set(m: v),
                ),
              ),
              if (widget.showSeconds) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: _ValueColumn(label: strings.secondLabel, count: 60, value: _s, onChanged: (v) => _set(s: v)),
                ),
              ],
            ],
          ),
          if (widget.presets.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final p in widget.presets)
                  _PresetChip(
                    label: label(p),
                    selected: p.hour == _h && p.minute == _m,
                    onTap: () => _set(h: p.hour, m: p.minute, s: 0),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          _Footer(
            leading: widget.includeNowPreset
                ? UnifiedPickerActionButton(
                    label: strings.now,
                    onPressed: () {
                      final n = DateTime.now();
                      _set(h: n.hour, m: n.minute, s: n.second);
                    },
                  )
                : null,
            onCancel: () => Navigator.of(context).maybePop(),
            onDone: _error == null ? _commit : null,
          ),
        ],
      ),
    );
  }
}

/// Opens [UnifiedFieldsCompactTimePicker] anchored to [context] (or as dialog / sheet).
Future<UnifiedFieldsPickedTime?> showUnifiedFieldsCompactTimePicker({
  required BuildContext context,
  required TimeOfDay initialTime,
  int initialSecond = 0,
  bool showSeconds = false,
  int minuteStep = 1,
  List<TimeOfDay> presets = const [],
  bool includeNowPreset = true,
  String? title,
  UnifiedPickerPresentation? presentation,
  UnifiedPickerSurfaceStyle? surfaceStyle,
  bool barrierDismissible = true,
}) {
  return showUnifiedCompactPicker<UnifiedFieldsPickedTime>(
    context: context,
    presentation: presentation,
    surfaceStyle: surfaceStyle,
    barrierDismissible: barrierDismissible,
    width: showSeconds ? 300 : 248,
    builder: (_) => UnifiedFieldsCompactTimePicker(
      initialTime: initialTime,
      initialSecond: initialSecond,
      showSeconds: showSeconds,
      minuteStep: minuteStep,
      presets: presets,
      includeNowPreset: includeNowPreset,
      title: title,
    ),
  );
}

// ---------------------------------------------------------------------------
// Duration
// ---------------------------------------------------------------------------

/// Compact duration picker: typed entry (`1:30`, `90m`, `1h 30m`), hour /
/// minute (/ second) columns and quick chips. Pops a [Duration].
class UnifiedFieldsCompactDurationPicker extends StatefulWidget {
  /// Creates a compact duration picker.
  const UnifiedFieldsCompactDurationPicker({
    super.key,
    required this.initial,
    this.min = Duration.zero,
    this.max = const Duration(hours: 99, minutes: 59),
    this.showSeconds = false,
    this.showHours = true,
    this.presets,
    this.title,
  });

  /// Initial value.
  final Duration initial;

  /// Minimum.
  final Duration min;

  /// Maximum.
  final Duration max;

  /// Seconds column.
  final bool showSeconds;

  /// Hours column.
  final bool showHours;

  /// Quick chips; defaults to 15m · 30m · 45m · 1h · 1h 30m · 2h within range.
  final List<Duration>? presets;

  /// Title shown in dialog / sheet mode.
  final String? title;

  @override
  State<UnifiedFieldsCompactDurationPicker> createState() => _UnifiedFieldsCompactDurationPickerState();
}

class _UnifiedFieldsCompactDurationPickerState extends State<UnifiedFieldsCompactDurationPicker> {
  late Duration _d = widget.initial;
  final _typed = TextEditingController();
  String? _error;

  String _fmt(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    final hm = widget.showHours ? '$h:${m.toString().padLeft(2, '0')}' : '${d.inMinutes}';
    return widget.showSeconds ? '$hm:${s.toString().padLeft(2, '0')}' : hm;
  }

  static String chipLabel(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h == 0) return '${m}m';
    if (m == 0) return '${h}h';
    return '${h}h ${m}m';
  }

  @override
  void initState() {
    super.initState();
    final seed = UnifiedPickerTypeAhead.take();
    _typed.text = seed ?? _fmt(_d);
    _typed.selection = seed != null
        ? TextSelection.collapsed(offset: seed.length)
        : TextSelection(baseOffset: 0, extentOffset: _typed.text.length);
  }

  @override
  void dispose() {
    _typed.dispose();
    super.dispose();
  }

  bool _inRange(Duration d) => d >= widget.min && d <= widget.max;

  void _onTyped(String t) {
    if (t.trim().isEmpty) {
      setState(() => _error = null);
      return;
    }
    final d = widget.showHours ? unifiedParseTypedDuration(t) : unifiedParseTypedDuration('${t}m');
    if (d == null) {
      setState(() => _error = 'Try 1:30, 90m or 1h 30m');
    } else if (!_inRange(d)) {
      setState(() => _error = 'Out of range');
    } else {
      setState(() {
        _error = null;
        _d = d;
      });
    }
  }

  void _set(Duration d) {
    final x = d < widget.min ? widget.min : (d > widget.max ? widget.max : d);
    setState(() {
      _d = x;
      _error = null;
      _typed.text = _fmt(x);
    });
  }

  void _commit() {
    if (_error != null) return;
    Navigator.of(context).pop(_d);
  }

  @override
  Widget build(BuildContext context) {
    final s = UnifiedResolvedPickerSurface.of(context);
    final strings = UnifiedFieldsStrings.instance;
    final anchored = UnifiedPickerPresentationScope.isAnchoredOf(context);
    final h = _d.inHours;
    final m = _d.inMinutes.remainder(60);
    final sec = _d.inSeconds.remainder(60);
    final maxH = math.min(widget.max.inHours, 99);
    final presets = (widget.presets ??
            const [
              Duration(minutes: 15),
              Duration(minutes: 30),
              Duration(minutes: 45),
              Duration(hours: 1),
              Duration(hours: 1, minutes: 30),
              Duration(hours: 2),
            ])
        .where(_inRange)
        .toList();
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!anchored && widget.title != null) ...[
            Text(widget.title!, style: s.itemTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
          ],
          UnifiedTypedEntryField(
            controller: _typed,
            hint: widget.showHours ? 'h:mm · 90m · 1h 30m' : 'minutes',
            icon: Icons.timelapse_rounded,
            error: _error,
            onChanged: _onTyped,
            onSubmitted: (_) => _commit(),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (widget.showHours) ...[
                Expanded(
                  child: _ValueColumn(
                    label: strings.hourLabel,
                    count: maxH + 1,
                    value: h,
                    format: (v) => '$v',
                    onChanged: (v) => _set(Duration(hours: v, minutes: m, seconds: sec)),
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: _ValueColumn(
                  label: strings.minuteLabel,
                  count: 60,
                  value: m,
                  onChanged: (v) => _set(Duration(hours: h, minutes: v, seconds: sec)),
                ),
              ),
              if (widget.showSeconds) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: _ValueColumn(
                    label: strings.secondLabel,
                    count: 60,
                    value: sec,
                    onChanged: (v) => _set(Duration(hours: h, minutes: m, seconds: v)),
                  ),
                ),
              ],
            ],
          ),
          if (presets.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final p in presets) _PresetChip(label: chipLabel(p), selected: p == _d, onTap: () => _set(p)),
              ],
            ),
          ],
          const SizedBox(height: 10),
          _Footer(
            leading: null,
            onCancel: () => Navigator.of(context).maybePop(),
            onDone: _error == null ? _commit : null,
          ),
        ],
      ),
    );
  }
}

/// Opens [UnifiedFieldsCompactDurationPicker] anchored to [context] (or as dialog / sheet).
Future<Duration?> showUnifiedFieldsCompactDurationPicker({
  required BuildContext context,
  required Duration initial,
  Duration min = Duration.zero,
  Duration max = const Duration(hours: 99, minutes: 59),
  bool showHours = true,
  bool showSeconds = false,
  List<Duration>? presets,
  String? title,
  UnifiedPickerPresentation? presentation,
  UnifiedPickerSurfaceStyle? surfaceStyle,
  bool barrierDismissible = true,
}) {
  final columns = (showHours ? 1 : 0) + 1 + (showSeconds ? 1 : 0);
  return showUnifiedCompactPicker<Duration>(
    context: context,
    presentation: presentation,
    surfaceStyle: surfaceStyle,
    barrierDismissible: barrierDismissible,
    width: 120.0 + columns * 72,
    builder: (_) => UnifiedFieldsCompactDurationPicker(
      initial: initial,
      min: min,
      max: max,
      showHours: showHours,
      showSeconds: showSeconds,
      presets: presets,
      title: title,
    ),
  );
}

// ---------------------------------------------------------------------------
// Date range
// ---------------------------------------------------------------------------

/// Compact range calendar: From / To typed entry, one or two months (two when
/// the surface is ≥ 520 wide), hover preview, presets and a day count. Pops a
/// [DateTimeRange] (inclusive, date-only).
class UnifiedFieldsCompactDateRangePicker extends StatefulWidget {
  /// Creates a compact range picker.
  const UnifiedFieldsCompactDateRangePicker({
    super.key,
    required this.initialRange,
    required this.firstDate,
    required this.lastDate,
    this.title,
    this.typedPattern,
    this.showPresets = true,
  });

  /// Initial range (null = none).
  final DateTimeRange? initialRange;

  /// Earliest selectable date.
  final DateTime firstDate;

  /// Latest selectable date.
  final DateTime lastDate;

  /// Title in dialog / sheet mode.
  final String? title;

  /// Typed pattern; defaults to theme `typedDateFormat` or `yyyy-MM-dd`.
  final String? typedPattern;

  /// Today · Last 7 days · Next 7 days · This month chips.
  final bool showPresets;

  @override
  State<UnifiedFieldsCompactDateRangePicker> createState() => _UnifiedFieldsCompactDateRangePickerState();
}

class _UnifiedFieldsCompactDateRangePickerState extends State<UnifiedFieldsCompactDateRangePicker> {
  late DateTime? _start = widget.initialRange == null ? null : DateUtils.dateOnly(widget.initialRange!.start);
  late DateTime? _end = widget.initialRange == null ? null : DateUtils.dateOnly(widget.initialRange!.end);
  DateTime? _hover;
  late DateTime _month;
  final _from = TextEditingController();
  final _to = TextEditingController();
  String? _fromError;
  String? _toError;
  String _pattern = 'yyyy-MM-dd';
  bool _ready = false;

  DateTime get _first => DateUtils.dateOnly(widget.firstDate);
  DateTime get _last => DateUtils.dateOnly(widget.lastDate);
  bool _enabled(DateTime d) => !d.isBefore(_first) && !d.isAfter(_last);

  @override
  void initState() {
    super.initState();
    final anchor = _start ?? DateUtils.dateOnly(DateTime.now());
    final a = anchor.isBefore(_first) ? _first : (anchor.isAfter(_last) ? _last : anchor);
    _month = DateTime(a.year, a.month);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_ready) return;
    _ready = true;
    _pattern = widget.typedPattern ?? UnifiedInputThemeScope.themeDataOf(context).typedDateFormat ?? 'yyyy-MM-dd';
    final seed = UnifiedPickerTypeAhead.take();
    _syncTyped();
    if (seed != null) {
      _from.text = seed;
      _from.selection = TextSelection.collapsed(offset: seed.length);
    }
  }

  @override
  void dispose() {
    _from.dispose();
    _to.dispose();
    super.dispose();
  }

  void _syncTyped() {
    final f = DateFormat(_pattern);
    _from.text = _start == null ? '' : f.format(_start!);
    _to.text = _end == null ? '' : f.format(_end!);
  }

  DateTime? _parse(String t) {
    if (t.length < _pattern.length) return null;
    try {
      return DateUtils.dateOnly(DateFormat(_pattern).parseStrict(t));
    } catch (_) {
      return null;
    }
  }

  void _onTyped(String t, {required bool isFrom}) {
    String? err;
    final d = _parse(t);
    if (t.length >= _pattern.length) {
      if (d == null) {
        err = 'Use ${_pattern.toLowerCase()}';
      } else if (!_enabled(d)) {
        err = 'Out of range';
      } else if (isFrom && _end != null && d.isAfter(_end!)) {
        err = 'After end';
      } else if (!isFrom && _start != null && d.isBefore(_start!)) {
        err = 'Before start';
      }
    }
    setState(() {
      if (isFrom) {
        _fromError = err;
        if (err == null && d != null) {
          _start = d;
          _month = DateTime(d.year, d.month);
        }
      } else {
        _toError = err;
        if (err == null && d != null) {
          _end = d;
          _month = DateTime(d.year, d.month - (_twoMonths ? 1 : 0));
        }
      }
    });
  }

  bool _twoMonths = false;

  void _tap(DateTime d) {
    if (!_enabled(d)) return;
    setState(() {
      if (_start == null || _end != null || d.isBefore(_start!)) {
        _start = d;
        _end = null;
      } else {
        _end = d;
      }
      _fromError = null;
      _toError = null;
      _syncTyped();
    });
  }

  void _preset(DateTime a, DateTime b) {
    final s = a.isBefore(_first) ? _first : a;
    final e = b.isAfter(_last) ? _last : b;
    if (e.isBefore(s)) return;
    setState(() {
      _start = s;
      _end = e;
      _month = DateTime(s.year, s.month);
      _fromError = null;
      _toError = null;
      _syncTyped();
    });
  }

  void _commit() {
    if (_start == null || _fromError != null || _toError != null) return;
    Navigator.of(context).pop(DateTimeRange(start: _start!, end: _end ?? _start!));
  }

  @override
  Widget build(BuildContext context) {
    final s = UnifiedResolvedPickerSurface.of(context);
    final loc = MaterialLocalizations.of(context);
    final anchored = UnifiedPickerPresentationScope.isAnchoredOf(context);
    final today = DateUtils.dateOnly(DateTime.now());
    final days = _start == null ? 0 : (_end ?? _start!).difference(_start!).inDays + 1;
    return LayoutBuilder(
      builder: (context, c) {
        _twoMonths = c.maxWidth >= 520;
        final months = [_month, if (_twoMonths) DateUtils.addMonthsToMonthDate(_month, 1)];
        final canPrev = DateTime(_month.year, _month.month).isAfter(DateTime(_first.year, _first.month));
        final lastShown = months.last;
        final canNext = DateTime(lastShown.year, lastShown.month).isBefore(DateTime(_last.year, _last.month));
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!anchored && widget.title != null) ...[
                Text(widget.title!, style: s.itemTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 10),
              ],
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: UnifiedTypedEntryField(
                      controller: _from,
                      hint: _pattern.toLowerCase(),
                      icon: Icons.first_page_rounded,
                      error: _fromError,
                      inputFormatters: [UnifiedMaskedDigitsFormatter(_pattern)],
                      onChanged: (t) => _onTyped(t, isFrom: true),
                      onSubmitted: (_) => _commit(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
                    child: Icon(Icons.arrow_forward_rounded, size: 16, color: s.mutedTextStyle.color),
                  ),
                  Expanded(
                    child: UnifiedTypedEntryField(
                      controller: _to,
                      autofocus: false,
                      hint: _pattern.toLowerCase(),
                      icon: Icons.last_page_rounded,
                      error: _toError,
                      inputFormatters: [UnifiedMaskedDigitsFormatter(_pattern)],
                      onChanged: (t) => _onTyped(t, isFrom: false),
                      onSubmitted: (_) => _commit(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < months.length; i++) ...[
                    if (i > 0) const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            height: 28,
                            child: Row(
                              children: [
                                if (i == 0)
                                  _NavButton(
                                    icon: Icons.chevron_left_rounded,
                                    tooltip: loc.previousMonthTooltip,
                                    onPressed: canPrev
                                        ? () => setState(() => _month = DateUtils.addMonthsToMonthDate(_month, -1))
                                        : null,
                                  )
                                else
                                  const SizedBox(width: 28),
                                Expanded(
                                  child: Center(
                                    child: Text(
                                      DateFormat.yMMMM().format(months[i]),
                                      style: s.itemTextStyle.copyWith(fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ),
                                if (i == months.length - 1)
                                  _NavButton(
                                    icon: Icons.chevron_right_rounded,
                                    tooltip: loc.nextMonthTooltip,
                                    onPressed: canNext
                                        ? () => setState(() => _month = DateUtils.addMonthsToMonthDate(_month, 1))
                                        : null,
                                  )
                                else
                                  const SizedBox(width: 28),
                              ],
                            ),
                          ),
                          const SizedBox(height: 8),
                          _RangeMonth(
                            month: months[i],
                            start: _start,
                            end: _end ?? (_start != null && _hover != null && !_hover!.isBefore(_start!) ? _hover : null),
                            preview: _end == null,
                            today: today,
                            enabled: _enabled,
                            onTap: _tap,
                            onHover: (d) {
                              if (_end == null && _start != null && d != _hover) setState(() => _hover = d);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              if (widget.showPresets) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    _PresetChip(label: loc.currentDateLabel, onTap: () => _preset(today, today)),
                    _PresetChip(
                      label: 'Last 7 days',
                      onTap: () => _preset(today.subtract(const Duration(days: 6)), today),
                    ),
                    _PresetChip(label: 'Next 7 days', onTap: () => _preset(today, today.add(const Duration(days: 6)))),
                    _PresetChip(
                      label: 'This month',
                      onTap: () => _preset(DateTime(today.year, today.month), DateTime(today.year, today.month + 1, 0)),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 10),
              _Footer(
                leading: Text(
                  _start == null ? 'Pick a start date' : '$days day${days == 1 ? '' : 's'}',
                  style: s.mutedTextStyle,
                ),
                onCancel: () => Navigator.of(context).maybePop(),
                onDone: _start == null || _fromError != null || _toError != null ? null : _commit,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RangeMonth extends StatelessWidget {
  const _RangeMonth({
    required this.month,
    required this.start,
    required this.end,
    required this.preview,
    required this.today,
    required this.enabled,
    required this.onTap,
    required this.onHover,
  });

  final DateTime month;
  final DateTime? start;
  final DateTime? end;
  final bool preview;
  final DateTime today;
  final bool Function(DateTime) enabled;
  final ValueChanged<DateTime> onTap;
  final ValueChanged<DateTime> onHover;

  @override
  Widget build(BuildContext context) {
    final s = UnifiedResolvedPickerSurface.of(context);
    final loc = MaterialLocalizations.of(context);
    final fdw = loc.firstDayOfWeekIndex;
    final first = DateTime(month.year, month.month);
    final lead = (first.weekday % 7 - fdw + 7) % 7;
    final start0 = first.subtract(Duration(days: lead));
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            for (var i = 0; i < 7; i++)
              Expanded(child: Center(child: Text(loc.narrowWeekdays[(fdw + i) % 7], style: s.sectionTextStyle))),
          ],
        ),
        const SizedBox(height: 4),
        for (var r = 0; r < 6; r++)
          Row(
            children: [
              for (var c = 0; c < 7; c++)
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final d = DateUtils.dateOnly(DateTime(start0.year, start0.month, start0.day + r * 7 + c));
                      final inMonth = d.month == month.month;
                      if (!inMonth) return const SizedBox(height: 34);
                      final isStart = start != null && DateUtils.isSameDay(d, start);
                      final isEnd = end != null && DateUtils.isSameDay(d, end);
                      final between = start != null && end != null && d.isAfter(start!) && d.isBefore(end!);
                      final band = between || ((isStart || isEnd) && start != null && end != null && start != end);
                      final on = enabled(d);
                      final cap = isStart || isEnd;
                      return MouseRegion(
                        onEnter: (_) => onHover(d),
                        child: Container(
                          height: 34,
                          margin: const EdgeInsets.symmetric(vertical: 1),
                          decoration: BoxDecoration(
                            color: band ? s.rowSelectedColor.withValues(alpha: preview ? 0.5 : 1) : null,
                            borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(isStart || c == 0 ? s.rowRadius : 0),
                              right: Radius.circular(isEnd || c == 6 ? s.rowRadius : 0),
                            ),
                          ),
                          child: Material(
                            color: cap ? s.accentColor : Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(s.rowRadius),
                              side: !cap && DateUtils.isSameDay(d, today)
                                  ? BorderSide(color: s.todayColor, width: 1.2)
                                  : BorderSide.none,
                            ),
                            child: InkWell(
                              canRequestFocus: false,
                              borderRadius: BorderRadius.circular(s.rowRadius),
                              hoverColor: s.rowHoverColor,
                              onTap: on ? () => onTap(d) : null,
                              child: Center(
                                child: Text(
                                  '${d.day}',
                                  style: s.monoTextStyle.copyWith(
                                    fontSize: 13,
                                    fontWeight: cap ? FontWeight.w600 : FontWeight.w400,
                                    color: cap
                                        ? s.onAccentColor
                                        : (on
                                            ? (band ? s.rowSelectedTextColor : s.itemTextStyle.color)
                                            : s.mutedTextStyle.color!.withValues(alpha: 0.35)),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

/// Opens [UnifiedFieldsCompactDateRangePicker] anchored to [context] (or as dialog / sheet).
Future<DateTimeRange?> showUnifiedFieldsCompactDateRangePicker({
  required BuildContext context,
  DateTimeRange? initialRange,
  required DateTime firstDate,
  required DateTime lastDate,
  String? title,
  String? typedPattern,
  bool showPresets = true,
  UnifiedPickerPresentation? presentation,
  UnifiedPickerSurfaceStyle? surfaceStyle,
  bool barrierDismissible = true,
}) {
  return showUnifiedCompactPicker<DateTimeRange>(
    context: context,
    presentation: presentation,
    surfaceStyle: surfaceStyle,
    barrierDismissible: barrierDismissible,
    width: 600,
    builder: (_) => UnifiedFieldsCompactDateRangePicker(
      initialRange: initialRange,
      firstDate: firstDate,
      lastDate: lastDate,
      title: title,
      typedPattern: typedPattern,
      showPresets: showPresets,
    ),
  );
}
