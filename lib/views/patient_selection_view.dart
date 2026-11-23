import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/patient_controller.dart';
import '../models/patient_model.dart';

import '../services/logger_service.dart';
import '../theme/app_theme.dart';
import '../utils/form_types.dart';
import '../utils/ui_helpers.dart';
import '../widgets/ds/ds.dart';

class PatientSelectionView extends GetView<PatientController> {
  PatientSelectionView({super.key});

  final LoggerService _logger = LoggerService();

  final String formType = Get.arguments?['formType'] as String? ?? '';

  String get formTypeTitle => FormTypes.title(formType);

  @override
  Widget build(BuildContext context) {
    if (controller.patients.isEmpty && !controller.isLoading.value) {
      controller.fetchPatients();
    }
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Pilih pasien')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.patients.isEmpty) {
              return DsEmpty(
                icon: Icons.person_add_alt_1_rounded,
                title: 'Belum ada pasien',
                message: 'Buat pasien dulu untuk mengisi $formTypeTitle.',
                actionLabel: 'Buat pasien baru',
                onAction: () => Get.toNamed('/patient-form'),
              );
            }
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
              children: [
                Text(formTypeTitle, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 4),
                Text('Pilih pasien yang akan didokumentasikan.',
                    style: theme.textTheme.bodySmall),
                const SizedBox(height: 20),
                for (final patient in controller.patients) ...[
                  DsCard(
                    radius: AppRadius.md,
                    padding: const EdgeInsets.all(14),
                    onTap: () => _navigateToForm(patient),
                    child: Row(children: [
                      DsAvatar(name: patient.name, size: 48),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(patient.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.titleSmall),
                              const SizedBox(height: 6),
                              Wrap(spacing: 6, runSpacing: 6, children: [
                                DsPill(label: 'RM ${patient.rmNumber}'),
                                DsPill(label: '${patient.age} th'),
                              ]),
                            ]),
                      ),
                      const Icon(Icons.arrow_forward_rounded, size: 20),
                    ]),
                  ),
                  const SizedBox(height: 10),
                ],
              ],
            );
          }),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Get.toNamed('/patient-form');
          if (result != null) controller.fetchPatients();
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Pasien baru'),
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
