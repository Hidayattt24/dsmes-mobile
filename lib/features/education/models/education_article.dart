import 'package:flutter/material.dart';

@immutable
class ArticleSectionData {
  final String id;
  final int sectionOrder;
  final String title;
  final String type;
  final String content;
  final String imageUrl;
  final List<ArticleStepData> steps;

  const ArticleSectionData({
    this.id = '',
    this.sectionOrder = 0,
    required this.title,
    this.type = 'paragraf',
    required this.content,
    this.imageUrl = '',
    this.steps = const [],
  });

  factory ArticleSectionData.fromJson(Map<String, dynamic> json) {
    var stepsList = json['steps'] as List? ?? [];
    return ArticleSectionData(
      id: json['id'] ?? '',
      sectionOrder: json['section_order'] ?? 0,
      title: json['section_title'] ?? '',
      type: json['section_type'] ?? 'paragraf',
      content: json['content_text'] ?? '',
      imageUrl: json['image_url'] ?? '',
      steps: stepsList.map((s) => ArticleStepData.fromJson(s)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'section_order': sectionOrder,
      'section_title': title,
      'section_type': type,
      'content_text': content,
      'image_url': imageUrl,
      'steps': steps.map((s) => s.toJson()).toList(),
    };
  }
}

@immutable
class ArticleStepData {
  final String id;
  final int stepOrder;
  final String stepText;

  const ArticleStepData({
    required this.id,
    required this.stepOrder,
    required this.stepText,
  });

  factory ArticleStepData.fromJson(Map<String, dynamic> json) {
    return ArticleStepData(
      id: json['id'] ?? '',
      stepOrder: json['step_order'] ?? 0,
      stepText: json['step_text'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'step_order': stepOrder, 'step_text': stepText};
  }
}

@immutable
class EducationArticle {
  final String id;
  final String title;
  final String category;
  final String readTime;
  final String author;
  final String date;
  final int views;
  final String imageUrl;
  final String? tagText;
  final String? readStatus;
  final double? readProgress;
  final String quoteText;
  final List<String> bodyParagraphs;
  final List<String> galleryImageUrls;
  final List<ArticleSectionData> sections;
  final String calloutText;
  final List<String> tags;
  final bool isCompleted;
  final bool isBookmarked;
  final bool isYoutubeWatched;
  final bool isArticleRead;
  final bool hasVideo;
  final String? videoUrl;
  final String? videoDuration;
  final String? channelName;
  final bool hasAudio;
  final String? audioUrl;
  final bool isAudioListened;
  final int audioListenDuration;
  final int audioLastTimestamp;

  const EducationArticle({
    required this.id,
    required this.title,
    required this.category,
    required this.readTime,
    required this.author,
    required this.date,
    required this.views,
    required this.imageUrl,
    this.tagText,
    this.readStatus,
    this.readProgress,
    required this.quoteText,
    required this.bodyParagraphs,
    required this.galleryImageUrls,
    required this.sections,
    required this.calloutText,
    required this.tags,
    this.isCompleted = false,
    this.isBookmarked = false,
    this.isYoutubeWatched = false,
    this.isArticleRead = false,
    this.hasVideo = false,
    this.videoUrl,
    this.videoDuration,
    this.channelName,
    this.hasAudio = false,
    this.audioUrl,
    this.isAudioListened = false,
    this.audioListenDuration = 0,
    this.audioLastTimestamp = 0,
  });

