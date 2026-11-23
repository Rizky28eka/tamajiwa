import 'package:flutter_test/flutter_test.dart';
import 'package:tamajiwa/models/user_model.dart';

void main() {
  test('parses a partial user without throwing', () {
    final user = UserModel.fromJson({'id': 3, 'name': 'Dosen Tidak Diketahui'});
    expect(user.id, 3);
    expect(user.name, 'Dosen Tidak Diketahui');
    expect(user.email, '');
    expect(user.role, '');
  });

  test('parses a full user', () {
    final user = UserModel.fromJson({
      'id': 1,
      'name': 'Dosen 1',
      'email': 'dosen1@example.com',
      'role': 'dosen',
      'dosen_selected_at': '2026-11-23 10:00:00',
    });
    expect(user.role, 'dosen');
    expect(user.dosenSelectedAt, isNotNull);
  });
}
