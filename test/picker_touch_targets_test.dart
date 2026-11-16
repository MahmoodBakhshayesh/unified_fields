import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unified_fields/unified_fields.dart';

/// Host theme like a dense desktop-first app: compact density + shrink-wrapped
/// Material tap targets, so only the package's own metrics decide the sizes.
final _denseTheme = ThemeData(
  visualDensity: VisualDensity.compact,
  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
);

UnifiedInputThemeData _themeData({double? minTapTarget, double? dayCellExtent, bool compact = true}) =>
    UnifiedInputThemeData(
      pickerPresentation: UnifiedPickerPresentation.bottomSheet,
      preferCompactPickers: compact,
      pickerSurfaceStyle: UnifiedPickerSurfaceStyle(
        // Ahem glyphs are a full em wide; keep footers within a phone sheet.
        actionTextStyle: const TextStyle(fontSize: 9),
        minTapTarget: minTapTarget,
        dayCellExtent: dayCellExtent,
      ),
    );

const _touch = UnifiedPickerSurfaceStyle.touch;

Future<void> _pump(WidgetTester tester, Widget field, {UnifiedInputThemeData? data}) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      theme: _denseTheme,
      // Above the Navigator, like an app shell, so modal sheets inherit it.
      builder: (context, child) => UnifiedInputThemeScope(data: data ?? _themeData(), child: child!),
      home: Scaffold(
        body: Padding(padding: const EdgeInsets.all(16), child: field),
      ),
    ),
  );
  await tester.tap(find.byWidget(field));
  await tester.pumpAndSettle();
}

final _first = DateTime(2026, 1, 1);
final _last = DateTime(2026, 12, 31);

Widget _date() => UnifiedDateField(label: 'Date', min: _first, max: _last, value: DateTime(2026, 6, 15));
Widget _range() => UnifiedDateRangeField(label: 'Range', min: _first, max: _last);
Widget _multi() => UnifiedMultiPickerField<String>(
  label: 'Multi',
  items: const ['A', 'B', 'C'],
  values: const ['A'],
  hasSearch: false,
);
Widget _time() => const UnifiedTimeOfDayField(label: 'Time');
Widget _single() => UnifiedSinglePickerField<String>(label: 'One', items: const ['A', 'B', 'C'], hasSearch: false);

Size _sizeOfText(WidgetTester tester, String day) {
  final ink = find.ancestor(of: find.text(day), matching: find.byType(InkWell)).first;
  return tester.getSize(ink);
}

void main() {
  group('default (pointer) metrics are unchanged', () {
    testWidgets('compact date day cells stay 34 px', (tester) async {
      await _pump(tester, _date());
      expect(_sizeOfText(tester, '10').height, 34);
    });

    testWidgets('compact range day cells stay 34 px', (tester) async {
      await _pump(tester, _range());
      expect(_sizeOfText(tester, '10').height, 34);
    });

    testWidgets('multi sheet buttons stay 40 px', (tester) async {
      await _pump(tester, _multi());
      for (final b in tester.widgetList<UnifiedSheetButton>(find.byType(UnifiedSheetButton))) {
        expect(tester.getSize(find.byWidget(b)).height, 40);
      }
    });

    testWidgets('calendar sheet day cells stay 36 px (40 px rows)', (tester) async {
      await _pump(tester, _date(), data: _themeData(compact: false));
      expect(_sizeOfText(tester, '10').height, 36);
    });

    test('resolved defaults', () {
      expect(UnifiedPickerSurfaceStyle.touch.minTapTarget, 44);
      expect(const UnifiedPickerSurfaceStyle().minTapTarget, isNull);
    });
  });

  group('touch metrics meet 44 × 44', () {
    final data = _themeData(minTapTarget: _touch.minTapTarget, dayCellExtent: _touch.dayCellExtent);

    testWidgets('compact date', (tester) async {
      await _pump(tester, _date(), data: data);
      expect(_sizeOfText(tester, '10').height, greaterThanOrEqualTo(44));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    });

    testWidgets('compact range', (tester) async {
      await _pump(tester, _range(), data: data);
      expect(_sizeOfText(tester, '10').height, greaterThanOrEqualTo(44));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    });

    testWidgets('calendar sheet day circles', (tester) async {
      await _pump(
        tester,
        _date(),
        data: _themeData(minTapTarget: _touch.minTapTarget, dayCellExtent: _touch.dayCellExtent, compact: false),
      );
      expect(_sizeOfText(tester, '10').height, greaterThanOrEqualTo(44));
    });

    testWidgets('compact time', (tester) async {
      await _pump(tester, _time(), data: data);
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    });

    testWidgets('multi sheet', (tester) async {
      await _pump(tester, _multi(), data: data);
      for (final b in tester.widgetList<UnifiedSheetButton>(find.byType(UnifiedSheetButton))) {
        expect(tester.getSize(find.byWidget(b)).height, greaterThanOrEqualTo(44));
      }
      final close = tester.getSize(find.byType(CloseButton));
      expect(close.width, greaterThanOrEqualTo(44));
      expect(close.height, greaterThanOrEqualTo(44));
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    });

    testWidgets('single sheet', (tester) async {
      await _pump(tester, _single(), data: data);
      await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    });
  });
}
