import 'dart:io';

import 'package:dsmes_mobile/core/storage/local_storage_service.dart';
import 'package:dsmes_mobile/core/widgets/app_smart_image.dart';
import 'package:dsmes_mobile/features/education/models/education_article.dart';
import 'package:dsmes_mobile/features/education/widgets/education_audio_player_card.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('data URI with expanding width uses a finite decode size', (
    tester,
  ) async {
    const image =
        'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVQIHWP4z8DwHwAFgAI/ScLttAAAAABJRU5ErkJggg==';

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 200,
            height: 200,
            child: AppSmartImage(imageUrl: image, width: double.infinity),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });

  test('education list skips article HTML while detail retains it', () {
    final payload = <String, dynamic>{
      'id': 'article-1',
      'title': 'Artikel',
      'content': '<p>Isi artikel</p>',
    };
    expect(
      EducationArticle.fromJson(payload, includeContent: false).bodyParagraphs,
      isEmpty,
    );
    expect(EducationArticle.fromJson(payload).bodyParagraphs, isNotEmpty);
  });
  test('audio upload path uses the configured API host', () {
    expect(
      resolveEducationAudioUri(
        '/uploads/audio/example.m4a',
        'http://10.0.2.2:8080/api/v1',
      ).toString(),
      'http://10.0.2.2:8080/uploads/audio/example.m4a',
    );
    expect(
      resolveEducationAudioUri(
        'http://localhost:8080/uploads/audio/example.m4a',
        'https://api.example.org/api/v1',
      ).toString(),
      'https://api.example.org/uploads/audio/example.m4a',
    );
    expect(
      resolveEducationAudioUri(
        'https://cdn.example.org/audio/example.m4a',
        'http://10.0.2.2:8080/api/v1',
      ).toString(),
      'https://cdn.example.org/audio/example.m4a',
    );
  });

  test('audio completion data survives article cache serialization', () {
    final article = EducationArticle.fromJson({
      'id': 'article-1',
      'title': 'Audio edukasi',
      'audio_url': '/uploads/audio/example.m4a',
      'audio_listened': true,
      'audio_listen_duration': 42,
      'audio_last_timestamp': 38,
    });

    expect(article.isAudioListened, isTrue);
    expect(article.audioListenDuration, 42);
    expect(article.audioLastTimestamp, 38);

    final restored = EducationArticle.fromJson(article.toJson());
    expect(restored.isAudioListened, isTrue);
    expect(restored.audioListenDuration, 42);
    expect(restored.audioLastTimestamp, 38);
  });

  test('concurrent encrypted cache writes leave a readable file', () async {
    FlutterSecureStorage.setMockInitialValues({});
    final directory = await Directory.systemTemp.createTemp('diba-cache-test-');
    addTearDown(() => directory.delete(recursive: true));
    final storage = LocalStorageService(
      const FlutterSecureStorage(),
      overrideDirectory: directory,
    );

    await Future.wait([
      for (var i = 0; i < 20; i++)
        storage.writeEncryptedJson('offline_cache_education_articles', {
          'revision': i,
        }, userId: 'patient-1'),
    ]);

    expect(
      await storage.readEncryptedJson(
        'offline_cache_education_articles',
        userId: 'patient-1',
      ),
      {'revision': 19},
    );
  });
}
