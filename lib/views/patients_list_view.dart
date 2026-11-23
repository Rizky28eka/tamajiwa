import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/patient_service.dart';
import '../services/logger_service.dart';
import '../theme/app_theme.dart';
import '../widgets/ds/ds.dart';

class PatientsListView extends StatefulWidget {
  const PatientsListView({super.key});

  @override
  PatientsListViewState createState() => PatientsListViewState();
}

class PatientsListViewState extends State<PatientsListView>
    with AutomaticKeepAliveClientMixin {
  final LoggerService _logger = LoggerService();
  final TextEditingController _searchController = TextEditingController();
  bool _loading = true;
  String _error = '';
  List<Map<String, dynamic>> _items = [];


  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _logger.info('Initializing PatientsListView');
    _fetch();
  }

  Future<void> _fetch() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _error = '';
    });

    try {
      _logger.patient(
        operation: 'LIST_FETCH_START',
        metadata: {'query': _searchController.text.trim()},
      );

      final response = await PatientService.list(
        query: _searchController.text.trim(),
      );

      _logger.patient(
        operation: 'LIST_FETCH_COMPLETE',
        metadata: {
          'statusCode': response.statusCode,
          'hasBody': response.body.isNotEmpty,
          'query': _searchController.text.trim(),
        },
      );

      if (response.body.isEmpty) {
        setState(() {
          _error = 'Tidak ada data pasien yang diterima dari server';
        });
        _logger.warning(
          'Respon kosong dari API pasien',
          context: {'query': _searchController.text.trim()},
        );
        return;
      }

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        final list = (data is List)
            ? data
            : (data['data'] ?? data['patients'] ?? []);
        setState(() {
          _items = List<Map<String, dynamic>>.from(list);
        });
        _logger.info(
          'Successfully loaded patients',
          context: {
            'count': _items.length,
            'query': _searchController.text.trim(),
          },
        );
      } else {
        setState(() {
          _error =
              (data['error']?['message'] ??
              data['message'] ??
              'Gagal memuat data');
        });
        _logger.error(
          'Gagal memuat pasien',
          context: {
            'statusCode': response.statusCode,
            'error': _error,
            'query': _searchController.text.trim(),
          },
        );
      }
    } catch (e, stackTrace) {
      setState(() {
        _error = e.toString();
      });
      _logger.error(
        'Exception occurred while loading patients',
        error: e,
        stackTrace: stackTrace,
        context: {'query': _searchController.text.trim()},
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
      _logger.debug(
        'Patients list fetch completed',
        context: {'isLoading': false},
      );
    }
  }

  Future<void> refresh() async {
    _logger.info('Manual refresh triggered for patients list');
    await _fetch();
  }

  @override
  void dispose() {
    _logger.info('Disposing PatientsListView');
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(builder: (context, c) {
          final cols = c.maxWidth > 900 ? 3 : (c.maxWidth > 600 ? 2 : 1);
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: RefreshIndicator(
                color: AppColors.ink,
                backgroundColor: AppColors.lime,
                onRefresh: _fetch,
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                  children: [
                    DsPageHeader(
                      title: 'Pasien',
                      subtitle: _loading
                          ? 'Memuat…'
                          : '${_items.length} pasien terdaftar',
                    ),
                    const SizedBox(height: 16),
                    DsSearchField(
                      controller: _searchController,
                      hint: 'Cari nama atau nomor RM',
                      onChanged: (_) => _debounceFetch(),
                    ),
                    const SizedBox(height: 20),
                    if (_loading)
                      const Padding(
                          padding: EdgeInsets.all(48),
                          child: Center(child: CircularProgressIndicator()))
                    else if (_error.isNotEmpty)
                      DsError(message: _error, onRetry: _fetch)
                    else if (_items.isEmpty)
                      DsEmpty(
                        icon: Icons.person_search_rounded,
                        title: 'Belum ada pasien',
                        message: 'Tambahkan pasien untuk mulai mengisi formulir.',
                        actionLabel: 'Tambah pasien',
                        onAction: _addPatient,
                      )
                    else
                      _grid(theme, cols),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addPatient,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: const Text('Tambah pasien'),
      ),
    );
  }

  Timer? _debounce;

  void _debounceFetch() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _fetch);
  }

  Future<void> _addPatient() async {
    await Get.toNamed('/patient-form');
    _fetch();
  }

  Widget _grid(ThemeData theme, int cols) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        mainAxisExtent: 128,
      ),
      itemCount: _items.length,
      itemBuilder: (_, i) => _card(theme, _items[i]),
    );
  }

  Widget _card(ThemeData theme, Map<String, dynamic> p) {
    final name = (p['name'] ?? 'Nama tidak diketahui').toString();
    return DsCard(
      onTap: () => Get.toNamed('/form-selection', arguments: {
        'patientId': p['id'],
        'patientName': p['name'],
      }),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            DsAvatar(name: name, size: 48),
            const SizedBox(width: 12),
            Expanded(
              child: Text(name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall),
            ),
            const Icon(Icons.arrow_forward_rounded, size: 20),
          ]),
          Wrap(spacing: 8, runSpacing: 6, children: [
            DsPill(
                icon: Icons.badge_outlined,
                label: 'RM ${p['rm_number'] ?? '-'}'),
            DsPill(
                icon: Icons.cake_outlined, label: '${p['age'] ?? '-'} th'),
          ]),
        ],
      ),
    );
  }
}
