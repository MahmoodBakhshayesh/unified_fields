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
8. [Pickers](#pickers)  
9. [Bindings with `AppInputController`](#bindings-with-appinputcontroller)  
10. [Theming & layout](#theming--layout)  
11. [Localization](#localization)  
12. [Try the built-in demo](#try-the-built-in-demo)  
13. [Dependencies](#dependencies)  

---

## Add to your app

Published on **[pub.dev/packages/unified_fields](https://pub.dev/packages/unified_fields)**. In **`pubspec.yaml`**:

```yaml
dependencies:
  unified_fields: ^0.1.1
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
| **Plain fields** | `UnifiedTextField`, `UnifiedNumberField`, `UnifiedNumericStepField`, `UnifiedDurationField`, `UnifiedDateField`, `UnifiedDateRangeField`, `UnifiedTimeOfDayField` | Same visual system as form fields, without `FormField` |
| **Pickers** | `UnifiedSinglePickerField`, `UnifiedMultiPickerField`, `UnifiedAsyncPickerField`, `UnifiedAsyncMultiPickerField` | Bottom-sheet selection; async variants load items on demand |
| **Customizable pickers** | `UnifiedCutomizablePickerField`, `UnifiedCustomizableAsyncPickerField`, `CustomizableSinglePickerController` | Controller-driven single selection with custom sheet content |
| **Form wrappers** | `UnifiedFormField`, `UnifiedFormTextField`, `UnifiedFormSinglePickerField`, `UnifiedFormMultiPickerField`, `UnifiedFormAsyncPickerField`, `UnifiedFormAsyncMultiPickerField`, `UnifiedFormDateField`, `UnifiedFormDateRangeField`, `UnifiedFormTimeOfDayField`, `UnifiedFormDurationField`, `UnifiedFormNumberField` | `Form` integration: `validate`, `save`, `reset`, validators |
| **Form scope** | `UnifiedFormFieldScope` | Shared `AutovalidateMode` for all unified form descendants |
| **Calendar** | `showUnifiedFieldsDatePicker`, `showUnifiedFieldsDatePickerRange`, `UnifiedFieldsDatePickerSheet`, `UnifiedFieldsDatePickerGranularity`, `UnifiedFieldsCalendarKind` | Single date or range; day / month / year granularity; Gregorian vs Jalali toggle |
| **Time** | `TimePickerUtils.show` | Wraps `showTimePicker` with sensible defaults |
| **Chrome helpers** | `UnifiedBaseTextField`, `AppUnifiedFieldShell`, `UnifiedInputDecoration`, `UnifiedInputBrightness`, `UnifiedInputPalette`, `UnifiedInputTheme`, `UnifiedInputThemeScope` | Labels, errors, light/dark palettes, optional global theme scope |
| **Utilities** | `AppInputController`, `UnifiedFieldsContextX`, `AppColors`, `UnifiedSheetButton`, `unifiedFormErrorText`, `unifiedFormPickerOverride` | State binding, layout helpers, default colors, sheet actions |
| **Demo** | `UnifiedInputsShowcasePage` | Scrollable gallery of widgets + palette toggle |

---

## Core concepts

### One visual language

Fields share **`UnifiedInputDecoration`** (label, placeholder, radii, validation colors, prefix/suffix) and **`UnifiedInputBrightness`** (light / dark palette). Use **`UnifiedInputThemeScope`** to push a palette or brightness subtree without threading parameters everywhere.

### Two usage modes

1. **Standalone** — e.g. `UnifiedTextField`, `UnifiedSinglePickerField`: drop into any screen; you own validation if needed.  
2. **Under a `Form`** — use `UnifiedForm…` variants so **`GlobalKey<FormState>`** can call **`validate()`**, **`save()`**, and **`reset()`** on the whole form.

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

Presentation: **bottom sheet** on smaller widths; **centered dialog** when **`context.isDesktop`** is true (see **`UnifiedFieldsContextX`** — width ≥ 900).

### Granularity (`UnifiedFieldsDatePickerGranularity`)

- **`day`** — full month grid (default).  
- **`month`** — pick first day of month in range.  
- **`year`** — pick first day of year in range.  

### Calendars (`UnifiedFieldsCalendarKind`)

Users can switch **Gregorian** vs **Jalali (Shamsi)** when **`showCalendarKindToggle`** is true. Jalali math uses the **`shamsi_date`** package.

### Widgets

- **`UnifiedDateField`** / **`UnifiedFormDateField`** — text field + tap to open picker.  
- **`UnifiedDateRangeField`** / **`UnifiedFormDateRangeField`** — range in one field.

---

## Time

- **`UnifiedTimeOfDayField`** / **`UnifiedFormTimeOfDayField`** — display + edit time with your chrome.  
- **`TimePickerUtils.show(context, …)`** — thin wrapper around **`showTimePicker`** using **`MaterialLocalizations`** for OK/cancel and English **Hour** / **Minute** labels (override in your fork if needed).

---

## Pickers

| Widget | Data |
|--------|------|
| **`UnifiedSinglePickerField<T>`** | `T?` selection, searchable list, suggestions |
| **`UnifiedMultiPickerField<T>`** | `List<T>`, checkboxes in sheet |
| **`UnifiedAsyncPickerField<T>`** | Items from `Future<List<T>> Function()` |
| **`UnifiedAsyncMultiPickerField<T>`** | Same, multi-select |

**`PickerSheetWidget`** / **`MultiPickerSheetWidget`** are the sheet implementations (scrollable list + search). Form variants mirror the same behavior with **`FormField`**.

**Customizable** APIs (`unified_cutomizable_picker_fields.dart` — filename keeps the historical typo **cutomizable**): single selection with **`CustomizableSinglePickerController`** and async sibling for remote data.

---

## Bindings with `AppInputController`

**`AppInputController<T>`** is a **`ChangeNotifier`** holding **`value`**, optional **`errorText`**, and helpers **`clear`**, **`setError`**, **`silentSetValue`**. Pass it as **`binding:`** on fields so UI and domain state stay in sync; form wrappers also write back on save/reset when configured.

---

## Theming & layout

- **`AppColors`** — default static palette used by built-in styles (replace over time with your design tokens or override via **`UnifiedInputDecoration`** / **`Theme`**).  
- **`resolveUnifiedDecoration(context, overrides: …, brightness: …)`** — merges theme + field overrides (used internally by several fields).  
- **`UnifiedFieldsContextX`** on **`BuildContext`**: **`width`**, **`height`**, **`isDesktop`**, **`mainColor`** — no dependency on routing or app-specific l10n.  
- **`UnifiedSheetButton`** — compact primary / outlined actions used inside picker sheets.

---

## Localization

- **Date picker UI strings** live in **`UnifiedDatePickerStrings`** (`unified_date_picker_sheet.dart`). Defaults are **English**; copy or subclass and wire your own strings for production i18n.  
- **Time picker** uses **`MaterialLocalizations`** where possible; hour/minute labels are English literals in **`TimePickerUtils`**.  
- **Clear** tooltip on the base text field uses **`MaterialLocalizations.deleteButtonTooltip`**.

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

---

## Dependencies

| Package | Role |
|---------|------|
| **`intl`** | Date/number formatting in date fields and picker |
| **`shamsi_date`** | Jalali calendar conversion |
| **`collection`** | Used by the **vendored** scrollable list implementation |

Loading indicators in async pickers use **`CircularProgressIndicator`** (no `flutter_spinkit`).

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

Current release: **`0.1.0`** (see **`pubspec.yaml`** and [pub.dev](https://pub.dev/packages/unified_fields/versions) for the latest). Follow semver when upgrading.

---

## License

See the **`LICENSE`** file in this repository.
