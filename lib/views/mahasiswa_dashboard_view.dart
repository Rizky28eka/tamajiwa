import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/auth_controller.dart';
import '../controllers/notification_controller.dart';
import '../services/logger_service.dart';
import '../models/form_type_model.dart';
import '../theme/app_theme.dart';
import '../widgets/ds/ds.dart';
import '../widgets/ds/notification_bell.dart';

class MahasiswaDashboardView extends GetView<DashboardController> {
  const MahasiswaDashboardView({super.key});

  static const List<FormType> _formTypes = [
    FormType(
      type: 'pengkajian',
      title: 'Pengkajian Kesehatan Jiwa',
      description: 'Formulir pengkajian awal klien',
      icon: Icons.medical_information_rounded,
    ),
    FormType(
      type: 'resume_kegawatdaruratan',
      title: 'Resume Kegawatdaruratan',
      description: 'Resume kasus darurat psikiatri',
      icon: Icons.emergency_rounded,
    ),
    FormType(
      type: 'resume_poliklinik',
      title: 'Resume Poliklinik',
      description: 'Resume kunjungan poliklinik',
      icon: Icons.local_hospital_rounded,
    ),
    FormType(
      type: 'sap',
      title: 'SAP',
      description: 'Satuan Acara Penyuluhan',
      icon: Icons.school_rounded,
    ),
    FormType(
      type: 'terapi_aktivitas_kelompok',
      title: 'Terapi Aktivitas Kelompok',
      description: 'Formulir TAK',
      icon: Icons.group_work_rounded,
    ),
    FormType(
      type: 'strategi_pelaksanaan_komunikasi',
      title: 'Strategi Komunikasi',
      description: 'Strategi pelaksanaan komunikasi',
      icon: Icons.chat_bubble_outline_rounded,
    ),
    FormType(
      type: 'catatan_tambahan',
      title: 'Catatan Tambahan',
      description: 'Catatan dokumentasi tambahan',
      icon: Icons.note_add_rounded,
    ),
  ];

  Future<void> _refreshDashboard() async {
    LoggerService().info('Memuat ulang Dashboard Mahasiswa');
    await Future.wait([
      controller.fetchMahasiswaStats(),
      controller.fetchLatestPatients(),
      if (Get.isRegistered<NotificationController>())
        Get.find<NotificationController>().fetch(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.ink,
          backgroundColor: AppColors.lime,
          onRefresh: _refreshDashboard,
          child: LayoutBuilder(builder: (context, c) {
            final wide = c.maxWidth > 600;
            final hPad = c.maxWidth > 900 ? 40.0 : (wide ? 24.0 : 20.0);
            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 120),
                  children: [
                    _header(context),
                    const SizedBox(height: 24),
                    _statsSection(context, wide),
                    const SizedBox(height: 32),
                    const DsSectionTitle('Buat dokumentasi'),
                    _servicesGrid(context, c.maxWidth),
                    const SizedBox(height: 32),
                    const DsSectionTitle('Pasien terbaru'),
                    _patients(context),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          LoggerService().userAction(
            action: 'Tombol Tambah Pasien ditekan',
            metadata: {'page': 'MahasiswaDashboardView'},
          );
          final result = await Get.toNamed('/patient-form');
          if (result != null) {
            await controller.fetchLatestPatients();
            await controller.fetchMahasiswaStats();
          }
        },
        icon: const Icon(Icons.add_rounded),
        label: const Text('Tambah pasien'),
      ),
    );
  }

  Widget _header(BuildContext context) {
    final auth = Get.find<AuthController>();
    final name = auth.user?.name ?? 'Mahasiswa';
    final first = name.trim().split(RegExp(r'\s+')).first;
    return Row(children: [
      DsAvatar(name: name, size: 52),
      const SizedBox(width: 14),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Halo, $first',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 2),
          Text('Siap mendokumentasikan hari ini?',
              style: Theme.of(context).textTheme.bodySmall),
        ]),
      ),
      const NotificationBell(),
      const SizedBox(width: 8),
      DsRoundIcon(
        icon: Icons.logout_rounded,
        tooltip: 'Keluar',
        onTap: () => auth.logout(),
      ),
    ]);
  }

  Widget _statsSection(BuildContext context, bool wide) {
    return Obx(() {
      if (controller.isMahasiswaStatsLoading &&
          controller.mahasiswaStats.isEmpty) {
        return const SizedBox(
            height: 120, child: Center(child: CircularProgressIndicator()));
      }
      if (controller.errorMessage.isNotEmpty &&
          controller.mahasiswaStats.isEmpty) {
        return DsError(
            message: controller.errorMessage,
            onRetry: controller.fetchMahasiswaStats);
      }
      final s = controller.mahasiswaStats;
      String v(String k) => (s[k] ?? 0).toString();
      final tiles = [
        DsStat(
            value: v('total_pasien'),
            label: 'Total pasien',
            icon: Icons.people_alt_rounded,
            highlight: true),
        DsStat(
            value: v('total_form'),
            label: 'Total formulir',
            icon: Icons.description_rounded),
        DsStat(
            value: v('form_disetujui'),
            label: 'Disetujui',
            icon: Icons.check_circle_rounded),
        DsStat(
            value: v('form_revisi'),
            label: 'Perlu revisi',
            icon: Icons.replay_rounded),
      ];
      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: wide ? 4 : 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: wide ? 1.5 : 1.35,
        children: tiles,
      );
    });
  }

  Widget _servicesGrid(BuildContext context, double width) {
    final cols = width > 900 ? 4 : (width > 600 ? 3 : 2);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: cols,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: 128,
      ),
      itemCount: _formTypes.length,
      itemBuilder: (context, i) {
        final f = _formTypes[i];
        return DsCard(
          onTap: () =>
              Get.toNamed('/patient-selection', arguments: {'formType': f.type}),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                    color: AppColors.lime, shape: BoxShape.circle),
                child: Icon(f.icon, size: 20, color: AppColors.ink),
              ),
              Text(f.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleSmall),
            ],
          ),
        );
      },
    );
  }

  Widget _patients(BuildContext context) {
    return Obx(() {
      if (controller.isLatestPatientsLoading &&
          controller.latestPatients.isEmpty) {
        return const Padding(
            padding: EdgeInsets.all(24),
            child: Center(child: CircularProgressIndicator()));
      }
      if (controller.latestPatients.isEmpty) {
        return const DsCard(
          child: DsEmpty(
            icon: Icons.person_add_alt_1_rounded,
            title: 'Belum ada pasien',
            message: 'Tambahkan pasien pertama untuk mulai mengisi formulir.',
          ),
        );
      }
      return Column(
        children: [
          for (final p in controller.latestPatients) ...[
            DsCard(
              padding: const EdgeInsets.all(14),
              radius: AppRadius.md,
              onTap: () => Get.toNamed('/form-selection', arguments: {
                'patientId': p['id'],
                'patientName': p['name'],
              }),
              child: Row(children: [
                DsAvatar(name: p['name'] as String?, size: 46),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text((p['name'] ?? 'Tanpa nama').toString(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleSmall),
                        const SizedBox(height: 3),
                        Text('RM ${p['rm_number'] ?? '-'}',
                            style: Theme.of(context).textTheme.bodySmall),
                      ]),
                ),
                const Icon(Icons.arrow_forward_rounded, size: 20),
              ]),
            ),
            const SizedBox(height: 10),
          ],
        ],
      );
    });
  }
}
