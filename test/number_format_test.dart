import 'package:dyatel/utils/number_format.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('formatGrouped', () {
    test('groups thousands', () {
      expect(formatGrouped(0), '0');
      expect(formatGrouped(100), '100');
      expect(formatGrouped(1000), '1,000');
      expect(formatGrouped(100000), '100,000');
      expect(formatGrouped(1234567), '1,234,567');
    });

    test('keeps the sign', () {
      expect(formatGrouped(-42), '-42');
      expect(formatGrouped(-100000), '-100,000');
    });
  });

  group('parseGrouped', () {
    test('reads grouped and plain digits', () {
      expect(parseGrouped('100,000'), 100000);
      expect(parseGrouped('100000'), 100000);
      expect(parseGrouped('  42 '), 42);
      expect(parseGrouped('-5'), -5);
    });

    test('rejects input with no digits', () {
      expect(parseGrouped(''), isNull);
      expect(parseGrouped('abc'), isNull);
      expect(parseGrouped('-'), isNull);
    });
  });

  test('round-trips', () {
    for (final value in [0, 7, 100, 100000, 1234567, -42]) {
      expect(parseGrouped(formatGrouped(value)), value);
    }
  });
}
