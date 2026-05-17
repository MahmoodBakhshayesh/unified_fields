## 0.3.0

* **Wheel date picker:** `UnifiedFieldsDatePickerStyle.wheels` on `UnifiedDateField`, `UnifiedFormDateField`, and `showUnifiedFieldsDatePicker` — Cupertino-style year / month / day columns (columns depend on `UnifiedFieldsDatePickerGranularity`). Gregorian and Shamsi toggle matches the calendar picker. New `UnifiedFieldsStrings` keys: `dayLabel`, `monthLabel`.
* **Wheel styling:** selection band (primary tint), top/bottom fade, column dividers, day-column background, magnifier zoom — tunable via `UnifiedFieldsDateWheelStyle` / `UnifiedFieldsDateWheelStyle.resolve`.

## 0.2.0

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
