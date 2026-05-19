# unified_fields_example

A small Flutter app that exercises every notable widget from
[`unified_fields`](../README.md):

- **App-wide `UnifiedInputThemeScope`** in `lib/main.dart` (required icon, validation, disabled chrome, picker suffix icons, sheet background, picker header `helpWidget`, `datePickerStyle`)
- **Nested theme scope** demo card on the home form (overrides required icon color inside one subtree)
- Plain fields (`UnifiedTextField`, `UnifiedNumberField`, …)
- Date pickers: calendar grid and scroll wheels, Gregorian / Shamsi
- Time and duration wheel pickers with optional Jalali digits
- Custom duration columns (e.g. year · week · day · hour)
- `UnifiedFormFieldScope` + every `UnifiedForm*` wrapper, including customizable picker form wrappers
- The bundled `UnifiedInputsShowcasePage` from the AppBar (includes a **UnifiedInputThemeScope** section at the top of the gallery)

## Run

```bash
cd example
flutter pub get
flutter run
```

The app uses `path: ../` to depend on the package source in this repository
so any edit in `lib/` is picked up on hot reload.

## Theme scope quick reference

```dart
// example/lib/main.dart — wrap the whole app
runApp(
  UnifiedInputThemeScope(
    data: const UnifiedInputThemeData(
      requiredIconColor: Color(0xFF1565C0),
      validationColor: Color(0xFFD32F2F),
      defaultSuffixIcons: UnifiedInputDefaultSuffixIcons(
        date: Icons.calendar_month_outlined,
      ),
      pickerHeaderStyle: UnifiedInputPickerHeaderStyle(
        itemOrder: [
          UnifiedPickerHeaderItem.title,
          UnifiedPickerHeaderItem.help,
          UnifiedPickerHeaderItem.clear,
          UnifiedPickerHeaderItem.close,
        ],
        helpWidget: Text('Pick one option'),
      ),
      datePickerStyle: UnifiedInputDatePickerStyle(
        daySelectedBackgroundColor: Color(0xFF1565C0),
      ),
    ),
    child: const MyApp(),
  ),
);

// Nested override on one screen section
UnifiedInputThemeScope(
  data: const UnifiedInputThemeData(requiredIconColor: Colors.orange),
  child: myFormSection,
)
```

See the root [README](../README.md#global-theme-unifiedinputthemescope) for the full option list.

## 0.2.5 field defaults (in `main.dart`)

The app-wide `fieldDefaults` demonstrate:

- **`textStyle` / `textStylePersian`** — shared value typography on text, number, **phone**, and **date** fields
- **`placeholderStyle`** — theme-wide hint typography
- **`labelInRowStyle` / `labelInColumnStyle`** — per–label-mode `labelStyle` and `labelPadding`
- **`selectTextOnFocus: true`** — tap the **Quantity** `UnifiedNumberField` (starts at `42`); the value is selected so typing replaces it

```dart
fieldDefaults: const UnifiedInputFieldDefaults(
  textStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
  textStylePersian: TextStyle(
    fontSize: 15,
    fontFamily: UnifiedFieldsTypography.kUnifiedFieldsDefaultPersianFontFamily,
  ),
  placeholderStyle: TextStyle(fontSize: 14),
  labelInRowStyle: UnifiedInputLabelModeStyle(
    labelPadding: EdgeInsets.symmetric(horizontal: 10),
    labelStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
  ),
  selectTextOnFocus: true,
),
```

Check **Phone** (`usePersianDigits: true`) and **Date** fields — they use the same theme `textStyle` as **Full name**.

## 1.0.0 highlights

- **Stable release** — depend on `unified_fields: ^1.0.0` (pubspec `1.0.0+1`)
- **Bug fixes** — Persian digits on `UnifiedNumberField` with `usePersianDigitsGlobally`; date/range/duration `initState` + theme format styles; customizable form pickers clear errors when input becomes valid

## 0.2.8 highlights

- **Patch** — `UnifiedDateField`, `UnifiedDateRangeField`, and `UnifiedDurationField` no longer read theme during `initState` (fixes crash with `UnifiedInputTheme` + `dateFormatStyle` / `durationFormatStyle`)

## 0.2.7 highlights

- **`dateFormatStyle` / `durationFormatStyle`** — theme-level Gregorian and Shamsi display patterns; see root README [Field display format](../README.md#field-display-format-027)
- **Form validators** — `FormFieldValidator<List<T>>` on multi-pickers and typed pickers align with `fieldController` + `UnifiedFieldValidation.validateFields`

## 0.2.6 highlights (in `main.dart`)

- **`pickerHeaderStyle.helpWidget`** — header help slot is a `Widget` (not `helpText` string); `helpTextStyle` from theme still applies
- **`datePickerStyle`** — optional app-wide date sheet chrome (see root README [Date picker styling](../README.md#date-picker-styling-unifiedinputdatepickerstyle))
- **`CustomWheelPicker`** — multi-column configuration demo with `pickerSheetStyle.basePickerSheetStyle` (sheet/panel colors and radii) and horizontal wheel layout
- **`UnifiedBasePickerSheetStyle`** / **`UnifiedPickerSheetModalSettings`** — theme or per-field sheet chrome and modal flags (`isDismissible`, `isScrollControlled`, …); see root README [Picker sheet chrome](../README.md#picker-sheet-chrome-026)
- **Pickers** — pass `valueToString` on picker fields; list rows use package helpers when `itemToWidget` is omitted

## Package version

This example tracks the parent package (**currently 1.0.0**). See the root
[`CHANGELOG.md`](../CHANGELOG.md) for release notes.

## Publish checklist (package maintainers)

From the repository root:

```bash
flutter pub get
dart analyze lib
dart pub publish --dry-run
dart pub publish   # when ready
```

Ensure `CHANGELOG.md` and `pubspec.yaml` version match (**1.0.0+1**).
