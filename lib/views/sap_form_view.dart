import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import '../controllers/form_controller.dart';
import '../controllers/patient_controller.dart';
import '../models/patient_model.dart';
import '../utils/form_builder_mixin.dart';
import '../widgets/form_components/custom_text_field.dart';
import '../widgets/form_components/custom_checkbox_group.dart';
import '../services/logger_service.dart';
import '../utils/ui_helpers.dart';

class SapFormView extends StatefulWidget {
  final Patient? patient;
  final int? formId;

  const SapFormView({super.key, this.patient, this.formId});

  @override
  State<SapFormView> createState() => _SapFormViewState();
}

class _SapFormViewState extends State<SapFormView> with FormBuilderMixin {
  @override
  final FormController formController = Get.put(FormController());
  @override
  final PatientController patientController = Get.find();
  final LoggerService _logger = LoggerService();

  int _currentSection = 0;
  final List<String> _materiFiles = [];
  final List<String> _fotoFiles = [];
  final List<String> _settingTempatFiles = [];

  @override
  String get formType => 'sap';

  @override
  int? get formId => widget.formId ?? Get.arguments?['formId'] as int?;

  Patient? _currentPatient;
  int? _currentPatientId;

  @override
  Patient? get currentPatient => _currentPatient;

  @override
  int? get currentPatientId => _currentPatientId;

