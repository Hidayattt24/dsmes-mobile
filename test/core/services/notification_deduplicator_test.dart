import 'package:dsmes_mobile/core/services/notification_deduplicator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await NotificationDeduplicator.clear();
  });

  group('NotificationDeduplicator.resolveKey', () {
    test('prioritizes occurrence_id when present', () {
      final key = NotificationDeduplicator.resolveKey({
        'occurrence_id': 'occ-123:2026-11-03T12:00:00Z',
        'reminder_id': 'rem-456',
        'scheduled_at': '2026-11-03T12:00:00Z',
      }, messageId: 'msg-789');

      expect(key, 'occ-123:2026-11-03T12:00:00Z');
    });

    test('falls back to reminder_id + scheduled_at when occurrence_id missing', () {
      final key = NotificationDeduplicator.resolveKey({
        'reminder_id': 'rem-456',
        'scheduled_at': '2026-11-03T12:00:00Z',
      }, messageId: 'msg-789');

      expect(key, 'rem-456_2026-11-03T12:00:00Z');
    });

    test('falls back to message_id when occurrence_id and scheduled_at missing', () {
      final key = NotificationDeduplicator.resolveKey({}, messageId: 'msg-789');

      expect(key, 'msg-789');
    });

    test('falls back to reminder_id when only reminder_id is present', () {
      final key = NotificationDeduplicator.resolveKey({
        'reminder_id': 'rem-only',
      });

      expect(key, 'reminder_rem-only');
    });

    test('returns empty string when no identifier exists', () {
      final key = NotificationDeduplicator.resolveKey({});
      expect(key, '');
    });
  });

  group('NotificationDeduplicator.resolveNotificationId', () {
    test('returns deterministic positive integer', () {
      const key = 'occ-test-123';
      final id1 = NotificationDeduplicator.resolveNotificationId(key);
      final id2 = NotificationDeduplicator.resolveNotificationId(key);

      expect(id1, id2);
      expect(id1 >= 0, isTrue);
    });

    test('returns 0 for empty key', () {
      expect(NotificationDeduplicator.resolveNotificationId(''), 0);
    });
  });

  group('NotificationDeduplicator duplicate detection & TTL', () {
    test('deduplicates identical occurrence key', () async {
      const key = 'occ-dup-test-1';

      expect(await NotificationDeduplicator.isDuplicate(key), isFalse);

      await NotificationDeduplicator.markProcessed(key);

      expect(await NotificationDeduplicator.isDuplicate(key), isTrue);
    });

    test('ignores empty key', () async {
      expect(await NotificationDeduplicator.isDuplicate(''), isFalse);
      await NotificationDeduplicator.markProcessed('');
      expect(await NotificationDeduplicator.isDuplicate(''), isFalse);
    });

    test('expires entries older than TTL', () async {
      const key = 'occ-expired-test';

      await NotificationDeduplicator.markProcessed(key);
      expect(await NotificationDeduplicator.isDuplicate(key), isTrue);

      await Future<void>.delayed(const Duration(milliseconds: 10));

      final isDup = await NotificationDeduplicator.isDuplicate(
        key,
        ttl: const Duration(milliseconds: 5),
      );
      expect(isDup, isFalse);
    });

    test('clear removes cached entries', () async {
      const key = 'occ-clear-test';

      await NotificationDeduplicator.markProcessed(key);
      expect(await NotificationDeduplicator.isDuplicate(key), isTrue);

      await NotificationDeduplicator.clear();
      expect(await NotificationDeduplicator.isDuplicate(key), isFalse);
    });
  });
}
