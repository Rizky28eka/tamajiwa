/// Komentar review dari dosen pada satu bagian formulir (atau umum bila
/// [section] null).
class ReviewComment {
  final int id;
  final String? section;
  final String comment;
  final String? reviewerName;
  final DateTime? createdAt;
  final DateTime? resolvedAt;

  const ReviewComment({
    required this.id,
    required this.comment,
    this.section,
    this.reviewerName,
    this.createdAt,
    this.resolvedAt,
  });

  bool get isResolved => resolvedAt != null;

  factory ReviewComment.fromJson(Map<String, dynamic> json) {
    return ReviewComment(
      id: json['id'] as int,
      section: json['section'] as String?,
      comment: (json['comment'] ?? '').toString(),
      reviewerName: (json['reviewer'] is Map)
          ? json['reviewer']['name'] as String?
          : null,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      resolvedAt: DateTime.tryParse(json['resolved_at']?.toString() ?? ''),
    );
  }

  ReviewComment copyWith({DateTime? resolvedAt, bool clearResolved = false}) {
    return ReviewComment(
      id: id,
      section: section,
      comment: comment,
      reviewerName: reviewerName,
      createdAt: createdAt,
      resolvedAt: clearResolved ? null : (resolvedAt ?? this.resolvedAt),
    );
  }
}
