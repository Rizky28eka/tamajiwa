class SapReverseMapper {
  static Map<String, dynamic> reverse(Map<String, dynamic> data) {
    String? joinListToString(dynamic value) {
      if (value is List) {
        return value.whereType<Object>().map((e) => e.toString()).join(', ');
      }
      if (value is String) return value;
      return null;
    }

    return {
      // Identitas SAP
      'topik': data['topik'] ?? data['identitas']?['topik'],
      'sub_topik': data['sub_topik'] ?? data['identitas']?['sub_topik'],
      'sasaran': data['sasaran'] ?? data['identitas']?['sasaran'],
      'tanggal_pelaksanaan':
          data['tanggal_pelaksanaan'] ??
          data['identitas']?['tanggal_pelaksanaan'],
      'waktu_pelaksanaan':
          data['waktu_pelaksanaan'] ??
          data['identitas']?['waktu_pelaksanaan'] ??
          data['identitas']?['waktu'],
      'tempat': data['tempat'] ?? data['identitas']?['tempat'],
      'durasi': data['durasi'] ?? data['identitas']?['durasi'],

      // Tujuan
      'tujuan_umum': data['tujuan_umum'] ?? data['tujuan']?['umum'],
      'tujuan_khusus': data['tujuan_khusus'] ?? data['tujuan']?['khusus'],

      // Materi
      'materi':
          data['materi_penyuluhan'] ??
          data['materi'] ??
          data['materi_dan_metode']?['materi'],

      // Metode & Media - convert array to string for frontend
      'metode': joinListToString(
        data['metode'] ?? data['materi_dan_metode']?['metode'],
      ),
      'media': joinListToString(
        data['media'] ?? data['materi_dan_metode']?['media'],
      ),

      // Joblist roles - map back to strings for TextFields
      'joblist_penyuluh': joinListToString(
        data['joblist_penyuluh'] ?? data['joblist']?['penyuluh'],
      ),
      'joblist_moderator': joinListToString(
        data['joblist_moderator'] ?? data['joblist']?['moderator'],
      ),
      'joblist_fasilitator': joinListToString(
        data['joblist_fasilitator'] ?? data['joblist']?['fasilitator'],
      ),
      'joblist_time_keeper': joinListToString(
        data['joblist_time_keeper'] ?? data['joblist']?['time_keeper'],
      ),
      'joblist_dokumentator': joinListToString(
        data['joblist_dokumentator'] ?? data['joblist']?['dokumentator'],
      ),
      'joblist_observer': joinListToString(
        data['joblist_observer'] ?? data['joblist']?['observer'],
      ),

      // Pengorganisasian
      'penyaji':
          data['penyaji'] ??
          data['penyuluh'] ??
          data['pengorganisasian']?['penyaji'] ??
          data['pengorganisasian']?['penyuluh'],
      'moderator': data['moderator'] ?? data['pengorganisasian']?['moderator'],
      'fasilitator':
          data['fasilitator'] ?? data['pengorganisasian']?['fasilitator'],
      'time_keeper':
          data['time_keeper'] ?? data['pengorganisasian']?['time_keeper'],
      'dokumentator':
          data['dokumentator'] ?? data['pengorganisasian']?['dokumentator'],
      'observer': data['observer'] ?? data['pengorganisasian']?['observer'],

      // Kegiatan Penyuluhan
      'tabel_kegiatan': data['kegiatan'] ?? data['tabel_kegiatan'] ?? [],

      // Evaluasi
      'evaluasi_input': data['evaluasi_struktur'] ?? data['evaluasi']?['input'],
      'evaluasi_proses': data['evaluasi_proses'] ?? data['evaluasi']?['proses'],
      'evaluasi_hasil': data['evaluasi_hasil'] ?? data['evaluasi']?['hasil'],

      // Feedback
      'pertanyaan_peserta':
          data['pertanyaan_peserta'] ??
          data['pertanyaan'] ??
          data['feedback']?['pertanyaan'],
      'saran_peserta':
          data['saran_peserta'] ?? data['saran'] ?? data['feedback']?['saran'],
    };
  }
}
