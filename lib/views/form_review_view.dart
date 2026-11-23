import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/form_controller.dart';
import '../controllers/nursing_diagnosis_controller.dart';
import '../controllers/nursing_intervention_controller.dart';
import '../controllers/review_controller.dart';
import '../models/form_model.dart';
import '../services/logger_service.dart';
import '../theme/app_theme.dart';
import '../utils/form_types.dart';
import '../utils/ui_helpers.dart';
import '../widgets/ds/ds.dart';

/// Satu bagian formulir yang bisa dikomentari dosen.
class _Field {
  final String label;
  final List<String> path;
  const _Field(this.label, this.path);
}

class _Section {
  final String key;
  final String title;
  final List<_Field> fields;
  const _Section(this.key, this.title, this.fields);
}

const _renpra = [
  'diagnosis',
  'tujuan',
  'kriteria',
  'rasional',
];

List<_Field> _renpraFields(List<String> prefix) => [
      for (final k in _renpra)
        _Field(k[0].toUpperCase() + k.substring(1), [...prefix, k]),
    ];

final Map<String, List<_Section>> _specs = {
  'pengkajian': [
    const _Section('section_1', 'Identitas klien', [
      _Field('Nama lengkap', ['section_1', 'nama_lengkap']),
      _Field('Umur', ['section_1', 'umur']),
      _Field('Jenis kelamin', ['section_1', 'jenis_kelamin']),
      _Field('Status perkawinan', ['section_1', 'status_perkawinan']),
    ]),
    const _Section('section_2', 'Riwayat kehidupan', [
      _Field('Riwayat pendidikan', ['section_2', 'riwayat_pendidikan']),
      _Field('Pekerjaan', ['section_2', 'pekerjaan']),
      _Field('Riwayat keluarga', ['section_2', 'riwayat_keluarga']),
    ]),
    _Section('section_10', 'Rencana perawatan', _renpraFields(['section_10'])),
  ],
  'resume_kegawatdaruratan': [
    const _Section('identitas', 'Identitas', [
      _Field('Nama lengkap', ['identitas', 'nama_lengkap']),
      _Field('Umur', ['identitas', 'umur']),
      _Field('Jenis kelamin', ['identitas', 'jenis_kelamin']),
      _Field('Alamat', ['identitas', 'alamat']),
      _Field('Tanggal masuk', ['identitas', 'tanggal_masuk']),
    ]),
    _Section('renpra', 'Rencana perawatan', [
      ..._renpraFields(['renpra']),
      const _Field('Evaluasi', ['renpra', 'evaluasi']),
    ]),
  ],
  'resume_poliklinik': [
    const _Section('section_1', 'Identitas klien', [
      _Field('Nama lengkap', ['section_1', 'nama_lengkap']),
      _Field('Umur', ['section_1', 'umur']),
      _Field('Jenis kelamin', ['section_1', 'jenis_kelamin']),
      _Field('Status perkawinan', ['section_1', 'status_perkawinan']),
    ]),
    _Section('section_9', 'Rencana perawatan', _renpraFields(['section_9'])),
  ],
  'sap': [
    const _Section('identitas', 'Identitas kegiatan', [
      _Field('Topik', ['identitas', 'topik']),
      _Field('Sasaran', ['identitas', 'sasaran']),
      _Field('Waktu', ['identitas', 'waktu']),
      _Field('Tempat', ['identitas', 'tempat']),
    ]),
    const _Section('tujuan', 'Tujuan', [
      _Field('Tujuan umum', ['tujuan', 'umum']),
      _Field('Tujuan khusus', ['tujuan', 'khusus']),
    ]),
    _Section('renpra', 'Renpra (opsional)', _renpraFields(['renpra'])),
  ],
  'catatan_tambahan': [
    const _Section('catatan', 'Catatan', [
      _Field('Isi catatan', ['catatan', 'isi_catatan']),
    ]),
    _Section('renpra', 'Renpra (opsional)', _renpraFields(['catatan', 'renpra'])),
  ],
};

dynamic _dig(Map<String, dynamic> data, List<String> path) {
  dynamic cur = data;
  for (final k in path) {
    if (cur is Map && cur.containsKey(k)) {
      cur = cur[k];
    } else {
      return null;
    }
  }
  return cur;
}

/// Untuk jenis tanpa spesifikasi: tiap kunci tingkat atas jadi satu bagian.
List<_Section> _genericSections(Map<String, dynamic> data) {
  final out = <_Section>[];
  final loose = <_Field>[];
  data.forEach((k, v) {
    if (v is Map) {
      final fields = <_Field>[];
      v.forEach((k2, v2) {
        if (v2 is! Map && v2 is! List) fields.add(_Field(_humanize(k2.toString()), [k, k2.toString()]));
      });
      if (fields.isNotEmpty) out.add(_Section(k, _humanize(k), fields));
    } else if (v is! List) {
      loose.add(_Field(_humanize(k), [k]));
    }
  });
  if (loose.isNotEmpty) out.insert(0, _Section('umum', 'Umum', loose));
  return out;
}

