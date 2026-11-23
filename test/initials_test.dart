import 'package:flutter/widgets.dart' show StringCharacters;
import 'package:flutter_test/flutter_test.dart';

// Salinan logika inisial yang dipakai daftar pasien, diuji pada kasus tepi.
String initials(String name) {
  final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return 'N/A';
  if (parts.length == 1) return parts[0].characters.first.toUpperCase();
  return '${parts[0].characters.first}${parts[1].characters.first}'.toUpperCase();
}

void main() {
  test('handles empty, single and double-spaced names', () {
    expect(initials(''), 'N/A');
    expect(initials('   '), 'N/A');
    expect(initials('budi'), 'B');
    expect(initials('Siti  Aminah'), 'SA');
  });
}
