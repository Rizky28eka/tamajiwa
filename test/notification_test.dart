import 'package:flutter_test/flutter_test.dart';
import 'package:tamajiwa/models/app_notification_model.dart';
import 'package:tamajiwa/models/form_model.dart';
import 'package:tamajiwa/views/notifications_view.dart';

void main() {
  test('AppNotification membaca JSON dan status baca', () {
    final n = AppNotification.fromJson({
      'id': 4,
      'type': 'form_revised',
      'title': 'Formulir perlu revisi',
      'body': 'Dr. Ani meminta revisi',
      'form_id': 9,
      'created_at': '2026-11-23T08:00:00.000000Z',
      'read_at': null,
    });
    expect(n.isRead, isFalse);
    expect(n.formId, 9);
    final read = n.asRead();
    expect(read.isRead, isTrue);
    expect(read.id, 4);
  });

  test('AppNotification tahan field opsional kosong', () {
    final n = AppNotification.fromJson({'id': 1, 'type': 'x', 'title': 't'});
    expect(n.body, isNull);
    expect(n.formId, isNull);
    expect(n.createdAt, isNull);
  });

  test('relativeTime memberi label yang wajar', () {
    final now = DateTime(2026, 11, 23, 12);
    String f(Duration d) =>
        NotificationsView.relativeTime(now.subtract(d), now: now);
    expect(f(const Duration(seconds: 20)), 'Baru saja');
    expect(f(const Duration(minutes: 5)), '5 menit lalu');
    expect(f(const Duration(hours: 3)), '3 jam lalu');
    expect(f(const Duration(days: 2)), '2 hari lalu');
    expect(NotificationsView.relativeTime(null), '');
  });

  test('FormModel membaca nilai dan mempertahankannya saat copyWith', () {
    final json = {
      'id': 1,
      'type': 'sap',
      'user_id': 2,
      'patient_id': 3,
      'status': 'approved',
      'score': 88,
      'created_at': '2026-11-20T08:00:00.000000Z',
      'updated_at': '2026-11-21T08:00:00.000000Z',
    };
    final f = FormModel.fromJson(json);
    expect(f.score, 88);
    expect(f.copyWith(status: 'revised').score, 88);
    expect(FormModel.fromJson({...json, 'score': null}).score, isNull);
  });
}
