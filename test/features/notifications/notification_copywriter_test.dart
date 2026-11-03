import 'package:flutter_test/flutter_test.dart';
import 'package:dsmes_mobile/features/notifications/helpers/notification_copywriter.dart';
import 'package:dsmes_mobile/features/notifications/models/notification_item.dart';

void main() {
  group('NotificationCopywriter Unit Tests', () {
    test('Walk reminder keeps its activity copy when body mentions blood sugar', () {
      final (title, desc) = NotificationCopywriter.getInteractiveCopy(
        rawTitle: 'Waktunya main valo! 🏃‍♂️',
        rawDescription: 'Hai, tes18! Yuk lakukan main valo sejenak untuk membantu menjaga kadar gula darah tetap stabil 🌟',
        type: NotificationType.medication,
        iconName: 'walk',
        activityName: 'main valo',
        actionType: 'activity_entry',
        username: 'tes18',
      );
      expect(title, 'Waktunya main valo! 🏃‍♂️');
      expect(desc, startsWith('Hai, tes18! Yuk lakukan main valo'));
      expect(desc, isNot(contains('mencatat angka')));
    });

    test('Walk icon wins over blood-sugar words in a legacy payload', () {
      final (title, desc) = NotificationCopywriter.getInteractiveCopy(
        rawTitle: 'Waktunya main valo! 🏃‍♂️',
        rawDescription: 'Yuk lakukan main valo untuk menjaga kadar gula darah',
        type: NotificationType.medication,
        iconName: 'walk',
        activityName: 'main valo',
      );
      expect(title, 'Waktunya main valo! 🏃‍♂️');
      expect(desc, isNot(contains('mencatat angka')));
    });

    test('Generates interactive copy for Medication / Insulin (pill icon)', () {
      final (title, desc) = NotificationCopywriter.getInteractiveCopy(
        rawTitle: 'Minum Obat Malam',
        rawDescription: 'Obat metformin sesudah makan',
        type: NotificationType.medication,
        iconName: 'pill',
        activityName: 'Minum Obat Malam',
      );

      expect(title, contains('Minum Obat Malam'));
      expect(title, contains('💊'));
      expect(desc, contains('anjuran dokter'));
    });

    test('Generates interactive copy for Blood Sugar check', () {
      final (title, desc) = NotificationCopywriter.getInteractiveCopy(
        rawTitle: 'Cek Gula Darah Puasa',
        rawDescription: 'Pemeriksaan pagi hari',
        type: NotificationType.medication,
        iconName: 'blood',
        activityName: 'Cek Gula Darah Puasa',
      );

      expect(title, contains('Cek Gula Darah Puasa'));
      expect(title, contains('🩸'));
      expect(desc, contains('gula darah'));
    });

    test('Generates interactive copy for Physical Activity (walk icon)', () {
      final (title, desc) = NotificationCopywriter.getInteractiveCopy(
        rawTitle: 'Jalan Pagi',
        rawDescription: 'Jalan santai 30 menit',
        type: NotificationType.medication,
        iconName: 'walk',
        activityName: 'Jalan Pagi',
      );

      expect(title, contains('Jalan Pagi'));
      expect(title, contains('🏃‍♂️'));
      expect(desc, contains('gula darah tetap stabil'));
    });

    test('Generates interactive copy for Hydration (water icon)', () {
      final (title, desc) = NotificationCopywriter.getInteractiveCopy(
        rawTitle: 'Minum Air Putih',
        rawDescription: 'Cairan harian',
        type: NotificationType.medication,
        iconName: 'water',
        activityName: 'Minum Air Putih',
      );

      expect(title, contains('Minum Air Putih'));
      expect(title, contains('💧'));
      expect(desc, contains('air putih'));
    });

    test('Generates interactive copy for Education notifications', () {
      final (title, desc) = NotificationCopywriter.getInteractiveCopy(
        rawTitle: 'Materi Edukasi Baru',
        rawDescription: 'Yuk pelajari "Panduan Nutrisi Diabetes"',
        type: NotificationType.education,
      );

      expect(title, contains('Panduan Nutrisi Diabetes'));
      expect(title, contains('📖'));
      expect(desc, contains('Panduan Nutrisi Diabetes'));
    });

    test('Generates interactive copy for Custom Reminder Fallback', () {
      final (title, desc) = NotificationCopywriter.getInteractiveCopy(
        rawTitle: 'Periksa Kaki',
        rawDescription: 'Kebersihan kaki harian',
        type: NotificationType.medication,
        iconName: 'custom_icon',
        activityName: 'Periksa Kaki',
      );

      expect(title, contains('Periksa Kaki'));
      expect(desc, contains('Periksa Kaki'));
    });

    test('Nutrisi air category with restaurant icon produces meal copy, not water copy', () {
      final (title, desc) = NotificationCopywriter.getInteractiveCopy(
        rawTitle: 'Catat Makanan Hari Ini',
        rawDescription: '',
        type: NotificationType.medication,
        iconName: 'restaurant',
        activityName: 'Catat Makanan Hari Ini',
        category: 'nutrisi_air',
      );

      expect(title, contains('🥗'));
      expect(title, isNot(contains('💧')));
      expect(desc, contains('piring sehatmu'));
      expect(desc, isNot(contains('air putih')));
    });

    test('Nutrisi air category with water icon produces water copy', () {
      final (title, desc) = NotificationCopywriter.getInteractiveCopy(
        rawTitle: 'Minum Air Putih',
        rawDescription: '',
        type: NotificationType.medication,
        iconName: 'water',
        activityName: 'Minum Air Putih',
        category: 'nutrisi_air',
      );

      expect(title, contains('💧'));
      expect(desc, contains('air putih'));
    });

    test('Uses the fixed personalized copy for automatic meal reminder', () {
      final (title, desc) = NotificationCopywriter.getInteractiveCopy(
        rawTitle: 'Pengingat DIBA',
        rawDescription: '',
        type: NotificationType.medication,
        actionType: 'meal_entry',
        username: 'Ayu',
      );

      expect(title, 'Waktunya Catat Makanan 🥗');
      expect(desc, 'Hai, Ayu! Jangan lupa mencatat makanan yang kamu konsumsi hari ini, ya.');
    });

    test('Does not render an empty username placeholder', () {
      final (_, desc) = NotificationCopywriter.getInteractiveCopy(
        rawTitle: 'Pengingat DIBA',
        rawDescription: '',
        type: NotificationType.medication,
        actionType: 'blood_sugar_entry',
      );

      expect(desc, 'Jangan lupa cek dan catat gula darahmu hari ini, ya.');
      expect(desc, isNot(contains('{nama_user}')));
    });
  });
}
