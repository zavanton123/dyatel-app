/// Formats and parses the grouped digits shown in the range fields.
///
/// Kept deliberately small so it can be unit tested without a widget tree.
String formatGrouped(int value) {
  final negative = value < 0;
  final digits = value.abs().toString();
  final buffer = StringBuffer();

  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
    buffer.write(digits[i]);
  }

  return negative ? '-$buffer' : buffer.toString();
}

int? parseGrouped(String text) {
  final cleaned = text.replaceAll(RegExp(r'[^\d-]'), '');
  if (cleaned.isEmpty || cleaned == '-') return null;
  return int.tryParse(cleaned);
}
