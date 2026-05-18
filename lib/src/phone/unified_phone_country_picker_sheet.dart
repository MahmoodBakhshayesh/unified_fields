import 'package:flutter/material.dart';

import '../fields/unified_picker_sheet.dart';
import '../unified_date_picker_types.dart';
import 'unified_country.dart';

/// Shows a searchable country list and returns the chosen [UnifiedCountry].
Future<UnifiedCountry?> showUnifiedPhoneCountryPicker({
  required BuildContext context,
  required List<UnifiedCountry> countries,
  UnifiedCountry? selected,
  String title = 'Country',
  bool? usePersianDigits,
  UnifiedFieldsCalendarKind? digitCalendarKind,
}) {
  return showModalBottomSheet<UnifiedCountry>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) {
      final h = MediaQuery.sizeOf(ctx).height * 0.72;
      return SizedBox(
        height: h,
        child: PickerSheetWidget<UnifiedCountry>(
          items: countries,
          suggestion: const [],
          label: title,
          hasClear: false,
          value: selected,
          searchAutoFocus: true,
          hasSearch: true,
          searchBuilder: (c) => '${c.name} ${c.dialCode} ${c.isoCode}',
          itemToWidget: (c) => ListTile(
            title: UnifiedCountryWidget(
              country: c,
              showName: true,
              usePersianDigits: usePersianDigits,
              digitCalendarKind: digitCalendarKind,
            ),
            trailing: UnifiedCountryWidget(
              country: c,
              showFlag: false,
              showName: false,
              showDialCode: true,
              usePersianDigits: usePersianDigits,
              digitCalendarKind: digitCalendarKind,
            ),
          ),
        ),
      );
    },
  );
}
