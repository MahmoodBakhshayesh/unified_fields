import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unified_fields/unified_fields.dart';

void main() {
  Future<Size> measureBaseField(WidgetTester tester, Widget child) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UnifiedInputThemeScope(
            data: const UnifiedInputThemeData(
              fieldDefaults: UnifiedInputFieldDefaults(
                labelMode: UnifiedFieldLabelMode.labelInRow,
              ),
            ),
            child: Center(child: SizedBox(width: 400, child: child)),
          ),
        ),
      ),
    );
    return tester.getSize(find.byType(UnifiedBaseTextField));
  }

  testWidgets('picker decoration height matches text field', (tester) async {
    final text = await measureBaseField(
      tester,
      const UnifiedTextField(
        label: 'Name',
        decoration: UnifiedInputDecoration(height: 72),
      ),
    );
    final picker = await measureBaseField(
      tester,
      const UnifiedSinglePickerField<String>(
        label: 'Country',
        items: ['A', 'B'],
        decoration: UnifiedInputDecoration(height: 72),
      ),
    );
    final date = await measureBaseField(
      tester,
      const UnifiedDateField(
        label: 'Date',
        decoration: UnifiedInputDecoration(height: 72),
      ),
    );

    expect(text.height, closeTo(72, 2));
    expect(picker.height, closeTo(72, 2));
    expect(date.height, closeTo(72, 2));
  });

  testWidgets(
    'picker height is not clobbered by theme readOnly decoration layer',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: UnifiedInputThemeScope(
              data: const UnifiedInputThemeData(
                fieldDefaults: UnifiedInputFieldDefaults(
                  labelMode: UnifiedFieldLabelMode.labelInRow,
                  height: 56,
                ),
                fieldDecorationSet: UnifiedInputDecorationSet(
                  // Pickers are permanently readOnly — this used to override
                  // per-field height when state chrome was merged last.
                  readOnly: UnifiedInputDecoration(height: 56),
                  focused: UnifiedInputDecoration(height: 56),
                ),
              ),
              child: const Center(
                child: SizedBox(
                  width: 400,
                  child: UnifiedSinglePickerField<String>(
                    label: 'Country',
                    items: ['A', 'B'],
                    decoration: UnifiedInputDecoration(height: 122),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      final size = tester.getSize(find.byType(UnifiedBaseTextField));
      expect(size.height, closeTo(122, 2));
    },
  );

  testWidgets('form single picker honors decoration height', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: UnifiedInputThemeScope(
            data: const UnifiedInputThemeData(
              fieldDefaults: UnifiedInputFieldDefaults(
                labelMode: UnifiedFieldLabelMode.labelInRow,
              ),
            ),
            child: const Form(
              child: UnifiedFormFieldScope(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: UnifiedFormSinglePickerField<String>(
                    label: 'Country',
                    decoration: UnifiedInputDecoration(height: 122, labelInRow: true),
                    items: ['Iran', 'Germany'],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    final size = tester.getSize(find.byType(UnifiedBaseTextField));
    expect(size.height, closeTo(122, 2));
  });
}
