import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/form_model.dart';
import '../services/forms_service.dart';
import '../services/logger_service.dart';
import '../theme/app_theme.dart';
import '../utils/form_types.dart';
import '../widgets/ds/ds.dart';
import 'form_detail_view.dart';

/// Progres satu mahasiswa bimbingan: kelengkapan tiap jenis formulir
/// dan daftar formulirnya. Dibuka dari tab Bimbingan (dosen).
class StudentProgressView extends StatefulWidget {
  const StudentProgressView({super.key});

  @override
  State<StudentProgressView> createState() => _StudentProgressViewState();
}

/// Peringkat status: makin besar makin maju.
int _rank(String status) {
  switch (status) {
    case 'approved':
      return 3;
    case 'submitted':
      return 2;
    case 'revised':
      return 1;
    default:
      return 0;
  }
}

class _StudentProgressViewState extends State<StudentProgressView> {
  late final Map<String, dynamic> _student;
  bool _loading = true;
  String _error = '';
  List<FormModel> _forms = [];

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    _student = args is Map
        ? Map<String, dynamic>.from(args)
        : {'id': args, 'name': 'Mahasiswa'};
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final res = await FormsService.list(
        userId: _student['id']?.toString(),
        perPage: 100,
      );
      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        final list = (data is List) ? data : (data['data'] as List? ?? const []);
        _forms = [
          for (final f in list)
            FormModel.fromJson(Map<String, dynamic>.from(f as Map)),
        ];
      } else {
        _error = 'Tidak dapat memuat formulir mahasiswa';
      }
    } catch (e) {
      _error = 'Periksa koneksi Anda lalu coba lagi';
      LoggerService().error('Gagal memuat progres mahasiswa', error: e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Status terbaik per jenis formulir, null bila belum ada.
  String? _bestStatus(String type) {
    String? best;
    for (final f in _forms.where((f) => f.type == type)) {
      if (best == null || _rank(f.status) > _rank(best)) best = f.status;
    }
    return best;
  }

  Future<void> _open(FormModel f) async {
    if (f.status == 'submitted') {
      await Get.toNamed('/form-review/${f.id}');
    } else {
      await Get.to(() => const FormDetailView(), arguments: f);
    }
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final types = [
      'pengkajian',
      'resume_kegawatdaruratan',
      'resume_poliklinik',
      'sap',
      'terapi_aktivitas_kelompok',
      'strategi_pelaksanaan_komunikasi',
      'catatan_tambahan',
    ];
    final done = types.where((t) => _bestStatus(t) == 'approved').length;
    final pending = _forms.where((f) => f.status == 'submitted').length;
    final scored = _forms.where((f) => f.score != null).toList();
    final average = scored.isEmpty
        ? null
        : scored.fold<int>(0, (a, f) => a + f.score!) / scored.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Progres mahasiswa')),
      body: RefreshIndicator(
        color: AppColors.ink,
        backgroundColor: AppColors.lime,
        onRefresh: _load,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              children: [
                DsCard(
                  child: Row(children: [
                    DsAvatar(name: _student['name'] as String?, size: 60),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text((_student['name'] ?? 'Mahasiswa').toString(),
                                style: theme.textTheme.titleLarge),
                            const SizedBox(height: 3),
                            Text((_student['email'] ?? '').toString(),
                                style: theme.textTheme.bodySmall),
                          ]),
                    ),
                  ]),
                ),
                const SizedBox(height: 16),
                if (_loading)
                  const Padding(
                      padding: EdgeInsets.all(48),
                      child: Center(child: CircularProgressIndicator()))
                else if (_error.isNotEmpty)
                  DsError(message: _error, onRetry: _load)
                else ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.lime,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('KELENGKAPAN',
                              style: TextStyle(
                                  color: AppColors.ink,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 1)),
                          const SizedBox(height: 6),
                          Text('$done / ${types.length} disetujui',
                              style: const TextStyle(
                                  color: AppColors.ink,
                                  fontSize: 30,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1)),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: done / types.length,
                              minHeight: 10,
                              color: AppColors.ink,
                              backgroundColor: AppColors.ink.withValues(alpha: 0.15),
                            ),
                          ),
                          if (average != null) ...[
                            const SizedBox(height: 10),
                            Text(
                                'Rata-rata nilai ${average.toStringAsFixed(1)} dari ${scored.length} formulir',
                                style: const TextStyle(
                                    color: AppColors.ink,
                                    fontWeight: FontWeight.w700)),
                          ],
                          if (pending > 0) ...[
                            const SizedBox(height: 10),
                            Text('$pending formulir menunggu review Anda',
                                style: const TextStyle(
                                    color: AppColors.ink,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ]),
                  ),
                  const SizedBox(height: 20),
                  const DsSectionTitle('Per jenis formulir'),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    for (final t in types)
                      _typeChip(t, _bestStatus(t)),
                  ]),
                  const SizedBox(height: 24),
                  DsSectionTitle('Semua formulir (${_forms.length})'),
                  if (_forms.isEmpty)
                    const DsEmpty(
                        icon: Icons.note_add_outlined,
                        title: 'Belum ada formulir',
                        message: 'Mahasiswa ini belum membuat formulir apa pun.')
                  else
                    for (final f in _forms) ...[
                      DsCard(
                        radius: AppRadius.md,
                        onTap: () => _open(f),
                        child: Row(children: [
                          Icon(FormTypes.icon(f.type)),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(FormTypes.title(f.type),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.titleSmall),
                                  const SizedBox(height: 3),
                                  Text(f.patient?.name ?? 'Pasien',
                                      style: theme.textTheme.bodySmall),
                                ]),
                          ),
                          if (f.score != null) ...[
                            DsBadge('${f.score}'),
                            const SizedBox(width: 8),
                          ],
                          DsStatusPill.raw(f.status),
                        ]),
                      ),
                      const SizedBox(height: 10),
                    ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _typeChip(String type, String? status) {
    final icon = switch (status) {
      'approved' => Icons.check_circle_rounded,
      'submitted' => Icons.hourglass_top_rounded,
      'revised' => Icons.replay_rounded,
      _ => Icons.radio_button_unchecked_rounded,
    };
    return DsPill(
      icon: icon,
      label: FormTypes.title(type).replaceAll(' (SAP)', ''),
      selected: status == 'approved',
    );
  }
}
