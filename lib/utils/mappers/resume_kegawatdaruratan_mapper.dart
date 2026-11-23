class ResumeKegawatdaruratanMapper {
  static Map<String, dynamic> map(Map<String, dynamic> formData) {
    final result = <String, dynamic>{};

    // Basic form information
    if (formData['patient_id'] != null) {
      result['patient_id'] = formData['patient_id'];
    }
    if (formData['status'] != null) result['status'] = formData['status'];

    // Identitas section
    if (formData['nama_lengkap'] != null) {
      result['nama_pasien'] = formData['nama_lengkap']; // name mapping
    }
    if (formData['no_rm'] != null) result['no_rm'] = formData['no_rm'];
    if (formData['tanggal_masuk'] != null) {
      result['tanggal_masuk'] = formData['tanggal_masuk'];
    }
    if (formData['jam_masuk'] != null) {
      result['jam_masuk'] = formData['jam_masuk'];
    }
    if (formData['tanggal_keluar'] != null) {
      result['tanggal_keluar'] = formData['tanggal_keluar'];
    }
    if (formData['jam_keluar'] != null) {
      result['jam_keluar'] = formData['jam_keluar'];
    }

    // Anamnesis section
    if (formData['keluhan_utama'] != null) {
      result['keluhan_utama'] = formData['keluhan_utama'];
    }
    if (formData['riwayat_penyakit_sekarang'] != null) {
      result['riwayat_penyakit_sekarang'] =
          formData['riwayat_penyakit_sekarang'];
    }
    if (formData['riwayat_penyakit_dahulu'] != null) {
      result['riwayat_penyakit_dahulu'] = formData['riwayat_penyakit_dahulu'];
    }
    if (formData['riwayat_pengobatan'] != null) {
      result['riwayat_pengobatan'] = formData['riwayat_pengobatan'];
    }
    if (formData['faktor_pencetus'] != null) {
      result['faktor_pencetus'] = formData['faktor_pencetus'];
    }

    // Pemeriksaan Fisik section
    if (formData['keadaan_umum'] != null) {
      result['keadaan_umum'] = formData['keadaan_umum'];
    }
    if (formData['tanda_vital'] != null) {
      result['tanda_vital'] = formData['tanda_vital'];
    }
    if (formData['kesadaran'] != null) {
      result['kesadaran'] = formData['kesadaran'];
    }
    if (formData['gcs'] != null) result['gcs'] = formData['gcs'];
    if (formData['tekanan_darah'] != null) {
      result['tekanan_darah'] = formData['tekanan_darah'];
    }
    if (formData['nadi'] != null) result['nadi'] = formData['nadi'];
    if (formData['suhu'] != null) result['suhu'] = formData['suhu'];
    if (formData['pernapasan'] != null) {
      result['pernapasan'] = formData['pernapasan'];
    }
    if (formData['spo2'] != null) result['spo2'] = formData['spo2'];
    if (formData['pemeriksaan_lain'] != null) {
      result['pemeriksaan_lain'] = formData['pemeriksaan_lain'];
    }

    // Status Mental section
    if (formData['penampilan'] != null) {
      result['penampilan'] = formData['penampilan'];
    }
    if (formData['perilaku'] != null) result['perilaku'] = formData['perilaku'];
    if (formData['pembicaraan'] != null) {
      result['pembicaraan'] = formData['pembicaraan'];
    }
    if (formData['mood_afek'] != null) {
      result['mood_afek'] = formData['mood_afek'];
    }
    if (formData['pikiran'] != null) result['pikiran'] = formData['pikiran'];
    if (formData['persepsi'] != null) result['persepsi'] = formData['persepsi'];
    if (formData['kognitif'] != null) result['kognitif'] = formData['kognitif'];
    if (formData['orientasi'] != null) {
      result['orientasi'] = formData['orientasi'];
    }
    if (formData['bentuk_pemikiran'] != null) {
      result['bentuk_pemikiran'] = formData['bentuk_pemikiran'];
    }
    if (formData['isi_pemikiran'] != null) {
      result['isi_pemikiran'] = formData['isi_pemikiran'];
    }

    // Diagnosis & Tindakan section
    if (formData['diagnosis_utama'] != null) {
      result['diagnosis_kerja'] = formData['diagnosis_utama']; // name mapping
    }
    if (formData['diagnosis_banding'] != null) {
      result['diagnosis_banding'] = formData['diagnosis_banding'];
    }
    if (formData['diagnosis_tambahan'] != null) {
      result['diagnosis_tambahan'] = formData['diagnosis_tambahan'];
    }
    if (formData['tindakan_medis'] != null) {
      result['tindakan_yang_dilakukan'] =
          formData['tindakan_medis']; // name mapping
    }
    if (formData['tindakan_keperawatan'] != null) {
      result['tindakan_keperawatan'] = formData['tindakan_keperawatan'];
    }
    if (formData['terapi_psikososial'] != null) {
      result['terapi_psikososial'] = formData['terapi_psikososial'];
    }
    if (formData['terapi_obat'] != null) {
      result['terapi_obat'] = formData['terapi_obat'];
    }

    // Section 7: Implementasi
    if (formData['pelaksanaan_intervensi'] != null) {
      result['pelaksanaan_intervensi'] = formData['pelaksanaan_intervensi'];
    }
    if (formData['kolaborasi_tim'] != null) {
      result['kolaborasi_tim'] = formData['kolaborasi_tim'];
    }
    if (formData['edukasi'] != null) result['edukasi'] = formData['edukasi'];

    // Section 8: Evaluasi
    if (formData['respon_intervensi'] != null) {
      result['respon_intervensi'] = formData['respon_intervensi'];
    }
    if (formData['perubahan_klinis'] != null) {
      result['perubahan_klinis'] = formData['perubahan_klinis'];
    }
    if (formData['tujuan_tercapai'] != null) {
      result['tujuan_tercapai'] = formData['tujuan_tercapai'];
    }
    if (formData['hambatan_perawatan'] != null) {
      result['hambatan_perawatan'] = formData['hambatan_perawatan'];
    }

    // Kondisi Keluar - CRITICAL FIX!
    if (formData['kondisi_keluar'] != null) {
      result['kondisi_keluar'] = formData['kondisi_keluar'];
    }

    // Section 9: Rencana Lanjut
    if (formData['rencana_medis'] != null) {
      result['anjuran'] = formData['rencana_medis']; // name mapping
    }
    if (formData['rencana_keperawatan'] != null) {
      result['rencana_keperawatan'] = formData['rencana_keperawatan'];
    }
    if (formData['rencana_pemantauan'] != null) {
      result['rencana_pemantauan'] = formData['rencana_pemantauan'];
    }

    // Section 10: Rencana dengan Keluarga
    if (formData['keterlibatan_keluarga'] != null) {
      result['keterlibatan_keluarga'] = formData['keterlibatan_keluarga'];
    }
    if (formData['edukasi_keluarga'] != null) {
      result['edukasi_keluarga'] = formData['edukasi_keluarga'];
    }
    if (formData['dukungan_keluarga'] != null) {
      result['dukungan_keluarga'] = formData['dukungan_keluarga'];
    }

    // Section 11: Renpra (nursing care plan) - Convert to JSON
    if (formData['diagnosis'] != null) {
      result['renpra'] = {
        'diagnosis': formData['diagnosis'],
        'intervensi': formData['intervensi'],
        'tujuan': formData['tujuan'],
        'kriteria': formData['kriteria'],
        'rasional': formData['rasional'],
        'evaluasi_renpra': formData['evaluasi_renpra'],
      };
    }

    return result;
  }
}
