// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_dao.dart';

// ignore_for_file: type=lint
mixin _$AuditDaoMixin on DatabaseAccessor<SoulDatabase> {
  AuditLog get auditLog => attachedDatabase.auditLog;
  Selectable<AuditLogData> recentAuditEntries(int limit) {
    return customSelect(
      'SELECT * FROM audit_log ORDER BY executed_at DESC LIMIT ?1',
      variables: [Variable<int>(limit)],
      readsFrom: {auditLog},
    ).asyncMap(auditLog.mapFromRow);
  }

  Selectable<int> toolSuccessCount(String toolName) {
    return customSelect(
      'SELECT COUNT(*) AS c FROM audit_log WHERE tool_name = ?1 AND result = \'success\'',
      variables: [Variable<String>(toolName)],
      readsFrom: {auditLog},
    ).map((QueryRow row) => row.read<int>('c'));
  }

  Selectable<int> toolFailureCount(String toolName) {
    return customSelect(
      'SELECT COUNT(*) AS c FROM audit_log WHERE tool_name = ?1 AND result = \'failure\'',
      variables: [Variable<String>(toolName)],
      readsFrom: {auditLog},
    ).map((QueryRow row) => row.read<int>('c'));
  }

  Future<int> deleteAuditOlderThan(int cutoff) {
    return customUpdate(
      'DELETE FROM audit_log WHERE executed_at < ?1',
      variables: [Variable<int>(cutoff)],
      updates: {auditLog},
      updateKind: UpdateKind.delete,
    );
  }

  AuditDaoManager get managers => AuditDaoManager(this);
}

class AuditDaoManager {
  final _$AuditDaoMixin _db;
  AuditDaoManager(this._db);
  $AuditLogTableManager get auditLog =>
      $AuditLogTableManager(_db.attachedDatabase, _db.auditLog);
}