  EducationArticle copyWith({
    String? id,
    String? title,
    String? category,
    String? readTime,
    String? author,
    String? date,
    int? views,
    String? imageUrl,
    String? tagText,
    String? readStatus,
    double? readProgress,
    String? quoteText,
    List<String>? bodyParagraphs,
    List<String>? galleryImageUrls,
    List<ArticleSectionData>? sections,
    String? calloutText,
    List<String>? tags,
    bool? isCompleted,
    bool? isBookmarked,
    bool? isYoutubeWatched,
    bool? isArticleRead,
    bool? hasVideo,
    String? videoUrl,
    String? videoDuration,
    String? channelName,
    bool? hasAudio,
    String? audioUrl,
    bool? isAudioListened,
    int? audioListenDuration,
    int? audioLastTimestamp,
  }) {
    return EducationArticle(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      readTime: readTime ?? this.readTime,
      author: author ?? this.author,
      date: date ?? this.date,
      views: views ?? this.views,
      imageUrl: imageUrl ?? this.imageUrl,
      tagText: tagText ?? this.tagText,
      readStatus: readStatus ?? this.readStatus,
      readProgress: readProgress ?? this.readProgress,
      quoteText: quoteText ?? this.quoteText,
      bodyParagraphs: bodyParagraphs ?? this.bodyParagraphs,
      galleryImageUrls: galleryImageUrls ?? this.galleryImageUrls,
      sections: sections ?? this.sections,
      calloutText: calloutText ?? this.calloutText,
      tags: tags ?? this.tags,
      isCompleted: isCompleted ?? this.isCompleted,
      isBookmarked: isBookmarked ?? this.isBookmarked,
      isYoutubeWatched: isYoutubeWatched ?? this.isYoutubeWatched,
      isArticleRead: isArticleRead ?? this.isArticleRead,
      hasVideo: hasVideo ?? this.hasVideo,
      videoUrl: videoUrl ?? this.videoUrl,
      videoDuration: videoDuration ?? this.videoDuration,
      channelName: channelName ?? this.channelName,
      hasAudio: hasAudio ?? this.hasAudio,
      audioUrl: audioUrl ?? this.audioUrl,
      isAudioListened: isAudioListened ?? this.isAudioListened,
      audioListenDuration: audioListenDuration ?? this.audioListenDuration,
      audioLastTimestamp: audioLastTimestamp ?? this.audioLastTimestamp,
    );
  }

