## 0.2.7

### Features

* **`UnifiedFieldsDateFormatStyle` / `UnifiedFieldsDurationFormatStyle`** — theme defaults on [UnifiedInputThemeData] (`dateFormatStyle`, `durationFormatStyle`) for Gregorian and Shamsi field display; override per [UnifiedDateField], [UnifiedDateRangeField], [UnifiedDurationField], form wrappers, and controllers. Presets: `UnifiedFieldsDateFormatStyle.standard`, `isoGregorianDay`. Legacy `valueFormat: DateFormat(…)` still wins for dates when set. Resolvers: [UnifiedInputThemeResolver.dateFormatStyle] / `durationFormatStyle`.

### Fixes

* **Typed form validators** — `unifiedFormClearErrorIfValid`, `syncUnifiedFieldValue`, `syncFormFieldFromExternalValue`, and `syncWidgetFormValidatorToFieldController` preserve `T` / `T?` / `List<T>` through form fields and controllers. `FormFieldValidator<List<T>>` (e.g. `notEmptyList<CoffeeFlavor>`) and nullable pickers no longer throw runtime subtype errors when the value changes. Public typedef: [UnifiedFieldValueValidator].
* **Form vs controller validation** — [UnifiedFormDateRangeField], [UnifiedFormTimeOfDayField], [UnifiedFormDurationField], and [UnifiedFormNumberField] sync `validator:` onto `fieldController`. Non-form date/time/duration/number fields map display-string validators onto typed controllers (`syncDisplayStringValidatorToFieldController`, `syncNumberDisplayValidatorToFieldController`). Form pickers skip string-validator sync when `validationOverrideMessage` is set.

### Docs

* README: **Upgrading to 0.2.7** (format styles, validation). Example README updated.

## 0.2.6

### Features

* **`UnifiedInputDatePickerStyle`** — theme and per-field styling for date picker sheets: sheet background, title/header, weekday row, day grid (normal, selected, today, disabled, in-range), month jump grid, year list, Gregorian/Shamsi toggle, confirm/cancel buttons, `cellHeight`, `dayCircleSize`, and nested **`wheelStyle`**. Set on [UnifiedInputThemeData.datePickerStyle] or `datePickerStyle` on [UnifiedDateField], [UnifiedDateRangeField], [UnifiedFormDateField], [UnifiedDateFieldController], and [showUnifiedFieldsDatePicker] / [showUnifiedFieldsDatePickerRange].
* **`UnifiedInputDatePickerStyle.shamsiTextStyle`** — optional [TextStyle] merged into picker labels when the active calendar is Shamsi (Jalali), via `calendarTextStyle` (same role as `textStylePersian` for field text).
* **`UnifiedInputDatePickerStyle.yearStripStyle`** — [UnifiedFieldsDateYearStripStyle]: horizontal year strip `fadeColor`, `showFade`, `fadeExtent`, `magnification`, chip sizing (defaults align with `wheelStyle` when omitted).
* **`CustomWheelPicker`** — multi-column wheel field with `columns` / `value` maps keyed by index (`{0: List<…>, 1: List<…>}` → `{0: v0, 1: v1}`). [CustomWheelPickerColumn.typed] per column type, [CustomWheelPickerWheelLayout.vertical] (side-by-side vertical wheels) or `.horizontal`, [UnifiedFieldsDateWheelStyle] chrome, `showCustomWheelPicker` sheet API.
* **`UnifiedPickerSheetModalSettings`** — theme and per-field `showModalBottomSheet` flags: `isScrollControlled`, `isDismissible`, `enableDrag`, `useSafeArea`, `showDragHandle`. Set on [UnifiedInputThemeData.pickerSheetModalSettings], [UnifiedPickerSheetStyle.modalSettings], or `pickerSheetModalSettings` on picker fields. [showUnifiedFieldsPickerBottomSheet] applies resolved flags.
* **`UnifiedBasePickerSheetStyle`** — shared sheet chrome: `sheetBackgroundColor`, `sheetBorderRadius`, `contentPadding`, `footerPadding`, `panelPadding`, `panelBackgroundColor`, `panelBorderRadius`, and panel border. Set on [UnifiedInputThemeData.basePickerSheetStyle] or [UnifiedPickerSheetStyle.basePickerSheetStyle]; list pickers, [CustomWheelPicker], and wheel sheets resolve it before field overrides.
* **Picker list helpers** — `unifiedPickerItemLabel`, `unifiedPickerDefaultItemWidget`, and `unifiedPickerResolveListItem` in `unified_picker_item_builders.dart`. Picker sheets default list rows use `valueToString` (not raw `toString()`). Field display text and controllers use the same helpers. Exported from the package barrel.

