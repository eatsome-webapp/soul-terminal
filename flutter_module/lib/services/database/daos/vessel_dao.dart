import 'dart:convert';
import 'package:drift/drift.dart';
import '../soul_database.dart';

part 'vessel_dao.g.dart';

@DriftAccessor(
  include: {
    '../tables/vessel_configs.drift',
    '../tables/vessel_tasks.drift',
    '../tables/vessel_tools.drift',
  },
)
class VesselDao extends DatabaseAccessor<SoulDatabase>
    with _$VesselDaoMixin {
  VesselDao(super.db);

  /// Returns active config for the given vessel type, or null.
  Future<VesselConfig?> getActiveConfig(String vesselType) =>
      activeConfigByType(vesselType).getSingleOrNull();

  /// Returns all vessel configs.
  Future<List<VesselConfig>> getAllConfigs() => allConfigs().get();

  /// Insert or update a vessel config.
  Future<void> upsertConfig({
    required String id,
    required String vesselType,
    required String host,
    required int port,
    required String tokenRef,
    bool isActive = false,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return into(vesselConfigs).insertOnConflictUpdate(
      VesselConfigsCompanion.insert(
        id: id,
        vesselType: vesselType,
        host: host,
        port: port,
        tokenRef: tokenRef,
        isActive: Value(isActive ? 1 : 0),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  /// Returns recent tasks ordered by created_at DESC.
  Future<List<VesselTask>> getRecentTasks({int limit = 50}) =>
      recentVesselTasks(limit).get();

  /// Get a single task by ID.
  Future<VesselTask?> getTaskById(String id) =>
      vesselTaskById(id).getSingleOrNull();

  /// Get tasks filtered by status.
  Future<List<VesselTask>> getTasksByStatus(String status) =>
      vesselTasksByStatus(status).get();

  /// Create a new task record.
  Future<void> insertTask({
    required String id,
    String? conversationId,
    required String vesselType,
    required String toolName,
    required String description,
    String status = 'proposed',
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return into(vesselTasks).insert(
      VesselTasksCompanion.insert(
        id: id,
        conversationId: Value(conversationId),
        vesselType: vesselType,
        toolName: toolName,
        description: description,
        status: Value(status),
        createdAt: now,
      ),
    );
  }

  // --- Vessel Tools CRUD ---

  /// Insert a single vessel tool into the cache.
  Future<void> insertVesselTool({
    required String vesselId,
    required String toolName,
    String? description,
    required String capabilityGroup,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return into(vesselTools).insertOnConflictUpdate(
      VesselToolsCompanion.insert(
        vesselId: vesselId,
        toolName: toolName,
        description: Value(description),
        capabilityGroup: capabilityGroup,
        cachedAt: now,
      ),
    );
  }

  /// Get all tools for a vessel, ordered by capability group.
  Future<List<VesselTool>> getToolsByVesselId(String vesselId) =>
      toolsByVesselId(vesselId).get();

  /// Get distinct capability groups for a vessel.
  Future<List<String>> getCapabilityGroups(String vesselId) =>
      capabilityGroupsByVesselId(vesselId).get();

  /// Delete all cached tools for a vessel (used before re-fetch).
  Future<void> deleteToolsByVesselId(String vesselId) =>
      deleteByVesselId(vesselId);

  /// Update task status with optional result JSON and error message.
  Future<void> updateTaskStatus(
    String id,
    String status, {
    String? resultJson,
    String? error,
  }) {
    return (update(vesselTasks)..where((t) => t.id.equals(id))).write(
      VesselTasksCompanion(
        status: Value(status),
        resultJson: Value(resultJson),
        errorMessage: Value(error),
        completedAt: Value(
          status == 'completed' || status == 'failed'
              ? DateTime.now().millisecondsSinceEpoch
              : null,
        ),
      ),
    );
  }
}
