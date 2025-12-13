import 'package:http/http.dart' as http;
import './api_service.dart';

class DashboardService {
  // Mahasiswa Stats
  static Future<http.Response> getMahasiswaStats({int? userId}) async {
    String endpoint = 'dashboard/mahasiswa';
    if (userId != null) {
      endpoint += '?user_id=$userId';
    }
    return ApiService.get(endpoint);
  }

  // Dosen Stats
  static Future<http.Response> getDosenStats({int? userId}) async {
    String endpoint = 'dashboard/dosen';
    if (userId != null) {
      endpoint += '?user_id=$userId';
    }
    return ApiService.get(endpoint);
  }

  // Latest Patients for Mahasiswa Dashboard
  static Future<http.Response> getLatestPatients({int? userId}) async {
    String endpoint = 'patients?limit=5&sort=created_at,desc';
    if (userId != null) {
      endpoint += '&user_id=$userId';
    }
    return ApiService.get(endpoint);
  }
}