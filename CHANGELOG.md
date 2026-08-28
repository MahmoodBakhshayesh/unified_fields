## 1.0.4+8

### Fixes

* **Picker search scroll gap** — filtering a single-select picker no longer leaves a blank band above the first match. Search rebuilds the list from the top (and jumps to index 0); scroll-to-selected only runs when the query is empty. Also fixes `_scrollToTop` incorrectly scheduling `_scrollToSelected` when the list was not yet attached.

### Features

* **`pickerSearchInputFormatters`** — optional theme / sheet formatters for picker search fields (single, multi, and async query sheets). Default is **no** formatters; each app opts in via [UnifiedInputThemeData] or per-sheet `searchInputFormatters` if it needs limits (e.g. English-only).

## 1.0.4+7

### Fixes

* **Orphan `FocusNode` crash** — pick-only fields, picker sheets and `UnifiedPickerFieldController` no longer park focus on a throwaway `FocusScope.of(context).requestFocus(FocusNode())` before opening a sheet. That node stayed attached to the scope without an element, so it held primary focus with a null context: traversal that sorts by `FocusNode.rect` asserted with *"Tried to get the bounds of a focus node that didn't have its context set yet"*, and until then Tab and every other shortcut was silently dropped. All sites now call the shared `unifiedUnfocusBeforeModal()`.

### Improvements

* **Keyboard reachable pickers** — single / multi / async / customizable pickers, date, time, duration and wheel fields keep a stable `FocusNode`, render focused chrome, and open their sheet on Space / Enter (focus alone never opens it). Focus returns to the field after the sheet closes.
* **Picker sheet navigation** — the sheet takes focus on open (the search field only when `searchAutoFocus` is set, so phones keep their soft keyboard closed), ArrowUp / ArrowDown move the highlight, Enter picks the highlighted row, typing starts a search, and Escape still dismisses.
* **Number arrow step** — ArrowUp / ArrowDown on a focused numeric field step by `step` within `min` / `max` and `fractionDigits`; arrows with Ctrl / Cmd / Alt / Shift are left to text editing.

## 1.0.4+5

### Fixes

* **Date picker dismiss** — closing/cancelling [UnifiedDateField]'s picker no longer clears the current value (only Confirm applies a change).

## 1.0.4+3

### Fixes

* **Picker / read-only `height`** — state chrome layers (`readOnly`, `focused`, `error`, …) no longer override layout props from the field decoration. Picker fields are permanently `readOnly`, so a theme `fieldDecorationSet.readOnly` with a `height` used to ignore per-field `UnifiedInputDecoration.height`.
* **`UnifiedInputDecorationSet.merge`** — layers are deep-merged via [UnifiedInputDecoration.merge] instead of replacing the whole layer, so partial overlays keep `height` / ratios from beneath.

## 1.0.3+2

### Fixes

* **`resolveUnifiedFieldLabelMode`** — field-level `labelInRow: true` now wins over a theme `labelMode` of column/floating, so `rowLabelRatio` applies in apps whose theme is not row-first.

## 1.0.3+1

### Features

* **Styled date & time pickers** — creative picker UIs from the app brick are now available in `unified_fields`:
  - Date: `monthGrid`, `dateStrip`, `verticalMonths`, `cascadeChips`, `heroCalendar` on [UnifiedFieldsDatePickerStyle] (legacy `calendar` / `wheels` unchanged with Jalali support).
  - Time: `rulerTape`, `arcSlider`, `digitPad`, `timelineRail`, `clockDial` on [UnifiedFieldsTimePickerStyle] (legacy `dial` / `wheels` unchanged).
* **[UnifiedFieldsPickerTheme]** — shared styling for styled pickers (colors, radii, action labels); resolves from [UnifiedInputDatePickerStyle] + [ThemeData] via [UnifiedFieldsPickerTheme.resolve].
* **[UnifiedFieldsCalendarDayInfo]** / `dayInfoBuilder` — per-day price labels, event dots, and disabled days on styled date pickers.
* **Field wiring** — [UnifiedDateField], [UnifiedDateRangeField], [UnifiedTimeOfDayField], form wrappers, and controllers accept `pickerStyle`, `pickerTheme`, `dayInfoBuilder` (date), and `presets` / `includeNowPreset` (time).

### Fixes

