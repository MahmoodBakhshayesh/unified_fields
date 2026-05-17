# unified_fields_example

A small Flutter app that exercises every notable widget from
[`unified_fields`](../README.md):

- Plain fields (`UnifiedTextField`, `UnifiedNumberField`, …)
- Date pickers: calendar grid and scroll wheels, Gregorian / Shamsi
- Time and duration wheel pickers with optional Jalali digits
- Custom duration columns (e.g. year · week · day · hour)
- `UnifiedFormFieldScope` + every `UnifiedForm*` wrapper, including customizable picker form wrappers
- The bundled `UnifiedInputsShowcasePage` from the AppBar

## Run

```bash
cd example
flutter pub get
flutter run
```

The app uses `path: ../` to depend on the package source in this repository
so any edit in `lib/` is picked up on hot reload.

## Package version

This example tracks the parent package (**currently 0.1.4**). See the root
[`CHANGELOG.md`](../CHANGELOG.md) for release notes.
