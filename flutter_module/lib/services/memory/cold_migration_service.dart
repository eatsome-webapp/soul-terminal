import '../../core/utils/logger.dart';
import '../database/daos/conversation_dao.dart';
import '../database/daos/settings_dao.dart';
import 'embedding_service.dart';
import 'vector_store.dart';

/// Migrates warm (recent) messages to cold storage (ObjectBox vectors).
///
/// Runs in batches to avoid blocking. Messages older than today
/// are embedded and stored in VectorStore for semantic retrieval.
class ColdMigrationService {
  final ConversationDao _conversationDao;
  final SettingsDao _settingsDao;
  final EmbeddingService? _embeddingService;
  final VectorStore? _vectorStore;

  static const int batchSize = 10;

  ColdMigrationService({
    required ConversationDao conversationDao,
    required SettingsDao settingsDao,
    EmbeddingService? embeddingService,
    VectorStore? vectorStore,
  })  : _conversationDao = conversationDao,
        _settingsDao = settingsDao,
        _embeddingService = embeddingService,
        _vectorStore = vectorStore;

  Future<void> migrateWarmToCold() async {
    if (_embeddingService == null || _vectorStore == null) {
      log.d('Skipping cold migration: embedding service not available');
      return;
    }

    try {
      final startOfToday = DateTime.now();
      final todayStart = DateTime(
          startOfToday.year, startOfToday.month, startOfToday.day);
      final cutoffMs = todayStart.millisecondsSinceEpoch;

      final lastMigrated = await _settingsDao
          .getString(SettingsKeys.lastColdMigrationTimestamp);
      final lastMs =
          lastMigrated != null ? int.tryParse(lastMigrated) ?? 0 : 0;

      // Only migrate messages between lastMigrated and today's start
      final messages = await _conversationDao.getMessagesOlderThan(
        cutoffMs,
        limit: batchSize,
      );

      if (messages.isEmpty) {
        log.d('No messages to migrate to cold storage');
        return;
      }

      var migrated = 0;
      for (final message in messages) {
        if (message.createdAt <= lastMs) continue;

        final embedding = await _embeddingService!.embed(message.content);
        if (embedding != null) {
          await _vectorStore!.putEmbedding(
            sourceId: message.id,
            sourceType: 'cold_message',
            embedding: embedding,
            sourceText: message.content.length > 200
                ? '${message.content.substring(0, 200)}...'
                : message.content,
          );
          migrated++;
        }
      }

      // Track last migrated timestamp
      if (messages.isNotEmpty) {
        final latestTimestamp = messages.last.createdAt;
        await _settingsDao.setString(
          SettingsKeys.lastColdMigrationTimestamp,
          latestTimestamp.toString(),
        );
      }

      log.i('Cold migration: $migrated messages embedded');
    } catch (e) {
      log.e('Cold migration failed: $e');
    }
  }
}
