## 0.1.9

### Features

* **Per-state field decoration** — optional [UnifiedInputDecorationSet] on every field (`decorationSet`) and globally via [UnifiedInputThemeData.fieldDecorationSet]. Layers: `base`, `focused`, `valid`, `error`, `locked`, `disabled`, `loading`, `readOnly`. Omitted layers keep current palette / single-[UnifiedInputDecoration] behavior. [UnifiedPhoneField] applies the same state resolution for borders and fills.

## 0.1.8

### Features

* **Picker grid layout** — optional `gridItemBuilder` on every list-based picker field and sheet. Pass a full [SliverGridDelegate] via `gridDelegate`, or use [unifiedPickerDefaultGridDelegate] for a fixed cross-axis count. Single-select tiles receive `(index, item, onSelect)`; multi-select adds `isSelected`.
* **Form pickers** — `itemToWidget`, `searchBuilder`, `gridItemBuilder`, and `gridDelegate` on all `UnifiedForm*Picker*` wrappers (`UnifiedFormSinglePickerField`, `UnifiedFormMultiPickerField`, async and customizable variants).
* **Standalone sheets** — [showUnifiedSinglePickerSheet] and [showUnifiedMultiPickerSheet] accept the same list/grid options.
* **`CustomizableSinglePickerController` / `CustomizableMultiPickerController`** — [openPicker] via attached field or `bindPicker` / `bindAsyncPicker` (same pattern as [UnifiedPickerFieldController]).
* **Exports** — [UnifiedPickerGridItemBuilder], [UnifiedPickerMultiGridItemBuilder], [unifiedPickerDefaultGridDelegate], [unifiedPickerResolveGridDelegate].

### Fixes

* **`UnifiedCustomizableAsyncPickerField`** (and sync customizable pickers) — sheet opens on full-field tap when `allowFreeText` is true, not only via the suffix icon.
* **Customizable picker fields** — `disabled` alongside `isDisabled`; `GestureDetector` + `interactionBlocked` for reliable tap-to-open.

## 0.1.7

### Features

* **`UnifiedPhoneField`** — phone input with SVG country flag, optional dial-code section, national mask, and validation. Editable country code uses one field (`+` + dial + national via [UnifiedPhoneFullNumberFormatter]); fixed or read-only dial code uses a label + national field.
* **`UnifiedPhoneField`** — Persian digit mode via `usePersianDigits` and `digitCalendarKind` (Jalali): parses Persian/Arabic-Indic input, localizes display (including partial dial prefixes), and applies KookFaNum when active.
* **`UnifiedCountry`** — enum of ~250 countries (ISO, name, dial code). Use `UnifiedCountry.ir`, `UnifiedCountries.byIso('DE')`, `UnifiedCountries.matchDialCode`, etc. Regenerate from `tool/countries.json` via `dart run tool/generate_unified_countries.dart`.
* **`UnifiedCountryWidget`** — public flag + optional name/dial row (`showName` defaults to `false`). [showUnifiedPhoneCountryPicker] for standalone country selection.
* **`UnifiedFlag`** — ISO or asset stem → bundled SVG; optional `size`, `width`, `height`, `borderRadius`; reads [UnifiedInputPhoneStyle] from theme.
* **`UnifiedInputPhoneStyle`** / **`UnifiedInputThemeData.phoneStyle`** — dial-code box chrome, flag dimensions, invalid dial-code display (`message` vs `highlightText`).
* **`UnifiedPhoneFieldController`** — `UnifiedPhoneNumber` value, national/dial controllers, `setCountry`, unified single-field entry mode.
* **`UnifiedFieldLabelMode`** — `labelInRow`, `labelInColumn`, and `floatingLabel` (default on [UnifiedBaseTextField]); set via `labelMode` on fields or [UnifiedInputDecoration]. Legacy `labelInRow: true` still maps to row mode.

### Breaking changes

* **`UnifiedPhoneCountry`** removed — use the [UnifiedCountry] enum (`UnifiedCountry.ir`, not `UnifiedPhoneCountry(isoCode: …)`). India: `UnifiedCountry.countryIN`.
* **`UnifiedPhoneCountries`** deprecated — use [UnifiedCountries]. `UnifiedCountryRow` renamed to [UnifiedCountryWidget].

### Fixes

* Placeholder / hint styling uses [UnifiedColors.hintColor] at **0.72** opacity by default.
* Placeholder no longer falls back to the label string on [UnifiedTextField] and [UnifiedNumberField].
* Phone layout: bounded row height, label modes on [UnifiedPhoneField], `height` / `width` support.
* Static analysis: `dart analyze` clean on `lib/` (including vendored `scrollable_list` dartdoc for pub.dev scoring).

## 0.1.6

### Features

