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
