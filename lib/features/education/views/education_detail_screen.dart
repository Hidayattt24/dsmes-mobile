import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_smart_image.dart';
import '../models/education_article.dart';
import '../viewmodels/education_notifier.dart';
import '../widgets/article_information.dart';
import '../widgets/education_skeleton.dart';
import '../widgets/youtube_preview_card.dart';

class EducationDetailScreen extends ConsumerStatefulWidget {
  const EducationDetailScreen({super.key, required this.articleId});

  final String articleId;

  @override
  ConsumerState<EducationDetailScreen> createState() =>
      _EducationDetailScreenState();
}

class _EducationDetailScreenState extends ConsumerState<EducationDetailScreen> {
  final ScrollController _scrollController = ScrollController();

  // ──────────────────────────────────────────────────────────────
  // Read-progress tracking state
  // ──────────────────────────────────────────────────────────────
  DateTime? _readStartTime;
  int _lastReportedScrollPct = 0;
  bool _hasMarkedComplete = false;

  // ──────────────────────────────────────────────────────────────
  // Video watch tracking state
  // ──────────────────────────────────────────────────────────────
  int _videoWatchSeconds = 0;
  int _videoLastTimestampSeconds = 0;

  @override
  void initState() {
    super.initState();
    _readStartTime = DateTime.now();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _flushReadProgress(); // report on close
    super.dispose();
  }

  // ──────────────────────────────────────────────────────────────
  // Scroll tracking
  // ──────────────────────────────────────────────────────────────
  void _onScroll() {
    final pos = _scrollController.position;
    if (pos.maxScrollExtent <= 0) return;

    final pct = ((pos.pixels / pos.maxScrollExtent) * 100).round().clamp(
      0,
      100,
    );

    // Throttle: only report every 10% change
    if (pct - _lastReportedScrollPct >= 10) {
      _lastReportedScrollPct = pct;
      _flushReadProgress(scrollPct: pct);
    }
  }

  void _flushReadProgress({int? scrollPct, bool forceComplete = false}) {
    if (_readStartTime == null) return;
    final duration = DateTime.now().difference(_readStartTime!).inSeconds;
    final pct = scrollPct ?? _lastReportedScrollPct;

    ref
        .read(educationDetailProvider(widget.articleId).notifier)
        .reportReadProgress(duration: duration, scrollPercentage: pct);
  }

  // ──────────────────────────────────────────────────────────────
  // Video watch tracking callbacks (passed to YouTubePreviewCard)
  // ──────────────────────────────────────────────────────────────
  void _onVideoProgressUpdated(int watchedSeconds, int lastTimestamp) {
    _videoWatchSeconds = watchedSeconds;
    _videoLastTimestampSeconds = lastTimestamp;
  }

  void _onVideoEnded() {
    ref
        .read(educationDetailProvider(widget.articleId).notifier)
        .markVideoWatched();
  }

