import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/review_controller.dart';
import '../services/logger_service.dart';
import '../theme/app_theme.dart';
import '../utils/form_types.dart';
import '../widgets/ds/ds.dart';

class DosenReviewDashboardView extends StatefulWidget {
  const DosenReviewDashboardView({super.key});

  @override
  State<DosenReviewDashboardView> createState() =>
      _DosenReviewDashboardViewState();
}

class _DosenReviewDashboardViewState extends State<DosenReviewDashboardView> {
  late final ReviewController _c = Get.put(ReviewController());
  String _query = '';

  @override
  Widget build(BuildContext context) {
    LoggerService().info('Dashboard Review Dosen dimuat');
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Review & revisi')),
      body: RefreshIndicator(
        color: AppColors.ink,
        backgroundColor: AppColors.lime,
        onRefresh: _c.fetchSubmittedForms,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              children: [
                Obx(() => DsPageHeader(
                      title: 'Antrean review',
                      subtitle: _c.isLoading
                          ? 'Memuat…'
                          : '${_c.submittedForms.length} formulir menunggu',
                    )),
                const SizedBox(height: 16),
                DsSearchField(
                  hint: 'Cari mahasiswa atau pasien',
                  onChanged: (v) => setState(() => _query = v),
                ),
                const SizedBox(height: 20),
                Obx(() {
                  if (_c.isLoading) {
                    return const Padding(
                        padding: EdgeInsets.all(48),
                        child: Center(child: CircularProgressIndicator()));
                  }
                  if (_c.errorMessage.isNotEmpty) {
                    return DsError(
                        message: _c.errorMessage,
                        onRetry: _c.fetchSubmittedForms);
                  }
                  final q = _query.trim().toLowerCase();
                  final items = _c.submittedForms.where((f) {
                    if (q.isEmpty) return true;
                    final hay =
                        '${f.user?.name ?? ''} ${f.patient?.name ?? ''} ${FormTypes.title(f.type)}'
                            .toLowerCase();
                    return hay.contains(q);
                  }).toList();
                  if (items.isEmpty) {
                    return const DsEmpty(
                      icon: Icons.task_alt_rounded,
                      title: 'Tidak ada formulir menunggu',
                      message: 'Semua formulir yang diajukan sudah Anda tinjau.',
                    );
                  }
                  return Column(children: [
                    for (final f in items) ...[
                      DsCard(
                        radius: AppRadius.md,
                        onTap: () {
                          LoggerService().userInteraction(
                            'Form dipilih untuk review',
                            page: 'DosenReviewDashboard',
                            data: {
                              'formId': f.id,
                              'formType': f.type,
                              'patientName': f.patient?.name,
                              'studentName': f.user?.name,
                            },
                          );
                          Get.toNamed('/form-review/${f.id}');
                        },
                        child: Row(children: [
                          DsAvatar(name: f.user?.name, size: 46),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(FormTypes.title(f.type),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.titleSmall),
                                  const SizedBox(height: 3),
                                  Text(
                                      '${f.user?.name ?? 'Mahasiswa'} · ${f.patient?.name ?? 'Pasien'}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodySmall),
                                  const SizedBox(height: 8),
                                  Row(children: [
                                    DsStatusPill.raw(f.status),
                                    const SizedBox(width: 8),
                                    Text(f.createdAt.toString().split(' ')[0],
                                        style: theme.textTheme.bodySmall),
                                  ]),
                                ]),
                          ),
                          const Icon(Icons.chevron_right_rounded),
                        ]),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ]);
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
