/// Notifikasi dalam aplikasi (mis. formulir diajukan, disetujui, perlu revisi).
class AppNotification {
  final int id;
  final String type;
  final String title;
  final String? body;
  final int? formId;
  final DateTime? createdAt;
  final DateTime? readAt;

  const AppNotification({
    required this.id,
    required this.type,
    required this.title,
    this.body,
    this.formId,
    this.createdAt,
    this.readAt,
  });

  bool get isRead => readAt != null;

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as int,
      type: (json['type'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      body: json['body'] as String?,
      formId: json['form_id'] as int?,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
      readAt: DateTime.tryParse(json['read_at']?.toString() ?? ''),
    );
  }

  AppNotification asRead() => AppNotification(
        id: id,
        type: type,
        title: title,
        body: body,
        formId: formId,
        createdAt: createdAt,
        readAt: readAt ?? DateTime.now(),
      );
}
