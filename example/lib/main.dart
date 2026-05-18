import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:unified_fields/unified_fields.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    UnifiedInputThemeScope(
      data: const UnifiedInputThemeData(
        requiredIconColor: Color(0xFF1565C0),
        requiredIconSize: 9,
        validationColor: Color(0xFFD32F2F),
        disabledFieldOpacity: 0.38,

        placeholderOpacityWhenDisabled: 0.38,
        pickerSheetBackgroundColor: Color(0xFFF5F7FA),
        defaultSuffixIcons: UnifiedInputDefaultSuffixIcons(
          date: Icons.calendar_month_outlined,
          time: Icons.access_time,
          duration: Icons.timelapse_outlined,
          picker: Icons.unfold_more,
        ),
        pickerHeaderStyle: const UnifiedInputPickerHeaderStyle(
          padding: EdgeInsets.fromLTRB(16, 14, 8, 14),
        ),
        multiPickerCheckboxStyle: const UnifiedInputMultiPickerCheckboxStyle(
          borderRadius: 4,
          fillColor: Color(0xFF1565C0),
        ),
      ),
      child: const UnifiedFieldsDemoApp(),
    ),
  );
}

/// Demo entry. Wires every notable widget from the `unified_fields` package
/// into a single `Form` so you can see validate / save / reset working with
/// the same `GlobalKey<FormState>` for every field type.
class UnifiedFieldsDemoApp extends StatelessWidget {
  const UnifiedFieldsDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'unified_fields demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff2A5CFF))),
      home: const DemoHomePage(),
    );
  }
}

/// Demo page hosting the showcase and a simple form that exercises every
/// `UnifiedForm*` wrapper.
class DemoHomePage extends StatefulWidget {
  const DemoHomePage({super.key});

  @override
  State<DemoHomePage> createState() => _DemoHomePageState();
}

class _DemoHomePageState extends State<DemoHomePage> {
  final _formKey = GlobalKey<FormState>();

  final _name = UnifiedInputPicker<String>(initialValue: '');
  final _nameC = UnifiedTextFieldController();
  final _country = UnifiedInputPicker<String>(initialValue: null);
  final _countryController = UnifiedPickerFieldController<String>();
  final _flavors = UnifiedInputPicker<List<String>>(initialValue: const []);
  final _date = UnifiedInputPicker<DateTime>(initialValue: null);
  final _time = UnifiedInputPicker<TimeOfDay>(initialValue: null);
  final _duration = UnifiedInputPicker<Duration>(initialValue: const Duration(minutes: 5));
  final UnifiedPhoneFieldController phoneC = UnifiedPhoneFieldController();
  late final CustomizableSinglePickerController<String> _customSingle;
  late final CustomizableMultiPickerController<String> _customMulti;

  static const _countries = <String>['Iran', 'Türkiye', 'Germany', 'Japan', 'Brazil', 'Canada'];
  static const _flavorChoices = <String>['Sweet', 'Acidic', 'Nutty', 'Floral', 'Chocolate'];

  String _savedSummary = '';
  List<String> selectedGrid  = [];
  @override
  void initState() {
    super.initState();
    _customSingle = CustomizableSinglePickerController<String>(valueToString: (e) => e, initialKind: CustomizablePickerInputKind.typed, initialTyped: '');
    _customMulti = CustomizableMultiPickerController<String>(valueToString: (e) => e);
  }

