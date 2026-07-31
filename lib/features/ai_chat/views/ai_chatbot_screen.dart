import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../models/chat_message.dart';
import '../viewmodels/ai_chat_notifier.dart';

import '../widgets/chat_history_sheet.dart';

class AiChatbotScreen extends ConsumerStatefulWidget {
  const AiChatbotScreen({super.key});

  @override
  ConsumerState<AiChatbotScreen> createState() => _AiChatbotScreenState();
}

class _AiChatbotScreenState extends ConsumerState<AiChatbotScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isComposing = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _isComposing = _textController.text.trim().isNotEmpty;
    });
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;
    _textController.clear();
    ref.read(aiChatProvider.notifier).sendMessage(text);
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(aiChatProvider);
    final messages = chatState.messages;
    final activeSession = chatState.activeSession;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceContainerLowest,
        elevation: 0,
        scrolledUnderElevation: 2,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          color: AppColors.onSurface,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Hero(
              tag: 'ai-assistant-avatar',
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, Color(0xFF0D9488)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.medical_services_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Asisten DSMES',
                    style: AppTextStyles.headlineMd.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF22C55E),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          activeSession?.title ?? 'Online • AI Kesehatan',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodyMd.copyWith(
                            fontSize: 11,
                            color: AppColors.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded),
            color: AppColors.primary,
            tooltip: 'Sesi Percakapan Baru',
            onPressed: () {
              ref.read(aiChatProvider.notifier).startNewSession();
            },
          ),
          IconButton(
            icon: const Icon(Icons.history_rounded),
            color: AppColors.onSurfaceVariant,
            tooltip: 'Riwayat Percakapan',
            onPressed: () {
              showChatHistorySheet(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? _buildEmptyState(chatState.quickSuggestions)
                : _buildMessageList(messages, chatState.isLoading),
          ),
          _buildInputBar(),
        ],
      ),
    );
  }

  Widget _buildEmptyState(List<String> suggestions) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.page),
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.md),
          // Avatar Icon Large
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryContainer,
                  AppColors.secondaryContainer,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.medical_services_rounded,
              size: 36,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Welcome Card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.outlineVariant.withValues(alpha: 0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Selamat Datang 👋',
                      style: AppTextStyles.headlineLg.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Saya adalah Asisten Kesehatan DSMES.\nSaya siap membantu menjawab pertanyaan seputar diabetes, nutrisi, aktivitas fisik, serta penggunaan aplikasi DSMES.',
                  style: AppTextStyles.bodyMd.copyWith(
                    fontSize: 13,
                    color: AppColors.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Quick Action Suggestions Header
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Pertanyaan Populer',
              style: AppTextStyles.headlineMd.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.onSurface,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Quick Action Pills
          Wrap(
            spacing: 8,
            runSpacing: 10,
            children: suggestions.map((suggestion) {
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _handleSubmitted(suggestion),
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: AppColors.primaryContainer.withValues(alpha: 0.8),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.lightbulb_outline_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            suggestion,
                            style: AppTextStyles.labelMd.copyWith(
                              fontSize: 13,
                              color: AppColors.onSurface,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(List<ChatMessage> messages, bool isLoading) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppSpacing.page),
      itemCount: messages.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length && isLoading) {
          return _buildLoadingBubble();
        }
        final msg = messages[index];
        return _buildChatBubble(msg);
      },
    );
  }

  Widget _buildChatBubble(ChatMessage msg) {
    final isUser = msg.isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.primary, Color(0xFF0D9488)],
                ),
              ),
              child: const Icon(
                Icons.medical_services_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: isUser
                    ? AppColors.primary
                    : AppColors.surfaceContainerLowest,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                border: isUser
                    ? null
                    : Border.all(
                        color: AppColors.outlineVariant.withValues(alpha: 0.5),
                      ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                msg.text,
                style: AppTextStyles.bodyMd.copyWith(
                  fontSize: 14,
                  color: isUser ? Colors.white : AppColors.onSurface,
                  height: 1.4,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildLoadingBubble() {
    return const _AnimatedThinkingBubble();
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.page,
        12,
        AppSpacing.page,
        MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppColors.outlineVariant.withValues(alpha: 0.6),
                  ),
                ),
                child: TextField(
                  controller: _textController,
                  onSubmitted: _handleSubmitted,
                  textInputAction: TextInputAction.send,
                  decoration: const InputDecoration(
                    hintText: 'Tulis pertanyaan Anda...',
                    hintStyle: TextStyle(
                      fontSize: 14,
                      color: AppColors.onSurfaceVariant,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: _isComposing
                    ? AppColors.primary
                    : AppColors.outlineVariant.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded, size: 20),
                color: _isComposing ? Colors.white : AppColors.onSurfaceVariant,
                onPressed: _isComposing
                    ? () => _handleSubmitted(_textController.text)
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedThinkingBubble extends StatefulWidget {
  const _AnimatedThinkingBubble();

  @override
  State<_AnimatedThinkingBubble> createState() => _AnimatedThinkingBubbleState();
}

class _AnimatedThinkingBubbleState extends State<_AnimatedThinkingBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;
  Timer? _textTimer;

  int _textIndex = 0;
  final List<String> _thinkingTexts = [
    'Sedang menganalisis data kesehatan Anda...',
    'Mempersiapkan edukasi diabetes terbaik...',
    'Menyusun rekomendasi personal untuk Anda...',
    'Menghubungkan ke konsultan AI DSMES...',
    'Hampir selesai, merapikan jawaban...',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _glowAnimation = Tween<double>(begin: 0.2, end: 0.6).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _textTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (mounted) {
        setState(() {
          _textIndex = (_textIndex + 1) % _thinkingTexts.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _textTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Glowing Pulsing Avatar
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, Color(0xFF0D9488)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary
                            .withValues(alpha: _glowAnimation.value),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.psychology_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              );
            },
          ),
          const SizedBox(width: 10),

          // Animated Thinking Card Bubble
          Flexible(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerLowest,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                  bottomLeft: Radius.circular(4),
                ),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.auto_awesome_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: 6),
                      const _BouncingDotsIndicator(),
                      const SizedBox(width: 8),
                      Text(
                        'Berpikir',
                        style: AppTextStyles.labelMd.copyWith(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0.0, 0.2),
                            end: Offset.zero,
                          ).animate(animation),
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      _thinkingTexts[_textIndex],
                      key: ValueKey<int>(_textIndex),
                      style: AppTextStyles.bodyMd.copyWith(
                        fontSize: 12,
                        color: AppColors.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                        height: 1.3,
                      ),
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

class _BouncingDotsIndicator extends StatefulWidget {
  const _BouncingDotsIndicator();

  @override
  State<_BouncingDotsIndicator> createState() => _BouncingDotsIndicatorState();
}

class _BouncingDotsIndicatorState extends State<_BouncingDotsIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final double delay = index * 0.2;
            final double value = (_controller.value - delay) % 1.0;
            final double translateY =
                (value < 0.5) ? -3.0 * (value * 2) : -3.0 * (1.0 - (value - 0.5) * 2);

            return Transform.translate(
              offset: Offset(0, translateY),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
