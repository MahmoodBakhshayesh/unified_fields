import 'package:flutter_test/flutter_test.dart';
import 'package:unified_fields/unified_fields.dart';

void main() {
  test('UnifiedFieldsStrings async query defaults', () {
    expect(
      UnifiedFieldsStrings.instance.asyncQueryTypeToFetch,
      'Start typing to fetch',
    );
    expect(UnifiedFieldsStrings.instance.asyncQueryNoResults, 'No results');
  });
}
