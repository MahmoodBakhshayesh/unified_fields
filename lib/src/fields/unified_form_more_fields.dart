/// Form-aware (FormField) wrappers around the unified picker, date/time,
/// duration, number, and async query fields.
library;

import 'package:flutter/material.dart';

import '../controllers/field_controller_sync.dart';
import '../controllers/unified_async_picker_field_controller.dart';
import '../controllers/unified_date_field_controller.dart';
import '../controllers/unified_date_range_field_controller.dart';
import '../controllers/unified_duration_field_controller.dart';
import '../controllers/unified_number_field_controller.dart';
import '../controllers/unified_picker_field_controller.dart';
import '../controllers/unified_time_field_controller.dart';
import '../unified_date_picker_sheet.dart';
import '../unified_date_picker_types.dart';
import '../unified_fields_date_format_style.dart';
import '../unified_fields_picker_theme.dart';
import '../unified_fields_styled_calendar_picker.dart';
import '../unified_time_picker_types.dart';
import '../unified_fields_duration_format_style.dart';
import 'unified_input_picker.dart';
import 'unified_async_picker_field.dart';
import 'unified_async_query_picker_field.dart';
import 'unified_async_query_picker_sheet.dart';
import '../controllers/unified_async_query_picker_field_controller.dart';
import '../controllers/unified_async_query_multi_picker_field_controller.dart';
import 'unified_async_query_multi_picker_field.dart';
import 'unified_date_field.dart';
import 'unified_duration_field.dart';
import 'unified_form_fields.dart';
import 'unified_input_brightness.dart';
import 'unified_input_decoration.dart';
import 'unified_numeric_step_buttons.dart';
import 'unified_number_field.dart';
import 'unified_picker_fields.dart';
import 'unified_picker_item_builders.dart';
import 'unified_input_theme.dart';
import 'unified_time_of_day_field.dart';

part 'unified_form_multi_picker_field.part.dart';
part 'unified_form_date_fields.part.dart';
part 'unified_form_time_duration_fields.part.dart';
part 'unified_form_async_picker_fields.part.dart';
part 'unified_form_number_field.part.dart';
part 'unified_form_async_query_fields.part.dart';

bool _unifiedListsEqual<T>(List<T>? a, List<T> b) {
  if (a == null) return b.isEmpty;
  if (a.length != b.length) return false;
  for (var i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}

