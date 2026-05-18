# unified_fields_example

A small Flutter app that exercises every notable widget from
[`unified_fields`](../README.md):

- **App-wide `UnifiedInputThemeScope`** in `lib/main.dart` (required icon, validation, disabled chrome, picker suffix icons, sheet background)
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

## Package version

This example tracks the parent package (**currently 0.2.1**). See the root
[`CHANGELOG.md`](../CHANGELOG.md) for release notes.
