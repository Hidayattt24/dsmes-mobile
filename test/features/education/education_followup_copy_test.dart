import 'package:dsmes_mobile/features/notifications/helpers/notification_copywriter.dart';
import 'package:dsmes_mobile/features/notifications/models/notification_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('follow-up copy is distinct from a new education notification', () {
    final (title, body) = NotificationCopywriter.getEducationFollowupCopy(
      articleTitle: 'Porsi Makan',
      username: 'Dayat',
    );
    expect(title, 'Pengingat Edukasi: Porsi Makan 📖');
    expect(
      body,
      'Hai, Dayat! Kamu belum membuka materi ini. Yuk pelajari saat sempat.',
    );

    final (newTitle, _) = NotificationCopywriter.getInteractiveCopy(
      rawTitle: 'Materi Edukasi Baru',
      rawDescription:
          'Yuk pelajari "Porsi Makan" untuk panduan sehatmu hari ini',
      type: NotificationType.education,
    );
    expect(newTitle, 'Edukasi Baru: Porsi Makan 📖');
  });

  test('follow-up copy omits empty name and title naturally', () {
    final (title, body) = NotificationCopywriter.getEducationFollowupCopy(
      articleTitle: ' ',
      username: ' ',
    );
    expect(title, 'Pengingat Edukasi 📖');
    expect(body, 'Kamu belum membuka materi ini. Yuk pelajari saat sempat.');
  });
}
