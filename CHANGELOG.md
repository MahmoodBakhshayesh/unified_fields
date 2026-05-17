## 0.1.4

### Features and Fixes

* **Time wheel picker:** `UnifiedFieldsTimePickerStyle.wheels` on `UnifiedTimeOfDayField` / `UnifiedFormTimeOfDayField` with `UnifiedFieldsTimeGranularity` (`hours`, `hoursMinutes`, `hoursMinutesSeconds`); `showUnifiedFieldsTimePicker`; Shamsi digit toggle via `initialCalendarKind`.
* **Duration wheel picker:** `UnifiedFieldsDurationPickerStyle.wheels` (default) with extended `UnifiedDurationGranularity` (`hours`, `hoursMinutes`, `hoursMinutesSeconds`, legacy `minutesSeconds`); shared `UnifiedFieldsHmsWheelPickerSheet` chrome for simple H:M:S; `UnifiedFieldsDurationColumnWheelPickerSheet` for custom columns.
* **Custom duration columns:** `pickerColumns: [UnifiedFieldsDurationColumn.year, UnifiedFieldsDurationColumn.week, …]` builds wheels in that order (year / month / week / day / hour / minute / second); presets on `UnifiedFieldsDurationColumnPresets`; helpers `composeUnifiedDuration`, `decomposeUnifiedDuration`, `formatUnifiedDurationColumns`.
* **Persian digits:** bundled **KookFaNum** font and `UnifiedFieldsTypography` — Shamsi (Jalali) pickers show ۰–۹ by default; set `usePersianDigitsGlobally: true` for all unified fields.
* **Typography API:** `localizeDigits`, `mergeDigitStyle`, `toPersianDigits`, `fromPersianDigits`; optional `persianFontFamily`.
* **Duration / time form fields:** `UnifiedFormDurationField` gains `pickerColumns`, `pickerStyle`, `initialCalendarKind`, `showCalendarKindToggle`.
* **`UnifiedFieldsStrings.durationColumnHeader`:** localized column headers for duration wheels (Gregorian and Shamsi).
* **Duration calendar columns:** year / month / week wheels use fixed ranges (**0…999**, **0…11**, **0…4**) instead of shrinking to `0` when `max` is below one year.
* **Calendar mode:** Shamsi month title bar and jump-panel year field show Persian year numerals (not only wheel / day grid).
* **`initialCalendarKind: jalali`** now applies to **calendar** (grid) pickers, not only wheel mode (`UnifiedFieldsDatePickerSheet` was missing the parameter).
* **Jalali field display:** after pick (or when calendar kind is Jalali), the date field shows Shamsi text (e.g. `۱۳,مرداد ۱۴۰۳`) instead of Gregorian `DateFormat`; picker confirm syncs kind via `onConfirmedCalendarKind`.
* `unifiedFormatDuration` / `unifiedTryParseDuration` use **named** `granularity:` and optional `pickerColumns:` / `calendarKind:` (update call sites from positional `granularity`).
* `UnifiedNumericStepField.digitCalendarKind` — optional Shamsi digit context for numeric surfaces inside pickers.


* **Wheel date picker:** `UnifiedFieldsDatePickerStyle.wheels` on `UnifiedDateField`, `UnifiedFormDateField`, and `showUnifiedFieldsDatePicker` — scroll wheels (year · month · day) with Gregorian / Shamsi toggle; column set follows `UnifiedFieldsDatePickerGranularity`.
* **Wheel styling:** optional `UnifiedFieldsDateWheelStyle` (themed via `forPicker`); desktop mouse / trackpad drag via `ListWheelScrollView`.
* **Shamsi wheel copy:** column headers سال / ماه / روز and Farsi weekday names on day rows (`PersianJalaliCalendar.jalaliDayWheelLabel`).
* **Calendar today:** hollow circle outline (same shape as selection) instead of a rectangular border.
* **Wheel alignment:** centered labels in each column for Gregorian mode.
* **`showWeekdayInWheel`:** optional weekday names in the day wheel (`true` by default); fixed-width day + weekday layout via `wheelDayNumberWidth` / `wheelWeekdayWidth` on `UnifiedFieldsDateWheelStyle`.
* **Renamed** `AppInputController` → `UnifiedInputPicker`, `AppUnifiedFieldShell` → `UnifiedFieldShell` (deprecated typedefs).
* **Localization:** `UnifiedFieldsStrings.instance` for Cancel, Confirm, picker copy, and wheel headers.
* **Breaking:** Renamed `AppInputController` → [`UnifiedInputPicker`](lib/src/fields/unified_input_picker.dart) and `AppUnifiedFieldShell` → [`UnifiedFieldShell`](lib/src/fields/unified_field_shell.dart). Deprecated typedefs remain for one release.
* **Localization:** All package button/label strings (Cancel, Confirm, Clear, Done, Pick, Suggestion, date picker copy, time hour/minute labels, default duration title) live in [`UnifiedFieldsStrings`](lib/src/unified_fields_strings.dart). Set `UnifiedFieldsStrings.instance` before `runApp` to customize. `UnifiedDatePickerStrings` is deprecated and forwards to the same instance.

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
  `UnifiedFormCustomizableAsyncPickerField`, `UnifiedFormCustomizableAsyncMultiPickerField`.
* Added a runnable `example/` Flutter project demonstrating the showcase page.
* Renamed `AppColors` to `UnifiedColors` to match the package naming style.
* Dartdoc comments on every public member across the package
  (palette, decoration, controllers, base text field, sheet helpers,
  color tokens, all unified and form-aware fields, plus the vendored
  utility extensions). The `public_member_api_docs` lint is now enforced
  in `analysis_options.yaml` to keep coverage from regressing.

## 0.1.1

* Documentation pass on the public API and minor README polish.

## 0.1.0

* Initial release: unified text / number / picker / async picker / date / time / duration fields,
  Gregorian–Jalali calendar sheet, vendored scrollable positioned list, and `Form`-aware wrappers.