  // Section titles for better UX
  final List<String> _sectionTitles = [
    '1. Identitas Kegiatan',
    '2. Tujuan',
    '3. Materi, Metode & Media',
    '4. Alokasi Waktu',
    '5. Perincian Tugas (Joblist)',
    '6. Pengorganisasian Tim',
    '7. Tabel Kegiatan',
    '8. Kriteria Evaluasi',
    '9. Daftar Pustaka',
    '10. Hasil Evaluasi - Info',
    '11. Hasil Evaluasi - Checklist',
    '12. Feedback Peserta',
  ];

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
    _logger.info('SapFormView initialized');
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
    // Scroll to top when changing sections
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        // Could implement scroll controller here if needed
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
        sectionContent = _buildTujuanSection();
        break;
      case 2:
        sectionContent = _buildMateriMetodeMediaSection();
        break;
      case 3:
        sectionContent = _buildAlokasiWaktuSection();
        break;
      case 4:
        sectionContent = _buildJoblistSection();
        break;
      case 5:
        sectionContent = _buildPengorganisasianSection();
        break;
      case 6:
        sectionContent = _buildTabelKegiatanSection();
        break;
      case 7:
        sectionContent = _buildEvaluasiSection();
        break;
      case 8:
        sectionContent = _buildDaftarPustakaSection();
        break;
      case 9:
        sectionContent = _buildHasilEvaluasiInfoSection();
        break;
      case 10:
        sectionContent = _buildHasilEvaluasiChecklistSection();
        break;
      case 11:
        sectionContent = _buildFeedbackSection();
        break;
      default:
        sectionContent = const SizedBox();
    }

    return KeyedSubtree(
      key: ValueKey('section_$sectionNumber'),
      child: sectionContent,
    );
  }

  // SECTION 1: IDENTITAS
  Widget _buildIdentitasSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Identitas Kegiatan',
          'Informasi dasar tentang kegiatan penyuluhan',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'topik',
          label: 'Topik *',
          tooltip: 'Topik utama dari kegiatan penyuluhan',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'sub_topik',
          label: 'Pokok Bahasan / Sub Topik *',
          tooltip: 'Sub topik atau pokok bahasan kegiatan penyuluhan',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'sasaran',
          label: 'Sasaran *',
          tooltip:
              'Sasaran peserta kegiatan penyuluhan (jumlah & karakteristik)',
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'tanggal_pelaksanaan',
          label: 'Hari/Tanggal Pelaksanaan *',
          tooltip: 'Tanggal kegiatan penyuluhan akan dilaksanakan',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'waktu_pelaksanaan',
          label: 'Waktu Pelaksanaan *',
          tooltip: 'Waktu mulai kegiatan penyuluhan (contoh: 09:00 - 11:00)',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'tempat',
          label: 'Tempat *',
          tooltip: 'Lokasi kegiatan penyuluhan dilaksanakan',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'durasi',
          label: 'Durasi Total (menit)',
          tooltip: 'Total durasi kegiatan dalam menit',
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }

  // SECTION 2: TUJUAN
  Widget _buildTujuanSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Tujuan Kegiatan',
          'Tujuan umum dan tujuan khusus dari kegiatan penyuluhan',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'tujuan_umum',
          label: 'Tujuan Umum *',
          tooltip: 'Tujuan umum dari kegiatan penyuluhan',
          maxLines: 4,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'tujuan_khusus',
          label: 'Tujuan Khusus *',
          tooltip: 'Tujuan khusus yang lebih spesifik dan terukur',
          maxLines: 6,
        ),
      ],
    );
  }

  // SECTION 3: MATERI, METODE & MEDIA
  Widget _buildMateriMetodeMediaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Materi, Metode & Media',
          'Materi penyuluhan, metode dan media yang digunakan',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'materi_penyuluhan',
          label: 'Materi Penyuluhan *',
          tooltip: 'Materi penyuluhan yang akan disampaikan',
          maxLines: 8,
        ),
        const SizedBox(height: 16),
        _buildSubSectionTitle('Metode Penyuluhan'),
        CustomTextField(
          name: 'metode',
          label: 'Metode *',
          tooltip:
              'Metode yang digunakan (pisahkan dengan koma). Contoh: Ceramah, Diskusi, Demonstrasi',
          maxLines: 3,
          hintText: 'Pisahkan dengan koma (,)',
        ),
        const SizedBox(height: 16),
        _buildSubSectionTitle('Media Penyuluhan'),
        CustomTextField(
          name: 'media',
          label: 'Media *',
          tooltip:
              'Media yang digunakan (pisahkan dengan koma). Contoh: Leaflet, PowerPoint, Video',
          maxLines: 3,
          hintText: 'Pisahkan dengan koma (,)',
        ),
        const SizedBox(height: 16),
        _buildSubSectionTitle('Upload Setting Tempat (Opsional)'),
        ElevatedButton.icon(
          onPressed: _uploadSettingTempat,
          icon: const Icon(Icons.upload_file),
          label: const Text('Upload Gambar/File Setting Tempat'),
        ),
        if (_settingTempatFiles.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text(
            'File Terupload:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          ..._settingTempatFiles.map(
            (file) => Padding(
              padding: const EdgeInsets.only(left: 8, top: 4),
              child: Text('✓ $file', style: const TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ],
    );
  }

  // SECTION 4: ALOKASI WAKTU DETAIL
  Widget _buildAlokasiWaktuSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Alokasi Waktu',
          'Rincian alokasi waktu untuk setiap tahap kegiatan',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'waktu_pembukaan',
          label: 'Waktu Pembukaan (menit) *',
          tooltip: 'Durasi pembukaan kegiatan dalam menit',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'waktu_penyampaian_materi',
          label: 'Waktu Penyampaian Materi (menit) *',
          tooltip: 'Durasi penyampaian materi dalam menit',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'waktu_tanya_jawab',
          label: 'Waktu Tanya Jawab (menit) *',
          tooltip: 'Durasi sesi tanya jawab dalam menit',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'waktu_penutup',
          label: 'Waktu Penutup (menit) *',
          tooltip: 'Durasi penutupan kegiatan dalam menit',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        _buildInfoBox('Total waktu akan dihitung otomatis sebagai referensi'),
      ],
    );
  }

  // SECTION 5: JOBLIST (PERINCIAN TUGAS)
  Widget _buildJoblistSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Perincian Tugas (Joblist)',
          'Rincian tugas untuk setiap peran dalam kegiatan',
        ),
        const SizedBox(height: 16),
        _buildSubSectionTitle('Joblist Penyuluh'),
        CustomTextField(
          name: 'joblist_penyuluh',
          label: 'Tugas Penyuluh',
          tooltip:
              'Rincian tugas yang dilakukan penyuluh (pisahkan dengan koma atau enter)',
          maxLines: 5,
          hintText: 'Contoh: 1) Membuka kegiatan, 2) Menyampaikan materi',
        ),
        const SizedBox(height: 16),
        _buildSubSectionTitle('Joblist Moderator'),
        CustomTextField(
          name: 'joblist_moderator',
          label: 'Tugas Moderator',
          tooltip: 'Rincian tugas yang dilakukan moderator',
          maxLines: 5,
        ),
        const SizedBox(height: 16),
        _buildSubSectionTitle('Joblist Fasilitator'),
        CustomTextField(
          name: 'joblist_fasilitator',
          label: 'Tugas Fasilitator',
          tooltip: 'Rincian tugas yang dilakukan fasilitator',
          maxLines: 5,
        ),
        const SizedBox(height: 16),
        _buildSubSectionTitle('Joblist Time Keeper'),
        CustomTextField(
          name: 'joblist_time_keeper',
          label: 'Tugas Time Keeper',
          tooltip: 'Rincian tugas yang dilakukan time keeper',
          maxLines: 5,
        ),
        const SizedBox(height: 16),
        _buildSubSectionTitle('Joblist Dokumentator'),
        CustomTextField(
          name: 'joblist_dokumentator',
          label: 'Tugas Dokumentator',
          tooltip: 'Rincian tugas yang dilakukan dokumentator',
          maxLines: 5,
        ),
        const SizedBox(height: 16),
        _buildSubSectionTitle('Joblist Observer'),
        CustomTextField(
          name: 'joblist_observer',
          label: 'Tugas Observer',
          tooltip: 'Rincian tugas yang dilakukan observer',
          maxLines: 5,
        ),
      ],
    );
  }

  // SECTION 6: PENGORGANISASIAN TIM
  Widget _buildPengorganisasianSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Pengorganisasian Tim',
          'Nama-nama anggota tim yang bertugas dalam kegiatan',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'penyaji',
          label: 'Nama Penyaji/Penyuluh *',
          tooltip: 'Nama petugas yang menjadi penyaji/penyuluh',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'moderator',
          label: 'Nama Moderator *',
          tooltip: 'Nama petugas yang menjadi moderator',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'fasilitator',
          label: 'Nama Fasilitator *',
          tooltip: 'Nama petugas yang menjadi fasilitator',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'time_keeper',
          label: 'Nama Time Keeper *',
          tooltip: 'Nama petugas yang menjadi time keeper',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'dokumentator',
          label: 'Nama Dokumentator *',
          tooltip: 'Nama petugas yang menjadi dokumentator',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'observer',
          label: 'Nama Observer *',
          tooltip: 'Nama petugas yang menjadi observer',
        ),
      ],
    );
  }

  // SECTION 7: TABEL KEGIATAN
  Widget _buildTabelKegiatanSection() {
    final tabelKegiatan =
        formKey.currentState?.fields['tabel_kegiatan']?.value as List? ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Tabel Kegiatan Penyuluhan',
          'Rincian kegiatan per tahap dengan waktu dan aktivitas',
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () => _showTabelKegiatanDialog(),
          icon: const Icon(Icons.add),
          label: const Text('Tambah Kegiatan'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
        const SizedBox(height: 16),
        if (tabelKegiatan.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tabelKegiatan.length,
            itemBuilder: (context, index) {
              final kegiatan = tabelKegiatan[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(child: Text('${index + 1}')),
                  title: Text(
                    'Tahap: ${kegiatan['tahap'] ?? '-'}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Waktu: ${kegiatan['waktu'] ?? '-'}'),
                      Text(
                        'Penyuluh: ${kegiatan['kegiatan_penyuluh'] ?? '-'}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showTabelKegiatanDialog(
                          index: index,
                          existingData: kegiatan,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          final updated = List.from(tabelKegiatan)
                            ..removeAt(index);
                          formKey.currentState?.fields['tabel_kegiatan']
                              ?.didChange(updated);
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          )
        else
          _buildInfoBox(
            'Belum ada kegiatan ditambahkan. Klik tombol "Tambah Kegiatan" untuk menambah.',
          ),
      ],
    );
  }

  void _showTabelKegiatanDialog({
    int? index,
    Map<String, dynamic>? existingData,
  }) {
    final tahapController = TextEditingController(text: existingData?['tahap']);
    final waktuController = TextEditingController(text: existingData?['waktu']);
    final kegiatanPenyuluhController = TextEditingController(
      text: existingData?['kegiatan_penyuluh'],
    );
    final kegiatanPesertaController = TextEditingController(
      text: existingData?['kegiatan_peserta'],
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              existingData != null ? Icons.edit : Icons.add,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(width: 8),
            Text(existingData != null ? 'Edit Kegiatan' : 'Tambah Kegiatan'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tahapController,
                decoration: const InputDecoration(
                  labelText: 'Tahap *',
                  hintText: 'Contoh: Pembukaan, Penyampaian Materi',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: waktuController,
                decoration: const InputDecoration(
                  labelText: 'Waktu *',
                  hintText: 'Contoh: 5 menit',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: kegiatanPenyuluhController,
                decoration: const InputDecoration(
                  labelText: 'Kegiatan Penyuluh *',
                  hintText: 'Apa yang dilakukan penyuluh',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: kegiatanPesertaController,
                decoration: const InputDecoration(
                  labelText: 'Kegiatan Peserta *',
                  hintText: 'Apa yang dilakukan peserta',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (tahapController.text.isEmpty ||
                  waktuController.text.isEmpty ||
                  kegiatanPenyuluhController.text.isEmpty ||
                  kegiatanPesertaController.text.isEmpty) {
                UIHelpers.showError(
                  title: 'Error',
                  message: 'Semua field harus diisi',
                );
                return;
              }

              final newKegiatan = {
                'tahap': tahapController.text,
                'waktu': waktuController.text,
                'kegiatan_penyuluh': kegiatanPenyuluhController.text,
                'kegiatan_peserta': kegiatanPesertaController.text,
              };

              final tabelKegiatan = List.from(
                formKey.currentState?.fields['tabel_kegiatan']?.value ?? [],
              );
              if (index != null) {
                tabelKegiatan[index] = newKegiatan;
              } else {
                tabelKegiatan.add(newKegiatan);
              }
              formKey.currentState?.fields['tabel_kegiatan']?.didChange(
                tabelKegiatan,
              );
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  // SECTION 8: EVALUASI
  Widget _buildEvaluasiSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Kriteria Evaluasi',
          'Evaluasi input, proses, dan hasil kegiatan penyuluhan',
        ),
        const SizedBox(height: 16),
        _buildSubSectionTitle('1. Evaluasi Input'),
        const Text(
          'Evaluasi terhadap kesiapan sebelum kegiatan dilaksanakan',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          name: 'evaluasi_input',
          label: 'Evaluasi Input *',
          tooltip: 'Evaluasi kesiapan peserta, tempat, tim, materi, dan media',
          maxLines: 5,
          hintText:
              'Contoh: Kesiapan peserta, tempat, tim penyaji, materi, media',
        ),
        const SizedBox(height: 16),
        _buildSubSectionTitle('2. Evaluasi Proses'),
        const Text(
          'Evaluasi terhadap jalannya kegiatan penyuluhan',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          name: 'evaluasi_proses',
          label: 'Evaluasi Proses *',
          tooltip: 'Evaluasi proses pelaksanaan kegiatan penyuluhan',
          maxLines: 5,
        ),
        const SizedBox(height: 16),
        _buildSubSectionTitle('3. Evaluasi Hasil'),
        const Text(
          'Evaluasi terhadap hasil atau outcome kegiatan',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          name: 'evaluasi_hasil',
          label: 'Evaluasi Hasil *',
          tooltip: 'Evaluasi hasil dari kegiatan penyuluhan',
          maxLines: 5,
        ),
      ],
    );
  }

  // SECTION 9: DAFTAR PUSTAKA
  Widget _buildDaftarPustakaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Daftar Pustaka',
          'Sumber referensi yang digunakan dalam materi penyuluhan',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'daftar_pustaka',
          label: 'Daftar Pustaka *',
          tooltip: 'Daftar sumber referensi yang digunakan',
          maxLines: 10,
          hintText: 'Tuliskan daftar pustaka sesuai format yang berlaku',
        ),
        const SizedBox(height: 16),
        _buildSubSectionTitle('Upload Materi Penyuluhan (Opsional)'),
        ElevatedButton.icon(
          onPressed: _uploadMaterials,
          icon: const Icon(Icons.upload_file),
          label: const Text('Upload File Materi'),
        ),
        if (_materiFiles.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text(
            'Materi Terupload:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          ..._materiFiles.map(
            (file) => Padding(
              padding: const EdgeInsets.only(left: 8, top: 4),
              child: Text('✓ $file', style: const TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ],
    );
  }

  // SECTION 10: HASIL EVALUASI - INFO PELAKSANAAN
  Widget _buildHasilEvaluasiInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Hasil Evaluasi - Info Pelaksanaan',
          'Informasi aktual pelaksanaan kegiatan (diisi setelah kegiatan)',
        ),
        const SizedBox(height: 16),
        _buildInfoBox('Section ini diisi SETELAH kegiatan dilaksanakan'),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'hasil_hari_tanggal',
          label: 'Tanggal Pelaksanaan Aktual',
          tooltip: 'Tanggal aktual saat kegiatan dilaksanakan',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'hasil_waktu',
          label: 'Waktu Pelaksanaan Aktual',
          tooltip: 'Waktu aktual pelaksanaan kegiatan',
        ),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'hasil_sasaran',
          label: 'Sasaran Aktual',
          tooltip: 'Jumlah dan karakteristik peserta yang hadir',
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        _buildSubSectionTitle('Tim yang Bertugas (Aktual)'),
        CustomTextField(name: 'hasil_moderator', label: 'Moderator'),
        const SizedBox(height: 12),
        CustomTextField(name: 'hasil_penyaji', label: 'Penyaji'),
        const SizedBox(height: 12),
        CustomTextField(name: 'hasil_observer', label: 'Observer'),
        const SizedBox(height: 12),
        CustomTextField(name: 'hasil_fasilitator', label: 'Fasilitator'),
        const SizedBox(height: 12),
        CustomTextField(name: 'hasil_time_keeper', label: 'Time Keeper'),
        const SizedBox(height: 12),
        CustomTextField(name: 'hasil_dokumentator', label: 'Dokumentator'),
        const SizedBox(height: 16),
        CustomTextField(
          name: 'hasil_media',
          label: 'Media yang Digunakan',
          tooltip: 'Media yang benar-benar digunakan saat pelaksanaan',
          maxLines: 2,
        ),
      ],
    );
  }

  // SECTION 11: HASIL EVALUASI - CHECKLIST
  Widget _buildHasilEvaluasiChecklistSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Hasil Evaluasi - Checklist',
          'Checklist evaluasi input dan hasil keseluruhan',
        ),
        const SizedBox(height: 16),
        _buildSubSectionTitle('Evaluasi Input (Checklist)'),
        const Text(
          'Centang item yang terpenuhi saat persiapan',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        CustomCheckboxGroup<String>(
          name: 'hasil_evaluasi_input',
          label: '',
          tooltip: 'Centang item yang terpenuhi',
          options: const [
            FormBuilderFieldOption(
              value: 'kesiapan_peserta',
              child: Text('Kesiapan Peserta Penyuluhan'),
            ),
            FormBuilderFieldOption(
              value: 'kesiapan_tempat',
              child: Text('Kesiapan Tempat Pelaksanaan'),
            ),
            FormBuilderFieldOption(
              value: 'kesiapan_tim',
              child: Text('Kesiapan Tim Penyaji'),
            ),
            FormBuilderFieldOption(
              value: 'kesiapan_materi',
              child: Text('Kesiapan Materi Penyaji'),
            ),
            FormBuilderFieldOption(
              value: 'kesiapan_media',
              child: Text('Kesiapan Media Penyuluhan'),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _buildSubSectionTitle('Evaluasi Seluruh Hasil (Checklist)'),
        const Text(
          'Centang item yang tercapai dalam pelaksanaan',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        CustomCheckboxGroup<String>(
          name: 'hasil_evaluasi_seluruh',
          label: '',
          tooltip: 'Centang item yang tercapai',
          options: const [
            FormBuilderFieldOption(
              value: 'berjalan_sesuai_waktu',
              child: Text(
                'Kegiatan berjalan sesuai dengan waktu yang ditentukan',
              ),
            ),
            FormBuilderFieldOption(
              value: 'materi_jelas',
              child: Text('Penyaji memberikan materi dengan jelas'),
            ),
            FormBuilderFieldOption(
              value: 'peserta_menjawab',
              child: Text('Peserta dapat menjawab pertanyaan moderator'),
            ),
            FormBuilderFieldOption(
              value: 'peserta_mengikuti',
              child: Text(
                'Peserta mengikuti kegiatan dari awal hingga selesai',
              ),
            ),
            FormBuilderFieldOption(
              value: 'ada_dokumentasi',
              child: Text('Melakukan dokumentasi kegiatan'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildSubSectionTitle('Upload Dokumentasi Foto'),
        ElevatedButton.icon(
          onPressed: _uploadPhotos,
          icon: const Icon(Icons.camera_alt),
          label: const Text('Upload Foto Kegiatan'),
        ),
        if (_fotoFiles.isNotEmpty) ...[
          const SizedBox(height: 8),
          const Text(
            'Foto Terupload:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          ..._fotoFiles.map(
            (file) => Padding(
              padding: const EdgeInsets.only(left: 8, top: 4),
              child: Text('✓ $file', style: const TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ],
    );
  }

  // SECTION 12: FEEDBACK PESERTA
  Widget _buildFeedbackSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          'Feedback Peserta',
          'Pertanyaan dan saran dari peserta setelah kegiatan',
        ),
        const SizedBox(height: 16),
        _buildSubSectionTitle('Pertanyaan Peserta'),
        const Text(
          'Pertanyaan yang diajukan peserta selama kegiatan',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          name: 'pertanyaan_peserta',
          label: 'Pertanyaan Peserta',
          tooltip:
              'Tulis pertanyaan yang diajukan peserta (pisahkan dengan enter atau nomor)',
          maxLines: 6,
          hintText: 'Contoh:\n1) Pertanyaan pertama\n2) Pertanyaan kedua',
        ),
        const SizedBox(height: 16),
        _buildSubSectionTitle('Saran Peserta'),
        const Text(
          'Saran yang diberikan peserta untuk perbaikan',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        CustomTextField(
          name: 'saran_peserta',
          label: 'Saran Peserta',
          tooltip:
              'Tulis saran yang diberikan peserta (pisahkan dengan enter atau nomor)',
          maxLines: 6,
          hintText: 'Contoh:\n1) Saran pertama\n2) Saran kedua',
        ),
      ],
    );
  }

  // HELPER WIDGETS
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

  Widget _buildSubSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
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

  // UPLOAD FUNCTIONS
  Future<void> _uploadSettingTempat() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png', 'doc', 'docx'],
      allowMultiple: false,
    );

    if (result != null && result.paths.first != null) {
      bool success = await _uploadFileToServer(
        File(result.paths.first!),
        'setting-tempat',
      );
      if (success) {
        setState(
          () => _settingTempatFiles.add(result.paths.first!.split('/').last),
        );
      }
    }
  }

  Future<void> _uploadMaterials() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'ppt', 'pptx'],
      allowMultiple: true,
    );

    if (result != null) {
      for (var path in result.paths) {
        if (path != null) {
          bool success = await _uploadFileToServer(File(path), 'material');
          if (success) setState(() => _materiFiles.add(path.split('/').last));
        }
      }
    }
  }

  Future<void> _uploadPhotos() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: true,
    );

    if (result != null) {
      for (var path in result.paths) {
        if (path != null) {
          bool success = await _uploadFileToServer(File(path), 'photo');
          if (success) setState(() => _fotoFiles.add(path.split('/').last));
        }
      }
    }
  }

  Future<bool> _uploadFileToServer(File file, String type) async {
    int? currentFormId = formId;
    if (currentFormId == null) {
      UIHelpers.showWarning(
        title: 'Peringatan',
        message: 'Simpan form terlebih dahulu sebelum upload file',
      );
      return false;
    }

    // Map legacy local types to controller types
    String controllerType = type;
    if (type == 'setting-tempat') controllerType = 'lainnya';
    if (type == 'material') controllerType = 'materi';
    if (type == 'photo') controllerType = 'foto';

    return await formController.uploadDocumentation(
      formId: currentFormId,
      filePath: file.path,
      type: controllerType,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.formId == null
              ? 'Form SAP (Satuan Acara Penyuluhan)'
              : 'Edit Form SAP',
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        elevation: 2,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Progress Indicator
            LinearProgressIndicator(
              value: (_currentSection + 1) / _sectionTitles.length,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
            const SizedBox(height: 12),
            // Section Info
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      _sectionTitles[_currentSection],
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '${_currentSection + 1}/${_sectionTitles.length}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Form Content
            Expanded(
              child: SingleChildScrollView(
                child: FormBuilder(
                  key: formKey,
                  initialValue: initialValues,
                  child: _buildSection(_currentSection),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Navigation Buttons
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
                      padding: const EdgeInsets.only(left: 8),
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
