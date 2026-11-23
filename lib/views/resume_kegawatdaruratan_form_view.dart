import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import '../controllers/form_controller.dart';
import '../controllers/patient_controller.dart';
import '../controllers/nursing_intervention_controller.dart';
import '../models/patient_model.dart';
import '../services/nursing_data_global_service.dart';
import '../utils/form_builder_mixin.dart';
import '../widgets/form_components/custom_text_field.dart';
import '../widgets/form_components/custom_dropdown.dart';
import '../widgets/form_components/custom_checkbox_group.dart';
import '../widgets/form_components/custom_date_time_picker.dart';
import '../services/logger_service.dart';

class ResumeKegawatdaruratanFormView extends StatefulWidget {
  final Patient? patient;
  final int? formId;

  const ResumeKegawatdaruratanFormView({super.key, this.patient, this.formId});

  @override
  State<ResumeKegawatdaruratanFormView> createState() =>
      _ResumeKegawatdaruratanFormViewState();
}

class _ResumeKegawatdaruratanFormViewState
    extends State<ResumeKegawatdaruratanFormView>
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

  // Section Titles for better UX
  final List<String> _sectionTitles = [
    '1. Identitas Pasien',
    '2. Riwayat Keluhan',
    '3. Pemeriksaan Fisik',
    '4. Status Mental',
    '5. Diagnosis & Tindakan',
    '6. Implementasi',
    '7. Evaluasi',
    '8. Rencana Tindak Lanjut',
    '9. Rencana dengan Keluarga',
    '10. Rencana Perawatan (Renpra)',
  ];

  @override
  String get formType => 'resume_kegawatdaruratan';

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
    _logger.info('ResumeKegawatdaruratanFormView diinisialisasi');
    _currentPatient = widget.patient ?? Get.arguments?['patient'] as Patient?;
    _currentPatientId =
        _currentPatient?.id ?? Get.arguments?['patientId'] as int?;

    if (formId == null && _currentPatient != null) {
      initialValues = {
        'nama_lengkap': _currentPatient!.name,
        'no_rm': _currentPatient!.rmNumber,
        'umur': _currentPatient!.age.toString(),
        'jenis_kelamin': _currentPatient!.gender, // 'L' or 'P'
        'alamat': _currentPatient!.address,
      };
    }

    // Initialize intervention controller
    if (_interventionController.interventions.isEmpty) {
      _interventionController.fetchInterventions();
    }

    initializeForm(
      patient: _currentPatient,
      patientId: _currentPatientId,
      formId: formId,
    );
  }

  void _nextSection() {
    updateFormData();
    if (_currentSection < _sectionTitles.length - 1) {
      setState(() => _currentSection++);
      _scrollToTop();
    }
  }

  void _previousSection() {
    updateFormData();
    if (_currentSection > 0) {
      setState(() => _currentSection--);
      _scrollToTop();
    }
  }

  void _scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Scroll logic if needed
      }
    });
  }

  Widget _buildSection(int sectionNumber) {
    Widget sectionContent;
    switch (sectionNumber) {
      case 0:
        sectionContent = _buildIdentitasSection();
        break;
      case 1:
        sectionContent = _buildRiwayatKeluhanSection();
        break;
      case 2:
        sectionContent = _buildPemeriksaanFisikSection();
        break;
      case 3:
        sectionContent = _buildStatusMentalSection();
        break;
      case 4:
        sectionContent = _buildDiagnosisSection();
        break;
      case 5:
        sectionContent = _buildTindakanSection();
        break;
      case 6:
        sectionContent = _buildImplementasiSection();
        break;
      case 7:
        sectionContent = _buildEvaluasiSection();
        break;
      case 8:
        sectionContent = _buildRencanaLanjutSection();
        break;
      case 9:
        sectionContent = _buildRencanaKeluargaSection();
        break;
      case 10:
        sectionContent = _buildRenpraSection();
        break;
      default:
        sectionContent = const SizedBox();
    }

    return KeyedSubtree(
      key: ValueKey('section_$sectionNumber'),
      child: sectionContent,
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildSectionHeader(String title, String description) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          description,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontStyle: FontStyle.italic,
          ),
        ),
        const Divider(height: 24, thickness: 1.5),
      ],
    );
  }

  Widget _buildInfoBox(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(fontSize: 12, color: Colors.blue.shade900),
            ),
          ),
        ],
      ),
    );
  }

  // --- SECTIONS ---

  Widget _buildIdentitasSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Identitas Pasien',
          'Data demografi dan informasi kunjungan pasien',
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'nama_lengkap',
          label: 'Nama Pasien',
          tooltip: 'Nama lengkap pasien',
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'no_rm',
          label: 'Nomor Rekam Medis',
          tooltip: 'Nomor rekam medis pasien',
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'umur',
          label: 'Umur',
          tooltip: 'Usia pasien dalam tahun',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        CustomDropdown<String>(
          name: 'jenis_kelamin',
          label: 'Jenis Kelamin',
          tooltip: 'Jenis kelamin pasien',
          items: const [
            DropdownMenuItem(value: 'L', child: Text('Laki-laki')),
            DropdownMenuItem(value: 'P', child: Text('Perempuan')),
            DropdownMenuItem(value: 'O', child: Text('Lainnya')),
          ],
          hint: 'Pilih Jenis Kelamin',
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'alamat',
          label: 'Alamat',
          tooltip: 'Alamat tempat tinggal pasien',
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: const CustomDateTimePicker(
                name: 'tanggal_masuk',
                label: 'Tanggal Masuk',
                tooltip: 'Tanggal pasien masuk',
                inputType: InputType.date,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: const CustomTextField(
                name: 'jam_masuk',
                label: 'Jam Masuk',
                tooltip: 'Format: HH:mm',
                hintText: 'HH:mm',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: const CustomDateTimePicker(
                name: 'tanggal_keluar',
                label: 'Tanggal Keluar',
                tooltip: 'Tanggal pasien keluar',
                inputType: InputType.date,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: const CustomTextField(
                name: 'jam_keluar',
                label: 'Jam Keluar',
                tooltip: 'Format: HH:mm',
                hintText: 'HH:mm',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRiwayatKeluhanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Riwayat Keluhan',
          'Informasi keluhan utama dan riwayat penyakit',
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'keluhan_utama',
          label: 'Keluhan Utama *',
          tooltip: 'Keluhan utama yang dirasakan pasien',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'riwayat_penyakit_sekarang',
          label: 'Riwayat Penyakit Sekarang',
          tooltip: 'Riwayat penyakit yang sedang dialami pasien',
          maxLines: 4,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'faktor_pencetus',
          label: 'Faktor Pencetus',
          tooltip:
              'Faktor-faktor yang mungkin memicu gangguan kesehatan pasien',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'riwayat_penyakit_dahulu',
          label: 'Riwayat Penyakit Dahulu',
          tooltip: 'Riwayat penyakit yang pernah dialami pasien sebelumnya',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'riwayat_pengobatan',
          label: 'Riwayat Pengobatan',
          tooltip: 'Riwayat pengobatan yang pernah diterima pasien',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildPemeriksaanFisikSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Pemeriksaan Fisik',
          'Hasil pemeriksaan fisik dan tanda-tanda vital',
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'keadaan_umum',
          label: 'Keadaan Umum',
          tooltip: 'Kondisi umum pasien saat pemeriksaan',
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'tanda_vital',
          label: 'Tanda-tanda Vital (Deskriptif)',
          tooltip: 'Deskripsi umum tanda-tanda vital',
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: const CustomTextField(
                name: 'tekanan_darah',
                label: 'TD (mmHg)',
                hintText: '120/80',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: const CustomTextField(
                name: 'nadi',
                label: 'Nadi (x/mnt)',
                hintText: '80',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: const CustomTextField(
                name: 'suhu',
                label: 'Suhu (°C)',
                hintText: '36.5',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: const CustomTextField(
                name: 'pernapasan',
                label: 'RR (x/mnt)',
                hintText: '20',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: const CustomTextField(
                name: 'spo2',
                label: 'SpO2 (%)',
                hintText: '98',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: const CustomTextField(
                name: 'gcs',
                label: 'GCS',
                hintText: 'E4V5M6',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'pemeriksaan_lain',
          label: 'Pemeriksaan Fisik Lain',
          tooltip: 'Pemeriksaan fisik tambahan yang dilakukan',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildStatusMentalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Status Mental', 'Evaluasi status mental pasien'),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomDropdown<String>(
                name: 'kesadaran',
                label: 'Kesadaran',
                items: const [
                  DropdownMenuItem(
                    value: 'sadar_penuh',
                    child: Text('Sadar Penuh'),
                  ),
                  DropdownMenuItem(
                    value: 'somnolent',
                    child: Text('Somnolent'),
                  ),
                  DropdownMenuItem(value: 'stupor', child: Text('Stupor')),
                  DropdownMenuItem(value: 'coma', child: Text('Coma')),
                ],
                hint: 'Pilih...',
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomDropdown<String>(
                name: 'orientasi',
                label: 'Orientasi',
                items: const [
                  DropdownMenuItem(value: 'utuh', child: Text('Utuh')),
                  DropdownMenuItem(value: 'gangguan', child: Text('Gangguan')),
                ],
                hint: 'Pilih...',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'penampilan',
          label: 'Penampilan',
          tooltip: 'Rapi, kotor, sesuai, tidak sesuai, dll',
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'perilaku',
          label: 'Perilaku',
          tooltip: 'Tenang, gelisah, agresif, dll',
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'pembicaraan',
          label: 'Pembicaraan',
          tooltip: 'Cepat, lambat, membisu, dll',
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'mood_afek',
          label: 'Mood/Afek',
          tooltip: 'Sedih, senang, datar, tumpul, dll',
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'pikiran',
          label: 'Proses Pikir',
          tooltip: 'Arus, bentuk, isi pikir',
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'isi_pemikiran',
          label: 'Isi Pikir',
          tooltip: 'Waham, obsesi, phobia, dll',
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'bentuk_pemikiran',
          label: 'Bentuk Pikir',
          tooltip: 'Realistik, non realistik, autistik, dll',
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'persepsi',
          label: 'Persepsi',
          tooltip: 'Halusinasi, ilusi, depersonalisasi, dll',
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'kognitif',
          label: 'Kognitif',
          tooltip: 'Memori, konsentrasi, dll',
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildDiagnosisSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Diagnosis Kerja',
          'Diagnosis keperawatan dan medis',
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'diagnosis_utama',
          label: 'Diagnosis Utama *',
          tooltip: 'Diagnosis utama pasien',
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'diagnosis_kerja',
          label: 'Diagnosis Kerja',
          tooltip: 'Diagnosis kerja',
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'diagnosis_banding',
          label: 'Diagnosis Banding',
          tooltip: 'Diagnosis banding yang mungkin',
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'diagnosis_tambahan',
          label: 'Diagnosis Tambahan',
          tooltip: 'Comorbiditas atau diagnosis lain',
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildTindakanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Tindakan',
          'Tindakan medis dan keperawatan yang dilakukan',
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'tindakan_keperawatan',
          label: 'Tindakan Keperawatan',
          tooltip: 'Tindakan asuhan keperawatan yang diberikan',
          maxLines: 4,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'terapi_psikososial',
          label: 'Terapi Psikososial',
          tooltip: 'Terapi individu, kelompok, atau keluarga',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'terapi_obat',
          label: 'Terapi Obat (Medikasi)',
          tooltip: 'Daftar obat yang diberikan',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        _buildInfoBox(
          'Field di bawah ini untuk historical data atau tindakan tambahan',
        ),
        const CustomTextField(
          name: 'tindakan_medis',
          label: 'Tindakan Medis Lainnya',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'tindakan_yang_dilakukan',
          label: 'Ringkasan Tindakan',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildImplementasiSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Implementasi',
          'Pelaksanaan intervensi dan kolaborasi',
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'pelaksanaan_intervensi',
          label: 'Pelaksanaan Intervensi',
          tooltip: 'Detail pelaksanaan intervensi',
          maxLines: 5,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'kolaborasi_tim',
          label: 'Kolaborasi Tim',
          tooltip: 'Kolaborasi dengan dokter, psikolog, dll',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'edukasi',
          label: 'Edukasi Pasien',
          tooltip: 'Materi edukasi yang diberikan ke pasien',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildEvaluasiSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Evaluasi',
          'Evaluasi hasil tindakan dan respon pasien',
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'respon_intervensi',
          label: 'Respon Pasien',
          tooltip: 'Respon subjektif dan objektif pasien',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'perubahan_klinis',
          label: 'Perubahan Klinis',
          tooltip: 'Perubahan tanda gejala klinis',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'tujuan_tercapai',
          label: 'Tujuan Tercapai',
          tooltip: 'Indikator tujuan yang sudah tercapai',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'hambatan_perawatan',
          label: 'Hambatan Perawatan',
          tooltip: 'Kendala yang dihadapi selama perawatan',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildRencanaLanjutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Rencana Tindak Lanjut',
          'Kondisi keluar dan perencanaan pulang',
        ),
        const SizedBox(height: 16),
        CustomDropdown<String>(
          name: 'kondisi_keluar',
          label: 'Kondisi Keluar *',
          tooltip: 'Status pasien saat keluar',
          items: const [
            DropdownMenuItem(value: 'Membaik', child: Text('Membaik')),
            DropdownMenuItem(
              value: 'Belum Membaik',
              child: Text('Belum Membaik'),
            ),
            DropdownMenuItem(value: 'Meninggal', child: Text('Meninggal')),
            DropdownMenuItem(
              value: 'Pulang Paksa',
              child: Text('Pulang Paksa'),
            ),
          ],
          hint: 'Pilih Kondisi Keluar',
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'anjuran',
          label: 'Anjuran',
          tooltip: 'Anjuran untuk pasien dan keluarga',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'rencana_medis',
          label: 'Rencana Medis',
          tooltip: 'Jadwal kontrol dan pengobatan',
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'rencana_keperawatan',
          label: 'Rencana Keperawatan',
          tooltip: 'Tindakan keperawatan di rumah',
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'rencana_pemantauan',
          label: 'Rencana Pemantauan',
          tooltip: 'Hal yang perlu dipantau keluarga',
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildRencanaKeluargaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Rencana dengan Keluarga',
          'Edukasi dan pelibatan keluarga',
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'keterlibatan_keluarga',
          label: 'Keterlibatan Keluarga',
          tooltip: 'Peran keluarga dalam perawatan',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'edukasi_keluarga',
          label: 'Edukasi Keluarga',
          tooltip: 'Materi edukasi untuk keluarga',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'dukungan_keluarga',
          label: 'Dukungan Keluarga',
          tooltip: 'Support system yang tersedia',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildRenpraSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Rencana Perawatan (Renpra)',
          'Diagnosis dan intervensi keperawatan standar',
        ),
        _buildInfoBox('Pilih diagnosis untuk menampilkan intervensi terkait'),
        const SizedBox(height: 16),
        Obx(() {
          final nursingService = Get.find<NursingDataGlobalService>();
          final diagnoses = nursingService.diagnoses;
          if (diagnoses.isEmpty) {
            return const Text('Tidak ada diagnosis tersedia');
          }

          return CustomDropdown<int>(
            name: 'diagnosis',
            label: 'Diagnosis Keperawatan',
            tooltip: 'Pilih diagnosis keperawatan prioritas',
            items: diagnoses
                .map(
                  (diag) =>
                      DropdownMenuItem(value: diag.id, child: Text(diag.name)),
                )
                .toList(),
            hint: 'Pilih Diagnosis',
            onChanged: (value) {
              if (value == null) {
                // Clear dependent fields
                formKey.currentState?.fields['intervensi']?.didChange([]);
                formKey.currentState?.fields['tujuan']?.didChange(null);
                formKey.currentState?.fields['kriteria']?.didChange(null);
                formKey.currentState?.fields['rasional']?.didChange(null);
              }
            },
          );
        }),
        const SizedBox(height: 16),
        Obx(() {
          final interventions = _interventionController.interventions;

          if (interventions.isEmpty) {
            return const Text('Tidak ada intervensi tersedia');
          }

          return CustomCheckboxGroup<int>(
            name: 'intervensi',
            label: 'Intervensi',
            tooltip: 'Pilih intervensi yang direncanakan',
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
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'tujuan',
          label: 'Tujuan',
          tooltip: 'Tujuan NOC/SLKI',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'kriteria',
          label: 'Kriteria Hasil',
          tooltip: 'Indikator keberhasilan',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'rasional',
          label: 'Rasional',
          tooltip: 'Scientific base intervensi',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        const CustomTextField(
          name: 'evaluasi_renpra',
          label: 'Evaluasi Renpra',
          tooltip: 'Evaluasi pencapaian Renpra',
          maxLines: 3,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.formId == null ? 'Resume Kegawatdaruratan' : 'Edit Resume',
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Professional Progress Indicator
            Column(
              children: [
                LinearProgressIndicator(
                  value: (_currentSection + 1) / _sectionTitles.length,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _sectionTitles[_currentSection],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_currentSection + 1}/${_sectionTitles.length}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: SingleChildScrollView(
                child: FormBuilder(
                  key: formKey,
                  initialValue: initialValues,
                  child: Card(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.surfaceContainerLowest,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                          color: Theme.of(context).colorScheme.outlineVariant),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildSection(_currentSection),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentSection > 0)
                  ElevatedButton.icon(
                    onPressed: _previousSection,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Sebelumnya'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  )
                else
                  const SizedBox.shrink(),
                if (_currentSection == _sectionTitles.length - 1)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: buildActionButtons(),
                    ),
                  )
                else
                  ElevatedButton.icon(
                    onPressed: _nextSection,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Selanjutnya'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
