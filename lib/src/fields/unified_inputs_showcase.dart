import 'package:flutter/material.dart';

import 'unified_input_picker.dart';
import 'unified_async_picker_field.dart';
import 'unified_customizable_async_picker_field.dart';
import 'unified_customizable_picker_controller.dart';
import 'unified_duration_field.dart';
import 'unified_form_fields.dart';
import 'unified_form_more_fields.dart';
import 'unified_input_brightness.dart';
import 'unified_input_decoration.dart';
import 'unified_number_field.dart';
import 'unified_picker_fields.dart';
import 'unified_text_field.dart';
import '../unified_date_picker_sheet.dart';
import '../unified_time_picker_types.dart';
import 'unified_date_field.dart';
import 'unified_time_of_day_field.dart';

/// Scrollable demo of every unified input widget + palette toggle (follow theme / light / dark).
///
/// Push inside your app, for example:
/// `Navigator.of(context).push(MaterialPageRoute(builder: (_) => const UnifiedInputsShowcasePage()));`
///
/// Safe to embed under scrollables / tabs: [LayoutBuilder] + [SizedBox] clamps to viewport when the parent passes unbounded constraints (otherwise [Scaffold] cannot compute size).
class UnifiedInputsShowcasePage extends StatefulWidget {
  /// Creates the showcase page.
  const UnifiedInputsShowcasePage({super.key});

  @override
  State<UnifiedInputsShowcasePage> createState() => _UnifiedInputsShowcasePageState();
}

class _UnifiedInputsShowcasePageState extends State<UnifiedInputsShowcasePage> {
  /// `null` = follow [Theme]; otherwise force unified palette.
  UnifiedInputBrightness? _paletteMode;

  late final TextEditingController _numberCtrl;
  late final UnifiedInputPicker<String> _textBinding;
  late final UnifiedInputPicker<DateTime> _dateBinding;
  late final UnifiedInputPicker<DateTimeRange> _dateRangeBinding;
  late final CustomizableSinglePickerController<String> _customAsyncPick;
  late final CustomizableMultiPickerController<String> _customAsyncMultiPick;

  DateTime? _dateFallback = DateTime.now();
  TimeOfDay? _time = TimeOfDay.now();
  Duration? _duration = const Duration(minutes: 5, seconds: 30);
  String? _singlePick = 'Arabica';
  List<String> _multiPick = ['Sweet'];
  List<String> _asyncMultiPick = [];

  static const _pickerItems = ['Arabica', 'Robusta', 'Blend', 'Excelsa', 'Liberica'];

  final GlobalKey<FormState> _formDemoKey = GlobalKey<FormState>();
  String _formDemoLastSaved = '';

  @override
  void initState() {
    super.initState();
    _numberCtrl = TextEditingController(text: '12');
    _textBinding = UnifiedInputPicker<String>(initialValue: 'Programmatic binding');
    _dateBinding = UnifiedInputPicker<DateTime>(initialValue: DateTime.now());
    _dateRangeBinding = UnifiedInputPicker<DateTimeRange>(
      initialValue: DateTimeRange(
        start: DateTime.now(),
        end: DateTime.now().add(const Duration(days: 7)),
      ),
    );
    _customAsyncPick = CustomizableSinglePickerController<String>(
      valueToString: (e) => e,
      initialKind: CustomizablePickerInputKind.typed,
      initialTyped: '',
    );
    _customAsyncPick.addListener(_onCustomAsyncPick);
    _customAsyncMultiPick = CustomizableMultiPickerController<String>(
      valueToString: (e) => e,
    );
    _customAsyncMultiPick.addListener(_onCustomAsyncMultiPick);
  }

  void _onCustomAsyncMultiPick() {
    if (mounted) setState(() {});
  }

