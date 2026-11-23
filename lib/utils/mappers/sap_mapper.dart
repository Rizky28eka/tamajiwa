class SapMapper {
  static Map<String, dynamic> map(Map<String, dynamic> formData) {
    final result = <String, dynamic>{};

    // Basic form information
    if (formData['patient_id'] != null) {
      result['patient_id'] = formData['patient_id'];
    }
    if (formData['status'] != null) result['status'] = formData['status'];

    // 1. Identitas SAP
    if (formData['topik'] != null) result['topik'] = formData['topik'];
    if (formData['sub_topik'] != null) {
      result['sub_topik'] = formData['sub_topik'];
    }
    if (formData['pokok_bahasan'] != null) {
      result['sub_topik'] = formData['pokok_bahasan']; // alias
    }
    if (formData['sasaran'] != null) result['sasaran'] = formData['sasaran'];
    if (formData['tanggal_pelaksanaan'] != null) {
      result['tanggal_pelaksanaan'] = formData['tanggal_pelaksanaan'];
    }
    if (formData['hari_tanggal'] != null) {
      result['tanggal_pelaksanaan'] = formData['hari_tanggal']; // alias
    }
    if (formData['waktu_pelaksanaan'] != null) {
      result['waktu_pelaksanaan'] = formData['waktu_pelaksanaan'];
    }
    if (formData['waktu'] != null) {
      result['waktu_pelaksanaan'] = formData['waktu']; // alias
    }
    if (formData['tempat'] != null) result['tempat'] = formData['tempat'];
    if (formData['durasi'] != null) result['durasi'] = formData['durasi'];

    // 2. Tujuan
    if (formData['tujuan_umum'] != null) {
      result['tujuan_umum'] = formData['tujuan_umum'];
    }
    if (formData['tujuan_khusus'] != null) {
      result['tujuan_khusus'] = formData['tujuan_khusus'];
    }

    // 3. Materi
    if (formData['materi'] != null) {
      result['materi_penyuluhan'] = formData['materi']; // name mapping
    }
    if (formData['materi_penyuluhan'] != null) {
      result['materi_penyuluhan'] = formData['materi_penyuluhan'];
    }

    // 4. Metode & Media - convert string to array for backend
    if (formData['metode'] != null) {
      result['metode'] = _toStringList(formData['metode']);
    }
    if (formData['media'] != null) {
      result['media'] = _toStringList(formData['media']);
    }

    // A. Kegiatan Penyuluhan - Alokasi Waktu Detail
    if (formData['waktu_pembukaan'] != null) {
      result['waktu_pembukaan'] = formData['waktu_pembukaan'];
    }
    if (formData['waktu_penyampaian_materi'] != null) {
      result['waktu_penyampaian_materi'] = formData['waktu_penyampaian_materi'];
    }
    if (formData['waktu_tanya_jawab'] != null) {
      result['waktu_tanya_jawab'] = formData['waktu_tanya_jawab'];
    }
    if (formData['waktu_penutup'] != null) {
      result['waktu_penutup'] = formData['waktu_penutup'];
    }

    // A. Kegiatan Penyuluhan - Table Kegiatan
    if (formData['tabel_kegiatan'] != null) {
      result['kegiatan'] =
          formData['tabel_kegiatan']; // already in correct format
    }
    if (formData['kegiatan'] != null) {
      result['kegiatan'] = formData['kegiatan'];
    }

    // 6. Perincian Tugas (Joblist) - convert to arrays
    if (formData['joblist_penyuluh'] != null) {
      result['joblist_penyuluh'] = _toStringList(formData['joblist_penyuluh']);
    }
    if (formData['joblist_moderator'] != null) {
      result['joblist_moderator'] = _toStringList(
        formData['joblist_moderator'],
      );
    }
    if (formData['joblist_fasilitator'] != null) {
      result['joblist_fasilitator'] = _toStringList(
        formData['joblist_fasilitator'],
      );
    }
    if (formData['joblist_time_keeper'] != null) {
      result['joblist_time_keeper'] = _toStringList(
        formData['joblist_time_keeper'],
      );
    }
    if (formData['joblist_dokumentator'] != null) {
      result['joblist_dokumentator'] = _toStringList(
        formData['joblist_dokumentator'],
      );
    }
    if (formData['joblist_observer'] != null) {
      result['joblist_observer'] = _toStringList(formData['joblist_observer']);
    }

    // 7. Pengorganisasian (Team Members)
    if (formData['penyaji'] != null) result['penyaji'] = formData['penyaji'];
    if (formData['penyuluh'] != null) {
      result['penyaji'] = formData['penyuluh']; // alias
    }
    if (formData['moderator'] != null) {
      result['moderator'] = formData['moderator'];
    }
    if (formData['fasilitator'] != null) {
      result['fasilitator'] = formData['fasilitator'];
    }
    if (formData['time_keeper'] != null) {
      result['time_keeper'] = formData['time_keeper'];
    }
    if (formData['dokumentator'] != null) {
      result['dokumentator'] = formData['dokumentator'];
    }
    if (formData['observer'] != null) result['observer'] = formData['observer'];

    // B. Evaluasi
    if (formData['evaluasi_input'] != null) {
      result['evaluasi_input'] = formData['evaluasi_input'];
    }
    if (formData['evaluasi_struktur'] != null) {
      result['evaluasi_input'] =
          formData['evaluasi_struktur']; // old field name
    }
    if (formData['evaluasi_proses'] != null) {
      result['evaluasi_proses'] = formData['evaluasi_proses'];
    }
    if (formData['evaluasi_hasil'] != null) {
      result['evaluasi_hasil'] = formData['evaluasi_hasil'];
    }

    // C. Lampiran
    if (formData['daftar_pustaka'] != null) {
      result['daftar_pustaka'] = formData['daftar_pustaka'];
    }
    // File paths handled by upload endpoints
    if (formData['materi_file_path'] != null) {
      result['materi_file_path'] = formData['materi_file_path'];
    }
    if (formData['dokumentasi_foto_path'] != null) {
      result['dokumentasi_foto_path'] = formData['dokumentasi_foto_path'];
    }
    if (formData['setting_tempat_file_path'] != null) {
      result['setting_tempat_file_path'] = formData['setting_tempat_file_path'];
    }

    // D. Hasil Evaluasi Penyuluhan - Info Pelaksanaan
    if (formData['hasil_hari_tanggal'] != null) {
      result['hasil_hari_tanggal'] = formData['hasil_hari_tanggal'];
    }
    if (formData['hasil_waktu'] != null) {
      result['hasil_waktu'] = formData['hasil_waktu'];
    }
    if (formData['hasil_sasaran'] != null) {
      result['hasil_sasaran'] = formData['hasil_sasaran'];
    }
    if (formData['hasil_moderator'] != null) {
      result['hasil_moderator'] = formData['hasil_moderator'];
    }
    if (formData['hasil_penyaji'] != null) {
      result['hasil_penyaji'] = formData['hasil_penyaji'];
    }
    if (formData['hasil_observer'] != null) {
      result['hasil_observer'] = formData['hasil_observer'];
    }
    if (formData['hasil_fasilitator'] != null) {
      result['hasil_fasilitator'] = formData['hasil_fasilitator'];
    }
    if (formData['hasil_time_keeper'] != null) {
      result['hasil_time_keeper'] = formData['hasil_time_keeper'];
    }
    if (formData['hasil_dokumentator'] != null) {
      result['hasil_dokumentator'] = formData['hasil_dokumentator'];
    }
    if (formData['hasil_media'] != null) {
      result['hasil_media'] = formData['hasil_media'];
    }

    // D. Hasil Evaluasi - Checklists (JSON arrays)
    if (formData['hasil_evaluasi_input'] != null) {
      result['hasil_evaluasi_input'] = formData['hasil_evaluasi_input'];
    }
    if (formData['hasil_evaluasi_proses'] != null) {
      result['hasil_evaluasi_proses'] = formData['hasil_evaluasi_proses'];
    }
    if (formData['hasil_evaluasi_seluruh'] != null) {
      result['hasil_evaluasi_seluruh'] = formData['hasil_evaluasi_seluruh'];
    }

    // D. Feedback dari Peserta
    if (formData['pertanyaan_peserta'] != null) {
      result['pertanyaan_peserta'] = _toStringList(
        formData['pertanyaan_peserta'],
      );
    }
    if (formData['saran_peserta'] != null) {
      result['saran_peserta'] = _toStringList(formData['saran_peserta']);
    }

    return result;
  }

  /// Convert dynamic value to list of strings
  static List<String> _toStringList(dynamic value) {
    if (value is List) return value.map((e) => e.toString()).toList();
    if (value is String) {
      return value
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();
    }
    return [];
  }
}
