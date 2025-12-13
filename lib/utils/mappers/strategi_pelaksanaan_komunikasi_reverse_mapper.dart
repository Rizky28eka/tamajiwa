class StrategiPelaksanaanKomunikasiReverseMapper {
  static Map<String, dynamic> reverse(Map<String, dynamic> data) {
    int? parseId(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      if (value is double) return value.toInt();
      return null;
    }

    List<int> parseIdList(dynamic value) {
      if (value is List) {
        return value
            .map((v) => v is int ? v : (v is String ? int.tryParse(v) : null))
            .whereType<int>()
            .toList();
      }
      return <int>[];
    }

    return {
      // A. Proses Keperawatan
      'kondisi_klien': data['kondisi_klien'],
      'diagnosa_keperawatan': parseId(data['diagnosa_keperawatan']),
      'tujuan': data['tujuan'],
      'tindakan_keperawatan': parseIdList(data['tindakan_keperawatan']),

      // B. Strategi Komunikasi - Fase Orientasi
      'salam_terapeutik': data['salam_terapeutik'],
      'evaluasi_validasi': data['evaluasi_validasi'],
      'kontrak_orientasi': data['kontrak_orientasi'],
      'menjaga_kerahasiaan': data['menjaga_kerahasiaan'],

      // B. Strategi Komunikasi - Fase Kerja
      'fase_kerja': data['fase_kerja'],

      // B. Strategi Komunikasi - Fase Terminasi
      'evaluasi_subjektif': data['evaluasi_subjektif'],
      'evaluasi_objektif': data['evaluasi_objektif'],
      'rencana_tindak_lanjut': data['rencana_tindak_lanjut'],
      'kontrak_terminasi': data['kontrak_terminasi'],
    };
  }
}