* **Global `height`** — [UnifiedFieldLabelMode.floatingLabel] now respects [UnifiedInputFieldDefaults.height] (label-in-row / label-in-column already did).
* **Global `rowLabelRatio`** — date/time/duration/picker fields no longer pass an empty `rowLabelRatio` / explicit `labelInRow: false` into [UnifiedBaseTextField], which could block theme defaults; all fields now use [UnifiedResolvedFieldChrome.optionalRowLabelRatio].
* **Label-in-row ratio** — [UnifiedBaseTextField] always uses the resolved decoration’s [UnifiedInputDecoration.effectiveRowLabelRatio].

### Features

* **[UnifiedInputAdornmentStyle]** — global prefix/suffix chrome: icon colors, slot sizes, padding, glyph size, gap between adornments. Set on [UnifiedInputThemeData.adornmentStyle], [UnifiedInputFieldDefaults], or per field via [UnifiedInputDecoration].
* **[UnifiedNumericStepButtonStyle]** — themed +/- button color, size, spacing, and background. Global via [UnifiedInputThemeData.numericStepButtonStyle]; per field via [UnifiedInputDecoration.numericStepButtonStyle] or [UnifiedNumberField.stepButtonStyle].
* **Number field adornment order** — [UnifiedNumericLeadingAdornmentOrder] and [UnifiedNumericTrailingAdornmentOrder] control whether custom prefix/suffix sit before or after step buttons.
* **Prefix adornments** — [UnifiedBaseTextField] now normalizes and tints leading icons the same way as suffixes; prefix/suffix padding is themeable (no longer hardcoded `8.0`).

## 1.0.2

Maintenance release. Pubspec version is **`1.0.2+1`**. No public API changes.

### Internal

* **File rename** — `unified_cutomizable_picker_fields.dart` → `unified_customizable_picker_fields.dart` (fixes the historical *cutomizable* typo). Import the package barrel (`package:unified_fields/unified_fields.dart`) as before; only direct `src/` path imports (unsupported) are affected.
* **`unified_form_more_fields.dart` split** — the 3300-line form-wrappers file is now a small library with `part` files grouped by domain (multi picker, date, time/duration, async pickers, number, async query). Public API and exports are unchanged.
* **`UnifiedColors` trimmed** — removed ~100 app-specific legacy tokens (aviation seat/passenger accents, brand pinks, `brownGrey1‑7`, `veryLightPink1‑7`, gradients, …) that nothing in the package or known consumers referenced. The core semantic tokens (text, hint, borders, error, primary, scaffold, `mainGreen`, `fieldTextFor` / `fieldLabelFor`) remain.

## 1.0.1

Patch release. Pubspec version is **`1.0.1+3`**.

### Features

* **`UnifiedAsyncQueryMultiPicker` / `UnifiedFormAsyncQueryMultiPicker`** — like [UnifiedAsyncQueryPicker] but multi-select: remote search at the bottom of the sheet, temp selection list (toggle rows across searches), **Cancel** / **Confirm**. [UnifiedAsyncQueryMultiPickerFieldController], [showUnifiedAsyncQueryMultiPickerSheet], [AsyncQueryMultiPickerSheetWidget].

### API

* **Async query controllers** — [queryFetcher] is required on the **widget** only ([UnifiedAsyncQueryPicker], [UnifiedAsyncQueryMultiPicker], form wrappers). Controllers receive it via [bindAsyncQueryPicker] when the field mounts; [UnifiedAsyncQueryPickerFieldController] and [UnifiedAsyncQueryMultiPickerFieldController] no longer take `queryFetcher` in the constructor.

### Fixes

* **Async query picker sheets** — search field moved **below the sheet title** (same as other pickers) so it is not hidden behind the keyboard; applies to single and multi async query sheets.

### Fixes

* **Tests** — restore `flutter_test` in `dev_dependencies` (was commented out, breaking `flutter test` and `flutter pub get` for contributors).
* **Vendored scrollable list** — [UnboundedViewport] passes `ScrollCacheExtent.pixels` to the [Viewport] super constructor on current Flutter; [UnboundedCustomScrollView] keeps `cacheExtent` (const constructor) with an analyzer ignore for the deprecation.

### Docs / lint

* Dartdoc on async query picker / multi-picker public members; remove unnecessary imports in async query picker sources; exclude vendored `scrollable_list` from analyzer (Flutter `cacheExtent` deprecations).

## 1.0.0

First stable release. The public API from **0.2.x** is unchanged; this version marks production readiness and rolls up bug fixes from **0.2.7** and **0.2.8**. Pubspec version is **`1.0.0+1`** (build metadata `+1` for consumers that track build numbers).

### Features

