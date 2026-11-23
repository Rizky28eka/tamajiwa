import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/dashboard_controller.dart';
import '../controllers/notification_controller.dart';
import '../services/logger_service.dart';
import '../theme/app_theme.dart';
import '../widgets/ds/ds.dart';
import '../widgets/ds/notification_bell.dart';

class DosenDashboardView extends StatelessWidget {
  const DosenDashboardView({super.key});

  Future<void> _refreshDashboard() async {
    LoggerService().info('Memuat ulang Dashboard Dosen');
    final AuthController auth = Get.find();
    final DashboardController dash = Get.find();
    await auth.getUserProfile();
    await dash.fetchDosenStats();
    if (Get.isRegistered<NotificationController>()) {
      await Get.find<NotificationController>().fetch();
    }
  }

  @override
  Widget build(BuildContext context) {
    LoggerService().info('DosenDashboardView dimuat');
    final AuthController auth = Get.find();
    final DashboardController dash = Get.put(DashboardController());
    final theme = Theme.of(context);
    final name = auth.user?.name ?? 'Dosen';

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          color: AppColors.ink,
          backgroundColor: AppColors.lime,
          onRefresh: _refreshDashboard,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                children: [
                  Row(children: [
                    DsAvatar(name: name, size: 52),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.headlineSmall),
                            const SizedBox(height: 2),
                            Text('Dosen pembimbing',
                                style: theme.textTheme.bodySmall),
                          ]),
                    ),
                    const NotificationBell(),
                    const SizedBox(width: 8),
                    DsRoundIcon(
                      icon: Icons.logout_rounded,
                      tooltip: 'Keluar',
                      onTap: () => auth.logout(),
                    ),
                  ]),
                  const SizedBox(height: 24),
                  Obx(() {
                    if (dash.isDosenStatsLoading && dash.dosenStats.isEmpty) {
                      return const SizedBox(
                          height: 160,
                          child: Center(child: CircularProgressIndicator()));
                    }
                    if (dash.errorMessage.isNotEmpty &&
                        dash.dosenStats.isEmpty) {
                      return DsError(
                          message: dash.errorMessage,
                          onRetry: dash.fetchDosenStats);
                    }
                    return _stats(context, dash.dosenStats);
                  }),
                  const SizedBox(height: 32),
                  const DsSectionTitle('Kelola & review'),
                  _action(
                    context,
                    Icons.rate_review_rounded,
                    'Review & revisi formulir',
                    'Periksa formulir yang diajukan mahasiswa',
                    '/dosen-review-dashboard',
                  ),
                  const SizedBox(height: 10),
                  _action(
                    context,
                    Icons.medical_information_rounded,
                    'Manajemen diagnosis',
                    'Kelola daftar diagnosis keperawatan',
                    '/diagnoses',
                  ),
                  const SizedBox(height: 10),
                  _action(
                    context,
                    Icons.volunteer_activism_rounded,
                    'Manajemen intervensi',
                    'Kelola daftar intervensi keperawatan',
                    '/interventions',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _stats(BuildContext context, Map<String, dynamic> s) {
    String v(String k) => (s[k] ?? 0).toString();
    final pending = v('form_menunggu_review');
    return Column(children: [
      // Kartu utama: antrean review
      GestureDetector(
        onTap: () => Get.toNamed('/dosen-review-dashboard'),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.lime,
            borderRadius: BorderRadius.circular(AppRadius.lg + 6),
          ),
          child: Row(children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('MENUNGGU REVIEW',
                        style: TextStyle(
                            color: AppColors.ink,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1)),
                    const SizedBox(height: 6),
                    Text(pending,
                        style: const TextStyle(
                            color: AppColors.ink,
                            fontSize: 56,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -2,
                            height: 1)),
                    const SizedBox(height: 6),
                    const Text('formulir butuh perhatian Anda',
                        style: TextStyle(
                            color: AppColors.ink, fontWeight: FontWeight.w600)),
                  ]),
            ),
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                  color: AppColors.ink, shape: BoxShape.circle),
              child: const Icon(Icons.arrow_forward_rounded,
                  color: AppColors.lime),
            ),
          ]),
        ),
      ),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(
            child: SizedBox(
          height: 132,
          child: DsStat(
              value: v('total_mahasiswa'),
              label: 'Mahasiswa',
              icon: Icons.people_alt_rounded),
        )),
        const SizedBox(width: 12),
        Expanded(
            child: SizedBox(
          height: 132,
          child: DsStat(
              value: v('total_form'),
              label: 'Total formulir',
              icon: Icons.description_rounded),
        )),
        const SizedBox(width: 12),
        Expanded(
            child: SizedBox(
          height: 132,
          child: DsStat(
              value: v('form_disetujui'),
              label: 'Disetujui',
              icon: Icons.check_circle_rounded),
        )),
      ]),
    ]);
  }

  Widget _action(BuildContext context, IconData icon, String title,
      String subtitle, String route) {
    final theme = Theme.of(context);
    return DsCard(
      radius: AppRadius.md,
      onTap: () => Get.toNamed(route),
      child: Row(children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
              color: AppColors.limeSoft,
              borderRadius: BorderRadius.circular(16)),
          child: Icon(icon, color: AppColors.ink),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: theme.textTheme.titleSmall),
            const SizedBox(height: 3),
            Text(subtitle, style: theme.textTheme.bodySmall),
          ]),
        ),
        const Icon(Icons.chevron_right_rounded),
      ]),
    );
  }
}
