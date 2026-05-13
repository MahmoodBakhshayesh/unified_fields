import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unified_fields/unified_fields.dart';

void main() {
  test('package exports core types', () {
    expect(AppColors.hintColor, isA<Color>());
  });
}