  void _onCustomAsyncPick() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _numberCtrl.dispose();
    _textBinding.dispose();
    _dateBinding.dispose();
    _dateRangeBinding.dispose();
    _customAsyncPick.removeListener(_onCustomAsyncPick);
    _customAsyncPick.dispose();
    _customAsyncMultiPick.removeListener(_onCustomAsyncMultiPick);
    _customAsyncMultiPick.dispose();
    super.dispose();
  }

  Future<List<String>> _asyncLoader() async {
    await Future<void>.delayed(const Duration(milliseconds: 650));
    return const ['Fetched option A', 'Fetched option B', 'Fetched option C'];
  }

  String _rangeSummary(DateTimeRange? r) {
    if (r == null) return '—';
    final s = r.start.toIso8601String().split('T').first;
    final e = r.end.toIso8601String().split('T').first;
    return '$s → $e';
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 16),
      child: Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
    );
  }

  Widget _brightnessControls() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Text('Unified palette'),
          SegmentedButton<UnifiedInputBrightness?>(
            segments: const [
              ButtonSegment(value: null, label: Text('Theme')),
              ButtonSegment(value: UnifiedInputBrightness.light, label: Text('Light')),
              ButtonSegment(value: UnifiedInputBrightness.dark, label: Text('Dark')),
            ],
            selected: {_paletteMode},
            onSelectionChanged: (s) => setState(() => _paletteMode = s.first),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(body: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Unified inputs',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Scroll through fields. For pickers, tap to open the sheet. Theme dropdown only affects unified palettes (labels/bodies/sheets).',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).hintColor),
          ),
          _brightnessControls(),
          ListenableBuilder(
            listenable: _textBinding,
            builder: (context, _) => Text(
              'Text binding value: "${_textBinding.value ?? ''}"',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          _sectionTitle('UnifiedFieldShell (custom body + error strip)'),
          // Builder(
          //   builder: (ctx) {
          //     final dec = resolveUnifiedDecoration(ctx, brightness: _paletteMode).merge(
          //       const UnifiedInputDecoration(
          //         label: 'Shell demo',
          //         placeholder: 'Tap nothing — visual only',
          //         requiredField: false,
          //       ),
          //     );
          //     return UnifiedFieldShell(
          //       decoration: dec,
          //       errorText: dec.showError ? 'Example validation message' : null,
          //       body: Center(
          //         child: Padding(
          //           padding: const EdgeInsets.symmetric(vertical: 16),
          //           child: Text(
          //             'Any widget goes here',
          //             style: dec.fieldStyle?.copyWith(fontWeight: FontWeight.w500),
          //           ),
          //         ),
          //       ),
          //     );
          //   },
          // ),
          _sectionTitle('UnifiedTextField (+ UnifiedInputPicker binding)'),
          UnifiedTextField(
            brightness: _paletteMode,
            decoration: const UnifiedInputDecoration(
              label: 'Your name',
              placeholder: 'Full name',
              requiredField: true,
            ),
            binding: _textBinding,
            validator: (v) => v.trim().isEmpty ? 'Required' : null,
            maxLines: 1,
          ),
          Row(
            children: [
              TextButton(onPressed: () => _textBinding.value = 'Reset from button', child: const Text('Set binding')),
              TextButton(onPressed: () => _textBinding.clear(), child: const Text('Clear')),
            ],
          ),
          _sectionTitle('UnifiedNumberField'),
          UnifiedNumberField(
            brightness: _paletteMode,
            decoration: const UnifiedInputDecoration(
              label: 'Dose (g)',
              placeholder: 'grams',
            ),
            controller: _numberCtrl,
            allowDecimals: true,
            step: 0.5,
            min: 0,
            max: 50,
            fractionDigits: 1,
            validator: (v) {
              final n = num.tryParse(v);
              if (n == null || n <= 0) return 'Enter a positive number';
              return null;
            },
            onChanged: (_) => setState(() {}),
          ),
          Text('Raw controller text: ${_numberCtrl.text}', style: Theme.of(context).textTheme.bodySmall),
          _sectionTitle('UnifiedDateField'),
          UnifiedDateField(
            brightness: _paletteMode,
            decoration: const UnifiedInputDecoration(label: 'Roast date'),
            binding: _dateBinding,
            min: DateTime(2020),
            max: DateTime(2035),
            onChanged: (d) => setState(() => _dateFallback = d),
          ),
          _sectionTitle('UnifiedDateField (wheel picker + Shamsi)'),
          UnifiedDateField(
            brightness: _paletteMode,
            decoration: const UnifiedInputDecoration(label: 'Wheel date'),
            value: _dateFallback,
            pickerStyle: UnifiedFieldsDatePickerStyle.wheels,
            initialCalendarKind: UnifiedFieldsCalendarKind.jalali,
            min: DateTime(2020),
            max: DateTime(2035),
            onChanged: (d) => setState(() => _dateFallback = d),
          ),
          Text(
            'Binding: ${_dateBinding.value?.toIso8601String().split('T').first ?? '—'}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          _sectionTitle('UnifiedDateField (value prop only)'),
          UnifiedDateField(
            brightness: _paletteMode,
            decoration: const UnifiedInputDecoration(label: 'Backup date (state)'),
            value: _dateFallback,
            onChanged: (d) => setState(() => _dateFallback = d),
          ),
          _sectionTitle('UnifiedDateRangeField'),
          UnifiedDateRangeField(
            brightness: _paletteMode,
            decoration: const UnifiedInputDecoration(label: 'Trip dates'),
            binding: _dateRangeBinding,
            min: DateTime(2020),
            max: DateTime(2035),
            onRangeChanged: (_) => setState(() {}),
          ),
          Text(
            'Range binding: ${_rangeSummary(_dateRangeBinding.value)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          _sectionTitle('UnifiedTimeOfDayField (wheel, Shamsi)'),
          UnifiedTimeOfDayField(
            brightness: _paletteMode,
            decoration: const UnifiedInputDecoration(label: 'Reminder time'),
            value: _time,
            pickerStyle: UnifiedFieldsTimePickerStyle.wheels,
            pickerGranularity: UnifiedFieldsTimeGranularity.hoursMinutesSeconds,
            initialCalendarKind: UnifiedFieldsCalendarKind.jalali,
            locked: false,
            onChanged: (t) => setState(() => _time = t),
          ),
          _sectionTitle('UnifiedDurationField (wheel H:M:S, Shamsi)'),
          UnifiedDurationField(
            brightness: _paletteMode,
            decoration: const UnifiedInputDecoration(label: 'Bloom duration'),
            granularity: UnifiedDurationGranularity.hoursMinutesSeconds,
            pickerStyle: UnifiedFieldsDurationPickerStyle.wheels,
            initialCalendarKind: UnifiedFieldsCalendarKind.jalali,
            value: _duration,
            min: Duration.zero,
            max: const Duration(hours: 2),
            onChanged: (d) => setState(() => _duration = d),
            validator: (v) => v.isEmpty ? 'Pick a duration' : null,
          ),
          _sectionTitle('UnifiedDurationField (custom: year · week · day · hour)'),
          UnifiedDurationField(
            brightness: _paletteMode,
            decoration: const UnifiedInputDecoration(label: 'Age / tenure'),
            pickerColumns: UnifiedFieldsDurationColumnPresets.yearsWeeksDaysHours,
            initialCalendarKind: UnifiedFieldsCalendarKind.jalali,
            value: const Duration(days: 400, hours: 5),
            max: const Duration(days: 365 * 10),
          ),
          _sectionTitle('UnifiedDurationField (M:S)'),
          UnifiedDurationField(
            brightness: _paletteMode,
            decoration: const UnifiedInputDecoration(label: 'Pour window'),
            granularity: UnifiedDurationGranularity.minutesSeconds,
            value: const Duration(minutes: 45, seconds: 15),
            min: Duration.zero,
            max: const Duration(minutes: 120),
          ),
          _sectionTitle('UnifiedSinglePickerField'),
          UnifiedSinglePickerField<String>(
            brightness: _paletteMode,
            decoration: UnifiedInputDecoration(
              label: 'Origin bean',
              suffixIcon: Icon(Icons.eco, color: Theme.of(context).colorScheme.primary),
            ),
            label: 'Origin bean',
            items: _pickerItems,
            value: _singlePick,
            suggestion: const ['Arabica'],
            onChanged: (v) => setState(() => _singlePick = v),
            valueToString: (e) => e,
            searchBuilder: (e) => e,
            validator: (s) => s.isEmpty ? 'Pick one' : null,
          ),
          _sectionTitle('UnifiedMultiPickerField'),
          UnifiedMultiPickerField<String>(
            brightness: _paletteMode,
            decoration: const UnifiedInputDecoration(label: 'Flavor notes'),
            label: 'Flavor notes',
            items: const ['Sweet', 'Acidic', 'Nutty', 'Floral', 'Chocolate'],
            values: _multiPick,
            onChanged: (v) => setState(() => _multiPick = List.of(v)),
            valueToString: (e) => e,
            validator: (s) => s.isEmpty ? 'Pick at least one' : null,
          ),
          Text('Selected: ${_multiPick.join(', ')}', style: Theme.of(context).textTheme.bodySmall),
          _sectionTitle('UnifiedAsyncPickerField'),
          UnifiedAsyncPickerField<String>(
            brightness: _paletteMode,
            decoration: const UnifiedInputDecoration(label: 'Async-loaded list'),
            label: 'Remote-ish options',
            itemProvider: _asyncLoader,
            value: null,
            onChanged: (_) {},
            valueToString: (e) => e,
            validator: (s) => null,
          ),
          _sectionTitle('UnifiedCustomizableAsyncPickerField'),
          UnifiedCustomizableAsyncPickerField<String>(
            brightness: _paletteMode,
            decoration: const UnifiedInputDecoration(label: 'Async + free text / pick'),
            label: 'Async customizable',
            itemProvider: _asyncLoader,
            pickerController: _customAsyncPick,
            valueToString: (e) => e,
            validator: (s) => null,
          ),
          Text(
            'Kind: ${_customAsyncPick.inputKind} | typed: "${_customAsyncPick.typedText}" | selected: ${_customAsyncPick.selectedItem ?? "—"}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          _sectionTitle('UnifiedAsyncMultiPickerField'),
          UnifiedAsyncMultiPickerField<String>(
            brightness: _paletteMode,
            decoration: const UnifiedInputDecoration(label: 'Async-loaded multi'),
            label: 'Async multi',
            itemProvider: _asyncLoader,
            values: _asyncMultiPick,
            onChanged: (v) => setState(() => _asyncMultiPick = List.of(v)),
            valueToString: (e) => e,
            validator: (s) => null,
          ),
          Text('Selected: ${_asyncMultiPick.join(', ')}', style: Theme.of(context).textTheme.bodySmall),
          _sectionTitle('UnifiedCustomizableAsyncMultiPickerField'),
          UnifiedCustomizableAsyncMultiPickerField<String>(
            brightness: _paletteMode,
            decoration: const UnifiedInputDecoration(label: 'Async customizable multi'),
            label: 'Async customizable multi',
            itemProvider: _asyncLoader,
            pickerController: _customAsyncMultiPick,
            valueToString: (e) => e,
            validator: (s) => null,
          ),
          Text(
            'Kind: ${_customAsyncMultiPick.inputKind} | typed: "${_customAsyncMultiPick.typedText}" | selected: ${_customAsyncMultiPick.selectedItems.join(", ")}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          _sectionTitle('Form + UnifiedFormTextField'),
          UnifiedFormFieldScope(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Form(
              key: _formDemoKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  UnifiedFormTextField(
                    brightness: _paletteMode,
                    decoration: const UnifiedInputDecoration(label: 'Inside Form'),
                    label: 'Required name',
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    onSaved: (v) => setState(() => _formDemoLastSaved = v?.trim() ?? ''),
                  ),
                  const SizedBox(height: 12),
                  UnifiedFormDateField(
                    brightness: _paletteMode,
                    label: 'Form date (wheels)',
                    pickerStyle: UnifiedFieldsDatePickerStyle.wheels,
                    min: DateTime(2020),
                    max: DateTime(2035),
                    validator: (v) => v == null ? 'Pick a date' : null,
                  ),
                  if (_formDemoLastSaved.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text('Last saved: $_formDemoLastSaved', style: Theme.of(context).textTheme.bodySmall),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: FilledButton(
                      onPressed: () {
                        if (_formDemoKey.currentState?.validate() ?? false) {
                          _formDemoKey.currentState?.save();
                        }
                      },
                      child: const Text('Validate + save'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    ),);

    // body = UnifiedInputThemeScope(
    //   brightnessOverride: _paletteMode,
    //   child: body,
    // );

    // Scaffold needs finite max constraints. Parents like nested scroll views can pass
    // unbounded height; resolve against [MediaQuery] so layout/paint always succeeds.
    // return LayoutBuilder(
    //   builder: (context, constraints) {
    //     final mediaSize = MediaQuery.sizeOf(context);
    //     final w = constraints.maxWidth.isFinite ? constraints.maxWidth : mediaSize.width;
    //     final h = constraints.maxHeight.isFinite ? constraints.maxHeight : mediaSize.height;
    //
    //     return SizedBox(
    //       width: w,
    //       height: h,
    //       child: Scaffold(
    //         backgroundColor: scaffoldBg,
    //         appBar: AppBar(
    //           title: const Text('Unified inputs showcase'),
    //           actions: [
    //             IconButton(
    //               tooltip: 'Rebuild',
    //               icon: const Icon(Icons.refresh),
    //               onPressed: () => setState(() {}),
    //             ),
    //           ],
    //         ),
    //         body: body,
    //       ),
    //     );
    //   },
    // );
  }
}
