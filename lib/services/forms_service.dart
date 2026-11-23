import 'package:http/http.dart' as http;
import '../constants/api_config.dart';
import '../controllers/auth_controller.dart';

class FormsService {
  static Future<http.Response> list({
    String? type,
    String? status,
    String? patientId,
    String? userId,
    int? perPage,
  }) async {
    final token = AuthController.to.token;
    final params = <String, String>{};
    if (type != null && type.isNotEmpty) params['type'] = type;
    if (status != null && status.isNotEmpty) params['status'] = status;
    if (patientId != null && patientId.isNotEmpty) params['patient_id'] = patientId;
    if (userId != null && userId.isNotEmpty) params['user_id'] = userId;
    if (perPage != null) params['per_page'] = perPage.toString();
    final uri = Uri.parse('${ApiConfig.currentBaseUrl}${ApiConfig.forms}').replace(queryParameters: params.isNotEmpty ? params : null);
    return http.get(uri, headers: {
      'Authorization': 'Bearer $token',
      'Accept': 'application/json',
      'Content-Type': 'application/json; charset=UTF-8',
    });
  }
}
