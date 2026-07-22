import 'package:flutter/material.dart';

@immutable
class ArticleSectionData {
  final String title;
  final String content;

  const ArticleSectionData({
    required this.title,
    required this.content,
  });
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
      hasVideo: hasVideo ?? this.hasVideo,
      videoUrl: videoUrl ?? this.videoUrl,
      videoDuration: videoDuration ?? this.videoDuration,
      channelName: channelName ?? this.channelName,
    );
  }
}
