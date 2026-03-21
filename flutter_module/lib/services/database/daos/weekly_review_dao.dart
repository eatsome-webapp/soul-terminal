import 'package:drift/drift.dart';
import '../soul_database.dart';

part 'weekly_review_dao.g.dart';

@DriftAccessor(include: {'../tables/weekly_reviews.drift'})
class WeeklyReviewDao extends DatabaseAccessor<SoulDatabase>
    with _$WeeklyReviewDaoMixin {
  WeeklyReviewDao(super.db);

  Future<void> insertReview({
    required String weekStart,
    required String content,
    String? metricsSummary,
    double? momentumScore,
  }) async {
    await into(weeklyReviews).insert(WeeklyReviewsCompanion.insert(
      weekStart: weekStart,
      content: content,
      metricsSummary: Value(metricsSummary),
      momentumScore: Value(momentumScore),
      createdAt: DateTime.now().millisecondsSinceEpoch,
    ));
  }

  Future<WeeklyReview?> getReviewForWeek(String weekStart) {
    return (select(weeklyReviews)
          ..where((r) => r.weekStart.equals(weekStart))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<List<WeeklyReview>> getRecentReviews({int limit = 4}) {
    return (select(weeklyReviews)
          ..orderBy([(r) => OrderingTerm.desc(r.createdAt)])
          ..limit(limit))
        .get();
  }
}
