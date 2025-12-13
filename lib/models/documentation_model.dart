class DocumentationModel {
  final int id;
  final int formId;
  final String filePath;
  final String type;
  final DateTime createdAt;
  final DateTime updatedAt;

  DocumentationModel({
    required this.id,
    required this.formId,
    required this.filePath,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DocumentationModel.fromJson(Map<String, dynamic> json) {
    return DocumentationModel(
      id: json['id'],
      formId: json['form_id'],
      filePath: json['file_path'],
      type: json['type'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'form_id': formId,
      'file_path': filePath,
      'type': type,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
