import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/form_controller.dart';
import '../controllers/notification_controller.dart';
import '../models/app_notification_model.dart';
import '../services/role_guard.dart';
import '../theme/app_theme.dart';
import '../widgets/ds/ds.dart';
import 'form_detail_view.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  static String relativeTime(DateTime? t, {DateTime? now}) {
    if (t == null) return '';
    final diff = (now ?? DateTime.now()).difference(t.toLocal());
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    final l = t.toLocal();
    return '${l.day}/${l.month}/${l.year}';
  }

  static IconData iconFor(String type) {
    switch (type) {
      case 'form_approved':
        return Icons.check_circle_outline_rounded;
      case 'form_revised':
        return Icons.replay_rounded;
      case 'form_submitted':
        return Icons.hourglass_top_rounded;
      default:
        return Icons.notifications_none_rounded;
    }
  }

  Future<void> _open(NotificationController c, AppNotification n) async {
    await c.markRead(n);
    final id = n.formId;
    if (id == null) return;
    if (RoleGuard.isDosen()) {
      await Get.toNamed('/form-review/$id');
    } else {
      final form = await Get.put(FormController()).getFormById(id);
      if (form != null) {
        await Get.to(() => const FormDetailView(), arguments: form);
      }
    }
    c.fetch();
  }

  @override
  Widget build(BuildContext context) {
    final c = Get.isRegistered<NotificationController>()
        ? Get.find<NotificationController>()
        : Get.put(NotificationController(), permanent: true);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          Obx(() => TextButton(
                onPressed: c.unreadCount.value > 0 ? c.markAllRead : null,
                child: const Text('Tandai semua'),
              )),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.ink,
        backgroundColor: AppColors.lime,
        onRefresh: c.fetch,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Obx(() {
              if (c.isLoading.value && c.items.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (c.error.isNotEmpty && c.items.isEmpty) {
                return ListView(padding: const EdgeInsets.all(20), children: [
                  DsError(message: c.error.value, onRetry: c.fetch),
                ]);
              }
              if (c.items.isEmpty) {
                return ListView(children: const [
                  SizedBox(height: 80),
                  DsEmpty(
                    icon: Icons.notifications_none_rounded,
                    title: 'Belum ada notifikasi',
                    message:
                        'Pembaruan review dan pengajuan formulir akan muncul di sini.',
                  ),
                ]);
              }
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                children: [
                  for (final n in c.items) ...[
                    DsCard(
                      radius: AppRadius.md,
                      color: n.isRead ? null : AppColors.limeSoft,
                      onTap: () => _open(c, n),
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: n.isRead
                                    ? theme.colorScheme.surfaceContainerHighest
                                    : AppColors.lime,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(iconFor(n.type),
                                  size: 20,
                                  color: n.isRead
                                      ? theme.colorScheme.onSurface
                                      : AppColors.ink),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(n.title,
                                        style: theme.textTheme.titleSmall
                                            ?.copyWith(
                                                color: n.isRead
                                                    ? null
                                                    : AppColors.ink)),
                                    if (n.body != null) ...[
                                      const SizedBox(height: 3),
                                      Text(n.body!,
                                          style: TextStyle(
                                              color: n.isRead
                                                  ? theme.colorScheme
                                                      .onSurfaceVariant
                                                  : AppColors.ink)),
                                    ],
                                    const SizedBox(height: 6),
                                    Text(relativeTime(n.createdAt),
                                        style: theme.textTheme.bodySmall
                                            ?.copyWith(
                                                color: n.isRead
                                                    ? null
                                                    : AppColors.ink)),
                                  ]),
                            ),
                          ]),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}
