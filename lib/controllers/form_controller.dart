import 'dart:convert';

import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:open_file/open_file.dart'; // For opening files
import 'package:path_provider/path_provider.dart'; // For saving files
import 'package:tamajiwa/constants/api_config.dart';
import 'package:tamajiwa/services/logger_service.dart';
import '../models/form_model.dart';
import '../services/api_service.dart';
import '../utils/form_data_mapper.dart';

class FormController extends GetxController {
  final LoggerService _logger = LoggerService();
  final RxList<FormModel> _forms = <FormModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;

  List<FormModel> get forms => _forms;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;

  Future<void> fetchForms({String? type, int? patientId}) async {
    _isLoading.value = true;
    _errorMessage.value = '';
    _forms.clear(); // Clear previous data before fetching
    _logger.form(
      operation: 'fetch',
      formType: type ?? 'all',
      patientId: patientId?.toString(),
    );

    try {
      String endpoint = 'forms';
      if (type != null || patientId != null) {
        endpoint += '?';
        List<String> params = [];
        if (type != null) params.add('type=$type');
        if (patientId != null) params.add('patient_id=$patientId');
        endpoint += params.join('&');
      }

      final response = await ApiService.get(endpoint);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> formList = (data['data'] is List)
            ? data['data'] as List<dynamic>
            : (data['data']['data'] as List<dynamic>);

        _forms.value = formList
            .map((json) => FormModel.fromJson(json as Map<String, dynamic>))
            .toList();
        _logger.info(
          'Successfully fetched forms',
          context: {'count': formList.length, 'patientId': patientId},
        );
      } else {
        _errorMessage.value = 'Failed to fetch forms';
        _logger.error(
          'Failed to fetch forms',
          error: response.body,
          stackTrace: StackTrace.current,
        );
      }
    } catch (e, stackTrace) {
      _errorMessage.value = 'Error fetching forms: $e';
      _logger.error('Error fetching forms', error: e, stackTrace: stackTrace);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<FormModel?> createForm({
    required String type,
    required int patientId,
    Map<String, dynamic>? data,
    String status = 'submitted',
  }) async {
    _isLoading.value = true;
    _errorMessage.value = '';
    _logger.form(
      operation: 'create',
      formType: type,
      patientId: patientId.toString(),
      status: status,
      data: data,
    );

    try {
      // Map form data to new structured format
      final mappedData = data != null
          ? FormDataMapper.mapToApiFormat(type, {
              ...data,
              'patient_id': patientId,
              'status': status,
            })
          : {
              'type': type,
              'patient_id': patientId,
              'status': status,
              'data': {},
            };

      _logger.info('Mapped data for API', context: {'mappedData': mappedData});

      final response = await ApiService.post('forms', body: mappedData);

      _logger.info(
        'API Response',
        context: {'statusCode': response.statusCode, 'body': response.body},
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final newForm = FormModel.fromJson(data['form']);
        // Don't auto-refresh to avoid ANR, let caller handle navigation
        _logger.info(
          'Form created successfully',
          context: {'type': type, 'formId': newForm.id},
        );
        return newForm;
      } else {
        final errorData = json.decode(response.body);
        _errorMessage.value = errorData['message'] ?? 'Failed to create form';
        _logger.error(
          'Failed to create form - API Error',
          error: _errorMessage.value,
          context: {'statusCode': response.statusCode, 'response': errorData},
        );
        if (Get.isSnackbarOpen != true) {
          Get.snackbar('Error', _errorMessage.value);
        }
      }
    } catch (e, stackTrace) {
      _errorMessage.value = 'Error creating form: $e';
      _logger.error('Error creating form', error: e, stackTrace: stackTrace);
      if (Get.isSnackbarOpen != true) {
        Get.snackbar(
          'Error',
          'Gagal membuat form: ${e.toString()}',
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
          duration: const Duration(seconds: 3),
        );
      }
    } finally {
      _isLoading.value = false;
    }
    return null;
  }

  Future<FormModel?> updateForm({
    required int id,
    String? type,
    int? patientId,
    Map<String, dynamic>? data,
    String? status,
    String? comments,
  }) async {
    _isLoading.value = true;
    _errorMessage.value = '';
    _logger.form(
      operation: 'update',
      formType: type ?? 'unknown',
      formId: id.toString(),
      patientId: patientId?.toString(),
      status: status,
      data: data,
      metadata: {'comments': comments},
    );

    try {
      Map<String, dynamic> body = {};

      // If data is provided and type is provided, use mapper
      if (data != null && type != null) {
        final mappedData = FormDataMapper.mapToApiFormat(type, {
          ...data,
          if (patientId != null) 'patient_id': patientId,
          if (status != null) 'status': status,
        });
        // Use the mapped structure
        body = mappedData;
        // Override with explicit parameters if provided
        if (comments != null) body['comments'] = comments;
      } else {
        // Fallback to old behavior if type or data is not provided
        if (type != null) body['type'] = type;
        if (patientId != null) body['patient_id'] = patientId;
        if (data != null) body['data'] = data;
        if (status != null) body['status'] = status;
        if (comments != null) body['comments'] = comments;
      }

      _logger.info('Mapped update data for API', context: {'mappedData': body});

      final response = await ApiService.put('forms/$id', body: body);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final updatedForm = FormModel.fromJson(data['form']);
        // Don't auto-refresh to avoid ANR
        Get.snackbar('Success', 'Form updated successfully');
        _logger.info('Form updated successfully', context: {'formId': id});
        return updatedForm;
      } else {
        final errorData = json.decode(response.body);
        _errorMessage.value = errorData['message'] ?? 'Failed to update form';
        Get.snackbar('Error', _errorMessage.value);
        _logger.error(
          'Failed to update form',
          error: _errorMessage.value,
          stackTrace: StackTrace.current,
        );
      }
    } catch (e, stackTrace) {
      _errorMessage.value = 'Error updating form: $e';
      Get.snackbar('Error', _errorMessage.value);
      _logger.error('Error updating form', error: e, stackTrace: stackTrace);
    } finally {
      _isLoading.value = false;
    }
    return null;
  }

