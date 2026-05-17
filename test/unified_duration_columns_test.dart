import 'package:flutter_test/flutter_test.dart';
import 'package:unified_fields/unified_fields.dart';

void main() {
  test('compose and decompose round-trip', () {
    const columns = UnifiedFieldsDurationColumnPresets.yearsWeeksDaysHours;
    const values = [1, 2, 3, 4];
    final d = composeUnifiedDuration(columns, values);
    expect(decomposeUnifiedDuration(d, columns), values);
  });

  test('calendar column max indices are fixed ranges', () {
    const columns = [
      UnifiedFieldsDurationColumn.year,
      UnifiedFieldsDurationColumn.month,
      UnifiedFieldsDurationColumn.week,
    ];
    const shortMax = Duration(hours: 2);
    expect(
      unifiedDurationColumnMaxIndex(
        UnifiedFieldsDurationColumn.year,
        columns,
        shortMax,
      ),
      999,
    );
    expect(
      unifiedDurationColumnMaxIndex(
        UnifiedFieldsDurationColumn.month,
        columns,
        shortMax,
      ),
      11,
    );
    expect(
      unifiedDurationColumnMaxIndex(
        UnifiedFieldsDurationColumn.week,
        columns,
        shortMax,
      ),
      4,
    );
  });

  test('format uses colon-separated parts', () {
    final d = composeUnifiedDuration(
      UnifiedFieldsDurationColumnPresets.hoursMinutesSeconds,
      [1, 2, 3],
    );
    final text = formatUnifiedDurationColumns(
      d,
      UnifiedFieldsDurationColumnPresets.hoursMinutesSeconds,
    );
    expect(text, '01:02:03');
  });
}
