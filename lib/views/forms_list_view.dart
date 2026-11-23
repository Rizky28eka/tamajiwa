import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../models/form_model.dart';
import '../services/forms_service.dart';
import '../services/logger_service.dart';
import '../theme/app_theme.dart';
import '../widgets/ds/ds.dart';
import 'form_detail_view.dart';

class FormsListView extends StatefulWidget {
  const FormsListView({super.key});

  @override
  State<FormsListView> createState() => FormsListViewState();
}

class FormsListViewState extends State<FormsListView>
    with AutomaticKeepAliveClientMixin {
  final LoggerService _logger = LoggerService();
  final _searchCtrl = TextEditingController();
  String _type = '';
  String _status = '';
  String _query = '';
  bool _loading = true;
  String _error = '';
  List<Map<String, dynamic>> _items = [];

  @override
  bool get wantKeepAlive => true;

  static const _types = <(String, String)>[
    ('', 'Semua jenis'),
    ('pengkajian', 'Pengkajian'),
    ('resume_kegawatdaruratan', 'Kegawatdaruratan'),
    ('resume_poliklinik', 'Poliklinik'),
    ('sap', 'SAP'),
    ('terapi_aktivitas_kelompok', 'TAK'),
    ('strategi_pelaksanaan_komunikasi', 'Komunikasi'),
    ('catatan_tambahan', 'Catatan'),
  ];

  static const _statuses = <(String, String)>[
    ('', 'Semua'),
    ('submitted', 'Diajukan'),
    ('revised', 'Perlu revisi'),
    ('approved', 'Disetujui'),
  ];

  @override
  void initState() {
    super.initState();
    _fetch();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetch() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final res = await FormsService.list(
        type: _type.isNotEmpty ? _type : null,
        status: _status.isNotEmpty ? _status : null,
      );
      _logger.info('Daftar form berhasil diambil',
          context: {'statusCode': res.statusCode});
      if (res.body.isEmpty) {
        _items = [];
        return;
      }
      final data = json.decode(res.body);
      if (res.statusCode == 200) {
        final list = (data is List)
            ? data
            : (data['data'] ?? data['forms'] ?? data['items'] ?? []);
        _items = List<Map<String, dynamic>>.from(list);
      } else {
        _error = (data['error']?['message'] ??
            data['message'] ??
            'Gagal memuat data');
      }
    } catch (e) {
      _error = e.toString();
      _logger.error('Terjadi kesalahan saat memuat form', error: e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void refresh() => _fetch();

  List<Map<String, dynamic>> get _visible {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _items;
    final out = <Map<String, dynamic>>[];
    for (final f in _items) {
      final hay = '${_patientName(f).toLowerCase()} ${_titleForType(f['type']).toLowerCase()}';
      if (hay.contains(q)) out.add(f);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final items = _visible;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: RefreshIndicator(
              color: AppColors.ink,
              backgroundColor: AppColors.lime,
              onRefresh: _fetch,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                children: [
                  DsPageHeader(
                    title: 'Formulir',
                    subtitle: _loading
                        ? 'Memuat…'
                        : '${items.length} formulir ditemukan',
                  ),
                  const SizedBox(height: 16),
                  DsSearchField(
                    controller: _searchCtrl,
                    hint: 'Cari pasien atau jenis formulir',
                    onChanged: (v) => setState(() => _query = v),
                  ),
                  const SizedBox(height: 14),
                  _chipRow(_statuses, _status, (v) {
                    setState(() => _status = v);
                    _fetch();
                  }),
                  const SizedBox(height: 8),
                  _chipRow(_types, _type, (v) {
                    setState(() => _type = v);
                    _fetch();
                  }),
                  const SizedBox(height: 20),
                  if (_loading)
                    const Padding(
                        padding: EdgeInsets.all(48),
                        child: Center(child: CircularProgressIndicator()))
                  else if (_error.isNotEmpty)
                    DsError(message: _error, onRetry: _fetch)
                  else if (items.isEmpty)
                    const DsEmpty(
                      icon: Icons.find_in_page_outlined,
                      title: 'Tidak ada formulir',
                      message: 'Coba ubah filter atau kata kunci pencarian.',
                    )
                  else
                    for (final f in items) ...[
                      _card(context, f),
                      const SizedBox(height: 10),
                    ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _chipRow(List<(String, String)> opts, String current,
      ValueChanged<String> onPick) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: opts.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => DsPill(
          label: opts[i].$2,
          selected: current == opts[i].$1,
          onTap: () => onPick(opts[i].$1),
        ),
      ),
    );
  }

  Widget _card(BuildContext context, Map<String, dynamic> form) {
    final model = FormModel.fromJson(form);
    final updated = DateFormat('d MMM yyyy').format(model.updatedAt);
    return DsCard(
      padding: const EdgeInsets.all(16),
      onTap: () async {
        await Get.to(() => const FormDetailView(), arguments: model);
        _fetch();
      },
      child: Row(children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
              color: AppColors.limeSoft,
              borderRadius: BorderRadius.circular(16)),
          child: Icon(_iconForType(form['type']),
              color: AppColors.ink, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_titleForType(form['type']),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text('${_patientName(form)} · $updated',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            DsStatusPill.raw(form['status']?.toString()),
          ]),
        ),
        const Icon(Icons.chevron_right_rounded),
      ]),
    );
  }

  IconData _iconForType(String? type) {
    switch (type) {
      case 'pengkajian':
        return Icons.medical_information_rounded;
      case 'resume_kegawatdaruratan':
        return Icons.emergency_rounded;
      case 'resume_poliklinik':
        return Icons.local_hospital_rounded;
      case 'sap':
        return Icons.school_rounded;
      case 'terapi_aktivitas_kelompok':
        return Icons.group_work_rounded;
      case 'strategi_pelaksanaan_komunikasi':
        return Icons.chat_bubble_outline_rounded;
      case 'catatan_tambahan':
        return Icons.note_add_rounded;
      default:
        return Icons.description_rounded;
    }
  }

  String _titleForType(String? type) {
    switch (type) {
      case 'pengkajian':
        return 'Pengkajian Kesehatan Jiwa';
      case 'resume_kegawatdaruratan':
        return 'Resume Kegawatdaruratan';
      case 'resume_poliklinik':
        return 'Resume Poliklinik';
      case 'sap':
        return 'SAP';
      case 'terapi_aktivitas_kelompok':
        return 'Terapi Aktivitas Kelompok';
      case 'strategi_pelaksanaan_komunikasi':
        return 'Strategi Komunikasi';
      case 'catatan_tambahan':
        return 'Catatan Tambahan';
      default:
        return 'Formulir';
    }
  }

  String _patientName(Map<String, dynamic> f) {
    if (f['patient'] is Map) {
      final p = f['patient'];
      if (p['name'] != null && p['name'].toString().isNotEmpty) {
        return p['name'].toString();
      }
    }
    if (f['patient_name'] != null && f['patient_name'].toString().isNotEmpty) {
      return f['patient_name'].toString();
    }
    return 'Tanpa nama';
  }
}
