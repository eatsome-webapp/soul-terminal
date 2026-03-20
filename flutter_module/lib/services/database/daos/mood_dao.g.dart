// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mood_dao.dart';

// ignore_for_file: type=lint
mixin _$MoodDaoMixin on DatabaseAccessor<SoulDatabase> {
  MoodStates get moodStates => attachedDatabase.moodStates;
  Selectable<MoodState> latestMoodForSession(String sessionId) {
    return customSelect(
      'SELECT * FROM mood_states WHERE session_id = ?1 ORDER BY analyzed_at DESC LIMIT 1',
      variables: [Variable<String>(sessionId)],
      readsFrom: {moodStates},
    ).asyncMap(moodStates.mapFromRow);
  }

  Selectable<MoodState> recentMoodStates(int limit) {
    return customSelect(
      'SELECT * FROM mood_states ORDER BY analyzed_at DESC LIMIT ?1',
      variables: [Variable<int>(limit)],
      readsFrom: {moodStates},
    ).asyncMap(moodStates.mapFromRow);
  }

  Selectable<MoodState> moodStatesOlderThan(int cutoff) {
    return customSelect(
      'SELECT * FROM mood_states WHERE analyzed_at < ?1',
      variables: [Variable<int>(cutoff)],
      readsFrom: {moodStates},
    ).asyncMap(moodStates.mapFromRow);
  }

  MoodDaoManager get managers => MoodDaoManager(this);
}

class MoodDaoManager {
  final _$MoodDaoMixin _db;
  MoodDaoManager(this._db);
  $MoodStatesTableManager get moodStates =>
      $MoodStatesTableManager(_db.attachedDatabase, _db.moodStates);
}
