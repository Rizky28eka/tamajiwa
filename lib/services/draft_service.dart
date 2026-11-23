import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'logger_service.dart';

/// Menyimpan draf formulir di perangkat agar isian tidak hilang
/// saat sinyal putus, aplikasi tertutup, atau pengguna kembali tanpa sengaja.
class DraftService {
  DraftService._();

  static const _prefix = 'form_draft_v1:';
  static const _dateTag = '__dt';

  static String keyFor(String formType, int patientId) =>
      '$_prefix$formType:$patientId';

  /// Ubah nilai formulir menjadi struktur yang aman untuk JSON.
  /// Nilai yang tidak dikenali (mis. File) dibuang, bukan membuat gagal.
  static dynamic encode(dynamic v) {
    if (v == null || v is String || v is num || v is bool) return v;
    if (v is DateTime) return {_dateTag: v.toIso8601String()};
    if (v is Map) {
      final out = <String, dynamic>{};
      v.forEach((k, val) {
        final e = encode(val);
        if (e != _drop) out[k.toString()] = e;
      });
      return out;
    }
    if (v is Iterable) {
      final out = <dynamic>[];
      for (final item in v) {
        final e = encode(item);
        if (e != _drop) out.add(e);
      }
      return out;
    }
    return _drop;
  }

  static const _drop = _Drop();

  static dynamic decode(dynamic v) {
    if (v is Map) {
      if (v.length == 1 && v[_dateTag] is String) {
        return DateTime.tryParse(v[_dateTag] as String);
      }
      return v.map((k, val) => MapEntry(k.toString(), decode(val)));
    }
    if (v is List) return v.map(decode).toList();
    return v;
  }

  static Future<void> save(
      String formType, int patientId, Map<String, dynamic> values) async {
    try {
      final encoded = encode(values) as Map;
      if (encoded.isEmpty) return;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        keyFor(formType, patientId),
        json.encode({
          'saved_at': DateTime.now().toIso8601String(),
          'values': encoded,
        }),
      );
    } catch (e) {
      LoggerService().error('Gagal menyimpan draf', error: e);
    }
  }

  /// Mengembalikan draf beserta waktu penyimpanannya, atau null.
  static Future<DraftSnapshot?> load(String formType, int patientId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(keyFor(formType, patientId));
      if (raw == null) return null;
      final map = json.decode(raw) as Map<String, dynamic>;
      final values = decode(map['values']);
      if (values is! Map<String, dynamic> || values.isEmpty) return null;
      return DraftSnapshot(
        values: values,
        savedAt: DateTime.tryParse(map['saved_at']?.toString() ?? ''),
      );
    } catch (e) {
      LoggerService().error('Gagal membaca draf', error: e);
      return null;
    }
  }

  static Future<void> clear(String formType, int patientId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(keyFor(formType, patientId));
    } catch (_) {}
  }
}

class DraftSnapshot {
  final Map<String, dynamic> values;
  final DateTime? savedAt;
  const DraftSnapshot({required this.values, this.savedAt});
}

class _Drop {
  const _Drop();
}