### Breaking

* **Picker header `helpText` → `helpWidget`** — [UnifiedInputPickerHeaderStyle] and [UnifiedPickerSheetHeader] use `helpWidget` ([Widget]) instead of `helpText` ([String]). [helpTextStyle] still applies via [DefaultTextStyle.merge].

### Fixes

* **Month / year picker year control** — jump panel and month-granularity views use a horizontally scrollable year strip (mouse drag + wheel, optional center magnification and edge fade via `yearStripStyle` / `wheelStyle` fallbacks) instead of a numeric step field or dropdown.
* **`textStyle` on [UnifiedNumberField] / [UnifiedNumericStepField]** — removed hardcoded `UnifiedColors.textColorDark` fallback so [UnifiedInputFieldDefaults.textStyle] applies (e.g. Quantity in the example). Optional per-field `style` on [UnifiedNumberField].
* **[CustomWheelPicker]** — horizontal layout with few options no longer shows empty phantom cells (centered row when content fits; selection overlay removed for horizontal). Vertical wheels respond to mouse wheel. Sheet uses [UnifiedPickerSheetHeader] and [UnifiedBasePickerSheetStyle] (including `pickerSheetStyle` on the field).
* **`sheetBorderRadius`** — [CustomWheelPicker] sheet content is clipped to the resolved radius; safe-area inset is applied inside the clip so `sheetBackgroundColor` no longer paints square corners under the home indicator. [UnifiedPickerSheetHeader] uses the same top corners from `sheetBorderRadius`.

### Docs

* README: date picker styling, `UnifiedBasePickerSheetStyle`, `UnifiedPickerSheetModalSettings`, `CustomWheelPicker`, picker list helpers, `helpWidget`, and **Upgrading to 0.2.6**. Example README updated for 0.2.6 demos.

## 0.2.5

### Fixes

* **`textStyle` on [UnifiedPhoneField]** — respects [UnifiedInputFieldDefaults.textStyle] / `textStylePersian` from theme (placeholders and dial code included). Persian mode merges `textStyle` with `textStylePersian` instead of using only the Persian style. Optional per-field `style` override.
* **`textStyle` on [UnifiedDateField] / [UnifiedDateRangeField]** — no longer hardcodes `TextStyle(fontSize: 14)`; defers to theme via [UnifiedBaseTextField] and [UnifiedInputThemeResolver.fieldTextStyle]. [UnifiedDateField] passes `digitCalendarKind` for Jalali / Persian digit styling. Optional per-field `style`; [UnifiedDateRangeField] adds `initialCalendarKind` for digit/Persian resolution.

### Features

* **`style`** on [UnifiedPhoneField], [UnifiedDateField], and [UnifiedDateRangeField] — same precedence as [UnifiedBaseTextField.style] (wins over theme `textStyle` when set).

## 0.2.4

### Features

* **`textStyle` / `textStylePersian`** on [UnifiedInputFieldDefaults] — default value [TextStyle] for field text; Persian variant used when Persian digits are active (`usePersianDigitsGlobally`, Jalali calendar, or field-level `usePersianDigits`). Resolved via [UnifiedInputThemeResolver.fieldTextStyle]; decoration / widget `style` still win.
* **`placeholderStyle`** — optional [TextStyle] on [UnifiedInputDecoration], [UnifiedInputFieldDefaults], and [UnifiedBaseTextField]. Placeholders inherit `fontFamily`, `fontSize`, and other typography from `fieldStyle` / `style` by default, with theme hint color/opacity; explicit `placeholderStyle` overrides win.
* **Per–label-mode chrome** — [UnifiedInputLabelModeStyle] on [UnifiedInputFieldDefaults] (`labelInRowStyle`, `labelInColumnStyle`, `floatingLabelStyle`) for `labelStyle` and `labelPadding` per [UnifiedFieldLabelMode]. Field-level `UnifiedInputDecoration.labelPadding` / [UnifiedBaseTextField.labelPadding] override theme.
* **`selectTextOnFocus`** — on text and number fields (including form wrappers): when enabled, focusing a non-empty editable field selects all text so the next keystroke replaces the value. Set per widget or via [UnifiedInputFieldDefaults].

## 0.2.3

### Features

* **Local picker sheet chrome** — every picker field (single/multi, sync/async, customizable) and matching `UnifiedForm*Picker*` wrappers accept optional `pickerSheetStyle`, `pickerSheetBackgroundColor`, and `pickerHeaderStyle` (including `itemOrder`). Direct params win over `pickerSheetStyle`, which wins over [UnifiedInputThemeData].

