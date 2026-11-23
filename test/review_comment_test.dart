import 'package:flutter_test/flutter_test.dart';
import 'package:tamajiwa/models/form_model.dart';
import 'package:tamajiwa/models/review_comment_model.dart';

Map<String, dynamic> _formJson({List<Map<String, dynamic>>? comments}) => {
      'id': 5,
      'type': 'pengkajian',
      'user_id': 2,
      'patient_id': 3,
      'status': 'revised',
      'data': {'section_1': {'nama_lengkap': 'Budi'}},
      'created_at': '2026-11-20T08:00:00.000000Z',
      'updated_at': '2026-11-21T08:00:00.000000Z',
      if (comments != null) 'review_comments': comments,
    };

void main() {
  test('ReviewComment membaca reviewer dan status selesai', () {
    final c = ReviewComment.fromJson({
      'id': 1,
      'section': 'section_1',
      'comment': 'Lengkapi identitas',
      'reviewer': {'id': 9, 'name': 'Dr. Ani'},
      'created_at': '2026-11-21T08:00:00.000000Z',
      'resolved_at': null,
    });
    expect(c.reviewerName, 'Dr. Ani');
    expect(c.isResolved, isFalse);

    final done = c.copyWith(resolvedAt: DateTime(2026, 11, 22));
    expect(done.isResolved, isTrue);
    expect(done.copyWith(clearResolved: true).isResolved, isFalse);
  });

  test('FormModel memuat review_comments dan tahan bila tidak ada', () {
    final withComments = FormModel.fromJson(_formJson(comments: [
      {'id': 1, 'section': 'section_1', 'comment': 'a', 'resolved_at': null},
      {'id': 2, 'section': null, 'comment': 'umum', 'resolved_at': '2026-11-22T00:00:00Z'},
    ]));
    expect(withComments.reviewComments, hasLength(2));
    expect(withComments.reviewComments.first.section, 'section_1');
    expect(withComments.reviewComments.last.isResolved, isTrue);

    final without = FormModel.fromJson(_formJson());
    expect(without.reviewComments, isEmpty);
  });

  test('copyWith mempertahankan komentar bila tidak diganti', () {
    final f = FormModel.fromJson(_formJson(comments: [
      {'id': 1, 'comment': 'a'},
    ]));
    expect(f.copyWith(status: 'approved').reviewComments, hasLength(1));
  });
}
