# unified_fields

**Unified Flutter input widgets**—text, numbers, pickers, duration, date & time—and **form-aware** wrappers that plug into [`Form`](https://api.flutter.dev/flutter/widgets/Form-class.html) with validation, save, reset, and optional **shake-on-error** feedback. Includes a **Gregorian / Jalali (Shamsi)** calendar sheet and a **vendored scrollable positioned list** for large picker lists (no `scrollable_positioned_list` pub dependency).

---

## Table of contents

1. [Add to your app](#add-to-your-app)  
2. [What you get (feature map)](#what-you-get-feature-map)  
3. [Core concepts](#core-concepts)  
4. [Form integration (validate · save · reset)](#form-integration-validate--save--reset)  
5. [Shake on validation error](#shake-on-validation-error)  
6. [Date & calendar](#date--calendar)  
7. [Time](#time)  
8. [Duration](#duration)  
9. [Pickers](#pickers)  
10. [Phone (`UnifiedPhoneField`)](#phone-unifiedphonefield)  
11. [Bindings with `UnifiedInputPicker`](#bindings-with-unifiedinputpicker)  
12. [Field controllers](#field-controllers)  
13. [Field states & label layout](#field-states--label-layout)  
14. [UI strings (`UnifiedFieldsStrings`)](#ui-strings-unifiedfieldsstrings)  
15. [Theming & layout](#theming--layout)  
16. [Global theme (`UnifiedInputThemeScope`)](#global-theme-unifiedinputthemescope)  
17. [Persian digits (`UnifiedFieldsTypography`)](#persian-digits-unifiedfieldstypography)  
18. [Localization](#localization)  
19. [Try the built-in demo](#try-the-built-in-demo)  
20. [Dependencies](#dependencies)  

---

## Add to your app

Published on **[pub.dev/packages/unified_fields](https://pub.dev/packages/unified_fields)**. In **`pubspec.yaml`**:

```yaml
dependencies:
  unified_fields: ^0.2.5
```

Run **`dart pub get`** (or **`flutter pub get`**).

**Import**

```dart
import 'package:unified_fields/unified_fields.dart';
```

**SDK:** Dart `^3.10`, Flutter `>=3.22` (see `pubspec.yaml`).

### Git or local path (contributors / forks)

If you need a specific commit or a local checkout instead of pub.dev:

```yaml
dependencies:
  unified_fields:
    git:
      url: https://github.com/MahmoodBakhshayesh/unified_fields.git
      ref: main # or a tag / commit SHA
```

```yaml
dependencies:
  unified_fields:
    path: ../unified_fields # relative path to your clone
```

---

## What you get (feature map)

| Area | Widgets / APIs | Purpose |
|------|------------------|---------|
| **Plain fields** | `UnifiedTextField`, `UnifiedNumberField`, `UnifiedNumericStepField`, `UnifiedPhoneField`, `UnifiedDurationField`, `UnifiedDateField`, `UnifiedDateRangeField`, `UnifiedTimeOfDayField` | Same visual system as form fields, without `FormField` |
| **Phone** | `UnifiedPhoneField`, `UnifiedPhoneFieldController`, `UnifiedCountry`, `UnifiedCountries`, `UnifiedCountryWidget`, `UnifiedFlag`, `showUnifiedPhoneCountryPicker`, `UnifiedPhoneNumber` | Country flag, dial code, masked national number, ~250-country enum, Persian digits |
| **Pickers** | `UnifiedSinglePickerField`, `UnifiedMultiPickerField`, `UnifiedAsyncPickerField`, `UnifiedAsyncMultiPickerField` | Bottom-sheet list or grid (`gridItemBuilder`, `gridDelegate`); async variants load items on demand |
| **Customizable pickers** | `UnifiedCustomizablePickerField`, `UnifiedCustomizableMultiPickerField`, `UnifiedCustomizableAsyncPickerField`, `UnifiedCustomizableAsyncMultiPickerField`, `CustomizableSinglePickerController`, `CustomizableMultiPickerController` | Controller-driven single or multi selection that also accepts free typed text |
| **Form wrappers** | `UnifiedFormField`, `UnifiedFormTextField`, `UnifiedFormSinglePickerField`, `UnifiedFormMultiPickerField`, `UnifiedFormAsyncPickerField`, `UnifiedFormAsyncMultiPickerField`, `UnifiedFormDateField`, `UnifiedFormDateRangeField`, `UnifiedFormTimeOfDayField`, `UnifiedFormDurationField`, `UnifiedFormNumberField`, `UnifiedFormCustomizablePickerField`, `UnifiedFormCustomizableMultiPickerField`, `UnifiedFormCustomizableAsyncPickerField`, `UnifiedFormCustomizableAsyncMultiPickerField` | `Form` integration: `validate`, `save`, `reset`, validators |
| **Form scope** | `UnifiedFormFieldScope` | Shared `AutovalidateMode` for all unified form descendants |
| **Calendar** | `showUnifiedFieldsDatePicker`, `showUnifiedFieldsDatePickerRange`, `UnifiedFieldsDatePickerSheet`, `UnifiedFieldsDatePickerGranularity`, `UnifiedFieldsCalendarKind`, `UnifiedFieldsDatePickerStyle` | Single date or range; calendar grid or scroll wheels; Gregorian vs Jalali |
| **Time** | `UnifiedTimeOfDayField`, `showUnifiedFieldsTimePicker`, `UnifiedFieldsTimePickerStyle`, `UnifiedFieldsTimeGranularity`, `TimePickerUtils.show` | Material dial (default) or H:M:S wheels with Shamsi digit toggle |
| **Duration** | `UnifiedDurationField`, `showUnifiedFieldsDurationPicker`, `UnifiedFieldsDurationColumn`, `UnifiedFieldsDurationColumnPresets`, `UnifiedDurationGranularity`, `UnifiedFieldsDurationPickerStyle` | Wheel picker with fixed granularity or custom column order (year · week · day · hour, …) |
| **Chrome helpers** | `UnifiedBaseTextField`, `UnifiedFieldShell`, `UnifiedFieldLabelMode`, `UnifiedInputDecoration`, `UnifiedInputDecorationSet`, `UnifiedInputFieldDefaults`, `UnifiedInputBrightness`, `UnifiedInputPalette`, `UnifiedInputThemeScope`, `UnifiedInputPhoneStyle`, `UnifiedInputPickerHeaderStyle`, `UnifiedInputMultiPickerCheckboxStyle`, `UnifiedSuffixIconChrome` | Labels, errors, palettes, per-state borders/fills, theme field defaults, phone/dial chrome, global theme scope, picker headers, aligned suffix icons |
| **Controllers** | `UnifiedPickerFieldController`, `UnifiedMultiPickerFieldController`, `UnifiedAsyncPickerFieldController`, `UnifiedDateFieldController`, `UnifiedTimeOfDayFieldController`, `UnifiedDurationFieldController`, `UnifiedNumberFieldController`, `UnifiedPhoneFieldController`, `UnifiedFormController` | Listenable value + validation + imperative `openPicker` / `requestFocus` |
| **Utilities** | `UnifiedInputPicker`, `UnifiedFieldsStrings`, `UnifiedFieldsTypography`, `UnifiedFieldsContextX`, `UnifiedColors`, `UnifiedSheetButton`, `unifiedPickerDefaultGridDelegate`, `showUnifiedSinglePickerSheet`, `showUnifiedMultiPickerSheet`, `unifiedFormErrorText`, `unifiedFormPickerOverride`, `attachUnifiedFieldHandles` | State binding, global UI copy, Persian digits, picker grid helpers, layout helpers, default colors, sheet actions |
| **Demo** | `UnifiedInputsShowcasePage` | Scrollable gallery of widgets + palette toggle |

---

## Core concepts

### One visual language

Fields share **`UnifiedInputDecoration`** (label, placeholder, `labelStyle`, `fieldStyle`, `placeholderStyle`, radii, validation colors, prefix/suffix) and **`UnifiedInputBrightness`** (light / dark palette). For colors that should be the same on every field (disabled chrome, required `*`, validation red, picker sheet background), wrap your app or a screen in **`UnifiedInputThemeScope`** — see [Global theme](#global-theme-unifiedinputthemescope).

### Per-state decoration (`decorationSet`)

Like Material `InputDecoration` focus/error borders, pass optional layers via **`decorationSet`** (or theme-wide **`fieldDecorationSet`**). Each layer is a partial **`UnifiedInputDecoration`**; unset properties fall back to **`decoration`** / palette defaults.

```dart
UnifiedTextField(
  decoration: const UnifiedInputDecoration(
    borderSide: BorderSide(color: Colors.grey),
  ),
  decorationSet: UnifiedInputDecorationSet(
    focused: const UnifiedInputDecoration(
      borderSide: BorderSide(color: Colors.blue, width: 1.5),
    ),
    error: const UnifiedInputDecoration(
      borderSide: BorderSide(color: Colors.red),
      validationColor: Colors.red,
    ),
    disabled: const UnifiedInputDecoration(
      backgroundColor: Color(0xFFF5F5F5),
    ),
  ),
)
```

**States:** `base`, `focused`, `valid`, `error`, `locked`, `disabled`, `loading`, `readOnly`. The `valid` layer applies only when you define it and validation has passed with no error.

### Two usage modes

1. **Standalone** — e.g. `UnifiedTextField`, `UnifiedSinglePickerField`: drop into any screen; you own validation if needed.  
2. **Under a `Form`** — use `UnifiedForm…` variants so **`GlobalKey<FormState>`** can call **`validate()`**, **`save()`**, and **`reset()`** on the whole form.

### `label`, `placeholder`, `isRequired`

Every field exposes **`label`**, **`placeholder`**, and **`isRequired`** as root-level constructor parameters. They always win over the equivalent values inside **`UnifiedInputDecoration`** (which still work as the form-wide default):

```dart
UnifiedTextField(
  label: 'Email',
  placeholder: 'name@example.com',
  isRequired: true,
)
```

### Placeholder, label, and focus defaults (0.2.4+)

**Value text style** — set on `UnifiedInputFieldDefaults` (or per field via `UnifiedInputDecoration.fieldStyle`, `UnifiedBaseTextField.style`, or `style` on phone/date fields):

```dart
fieldDefaults: const UnifiedInputFieldDefaults(
  textStyle: TextStyle(fontSize: 16, color: Colors.black87),
  textStylePersian: TextStyle(fontFamily: 'KookFaNum'),
),
```

Applies to text/number fields, **`UnifiedPhoneField`**, **`UnifiedDateField`**, and **`UnifiedDateRangeField`**. When Persian digits are active (Jalali calendar, `usePersianDigits`, or global Persian mode), `textStylePersian` is **merged** onto `textStyle` (font family, weight, size, etc.).

**Placeholder style** — set on decoration or theme; inherits field typography (`fontFamily`, `fontSize`, …) unless you override:

```dart
UnifiedTextField(
  decoration: const UnifiedInputDecoration(
    fieldStyle: TextStyle(fontFamily: 'Vazirmatn', fontSize: 16),
    // placeholder uses Vazirmatn 16 + theme hint color
    placeholderStyle: TextStyle(fontStyle: FontStyle.italic),
  ),
  placeholder: 'Search…',
)
```

**Label style / padding per layout mode** — on `UnifiedInputFieldDefaults`:

```dart
fieldDefaults: const UnifiedInputFieldDefaults(
  labelInRowStyle: UnifiedInputLabelModeStyle(
    labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
    labelPadding: EdgeInsets.symmetric(horizontal: 12),
  ),
  labelInColumnStyle: UnifiedInputLabelModeStyle(
    labelPadding: EdgeInsets.only(top: 4, bottom: 6),
  ),
),
```

**Select all on focus** — useful for number fields; replace value on first keystroke:

```dart
UnifiedNumberField(
  controller: quantityController, // e.g. text: '42'
  selectTextOnFocus: true,
  label: 'Quantity',
)
```

Or app-wide: `UnifiedInputFieldDefaults(selectTextOnFocus: true)`.

### `UnifiedFormField<T>`

Low-level shell: one **`FormField<T>`** + your **`builder`**. Prefer the prebuilt `UnifiedForm…` widgets; use **`UnifiedFormField`** when you need a custom control but the same autovalidate, reset sync, and optional **`shakeOnError`**.

---

## Form integration (validate · save · reset)

Wrap inputs in a **`Form`** and keep a key:

```dart
final _formKey = GlobalKey<FormState>();

@override
Widget build(BuildContext context) {
  return Form(
    key: _formKey,
    child: Column(
      children: [
        UnifiedFormTextField(
          label: 'Name',
          validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
        ),
        UnifiedFormSinglePickerField<String?>(
          label: 'Country',
          items: countries,
          resetValue: () => null, // on Form reset, clear selection
          validator: (v) => v == null ? 'Pick one' : null,
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
            }
          },
          child: const Text('Submit'),
        ),
      ],
    ),
  );
}
```

### Reset behavior — `UnifiedFormResetValue<T>`

```dart
typedef UnifiedFormResetValue<T> = T Function();
```

| You pass | On `FormState.reset` |
|----------|----------------------|
| `resetValue: null` (default) | Field value is **not** forced by reset (baseline tracks live value / controller). |
| `resetValue: () => ''` | Text / number string resets to empty. |
| `resetValue: () => null` | Nullable picker / date clears to **null** (use nullable generic, e.g. `UnifiedFormSinglePickerField<MyEnum?>`). |
| `resetValue: () => model.defaultX` | Restores that snapshot (pass a **new** closure if the snapshot should change). |
| Lists | `UnifiedFormMultiPickerField`: `resetValue: () => const <T>[]` or `() => myList` |

Nullable **return type** is carried by **`T`** on the picker (e.g. `RoastLevel?`), not by `T?` on the typedef.

---

## Shake on validation error

Any `UnifiedForm…` widget and **`UnifiedFormField`** accept **`shakeOnError`** (default **`false`**). When **`true`**, the field runs a short horizontal shake the first time **`hasError`** goes from false to true (typical failed **`validate()`**).

```dart
UnifiedFormTextField(
  label: 'Email',
  shakeOnError: true,
  validator: (v) => v!.contains('@') ? null : 'Invalid',
)
```

---

## Date & calendar

### Sheet API

- **`showUnifiedFieldsDatePicker`** — returns **`DateTime?`**.  
- **`showUnifiedFieldsDatePickerRange`** — returns **`DateTimeRange?`**.  

Presentation: **bottom sheet** on smaller widths; **centered dialog** when **`context.unifiedFieldsUseDialogLayout`** is true (see **`UnifiedFieldsContextX`** — width ≥ 900).

### Granularity (`UnifiedFieldsDatePickerGranularity`)

- **`day`** — full month grid (default).  
- **`month`** — pick first day of month in range.  
- **`year`** — pick first day of year in range.  

### Calendars (`UnifiedFieldsCalendarKind`)

Users can switch **Gregorian** vs **Jalali (Shamsi)** when **`showCalendarKindToggle`** is true. Jalali math uses the **`shamsi_date`** package.

### Widgets

- **`UnifiedDateField`** / **`UnifiedFormDateField`** — text field + tap to open picker.  
- **`UnifiedDateRangeField`** / **`UnifiedFormDateRangeField`** — range in one field.

### Picker style (`UnifiedFieldsDatePickerStyle`)

| Style | UI |
|-------|-----|
| **`calendar`** (default) | Month grid (day granularity) or year/month lists |
| **`wheels`** | Scroll wheels left→right: **year · month · day** (subset per **`pickerGranularity`**) |

Both styles support **Gregorian / Shamsi** when `showCalendarKindToggle` is true. In Shamsi wheel mode, column headers use **سال / ماه / روز** (customize via `UnifiedFieldsStrings`). Set `showWeekdayInWheel: false` to show only the day numeral; weekday + day use fixed column widths on `UnifiedFieldsDateWheelStyle`.

Calendar **today** is shown as a hollow circle (same shape as the selected day fill).

```dart
UnifiedDateField(
  label: 'Birth date',
  pickerStyle: UnifiedFieldsDatePickerStyle.wheels,
  showWeekdayInWheel: true,
  initialCalendarKind: UnifiedFieldsCalendarKind.jalali,
  pickerGranularity: UnifiedFieldsDatePickerGranularity.day,
)

// Same parameters on the Form wrapper:
UnifiedFormDateField(
  label: 'Birth date',
  pickerStyle: UnifiedFieldsDatePickerStyle.wheels,
  wheelStyle: null, // optional; auto-themed when omitted
)
```

Date **ranges** still use the calendar sheet (`showUnifiedFieldsDatePickerRange`).

Wheel chrome is themed automatically (`UnifiedFieldsDateWheelStyle.resolve`). Pass optional `wheelStyle:` only when you need custom colors or zoom.

**Jalali field text:** when `initialCalendarKind` / active kind is **`jalali`**, the field shows Shamsi-formatted text (e.g. `۱۳,مرداد ۱۴۰۳`) after pick, not a Gregorian `DateFormat`. `initialCalendarKind: jalali` applies to **both** calendar grid and wheel pickers (0.1.4).

```dart
UnifiedDateField(
  label: 'Event',
  initialCalendarKind: UnifiedFieldsCalendarKind.jalali,
  pickerStyle: UnifiedFieldsDatePickerStyle.calendar, // grid respects jalali
)
```

---

## Time

- **`UnifiedTimeOfDayField`** / **`UnifiedFormTimeOfDayField`** — display + edit time with unified chrome.  
- **`showUnifiedFieldsTimePicker`** — bottom sheet with **`UnifiedFieldsTimePickerStyle.dial`** (Material) or **`wheels`** (H:M:S scroll wheels).  
- **`TimePickerUtils.show(context, …)`** — forwards to **`showUnifiedFieldsTimePicker`** (wheels by default in recent versions; pass `pickerStyle` to use the platform dial).

### Picker style (`UnifiedFieldsTimePickerStyle`)

| Style | UI |
|-------|-----|
| **`dial`** | Platform **`showTimePicker`** |
| **`wheels`** | Scroll wheels for hour · minute · (optional) second |

### Granularity (`UnifiedFieldsTimeGranularity`)

- **`hours`** — hour wheel only  
- **`hoursMinutes`** — hour + minute (default for wheels)  
- **`hoursMinutesSeconds`** — hour + minute + second  

Wheels support **Gregorian / Shamsi** digit toggle via **`initialCalendarKind`** and **`showCalendarKindToggle`** (same idea as date/duration wheels).

```dart
UnifiedTimeOfDayField(
  label: 'Start time',
  pickerStyle: UnifiedFieldsTimePickerStyle.wheels,
  pickerGranularity: UnifiedFieldsTimeGranularity.hoursMinutesSeconds,
  initialCalendarKind: UnifiedFieldsCalendarKind.jalali,
)
```

---

## Duration

- **`UnifiedDurationField`** / **`UnifiedFormDurationField`** — tap to open a duration sheet; optional manual edit of the formatted string.  
- **`showUnifiedFieldsDurationPicker`** — imperative sheet API (also used internally by the field).

### Picker style (`UnifiedFieldsDurationPickerStyle`)

| Style | UI |
|-------|-----|
| **`wheels`** (default) | Unified scroll wheels (themed like date/time wheels) |
| **`cupertino`** | Legacy Cupertino-style H:M:S wheels |

### Granularity vs custom columns

Use **`granularity`** for the classic fixed shapes when you do **not** need year/month/week:

| `UnifiedDurationGranularity` | Columns | Display example |
|------------------------------|---------|-----------------|
| **`hours`** | hour | `05` |
| **`hoursMinutes`** | hour, minute | `05:30` |
| **`hoursMinutesSeconds`** | hour, minute, second | `05:30:45` |
| **`minutesSeconds`** | minute, second (minutes may exceed 59) | `90:00` |

Use **`pickerColumns`** when you need **calendar-style units** in a custom order (largest unit first, left → right on the wheel):

```dart
UnifiedDurationField(
  label: 'Tenure',
  pickerColumns: [
    UnifiedFieldsDurationColumn.year,
    UnifiedFieldsDurationColumn.week,
    UnifiedFieldsDurationColumn.day,
    UnifiedFieldsDurationColumn.hour,
  ],
  // or: UnifiedFieldsDurationColumnPresets.yearsWeeksDaysHours
  initialCalendarKind: UnifiedFieldsCalendarKind.jalali,
  min: Duration.zero,
  max: const Duration(days: 365 * 10),
)
```

**`UnifiedFieldsDurationColumn`:** `year`, `month`, `week`, `day`, `hour`, `minute`, `second`.

**Presets** on **`UnifiedFieldsDurationColumnPresets`:** `yearsMonthsDays`, `yearsWeeksDaysHours`, `hoursMinutesSeconds`, `minutesSeconds`.

When **`pickerColumns`** is set, it overrides **`granularity`** for both the picker and display format. Wheel ranges: **year** `0…999`, **month** `0…11`, **week** `0…4` (when used with coarser calendar columns). Totals still compose with **year = 365 days**, **month = 30 days**, **week = 7 days** per unit (standard day/hour/minute/second otherwise); the result is clamped to **`max`** on confirm.

Helpers: **`unifiedFormatDuration`**, **`unifiedTryParseDuration`**, **`composeUnifiedDuration`**, **`decomposeUnifiedDuration`**, **`formatUnifiedDurationColumns`**.

---

## Pickers

| Widget | Data |
|--------|------|
| **`UnifiedSinglePickerField<T>`** | `T?` selection, searchable list, suggestions |
| **`UnifiedMultiPickerField<T>`** | `List<T>`, checkboxes in sheet |
| **`UnifiedAsyncPickerField<T>`** | Items from `Future<List<T>> Function()` |
| **`UnifiedAsyncMultiPickerField<T>`** | Same, multi-select |

**`PickerSheetWidget`** / **`MultiPickerSheetWidget`** are the sheet implementations (scrollable list + search). Every picker field and **`UnifiedForm*Picker*`** wrapper supports the same sheet customization:

| Parameter | Purpose |
|-----------|---------|
| **`itemToWidget`** | Custom list row (default: text from `valueToString`) |
| **`searchBuilder`** | Custom searchable text per item |
| **`gridItemBuilder`** | Custom grid tile; sheet uses **`GridView`** instead of a list |
| **`gridDelegate`** | Full **`SliverGridDelegate`** (max extent, fixed count, spacing, aspect ratio, …). Omit to use **`unifiedPickerDefaultGridDelegate()`** |

**Grid (single-select):** builder receives `(context, index, item, onSelect)` — call **`onSelect`** to choose and close.

**Grid (multi-select):** builder receives `(context, index, item, isSelected, onSelect)` — **`onSelect`** toggles selection; user confirms in the sheet footer.

```dart
UnifiedMultiPickerField<String>(
  label: 'Tags',
  values: selected,
  items: allTags,
  gridDelegate: unifiedPickerDefaultGridDelegate(crossAxisCount: 3, childAspectRatio: 1.2),
  gridItemBuilder: (context, index, item, isSelected, onSelect) => FilterChip(
    label: Text(item),
    selected: isSelected,
    onSelected: (_) => onSelect(),
  ),
)
```

**Form:** use **`UnifiedFormMultiPickerField`** (or any other `UnifiedForm*Picker*`) with the same parameters. Imperative open: **`fieldController.openPicker(context)`** or **`pickerController.openPicker(context)`** on customizable controllers after **`bindPicker`**.

**Standalone sheets:** **`showUnifiedSinglePickerSheet`** / **`showUnifiedMultiPickerSheet`**.

**Customizable** APIs (`unified_cutomizable_picker_fields.dart` — filename keeps the historical typo **cutomizable**): single or multi selection with **`CustomizableSinglePickerController`** / **`CustomizableMultiPickerController`** plus async siblings for remote data. Each controller carries either typed text **or** the selected value(s); the matching **`UnifiedFormCustomizable…`** wrappers expose `resetValue` snapshots so `FormState.reset` restores both the mode and the payload in one step.

---

## Phone (`UnifiedPhoneField`)

International phone input with **SVG flags** (bundled under `assets/flags/countries/`), optional **dial-code** segment, **national mask** (`#` = digit), and a default **phone** suffix icon.

### Countries

Countries are a fixed **`UnifiedCountry` enum** (~250 entries) with ISO code, display name, and dial code:

```dart
UnifiedCountry.ir.isoCode   // IR
UnifiedCountry.ir.dialCode  // +98
UnifiedCountries.byIso('DE')
UnifiedCountries.matchDialCode('+98912…')
UnifiedCountries.defaults   // all enum values (picker / field default list)
```

India uses **`UnifiedCountry.countryIN`** (`in` is a reserved Dart name). Regenerate the enum after editing `tool/countries.json`:

```bash
dart run tool/generate_unified_countries.dart
```

### Field usage

```dart
UnifiedPhoneField(
  label: 'Mobile',
  placeholder: '912 123 4567',
  labelMode: UnifiedFieldLabelMode.labelInColumn,
  usePersianDigits: true, // or digitCalendarKind: UnifiedFieldsCalendarKind.jalali
  fixedCountry: UnifiedCountry.ir, // optional: lock dial code
  // showCountryCodeSection: true,
  // editableCountryCode: true, // one field: + dial + national
  fieldController: UnifiedPhoneFieldController(
    initialCountry: UnifiedCountry.ir,
    onChanged: (UnifiedPhoneNumber? n) => debugPrint(n?.e164),
  ),
)
```

| Mode | Behavior |
|------|----------|
| **Editable dial code** (default when code section is shown) | Single input: `+` + country code + masked national digits |
| **Fixed country** (`fixedCountry`) | Flag + dial label + national digits only |
| **Non-editable code section** | Dial label (tap opens picker) + national field |

Theme phone chrome via **`UnifiedInputPhoneStyle`** / **`UnifiedInputThemeData.phoneStyle`** (dial-code box, flag size, invalid-code highlight vs message).

### Standalone widgets

```dart
UnifiedCountryWidget(country: UnifiedCountry.ae) // flag only (showName defaults to false)
UnifiedCountryWidget(country: UnifiedCountry.ir, showName: true, showDialCode: true)
UnifiedFlag(code: 'IR', size: 28)

final picked = await showUnifiedPhoneCountryPicker(
  context: context,
  countries: UnifiedCountries.defaults,
  usePersianDigits: true,
);
```

**`UnifiedPhoneNumber`** exposes `country`, `nationalDigits`, `e164`, `display`, and `localizedDisplay` / `localizedE164` when using Persian digits.

---

## Bindings with `UnifiedInputPicker`

**`UnifiedInputPicker<T>`** is a **`ChangeNotifier`** holding **`value`**, optional **`errorText`**, and helpers **`clear`**, **`setError`**, **`silentSetValue`**. Pass it as **`binding:`** on fields so UI and domain state stay in sync; form wrappers also write back on save/reset when configured.

Form-aware pickers and date/time fields **listen to the binding**, so clearing from code updates the visible field:

```dart
final country = UnifiedInputPicker<String?>();

UnifiedFormSinglePickerField<String?>(
  label: 'Country',
  binding: country,
  items: countries,
);

// Later — UI and FormField both clear:
country.clear();
```

You can use **`binding`** and **`fieldController`** together: the binding holds app state; the typed controller adds picker-specific APIs (`openPicker`, `displayText`, sheet options).

> `AppInputController` was renamed in **0.1.4**; a deprecated typedef points to **`UnifiedInputPicker`**.

---

## Field controllers

**`BaseUnifiedFieldController<T>`** (and typed subclasses) mirror **`TextEditingController`** for pickers, dates, numbers, and duration. Pass **`fieldController:`** on the matching **`Unified…`** widget.

| Controller | Field(s) |
|------------|----------|
| **`UnifiedPickerFieldController<T>`** | `UnifiedSinglePickerField`, `UnifiedAsyncPickerField` |
| **`UnifiedMultiPickerFieldController<T>`** | `UnifiedMultiPickerField`, `UnifiedAsyncMultiPickerField` |
| **`UnifiedDateFieldController`** | `UnifiedDateField` |
| **`UnifiedDateRangeFieldController`** | `UnifiedDateRangeField` |
| **`UnifiedTimeOfDayFieldController`** | `UnifiedTimeOfDayField` |
| **`UnifiedDurationFieldController`** | `UnifiedDurationField` |
| **`UnifiedNumberFieldController`** | `UnifiedNumberField`, `UnifiedNumericStepField` |

When the field is **mounted**, **`openPicker(context)`** (and async **`openPickerAsync`**) use the same code path as a tap—no need to pass **`items`** / **`label`** again. Off-tree or tests: call **`bindPicker`** / **`bindPickerLabel`** first, or pass **`items`** and **`label`** explicitly.

**`requestFocus()`** on the controller (or on a **`binding`** that shares the attached focus node) focuses the wired field.

**`UnifiedFormController`** coordinates multiple controllers for validate/save/reset on a custom form layout.

---

## Field states & label layout

Shared by **`UnifiedBaseTextField`** and every field built on it:

| Parameter | Effect |
|-----------|--------|
| **`isDisabled` / `disabled`** | Read-only look; when both placeholder and value exist, **both** are shown (not hidden like a greyed empty field). |
| **`locked`** | Blocks interaction; distinct from disabled styling. |
| **`loading`** | Small **suffix spinner** (replaces dropdown/chevron); field does **not** use full-field overlay or muted disabled colors. |
| **`interactionBlocked`** | Absorbs pointer events without disabled chrome—used for pick-only surfaces (date, async picker while idle). |
| **`labelMode`** / **`labelInRow`** | **`UnifiedFieldLabelMode`**: `floatingLabel` (default), `labelInColumn`, or `labelInRow` (label + body in one bordered row with a vertical divider). Legacy `labelInRow: true` on decoration maps to row mode. |

Async pickers set **`loading: true`** while **`itemProvider`** runs; date fields use **`interactionBlocked: true`** so the platform picker still opens without **`disabled: true`**. **`UnifiedPhoneField`** supports the same label modes plus optional **`height`** / **`width`**.

---

## UI strings (`UnifiedFieldsStrings`)

All built-in button and sheet copy (Cancel, Confirm, Clear, Done, Pick, Suggestion, date-picker labels, time hour/minute labels, default duration title) comes from **`UnifiedFieldsStrings.instance`**. Override once at startup:

```dart
void main() {
  UnifiedFieldsStrings.instance = const UnifiedFieldsStrings(
    cancel: 'لغو',
    confirm: 'تأیید',
    clear: 'پاک کردن',
    pickPrefix: 'انتخاب',
  );
  runApp(const MyApp());
}
```

Multi-picker titles use **`multiPickerTitle(label)`** (default `"Pick $label"`). **`UnifiedDatePickerStrings`** is deprecated and reads from the same instance.

---

## Theming & layout

- **`UnifiedColors`** — default static palette used by built-in styles (replace over time with your design tokens or override via **`UnifiedInputDecoration`** / **`Theme`**).  
- **`resolveUnifiedDecoration(context, overrides: …, brightness: …)`** — merges theme + field overrides (used internally by several fields).  
- **`UnifiedFieldsContextX`** on **`BuildContext`**: **`unifiedFieldsScreenWidth`**, **`unifiedFieldsScreenHeight`**, **`unifiedFieldsUseDialogLayout`**, **`unifiedFieldsPrimaryColor`** (prefixed to avoid clashing with app extensions).  
- **`UnifiedSheetButton`** — compact primary / outlined actions used inside picker sheets.

---

## Global theme (`UnifiedInputThemeScope`)

Only **`child`** is required. Pass a **`UnifiedInputThemeData`** to set shared chrome for every unified field in that subtree (labels, values, placeholders, required icon, errors, suffix icons, picker sheets).

### App-wide (recommended)

Wrap **`runApp`** so settings screens and forms inherit the same rules:

```dart
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
        pickerHeaderStyle: UnifiedInputPickerHeaderStyle(
          padding: EdgeInsets.fromLTRB(16, 14, 8, 14),
          backgroundColor: Colors.white,
        ),
        multiPickerCheckboxStyle: UnifiedInputMultiPickerCheckboxStyle(
          borderRadius: 6,
          fillColor: Color(0xFF1565C0),
          checkColor: Colors.white,
        ),
      ),
      child: const MyApp(),
    ),
  );
}
```

The runnable **`example/`** app uses this pattern in `example/lib/main.dart`.

### Nested scope (one screen or card)

Inner scopes **merge** over ancestors — useful for a settings subsection or A/B styling:

```dart
UnifiedInputThemeScope(
  data: const UnifiedInputThemeData(
    requiredIconColor: Colors.orange,
    disabledFieldColor: Colors.grey,
    disabledFieldOpacity: 0.5,
  ),
  child: Column(
    children: [
      UnifiedFormTextField(
        label: 'Nickname',
        isRequired: true, // orange * from this scope
      ),
      UnifiedFormTextField(
        label: 'Archived',
        isDisabled: true,
        resetValue: () => 'Read-only',
      ),
    ],
  ),
)
```

### Common `UnifiedInputThemeData` fields

| Field | Effect |
|-------|--------|
| `brightnessOverride` / `paletteOverride` | Force light/dark or a full custom palette |
| `disabledLabelColor` / `disabledLabelOpacity` | Label when `isDisabled` / `disabled` |
| `disabledFieldColor` / `disabledFieldOpacity` | Input text when disabled |
| `disabledFieldBackgroundOpacity` | Field body fade when disabled |
| `lockedLabelColor` / `lockedLabelOpacity` | Label when `locked` |
| `lockedFieldColor` / `lockedFieldOpacity` | Input text when locked |
| `lockedFieldBackgroundOpacity` | Body fade when locked |
| `placeholderColor` / `placeholderOpacity` | Hint when enabled |
| `placeholderOpacityWhenDisabled` | Hint when disabled |
| `requiredIcon` / `requiredIconColor` / `requiredIconSize` | Required `*` marker |
| `validationColor` | Inline errors and error border |
| `clearButtonColor` | Clear (×) button |
| `suffixIconColor` / `suffixIconOpacity` | Lock, password, default picker suffixes |
| `loadingIndicatorColor` | Loading spinner on fields |
| `pickerSheetBackgroundColor` | Date/time/duration sheets (else `bottomSheetTheme` → palette) |
| `pickerHeaderStyle` | `UnifiedInputPickerHeaderStyle`: header `padding`, `backgroundColor`, `titleStyle`, `clearButtonColor` |
| `multiPickerCheckboxStyle` | `UnifiedInputMultiPickerCheckboxStyle`: `size`, `borderRadius`, `fillColor`, `checkColor`, `borderColor` |
| `fieldDecorationSet` | Default per-state layers (`focused`, `error`, `disabled`, …) for all fields in the scope |
| `fieldDefaults` | Default [UnifiedBaseTextField] layout/behavior: `labelMode`, `height`, `borderRadius`, `textStyle` / `textStylePersian`, `placeholderStyle`, per-mode `labelInRowStyle` / `labelInColumnStyle` / `floatingLabelStyle`, `selectTextOnFocus`, `showClearButton`, `autovalidateMode`, … |
| `defaultSuffixIcons` | Default suffix per field type (`date`, `time`, `duration`, `picker`, …) |

Field-level **`UnifiedInputDecoration`** / **`decorationSet`** / **`fieldDefaults`** and per-widget params still win for one-off overrides.

```dart
UnifiedInputThemeScope(
  data: UnifiedInputThemeData(
    fieldDefaults: const UnifiedInputFieldDefaults(
      labelMode: UnifiedFieldLabelMode.labelInColumn,
      height: 52,
      textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      textStylePersian: TextStyle(fontSize: 16, fontFamily: 'KookFaNum'),
      placeholderStyle: TextStyle(fontSize: 15, color: Colors.grey),
      labelInColumnStyle: UnifiedInputLabelModeStyle(
        labelPadding: EdgeInsets.only(bottom: 6, top: 4),
        labelStyle: TextStyle(fontWeight: FontWeight.w600),
      ),
      showClearButton: true,
    ),
    fieldDecorationSet: UnifiedInputDecorationSet(
      focused: UnifiedInputDecoration(
        borderSide: BorderSide(color: Colors.blue, width: 1.5),
      ),
    ),
  ),
  child: myForm,
)
```

Live demos: **`example/lib/main.dart`** (app + nested card) and **`UnifiedInputsShowcasePage`** (scoped block near the top of the gallery).

---

## Persian digits (`UnifiedFieldsTypography`)

Shamsi (Jalali) date pickers show **Persian numerals** (۰–۹) using the bundled **KookFaNum** font. Override at startup:

```dart
void main() {
  UnifiedFieldsTypography.instance = const UnifiedFieldsTypography(
    usePersianDigitsGlobally: true, // all unified text / number fields
    // persianFontFamily: 'YourAppNumFont', // optional
  );
  runApp(const MyApp());
}
```

By default only Shamsi UI uses Persian digits (`usePersianDigitsInShamsi: true`). Set `usePersianDigitsGlobally: true` to apply the font and digit mapping to every field (including `UnifiedBaseTextField`, numeric step fields, duration wheels, and **`UnifiedPhoneField`**).

On the phone field, set **`usePersianDigits: true`** or **`digitCalendarKind: UnifiedFieldsCalendarKind.jalali`** to localize dial codes and national digits (input accepts ۰–۹). Use **`UnifiedCountry.localizedDialCode`** / **`UnifiedPhoneNumber.localizedDisplay`** outside the field.

---

## Localization

- Set **`UnifiedFieldsStrings.instance`** for package-owned copy (pickers, date sheet, duration sheet, time picker hour/minute fallbacks, wheel headers including Shamsi سال/ماه/روز, duration column headers via **`durationColumnHeader`**).  
- **Time picker** OK/Cancel use **`MaterialLocalizations`** when available.  
- **Clear** tooltip on the base text field uses **`MaterialLocalizations.deleteButtonTooltip`** (platform).

---

## Try the built-in demo

**`UnifiedInputsShowcasePage`** is a long-form scroll demo with a brightness / palette toggle. Push it from debug menus or a settings screen:

```dart
Navigator.of(context).push(
  MaterialPageRoute<void>(
    builder: (_) => const UnifiedInputsShowcasePage(),
  ),
);
```

A runnable example app lives in **`example/`** — open it with `flutter run` from that folder. It wraps the app in **`UnifiedInputThemeScope`**, shows a nested-scope demo card on the home form, and opens **`UnifiedInputsShowcasePage`** from the app bar (includes a dedicated theme-scope section).

---

## Dependencies

| Package | Role |
|---------|------|
| **`flutter_svg`** | Country flag SVGs in `UnifiedFlag` / phone field |
| **`intl`** | Date/number formatting in date fields and picker |
| **`shamsi_date`** | Jalali calendar conversion |
| **`collection`** | Used by the **vendored** scrollable list implementation |

Async pickers show loading via the field **suffix spinner** (`loading` on **`UnifiedBaseTextField`**), not a full-field overlay.

### Vendored code

Under **`lib/src/scrollable_list/`** you’ll find a local copy of a **scrollable positioned list** implementation (same family as the popular package, kept in-tree so this package stays self-contained).

---

## Architecture sketch

```mermaid
flowchart TB
  subgraph form [Form]
    UFS[UnifiedFormFieldScope optional]
    UFT[UnifiedFormTextField]
    UFS2[UnifiedFormSinglePickerField]
    UFD[UnifiedFormDateField]
  end
  UFS --> UFT
  UFS --> UFS2
  UFS --> UFD
  form --> FF[FormState validate save reset]
```

---

## Version

Current release: **`0.2.5`** (see **`pubspec.yaml`** and [pub.dev](https://pub.dev/packages/unified_fields/versions) for the latest). Follow semver when upgrading.

### Upgrading to 0.2.5

* **`textStyle` / `textStylePersian`** — now apply to **`UnifiedPhoneField`**, **`UnifiedDateField`**, and **`UnifiedDateRangeField`** via `fieldDefaults` (no per-field hardcoded 14px on dates). Persian mode merges both styles; override one field with `style:` on the widget or `UnifiedInputDecoration.fieldStyle`.
* **`UnifiedDateRangeField`** — optional `initialCalendarKind` for Jalali digit font / Persian value style when displaying ranges.

### Upgrading to 0.2.4

* **`placeholderStyle`** — on `UnifiedInputDecoration`, `UnifiedBaseTextField`, or `UnifiedInputFieldDefaults`. Placeholders copy `fieldStyle` typography by default; set `placeholderStyle` only to differ (e.g. italic or lighter color).
* **Label chrome per mode** — `labelInRowStyle`, `labelInColumnStyle`, `floatingLabelStyle` on `UnifiedInputFieldDefaults` (`UnifiedInputLabelModeStyle` with `labelStyle` + `labelPadding`). Per-field: `UnifiedInputDecoration.labelPadding` / `UnifiedBaseTextField.labelPadding`.
* **`selectTextOnFocus`** — `true` on `UnifiedTextField`, `UnifiedNumberField`, form wrappers, or `fieldDefaults` so focusing selects the whole value for easy overwrite.

### Upgrading to 0.2.3

* **Picker sheets** — override sheet background and header per field with `pickerSheetBackgroundColor`, `pickerHeaderStyle` (e.g. `itemOrder`, `helpText`), or bundled `pickerSheetStyle`. Works on standalone pickers and `UnifiedForm*Picker*` wrappers without changing global theme.

### Upgrading to 0.2.2

* **Number fields** — optional `stepButtons`, `stepButtonPlacement`, `decrementIcon`, `incrementIcon`, and `textAlign`. Use `UnifiedInputDecoration` `prefix` / `prefixIcon` / `suffixIcon` alongside step buttons; set `suffixWidth` / `suffixHeight` only when you need a fixed suffix box (otherwise custom suffixes size intrinsically).

### Upgrading to 0.2.0

- **Theme field defaults** — set **`UnifiedInputThemeData.fieldDefaults`** (`labelMode`, `height`, borders, `showClearButton`, `autovalidateMode`, …). See [Global theme](#global-theme-unifiedinputthemescope).
- **`UnifiedBaseTextField`** — some params are nullable and inherit from theme; **`isValid(context)`** now needs a **`BuildContext`**.

### Upgrading to 0.1.9

- **Per-state decoration** — optional **`decorationSet`** on any field, or **`UnifiedInputThemeData.fieldDecorationSet`** in **`UnifiedInputThemeScope`**. Layers: `focused`, `error`, `valid`, `locked`, `disabled`, `loading`, `readOnly`, `base`. See [Per-state decoration](#per-state-decoration-decorationset).

### Upgrading to 0.1.8

- **Picker grid / custom list** — pass **`itemToWidget`**, **`gridItemBuilder`**, and **`gridDelegate`** on any picker field or **`UnifiedForm*Picker*`** wrapper; see [Pickers](#pickers). Helpers: **`unifiedPickerDefaultGridDelegate`**, **`showUnifiedSinglePickerSheet`**, **`showUnifiedMultiPickerSheet`**.
- **`CustomizableSinglePickerController.openPicker`** / **`CustomizableMultiPickerController.openPicker`** — call after the field is mounted, or **`bindPicker`** / **`bindAsyncPicker`** first.
- Customizable async/sync pickers: full-field tap opens the sheet when **`allowFreeText`** is true; use **`disabled`** or **`isDisabled`** to block interaction.

### Upgrading from 0.1.6 → 0.1.7

- **`UnifiedPhoneField`**, **`UnifiedCountry`** enum, **`UnifiedFlag`**, and **`UnifiedCountryWidget`** — see [Phone](#phone-unifiedphonefield). Replace any `UnifiedPhoneCountry(...)` constructor with enum values (e.g. `UnifiedCountry.ir`; India: `UnifiedCountry.countryIN`). `UnifiedPhoneCountries` → **`UnifiedCountries`**.
- **`UnifiedFieldLabelMode`** on fields; legacy decoration **`labelInRow: true`** still maps to row mode.

### Upgrading from earlier 0.1.x

- Wrap your app (or a screen) in **`UnifiedInputThemeScope`** for global disabled/placeholder/required/validation colors, picker sheet background, header padding, and multi-picker checkbox styling — see [Global theme](#global-theme-unifiedinputthemescope).  
- Replace **`context.isDesktop`** / **`context.width`** with **`context.unifiedFieldsUseDialogLayout`** / **`context.unifiedFieldsScreenWidth`** (old names are deprecated).  
- **Duration wheels** default to `UnifiedFieldsDurationPickerStyle.wheels`; use **`pickerColumns`** for year/month/week-style columns.  
- **`unifiedFormatDuration`** / **`unifiedTryParseDuration`** use **named** `granularity:` and optional `pickerColumns:` / `calendarKind:`.  
- **Shamsi dates / phone:** set **`initialCalendarKind: jalali`** or **`usePersianDigits`** on the phone field; optional **`UnifiedFieldsTypography`** for app-wide Persian digits (KookFaNum font).

---

## License

See the **`LICENSE`** file in this repository.
