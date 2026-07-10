import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unified_fields/unified_fields.dart';

void main() {
  group('UnifiedInputFieldDefaults global theme', () {
    Widget themedField({
      required Widget child,
      UnifiedInputFieldDefaults? fieldDefaults,
    }) {
      return MaterialApp(
        home: UnifiedInputThemeScope(
          data: UnifiedInputThemeData(fieldDefaults: fieldDefaults),
          child: Scaffold(body: child),
        ),
      );
    }

    testWidgets('resolveUnifiedDecoration applies global height and rowLabelRatio',
        (tester) async {
      late UnifiedInputDecoration resolved;

      await tester.pumpWidget(
        themedField(
          fieldDefaults: const UnifiedInputFieldDefaults(
            height: 72,
            rowLabelRatio: [8, 20],
            labelMode: UnifiedFieldLabelMode.labelInRow,
          ),
          child: Builder(
            builder: (context) {
              resolved = resolveUnifiedDecoration(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(resolved.height, 72);
      expect(resolved.rowLabelRatio, [8, 20]);
      expect(resolved.labelMode, UnifiedFieldLabelMode.labelInRow);
    });

    testWidgets('UnifiedTextField uses global height in label-in-row layout',
        (tester) async {
      await tester.pumpWidget(
        themedField(
          fieldDefaults: const UnifiedInputFieldDefaults(
            height: 72,
            labelMode: UnifiedFieldLabelMode.labelInRow,
          ),
          child: const UnifiedTextField(label: 'Name', placeholder: 'Enter'),
        ),
      );

      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      expect(
        sizedBoxes.any((box) => box.height == 72),
        isTrue,
        reason: 'Expected a SizedBox with global height 72',
      );
    });

    testWidgets('UnifiedTextField uses global rowLabelRatio in label-in-row layout',
        (tester) async {
      await tester.pumpWidget(
        themedField(
          fieldDefaults: const UnifiedInputFieldDefaults(
            rowLabelRatio: [1, 9],
            labelMode: UnifiedFieldLabelMode.labelInRow,
          ),
          child: const UnifiedTextField(label: 'Ratio', placeholder: 'x'),
        ),
      );

      final expanded = tester.widgetList<Expanded>(find.byType(Expanded));
      final flexes = expanded.map((e) => e.flex).toList();
      expect(flexes, containsAll([1, 9]));
    });

    testWidgets('per-field decoration overrides global rowLabelRatio',
        (tester) async {
      await tester.pumpWidget(
        themedField(
          fieldDefaults: const UnifiedInputFieldDefaults(
            rowLabelRatio: [1, 9],
            labelMode: UnifiedFieldLabelMode.labelInRow,
          ),
          child: const UnifiedTextField(
            label: 'One',
            decoration: UnifiedInputDecoration(rowLabelRatio: [3, 7]),
          ),
        ),
      );

      final expanded = tester.widgetList<Expanded>(find.byType(Expanded));
      final flexes = expanded.map((e) => e.flex).toList();
      expect(flexes, containsAll([3, 7]));
      expect(flexes, isNot(containsAll([1, 9])));
    });

    testWidgets('UnifiedDateField uses global height', (tester) async {
      await tester.pumpWidget(
        themedField(
          fieldDefaults: const UnifiedInputFieldDefaults(
            height: 80,
            labelMode: UnifiedFieldLabelMode.labelInRow,
          ),
          child: const UnifiedDateField(label: 'Date'),
        ),
      );

      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      expect(
        sizedBoxes.any((box) => box.height == 80),
        isTrue,
        reason: 'UnifiedDateField should honor global height',
      );
    });

    testWidgets('global labelInRow flag enables row layout without labelMode',
        (tester) async {
      await tester.pumpWidget(
        themedField(
          fieldDefaults: const UnifiedInputFieldDefaults(
            labelInRow: true,
            rowLabelRatio: [2, 8],
            height: 64,
          ),
          child: const UnifiedTextField(label: 'Legacy', placeholder: 'x'),
        ),
      );

      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      expect(sizedBoxes.any((box) => box.height == 64), isTrue);

      final flexes =
          tester.widgetList<Expanded>(find.byType(Expanded)).map((e) => e.flex);
      expect(flexes, containsAll([2, 8]));
    });

    testWidgets('floating label layout respects global height', (tester) async {
      await tester.pumpWidget(
        themedField(
          fieldDefaults: const UnifiedInputFieldDefaults(
            height: 88,
            labelMode: UnifiedFieldLabelMode.floatingLabel,
          ),
          child: const UnifiedTextField(label: 'Float', placeholder: 'x'),
        ),
      );

      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      expect(
        sizedBoxes.any((box) => box.height == 88),
        isTrue,
        reason: 'Floating label fields should honor global height',
      );
    });
  });
}
