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

class ResumePoliklinikFormView extends StatefulWidget {
  final Patient? patient;
  final int? formId;

  const ResumePoliklinikFormView({super.key, this.patient, this.formId});

  @override
  State<ResumePoliklinikFormView> createState() =>
      _ResumePoliklinikFormViewState();
}

class _ResumePoliklinikFormViewState extends State<ResumePoliklinikFormView>
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

  final List<String> _sectionTitles = [
    'Identitas Klien',
    'Riwayat Kehidupan',
    'Riwayat Psikososial',
    'Riwayat Psikiatri',
    'Pemeriksaan Psikologis',
    'Fungsi Psikologis',
    'Fungsi Sosial',
    'Fungsi Spiritual',
    'Rencana Perawatan',
    'Penutup',
  ];

  @override
  String get formType => 'resume_poliklinik';

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
    _logger.info('ResumePoliklinikFormView diinisialisasi');
    _currentPatient = widget.patient ?? Get.arguments?['patient'] as Patient?;
    _currentPatientId =
        _currentPatient?.id ?? Get.arguments?['patientId'] as int?;

    // Load interventions if needed
    if (_interventionController.interventions.isEmpty) {
      _interventionController.fetchInterventions();
    }

    if (formId == null && _currentPatient != null) {
      initialValues = {
        'nama_lengkap': _currentPatient!.name,
        'no_rm': _currentPatient!.rmNumber,
        'umur': _currentPatient!.age.toString(),
        'jenis_kelamin': _currentPatient!.gender, // 'L' or 'P'
      };
    }

    final formDataArg = Get.arguments?['formData'] as Map<String, dynamic>?;
    if (formDataArg != null) {
      initialValues = transformInitialData(formDataArg);
    }

    initializeForm(
      patient: _currentPatient,
      patientId: _currentPatientId,
      formId: formId,
    );
  }

  @override
  Map<String, dynamic> transformInitialData(Map<String, dynamic> data) {
    return data;
  }

  void _nextSection() {
    updateFormData();
    if (_currentSection < _sectionTitles.length - 1) {
      setState(() => _currentSection++);
    }
  }

  void _previousSection() {
    updateFormData();
    if (_currentSection > 0) {
      setState(() => _currentSection--);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Resume Poliklinik'),
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: BackButton(color: colorScheme.onSurface),
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: (_currentSection + 1) / _sectionTitles.length,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      colorScheme.primary,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _sectionTitles[_currentSection],
                      style: textTheme.labelMedium?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_currentSection + 1}/${_sectionTitles.length}',
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: FormBuilder(
        key: formKey,
        initialValue: initialValues,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                key: ValueKey('section_$_currentSection'),
                padding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 16.0,
                ),
                child: _buildSection(context, _currentSection),
              ),
            ),
            _buildBottomActionBar(colorScheme, textTheme),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(BuildContext context, int sectionNumber) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    Widget content;

    switch (sectionNumber) {
      case 0:
        content = _buildIdentitasSection(colorScheme);
        break;
      case 1:
        content = _buildRiwayatKehidupanSection(colorScheme);
        break;
      case 2:
        content = _buildRiwayatPsikososialSection(colorScheme);
        break;
      case 3:
        content = _buildRiwayatPsikiatriSection(colorScheme);
        break;
      case 4:
        content = _buildPemeriksaanPsikologisSection(colorScheme);
        break;
      case 5:
        content = _buildFungsiPsikologisSection(colorScheme);
        break;
      case 6:
        content = _buildFungsiSosialSection(colorScheme);
        break;
      case 7:
        content = _buildFungsiSpiritualSection(colorScheme);
        break;
      case 8:
        content = _buildRenpraSection(colorScheme);
        break;
      case 9:
        content = _buildPenutupSection(colorScheme);
        break;
      default:
        content = const SizedBox.shrink();
    }

    return _buildInfoCard(
      colorScheme: colorScheme,
      textTheme: textTheme,
      title: '${sectionNumber + 1}. ${_sectionTitles[sectionNumber]}',
      child: content,
    );
  }

  // --- SECTIONS ---

  Widget _buildIdentitasSection(ColorScheme colorScheme) {
    return Column(
      children: [
        CustomTextField(
          name: 'nama_lengkap',
          label: 'Nama Lengkap',
          tooltip: 'Nama lengkap pasien',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'no_rm',
          label: 'No. RM',
          tooltip: 'Nomor Rekam Medis',
        ),
        const SizedBox(height: 16),
        CustomDateTimePicker(
          name: 'tanggal_kunjungan',
          label: 'Tanggal Kunjungan',
          inputType: InputType.date,
        ),
        const SizedBox(height: 16),
        CustomTextField(name: 'poliklinik', label: 'Poliklinik Tujuan'),
        const SizedBox(height: 16),
        CustomTextField(
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
          ],
        ),
        const SizedBox(height: 16),
        CustomDropdown<String>(
          name: 'status_perkawinan',
          label: 'Status Perkawinan',
          tooltip: 'Status perkawinan pasien saat ini',
          items: const [
            DropdownMenuItem(value: 'belum_kawin', child: Text('Belum Kawin')),
            DropdownMenuItem(value: 'menikah', child: Text('Menikah')),
            DropdownMenuItem(value: 'cerai', child: Text('Cerai')),
            DropdownMenuItem(value: 'duda', child: Text('Duda')),
            DropdownMenuItem(value: 'janda', child: Text('Janda')),
          ],
        ),
      ],
    );
  }

  Widget _buildRiwayatKehidupanSection(ColorScheme colorScheme) {
    return Column(
      children: [
        CustomTextField(
          name: 'riwayat_pendidikan',
          label: 'Riwayat Pendidikan',
          tooltip: 'Riwayat pendidikan yang pernah ditempuh pasien',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'pekerjaan',
          label: 'Pekerjaan',
          tooltip: 'Pekerjaan pasien saat ini',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'riwayat_keluarga',
          label: 'Riwayat Keluarga',
          tooltip: 'Kondisi dan hubungan dalam keluarga pasien',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildRiwayatPsikososialSection(ColorScheme colorScheme) {
    return Column(
      children: [
        CustomTextField(
          name: 'hubungan_sosial',
          label: 'Hubungan Sosial',
          tooltip: 'Hubungan pasien dengan lingkungan sosialnya',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'dukungan_sosial',
          label: 'Dukungan Sosial',
          tooltip: 'Jenis dukungan yang diterima pasien dari lingkungan',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'stresor_psikososial',
          label: 'Stresor Psikososial',
          tooltip: 'Faktor-faktor yang menyebabkan stres pada pasien',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildRiwayatPsikiatriSection(ColorScheme colorScheme) {
    return Column(
      children: [
        CustomTextField(
          name: 'keluhan_utama',
          label: 'Keluhan Utama',
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'riwayat_gangguan_psikiatri',
          label: 'Riwayat Gangguan Psikiatri',
          tooltip: 'Riwayat gangguan psikiatri sebelumnya pada pasien',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'riwayat_penyakit_sekarang',
          label: 'Riwayat Penyakit Sekarang',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'riwayat_penyakit_dahulu',
          label: 'Riwayat Penyakit Dahulu',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'riwayat_pengobatan',
          label: 'Riwayat Pengobatan',
          tooltip: 'Riwayat pengobatan psikiatri yang pernah diterima pasien',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'riwayat_alergi',
          label: 'Riwayat Alergi',
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildPemeriksaanPsikologisSection(ColorScheme colorScheme) {
    return Column(
      children: [
        CustomTextField(
          name: 'kesadaran',
          label: 'Kesadaran',
          tooltip: 'Tingkat kesadaran pasien saat pemeriksaan',
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(name: 'tekanan_darah', label: 'TD (mmHg)'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CustomTextField(name: 'nadi', label: 'Nadi (x/m)'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CustomTextField(name: 'suhu', label: 'Suhu (°C)'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(name: 'pernapasan', label: 'RR (x/m)'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CustomTextField(name: 'berat_badan', label: 'BB (kg)'),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: CustomTextField(name: 'tinggi_badan', label: 'TB (cm)'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'orientasi',
          label: 'Orientasi',
          tooltip: 'Kemampuan pasien mengenal diri dan lingkungan',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'penampilan',
          label: 'Penampilan',
          tooltip: 'Deskripsi penampilan fisik pasien',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'perilaku',
          label: 'Perilaku',
          tooltip: 'Deskripsi perilaku pasien',
        ),
      ],
    );
  }

  Widget _buildFungsiPsikologisSection(ColorScheme colorScheme) {
    return Column(
      children: [
        CustomTextField(
          name: 'mood',
          label: 'Mood',
          tooltip: 'Perasaan umum pasien dalam periode waktu tertentu',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'afect',
          label: 'Afek',
          tooltip: 'Ekspresi emosional yang dapat diamati pada pasien',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'pikiran',
          label: 'Proses Pikir',
          tooltip: 'Proses berpikir pasien',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'alam_pikiran',
          label: 'Alam Pikiran',
          tooltip: 'Isi pikiran yang dipercakapkan pasien',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'diagnosis',
          label: 'Diagnosis Medis',
          tooltip: 'Diagnosis medis psikiatri',
        ), // This is distinct from Renpra Diagnosis
      ],
    );
  }

  Widget _buildFungsiSosialSection(ColorScheme colorScheme) {
    return Column(
      children: [
        CustomTextField(
          name: 'fungsi_sosial',
          label: 'Fungsi Sosial',
          tooltip: 'Kemampuan pasien dalam berinteraksi sosial',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'interaksi_sosial',
          label: 'Interaksi Sosial',
          tooltip: 'Cara pasien berinteraksi dengan orang lain',
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildFungsiSpiritualSection(ColorScheme colorScheme) {
    return Column(
      children: [
        CustomTextField(
          name: 'kepercayaan',
          label: 'Kepercayaan',
          tooltip: 'Keyakinan atau kepercayaan yang dianut pasien',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'praktik_ibadah',
          label: 'Praktik Ibadah',
          tooltip: 'Aktivitas keagamaan atau spiritual yang dilakukan pasien',
        ),
      ],
    );
  }

  Widget _buildRenpraSection(ColorScheme colorScheme) {
    final nursingService = Get.find<NursingDataGlobalService>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoBox(
          'Bagian ini khusus untuk Rencana Keperawatan (Renpra). Pilih diagnosis untuk memunculkan opsi intervensi.',
        ),
        const SizedBox(height: 16),
        Obx(() {
          final diagnoses = nursingService.diagnoses;
          if (diagnoses.isEmpty) {
            return const Center(child: Text('Data diagnosis tidak tersedia.'));
          }
          return CustomDropdown<int>(
            name: 'renpra_diagnosis', // Changed key to avoid conflict
            label: 'Diagnosis Keperawatan',
            tooltip: 'Pilih diagnosis keperawatan yang sesuai',
            items: diagnoses
                .map((d) => DropdownMenuItem(value: d.id, child: Text(d.name)))
                .toList(),
            onChanged: (val) {
              if (val == null) {
                // Clear dependent fields
                formKey.currentState?.fields['renpra_intervensi']?.didChange(
                  [],
                );
                formKey.currentState?.fields['renpra_tujuan']?.didChange(null);
                formKey.currentState?.fields['renpra_kriteria']?.didChange(
                  null,
                );
                formKey.currentState?.fields['renpra_rasional']?.didChange(
                  null,
                );
              }
            },
          );
        }),
        const SizedBox(height: 16),
        Obx(() {
          final interventions = _interventionController.interventions;

          if (interventions.isEmpty) {
            return const Center(child: Text('Tidak ada intervensi tersedia.'));
          }
          final options = interventions
              .map(
                (iv) =>
                    FormBuilderFieldOption(value: iv.id, child: Text(iv.name)),
              )
              .toList();

          return CustomCheckboxGroup<int>(
            name: 'renpra_intervensi', // Changed key
            label: 'Intervensi',
            tooltip: 'Pilih intervensi yang akan dilakukan',
            options: options,
          );
        }),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'renpra_tujuan',
          label: 'Tujuan',
          tooltip: 'Tujuan perawatan yang ingin dicapai',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'renpra_kriteria',
          label: 'Kriteria Evaluasi',
          tooltip: 'Kriteria untuk mengevaluasi pencapaian tujuan',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'renpra_rasional',
          label: 'Rasional',
          tooltip: 'Alasan atau landasan mengapa intervensi dipilih',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'terapi_farmakologi',
          label: 'Terapi Farmakologi',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'terapi_non_farmakologi',
          label: 'Terapi Non-Farmakologi',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        CustomTextField(name: 'edukasi', label: 'Edukasi', maxLines: 3),
      ],
    );
  }

  Widget _buildPenutupSection(ColorScheme colorScheme) {
    return Column(
      children: [
        CustomDateTimePicker(
          name: 'tanggal_kontrol_berikutnya',
          label: 'Tanggal Kontrol Berikutnya',
          inputType: InputType.date,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'rencana_tindak_lanjut',
          label: 'Rencana Tindak Lanjut',
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'catatan_tambahan',
          label: 'Catatan Tambahan',
          tooltip: 'Catatan tambahan atau informasi penting lainnya',
          maxLines: 5,
        ),
        const SizedBox(height: 16),
        CustomDateTimePicker(
          name: 'tanggal_pengisian',
          label: 'Tanggal Pengisian',
          tooltip: 'Tanggal formulir ini diisi',
          inputType: InputType.date,
          initialDate: DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now(),
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required ColorScheme colorScheme,
    required TextTheme textTheme,
    required String title,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 24),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoBox(String message) {
    return Container(
      padding: const EdgeInsets.all(12),
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

  Widget _buildBottomActionBar(ColorScheme colorScheme, TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (_currentSection > 0)
            ElevatedButton.icon(
              onPressed: _previousSection,
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
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

          Obx(
            () => FilledButton.icon(
              onPressed: formController.isLoading
                  ? null
                  : (_currentSection == _sectionTitles.length - 1
                        ? submitForm
                        : _nextSection),
              icon: formController.isLoading
                  ? const SizedBox.shrink()
                  : Icon(
                      _currentSection == _sectionTitles.length - 1
                          ? Icons.save_alt_rounded
                          : Icons.arrow_forward_ios_rounded,
                      size: 16,
                    ),
              label: formController.isLoading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.onPrimary,
                      ),
                    )
                  : Text(
                      _currentSection == _sectionTitles.length - 1
                          ? 'Simpan'
                          : 'Selanjutnya',
                    ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