* **`UnifiedAsyncQueryPicker` / `UnifiedFormAsyncQueryPicker`** — read-only field; tap opens a sheet with an auto-focused search field at the **bottom**. Shows *Start typing to fetch* until [queryThreshold] (default **3**) characters are entered, then calls [queryFetcher] with debounce and **cancels** stale requests when the user keeps typing. Results appear in a list; tap to select. [UnifiedAsyncQueryPickerFieldController], [showUnifiedAsyncQueryPickerSheet], [UnifiedAsyncQueryFetcher].

### Fixes (included from 0.2.7 / 0.2.8)

* **Customizable form pickers** — [UnifiedFormCustomizablePickerField] and multi/async variants clear the form error when the value becomes valid (`unifiedFormClearErrorIfValid` on controller updates). [CustomizableSinglePickerController] / [CustomizableMultiPickerController] revalidate on `applyTyped` / `applySelected`. Form `validator:` syncs to the controller for [UnifiedFieldValidation.validateFields] (`syncCustomizableSingleFormValidatorToFieldController` / `syncCustomizableMultiFormValidatorToFieldController`).
* **`UnifiedNumberField` / `UnifiedNumericStepField`** — [UnifiedFieldsTypography.usePersianDigitsGlobally] localizes displayed digits on init, while typing, and from [UnifiedNumberFieldController]; input formatters accept Persian digits; theme `textStylePersian` applies via [UnifiedInputThemeResolver.fieldTextStyle]. Helpers: `formatUnifiedNumberFieldText`, `localizeUnifiedNumberDisplayText`.
* **`UnifiedDateField` / `UnifiedDateRangeField` / `UnifiedDurationField`** — no longer read [UnifiedInputThemeScope] during `initState` when resolving `dateFormatStyle` / `durationFormatStyle` (fixes `dependOnInheritedWidgetOfExactType` was called before initState completed).
* **Typed form validators** (0.2.7) — `FormFieldValidator<List<T>>`, nullable pickers, and `UnifiedFieldValidation.validateFields` stay aligned with `FormState.validate`.
* **Field height on focus** — [UnifiedBaseTextField] label-in-row layout uses a fixed row height; Material outline borders no longer thicken on focus, so enabled vs focused states keep the same height by default. [UnifiedInputDecoration.height] is optional (unset layers no longer force `56` during merge).

### Docs

* README: **Upgrading to 1.0.0**, async query picker, Persian digits on number fields, customizable picker validation, consistent field height. Example README updated.

## 0.2.8

### Fixes

* **Customizable form pickers** — [UnifiedFormCustomizablePickerField], multi/async variants call [unifiedFormClearErrorIfValid] when the picker controller changes; [CustomizableSinglePickerController] / [CustomizableMultiPickerController] revalidate on `applyTyped` / `applySelected`. Form `validator:` syncs to the controller for [UnifiedFieldValidation.validateFields].
* **`UnifiedNumberField` / `UnifiedNumericStepField`** — respect [UnifiedFieldsTypography.usePersianDigitsGlobally]: display text is localized on init, while typing, and from [UnifiedNumberFieldController]; input formatters accept Persian digits; theme `textStylePersian` applies via [UnifiedInputThemeResolver.fieldTextStyle].
* **`UnifiedDateField` / `UnifiedDateRangeField` / `UnifiedDurationField`** — complete fix for `dependOnInheritedWidgetOfExactType<UnifiedInputThemeScope>() was called before initState() completed` when theme `dateFormatStyle` / `durationFormatStyle` is set. Format styles are cached in `didChangeDependencies` on all three widgets; `initState` uses field-only resolution until dependencies are available.

### Docs

* README and example README version **0.2.8**. Publish checklist updated.

## 0.2.7

### Features

* **`UnifiedFieldsDateFormatStyle` / `UnifiedFieldsDurationFormatStyle`** — theme defaults on [UnifiedInputThemeData] (`dateFormatStyle`, `durationFormatStyle`) for Gregorian and Shamsi field display; override per [UnifiedDateField], [UnifiedDateRangeField], [UnifiedDurationField], form wrappers, and controllers. Presets: `UnifiedFieldsDateFormatStyle.standard`, `isoGregorianDay`. Legacy `valueFormat: DateFormat(…)` still wins for dates when set. Resolvers: [UnifiedInputThemeResolver.dateFormatStyle] / `durationFormatStyle`.

### Fixes

* **`UnifiedDateField` / range / `UnifiedDurationField`** — resolve `dateFormatStyle` / `durationFormatStyle` from theme in `didChangeDependencies` only (not during `initState`), fixing `dependOnInheritedWidgetOfExactType` was called before initState completed.
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
