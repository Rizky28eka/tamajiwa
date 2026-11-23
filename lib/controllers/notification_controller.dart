import 'dart:convert';
import 'package:get/get.dart';
import '../models/app_notification_model.dart';
import '../services/api_service.dart';
import '../services/logger_service.dart';

class NotificationController extends GetxController {
  final LoggerService _logger = LoggerService();

  final RxList<AppNotification> items = <AppNotification>[].obs;
  final RxInt unreadCount = 0.obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetch();
  }

  Future<void> fetch() async {
    isLoading.value = true;
    error.value = '';
    try {
      final res = await ApiService.get('notifications');
      if (res.statusCode == 200) {
        final data = json.decode(res.body) as Map<String, dynamic>;
        items.value = [
          for (final n in (data['data'] as List? ?? const []))
            AppNotification.fromJson(Map<String, dynamic>.from(n as Map)),
        ];
        unreadCount.value = (data['unread_count'] as num?)?.toInt() ?? 0;
      } else if (res.statusCode != 401) {
        error.value = 'Gagal memuat notifikasi';
      }
    } catch (e) {
      error.value = 'Periksa koneksi Anda lalu coba lagi';
      _logger.error('Gagal memuat notifikasi', error: e);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markRead(AppNotification n) async {
    if (n.isRead) return;
    // Optimistis: perbarui UI dulu, kembalikan bila gagal.
    final index = items.indexWhere((x) => x.id == n.id);
    if (index == -1) return;
    final before = items[index];
    items[index] = before.asRead();
    unreadCount.value = (unreadCount.value - 1).clamp(0, 1 << 30);
    try {
      final res = await ApiService.post('notifications/${n.id}/read');
      if (res.statusCode != 200) throw Exception('status ${res.statusCode}');
    } catch (e) {
      items[index] = before;
      unreadCount.value += 1;
      _logger.error('Gagal menandai notifikasi dibaca', error: e);
    }
  }

  Future<void> markAllRead() async {
    if (unreadCount.value == 0) return;
    try {
      final res = await ApiService.post('notifications/read-all');
      if (res.statusCode == 200) {
        items.value = [for (final n in items) n.asRead()];
        unreadCount.value = 0;
      }
    } catch (e) {
      _logger.error('Gagal menandai semua dibaca', error: e);
    }
  }
}
