import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repositories/ai_chat_repository.dart';
import '../models/chat_message.dart';
import '../models/chat_session.dart';

class AiChatState {
  final List<ChatSession> sessions;
  final String? activeSessionId;
  final bool isLoading;
  final String? errorMessage;
  final List<String> quickSuggestions;

  const AiChatState({
    this.sessions = const [],
    this.activeSessionId,
    this.isLoading = false,
    this.errorMessage,
    this.quickSuggestions = const [
      'Apa itu Diabetes?',
      'Rekomendasi Makanan',
      'Aktivitas Fisik',
      'Cara Menurunkan Gula Darah',
      'Tips Minum Obat',
    ],
  });

  ChatSession? get activeSession {
    if (activeSessionId == null || sessions.isEmpty) return null;
    try {
      return sessions.firstWhere((s) => s.id == activeSessionId);
    } catch (_) {
      return null;
    }
  }

  List<ChatMessage> get messages => activeSession?.messages ?? const [];

  AiChatState copyWith({
    List<ChatSession>? sessions,
    String? activeSessionId,
    bool clearActiveSessionId = false,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    List<String>? quickSuggestions,
  }) {
    return AiChatState(
      sessions: sessions ?? this.sessions,
      activeSessionId: clearActiveSessionId ? null : (activeSessionId ?? this.activeSessionId),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      quickSuggestions: quickSuggestions ?? this.quickSuggestions,
    );
  }
}

class AiChatNotifier extends StateNotifier<AiChatState> {
  final IAIChatRepository _repository;

  AiChatNotifier(this._repository) : super(const AiChatState()) {
    fetchConversations();
  }

  /// Resets the notifier state, e.g. on user logout / re-login
  void reset() {
    state = const AiChatState();
    fetchConversations();
  }

  Future<void> fetchConversations() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final conversations = await _repository.getConversations();
      // Keep sessions in history, but always default activeSessionId to null
      // so opening chatbot or re-logging in directly goes to a fresh NEW session.
      state = state.copyWith(
        sessions: conversations,
        clearActiveSessionId: true,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> selectSession(String sessionId) async {
    state = state.copyWith(activeSessionId: sessionId, clearError: true);
    try {
      final messages = await _repository.getMessages(sessionId);
      final updatedSessions = state.sessions.map((s) {
        if (s.id == sessionId) {
          return s.copyWith(messages: messages);
        }
        return s;
      }).toList();

      state = state.copyWith(sessions: updatedSessions);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> startNewSession([String title = 'Sesi Percakapan Baru']) async {
    state = state.copyWith(clearActiveSessionId: true, clearError: true);
  }

  Future<void> clearAllHistory() async {
    for (final s in state.sessions) {
      try {
        await _repository.deleteConversation(s.id);
      } catch (_) {}
    }
    state = state.copyWith(sessions: [], clearActiveSessionId: true);
    await startNewSession();
  }

  Future<void> deleteSession(String sessionId) async {
    try {
      await _repository.deleteConversation(sessionId);
    } catch (_) {}

    final updatedSessions = state.sessions.where((s) => s.id != sessionId).toList();
    String? nextActiveId = state.activeSessionId;

    if (state.activeSessionId == sessionId) {
      nextActiveId = updatedSessions.isNotEmpty ? updatedSessions.first.id : null;
    }

    state = state.copyWith(
      sessions: updatedSessions,
      activeSessionId: nextActiveId,
    );

    if (updatedSessions.isEmpty) {
      await startNewSession();
    } else if (nextActiveId != null) {
      await selectSession(nextActiveId);
    }
  }

  Future<void> sendMessage(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty) return;

    var currentSession = state.activeSession;
    final currentSessionId = currentSession?.id;
    final isNewSession = (currentSessionId == null || currentSessionId.isEmpty || currentSessionId.startsWith('temp_sess_'));

    // Generate temporary session ID if in a fresh new session state
    final activeId = isNewSession
        ? (currentSessionId != null && currentSessionId.startsWith('temp_sess_')
            ? currentSessionId
            : 'temp_sess_${DateTime.now().millisecondsSinceEpoch}')
        : currentSessionId;

    // Local optimistic user message append
    final tempUserMsg = ChatMessage(
      id: 'temp_user_${DateTime.now().millisecondsSinceEpoch}',
      text: trimmed,
      sender: ChatSender.user,
      timestamp: DateTime.now(),
    );

    final isFirstMessage = (currentSession?.messages.isEmpty ?? true);
    final updatedTitle = isFirstMessage
        ? (trimmed.length > 30 ? '${trimmed.substring(0, 30)}...' : trimmed)
        : (currentSession?.title ?? 'Percakapan Baru');

    final existingMessages = currentSession?.messages ?? const [];
    final updatedMessages = [...existingMessages, tempUserMsg];

    final updatedSession = (currentSession ??
            ChatSession(
              id: activeId,
              title: updatedTitle,
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              messages: const [],
            ))
        .copyWith(
      id: activeId,
      title: updatedTitle,
      updatedAt: DateTime.now(),
      messages: updatedMessages,
    );

    // If new session, prepend to existing sessions list; otherwise update existing in place
    final containsSession = state.sessions.any((s) => s.id == activeId);
    final updatedSessions = containsSession
        ? state.sessions.map((s) => s.id == activeId ? updatedSession : s).toList()
        : [updatedSession, ...state.sessions];

    state = state.copyWith(
      sessions: updatedSessions,
      activeSessionId: activeId,
      isLoading: true,
      clearError: true,
    );

    try {
      final res = await _repository.sendMessage(
        trimmed,
        conversationId: !isNewSession ? currentSessionId : null,
      );

      final assistantMessageText = res['assistant_message'] as String? ?? 'Terima kasih atas pertanyaan Anda.';
      final returnedConvId = res['conversation_id'] as String? ?? activeId;
      final msgId = res['message_id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString();

      final aiMsg = ChatMessage(
        id: msgId,
        text: assistantMessageText,
        sender: ChatSender.assistant,
        timestamp: DateTime.now(),
      );

      final finalMessages = [...updatedMessages, aiMsg];
      final finalSession = updatedSession.copyWith(
        id: returnedConvId,
        title: updatedTitle,
        updatedAt: DateTime.now(),
        messages: finalMessages,
      );

      final finalSessions = state.sessions.map((s) {
        return (s.id == activeId || s.id == returnedConvId) ? finalSession : s;
      }).toList();

      state = state.copyWith(
        sessions: finalSessions,
        activeSessionId: returnedConvId,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Gagal mendapatkan respon AI: $e',
      );
    }
  }
}

final aiChatProvider = StateNotifierProvider<AiChatNotifier, AiChatState>((ref) {
  final repo = ref.watch(aiChatRepositoryProvider);
  return AiChatNotifier(repo);
});