  Future<void> _markComplete() async {
    try {
      await ref
          .read(educationDetailProvider(widget.articleId).notifier)
          .markArticleRead();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Artikel edukasi berhasil ditandai selesai! 🎉'),
            backgroundColor: AppColors.primaryContainer,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menandai artikel. Silakan coba lagi.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // ──────────────────────────────────────────────────────────────
  // Bookmark toggle
  // ──────────────────────────────────────────────────────────────
  Future<void> _toggleBookmark() async {
    try {
      await ref
          .read(educationDetailProvider(widget.articleId).notifier)
          .toggleBookmark();
      final isNowBookmarked =
          ref
              .read(educationDetailProvider(widget.articleId))
              .value
              ?.isBookmarked ??
          false;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isNowBookmarked
                  ? 'Artikel berhasil disimpan di Markah Buku'
                  : 'Artikel dihapus dari Markah Buku',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal mengubah bookmark. Silakan coba lagi.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  // ──────────────────────────────────────────────────────────────
  // Share sheet
  // ──────────────────────────────────────────────────────────────
  void _handleShare(EducationArticle article) {
    final mockUrl = 'https://dsmes-aceh.id/edukasi/${article.id}';
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      backgroundColor: AppColors.surfaceContainerLowest,
      builder:
          (ctx) => Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.outlineVariant,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Bagikan Artikel Edukasi',
                  style: AppTextStyles.headlineMd.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  article.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodyMd.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerLow,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.outlineVariant.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.link_rounded, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          mockUrl,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMd.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Tautan artikel berhasil disalin'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        child: const Text('Salin'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  // Build
  // ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final articleAsync = ref.watch(educationDetailProvider(widget.articleId));

    return articleAsync.when(
      loading:
          () => Scaffold(
            backgroundColor: AppColors.surface,
            appBar: AppBar(
              backgroundColor: AppColors.surface,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.primary,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
                'Detail Edukasi',
                style: AppTextStyles.headlineMd.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: const EducationDetailSkeleton(),
          ),
      error:
          (e, _) => Scaffold(
            backgroundColor: AppColors.surface,
            appBar: AppBar(
              backgroundColor: AppColors.surface,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppColors.primary,
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
                'Detail Edukasi',
                style: AppTextStyles.headlineMd.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      size: 56,
                      color: AppColors.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Gagal memuat artikel',
                      style: AppTextStyles.headlineMd.copyWith(
                        color: AppColors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Periksa koneksi internet Anda lalu coba lagi.',
                      textAlign: TextAlign.center,
                      style: AppTextStyles.bodyMd.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed:
                          () => ref.invalidate(
                            educationDetailProvider(widget.articleId),
                          ),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            ),
          ),
      data: (article) => _buildContent(article),
    );
  }

  Widget _buildContent(EducationArticle article) {
    final isBookmarked = article.isBookmarked;
    final isCompleted = article.isCompleted || _hasMarkedComplete;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 1,
        shadowColor: AppColors.primaryContainer.withValues(alpha: 0.1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Detail Edukasi',
          style: AppTextStyles.headlineMd.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          // Read-progress indicator badge
          if (isCompleted)
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: Tooltip(
                message: 'Selesai Dibaca',
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Selesai',
                        style: AppTextStyles.labelMd.copyWith(
                          color: AppColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          IconButton(
            icon: Icon(
              isBookmarked
                  ? Icons.bookmark_rounded
                  : Icons.bookmark_border_rounded,
              color:
                  isBookmarked ? AppColors.primary : AppColors.onSurfaceVariant,
            ),
            onPressed: _toggleBookmark,
          ),
          IconButton(
            icon: const Icon(
              Icons.share_rounded,
              color: AppColors.onSurfaceVariant,
            ),
            onPressed: () => _handleShare(article),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Image Section
                SizedBox(
                  width: double.infinity,
                  height: 200,
                  child: AppSmartImage(
                    imageUrl: article.imageUrl,
                    fit: BoxFit.cover,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                    fallbackIcon: Icons.menu_book_rounded,
                  ),
                ),

                // Badges & Metadata Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    AppSpacing.md,
                    AppSpacing.page,
                    0,
                  ),
                  child: ArticleInformation(article: article),
                ),

                // Content Section
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.page),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Main Headline Title
                      Text(
                        article.title,
                        style: AppTextStyles.poppinsHeadline.copyWith(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.35,
                          color: AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Main Content Body (HTML Rendered sequentially in exact DOM order without duplicate headers)
                      for (final contentHtml in article.bodyParagraphs) ...[
                        HtmlWidget(
                          contentHtml,
                          onTapUrl: (url) async {
                            final uri = Uri.parse(url);
                            if (await canLaunchUrl(uri)) {
                              await launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );
                            }
                            return true;
                          },
                          textStyle: AppTextStyles.bodyLg.copyWith(
                            fontSize: 14.5,
                            height: 1.55,
                            color: const Color(0xFF334155),
                          ),
                          customWidgetBuilder: (element) {
                            // 1. YouTube video block (data-youtube-id attribute or YouTube link wrapper)
                            final youtubeId =
                                element.attributes['data-youtube-id'] ??
                                (element.localName == 'a' &&
                                        element.attributes['href'] != null
                                    ? YoutubePlayer.convertUrlToId(
                                      element.attributes['href']!,
                                    )
                                    : null);
                            if (youtubeId != null && youtubeId.isNotEmpty) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: YouTubePreviewCard(
                                  videoTitle: article.title,
                                  videoDuration: 'Video Edukasi',
                                  channelName:
                                      article.channelName ?? 'DSMES Official',
                                  imageUrl: article.imageUrl,
                                  videoUrl:
                                      'https://www.youtube.com/watch?v=$youtubeId',
                                  isWatched:
                                      article.isYoutubeWatched ||
                                      article.isCompleted,
                                  onWatchProgress: _onVideoProgressUpdated,
                                  onVideoEnded: _onVideoEnded,
                                ),
                              );
                            }

                            // 2. Embedded Content Images (<img src="...">)
                            if (element.localName == 'img' &&
                                element.attributes['src'] != null) {
                              final src = element.attributes['src']!;
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: AppSmartImage(
                                    imageUrl: src,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            }

                            // 3. Info Penting Block (bg-teal-50 / blockquote / border-l-4)
                            if (element.classes.contains('bg-teal-50') ||
                                element.localName == 'blockquote') {
                              return Container(
                                width: double.infinity,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0F9F8), // Teal 50
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(10),
                                    bottomRight: Radius.circular(10),
                                  ),
                                  border: const Border(
                                    left: BorderSide(
                                      color: AppColors.primary, // #00695C
                                      width: 4,
                                    ),
                                  ),
                                ),
                                child: HtmlWidget(
                                  element.innerHtml,
                                  textStyle: AppTextStyles.bodyLg.copyWith(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primary,
                                    height: 1.45,
                                  ),
                                ),
                              );
                            }

                            return null;
                          },
                          customStylesBuilder: (element) {
                            if (element.localName == 'h1') {
                              return {
                                'color': '#1E293B',
                                'font-weight': 'bold',
                                'font-size': '18px',
                                'margin-top': '14px',
                                'margin-bottom': '6px',
                              };
                            }
                            if (element.localName == 'h2') {
                              return {
                                'color': '#1E293B',
                                'font-weight': 'bold',
                                'font-size': '17px',
                                'margin-top': '12px',
                                'margin-bottom': '6px',
                              };
                            }
                            if (element.localName == 'h3') {
                              return {
                                'color': '#1E293B',
                                'font-weight': 'bold',
                                'font-size': '16px',
                                'margin-top': '10px',
                                'margin-bottom': '4px',
                              };
                            }
                            if (element.localName == 'h4') {
                              return {
                                'color': '#1E293B',
                                'font-weight': 'bold',
                                'font-size': '15px',
                                'margin-top': '8px',
                                'margin-bottom': '4px',
                              };
                            }
                            if (element.localName == 'p') {
                              return {
                                'color': '#4A5568',
                                'line-height': '1.55',
                                'margin-bottom': '8px',
                              };
                            }
                            if (element.localName == 'ol' ||
                                element.localName == 'ul') {
                              return {
                                'color': '#4A5568',
                                'padding-left': '18px',
                                'margin-bottom': '8px',
                              };
                            }
                            if (element.localName == 'li') {
                              return {'margin-bottom': '4px'};
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Sticky Bottom Footer Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.page),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.95),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isCompleted
                                ? AppColors.secondary
                                : AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: isCompleted ? null : _markComplete,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isCompleted
                                ? Icons.check_circle_rounded
                                : Icons.check_circle_outline_rounded,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            isCompleted
                                ? 'Sudah Membaca Artikel ✓'
                                : 'Tandai Sudah Membaca Artikel',
                            style: AppTextStyles.poppinsButton.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '© 2026 DSMES Aceh',
                    style: AppTextStyles.bodyMd.copyWith(
                      fontSize: 11,
                      color: AppColors.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
