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

  test('UnifiedAsyncQueryMultiPickerFieldController defaults', () {
    final c = UnifiedAsyncQueryMultiPickerFieldController<String>();
    expect(c.queryThreshold, 3);
    expect(c.queryDebounce, const Duration(milliseconds: 300));
    expect(c.showClearButton, isTrue);
    expect(c.values, isEmpty);
    c.bindAsyncQueryPicker(
      label: 'Tags',
      queryFetcher: (_) async => ['a'],
      queryThreshold: 2,
      queryDebounce: const Duration(milliseconds: 300),
    );
    expect(c.queryThreshold, 2);
  });

  test('UnifiedAsyncQueryPickerFieldController binds queryFetcher from widget', () {
    final c = UnifiedAsyncQueryPickerFieldController<String>();
    c.bindAsyncQueryPicker(
      label: 'City',
      queryFetcher: (q) async => [q],
      queryThreshold: 3,
      queryDebounce: const Duration(milliseconds: 300),
    );
    expect(c.queryThreshold, 3);
  });
}
