import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/api_service.dart';
import '../services/logger_service.dart';
import '../theme/app_theme.dart';
import '../widgets/ds/ds.dart';

class MahasiswaBimbinganView extends StatefulWidget {
  const MahasiswaBimbinganView({super.key});

  @override
  State<MahasiswaBimbinganView> createState() => _MahasiswaBimbinganViewState();
}

class _MahasiswaBimbinganViewState extends State<MahasiswaBimbinganView> {
  final LoggerService _logger = LoggerService();
  final _search = TextEditingController();
  String _query = '';

  bool _loading = true;
  String _error = '';
  List<Map<String, dynamic>> _students = [];

  @override
  void initState() {
    super.initState();
    _logger.info('MahasiswaBimbinganView diinisialisasi');
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      final res = await ApiService.getAssignedStudents();
      if (res.statusCode == 200) {
        final parsed = json.decode(res.body);
        _students = List<Map<String, dynamic>>.from(
            (parsed['students'] as List<dynamic>? ?? const []));
      } else {
        _error = 'Tidak dapat memuat daftar mahasiswa';
      }
    } catch (e) {
      _error = 'Periksa koneksi Anda lalu coba lagi';
      _logger.error('Gagal memuat mahasiswa bimbingan', error: e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> get _visible {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return _students;
    final out = <Map<String, dynamic>>[];
    for (final s in _students) {
      final hay = '${s['name'] ?? ''} ${s['email'] ?? ''}'.toLowerCase();
      if (hay.contains(q)) out.add(s);
    }
    return out;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = _visible;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.ink,
          backgroundColor: AppColors.lime,
          onRefresh: _load,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                children: [
                  DsPageHeader(
                    title: 'Bimbingan',
                    subtitle: _loading
                        ? 'Memuat…'
                        : '${_students.length} mahasiswa dibimbing',
                  ),
                  const SizedBox(height: 16),
                  DsSearchField(
                    controller: _search,
                    hint: 'Cari nama atau email',
                    onChanged: (v) => setState(() => _query = v),
                  ),
                  const SizedBox(height: 20),
                  if (_loading)
                    const Padding(
                        padding: EdgeInsets.all(48),
                        child: Center(child: CircularProgressIndicator()))
                  else if (_error.isNotEmpty)
                    DsError(message: _error, onRetry: _load)
                  else if (items.isEmpty)
                    DsEmpty(
                      icon: Icons.school_outlined,
                      title: _students.isEmpty
                          ? 'Belum ada mahasiswa'
                          : 'Tidak ditemukan',
                      message: _students.isEmpty
                          ? 'Mahasiswa yang memilih Anda sebagai dosen pembimbing akan muncul di sini.'
                          : 'Coba kata kunci lain.',
                    )
                  else
                    for (final s in items) ...[
                      DsCard(
                        radius: AppRadius.md,
                        onTap: () =>
                            Get.toNamed('/patients-for-student', arguments: s),
                        child: Row(children: [
                          DsAvatar(name: s['name'] as String?, size: 50),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      (s['name'] ?? 'Mahasiswa').toString(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.titleSmall),
                                  const SizedBox(height: 3),
                                  Text((s['email'] ?? '-').toString(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodySmall),
                                ]),
                          ),
                          IconButton(
                            tooltip: 'Tinjau formulir',
                            icon: const Icon(Icons.rate_review_outlined),
                            onPressed: () =>
                                Get.toNamed('/dosen-review-dashboard'),
                          ),
                        ]),
                      ),
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
}