  Future<FormModel?> getFormById(int id) async {
    _logger.form(
      operation: 'get by id',
      formType: 'unknown',
      formId: id.toString(),
    );
    try {
      final response = await ApiService.get('forms/$id');

      if (response.statusCode == 200) {
        final formData = json.decode(response.body);
        _logger.form(
          operation: 'Successfully fetched form by id',
          formType: formData['type'] ?? 'unknown',
          formId: id.toString(),
        );
        return FormModel.fromJson(formData);
      } else {
        _logger.warning('Could not find form with id $id');
      }
    } catch (e, stackTrace) {
      _errorMessage.value = 'Error fetching form: $e';
      _logger.error(
        'Error fetching form by id',
        error: e,
        stackTrace: stackTrace,
      );
    }
    return null;
  }

  /// Fetch SVG preview for a form's genogram as raw string
  Future<String?> fetchGenogramSvg(int formId) async {
    try {
      final response = await ApiService.get('forms/$formId/genogram/svg');
      if (response.statusCode == 200) {
        return response.body;
      }
    } catch (e) {
      _logger.error('Error fetching genogram svg', error: e);
    }
    return null;
  }

  Future<bool> deleteForm(int id) async {
    _logger.form(
      operation: 'delete',
      formType: 'unknown',
      formId: id.toString(),
    );
    try {
      final response = await ApiService.delete('forms/$id');

      if (response.statusCode == 200) {
        // Remove from local list instead of fetching all
        _forms.removeWhere((form) => form.id == id);
        _logger.info('Form deleted successfully', context: {'formId': id});
        return true;
      } else {
        final errorData = json.decode(response.body);
        _errorMessage.value = errorData['message'] ?? 'Failed to delete form';
        _logger.error(
          'Failed to delete form',
          error: _errorMessage.value,
          stackTrace: StackTrace.current,
        );
        return false;
      }
    } catch (e, stackTrace) {
      _errorMessage.value = 'Error deleting form: $e';
      _logger.error('Error deleting form', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  Future<void> exportFormToPdf(int formId) async {
    _isLoading.value = true;
    try {
      final token =
          await ApiService.getToken(); // Assuming we expose this or use AuthController
      if (token == null) {
        throw Exception('User authentication token not found');
      }

      final url = Uri.parse(
        '${ApiConfig.currentBaseUrl}${ApiConfig.formGeneratePdfEndpoint(formId.toString())}',
      );

      _logger.info('Exporting PDF', context: {'url': url.toString()});

      final response = await http.get(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;
        final dir = await getApplicationDocumentsDirectory();
        final file = File('${dir.path}/form_$formId.pdf');

        await file.writeAsBytes(bytes, flush: true);

        _logger.info(
          'PDF downloaded successfully',
          context: {'path': file.path},
        );
        await OpenFile.open(file.path);
      } else {
        _errorMessage.value = 'Failed to export PDF: ${response.statusCode}';
        _logger.error(
          'Failed to export PDF',
          error: response.body,
          context: {'statusCode': response.statusCode},
        );
        Get.snackbar('Error', 'Gagal mengekspor PDF: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      _errorMessage.value = 'Error exporting PDF: $e';
      _logger.error('Error exporting PDF', error: e, stackTrace: stackTrace);
      Get.snackbar('Error', 'Gagal mengekspor PDF: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  Future<bool> uploadDocumentation({
    required int formId,
    required String filePath,
    required String type, // 'materi', 'foto', 'lainnya'
  }) async {
    _isLoading.value = true;
    try {
      final token = await ApiService.getToken();
      if (token == null) {
        throw Exception('User authentication token not found');
      }

      String endpoint;
      if (type == 'foto') {
        endpoint = ApiConfig.formUploadPhotoEndpoint(formId.toString());
      } else {
        endpoint = ApiConfig.formUploadMaterialEndpoint(formId.toString());
      }

      final uri = Uri.parse('${ApiConfig.currentBaseUrl}$endpoint');

      final request = http.MultipartRequest('POST', uri);
      request.headers['Authorization'] = 'Bearer $token';

      // Determine field name based on typical laravel request
      // Ideally 'file' or 'documentation'
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
      request.fields['type'] = type;

      _logger.info(
        'Uploading documentation',
        context: {'formId': formId, 'type': type},
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        _logger.info('Documentation uploaded successfully');
        Get.snackbar('Success', 'Dokumentasi berhasil diunggah');
        // Refresh form data to show new attachment
        await getFormById(formId);
        return true;
      } else {
        final errorData = json.decode(response.body);
        _errorMessage.value =
            errorData['message'] ?? 'Failed to upload documentation';
        _logger.error('Failed to upload documentation', error: response.body);
        Get.snackbar('Error', _errorMessage.value);
        return false;
      }
    } catch (e, stackTrace) {
      _errorMessage.value = 'Error uploading documentation: $e';
      _logger.error(
        'Error uploading documentation',
        error: e,
        stackTrace: stackTrace,
      );
      Get.snackbar('Error', 'Gagal mengunggah dokumentasi: $e');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
}