String _humanize(String key) {
  final t = key.replaceAll('_', ' ').trim();
  return t.isEmpty ? key : t[0].toUpperCase() + t.substring(1);
}

class FormReviewView extends StatefulWidget {
  const FormReviewView({super.key});

  @override
  State<FormReviewView> createState() => _FormReviewViewState();
}

class _FormReviewViewState extends State<FormReviewView> {
  final FormController formController = Get.put(FormController());
  final NursingDiagnosisController _diagnosisController = Get.put(
    NursingDiagnosisController(),
  );
  final NursingInterventionController _interventionController = Get.put(
    NursingInterventionController(),
  );
  final TextEditingController _commentController = TextEditingController();
  final TextEditingController _scoreController = TextEditingController();
  final LoggerService _logger = LoggerService();
  late int formId;
  late final Future<FormModel?> _future;

  String _status = 'submitted';
  bool _submitting = false;

  /// Komentar per bagian yang baru ditulis dosen pada sesi ini.
  final Map<String, String> _pending = {};

  @override
  void initState() {
    super.initState();
    formId = int.tryParse(Get.parameters['formId'] ?? '') ?? 0;
    _logger.info('FormReviewView diinisialisasi', context: {'formId': formId});
    _future = formController.getFormById(formId).then((f) {
      if (f != null && mounted) setState(() => _status = f.status);
      return f;
    });
  }

