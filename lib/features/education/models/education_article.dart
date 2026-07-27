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
    );
  }

  String? get youtubeVideoId {
    if (videoUrl == null || videoUrl!.trim().isEmpty) return null;
    final regExp = RegExp(
      r'^.*(?:youtu.be\/|v\/|e\/|u\/\w\/|embed\/|v=|\&v=)([^#\&\?]*).*',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(videoUrl!);
    if (match != null && match.groupCount >= 1) {
      final id = match.group(1);
      if (id != null && id.length == 11) return id;
    }
    return null;
  }

  factory EducationArticle.fromJson(Map<String, dynamic> json) {
    var rawSections = json['sections'] as List? ?? [];
    List<ArticleSectionData> parsedSections = rawSections
        .map((s) => ArticleSectionData.fromJson(s))
        .toList();

    // Map fields from backend
    String title = json['title'] ?? '';
    String categoryName = json['category_name'] ?? 'Umum';
    int readMin = json['estimated_read_minutes'] ?? 5;
    String author = json['author_name'] ?? 'Tim Medis DSMES';
    String bannerUrl = json['banner_image_url'] ?? '';
    String rawSummary = json['summary'] ?? '';
    String rawContent = json['content'] ?? '';
    String youtubeLink = json['youtube_link'] ?? '';
    bool bookmarked = json['is_bookmarked'] ?? false;
    bool completed = json['is_completed'] ?? false;
    bool youtubeWatched = json['youtube_watched'] ?? false;
    bool articleRead = json['article_read'] ?? false;
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

    return EducationArticle(
      id: json['id'] ?? '',
      title: title,
      category: categoryName,
      readTime: '$readMin menit',
      author: author.isEmpty ? 'Tim Medis DSMES' : author,
      date: formattedDate,
      views: json['read_count'] ?? 0,
      imageUrl: bannerUrl,
      tagText: null,
      readStatus: (completed || youtubeWatched || articleRead) ? 'Selesai' : 'Belum Selesai',
      readProgress: (completed || youtubeWatched || articleRead) ? 1.0 : 0.0,
      quoteText: rawSummary,
      bodyParagraphs: cleanedContent.isNotEmpty ? [cleanedContent] : const [],
      galleryImageUrls: const [],
      sections: parsedSections,
      calloutText: '',
      tags: const [],
      isBookmarked: bookmarked,
      isCompleted: completed || youtubeWatched || articleRead,
      isYoutubeWatched: youtubeWatched,
      isArticleRead: articleRead,
      hasVideo: youtubeLink.isNotEmpty,
      videoUrl: youtubeLink,
      videoDuration: 'Edukasi Video',
      channelName: 'DSMES Official',
    );
  }
}

/// Cleans Web Admin editor control artifacts (<button>, .editor-actions, etc.) from HTML content.
String _cleanHtmlContent(String html) {
  if (html.isEmpty) return html;
  var cleaned = html;
  // Remove button tags and their inner content (e.g., edit, delete buttons)
  cleaned = cleaned.replaceAll(RegExp(r'<button[^>]*>.*?</button>', caseSensitive: false, dotAll: true), '');
  // Remove editor action divs
  cleaned = cleaned.replaceAll(RegExp(r'<div[^>]*class="[^"]*editor-actions[^"]*"[^>]*>.*?</div>', caseSensitive: false, dotAll: true), '');
  // Remove editor overlay divs
  cleaned = cleaned.replaceAll(RegExp(r'<div[^>]*class="[^"]*editor-only-overlay[^"]*"[^>]*>.*?</div>', caseSensitive: false, dotAll: true), '');
  // Remove onclick attributes
  cleaned = cleaned.replaceAll(RegExp(r'onclick="[^"]*"', caseSensitive: false), '');
  return cleaned;
}