* **`UnifiedInputThemeScope`** — global field chrome via `UnifiedInputThemeData`: disabled/locked label and field colors, placeholder, required icon, validation, suffix/clear/loading colors, picker sheet background, default suffix icons per field type.
* **`UnifiedInputPickerHeaderStyle`** — settable picker sheet header `padding`, `backgroundColor`, `titleStyle`, and `clearButtonColor` (shared `UnifiedPickerSheetHeader` for single and multi pickers).
* **`UnifiedInputMultiPickerCheckboxStyle`** — settable multi-picker checkbox `size`, `borderRadius`, `fillColor`, `checkColor`, and `borderColor`.
* **`UnifiedSuffixIconChrome`** — 32×32 aligned suffix slot so date/time/duration icons line up with picker dropdown and lock/clear affordances.
* **Custom duration columns** — `pickerColumns` with fixed wheel ranges (year `0…999`, month `0…11`, week `0…4`); presets on `UnifiedFieldsDurationColumnPresets`.
* **Time / duration wheel pickers**, **Persian digits** (KookFaNum), **Jalali** calendar and field display improvements (see 0.1.4–0.1.5 notes below).

### API

* **`UnifiedFieldsContextX`** — prefixed getters (`unifiedFieldsScreenWidth`, `unifiedFieldsUseDialogLayout`, …); legacy `width` / `isDesktop` deprecated.
* **`UnifiedFieldsDateWheelStyle.forPicker`** — named `overrides:` and optional `context:` for themed sheet background.
* **`unifiedFormatDuration`** / **`unifiedTryParseDuration`** — named `granularity:`, optional `pickerColumns:` / `calendarKind:`.

### Fixes

* Picker sheets use theme scope for background color instead of hard-coded values.
* Static-analysis cleanup (`dart analyze lib` clean).

## 0.1.5

### Features

* **`UnifiedInputThemeData`** — optional scope via `UnifiedInputThemeScope` (only `child` required): brightness/palette; disabled & locked label/field colors and opacities; placeholder; required icon; validation/suffix/loading colors; `pickerSheetBackgroundColor`; `UnifiedInputPickerHeaderStyle` (header padding and colors); `UnifiedInputMultiPickerCheckboxStyle` (radius and colors); `UnifiedInputDefaultSuffixIcons`.
* **`UnifiedInputThemeResolver`** — helpers used by [UnifiedBaseTextField] (`disabledLabelColor`, `disabledFieldColor`, `requiredIcon`, `placeholderStyle`, `validationColor`, etc.) plus picker sheet background and default suffix icons.
* Picker sheets and wheel chrome use scope sheet background when set; otherwise `Theme.bottomSheetTheme.backgroundColor` then palette `sheetBackground`.

### API

* **`UnifiedFieldsContextX`** getters renamed to avoid app extension clashes: `unifiedFieldsScreenWidth`, `unifiedFieldsScreenHeight`, `unifiedFieldsUseDialogLayout`, `unifiedFieldsPrimaryColor` (old names kept as `@Deprecated`).
* **`UnifiedFieldsDateWheelStyle.forPicker`** — optional `context:` for themed sheet background; positional `overrides` replaced with named `overrides:`.

### Fixes

* Static analysis: removed unnecessary imports, fixed `use_build_context_synchronously` in async pickers, `use_key_in_widget_constructors` on `UnifiedDurationPickerSheet`.
* Duration calendar columns: year `0…999`, month `0…11`, week `0…4` on wheels (not squeezed by small `max`).

## 0.1.4

### Features and fixes

* Time/duration wheel pickers, custom duration columns, Persian digits (KookFaNum), Jalali calendar/display fixes, and related APIs (see git history for full 0.1.4 scope).

## 0.1.3

* **Field states on `UnifiedBaseTextField`:** `loading` shows a suffix spinner (no full-field overlay or muted disabled chrome); `interactionBlocked` blocks taps/focus without looking disabled (date, async pickers). `isDisabled` / `disabled` show placeholder and value together when both are set.
* **`labelInRow`:** one outer rounded border around label + body with a straight vertical divider (no inner radius on the body side).
* **Field controllers:** `UnifiedPickerFieldController`, `UnifiedMultiPickerFieldController`, async/date/time/duration/number variants, and `UnifiedFormController` for imperative `openPicker` / `requestFocus` that match tapping the bound field when mounted (`attachUnifiedFieldHandles` in `field_controller_sync.dart`).
* **Form + binding sync:** `UnifiedForm…` picker/date/time/async fields listen to `binding` so `binding.clear()` updates the `FormField` UI; `syncFormFieldFromExternalValue` helpers for external writes.
* **Date field:** uses `interactionBlocked` instead of `disabled: true` so the picker opens without disabled styling.
* **Async pickers:** removed full-field loading overlay; loading uses the base field suffix spinner.
* **Dartdoc:** documented remaining public controller APIs and `UnifiedDurationPickerSheet` fields; `public_member_api_docs` is clean for `lib/`.

## 0.1.2

* Hoisted `isRequired` and `placeholder` to the root constructor of every field.
  Decoration values (`UnifiedInputDecoration.requiredField` / `UnifiedInputDecoration.placeholder`)
  are still honored as a fallback for backwards compatibility, but field-level parameters now win.
* Added `Form`-aware wrappers for the customizable pickers:
  `UnifiedFormCustomizablePickerField`, `UnifiedFormCustomizableMultiPickerField`,
  `UnifiedFormCustomizableAsyncPickerField`.
* Added **`example/`** — runnable Flutter app demonstrating form validate/save/reset and theme scope.
* Expanded dartdoc on public APIs; `public_member_api_docs` enabled for `lib/`.

## 0.1.1

* Initial pub.dev release scaffolding.

## 0.1.0

* Initial release.
