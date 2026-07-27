import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/chat_message.dart';
import '../models/chat_session.dart';

class AiChatState {
  final List<ChatSession> sessions;
  final String? activeSessionId;
  final bool isLoading;
  final List<String> quickSuggestions;

  const AiChatState({
    this.sessions = const [],
    this.activeSessionId,
    this.isLoading = false,
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
      return sessions.first;
    }
  }

  List<ChatMessage> get messages => activeSession?.messages ?? const [];

  AiChatState copyWith({
    List<ChatSession>? sessions,
    String? activeSessionId,
    bool? isLoading,
    List<String>? quickSuggestions,
  }) {
    return AiChatState(
      sessions: sessions ?? this.sessions,
      activeSessionId: activeSessionId ?? this.activeSessionId,
      isLoading: isLoading ?? this.isLoading,
      quickSuggestions: quickSuggestions ?? this.quickSuggestions,
    );
  }
}

class AiChatNotifier extends StateNotifier<AiChatState> {
  AiChatNotifier() : super(_initialState());

  static AiChatState _initialState() {
    final now = DateTime.now();
    final mockSessions = [
      ChatSession(
        id: 'sess_1',
        title: 'Edukasi Kadar Gula Darah Puasa',
        createdAt: now.subtract(const Duration(hours: 2)),
        updatedAt: now.subtract(const Duration(hours: 2)),
        messages: [
          ChatMessage(
            id: 'm1_1',
            text: 'Berapa kadar gula darah puasa yang normal?',
            sender: ChatSender.user,
            timestamp: now.subtract(const Duration(hours: 2)),
          ),
          ChatMessage(
            id: 'm1_2',
            text: 'Kadar gula darah puasa yang normal berkisar antara 70-99 mg/dL. Kadar 100-125 mg/dL menandakan pradiabetes, sedangkan 126 mg/dL ke atas dapat mengindikasikan diabetes.',
            sender: ChatSender.assistant,
            timestamp: now.subtract(const Duration(hours: 2, minutes: -1)),
          ),
        ],
      ),
      ChatSession(
        id: 'sess_2',
        title: 'Rekomendasi Karbohidrat Kompleks',
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
        messages: [
          ChatMessage(
            id: 'm2_1',
            text: 'Rekomendasi makanan sehat untuk penderita diabetes',
            sender: ChatSender.user,
            timestamp: now.subtract(const Duration(days: 1)),
          ),
          ChatMessage(
            id: 'm2_2',
            text: 'Pilihlah makanan berbahan karbohidrat kompleks seperti beras merah, oat, ubi jalar, dan sayuran hijau. Hindari makanan manis dan berlemak tinggi.',
            sender: ChatSender.assistant,
            timestamp: now.subtract(const Duration(days: 1, minutes: -1)),
          ),
        ],
      ),
      ChatSession(
        id: 'sess_3',
        title: 'Jadwal Olahraga & Aktivitas Fisik',
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 3)),
        messages: [
          ChatMessage(
            id: 'm3_1',
            text: 'Berapa lama sebaiknya penderita diabetes berolahraga?',
            sender: ChatSender.user,
            timestamp: now.subtract(const Duration(days: 3)),
          ),
          ChatMessage(
            id: 'm3_2',
            text: 'Disarankan melakukan aktivitas fisik intensitas sedang seperti jalan cepat atau jalan santai selama minimal 30 menit sehari atau 150 menit seminggu.',
            sender: ChatSender.assistant,
            timestamp: now.subtract(const Duration(days: 3, minutes: -1)),
          ),
        ],
      ),
    ];

    return AiChatState(
      sessions: mockSessions,
      activeSessionId: mockSessions.first.id,
    );
  }

  void startNewSession() {
    final newId = 'sess_${DateTime.now().millisecondsSinceEpoch}';
    final newSession = ChatSession(
      id: newId,
      title: 'Sesi Percakapan Baru',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      messages: const [],
    );

    state = state.copyWith(
      sessions: [newSession, ...state.sessions],
      activeSessionId: newId,
      isLoading: false,
    );
  }

  void selectSession(String sessionId) {
    if (state.sessions.any((s) => s.id == sessionId)) {
      state = state.copyWith(activeSessionId: sessionId);
    }
  }

  void deleteSession(String sessionId) {
    final updatedSessions = state.sessions.where((s) => s.id != sessionId).toList();
    String? nextActiveId = state.activeSessionId;

    if (state.activeSessionId == sessionId) {
      nextActiveId = updatedSessions.isNotEmpty ? updatedSessions.first.id : null;
    }

    state = state.copyWith(
      sessions: updatedSessions,
      activeSessionId: nextActiveId,
    );

    // If no sessions remain, auto start a fresh session
    if (updatedSessions.isEmpty) {
      startNewSession();
    }
  }

  void clearAllHistory() {
    state = state.copyWith(sessions: [], activeSessionId: null);
    startNewSession();
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty) return;

    // Ensure there is an active session
    var currentSession = state.activeSession;
    if (currentSession == null) {
      startNewSession();
      currentSession = state.activeSession!;
    }

    final userMsg = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text.trim(),
      sender: ChatSender.user,
      timestamp: DateTime.now(),
    );

    // Derive smart session title if this is the first user message in current session
    final isFirstMessage = currentSession.messages.isEmpty;
    final updatedTitle = isFirstMessage
        ? (text.trim().length > 30 ? '${text.trim().substring(0, 30)}...' : text.trim())
        : currentSession.title;

    final updatedMessages = [...currentSession.messages, userMsg];
    final updatedSession = currentSession.copyWith(
      title: updatedTitle,
      updatedAt: DateTime.now(),
      messages: updatedMessages,
    );

    final updatedSessions = state.sessions.map((s) {
      return s.id == updatedSession.id ? updatedSession : s;
    }).toList();

    state = state.copyWith(
      sessions: updatedSessions,
      isLoading: true,
    );

    // Simulate AI Assistant response
    Future.delayed(const Duration(milliseconds: 1200), () {
      final aiResponseText = _getPlaceholderResponse(text);
      final aiMsg = ChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        text: aiResponseText,
        sender: ChatSender.assistant,
        timestamp: DateTime.now(),
      );

      final activeSess = state.activeSession;
      if (activeSess != null && activeSess.id == updatedSession.id) {
        final finalMessages = [...activeSess.messages, aiMsg];
        final finalSession = activeSess.copyWith(
          updatedAt: DateTime.now(),
          messages: finalMessages,
        );

        final finalSessions = state.sessions.map((s) {
          return s.id == finalSession.id ? finalSession : s;
        }).toList();

        state = state.copyWith(
          sessions: finalSessions,
          isLoading: false,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    });
  }

  String _getPlaceholderResponse(String userText) {
    final query = userText.toLowerCase();
    if (query.contains('apa itu diabetes') || query.contains('diabetes')) {
      return 'Diabetes Mellitus adalah kondisi kronis di mana kadar gula darah (glukosa) berada di atas nilai normal. Pengelolaan yang tepat meliputi pola makan gizi seimbang, aktivitas fisik rutin, dan pemantauan gula darah berkala melalui aplikasi DSMES.';
    } else if (query.contains('makanan') || query.contains('nutrisi')) {
      return 'Untuk penderita diabetes, pilihlah makanan berbahan karbohidrat kompleks (beras merah, gandum, sayuran) dan hindari makanan manis atau bersantan pekat. Anda dapat mencatat konsumsi harian di fitur Jadwal Makan DSMES.';
    } else if (query.contains('aktivitas') || query.contains('olahraga')) {
      return 'Disarankan melakukan aktivitas fisik teratur minimal 30 menit per hari, seperti berjalan santai, bersepeda, atau senam diabetes. Jangan lupa periksa gula darah sebelum dan sesudah berolahraga.';
    } else if (query.contains('menurunkan') || query.contains('gula darah')) {
      return 'Langkah efektif menurunkan kadar gula darah:\n1. Patuhi konsumsi obat/insulin tepat waktu\n2. Jaga hidrasi dengan minum air putih secukupnya\n3. Kurangi asupan gula dan karbohidrat sederhana\n4. Lakukan pemantauan gula darah secara berkala.';
    } else if (query.contains('obat') || query.contains('minum')) {
      return 'Penggunaan obat diabetes harus sesuai petunjuk dokter. Atur pengingat di fitur Pengingat DSMES agar tidak terlewat minum obat harian Anda.';
    }
    return 'Terima kasih atas pertanyaan Anda! Sebagai Asisten Kesehatan DSMES, saya siap membantu memberikan informasi seputar edukasi diabetes, pola makan, dan pemantauan harian Anda.';
  }
}

final aiChatProvider = StateNotifierProvider<AiChatNotifier, AiChatState>((ref) {
  return AiChatNotifier();
});
