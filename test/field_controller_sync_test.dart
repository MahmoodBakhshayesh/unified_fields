import 'package:flutter_test/flutter_test.dart';
import 'package:unified_fields/src/controllers/field_controller_sync.dart';
import 'package:unified_fields/src/controllers/unified_field_validation.dart';
import 'package:unified_fields/src/controllers/unified_text_field_controller.dart';

void main() {
  test('syncWidgetStringValidatorToFieldController enables validateFields', () {
    final fc = UnifiedTextFieldController();
    syncWidgetStringValidatorToFieldController(
      fc,
      (v) => v == null || v.isEmpty ? 'Required' : null,
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
      (v) => v == null || v.isEmpty ? 'Required' : null,
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
}
