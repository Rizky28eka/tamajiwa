import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/notification_controller.dart';
import '../../theme/app_theme.dart';
import 'ds.dart';

/// Tombol lonceng dengan badge jumlah notifikasi belum dibaca.
class NotificationBell extends StatelessWidget {
  const NotificationBell({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.isRegistered<NotificationController>()
        ? Get.find<NotificationController>()
        : Get.put(NotificationController(), permanent: true);
    return Obx(() {
      final n = c.unreadCount.value;
      return Stack(clipBehavior: Clip.none, children: [
        DsRoundIcon(
          icon: Icons.notifications_none_rounded,
          tooltip: 'Notifikasi',
          onTap: () => Get.toNamed('/notifications'),
        ),
        if (n > 0)
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
              padding: const EdgeInsets.symmetric(horizontal: 5),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.lime,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.ink, width: 1.5),
              ),
              child: Text(n > 99 ? '99+' : '$n',
                  style: const TextStyle(
                      color: AppColors.ink,
                      fontSize: 11,
                      fontWeight: FontWeight.w800)),
            ),
          ),
      ]);
    });
  }
}
