import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../constants/api_config.dart';
import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/form_controller.dart';
import '../controllers/patient_controller.dart';
import '../models/patient_model.dart';
import '../utils/form_builder_mixin.dart';
import '../widgets/form_components/custom_text_field.dart';
import '../services/logger_service.dart';
import '../utils/ui_helpers.dart';

class TerapiAktivitasKelompokFormView extends StatefulWidget {
  final Patient? patient;
  final int? formId;

  const TerapiAktivitasKelompokFormView({super.key, this.patient, this.formId});

  @override
  State<TerapiAktivitasKelompokFormView> createState() =>
      _TerapiAktivitasKelompokFormViewState();
}

class _TerapiAktivitasKelompokFormViewState
    extends State<TerapiAktivitasKelompokFormView>
    with FormBuilderMixin {
  @override
  final FormController formController = Get.put(FormController());
  @override
  final PatientController patientController = Get.find();
  final LoggerService _logger = LoggerService();

  int _currentSection = 0;
  final List<String> _settingTempatFiles = [];
  final List<String> _dokumentasiFiles = [];

  @override
  String get formType => 'terapi_aktivitas_kelompok';

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
    _logger.info('TerapiAktivitasKelompokFormView initialized');
  }

  @override
  Map<String, dynamic> transformInitialData(Map<String, dynamic> data) {
    // Data is already reverse-mapped by FormBuilderMixin.loadFormData()
    // via FormDataMapper.mapFromApiFormat()
    return data;
  }

  void _nextSection() {
    updateFormData();
    if (_currentSection < 8) {
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
        sectionContent = _buildLatarBelakangSection();
        break;
      case 1:
        sectionContent = _buildTujuanSection();
        break;
      case 2:
        sectionContent = _buildPersiapanKlienSection();
        break;
      case 3:
        sectionContent = _buildPengorganisasianSection();
        break;
      case 4:
        sectionContent = _buildJadwalSection();
        break;
      case 5:
        sectionContent = _buildSettingTempatSection();
        break;
      case 6:
        sectionContent = _buildAlatMetodeSection();
        break;
      case 7:
        sectionContent = _buildSesiKegiatanSection();
        break;
      case 8:
        sectionContent = _buildDaftarPustakaSection();
        break;
      default:
        sectionContent = const SizedBox();
    }

    return KeyedSubtree(
      key: ValueKey('section_$sectionNumber'),
      child: sectionContent,
    );
  }

  Widget _buildLatarBelakangSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'A. Latar Belakang',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'latar_belakang',
          label: 'Latar Belakang',
          tooltip: 'Jelaskan latar belakang terapi aktivitas kelompok',
          maxLines: 8,
        ),
      ],
    );
  }

  Widget _buildTujuanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'B. Tujuan Terapi Aktivitas Kelompok',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'tujuan_umum',
          label: '1. Tujuan Umum',
          tooltip: 'Tujuan umum dari terapi aktivitas kelompok',
          maxLines: 4,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'tujuan_khusus',
          label: '2. Tujuan Khusus',
          tooltip: 'Tujuan khusus dari terapi aktivitas kelompok',
          maxLines: 6,
        ),
      ],
    );
  }

  Widget _buildPersiapanKlienSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'C. Persiapan Klien',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'karakteristik_klien',
          label: '1. Karakteristik Klien',
          tooltip: 'Jelaskan karakteristik klien yang akan mengikuti terapi',
          maxLines: 4,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'proses_seleksi_klien',
          label: '2. Proses Seleksi Klien',
          tooltip: 'Jelaskan proses seleksi klien untuk terapi',
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildPengorganisasianSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'D. Pengorganisasian',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text(
          'Uraian Tugas Tim',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        CustomTextField(
          name: 'leader_sesi_1',
          label: '1) Leader - Sesi 1',
          tooltip: 'Nama leader untuk sesi 1',
        ),
        const SizedBox(height: 12),
        CustomTextField(
          name: 'leader_sesi_2',
          label: 'Leader - Sesi 2',
          tooltip: 'Nama leader untuk sesi 2',
        ),
        const SizedBox(height: 12),
        CustomTextField(
          name: 'uraian_tugas_leader',
          label: 'Uraian Tugas Leader',
          tooltip: 'Jelaskan uraian tugas leader',
          maxLines: 4,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'observer_fasilitator_sesi_1',
          label: '2) Observer/Fasilitator - Sesi 1',
          tooltip: 'Nama observer/fasilitator untuk sesi 1',
        ),
        const SizedBox(height: 12),
        CustomTextField(
          name: 'observer_fasilitator_sesi_2',
          label: 'Observer/Fasilitator - Sesi 2',
          tooltip: 'Nama observer/fasilitator untuk sesi 2',
        ),
        const SizedBox(height: 12),
        CustomTextField(
          name: 'uraian_tugas_observer',
          label: 'Uraian Tugas Observer/Fasilitator',
          tooltip: 'Jelaskan uraian tugas observer/fasilitator',
          maxLines: 4,
        ),
      ],
    );
  }

  Widget _buildJadwalSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'a. Jadwal Pelaksanaan',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        const Text(
          'Pelaksanaan kegiatan terapi aktivitas kelompok',
          style: TextStyle(fontSize: 14),
        ),
        const SizedBox(height: 16),
        const Text(
          '1) Sesi 1-5',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        CustomTextField(
          name: 'hari_tanggal',
          label: 'a) Hari/Tanggal',
          tooltip: 'Masukkan hari dan tanggal pelaksanaan',
        ),
        const SizedBox(height: 12),
        CustomTextField(
          name: 'waktu',
          label: 'b) Waktu',
          tooltip: 'Masukkan waktu pelaksanaan',
        ),
        const SizedBox(height: 12),
        CustomTextField(
          name: 'alokasi_waktu',
          label: 'c) Alokasi Waktu (menit)',
          tooltip: 'Masukkan alokasi waktu dalam menit',
        ),
        const SizedBox(height: 12),
        CustomTextField(
          name: 'sasaran',
          label: 'd) Sasaran (jumlah pasien)',
          tooltip: 'Masukkan jumlah pasien yang menjadi sasaran',
        ),
        const SizedBox(height: 12),
        CustomTextField(
          name: 'tempat',
          label: 'e) Tempat',
          tooltip: 'Masukkan tempat pelaksanaan',
        ),
      ],
    );
  }

  Widget _buildSettingTempatSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'b. Setting Tempat',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'keterangan_setting',
          label: 'Keterangan',
          tooltip: 'Jelaskan setting tempat terapi',
          maxLines: 4,
        ),
        const SizedBox(height: 12),
        CustomTextField(
          name: 'leader',
          label: '1) Leader',
          tooltip: 'Keterangan posisi leader',
        ),
        const SizedBox(height: 12),
        CustomTextField(
          name: 'observer_fasilitator',
          label: '2) Observer/Fasilitator',
          tooltip: 'Keterangan posisi observer/fasilitator',
        ),
        const SizedBox(height: 12),
        CustomTextField(
          name: 'peserta',
          label: '3) Peserta',
          tooltip: 'Keterangan posisi peserta',
        ),
        const SizedBox(height: 12),
        CustomTextField(
          name: 'pembimbing',
          label: '4) Pembimbing',
          tooltip: 'Keterangan posisi pembimbing',
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _uploadSettingTempat,
          icon: const Icon(Icons.upload_file),
          label: const Text('Upload File Setting Tempat'),
        ),
        if (_settingTempatFiles.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text(
            'File Terupload:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          ..._settingTempatFiles.map((file) => Text('• $file')),
        ],
      ],
    );
  }

  Widget _buildAlatMetodeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'c. Alat & e. Metode',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'alat',
          label: 'c. Alat',
          tooltip:
              'Sebutkan alat-alat yang digunakan dalam terapi (pisahkan dengan enter)',
          maxLines: 5,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'metode',
          label: 'e. Metode',
          tooltip:
              'Sebutkan metode yang digunakan dalam terapi (pisahkan dengan enter)',
          maxLines: 5,
        ),
      ],
    );
  }

  Widget _buildSesiKegiatanSection() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '4. Proses Pelaksanaan Terapi Aktivitas Kelompok',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Sesi 1
          _buildSesiCard(1),
          const SizedBox(height: 16),

          // Sesi 2
          _buildSesiCard(2),
          const SizedBox(height: 16),

          // Sesi 3
          _buildSesiCard(3),
          const SizedBox(height: 16),

          // Sesi 4
          _buildSesiCard(4),
          const SizedBox(height: 16),

          // Sesi 5
          _buildSesiCard(5),
          const SizedBox(height: 16),

          // Evaluasi & Dokumentasi
          CustomTextField(
            name: 'evaluasi',
            label: '5) Evaluasi',
            tooltip: 'Evaluasi dari keseluruhan terapi aktivitas kelompok',
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _uploadDokumentasi,
            icon: const Icon(Icons.upload_file),
            label: const Text('Upload Dokumentasi'),
          ),
          if (_dokumentasiFiles.isNotEmpty) ...[
            const SizedBox(height: 8),
            const Text(
              'Dokumentasi Terupload:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            ..._dokumentasiFiles.map((file) => Text('• $file')),
          ],
        ],
      ),
    );
  }

  Widget _buildSesiCard(int sesiNumber) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Sesi $sesiNumber',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            CustomTextField(
              name: 'sesi_${sesiNumber}_persiapan',
              label: '1) Persiapan',
              tooltip: 'Persiapan untuk sesi $sesiNumber',
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            const Text(
              '2) Fase Orientasi',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              name: 'sesi_${sesiNumber}_salam_terapeutik',
              label: 'a) Salam Terapeutik',
              tooltip: 'Salam terapeutik untuk sesi $sesiNumber',
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            CustomTextField(
              name: 'sesi_${sesiNumber}_evaluasi_validasi',
              label: 'b) Evaluasi/Validasi',
              tooltip: 'Evaluasi/validasi untuk sesi $sesiNumber',
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            CustomTextField(
              name: 'sesi_${sesiNumber}_kontrak',
              label: 'c) Kontrak',
              tooltip: 'Kontrak untuk sesi $sesiNumber',
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            CustomTextField(
              name: 'sesi_${sesiNumber}_fase_kerja',
              label: '3) Fase Kerja',
              tooltip: 'Fase kerja untuk sesi $sesiNumber',
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            const Text(
              '4) Fase Terminasi',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            CustomTextField(
              name: 'sesi_${sesiNumber}_evaluasi_terminasi',
              label: 'a) Evaluasi',
              tooltip: 'Evaluasi fase terminasi untuk sesi $sesiNumber',
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            CustomTextField(
              name: 'sesi_${sesiNumber}_tindak_lanjut',
              label: 'b) Tindak Lanjut',
              tooltip: 'Tindak lanjut untuk sesi $sesiNumber',
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            CustomTextField(
              name: 'sesi_${sesiNumber}_kontrak_datang',
              label: 'c) Kontrak yang Akan Datang',
              tooltip: 'Kontrak yang akan datang untuk sesi $sesiNumber',
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDaftarPustakaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DAFTAR PUSTAKA',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'daftar_pustaka',
          label: 'Daftar Pustaka',
          tooltip:
              'Masukkan daftar pustaka yang digunakan (pisahkan dengan enter)',
          maxLines: 8,
        ),
      ],
    );
  }

  Future<void> _uploadSettingTempat() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
      allowMultiple: true,
    );

    if (result != null) {
      for (var path in result.paths) {
        if (path != null) {
          bool success = await _uploadFileToServer(
            File(path),
            'setting-tempat',
          );
          if (success) {
            setState(() => _settingTempatFiles.add(path.split('/').last));
          }
        }
      }
    }
  }

  Future<void> _uploadDokumentasi() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
      allowMultiple: true,
    );

    if (result != null) {
      for (var path in result.paths) {
        if (path != null) {
          bool success = await _uploadFileToServer(File(path), 'dokumentasi');
          if (success) {
            setState(() => _dokumentasiFiles.add(path.split('/').last));
          }
        }
      }
    }
  }

  Future<bool> _uploadFileToServer(File file, String type) async {
    int? formId = widget.formId;
    if (formId == null) {
      UIHelpers.showWarning(
        title: 'Peringatan',
        message: 'Simpan form terlebih dahulu sebelum upload file',
      );
      return false;
    }

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.currentBaseUrl}/forms/$formId/upload-$type'),
      );

      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      request.headers['Authorization'] = 'Bearer $token';
      request.files.add(
        await http.MultipartFile.fromPath(
          'file',
          file.path,
          filename: file.path.split('/').last,
        ),
      );

      var response = await request.send();
      if (response.statusCode == 201) {
        UIHelpers.showSuccess(
          title: 'Sukses',
          message: 'File berhasil diupload',
        );
        return true;
      } else {
        UIHelpers.showError(title: 'Error', message: 'Gagal mengupload file');
        return false;
      }
    } catch (e) {
      UIHelpers.showError(title: 'Error', message: 'Upload gagal: $e');
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.formId == null
              ? 'Form Terapi Aktivitas Kelompok'
              : 'Edit Terapi Aktivitas Kelompok',
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            LinearProgressIndicator(value: (_currentSection + 1) / 9),
            const SizedBox(height: 16),
            Text('Bagian ${_currentSection + 1} dari 9'),
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
                if (_currentSection == 8)
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
