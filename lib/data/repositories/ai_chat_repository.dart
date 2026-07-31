import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/api_exception.dart';
import '../../core/network/dio_client.dart';
import '../../features/ai_chat/models/chat_message.dart';
import '../../features/ai_chat/models/chat_session.dart';

abstract class IAIChatRepository {
  Future<List<ChatSession>> getConversations();
  Future<ChatSession> createConversation(String title);
  Future<List<ChatMessage>> getMessages(String conversationId);
  Future<void> deleteConversation(String conversationId);
  Future<Map<String, dynamic>> sendMessage(String message, {String? conversationId});
}

class AIChatRepository implements IAIChatRepository {
  final Dio _dio;

  AIChatRepository(this._dio);

  @override
  Future<List<ChatSession>> getConversations() async {
    try {
      final response = await _dio.get('/ai/conversations');
      final list = (response.data['data'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();

      return list.map((json) {
        return ChatSession(
          id: json['id'] as String? ?? '',
          title: json['title'] as String? ?? 'Percakapan Baru',
          createdAt: DateTime.tryParse(json['created_at'] as String? ?? '')?.toLocal() ?? DateTime.now(),
          updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '')?.toLocal() ?? DateTime.now(),
          messages: const [],
        );
      }).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<ChatSession> createConversation(String title) async {
    try {
      final response = await _dio.post(
        '/ai/conversations',
        data: {'title': title},
      );
      final json = response.data['data'] as Map<String, dynamic>;
      return ChatSession(
        id: json['id'] as String? ?? '',
        title: json['title'] as String? ?? title,
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? '')?.toLocal() ?? DateTime.now(),
        updatedAt: DateTime.tryParse(json['updated_at'] as String? ?? '')?.toLocal() ?? DateTime.now(),
        messages: const [],
      );
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<List<ChatMessage>> getMessages(String conversationId) async {
    try {
      final response = await _dio.get('/ai/conversations/$conversationId/messages');
      final list = (response.data['data'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>();

      return list.map((json) {
        final role = json['role'] as String? ?? 'user';
        return ChatMessage(
          id: json['id'] as String? ?? '',
          text: json['message'] as String? ?? '',
          sender: role == 'assistant' ? ChatSender.assistant : ChatSender.user,
          timestamp: DateTime.tryParse(json['created_at'] as String? ?? '')?.toLocal() ?? DateTime.now(),
        );
      }).toList();
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<void> deleteConversation(String conversationId) async {
    try {
      await _dio.delete('/ai/conversations/$conversationId');
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }

  @override
  Future<Map<String, dynamic>> sendMessage(String message, {String? conversationId}) async {
    try {
      final payload = <String, dynamic>{'message': message};
      if (conversationId != null && conversationId.isNotEmpty) {
        payload['conversation_id'] = conversationId;
      }
      final response = await _dio.post(
        '/ai/chat',
        data: payload,
        options: Options(
          receiveTimeout: const Duration(seconds: 60),
          sendTimeout: const Duration(seconds: 60),
        ),
      );
      return response.data['data'] as Map<String, dynamic>? ?? {};
    } on DioException catch (e) {
      throw ApiException.fromDioException(e);
    }
  }
}

final aiChatRepositoryProvider = Provider<IAIChatRepository>((ref) {
  final dio = ref.watch(dioClientProvider);
  return AIChatRepository(dio);
});
