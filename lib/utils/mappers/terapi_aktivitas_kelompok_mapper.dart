class TerapiAktivitasKelompokMapper {
  static Map<String, dynamic> map(Map<String, dynamic> formData) {
    final result = <String, dynamic>{};

    // Basic form information
    if (formData['patient_id'] != null) {
      result['patient_id'] = formData['patient_id'];
    }
    if (formData['status'] != null) {
      result['status'] = formData['status'];
    }

    // A. Latar Belakang
    if (formData['latar_belakang'] != null) {
      result['latar_belakang'] = formData['latar_belakang'];
    }

    // B. Tujuan
    if (formData['tujuan_umum'] != null) {
      result['tujuan_umum'] = formData['tujuan_umum'];
    }
    if (formData['tujuan_khusus'] != null) {
      result['tujuan_khusus'] = formData['tujuan_khusus'];
    }

    // C. Persiapan Klien
    if (formData['karakteristik_klien'] != null) {
      result['karakteristik_klien'] = formData['karakteristik_klien'];
    }
    if (formData['proses_seleksi_klien'] != null) {
      result['proses_seleksi_klien'] = formData['proses_seleksi_klien'];
    }

    // D. Pengorganisasian
    if (formData['leader_sesi_1'] != null) {
      result['leader_sesi_1'] = formData['leader_sesi_1'];
    }
    if (formData['leader_sesi_2'] != null) {
      result['leader_sesi_2'] = formData['leader_sesi_2'];
    }
    if (formData['uraian_tugas_leader'] != null) {
      result['uraian_tugas_leader'] = formData['uraian_tugas_leader'];
    }
    if (formData['observer_fasilitator_sesi_1'] != null) {
      result['observer_fasilitator_sesi_1'] =
          formData['observer_fasilitator_sesi_1'];
    }
    if (formData['observer_fasilitator_sesi_2'] != null) {
      result['observer_fasilitator_sesi_2'] =
          formData['observer_fasilitator_sesi_2'];
    }
    if (formData['uraian_tugas_observer'] != null) {
      result['uraian_tugas_observer'] = formData['uraian_tugas_observer'];
    }

    // a. Jadwal Pelaksanaan
    if (formData['hari_tanggal'] != null) {
      result['hari_tanggal'] = formData['hari_tanggal'];
    }
    if (formData['waktu'] != null) {
      result['waktu'] = formData['waktu'];
    }
    if (formData['alokasi_waktu'] != null) {
      result['alokasi_waktu'] = formData['alokasi_waktu'];
    }
    if (formData['sasaran'] != null) {
      result['sasaran'] = formData['sasaran'];
    }
    if (formData['tempat'] != null) {
      result['tempat'] = formData['tempat'];
    }

    // b. Setting Tempat
    if (formData['keterangan_setting'] != null) {
      result['keterangan_setting'] = formData['keterangan_setting'];
    }
    if (formData['leader'] != null) {
      result['leader'] = formData['leader'];
    }
    if (formData['observer_fasilitator'] != null) {
      result['observer_fasilitator'] = formData['observer_fasilitator'];
    }
    if (formData['peserta'] != null) {
      result['peserta'] = formData['peserta'];
    }
    if (formData['pembimbing'] != null) {
      result['pembimbing'] = formData['pembimbing'];
    }

    // c. Alat & e. Metode
    if (formData['alat'] != null) {
      result['alat'] = formData['alat'];
    }
    if (formData['metode'] != null) {
      result['metode'] = formData['metode'];
    }

    // 4. Proses Pelaksanaan TAK - Sesi 1-5
    for (int i = 1; i <= 5; i++) {
      final prefix = 'sesi_$i';

      if (formData['${prefix}_persiapan'] != null) {
        result['${prefix}_persiapan'] = formData['${prefix}_persiapan'];
      }

      // Fase Orientasi
      if (formData['${prefix}_salam_terapeutik'] != null) {
        result['${prefix}_salam_terapeutik'] =
            formData['${prefix}_salam_terapeutik'];
      }
      if (formData['${prefix}_evaluasi_validasi'] != null) {
        result['${prefix}_evaluasi_validasi'] =
            formData['${prefix}_evaluasi_validasi'];
      }
      if (formData['${prefix}_kontrak'] != null) {
        result['${prefix}_kontrak'] = formData['${prefix}_kontrak'];
      }

      // Fase Kerja
      if (formData['${prefix}_fase_kerja'] != null) {
        result['${prefix}_fase_kerja'] = formData['${prefix}_fase_kerja'];
      }

      // Fase Terminasi
      if (formData['${prefix}_evaluasi_terminasi'] != null) {
        result['${prefix}_evaluasi_terminasi'] =
            formData['${prefix}_evaluasi_terminasi'];
      }
      if (formData['${prefix}_tindak_lanjut'] != null) {
        result['${prefix}_tindak_lanjut'] = formData['${prefix}_tindak_lanjut'];
      }
      if (formData['${prefix}_kontrak_datang'] != null) {
        result['${prefix}_kontrak_datang'] =
            formData['${prefix}_kontrak_datang'];
      }
    }

    // Evaluasi Keseluruhan
    if (formData['evaluasi'] != null) {
      result['evaluasi'] = formData['evaluasi'];
    }

    // Daftar Pustaka
    if (formData['daftar_pustaka'] != null) {
      result['daftar_pustaka'] = formData['daftar_pustaka'];
    }

    return result;
  }
}
