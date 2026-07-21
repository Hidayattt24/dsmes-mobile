import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/notification_item.dart';

class NotificationsNotifier extends Notifier<List<NotificationItem>> {
  @override
  List<NotificationItem> build() {
    return const [
      NotificationItem(
        id: 'warn_1',
        title: 'Gula Darah Tinggi!',
        description:
            'Catatan gula darah Anda hari ini (148 mg/dL) berada di atas rentang normal. Periksa konsumsi makanan Anda.',
        timestamp: '10 mnt lalu',
        type: NotificationType.warning,
        isUnread: true,
        group: 'Hari Ini',
      ),
      NotificationItem(
        id: 'meds_1',
        title: 'Waktunya Minum Obat',
        description:
            'Jadwal minum obat Metformin 500mg Anda sudah dekat (08:00). Jangan lupa diminum setelah makan.',
        timestamp: '2 jam lalu',
        type: NotificationType.medication,
        isUnread: false,
        group: 'Hari Ini',
      ),
      NotificationItem(
        id: 'edu_1',
        title: 'Artikel Edukasi Baru',
        description:
            'Admin Puskesmas baru saja menerbitkan artikel: \'Panduan Lengkap Manajemen Mandiri Diabetes Melitus\'. Yuk baca sekarang!',
        timestamp: '1 hari lalu',
        type: NotificationType.education,
        isUnread: false,
        group: 'Kemarin',
      ),
      NotificationItem(
        id: 'target_1',
        title: 'Target Harian Tercapai',
        description:
            'Selamat! Anda telah mencapai target berjalan kaki 5.000 langkah kemarin. Pertahankan performa Anda.',
        timestamp: '1 hari lalu',
        type: NotificationType.targetAchieved,
        isUnread: false,
        group: 'Kemarin',
      ),
    ];
  }

  void markAsRead(String id) {
    state = [
      for (final notification in state)
        if (notification.id == id) notification.copyWith(isUnread: false) else notification,
    ];
  }

  void markAllAsRead() {
    state = [
      for (final notification in state)
        if (notification.isUnread) notification.copyWith(isUnread: false) else notification,
    ];
  }
}

final notificationsProvider = NotifierProvider<NotificationsNotifier, List<NotificationItem>>(
  NotificationsNotifier.new,
);
