# unified_fields_example

A small Flutter app that exercises every notable widget from
[`unified_fields`](../README.md):

- Plain fields (`UnifiedTextField`, `UnifiedNumberField`, …)
- `UnifiedFormFieldScope` + every `UnifiedForm*` wrapper, including the new
  customizable picker form wrappers (`UnifiedFormCustomizablePickerField`,
  `UnifiedFormCustomizableMultiPickerField`).
- The bundled `UnifiedInputsShowcasePage` accessible from the AppBar.

## Run

```bash
cd example
flutter pub get
flutter run
```

The app uses `path: ../` to depend on the package source in this repository
so any edit in `lib/` is picked up on hot reload.
