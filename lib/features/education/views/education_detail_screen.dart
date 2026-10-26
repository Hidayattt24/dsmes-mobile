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
import '../widgets/education_review_dialog.dart';
import '../widgets/education_skeleton.dart';
import '../widgets/youtube_mini_player.dart';
import '../widgets/youtube_preview_card.dart';
import '../../questionnaire/models/questionnaire_detail_model.dart';
import '../../questionnaire/viewmodels/questionnaire_notifier.dart';
import '../../questionnaire/views/questionnaire_questions_screen.dart';

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
  // Cached Notifier Reference (Safe for lifecycle/deactivate)
  // ──────────────────────────────────────────────────────────────
  EducationDetailNotifier? _cachedNotifier;

  // ──────────────────────────────────────────────────────────────
  // Read-progress tracking state
  // ──────────────────────────────────────────────────────────────
  DateTime? _readStartTime;
  int _lastReportedScrollPct = 0;
  bool _hasMarkedComplete = false;
  bool _hasScrolledToBottom = false;
  bool _hasCheckedPreTest = false;

  // ──────────────────────────────────────────────────────────────
  // YouTube shared controller & mini-player state
  // ──────────────────────────────────────────────────────────────

  /// Shared [YoutubePlayerController] lifted from [YouTubePreviewCard].
  /// Null until the card calls [_onVideoControllerReady].
  YoutubePlayerController? _sharedVideoController;

  /// Title of the currently loaded video (for mini player label).
  String _videoTitle = 'Video Edukasi';

  /// Whether the mini player is currently visible.
  bool _showMiniPlayer = false;

  /// GlobalKey on the [YouTubePreviewCard] container so we can calculate
  /// when the video widget scrolls out of view.
  final GlobalKey _videoCardKey = GlobalKey();

  /// Cached bottom-Y of the video card widget (in scroll coordinates).
  /// Updated lazily on first scroll event after controller is ready.
  double? _videoCardBottomOffset;

  // ──────────────────────────────────────────────────────────────
  // Overlay entry for the floating mini player
  // ──────────────────────────────────────────────────────────────
  OverlayEntry? _miniPlayerOverlay;

  @override
  void initState() {
    super.initState();
    _readStartTime = DateTime.now();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndPromptPreTest();
    });
  }

  Future<void> _checkAndPromptPreTest() async {
    if (_hasCheckedPreTest) return;
    _hasCheckedPreTest = true;

    try {
      final preTest = await ref.read(
        preTestByEducationProvider(widget.articleId).future,
      );
      if (!mounted || preTest == null) return;
      if (preTest.hasAttempted) return;

      final hasQuestions = preTest.categories.any(
        (c) => c.questions.isNotEmpty,
      );
      if (!hasQuestions) return;

      final startPreTest = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder:
            (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.psychology_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Pre-Test Edukasi',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              content: Text(
                'Sebelum membaca materi ini, ukur tingkat pemahaman awal Anda melalui Pre-Test singkat: "${preTest.title}".',
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              actions: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onPressed: () => Navigator.of(ctx).pop(true),
                  child: const Text(
                    'Mulai Pre-Test',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
      );

      if (startPreTest == true && mounted) {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (_) => QuestionnaireQuestionsScreen(
                  questionnaire: preTest,
                  isPreTest: true,
                  returnToEducationId: widget.articleId,
                ),
          ),
        );
      }
    } catch (_) {}
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _cachedNotifier = ref.read(
      educationDetailProvider(widget.articleId).notifier,
    );
  }

  @override
  void deactivate() {
    _flushReadProgress();
    super.deactivate();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _removeMiniPlayerOverlay();
    // Dispose the shared controller here since we own it after it was
    // transferred from YouTubePreviewCard via onControllerReady.
    _sharedVideoController?.dispose();
    super.dispose();
  }

  // ──────────────────────────────────────────────────────────────
  // YouTube shared controller callback
  // ──────────────────────────────────────────────────────────────

  void _onVideoControllerReady(YoutubePlayerController ctrl) {
    if (_sharedVideoController == ctrl) return;
    _sharedVideoController?.dispose();
    setState(() => _sharedVideoController = ctrl);
  }

  // ──────────────────────────────────────────────────────────────
  // Mini player overlay management
  // ──────────────────────────────────────────────────────────────

  void _showMiniPlayerOverlay(String title) {
    if (_sharedVideoController == null) return;
    _removeMiniPlayerOverlay();

    _miniPlayerOverlay = OverlayEntry(
      builder:
          (ctx) => Positioned(
            right: 16,
            bottom: 100, // sits above the bottom "Tandai Selesai" bar
            child: YouTubeMiniPlayer(
              controller: _sharedVideoController!,
              videoTitle: title,
              onExpand: _expandMiniPlayer,
              onClose: _closeMiniPlayer,
            ),
          ),
    );

    Overlay.of(context).insert(_miniPlayerOverlay!);
    setState(() => _showMiniPlayer = true);
  }

  void _removeMiniPlayerOverlay() {
    _miniPlayerOverlay?.remove();
    _miniPlayerOverlay = null;
  }

  void _closeMiniPlayer() {
    _sharedVideoController?.pause();
    _removeMiniPlayerOverlay();
    if (mounted) setState(() => _showMiniPlayer = false);
  }

  void _expandMiniPlayer() {
    _removeMiniPlayerOverlay();
    if (mounted) setState(() => _showMiniPlayer = false);

    // Scroll back to video position
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_videoCardBottomOffset != null && _scrollController.hasClients) {
        _scrollController.animateTo(
          (_videoCardBottomOffset! - 400).clamp(0.0, double.infinity),
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _onMinimizeVideo() {
    final title = _videoTitle;
    _showMiniPlayerOverlay(title);
  }

  // ──────────────────────────────────────────────────────────────
  // Scroll tracking
  // ──────────────────────────────────────────────────────────────

  void _onScroll() {
    if (!mounted) return;
    final pos = _scrollController.position;

    // ── Article read-progress ──────────────────────────────────
    if (pos.maxScrollExtent <= 0) {
      if (!_hasScrolledToBottom) {
        setState(() => _hasScrolledToBottom = true);
      }
      return;
    }

    final pct = ((pos.pixels / pos.maxScrollExtent) * 100).round().clamp(
      0,
      100,
    );

    if (pct - _lastReportedScrollPct >= 10) {
      _lastReportedScrollPct = pct;
      _flushReadProgress(scrollPct: pct);
    }

    if (!_hasScrolledToBottom && pos.pixels >= pos.maxScrollExtent - 1) {
      setState(() => _hasScrolledToBottom = true);
    }

    // ── Mini player visibility ─────────────────────────────────
    _updateMiniPlayerVisibility(pos.pixels);
  }

  /// Shows mini player when video card is scrolled out of view upward.
  void _updateMiniPlayerVisibility(double scrollPixels) {
    if (_sharedVideoController == null) return;

    // Lazily compute the video card's bottom offset
    _videoCardBottomOffset ??= _computeVideoCardBottom();
    final cardBottom = _videoCardBottomOffset;
    if (cardBottom == null) return;

    final videoIsOutOfView = scrollPixels > cardBottom;

    if (videoIsOutOfView && !_showMiniPlayer) {
      _showMiniPlayerOverlay(_videoTitle);
    } else if (!videoIsOutOfView && _showMiniPlayer) {
      _removeMiniPlayerOverlay();
      if (mounted) setState(() => _showMiniPlayer = false);
    }
  }

  /// Computes how many pixels from the top of the scroll content the bottom
  /// edge of the video card widget is located.
  double? _computeVideoCardBottom() {
    final ro = _videoCardKey.currentContext?.findRenderObject();
    if (ro == null || ro is! RenderBox || !ro.hasSize) return null;
    // Convert widget's local top to scroll coordinate
    final scrollRo =
        _scrollController.position.context.storageContext.findRenderObject();
    if (scrollRo == null || scrollRo is! RenderBox) return null;
    final localOffset = ro.localToGlobal(Offset.zero, ancestor: scrollRo);
    return localOffset.dy + ro.size.height;
  }

  void _flushReadProgress({int? scrollPct}) {
    if (_readStartTime == null) return;
    final duration = DateTime.now().difference(_readStartTime!).inSeconds;
    final pct = scrollPct ?? _lastReportedScrollPct;

    if (mounted) {
      ref
          .read(educationDetailProvider(widget.articleId).notifier)
          .reportReadProgress(duration: duration, scrollPercentage: pct);
    } else {
      _cachedNotifier?.reportReadProgress(
        duration: duration,
        scrollPercentage: pct,
      );
    }
  }

  // ──────────────────────────────────────────────────────────────
  // Video watch tracking callbacks (passed to YouTubePreviewCard)
  // ──────────────────────────────────────────────────────────────
  void _onVideoEnded() {
    if (!mounted) return;
    ref
        .read(educationDetailProvider(widget.articleId).notifier)
        .markVideoWatched();
  }

  Future<void> _markComplete() async {
    // 1. Tandai artikel selesai dibaca
    try {
      await ref
          .read(educationDetailProvider(widget.articleId).notifier)
          .markArticleRead();

      if (mounted) {
        setState(() {
          _hasMarkedComplete = true;
        });
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
      return;
    }

    if (!mounted) return;

    // 2. Tampilkan dialog ulasan
    final article = ref.read(educationDetailProvider(widget.articleId)).value;
    final articleTitle = article?.title ?? 'Artikel Edukasi';

    final result = await EducationReviewDialog.show(
      context,
      articleTitle: articleTitle,
    );

    if (!mounted) return;

    // 3. Simpan ulasan jika diisi, atau tampilkan konfirmasi selesai
    if (result != null) {
      final rating = result['rating'] as int? ?? 5;
      final note = result['note'] as String? ?? '';

      try {
        await ref
            .read(educationDetailProvider(widget.articleId).notifier)
            .submitReview(rating: rating, note: note);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Ulasan berhasil dikirim! Terima kasih atas masukan Anda. 🎉',
              ),
              backgroundColor: AppColors.primaryContainer,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } catch (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal mengirim ulasan. Silakan coba lagi.'),
              duration: Duration(seconds: 2),
            ),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Artikel edukasi berhasil ditandai selesai! 🎉'),
          backgroundColor: AppColors.primaryContainer,
          duration: Duration(seconds: 2),
        ),
      );
    }

    // 4. Setelah ulasan selesai, tawarkan post-test jika tersedia
    if (!mounted) return;
    try {
      final postTest = await ref.read(
        postTestByEducationProvider(widget.articleId).future,
      );
      if (mounted && postTest != null) {
        final proceedToPostTest = await showDialog<bool>(
          context: context,
          builder:
              (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.workspace_premium_rounded,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Lanjut ke Post-Test?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                content: Text(
                  'Anda telah menyelesaikan materi dan ulasan. Uji pemahaman Anda dengan mengerjakan Post-Test: "${postTest.title}".',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(false),
                    child: const Text(
                      'Lewati',
                      style: TextStyle(
                        color: AppColors.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () => Navigator.of(ctx).pop(true),
                    child: const Text(
                      'Lanjutkan',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
        );

        if (proceedToPostTest == true && mounted) {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder:
                  (_) => QuestionnaireQuestionsScreen(
                    questionnaire: postTest,
                    isPreTest: false,
                  ),
            ),
          );
        }
      }
    } catch (_) {}
  }

  // ──────────────────────────────────────────────────────────────
  // Bookmark toggle
  // ──────────────────────────────────────────────────────────────
  Future<void> _toggleBookmark() async {
    try {
      await ref
          .read(educationDetailProvider(widget.articleId).notifier)
          .toggleBookmark();
      if (!mounted) return;
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
  // Share
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
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Tautan artikel berhasil disalin',
                                ),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
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
                      Icons.cloud_off_rounded,
                      size: 56,
                      color: AppColors.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Artikel Belum Tersedia Offline',
                      style: AppTextStyles.headlineMd.copyWith(
                        color: AppColors.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Konten lengkap artikel ini belum sempat diunduh ke perangkat. Hubungkan ke internet untuk memuatnya.',
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
    final canMarkRead = !isCompleted && _hasScrolledToBottom;
    final buttonContentColor =
        (canMarkRead || isCompleted)
            ? Colors.white
            : AppColors.onSurfaceVariant;

    // Cache video title for mini player label
    _videoTitle = article.title;

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
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // ── Main scrollable content ──────────────────────────────────
          SingleChildScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Hero image ───────────────────────────────────────
                SizedBox(
                  width: double.infinity,
                  height: 180,
                  child:
                      article.imageUrl.trim().isEmpty
                          ? Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.primaryContainer.withValues(
                                    alpha: 0.35,
                                  ),
                                  AppColors.primary.withValues(alpha: 0.12),
                                  AppColors.surfaceContainerLowest,
                                ],
                              ),
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                            ),
                            child: Center(
                              child: Container(
                                width: 64,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary.withValues(
                                        alpha: 0.1,
                                      ),
                                      blurRadius: 16,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.menu_book_rounded,
                                  size: 32,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          )
                          : AppSmartImage(
                            imageUrl: article.imageUrl,
                            fit: BoxFit.cover,
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(16),
                              bottomRight: Radius.circular(16),
                            ),
                            fallbackIcon: Icons.menu_book_rounded,
                          ),
                ),

                // ── Article info ─────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.page,
                    AppSpacing.md,
                    AppSpacing.page,
                    0,
                  ),
                  child: ArticleInformation(article: article),
                ),

                // ── Body content ─────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.page),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        header: true,
                        child: Text(
                          article.title,
                          style: AppTextStyles.poppinsHeadline.copyWith(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            height: 1.35,
                            color: AppColors.onSurface,
                          ),
                        ),
                      ),
                      if (article.quoteText.trim().isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerLow,
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                            ),
                            border: const Border(
                              left: BorderSide(
                                color: AppColors.primary,
                                width: 4,
                              ),
                            ),
                          ),
                          child: Text(
                            article.quoteText.trim(),
                            style: AppTextStyles.bodyLg.copyWith(
                              color: AppColors.onSurface,
                              fontStyle: FontStyle.italic,
                              height: 1.55,
                            ),
                          ),
                        ),
                      ],
                      if (article.youtubeVideoId != null &&
                          !article.bodyParagraphs.any(
                            (paragraph) =>
                                paragraph.contains('youtube.com') ||
                                paragraph.contains('youtu.be') ||
                                paragraph.contains('data-youtube-id'),
                          )) ...[
                        const SizedBox(height: 20),
                        KeyedSubtree(
                          key: _videoCardKey,
                          child: YouTubePreviewCard(
                            videoTitle: article.title,
                            videoDuration:
                                article.videoDuration ?? 'Video Edukasi',
                            channelName: article.channelName ?? 'DIBA Official',
                            imageUrl: article.imageUrl,
                            videoUrl: article.videoUrl,
                            isWatched:
                                article.isYoutubeWatched || article.isCompleted,
                            onVideoEnded: _onVideoEnded,
                            onControllerReady: _onVideoControllerReady,
                            onMinimize: _onMinimizeVideo,
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
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
                            // ── YouTube embed ───────────────────────
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
                                // GlobalKey so we can measure position for
                                // mini-player trigger
                                child: KeyedSubtree(
                                  key: _videoCardKey,
                                  child: YouTubePreviewCard(
                                    videoTitle: article.title,
                                    videoDuration: 'Video Edukasi',
                                    channelName:
                                        article.channelName ?? 'DIBA Official',
                                    imageUrl: article.imageUrl,
                                    videoUrl:
                                        'https://www.youtube.com/watch?v=$youtubeId',
                                    isWatched:
                                        article.isYoutubeWatched ||
                                        article.isCompleted,
                                    onVideoEnded: _onVideoEnded,
                                    onControllerReady: _onVideoControllerReady,
                                    onMinimize: _onMinimizeVideo,
                                  ),
                                ),
                              );
                            }

                            // ── Inline image ────────────────────────
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

                            // ── Blockquote / teal box ───────────────
                            if (element.classes.contains('bg-teal-50') ||
                                element.localName == 'blockquote') {
                              return Container(
                                width: double.infinity,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF0F9F8),
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(10),
                                    bottomRight: Radius.circular(10),
                                  ),
                                  border: const Border(
                                    left: BorderSide(
                                      color: AppColors.primary,
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

          // ── Bottom "Tandai Selesai" bar ──────────────────────────────
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
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor:
                            isCompleted
                                ? AppColors.secondary
                                : AppColors.outlineVariant,
                        foregroundColor: Colors.white,
                        disabledForegroundColor:
                            isCompleted
                                ? Colors.white
                                : AppColors.onSurfaceVariant,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: canMarkRead ? _markComplete : null,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isCompleted
                                ? Icons.check_circle_rounded
                                : canMarkRead
                                ? Icons.check_circle_outline_rounded
                                : Icons.lock_outline_rounded,
                            size: 20,
                            color: buttonContentColor,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              isCompleted
                                  ? 'Sudah Membaca Artikel ✓'
                                  : 'Tandai Sudah Membaca Artikel',
                              textAlign: TextAlign.center,
                              softWrap: true,
                              style: AppTextStyles.poppinsButton.copyWith(
                                color: buttonContentColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!isCompleted && !_hasScrolledToBottom) ...[
                    const SizedBox(height: 6),
                    Text(
                      'Gulir artikel sampai bawah untuk mengaktifkan tombol.',
                      style: AppTextStyles.bodyMd.copyWith(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Text(
                    '© 2026 DIBA',
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
