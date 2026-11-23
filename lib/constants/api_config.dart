import 'dart:io' show Platform;

import 'package:flutter/foundation.dart' show kIsWeb;

class ApiConfig {
  /// Alamat API diberikan saat build, bukan ditulis di kode:
  ///
  ///   flutter run --dart-define=API_BASE_URL=https://api.contoh.id/api
  ///
  /// Tanpa define, aplikasi memakai backend lokal (`php artisan serve`):
  /// emulator Android lewat 10.0.2.2, simulator iOS dan platform lain lewat 127.0.0.1.
  static const String _fromEnvironment = String.fromEnvironment('API_BASE_URL');

  static String get currentBaseUrl {
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