  String? get youtubeVideoId {
    if (videoUrl == null || videoUrl!.trim().isEmpty) return null;
    final regExp = RegExp(
      r'^.*(?:youtu.be\/|v\/|e\/|u\/\w\/|embed\/|shorts\/|v=|\&v=)([^#\&\?]*).*',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(videoUrl!);
    if (match != null && match.groupCount >= 1) {
      final id = match.group(1);
      if (id != null && id.length == 11) return id;
    }
    return null;
  }

  String? get audioYoutubeVideoId {
    if (audioUrl != null && audioUrl!.trim().isNotEmpty) {
      final regExp = RegExp(
        r'^.*(?:youtu.be\/|v\/|e\/|u\/\w\/|embed\/|shorts\/|v=|\&v=)([^#\&\?]*).*',
        caseSensitive: false,
      );
      final match = regExp.firstMatch(audioUrl!);
      if (match != null && match.groupCount >= 1) {
        final id = match.group(1);
        if (id != null && id.length == 11) return id;
      }
    }
    for (final p in bodyParagraphs) {
      final match = RegExp(r'data-audio-youtube-id="([^"]+)"').firstMatch(p);
      if (match != null && match.group(1)?.length == 11) {
        return match.group(1);
      }
    }
    return null;
  }

  factory EducationArticle.fromJson(Map<String, dynamic> json) {
    var rawSections = json['sections'] as List? ?? [];
    List<ArticleSectionData> parsedSections =
        rawSections.map((s) => ArticleSectionData.fromJson(s)).toList();

    // Map fields from backend
    String title = json['title'] ?? '';
    String categoryName = json['category_name'] ?? 'Umum';
    int readSec =
        json['estimated_read_seconds'] ??
        (json['estimated_read_minutes'] != null
            ? (json['estimated_read_minutes'] as int) * 60
            : 60);
    String formattedReadTime;
    if (readSec < 60) {
      formattedReadTime = '$readSec detik';
    } else if (readSec % 60 == 0) {
      formattedReadTime = '${readSec ~/ 60} menit';
    } else {
      formattedReadTime = '${readSec ~/ 60} mnt ${readSec % 60} dtk';
    }
    String author = json['author_name'] ?? 'Tim Medis DIBA';
    String bannerUrl = json['banner_image_url'] ?? '';
    String rawSummary = json['summary'] ?? '';
    String rawContent = json['content'] ?? '';
    String youtubeLink = json['youtube_link'] ?? '';
    String audioUrl = json['audio_url'] ?? '';
    if (audioUrl.isEmpty && rawContent.isNotEmpty) {
      final audioMatch =
          RegExp(r'data-audio-url="([^"]+)"').firstMatch(rawContent) ??
          RegExp(r'data-audio-youtube-id="([^"]+)"').firstMatch(rawContent) ??
          RegExp(r'<audio[^>]*src="([^"]+)"').firstMatch(rawContent);
      if (audioMatch != null) {
        final val = audioMatch.group(1) ?? '';
        if (val.length == 11 && !val.contains('/')) {
          audioUrl = 'https://www.youtube.com/watch?v=$val';
        } else {
          audioUrl = val;
        }
      }
    }
    bool bookmarked = json['is_bookmarked'] ?? false;
    bool completed = json['is_completed'] ?? false;
    bool youtubeWatched = json['youtube_watched'] ?? false;
    bool articleRead = json['article_read'] ?? false;
    bool audioListened = json['audio_listened'] ?? false;
    int audioListenDuration = json['audio_listen_duration'] ?? 0;
    int audioLastTimestamp = json['audio_last_timestamp'] ?? 0;
    String createdAt = json['created_at'] ?? '';

    // Parse date nicely
    String formattedDate = '';
    if (createdAt.isNotEmpty) {
      try {
        DateTime dt = DateTime.parse(createdAt);
        formattedDate = '${dt.day}-${dt.month}-${dt.year}';
      } catch (_) {
        formattedDate = createdAt;
      }
    }

    String cleanedContent = _cleanHtmlContent(rawContent);

    final isDone = completed || youtubeWatched || articleRead || audioListened;

    return EducationArticle(
      id: json['id'] ?? '',
      title: title,
      category: categoryName,
      readTime: formattedReadTime,
      author: author.isEmpty ? 'Tim Medis DIBA' : author,
      date: formattedDate,
      views: json['read_count'] ?? 0,
      imageUrl: bannerUrl,
      tagText: null,
      readStatus: isDone ? 'Selesai' : 'Belum Selesai',
      readProgress: isDone ? 1.0 : 0.0,
      quoteText: rawSummary,
      bodyParagraphs: cleanedContent.isNotEmpty ? [cleanedContent] : const [],
      galleryImageUrls: const [],
      sections: parsedSections,
      calloutText: '',
      tags: const [],
      isBookmarked: bookmarked,
      isCompleted: isDone,
      isYoutubeWatched: youtubeWatched,
      isArticleRead: articleRead,
      hasVideo: youtubeLink.isNotEmpty,
      videoUrl: youtubeLink,
      videoDuration: 'Edukasi Video',
      channelName: 'DIBA Official',
      hasAudio: audioUrl.isNotEmpty,
      audioUrl: audioUrl.isNotEmpty ? audioUrl : null,
      isAudioListened: audioListened,
      audioListenDuration: audioListenDuration,
      audioLastTimestamp: audioLastTimestamp,
    );
  }

  Map<String, dynamic> toJson() {
    int parsedSec = 60;
    final parts = readTime.split(' ');
    if (readTime.contains('detik')) {
      parsedSec = int.tryParse(parts.first) ?? 60;
    } else if (readTime.contains('menit')) {
      parsedSec = (int.tryParse(parts.first) ?? 1) * 60;
    }
    return {
      'id': id,
      'title': title,
      'category_name': category,
      'estimated_read_seconds': parsedSec,
      'estimated_read_minutes': (parsedSec + 59) ~/ 60,
      'author_name': author,
      'created_at': date,
      'read_count': views,
      'banner_image_url': imageUrl,
      'summary': quoteText,
      'content': bodyParagraphs.isNotEmpty ? bodyParagraphs.first : '',
      'sections': sections.map((s) => s.toJson()).toList(),
      'is_bookmarked': isBookmarked,
      'is_completed': isCompleted,
      'youtube_watched': isYoutubeWatched,
      'article_read': isArticleRead,
      'audio_listened': isAudioListened,
      'audio_listen_duration': audioListenDuration,
      'audio_last_timestamp': audioLastTimestamp,
      'youtube_link': videoUrl ?? '',
      'audio_url': audioUrl ?? '',
    };
  }
}

/// Cleans Web Admin editor control artifacts (<button>, .editor-actions, etc.) from HTML content.
String _cleanHtmlContent(String html) {
  if (html.isEmpty) return html;
  var cleaned = html;
  // Remove button tags and their inner content (e.g., edit, delete buttons)
  cleaned = cleaned.replaceAll(
    RegExp(r'<button[^>]*>.*?</button>', caseSensitive: false, dotAll: true),
    '',
  );
  // Remove editor action divs
  cleaned = cleaned.replaceAll(
    RegExp(
      r'<div[^>]*class="[^"]*editor-actions[^"]*"[^>]*>.*?</div>',
      caseSensitive: false,
      dotAll: true,
    ),
    '',
  );
  // Remove editor overlay divs
  cleaned = cleaned.replaceAll(
    RegExp(
      r'<div[^>]*class="[^"]*editor-only-overlay[^"]*"[^>]*>.*?</div>',
      caseSensitive: false,
      dotAll: true,
    ),
    '',
  );
  // Remove onclick attributes
  cleaned = cleaned.replaceAll(
    RegExp(r'onclick="[^"]*"', caseSensitive: false),
    '',
  );
  return cleaned;
}
