import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unified_fields/src/controllers/field_controller_sync.dart';
import 'package:unified_fields/src/controllers/unified_field_validation.dart';
import 'package:unified_fields/src/controllers/unified_date_field_controller.dart';
import 'package:unified_fields/src/controllers/unified_number_field_controller.dart';
import 'package:unified_fields/src/controllers/unified_text_field_controller.dart';

void main() {
  test('syncWidgetStringValidatorToFieldController enables validateFields', () {
    final fc = UnifiedTextFieldController();
    syncWidgetStringValidatorToFieldController(
      fc,
      (v) => v.isEmpty ? 'Required' : null,
    );

    expect(UnifiedFieldValidation.validateFields([fc]), isFalse);
    expect(fc.errorText, 'Required');

    fc.value = 'ok';
    expect(UnifiedFieldValidation.validateFields([fc]), isTrue);
    expect(fc.errorText, isNull);
  });

  test('applyValueFromUser clears error only when value becomes valid', () {
    final fc = UnifiedTextFieldController();
    syncWidgetStringValidatorToFieldController(
      fc,
      (v) => v.isEmpty ? 'Required' : null,
    );
    fc.validate();
    expect(fc.hasError, isTrue);

    fc.textController.text = '';
    expect(fc.hasError, isTrue);
    expect(fc.errorText, 'Required');

    fc.textController.text = 'fixed';
    expect(fc.hasError, isFalse);
    expect(fc.errorText, isNull);
  });

  test('widget validator overrides controller validator when synced', () {
    final fc = UnifiedTextFieldController(
      validator: (_) => 'from controller',
    );
    syncWidgetStringValidatorToFieldController(
      fc,
      (v) => v.isEmpty ? 'from widget' : null,
    );

    expect(fc.validate(), 'from widget');
  });

  testWidgets('unifiedFormClearErrorIfValid supports List<T> validators', (
    tester,
  ) async {
    final fieldKey = GlobalKey<FormFieldState<List<int>>>();

    String? notEmptyList(List<int>? value) =>
        (value ?? []).isEmpty ? 'Required' : null;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            child: FormField<List<int>>(
              key: fieldKey,
              initialValue: const [],
              validator: notEmptyList,
              builder: (fieldState) {
                return Column(
                  children: [
                    Text(fieldState.hasError ? 'error' : 'ok'),
                    TextButton(
                      onPressed: () {
                        fieldState.didChange([1]);
                        syncUnifiedFieldListValue<int>(
                          value: const [1],
                          formFieldState: fieldState,
                        );
                      },
                      child: const Text('pick'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );

    fieldKey.currentState!.validate();
    await tester.pump();
    expect(find.text('error'), findsOneWidget);

    await tester.tap(find.text('pick'));
    await tester.pump();

    expect(find.text('ok'), findsOneWidget);
    expect(fieldKey.currentState!.hasError, isFalse);
  });

  testWidgets('unifiedFormClearErrorIfValid supports nullable T validators', (
    tester,
  ) async {
    final fieldKey = GlobalKey<FormFieldState<String?>>();

    String? required(String? value) =>
        (value == null || value.isEmpty) ? 'Required' : null;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Form(
            child: FormField<String?>(
              key: fieldKey,
              initialValue: null,
              validator: required,
              builder: (fieldState) {
                return Column(
                  children: [
                    Text(fieldState.hasError ? 'error' : 'ok'),
                    TextButton(
                      onPressed: () {
                        fieldState.didChange('picked');
                        syncUnifiedFieldValue<String?>(
                          value: 'picked',
                          formFieldState: fieldState,
                        );
                      },
                      child: const Text('pick'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );

    fieldKey.currentState!.validate();
    await tester.pump();
    expect(find.text('error'), findsOneWidget);

    await tester.tap(find.text('pick'));
    await tester.pump();

    expect(find.text('ok'), findsOneWidget);
    expect(fieldKey.currentState!.hasError, isFalse);
  });

  test('syncWidgetFormValidatorToFieldController copies T? form validators', () {
    final fc = UnifiedTextFieldController();
    String? required(String? value) =>
        (value == null || value.isEmpty) ? 'Required' : null;

    syncWidgetFormValidatorToFieldController<String?>(fc, required);

    expect(fc.validate(), 'Required');
    fc.value = 'ok';
    expect(fc.validate(), isNull);
  });

  test('syncDisplayStringValidatorToFieldController maps date display text', () {
    final fc = UnifiedDateFieldController();
    syncDisplayStringValidatorToFieldController<DateTime>(
      fieldController: fc,
      widgetValidator: (s) => s.isEmpty ? 'Required' : null,
      displayFor: (dt) => dt == null ? '' : '2024-01-01',
    );

    expect(fc.validate(), 'Required');
    fc.value = DateTime(2024, 1, 1);
    expect(fc.validate(), isNull);
  });

  test('syncNumberFormStringValidatorToFieldController matches form text', () {
    final fc = UnifiedNumberFieldController();
    syncNumberFormStringValidatorToFieldController(
      fc,
      (s) => (s ?? '').trim().isEmpty ? 'Required' : null,
    );

    expect(fc.validate(), 'Required');
    fc.text.textController.text = '42';
    expect(fc.validate(), isNull);
  });
}
