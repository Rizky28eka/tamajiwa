import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import '../controllers/form_controller.dart';
import '../controllers/patient_controller.dart';
import '../controllers/nursing_intervention_controller.dart';
import '../models/patient_model.dart';
import '../utils/form_builder_mixin.dart';
import '../widgets/form_components/custom_text_field.dart';
import '../widgets/form_components/custom_dropdown.dart';
import '../widgets/form_components/custom_checkbox_group.dart';
import '../services/nursing_data_global_service.dart';

import '../services/logger_service.dart';

class StrategiPelaksanaanKomunikasiFormView extends StatefulWidget {
  final Patient? patient;
  final int? formId;

  const StrategiPelaksanaanKomunikasiFormView({
    super.key,
    this.patient,
    this.formId,
  });

  @override
  State<StrategiPelaksanaanKomunikasiFormView> createState() =>
      _StrategiPelaksanaanKomunikasiFormViewState();
}

class _StrategiPelaksanaanKomunikasiFormViewState
    extends State<StrategiPelaksanaanKomunikasiFormView>
    with FormBuilderMixin {
  @override
  final FormController formController = Get.put(FormController());
  @override
  final PatientController patientController = Get.find();
  final NursingInterventionController _interventionController = Get.put(
    NursingInterventionController(),
  );

  final LoggerService _logger = LoggerService();

  int _currentSection = 0;

  @override
  String get formType => 'strategi_pelaksanaan_komunikasi';

  @override
  int? get formId => widget.formId ?? Get.arguments?['formId'] as int?;

  Patient? _currentPatient;
  int? _currentPatientId;

  @override
  Patient? get currentPatient => _currentPatient;

  @override
  int? get currentPatientId => _currentPatientId;

  @override
  void initState() {
    super.initState();
    _currentPatient = widget.patient ?? Get.arguments?['patient'] as Patient?;
    _currentPatientId =
        _currentPatient?.id ?? Get.arguments?['patientId'] as int?;

    initializeForm(
      patient: _currentPatient,
      patientId: _currentPatientId,
      formId: formId,
    );
    _logger.info('StrategiPelaksanaanKomunikasiFormView initialized');
  }

  @override
  Map<String, dynamic> transformInitialData(Map<String, dynamic> data) {
    // Data is already reverse-mapped by FormBuilderMixin.loadFormData()
    // via FormDataMapper.mapFromApiFormat()
    return data;
  }

  void _nextSection() {
    updateFormData();
    if (_currentSection < 1) {
      setState(() => _currentSection++);
    }
  }

  void _previousSection() {
    updateFormData();
    if (_currentSection > 0) {
      setState(() => _currentSection--);
    }
  }

  Widget _buildSection(int sectionNumber) {
    Widget sectionContent;
    switch (sectionNumber) {
      case 0:
        sectionContent = _buildProsesKeperawatanSection();
        break;
      case 1:
        sectionContent = _buildStrategiKomunikasiSection();
        break;
      default:
        sectionContent = const SizedBox();
    }

    return KeyedSubtree(
      key: ValueKey('section_$sectionNumber'),
      child: sectionContent,
    );
  }

  Widget _buildProsesKeperawatanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'A. Proses Keperawatan',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'kondisi_klien',
          label: '1. Kondisi Klien',
          tooltip: 'Jelaskan kondisi klien saat ini',
          maxLines: 4,
        ),
        const SizedBox(height: 16),
        Obx(() {
          final nursingService = Get.find<NursingDataGlobalService>();
          final diagnoses = nursingService.diagnoses;
          if (diagnoses.isEmpty) {
            return const Text('Tidak ada diagnosis tersedia');
          }

          return CustomDropdown<int>(
            name: 'diagnosa_keperawatan',
            label: '2. Diagnosa Keperawatan',
            tooltip: 'Pilih diagnosa keperawatan yang sesuai',
            items: diagnoses
                .map(
                  (diag) =>
                      DropdownMenuItem(value: diag.id, child: Text(diag.name)),
                )
                .toList(),
            hint: 'Pilih Diagnosa',
          );
        }),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'tujuan',
          label: '3. Tujuan',
          tooltip: 'Tujuan dari strategi pelaksanaan komunikasi',
          maxLines: 4,
        ),
        const SizedBox(height: 16),
        Obx(() {
          final interventions = _interventionController.interventions;
          if (interventions.isEmpty) {
            return const Text('Tidak ada intervensi tersedia');
          }

          return CustomCheckboxGroup<int>(
            name: 'tindakan_keperawatan',
            label: '4. Tindakan Keperawatan',
            tooltip: 'Pilih tindakan keperawatan yang akan dilakukan',
            options: interventions
                .map(
                  (iv) => FormBuilderFieldOption(
                    value: iv.id,
                    child: Text(iv.name),
                  ),
                )
                .toList(),
          );
        }),
      ],
    );
  }

  Widget _buildStrategiKomunikasiSection() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'B. Strategi Komunikasi',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Fase Orientasi
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '1. Fase Orientasi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    name: 'salam_terapeutik',
                    label: 'a. Salam Terapeutik',
                    tooltip: 'Salam terapeutik yang akan disampaikan',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    name: 'evaluasi_validasi',
                    label: 'b. Evaluasi/Validasi',
                    tooltip: 'Evaluasi dan validasi kondisi klien',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    name: 'kontrak_orientasi',
                    label: 'c. Kontrak',
                    tooltip: 'Kontrak yang disepakati dengan klien',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    name: 'menjaga_kerahasiaan',
                    label: 'd. Menjaga Kerahasiaan',
                    tooltip: 'Penjelasan tentang menjaga kerahasiaan',
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Fase Kerja
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '2. Fase Kerja',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    name: 'fase_kerja',
                    label: 'Fase Kerja',
                    tooltip:
                        'Aktivitas dan komunikasi yang dilakukan pada fase kerja',
                    maxLines: 6,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Fase Terminasi
          Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '3. Fase Terminasi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    name: 'evaluasi_subjektif',
                    label: 'a. Evaluasi Subjektif',
                    tooltip: 'Evaluasi subjektif dari klien',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    name: 'evaluasi_objektif',
                    label: 'b. Evaluasi Objektif',
                    tooltip: 'Evaluasi objektif hasil komunikasi',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    name: 'rencana_tindak_lanjut',
                    label: 'c. Rencana Tindak Lanjut',
                    tooltip: 'Rencana tindak lanjut setelah komunikasi',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  CustomTextField(
                    name: 'kontrak_terminasi',
                    label: 'd. Kontrak',
                    tooltip: 'Kontrak untuk pertemuan selanjutnya',
                    maxLines: 3,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.formId == null
              ? 'Form Strategi Pelaksanaan Komunikasi'
              : 'Edit Strategi Pelaksanaan Komunikasi',
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            LinearProgressIndicator(value: (_currentSection + 1) / 2),
            const SizedBox(height: 16),
            Text('Bagian ${_currentSection + 1} dari 2'),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: FormBuilder(
                  key: formKey,
                  initialValue: initialValues,
                  child: _buildSection(_currentSection),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentSection > 0)
                  ElevatedButton(
                    onPressed: _previousSection,
                    child: const Text('Sebelumnya'),
                  )
                else
                  const SizedBox.shrink(),
                if (_currentSection == 1)
                  Expanded(child: buildActionButtons())
                else
                  ElevatedButton(
                    onPressed: _nextSection,
                    child: const Text('Selanjutnya'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
