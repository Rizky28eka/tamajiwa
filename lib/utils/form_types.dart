import 'package:flutter/material.dart';

/// Satu sumber kebenaran untuk judul dan ikon tiap jenis formulir.
class FormTypes {
  FormTypes._();

  static const _titles = <String, String>{
    'pengkajian': 'Pengkajian Kesehatan Jiwa',
    'resume_kegawatdaruratan': 'Resume Kegawatdaruratan',
    'resume_poliklinik': 'Resume Poliklinik',
    'sap': 'Satuan Acara Penyuluhan (SAP)',
    'terapi_aktivitas_kelompok': 'Terapi Aktivitas Kelompok',
    'strategi_pelaksanaan_komunikasi': 'Strategi Pelaksanaan Komunikasi',
    'catatan_tambahan': 'Catatan Tambahan',
  };

  static const _icons = <String, IconData>{
    'pengkajian': Icons.medical_information_rounded,
    'resume_kegawatdaruratan': Icons.emergency_rounded,
    'resume_poliklinik': Icons.local_hospital_rounded,
    'sap': Icons.school_rounded,
    'terapi_aktivitas_kelompok': Icons.group_work_rounded,
    'strategi_pelaksanaan_komunikasi': Icons.chat_bubble_outline_rounded,
    'catatan_tambahan': Icons.note_add_rounded,
  };

  static String title(String? type) => _titles[type] ?? 'Formulir';

  static IconData icon(String? type) =>
      _icons[type] ?? Icons.description_rounded;
}
