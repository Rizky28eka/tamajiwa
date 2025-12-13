class TerapiAktivitasKelompokReverseMapper {
  static Map<String, dynamic> reverse(Map<String, dynamic> data) {
    final result = <String, dynamic>{};

    // A. Latar Belakang
    result['latar_belakang'] = data['latar_belakang'];

    // B. Tujuan
    result['tujuan_umum'] = data['tujuan_umum'];
    result['tujuan_khusus'] = data['tujuan_khusus'];

    // C. Persiapan Klien
    result['karakteristik_klien'] = data['karakteristik_klien'];
    result['proses_seleksi_klien'] = data['proses_seleksi_klien'];

    // D. Pengorganisasian
    result['leader_sesi_1'] = data['leader_sesi_1'];
    result['leader_sesi_2'] = data['leader_sesi_2'];
    result['uraian_tugas_leader'] = data['uraian_tugas_leader'];
    result['observer_fasilitator_sesi_1'] = data['observer_fasilitator_sesi_1'];
    result['observer_fasilitator_sesi_2'] = data['observer_fasilitator_sesi_2'];
    result['uraian_tugas_observer'] = data['uraian_tugas_observer'];

    // a. Jadwal Pelaksanaan
    result['hari_tanggal'] = data['hari_tanggal'];
    result['waktu'] = data['waktu'];
    result['alokasi_waktu'] = data['alokasi_waktu'];
    result['sasaran'] = data['sasaran'];
    result['tempat'] = data['tempat'];

    // b. Setting Tempat
    result['keterangan_setting'] = data['keterangan_setting'];
    result['leader'] = data['leader'];
    result['observer_fasilitator'] = data['observer_fasilitator'];
    result['peserta'] = data['peserta'];
    result['pembimbing'] = data['pembimbing'];

    // c. Alat & e. Metode
    result['alat'] = data['alat'];
    result['metode'] = data['metode'];

    // 4. Proses Pelaksanaan TAK - Sesi 1-5
    for (int i = 1; i <= 5; i++) {
      final prefix = 'sesi_$i';

      // Persiapan
      result['${prefix}_persiapan'] = data['${prefix}_persiapan'];

      // Fase Orientasi
      result['${prefix}_salam_terapeutik'] = data['${prefix}_salam_terapeutik'];
      result['${prefix}_evaluasi_validasi'] =
          data['${prefix}_evaluasi_validasi'];
      result['${prefix}_kontrak'] = data['${prefix}_kontrak'];

      // Fase Kerja
      result['${prefix}_fase_kerja'] = data['${prefix}_fase_kerja'];

      // Fase Terminasi
      result['${prefix}_evaluasi_terminasi'] =
          data['${prefix}_evaluasi_terminasi'];
      result['${prefix}_tindak_lanjut'] = data['${prefix}_tindak_lanjut'];
      result['${prefix}_kontrak_datang'] = data['${prefix}_kontrak_datang'];
    }

    // Evaluasi Keseluruhan
    result['evaluasi'] = data['evaluasi'];

    // Daftar Pustaka
    result['daftar_pustaka'] = data['daftar_pustaka'];

    return result;
  }
}
