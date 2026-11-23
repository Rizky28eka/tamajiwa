import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/patient_controller.dart';
import '../models/patient_model.dart';

import '../services/logger_service.dart';
import '../utils/ui_helpers.dart';

class PatientSelectionView extends GetView<PatientController> {
  PatientSelectionView({super.key});

  final LoggerService _logger = LoggerService();

  final String formType = Get.arguments?['formType'] as String? ?? '';

  // Helper to map formType string to title (can be moved to a util or service)
  String get formTypeTitle {
    switch (formType) {
      case 'pengkajian':
        return 'Pengkajian Kesehatan Jiwa';
      case 'resume_kegawatdaruratan':
        return 'Resume Kegawatdaruratan';
      case 'resume_poliklinik':
        return 'Resume Poliklinik';
      case 'sap':
        return 'Satuan Acara Penyuluhan (SAP)';
      case 'terapi_aktivitas_kelompok':
        return 'Terapi Aktivitas Kelompok';
      case 'strategi_pelaksanaan_komunikasi':
        return 'Strategi Pelaksanaan Komunikasi';
      case 'logbook':
        return 'Logbook & Lainnya';
      case 'catatan_tambahan':
        return 'Catatan Tambahan';
      default:
        return 'Formulir';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ensure controller searches or refreshes if needed
    if (controller.patients.isEmpty && !controller.isLoading.value) {
      controller.fetchPatients();
    }

    return Scaffold(
      appBar: AppBar(title: Text('Pilih Pasien untuk $formTypeTitle')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.patients.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Belum ada pasien.'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Get.toNamed('/patient-form'),
                  child: const Text('Buat Pasien Baru'),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          itemCount: controller.patients.length,
          padding: const EdgeInsets.all(16),
          itemBuilder: (context, index) {
            final patient = controller.patients[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(child: Text(patient.gender)),
                title: Text(patient.name),
                subtitle: Text(
                  'RM: ${patient.rmNumber} | Umur: ${patient.age}',
                ),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  _navigateToForm(patient);
                },
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Get.toNamed('/patient-form');
          if (result != null) {
            controller.fetchPatients();
          }
        },
        tooltip: 'Tambah Pasien Baru',
        child: const Icon(Icons.add),
      ),
    );
  }

  void _navigateToForm(Patient patient) {
    String route = '';
    switch (formType) {
      case 'pengkajian':
        route = '/mental-health-assessment-form';
        break;
      case 'resume_kegawatdaruratan':
        route = '/resume-kegawatdaruratan-form';
        break;
      case 'resume_poliklinik':
        route = '/resume-poliklinik-form';
        break;
      case 'sap':
        route = '/sap-form';
        break;
      case 'terapi_aktivitas_kelompok':
        route = '/terapi-aktivitas-kelompok-form';
        break;
      case 'strategi_pelaksanaan_komunikasi':
        route = '/strategi-pelaksanaan-komunikasi-form';
        break;
      case 'catatan_tambahan':
        route = '/catatan-tambahan-form';
        break;
      default:
        _logger.warning(
          'Tipe form tidak valid saat navigasi',
          context: {'formType': formType},
        );
        UIHelpers.showError(
          title: 'Kesalahan',
          message: 'Tipe formulir tidak dikenali',
        );
        return;
    }

    if (route.isNotEmpty) {
      Get.toNamed(
        route,
        arguments: {
          'patient': patient,
          'patientId': patient.id,
          'patientName': patient.name,
          'formType': formType,
        },
      );
    }
  }
}
