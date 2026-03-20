import 'dart:convert';
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:uuid/uuid.dart';
import '../../core/utils/logger.dart';
import '../../services/database/daos/conversation_dao.dart';
import '../../services/database/daos/profile_dao.dart';

/// Extracts founder profile traits by analyzing conversation patterns.
/// Runs after every 5 conversations to update the profile.
class ProfileLearner {
  final ConversationDao _conversationDao;
  final ProfileDao _profileDao;
  final AnthropicClient _client;
  int _conversationsSinceLastAnalysis = 0;

  static const _analysisThreshold = 5;

  ProfileLearner({
    required ConversationDao conversationDao,
    required ProfileDao profileDao,
    required String apiKey,
  })  : _conversationDao = conversationDao,
        _profileDao = profileDao,
        _client = AnthropicClient(
          config: AnthropicConfig(
            authProvider: ApiKeyProvider(apiKey),
          ),
        );

  /// Called after each conversation completes. Triggers analysis every N conversations.
  Future<void> onConversationComplete() async {
    _conversationsSinceLastAnalysis++;
    if (_conversationsSinceLastAnalysis < _analysisThreshold) return;
    _conversationsSinceLastAnalysis = 0;
    await analyzeAndUpdateProfile();
  }

  /// Analyzes recent conversations to extract/update profile traits.
  Future<void> analyzeAndUpdateProfile() async {
    try {
      // Get recent conversations for analysis
      final conversations = await _conversationDao.getAllConversations();
      if (conversations.isEmpty) return;

      // Get recent messages from last 5 conversations
      final recentConvIds =
          conversations.take(5).map((c) => c.id as String).toList();
      final allMessages = <String>[];
      for (final convId in recentConvIds) {
        final messages =
            await _conversationDao.getMessagesForConversation(convId);
        for (final m in messages) {
          allMessages.add('[${m.role}]: ${m.content}');
        }
      }

      if (allMessages.isEmpty) return;

      // Summarize for analysis (limit to prevent huge prompts)
      final conversationSummary = allMessages.take(50).join('\n');

      final response = await _client.messages.create(
        MessageCreateRequest(
          model: 'claude-sonnet-4-20250514',
          maxTokens: 1024,
          system: SystemPrompt.text(
            'You are analyzing conversation patterns to build a founder profile. '
            'Extract traits about the user\'s communication style, decision patterns, and preferences. '
            'Return a JSON array of objects with: category (one of: style, preference, pattern), '
            'trait_key (short identifier), trait_value (description), confidence (0.0-1.0). '
            'Only return the JSON array, nothing else.',
          ),
          messages: [
            InputMessage.user(
              'Analyze these recent conversations and extract profile traits:\n\n$conversationSummary',
            ),
          ],
        ),
      );

      // Parse the response
      final content = response.content.first;
      if (content is! TextBlock) return;

      final traits = jsonDecode(content.text) as List<dynamic>;

      for (final trait in traits) {
        final map = trait as Map<String, dynamic>;
        await _profileDao.upsertTrait(
          id: const Uuid().v4(),
          category: map['category'] as String,
          traitKey: map['trait_key'] as String,
          traitValue: map['trait_value'] as String,
          confidence: (map['confidence'] as num).toDouble(),
        );
      }

      log.i('Profile updated: ${traits.length} traits extracted');
    } catch (e) {
      log.e('Profile analysis failed: $e');
    }
  }

  /// Generates a natural language summary of the founder profile.
  Future<String> generateProfileSummary() async {
    try {
      final traits = await _profileDao.getAllTraits();
      if (traits.isEmpty) {
        return "I'm still getting to know you. After a few more conversations, I'll have a clearer picture of how you work.";
      }

      final traitText = traits
          .map((t) =>
              '- ${t.category}/${t.traitKey}: ${t.traitValue} (confidence: ${t.confidence})')
          .join('\n');

      final response = await _client.messages.create(
        MessageCreateRequest(
          model: 'claude-sonnet-4-20250514',
          maxTokens: 512,
          system: SystemPrompt.text(
            'Write a brief, warm, first-person summary of what you know about the user based on these traits. '
            'Speak as SOUL addressing the user directly. Keep it to 2-3 short paragraphs. '
            'Be specific about observed patterns, not generic.',
          ),
          messages: [
            InputMessage.user(
                'Here are the traits I\'ve observed:\n\n$traitText'),
          ],
        ),
      );

      final content = response.content.first;
      if (content is TextBlock) return content.text;
      return "I'm still getting to know you. After a few more conversations, I'll have a clearer picture of how you work.";
    } catch (e) {
      log.e('Profile summary generation failed: $e');
      return "I'm still getting to know you. After a few more conversations, I'll have a clearer picture of how you work.";
    }
  }

  void close() {
    _client.close();
  }
}
