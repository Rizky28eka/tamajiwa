import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';

class ApiConfig {
  /// Urutan prioritas alamat API:
  ///
  /// 1. Alamat yang dimasukkan pengguna di layar Setup Server (disimpan di perangkat).
  /// 2. `--dart-define=API_BASE_URL=https://api.contoh.id/api` saat build.
  /// 3. Backend lokal (`php artisan serve`): emulator Android lewat 10.0.2.2,
  ///    platform lain lewat 127.0.0.1.
  static const String _fromEnvironment = String.fromEnvironment('API_BASE_URL');
  static const String _prefsKey = 'api_base_url';

  /// Alamat yang disimpan pengguna; null bila belum diatur.
  static String? _saved;

  /// Muat alamat tersimpan. Panggil sekali di `main()` sebelum memakai API.
  static Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      _saved = raw == null ? null : normalize(raw);
    } catch (_) {
      _saved = null;
    }
  }

  /// Simpan alamat API. Mengembalikan alamat yang sudah dinormalisasi,
  /// atau null (dan tidak menyimpan apa pun) bila input tidak valid.
  static Future<String?> save(String input) async {
    final normalized = normalize(input);
    if (normalized == null) return null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, normalized);
    _saved = normalized;
    return normalized;
  }

  /// Hapus alamat tersimpan; kembali ke define/bawaan.
  static Future<void> reset() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
    _saved = null;
  }

  /// Apakah alamat sudah ditentukan (disimpan pengguna atau lewat define).
  static bool get isConfigured => _saved != null || _fromEnvironment.isNotEmpty;

  /// Rapikan input pengguna menjadi alamat dasar API, atau null bila tidak valid.
  ///
  /// - spasi dan garis miring penutup dibuang
  /// - tanpa skema: `http://` untuk localhost/IP/`.local`, selain itu `https://`
  /// - tanpa path: ditambah `/api` (mis. `https://api.contoh.id` -> `.../api`)
  static String? normalize(String input) {
    var text = input.trim();
    if (text.isEmpty || text.contains(RegExp(r'\s'))) return null;

    if (!text.contains('://')) {
      final host = text.split(RegExp(r'[/:?#]')).first;
      final local = host == 'localhost' ||
          host.endsWith('.local') ||
          RegExp(r'^\d{1,3}(\.\d{1,3}){3}$').hasMatch(host);
      text = '${local ? 'http' : 'https'}://$text';
    }

    final uri = Uri.tryParse(text);
    if (uri == null ||
        (uri.scheme != 'http' && uri.scheme != 'https') ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment) {
      return null;
    }

    var path = uri.path.replaceAll(RegExp(r'/+$'), '');
    if (path.isEmpty) path = '/api';

    return Uri(
      scheme: uri.scheme,
      host: uri.host,
      port: uri.hasPort ? uri.port : null,
      path: path,
    ).toString();
  }

  static String get currentBaseUrl {
    if (_saved != null) return _saved!;
    if (_fromEnvironment.isNotEmpty) return _fromEnvironment;
    if (!kIsWeb && Platform.isAndroid) return 'http://10.0.2.2:8000/api';
    return 'http://127.0.0.1:8000/api';
  }

  // API endpoints
  static const String register = '/register';
  static const String login = '/login';
  static const String logout = '/logout';
  static const String userProfile = '/user/profile';
  static const String passwordResetRequest = '/forgot-password';
  static const String passwordReset = '/reset-password';
  static const String patients = '/patients';
  static const String forms = '/forms';
  static const String dashboardMahasiswa = '/dashboard/mahasiswa';
  static const String dashboardDosen = '/dashboard/dosen';
  static const String diagnoses = '/diagnoses';
  static const String interventions = '/interventions';
  static const String formsSubmitted = '/forms/submitted';
  static const String formReview = '/forms/{id}/review';
  static const String formGeneratePdf = '/forms/{id}/generate-pdf';
  static const String formUploadMaterial = '/forms/{id}/upload-material';
  static const String formUploadPhoto = '/forms/{id}/upload-photo';

  // Helper methods for dynamic endpoints
  static String formReviewEndpoint(String id) => '/forms/$id/review';
  static String formGeneratePdfEndpoint(String id) => '/forms/$id/generate-pdf';
  static String formUploadMaterialEndpoint(String id) =>
      '/forms/$id/upload-material';
  static String formUploadPhotoEndpoint(String id) => '/forms/$id/upload-photo';
}
