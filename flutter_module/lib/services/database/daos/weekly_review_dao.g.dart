// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_review_dao.dart';

// ignore_for_file: type=lint
mixin _$WeeklyReviewDaoMixin on DatabaseAccessor<SoulDatabase> {
  WeeklyReviews get weeklyReviews => attachedDatabase.weeklyReviews;
  WeeklyReviewDaoManager get managers => WeeklyReviewDaoManager(this);
}

class WeeklyReviewDaoManager {
  final _$WeeklyReviewDaoMixin _db;
  WeeklyReviewDaoManager(this._db);
  $WeeklyReviewsTableManager get weeklyReviews =>
      $WeeklyReviewsTableManager(_db.attachedDatabase, _db.weeklyReviews);
}
