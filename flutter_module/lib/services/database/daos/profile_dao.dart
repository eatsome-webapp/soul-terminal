import 'package:drift/drift.dart';
import '../soul_database.dart';

part 'profile_dao.g.dart';

@DriftAccessor(
  include: {'../tables/profile_traits.drift'},
)
class ProfileDao extends DatabaseAccessor<SoulDatabase>
    with _$ProfileDaoMixin {
  ProfileDao(super.db);

  Future<List<ProfileTrait>> getAllTraits() => allTraits().get();
  Future<List<ProfileTrait>> getTraitsByCategory(String category) =>
      traitsByCategory(category).get();
  Future<List<ProfileTrait>> getHighConfidenceTraits() =>
      highConfidenceTraits().get();

  Future<void> upsertTrait({
    required String id,
    required String category,
    required String traitKey,
    required String traitValue,
    double confidence = 0.5,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final existing =
        await traitByCategoryAndKey(category, traitKey).getSingleOrNull();
    if (existing != null) {
      await (update(profileTraits)..where((t) => t.id.equals(existing.id)))
          .write(
        ProfileTraitsCompanion(
          traitValue: Value(traitValue),
          confidence: Value(confidence),
          evidenceCount: Value(existing.evidenceCount + 1),
          lastObserved: Value(now),
        ),
      );
    } else {
      await into(profileTraits).insert(
        ProfileTraitsCompanion.insert(
          id: id,
          category: category,
          traitKey: traitKey,
          traitValue: traitValue,
          confidence: Value(confidence),
          firstObserved: now,
          lastObserved: now,
        ),
      );
    }
  }
}
