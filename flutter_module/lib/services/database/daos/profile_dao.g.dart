// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_dao.dart';

// ignore_for_file: type=lint
mixin _$ProfileDaoMixin on DatabaseAccessor<SoulDatabase> {
  ProfileTraits get profileTraits => attachedDatabase.profileTraits;
  Selectable<ProfileTrait> allTraits() {
    return customSelect(
      'SELECT * FROM profile_traits ORDER BY confidence DESC',
      variables: [],
      readsFrom: {profileTraits},
    ).asyncMap(profileTraits.mapFromRow);
  }

  Selectable<ProfileTrait> traitsByCategory(String category) {
    return customSelect(
      'SELECT * FROM profile_traits WHERE category = ?1 ORDER BY confidence DESC',
      variables: [Variable<String>(category)],
      readsFrom: {profileTraits},
    ).asyncMap(profileTraits.mapFromRow);
  }

  Selectable<ProfileTrait> highConfidenceTraits() {
    return customSelect(
      'SELECT * FROM profile_traits WHERE confidence >= 0.7 ORDER BY confidence DESC',
      variables: [],
      readsFrom: {profileTraits},
    ).asyncMap(profileTraits.mapFromRow);
  }

  Selectable<ProfileTrait> traitByCategoryAndKey(
    String category,
    String traitKey,
  ) {
    return customSelect(
      'SELECT * FROM profile_traits WHERE category = ?1 AND trait_key = ?2',
      variables: [Variable<String>(category), Variable<String>(traitKey)],
      readsFrom: {profileTraits},
    ).asyncMap(profileTraits.mapFromRow);
  }

  ProfileDaoManager get managers => ProfileDaoManager(this);
}

class ProfileDaoManager {
  final _$ProfileDaoMixin _db;
  ProfileDaoManager(this._db);
  $ProfileTraitsTableManager get profileTraits =>
      $ProfileTraitsTableManager(_db.attachedDatabase, _db.profileTraits);
}
