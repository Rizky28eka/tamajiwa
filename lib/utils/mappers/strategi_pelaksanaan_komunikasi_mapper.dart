class StrategiPelaksanaanKomunikasiMapper {
  static Map<String, dynamic> map(Map<String, dynamic> formData) {
    final result = <String, dynamic>{};

    // Basic form information
    if (formData['patient_id'] != null) {
      result['patient_id'] = formData['patient_id'];
    }
    if (formData['status'] != null) {
      result['status'] = formData['status'];
    }

    // A. Proses Keperawatan
    if (formData['kondisi_klien'] != null) {
      result['kondisi_klien'] = formData['kondisi_klien'];
    }
    if (formData['diagnosa_keperawatan'] != null) {
      result['diagnosa_keperawatan'] = formData['diagnosa_keperawatan'];
    }
    if (formData['tujuan'] != null) {
      result['tujuan'] = formData['tujuan'];
    }
    if (formData['tindakan_keperawatan'] != null) {
      result['tindakan_keperawatan'] = _toIntList(
        formData['tindakan_keperawatan'],
      );
    }

    // B. Strategi Komunikasi - Fase Orientasi
    if (formData['salam_terapeutik'] != null) {
      result['salam_terapeutik'] = formData['salam_terapeutik'];
    }
    if (formData['evaluasi_validasi'] != null) {
      result['evaluasi_validasi'] = formData['evaluasi_validasi'];
    }
    if (formData['kontrak_orientasi'] != null) {
      result['kontrak_orientasi'] = formData['kontrak_orientasi'];
    }
    if (formData['menjaga_kerahasiaan'] != null) {
      result['menjaga_kerahasiaan'] = formData['menjaga_kerahasiaan'];
    }

    // B. Strategi Komunikasi - Fase Kerja
    if (formData['fase_kerja'] != null) {
      result['fase_kerja'] = formData['fase_kerja'];
    }

    // B. Strategi Komunikasi - Fase Terminasi
    if (formData['evaluasi_subjektif'] != null) {
      result['evaluasi_subjektif'] = formData['evaluasi_subjektif'];
    }
    if (formData['evaluasi_objektif'] != null) {
      result['evaluasi_objektif'] = formData['evaluasi_objektif'];
    }
    if (formData['rencana_tindak_lanjut'] != null) {
      result['rencana_tindak_lanjut'] = formData['rencana_tindak_lanjut'];
    }
    if (formData['kontrak_terminasi'] != null) {
      result['kontrak_terminasi'] = formData['kontrak_terminasi'];
    }

    return result;
  }

  /// Convert dynamic value to list of integers
  static List<int> _toIntList(dynamic value) {
    if (value is List) {
      return value
          .map((e) => e is int ? e : (e is String ? int.tryParse(e) : null))
          .whereType<int>()
          .toList();
    }
    return [];
  }
}
