import 'genogram_model.dart';
import 'user_model.dart';
import 'patient_model.dart';
import 'pengkajian_form_model.dart';
import 'resume_kegawatdaruratan_form_model.dart';
import 'resume_poliklinik_form_model.dart';
import 'sap_form_model.dart';
import 'catatan_tambahan_form_model.dart';
import 'documentation_model.dart';
import 'review_comment_model.dart';

class FormUser {
  final int id;
  final String name;

  FormUser({required this.id, required this.name});

  factory FormUser.fromJson(Map<String, dynamic> json) {
    return FormUser(id: json['id'], name: json['name']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

class FormPatient {
  final int id;
  final String name;

  FormPatient({required this.id, required this.name});

  factory FormPatient.fromJson(Map<String, dynamic> json) {
    return FormPatient(id: json['id'], name: json['name']);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

class FormModel {
  final int id;
  final String type;
  final int userId;
  final int patientId;
  final String status;
  final int? score;
  final Map<String, dynamic>? data;
  final DateTime createdAt;
  final DateTime updatedAt;
  final GenogramModel? genogram;
  final UserModel? user;
  final Patient? patient;
  final String? comments;

  // Polymorphic fields
  final String? formableType;
  final int? formableId;
  final dynamic formable;
  final List<DocumentationModel>? documentations;
  final List<ReviewComment> reviewComments;

  FormModel({
    required this.id,
    required this.type,
    required this.userId,
    required this.patientId,
    required this.status,
    this.score,
    this.data,
    required this.createdAt,
    required this.updatedAt,
    this.genogram,
    this.user,
    this.patient,
    this.comments,
    this.formableType,
    this.formableId,
    this.formable,
    this.documentations,
    this.reviewComments = const [],
  });

  factory FormModel.fromJson(Map<String, dynamic> json) {
    dynamic formableData;
    if (json['formable'] != null) {
      final formableType = json['formable_type'];
      if (formableType != null) {
        if (formableType.contains('PengkajianForm')) {
          formableData = PengkajianFormModel.fromJson(json['formable']);
        } else if (formableType.contains('ResumeKegawatdaruratanForm')) {
          formableData = ResumeKegawatdaruratanFormModel.fromJson(
            json['formable'],
          );
        } else if (formableType.contains('ResumePoliklinikForm')) {
          formableData = ResumePoliklinikFormModel.fromJson(json['formable']);
        } else if (formableType.contains('SapForm')) {
          formableData = SapFormModel.fromJson(json['formable']);
        } else if (formableType.contains('CatatanTambahanForm')) {
          formableData = CatatanTambahanFormModel.fromJson(json['formable']);
        } else {
          formableData = json['formable'];
        }
      } else {
        formableData = json['formable'];
      }
    }

    return FormModel(
      id: json['id'],
      type: json['type'],
      userId: json['user_id'],
      patientId: json['patient_id'],
      status: json['status'],
      score: (json['score'] as num?)?.toInt(),
      data: json['data'] != null && json['data'] is Map
          ? Map<String, dynamic>.from(json['data'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      genogram: json['genogram'] != null
          ? GenogramModel.fromJson(json['genogram'])
          : null,
      user: json['user'] != null ? UserModel.fromJson(json['user']) : null,
      patient: json['patient'] != null
          ? Patient.fromJson(json['patient'])
          : null,
      comments: json['comments'],
      formableType: json['formable_type'],
      formableId: json['formable_id'],
      formable: formableData,
      documentations: json['documentations'] != null
          ? (json['documentations'] as List)
                .map((doc) => DocumentationModel.fromJson(doc))
                .toList()
          : null,
      reviewComments: json['review_comments'] is List
          ? (json['review_comments'] as List)
                .whereType<Map>()
                .map((c) => ReviewComment.fromJson(Map<String, dynamic>.from(c)))
                .toList()
          : const [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'user_id': userId,
      'patient_id': patientId,
      'status': status,
      'score': score,
      'data': data,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'genogram': genogram?.toJson(),
      'user': user?.toJson(),
      'patient': patient?.toJson(),
      'comments': comments,
      'documentations': documentations?.map((doc) => doc.toJson()).toList(),
    };
  }

  FormModel copyWith({
    int? id,
    String? type,
    int? userId,
    int? patientId,
    String? status,
    int? score,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    DateTime? updatedAt,
    GenogramModel? genogram,
    UserModel? user,
    Patient? patient,
    String? comments,
    List<DocumentationModel>? documentations,
    List<ReviewComment>? reviewComments,
  }) {
    return FormModel(
      id: id ?? this.id,
      type: type ?? this.type,
      userId: userId ?? this.userId,
      patientId: patientId ?? this.patientId,
      status: status ?? this.status,
      score: score ?? this.score,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      genogram: genogram ?? this.genogram,
      user: user ?? this.user,
      patient: patient ?? this.patient,
      comments: comments ?? this.comments,
      documentations: documentations ?? this.documentations,
      reviewComments: reviewComments ?? this.reviewComments,
    );
  }
}
