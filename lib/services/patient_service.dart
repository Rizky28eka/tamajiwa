import 'package:http/http.dart' as http;
import './api_service.dart';

class PatientService {
  static Future<http.Response> list({String? query}) async {
    if (query != null && query.isNotEmpty) {
      return ApiService.get('patients?search=$query');
    } else {
      return ApiService.getPatients(); // Using the new API service method
    }
  }
}