## 0.2.2

### Features

* **[UnifiedNumberField] / [UnifiedFormNumberField] / [UnifiedNumericStepField]** — configurable step buttons: [UnifiedNumericStepButtons] (`both`, `incrementOnly`, `decrementOnly`, `none`), [UnifiedNumericStepButtonPlacement] (`split`, `leading`, `trailing`), and custom `decrementIcon` / `incrementIcon`. Decoration `prefix`, `prefixIcon`, and `suffixIcon` compose with buttons (prefix at natural width, then buttons; trailing buttons before suffix).
* **`textAlign`** on number fields (default `TextAlign.center`).
* **[UnifiedInputDecoration]** — optional `suffixWidth` / `suffixHeight` to force a suffix slot size.
* **Picker sheet header** — [UnifiedPickerHeaderItem] + `itemOrder` list on [UnifiedInputPickerHeaderStyle] / [UnifiedPickerSheetHeader]: lay out title (expanded), help, close, and clear in any order; unavailable slots are skipped. Defaults to title → help → close → clear. Also `helpWidget`, custom `closeButton` / `clearButton`, and `titleWidget`. (**Breaking:** picker header/theme `helpText` removed — use `helpWidget` instead.)

### Fixes

* **Adornment sizing** — [UnifiedSuffixIconChrome] uses intrinsic width/height for custom `suffixIcon` / `prefix` widgets; fixed 32×32 only for [Icon]s / [IconButton]s or when `suffixWidth` / `suffixHeight` are set. Avoids clipping text or wide trailing labels.
* **Live validation on edit** — user edits only clear errors when the value becomes valid (no re-`validate()` while still invalid), fixing focus loss on [UnifiedFormTextField] and delete-and-retype. [unifiedFormClearErrorIfValid] on form pickers, dates, time, duration, and multi-select after a selection.

## 0.2.1

### Fixes

* **Widget vs controller validator** — fields sync `validator:` on the widget onto `fieldController` so [UnifiedFieldValidation.validateFields] matches [FormState.validate] / inline errors ([UnifiedTextField], [UnifiedFormTextField], [UnifiedSinglePickerField], [UnifiedMultiPickerField], and form picker wrappers).
* **[UnifiedFormSinglePickerField]** — rebuilds when `fieldController.errorText` changes only (imperative validate).
* **Live error updates** — after a failed validate, editing the value re-runs validation on [BaseUnifiedFieldController] and `UnifiedForm*` fields (error clears when fixed, without tapping validate again).

## 0.2.0

### Features

* **`UnifiedInputFieldDefaults`** — set [UnifiedBaseTextField] layout and behavior on [UnifiedInputThemeData.fieldDefaults]: `labelMode`, `rowLabelRatio`, `height`, `borderRadius`, `borderSide`, `showError`, `showClearButton`, `resetTextWhenLocked`, `autovalidateMode`, `contentPadding`, `mustResolveTextDirectionByInput`, and related colors. Merged into [resolveUnifiedDecoration] before field overrides. Field-level params still win; `null` on [UnifiedBaseTextField] defers to theme.

### Breaking changes

* **[UnifiedBaseTextField]** — several constructor params are now nullable and defer to theme / palette when omitted (`backgroundColor`, `borderRadius`, `borderSide`, `height`, `labelInRow`, `showError`, `showClearButton`, `resetTextWhenLocked`, `mustResolveTextDirectionByInput`). [UnifiedBaseTextFieldState.isValid] now requires a [BuildContext] argument.

### Fixes

* **Customizable picker fields** — when `allowFreeText` is true (default), tapping the field focuses the text input for typing; the picker opens only via the suffix icon. Tap-to-open on the whole field applies when `allowFreeText` is false.
* **`fieldDefaults`** — `borderRadius`, `labelMode` / label-in-row layout, and other chrome now apply on [UnifiedTextField], [UnifiedFormTextField], and fields using [UnifiedBaseTextField] (including when `decorationSet` is set). Removed hardcoded `18` radius / `Colors.black26` overrides on wrappers that blocked theme values.
* **Controller validation UI** — [UnifiedTextField] rebuilds when [UnifiedTextFieldController] error changes (`ListenableBuilder`). Label-in-row layout shows the error message below the field. [UnifiedFieldValidation.validateFields] documented: requires `fieldController:` on the field.
* **[UnifiedFormTextField]** — listening to [UnifiedTextFieldController] now rebuilds when only `errorText` changes (not only value). [shakeOnError] works with [UnifiedFieldValidation.validateFields]. If both `controller` and `fieldController` are passed, wire the same [TextEditingController] via [UnifiedTextFieldController.textController].

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
