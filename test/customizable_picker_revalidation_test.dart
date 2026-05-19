import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unified_fields/unified_fields.dart';

void main() {
  test('applyTyped clears controller error when displayValidator passes', () {
    final controller = CustomizableSinglePickerController<String>(
      initialKind: CustomizablePickerInputKind.typed,
      initialTyped: '',
      displayValidator: (text) => text.trim().isEmpty ? 'Required' : null,
    );
    expect(controller.validate(), 'Required');

    controller.applyTyped('Iran');
    expect(controller.hasError, isFalse);
    expect(controller.errorText, isNull);
  });

  testWidgets('customizable form field clears error when user types valid text', (
    tester,
  ) async {
    final controller = CustomizableSinglePickerController<String>(
      initialKind: CustomizablePickerInputKind.typed,
      initialTyped: '',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            child: UnifiedFormCustomizablePickerField<String>(
              label: 'Origin',
              items: const ['Iran', 'USA'],
              pickerController: controller,
              validator: (c) =>
                  c!.fieldDisplayText.trim().isEmpty ? 'Required' : null,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final formState = tester.state<FormState>(find.byType(Form));
    expect(formState.validate(), isFalse);

    await tester.enterText(find.byType(TextField), 'Iran');
    await tester.pump();
    await tester.pump();

    expect(formState.validate(), isTrue);
    expect(find.text('Required'), findsNothing);
  });
}