  @override
  void dispose() {
    _scoreController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  bool get _canReview => _status == 'submitted' && !_submitting;

  Future<void> _editComment(String key, String title) async {
    final ctrl = TextEditingController(text: _pending[key] ?? '');
    final result = await Get.bottomSheet<String>(
      SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(
              20, 16, 20, 16 + MediaQuery.of(Get.context!).viewInsets.bottom),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Komentar: $title',
                  style: Get.theme.textTheme.titleLarge),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: ctrl,
              autofocus: true,
              maxLines: 4,
              maxLength: 2000,
              decoration: const InputDecoration(
                  hintText: 'Apa yang perlu diperbaiki di bagian ini?'),
            ),
            const SizedBox(height: 8),
            Row(children: [
              if ((_pending[key] ?? '').isNotEmpty)
                TextButton(
                  onPressed: () => Get.back(result: ''),
                  child: const Text('Hapus'),
                ),
              const Spacer(),
              FilledButton(
                onPressed: () => Get.back(result: ctrl.text.trim()),
                child: const Text('Simpan komentar'),
              ),
            ]),
          ]),
        ),
      ),
      isScrollControlled: true,
    );
    ctrl.dispose();
    if (result == null) return;
    setState(() {
      if (result.isEmpty) {
        _pending.remove(key);
      } else {
        _pending[key] = result;
      }
    });
  }

  Future<void> _reviewForm(String status) async {
    final overall = _commentController.text.trim();
    if (status == 'revised' && overall.isEmpty && _pending.isEmpty) {
      UIHelpers.showWarning(
        title: 'Komentar diperlukan',
        message:
            'Tulis komentar umum atau komentar pada bagian yang perlu direvisi.',
      );
      return;
    }

    final scoreText = _scoreController.text.trim();
    int? score;
    if (scoreText.isNotEmpty) {
      score = int.tryParse(scoreText);
      if (score == null || score < 0 || score > 100) {
        UIHelpers.showWarning(
          title: 'Nilai tidak valid',
          message: 'Nilai harus berupa angka 0 sampai 100.',
        );
        return;
      }
    }

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text(status == 'approved' ? 'Setujui formulir?' : 'Minta revisi?'),
        content: Text(status == 'approved'
            ? 'Formulir ini akan ditandai disetujui.'
            : 'Mahasiswa akan menerima ${_pending.length + (overall.isEmpty ? 0 : 1)} komentar untuk diperbaiki.'),
        actions: [
          TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Batal')),
          FilledButton(
              onPressed: () => Get.back(result: true),
              child: Text(status == 'approved' ? 'Setujui' : 'Kirim revisi')),
        ],
      ),
    );
    if (confirmed != true) return;

    _logger.userInteraction(
      'Konfirmasi review form',
      page: 'FormReviewView',
      data: {
        'formId': formId,
        'status': status,
        'sectionComments': _pending.length,
      },
    );

    setState(() => _submitting = true);
    final ok = await Get.find<ReviewController>().reviewForm(
      formId,
      status,
      overall.isEmpty ? null : overall,
      sectionComments: status == 'revised'
          ? [
              for (final e in _pending.entries)
                {'section': e.key, 'comment': e.value},
            ]
          : const [],
      score: score,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (!ok) return;

    if (status == 'approved') {
      UIHelpers.showSuccess(title: 'Sukses', message: 'Formulir disetujui');
    } else {
      UIHelpers.showInfo(
          title: 'Terkirim', message: 'Formulir dikembalikan untuk revisi');
    }
    Get.back();
  }

  Widget _fieldRow(String label, dynamic value) {
    final theme = Theme.of(context);
    final text = _formatFieldValue(label, value);
    final empty = text == null || text.trim().isEmpty;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(), style: theme.textTheme.labelSmall),
        const SizedBox(height: 3),
        Text(empty ? '-' : text,
            style: theme.textTheme.bodyMedium?.copyWith(
                color: empty ? theme.colorScheme.onSurfaceVariant : null)),
      ]),
    );
  }

  Widget _sectionCard(FormModel form, _Section sec) {
    final theme = Theme.of(context);
    final data = form.data ?? {};
    final earlier = form.reviewComments.where((c) => c.section == sec.key);
    final mine = _pending[sec.key];
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DsCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(
                child: Text(sec.title, style: theme.textTheme.titleMedium)),
            if (_status == 'submitted')
              DsPill(
                icon: mine == null
                    ? Icons.add_comment_outlined
                    : Icons.edit_outlined,
                label: mine == null ? 'Komentari' : 'Ubah',
                onTap: () => _editComment(sec.key, sec.title),
              ),
          ]),
          const SizedBox(height: 14),
          for (final f in sec.fields) _fieldRow(f.label, _dig(data, f.path)),
          for (final c in earlier) _commentBubble(c.comment,
              label: c.isResolved ? 'Komentar sebelumnya · selesai' : 'Komentar sebelumnya',
              muted: true),
          if (mine != null) _commentBubble(mine, label: 'Komentar Anda'),
        ]),
      ),
    );
  }

  Widget _commentBubble(String text, {required String label, bool muted = false}) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: muted ? theme.colorScheme.surfaceContainerHighest : AppColors.limeSoft,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(),
            style: theme.textTheme.labelSmall?.copyWith(
                color: muted ? null : AppColors.ink)),
        const SizedBox(height: 3),
        Text(text,
            style: TextStyle(
                color: muted ? theme.colorScheme.onSurface : AppColors.ink)),
      ]),
    );
  }

  List<_Section> _sectionsFor(FormModel form) {
    final spec = _specs[form.type];
    final data = form.data ?? {};
    if (spec != null) {
      // Hanya tampilkan bagian yang punya data.
      return [
        for (final s in spec)
          if (s.fields.any((f) => _dig(data, f.path) != null)) s,
      ];
    }
    return _genericSections(data);
  }

  String? _formatFieldValue(String label, dynamic value) {
    if (value == null) return null;
    final lower = label.toLowerCase();
    // Friendly display mapping for common select fields
    if (lower.contains('jenis kelamin')) {
      if (value is String) {
        switch (value.toLowerCase()) {
          case 'l':
          case 'laki-laki':
            return 'Laki-laki';
          case 'p':
          case 'perempuan':
            return 'Perempuan';
          case 'o':
          case 'lainnya':
            return 'Lainnya';
          default:
            return value.toString();
        }
      }
    }
    if (lower.contains('status perkawinan')) {
      if (value is String) {
        switch (value.toLowerCase()) {
          case 'belum_kawin':
          case 'belum kawin':
            return 'Belum Kawin';
          case 'menikah':
            return 'Menikah';
          case 'cerai_hidup':
          case 'cerai hidup':
            return 'Cerai Hidup';
          case 'cerai_mati':
          case 'cerai mati':
            return 'Cerai Mati';
          case 'duda':
            return 'Duda';
          case 'janda':
            return 'Janda';
          default:
            return value.toString();
        }
      }
    }
    if (lower.contains('kesadaran')) {
      if (value is String) {
        switch (value.toLowerCase()) {
          case 'sadar_penuh':
          case 'sadar penuh':
            return 'Sadar Penuh';
          case 'somnolent':
            return 'Somnolent';
          case 'stupor':
            return 'Stupor';
          case 'coma':
            return 'Coma';
          default:
            return value.toString();
        }
      }
    }
    if (lower.contains('orientasi')) {
      if (value is String) {
        switch (value.toLowerCase()) {
          case 'utuh':
            return 'Utuh';
          case 'gangguan':
            return 'Gangguan';
          default:
            return value.toString();
        }
      }
    }
    if (lower.contains('mood')) {
      if (value is String) {
        switch (value.toLowerCase()) {
          case 'normal':
            return 'Normal';
          case 'depresi':
            return 'Depresi';
          case 'ansietas':
            return 'Ansietas';
          case 'iritabel':
            return 'Iritabel';
          case 'labil':
            return 'Labil';
          default:
            return value.toString();
        }
      }
    }
    if (lower.contains('afect') || lower.contains('affect')) {
      if (value is String) {
        switch (value.toLowerCase()) {
          case 'normal':
            return 'Normal';
          case 'flat':
            return 'Flat';
          case 'terhambat':
            return 'Terhambat';
          case 'labil':
            return 'Labil';
          case 'iritabel':
            return 'Iritabel';
          default:
            return value.toString();
        }
      }
    }
    if (lower.contains('intervensi') || lower.contains('intervention')) {
      if (value is List) {
        final names = value.map((id) {
          final found = _interventionController.interventions
              .where((it) => it.id == id)
              .toList();
          final item = found.isNotEmpty ? found.first : null;
          return item != null ? item.name : id.toString();
        }).toList();
        return names.join(', ');
      }
    }

    if (lower.contains('diagnosis')) {
      if (value is int) {
        final found = _diagnosisController.diagnoses
            .where((d) => d.id == value)
            .toList();
        final item = found.isNotEmpty ? found.first : null;
        return item != null ? item.name : value.toString();
      }
      // If it's a list (maybe multiple diagnoses), map names
      if (value is List) {
        final names = value.map((id) {
          final found = _diagnosisController.diagnoses
              .where((d) => d.id == id)
              .toList();
          final item = found.isNotEmpty ? found.first : null;
          return item != null ? item.name : id.toString();
        }).toList();
        return names.join(', ');
      }
    }

    return value.toString();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review formulir'),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: 'Ekspor PDF',
            onPressed: () => formController.exportFormToPdf(formId),
          ),
        ],
      ),
      body: FutureBuilder<FormModel?>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final form = snap.data;
          if (snap.hasError || form == null) {
            return const DsEmpty(
                icon: Icons.error_outline_rounded,
                title: 'Gagal memuat formulir',
                message: 'Tarik untuk mencoba lagi atau kembali.');
          }
          final sections = _sectionsFor(form);
          final general =
              form.reviewComments.where((c) => c.section == null).toList();
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                children: [
                  DsCard(
                    child: Row(children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                            color: AppColors.lime,
                            borderRadius: BorderRadius.circular(16)),
                        child: Icon(FormTypes.icon(form.type),
                            color: AppColors.ink),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(FormTypes.title(form.type),
                                  style: theme.textTheme.titleMedium),
                              const SizedBox(height: 3),
                              Text(
                                  '${form.user?.name ?? 'Mahasiswa'} · ${form.patient?.name ?? 'Pasien'}',
                                  style: theme.textTheme.bodySmall),
                              const SizedBox(height: 8),
                              DsStatusPill.raw(_status),
                            ]),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 16),
                  if (sections.isEmpty)
                    const DsEmpty(
                        icon: Icons.description_outlined,
                        title: 'Belum ada isi untuk ditampilkan')
                  else
                    for (final s in sections) _sectionCard(form, s),
                  if (form.documentations != null &&
                      form.documentations!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    const DsSectionTitle('Lampiran'),
                    for (final doc in form.documentations!)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: DsCard(
                          radius: AppRadius.md,
                          padding: const EdgeInsets.all(12),
                          child: Row(children: [
                            Icon(doc.type == 'foto'
                                ? Icons.image_outlined
                                : Icons.attach_file_rounded),
                            const SizedBox(width: 12),
                            Expanded(
                                child: Text(doc.filePath.split('/').last,
                                    overflow: TextOverflow.ellipsis)),
                          ]),
                        ),
                      ),
                  ],
                  const SizedBox(height: 8),
                  const DsSectionTitle('Komentar umum'),
                  for (final c in general)
                    _commentBubble(c.comment,
                        label: c.isResolved ? 'Sebelumnya · selesai' : 'Sebelumnya',
                        muted: true),
                  if (_status == 'submitted') ...[
                    TextField(
                      controller: _commentController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                          hintText: 'Ringkasan penilaian untuk mahasiswa…'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _scoreController,
                      keyboardType: TextInputType.number,
                      maxLength: 3,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Nilai (0–100, opsional)',
                        counterText: '',
                        prefixIcon: Icon(Icons.grade_outlined),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: _status != 'submitted'
          ? null
          : DsStickyCta(
              child: Row(children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _canReview ? () => _reviewForm('revised') : null,
                    child: Text(_pending.isEmpty
                        ? 'Minta revisi'
                        : 'Revisi (${_pending.length})'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _canReview ? () => _reviewForm('approved') : null,
                    child: const Text('Setujui'),
                  ),
                ),
              ]),
            ),
    );
  }
}