  @override
  void dispose() {
    _name.dispose();
    _country.dispose();
    _flavors.dispose();
    _date.dispose();
    _time.dispose();
    _duration.dispose();
    _customSingle.dispose();
    _customMulti.dispose();
    super.dispose();
  }
  final testFC = CustomizableSinglePickerController<String>();
  final gridPickFC = UnifiedMultiPickerFieldController<String>();
  Future<List<String>> _loadAsyncCountries() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return _countries;
  }

  void _onValidate() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState!.save();
      setState(() {
        _savedSummary = [
          'name: ${_name.value ?? ''}',
          'country: ${_country.value ?? '—'}',
          'flavors: ${_flavors.value?.join(', ') ?? ''}',
          'date: ${_date.value?.toIso8601String().split('T').first ?? '—'}',
          'time: ${_time.value?.format(context) ?? '—'}',
          'duration: ${_duration.value}',
          'custom single: ${_customSingle.fieldDisplayText}',
          'custom multi: ${_customMulti.fieldDisplayText}',
        ].join('\n');
      });
    }
  }

  void _onReset() {
    _formKey.currentState?.reset();
    setState(() => _savedSummary = '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('unified_fields demo'),
        actions: [
          IconButton(
            tooltip: 'Open full showcase',
            icon: const Icon(Icons.dashboard_customize_outlined),

            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => Scaffold(
                  appBar: AppBar(),
                  body: const SafeArea(
                    child: Padding(padding: EdgeInsets.all(8.0), child: UnifiedInputsShowcasePage()),
                  ),
                ),
              ),
            ),
          ),
          IconButton(
            tooltip: 'Open full showcase',
            icon: const Icon(Icons.clear),


            onPressed: () {
              // _nameC.requestFocus();
              // log(phoneC.value!.nationalDigits);
              // testFC.openPicker(context);
              // gridPickFC.openPicker(context);
              gridPickFC.clear();
              // _countryController.openPicker(context);

              // _country.clear();
              // _countryController.openPicker(context, items: [], label: "label");
              // _countryController.clear();
              // setState((){});
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: UnifiedFormFieldScope(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'A small form using every UnifiedForm* widget. '
                    'Tap Validate to run validators and save state, '
                    'or Reset to restore each field with its resetValue.',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  _ThemeScopeDemoCard(),
                  const SizedBox(height: 12),
                  Text(phoneC.dialCodeController.text),
                  UnifiedCustomizablePickerField<String>(
                    label: "Test",
                    valueToString: (v) => v.toString(),
                    gridDelegate: unifiedPickerDefaultGridDelegate(
                      crossAxisCount: 3,
                      childAspectRatio: 4,
                    ),

                    items:["1","2","3","4","5","6","7",],
                    gridItemBuilder: (c,i,item,onselect){
                      return TextButton(onPressed: (){
                        onselect();
                      }, child: Text("${i} -${item}"));
                    },
                    pickerController: testFC,
                  ),
                  UnifiedMultiPickerField<String>(
                    label: "Test",
                    isDisabled: true,
                    gridItemBuilder: (context, index, item, isSelected, onSelect) {
                      return GestureDetector(
                        onTap: onSelect,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.blue : Colors.grey.shade200,
                          ),
                          child: Center(child: Text(item)),
                        ),
                      );
                    },
                    onChanged: (a){
                      selectedGrid = [...a];
                      setState((){});
                    },
                    fieldController: gridPickFC,
                    valueToString: (v) => v.toString(),
                    gridDelegate: unifiedPickerDefaultGridDelegate(
                      crossAxisCount: 3,
                      childAspectRatio: 4,
                    ),
                    items:["1","2","3","4","5","6","7",],
                    // gridItemBuilder: (c,i,item,onselect){
                    //   return TextButton(onPressed: (){
                    //     onselect();
                    //   }, child: Text("${i} -${item}"));
                    // },
                    values: selectedGrid,
                  ),
                  UnifiedCountryWidget(country: UnifiedCountries.defaultCountry),
                  UnifiedPhoneField(
                    label: "Phone",
                    usePersianDigits: true,
                    fieldController: phoneC,
                    labelMode: UnifiedFieldLabelMode.labelInColumn,
                    phoneStyle: UnifiedInputPhoneStyle(),
                    // editableCountryCode: true,
                    // showCountryCodeSection: true,
                    invalidDialCodeDisplay: UnifiedInvalidDialCodeDisplay.highlightText,
                    // fixedCountry: UnifiedPhoneCountry(isoCode: 'ir', name: 'ir', dialCode: '+98'),

                    // editableCountryCode: false,

                  ),
                  UnifiedFormTextField(
                    label: 'Full name',

                    decoration: UnifiedInputDecoration(
                      labelInRow: true,

                      height: 40,

                      // headerBackgroundColor: Colors.red,
                      // backgroundColor: Colors.blue
                      // borderRadius: BorderRadius.circular(5)
                    ),
                    placeholder: 'e.g. Ada Lovelace',
                    isRequired: true,
                    binding: _name,
                    fieldController: _nameC,
                    // locked: true,
                    // disabled: true,
                    resetValue: () => '',
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),

                  UnifiedFormSinglePickerField<String>(
                    label: 'Country',
                    decoration: UnifiedInputDecoration(height: 40, labelInRow: true),
                    placeholder: 'Pick one',
                    isRequired: true,
                    items: _countries,
                    fieldController: _countryController,

                    binding: _country,
                    validator: (v) => v == null ? 'Pick a country' : null,
                  ),
                  const SizedBox(height: 12),

                  UnifiedFormMultiPickerField<String>(
                      isDisabled: true,
                      label: 'Flavors', placeholder: 'Add some', items: _flavorChoices, values: _flavors.value ?? const [], binding: _flavors, resetValue: () => const <String>[]),
                  const SizedBox(height: 12),

                  UnifiedFormDateField(
                    label: 'Date (form, wheels)',
                    placeholder: 'Tap to pick',
                    isRequired: true,
                    binding: _date,
                    min: DateTime(2020),
                    max: DateTime(2035),
                    pickerStyle: UnifiedFieldsDatePickerStyle.wheels,
                    initialCalendarKind: UnifiedFieldsCalendarKind.gregorian,
                    pickerGranularity: UnifiedFieldsDatePickerGranularity.day,
                    resetValue: () => null,
                    validator: (v) => v == null ? 'Pick a date' : null,
                  ),
                  const SizedBox(height: 12),

                  UnifiedDateField(
                    label: 'Date',
                    placeholder: 'Tap to pick',
                    isRequired: true,
                    binding: _date,

                    min: DateTime(2020),
                    showCalendarKindToggle: false,

                    initialCalendarKind: UnifiedFieldsCalendarKind.jalali,



                    max: DateTime(2035),
                    // pickerGranularity: UnifiedFieldsDatePickerGranularity.year,
                    validator: (v) => v.trim().isEmpty ? 'Pick a date' : null,
                  ),
                  const SizedBox(height: 12),
                  UnifiedTimeOfDayField(
                    pickerStyle: UnifiedFieldsTimePickerStyle.wheels,
                    pickerGranularity: UnifiedFieldsTimeGranularity.hoursMinutesSeconds, // or .hours / .hoursMinutes
                    initialCalendarKind: UnifiedFieldsCalendarKind.jalali,

                    showCalendarKindToggle: true,
                    value: TimeOfDay(hour: 14, minute: 30),
                  ),
                  const SizedBox(height: 12),
                  UnifiedDurationField(
                    // locked: true,
                    // isDisabled: true,
                    // showCalendarKindToggle: false,
                    // pickerStyle: UnifiedFieldsDurationPickerStyle.wheels, // default
                    // granularity: UnifiedDurationGranularity.hoursMinutesSeconds, // or .hours / .hoursMinutesSeconds
                    // initialCalendarKind: UnifiedFieldsCalendarKind.jalali,
                    // value: const Duration(hours: 1, minutes: 30),
                    // pickerColumns: [UnifiedFieldsDurationColumn.year,UnifiedFieldsDurationColumn.month,UnifiedFieldsDurationColumn.week],
                  ),
                  const SizedBox(height: 12),

                  UnifiedFormTimeOfDayField(label: 'Time', placeholder: 'Tap to pick', binding: _time, resetValue: () => null),
                  const SizedBox(height: 12),

                  UnifiedFormDurationField(label: 'Duration', placeholder: 'Tap to edit', binding: _duration, granularity: UnifiedDurationGranularity.hoursMinutesSeconds, resetValue: () => Duration.zero),
                  const SizedBox(height: 12),

                  UnifiedFormAsyncPickerField<String>(label: 'Country (async)', placeholder: 'Loads on tap', itemProvider: _loadAsyncCountries),
                  const SizedBox(height: 12),

                  UnifiedFormCustomizablePickerField<String>(
                    label: 'Origin (free text or pick)',
                    placeholder: 'Type or open the sheet',
                    items: _countries,
                    pickerController: _customSingle,
                    resetValue: () => const CustomizableSinglePickerSnapshot<String>.empty(),
                  ),
                  const SizedBox(height: 12),

                  UnifiedFormCustomizableMultiPickerField<String>(
                    label: 'Tags',
                    placeholder: 'Type or pick multiple',
                    items: _flavorChoices,
                    pickerController: _customMulti,
                    allowFreeText: false,
                    resetValue: () => const CustomizableMultiPickerSnapshot<String>.empty(),
                  ),
                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: FilledButton(onPressed: _onValidate, child: const Text('Validate + Save')),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(onPressed: _onReset, child: const Text('Reset')),
                      ),
                    ],
                  ),
                  if (_savedSummary.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)),
                      child: Text(_savedSummary, style: const TextStyle(fontFamily: 'monospace')),
                    ),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Contrasts app-wide [UnifiedInputThemeScope] (from [main]) with a local override.
class _ThemeScopeDemoCard extends StatelessWidget {
  const _ThemeScopeDemoCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'UnifiedInputThemeScope',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'The whole app uses the scope from main() (blue required *, custom picker icons). '
              'This card adds a nested scope with orange required icons.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            const UnifiedTextField(
              label: 'App scope (blue *)',
              isRequired: true,
              initialValue: 'Uses main() theme',
            ),
            const SizedBox(height: 12),
            UnifiedInputThemeScope(
              data: const UnifiedInputThemeData(
                requiredIconColor: Color(0xFFE65100),
                requiredIconSize: 11,
                validationColor: Color(0xFF6A1B9A),
                disabledFieldColor: Color(0xFF757575),
                disabledFieldOpacity: 0.5,
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  UnifiedTextField(
                    label: 'Nested scope (orange *)',
                    isRequired: true,
                    initialValue: 'Overrides required icon only',
                  ),
                  SizedBox(height: 12),
                  UnifiedTextField(
                    label: 'Disabled (nested grey)',
                    isDisabled: true,
                    initialValue: 'Themed disabled value',
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
