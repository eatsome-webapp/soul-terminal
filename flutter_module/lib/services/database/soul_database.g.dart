// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'soul_database.dart';

// ignore_for_file: type=lint
class WeeklyReviews extends Table with TableInfo<WeeklyReviews, WeeklyReview> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  WeeklyReviews(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT',
  );
  static const VerificationMeta _weekStartMeta = const VerificationMeta(
    'weekStart',
  );
  late final GeneratedColumn<String> weekStart = GeneratedColumn<String>(
    'week_start',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _metricsSummaryMeta = const VerificationMeta(
    'metricsSummary',
  );
  late final GeneratedColumn<String> metricsSummary = GeneratedColumn<String>(
    'metrics_summary',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _momentumScoreMeta = const VerificationMeta(
    'momentumScore',
  );
  late final GeneratedColumn<double> momentumScore = GeneratedColumn<double>(
    'momentum_score',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    weekStart,
    content,
    metricsSummary,
    momentumScore,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'weekly_reviews';
  @override
  VerificationContext validateIntegrity(
    Insertable<WeeklyReview> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('week_start')) {
      context.handle(
        _weekStartMeta,
        weekStart.isAcceptableOrUnknown(data['week_start']!, _weekStartMeta),
      );
    } else if (isInserting) {
      context.missing(_weekStartMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('metrics_summary')) {
      context.handle(
        _metricsSummaryMeta,
        metricsSummary.isAcceptableOrUnknown(
          data['metrics_summary']!,
          _metricsSummaryMeta,
        ),
      );
    }
    if (data.containsKey('momentum_score')) {
      context.handle(
        _momentumScoreMeta,
        momentumScore.isAcceptableOrUnknown(
          data['momentum_score']!,
          _momentumScoreMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WeeklyReview map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeeklyReview(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      weekStart: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}week_start'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      metricsSummary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metrics_summary'],
      ),
      momentumScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}momentum_score'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  WeeklyReviews createAlias(String alias) {
    return WeeklyReviews(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class WeeklyReview extends DataClass implements Insertable<WeeklyReview> {
  final int id;
  final String weekStart;
  final String content;
  final String? metricsSummary;
  final double? momentumScore;
  final int createdAt;
  const WeeklyReview({
    required this.id,
    required this.weekStart,
    required this.content,
    this.metricsSummary,
    this.momentumScore,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['week_start'] = Variable<String>(weekStart);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || metricsSummary != null) {
      map['metrics_summary'] = Variable<String>(metricsSummary);
    }
    if (!nullToAbsent || momentumScore != null) {
      map['momentum_score'] = Variable<double>(momentumScore);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  WeeklyReviewsCompanion toCompanion(bool nullToAbsent) {
    return WeeklyReviewsCompanion(
      id: Value(id),
      weekStart: Value(weekStart),
      content: Value(content),
      metricsSummary: metricsSummary == null && nullToAbsent
          ? const Value.absent()
          : Value(metricsSummary),
      momentumScore: momentumScore == null && nullToAbsent
          ? const Value.absent()
          : Value(momentumScore),
      createdAt: Value(createdAt),
    );
  }

  factory WeeklyReview.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WeeklyReview(
      id: serializer.fromJson<int>(json['id']),
      weekStart: serializer.fromJson<String>(json['week_start']),
      content: serializer.fromJson<String>(json['content']),
      metricsSummary: serializer.fromJson<String?>(json['metrics_summary']),
      momentumScore: serializer.fromJson<double?>(json['momentum_score']),
      createdAt: serializer.fromJson<int>(json['created_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'week_start': serializer.toJson<String>(weekStart),
      'content': serializer.toJson<String>(content),
      'metrics_summary': serializer.toJson<String?>(metricsSummary),
      'momentum_score': serializer.toJson<double?>(momentumScore),
      'created_at': serializer.toJson<int>(createdAt),
    };
  }

  WeeklyReview copyWith({
    int? id,
    String? weekStart,
    String? content,
    Value<String?> metricsSummary = const Value.absent(),
    Value<double?> momentumScore = const Value.absent(),
    int? createdAt,
  }) => WeeklyReview(
    id: id ?? this.id,
    weekStart: weekStart ?? this.weekStart,
    content: content ?? this.content,
    metricsSummary: metricsSummary.present
        ? metricsSummary.value
        : this.metricsSummary,
    momentumScore: momentumScore.present
        ? momentumScore.value
        : this.momentumScore,
    createdAt: createdAt ?? this.createdAt,
  );
  WeeklyReview copyWithCompanion(WeeklyReviewsCompanion data) {
    return WeeklyReview(
      id: data.id.present ? data.id.value : this.id,
      weekStart: data.weekStart.present ? data.weekStart.value : this.weekStart,
      content: data.content.present ? data.content.value : this.content,
      metricsSummary: data.metricsSummary.present
          ? data.metricsSummary.value
          : this.metricsSummary,
      momentumScore: data.momentumScore.present
          ? data.momentumScore.value
          : this.momentumScore,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeeklyReview(')
          ..write('id: $id, ')
          ..write('weekStart: $weekStart, ')
          ..write('content: $content, ')
          ..write('metricsSummary: $metricsSummary, ')
          ..write('momentumScore: $momentumScore, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    weekStart,
    content,
    metricsSummary,
    momentumScore,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeeklyReview &&
          other.id == this.id &&
          other.weekStart == this.weekStart &&
          other.content == this.content &&
          other.metricsSummary == this.metricsSummary &&
          other.momentumScore == this.momentumScore &&
          other.createdAt == this.createdAt);
}

class WeeklyReviewsCompanion extends UpdateCompanion<WeeklyReview> {
  final Value<int> id;
  final Value<String> weekStart;
  final Value<String> content;
  final Value<String?> metricsSummary;
  final Value<double?> momentumScore;
  final Value<int> createdAt;
  const WeeklyReviewsCompanion({
    this.id = const Value.absent(),
    this.weekStart = const Value.absent(),
    this.content = const Value.absent(),
    this.metricsSummary = const Value.absent(),
    this.momentumScore = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  WeeklyReviewsCompanion.insert({
    this.id = const Value.absent(),
    required String weekStart,
    required String content,
    this.metricsSummary = const Value.absent(),
    this.momentumScore = const Value.absent(),
    required int createdAt,
  }) : weekStart = Value(weekStart),
       content = Value(content),
       createdAt = Value(createdAt);
  static Insertable<WeeklyReview> custom({
    Expression<int>? id,
    Expression<String>? weekStart,
    Expression<String>? content,
    Expression<String>? metricsSummary,
    Expression<double>? momentumScore,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (weekStart != null) 'week_start': weekStart,
      if (content != null) 'content': content,
      if (metricsSummary != null) 'metrics_summary': metricsSummary,
      if (momentumScore != null) 'momentum_score': momentumScore,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  WeeklyReviewsCompanion copyWith({
    Value<int>? id,
    Value<String>? weekStart,
    Value<String>? content,
    Value<String?>? metricsSummary,
    Value<double?>? momentumScore,
    Value<int>? createdAt,
  }) {
    return WeeklyReviewsCompanion(
      id: id ?? this.id,
      weekStart: weekStart ?? this.weekStart,
      content: content ?? this.content,
      metricsSummary: metricsSummary ?? this.metricsSummary,
      momentumScore: momentumScore ?? this.momentumScore,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (weekStart.present) {
      map['week_start'] = Variable<String>(weekStart.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (metricsSummary.present) {
      map['metrics_summary'] = Variable<String>(metricsSummary.value);
    }
    if (momentumScore.present) {
      map['momentum_score'] = Variable<double>(momentumScore.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeeklyReviewsCompanion(')
          ..write('id: $id, ')
          ..write('weekStart: $weekStart, ')
          ..write('content: $content, ')
          ..write('metricsSummary: $metricsSummary, ')
          ..write('momentumScore: $momentumScore, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class Achievements extends Table with TableInfo<Achievements, Achievement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Achievements(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT',
  );
  static const VerificationMeta _milestoneTypeMeta = const VerificationMeta(
    'milestoneType',
  );
  late final GeneratedColumn<String> milestoneType = GeneratedColumn<String>(
    'milestone_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _achievedAtMeta = const VerificationMeta(
    'achievedAt',
  );
  late final GeneratedColumn<int> achievedAt = GeneratedColumn<int>(
    'achieved_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _contextSummaryMeta = const VerificationMeta(
    'contextSummary',
  );
  late final GeneratedColumn<String> contextSummary = GeneratedColumn<String>(
    'context_summary',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _celebrationTierMeta = const VerificationMeta(
    'celebrationTier',
  );
  late final GeneratedColumn<String> celebrationTier = GeneratedColumn<String>(
    'celebration_tier',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _displayedMeta = const VerificationMeta(
    'displayed',
  );
  late final GeneratedColumn<int> displayed = GeneratedColumn<int>(
    'displayed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    milestoneType,
    achievedAt,
    contextSummary,
    celebrationTier,
    displayed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'achievements';
  @override
  VerificationContext validateIntegrity(
    Insertable<Achievement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('milestone_type')) {
      context.handle(
        _milestoneTypeMeta,
        milestoneType.isAcceptableOrUnknown(
          data['milestone_type']!,
          _milestoneTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_milestoneTypeMeta);
    }
    if (data.containsKey('achieved_at')) {
      context.handle(
        _achievedAtMeta,
        achievedAt.isAcceptableOrUnknown(data['achieved_at']!, _achievedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_achievedAtMeta);
    }
    if (data.containsKey('context_summary')) {
      context.handle(
        _contextSummaryMeta,
        contextSummary.isAcceptableOrUnknown(
          data['context_summary']!,
          _contextSummaryMeta,
        ),
      );
    }
    if (data.containsKey('celebration_tier')) {
      context.handle(
        _celebrationTierMeta,
        celebrationTier.isAcceptableOrUnknown(
          data['celebration_tier']!,
          _celebrationTierMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_celebrationTierMeta);
    }
    if (data.containsKey('displayed')) {
      context.handle(
        _displayedMeta,
        displayed.isAcceptableOrUnknown(data['displayed']!, _displayedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Achievement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Achievement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      milestoneType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}milestone_type'],
      )!,
      achievedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}achieved_at'],
      )!,
      contextSummary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}context_summary'],
      ),
      celebrationTier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}celebration_tier'],
      )!,
      displayed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}displayed'],
      )!,
    );
  }

  @override
  Achievements createAlias(String alias) {
    return Achievements(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class Achievement extends DataClass implements Insertable<Achievement> {
  final int id;
  final String milestoneType;
  final int achievedAt;
  final String? contextSummary;
  final String celebrationTier;
  final int displayed;
  const Achievement({
    required this.id,
    required this.milestoneType,
    required this.achievedAt,
    this.contextSummary,
    required this.celebrationTier,
    required this.displayed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['milestone_type'] = Variable<String>(milestoneType);
    map['achieved_at'] = Variable<int>(achievedAt);
    if (!nullToAbsent || contextSummary != null) {
      map['context_summary'] = Variable<String>(contextSummary);
    }
    map['celebration_tier'] = Variable<String>(celebrationTier);
    map['displayed'] = Variable<int>(displayed);
    return map;
  }

  AchievementsCompanion toCompanion(bool nullToAbsent) {
    return AchievementsCompanion(
      id: Value(id),
      milestoneType: Value(milestoneType),
      achievedAt: Value(achievedAt),
      contextSummary: contextSummary == null && nullToAbsent
          ? const Value.absent()
          : Value(contextSummary),
      celebrationTier: Value(celebrationTier),
      displayed: Value(displayed),
    );
  }

  factory Achievement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Achievement(
      id: serializer.fromJson<int>(json['id']),
      milestoneType: serializer.fromJson<String>(json['milestone_type']),
      achievedAt: serializer.fromJson<int>(json['achieved_at']),
      contextSummary: serializer.fromJson<String?>(json['context_summary']),
      celebrationTier: serializer.fromJson<String>(json['celebration_tier']),
      displayed: serializer.fromJson<int>(json['displayed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'milestone_type': serializer.toJson<String>(milestoneType),
      'achieved_at': serializer.toJson<int>(achievedAt),
      'context_summary': serializer.toJson<String?>(contextSummary),
      'celebration_tier': serializer.toJson<String>(celebrationTier),
      'displayed': serializer.toJson<int>(displayed),
    };
  }

  Achievement copyWith({
    int? id,
    String? milestoneType,
    int? achievedAt,
    Value<String?> contextSummary = const Value.absent(),
    String? celebrationTier,
    int? displayed,
  }) => Achievement(
    id: id ?? this.id,
    milestoneType: milestoneType ?? this.milestoneType,
    achievedAt: achievedAt ?? this.achievedAt,
    contextSummary: contextSummary.present
        ? contextSummary.value
        : this.contextSummary,
    celebrationTier: celebrationTier ?? this.celebrationTier,
    displayed: displayed ?? this.displayed,
  );
  Achievement copyWithCompanion(AchievementsCompanion data) {
    return Achievement(
      id: data.id.present ? data.id.value : this.id,
      milestoneType: data.milestoneType.present
          ? data.milestoneType.value
          : this.milestoneType,
      achievedAt: data.achievedAt.present
          ? data.achievedAt.value
          : this.achievedAt,
      contextSummary: data.contextSummary.present
          ? data.contextSummary.value
          : this.contextSummary,
      celebrationTier: data.celebrationTier.present
          ? data.celebrationTier.value
          : this.celebrationTier,
      displayed: data.displayed.present ? data.displayed.value : this.displayed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Achievement(')
          ..write('id: $id, ')
          ..write('milestoneType: $milestoneType, ')
          ..write('achievedAt: $achievedAt, ')
          ..write('contextSummary: $contextSummary, ')
          ..write('celebrationTier: $celebrationTier, ')
          ..write('displayed: $displayed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    milestoneType,
    achievedAt,
    contextSummary,
    celebrationTier,
    displayed,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Achievement &&
          other.id == this.id &&
          other.milestoneType == this.milestoneType &&
          other.achievedAt == this.achievedAt &&
          other.contextSummary == this.contextSummary &&
          other.celebrationTier == this.celebrationTier &&
          other.displayed == this.displayed);
}

class AchievementsCompanion extends UpdateCompanion<Achievement> {
  final Value<int> id;
  final Value<String> milestoneType;
  final Value<int> achievedAt;
  final Value<String?> contextSummary;
  final Value<String> celebrationTier;
  final Value<int> displayed;
  const AchievementsCompanion({
    this.id = const Value.absent(),
    this.milestoneType = const Value.absent(),
    this.achievedAt = const Value.absent(),
    this.contextSummary = const Value.absent(),
    this.celebrationTier = const Value.absent(),
    this.displayed = const Value.absent(),
  });
  AchievementsCompanion.insert({
    this.id = const Value.absent(),
    required String milestoneType,
    required int achievedAt,
    this.contextSummary = const Value.absent(),
    required String celebrationTier,
    this.displayed = const Value.absent(),
  }) : milestoneType = Value(milestoneType),
       achievedAt = Value(achievedAt),
       celebrationTier = Value(celebrationTier);
  static Insertable<Achievement> custom({
    Expression<int>? id,
    Expression<String>? milestoneType,
    Expression<int>? achievedAt,
    Expression<String>? contextSummary,
    Expression<String>? celebrationTier,
    Expression<int>? displayed,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (milestoneType != null) 'milestone_type': milestoneType,
      if (achievedAt != null) 'achieved_at': achievedAt,
      if (contextSummary != null) 'context_summary': contextSummary,
      if (celebrationTier != null) 'celebration_tier': celebrationTier,
      if (displayed != null) 'displayed': displayed,
    });
  }

  AchievementsCompanion copyWith({
    Value<int>? id,
    Value<String>? milestoneType,
    Value<int>? achievedAt,
    Value<String?>? contextSummary,
    Value<String>? celebrationTier,
    Value<int>? displayed,
  }) {
    return AchievementsCompanion(
      id: id ?? this.id,
      milestoneType: milestoneType ?? this.milestoneType,
      achievedAt: achievedAt ?? this.achievedAt,
      contextSummary: contextSummary ?? this.contextSummary,
      celebrationTier: celebrationTier ?? this.celebrationTier,
      displayed: displayed ?? this.displayed,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (milestoneType.present) {
      map['milestone_type'] = Variable<String>(milestoneType.value);
    }
    if (achievedAt.present) {
      map['achieved_at'] = Variable<int>(achievedAt.value);
    }
    if (contextSummary.present) {
      map['context_summary'] = Variable<String>(contextSummary.value);
    }
    if (celebrationTier.present) {
      map['celebration_tier'] = Variable<String>(celebrationTier.value);
    }
    if (displayed.present) {
      map['displayed'] = Variable<int>(displayed.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AchievementsCompanion(')
          ..write('id: $id, ')
          ..write('milestoneType: $milestoneType, ')
          ..write('achievedAt: $achievedAt, ')
          ..write('contextSummary: $contextSummary, ')
          ..write('celebrationTier: $celebrationTier, ')
          ..write('displayed: $displayed')
          ..write(')'))
        .toString();
  }
}

class Streaks extends Table with TableInfo<Streaks, Streak> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Streaks(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT',
  );
  static const VerificationMeta _streakTypeMeta = const VerificationMeta(
    'streakType',
  );
  late final GeneratedColumn<String> streakType = GeneratedColumn<String>(
    'streak_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL UNIQUE',
  );
  static const VerificationMeta _currentCountMeta = const VerificationMeta(
    'currentCount',
  );
  late final GeneratedColumn<int> currentCount = GeneratedColumn<int>(
    'current_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _longestCountMeta = const VerificationMeta(
    'longestCount',
  );
  late final GeneratedColumn<int> longestCount = GeneratedColumn<int>(
    'longest_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _lastActiveDateMeta = const VerificationMeta(
    'lastActiveDate',
  );
  late final GeneratedColumn<String> lastActiveDate = GeneratedColumn<String>(
    'last_active_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _graceUsedMeta = const VerificationMeta(
    'graceUsed',
  );
  late final GeneratedColumn<int> graceUsed = GeneratedColumn<int>(
    'grace_used',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    streakType,
    currentCount,
    longestCount,
    lastActiveDate,
    graceUsed,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'streaks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Streak> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('streak_type')) {
      context.handle(
        _streakTypeMeta,
        streakType.isAcceptableOrUnknown(data['streak_type']!, _streakTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_streakTypeMeta);
    }
    if (data.containsKey('current_count')) {
      context.handle(
        _currentCountMeta,
        currentCount.isAcceptableOrUnknown(
          data['current_count']!,
          _currentCountMeta,
        ),
      );
    }
    if (data.containsKey('longest_count')) {
      context.handle(
        _longestCountMeta,
        longestCount.isAcceptableOrUnknown(
          data['longest_count']!,
          _longestCountMeta,
        ),
      );
    }
    if (data.containsKey('last_active_date')) {
      context.handle(
        _lastActiveDateMeta,
        lastActiveDate.isAcceptableOrUnknown(
          data['last_active_date']!,
          _lastActiveDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastActiveDateMeta);
    }
    if (data.containsKey('grace_used')) {
      context.handle(
        _graceUsedMeta,
        graceUsed.isAcceptableOrUnknown(data['grace_used']!, _graceUsedMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Streak map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Streak(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      streakType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}streak_type'],
      )!,
      currentCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_count'],
      )!,
      longestCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}longest_count'],
      )!,
      lastActiveDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_active_date'],
      )!,
      graceUsed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}grace_used'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  Streaks createAlias(String alias) {
    return Streaks(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class Streak extends DataClass implements Insertable<Streak> {
  final int id;
  final String streakType;
  final int currentCount;
  final int longestCount;
  final String lastActiveDate;
  final int graceUsed;
  final int updatedAt;
  const Streak({
    required this.id,
    required this.streakType,
    required this.currentCount,
    required this.longestCount,
    required this.lastActiveDate,
    required this.graceUsed,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['streak_type'] = Variable<String>(streakType);
    map['current_count'] = Variable<int>(currentCount);
    map['longest_count'] = Variable<int>(longestCount);
    map['last_active_date'] = Variable<String>(lastActiveDate);
    map['grace_used'] = Variable<int>(graceUsed);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  StreaksCompanion toCompanion(bool nullToAbsent) {
    return StreaksCompanion(
      id: Value(id),
      streakType: Value(streakType),
      currentCount: Value(currentCount),
      longestCount: Value(longestCount),
      lastActiveDate: Value(lastActiveDate),
      graceUsed: Value(graceUsed),
      updatedAt: Value(updatedAt),
    );
  }

  factory Streak.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Streak(
      id: serializer.fromJson<int>(json['id']),
      streakType: serializer.fromJson<String>(json['streak_type']),
      currentCount: serializer.fromJson<int>(json['current_count']),
      longestCount: serializer.fromJson<int>(json['longest_count']),
      lastActiveDate: serializer.fromJson<String>(json['last_active_date']),
      graceUsed: serializer.fromJson<int>(json['grace_used']),
      updatedAt: serializer.fromJson<int>(json['updated_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'streak_type': serializer.toJson<String>(streakType),
      'current_count': serializer.toJson<int>(currentCount),
      'longest_count': serializer.toJson<int>(longestCount),
      'last_active_date': serializer.toJson<String>(lastActiveDate),
      'grace_used': serializer.toJson<int>(graceUsed),
      'updated_at': serializer.toJson<int>(updatedAt),
    };
  }

  Streak copyWith({
    int? id,
    String? streakType,
    int? currentCount,
    int? longestCount,
    String? lastActiveDate,
    int? graceUsed,
    int? updatedAt,
  }) => Streak(
    id: id ?? this.id,
    streakType: streakType ?? this.streakType,
    currentCount: currentCount ?? this.currentCount,
    longestCount: longestCount ?? this.longestCount,
    lastActiveDate: lastActiveDate ?? this.lastActiveDate,
    graceUsed: graceUsed ?? this.graceUsed,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Streak copyWithCompanion(StreaksCompanion data) {
    return Streak(
      id: data.id.present ? data.id.value : this.id,
      streakType: data.streakType.present
          ? data.streakType.value
          : this.streakType,
      currentCount: data.currentCount.present
          ? data.currentCount.value
          : this.currentCount,
      longestCount: data.longestCount.present
          ? data.longestCount.value
          : this.longestCount,
      lastActiveDate: data.lastActiveDate.present
          ? data.lastActiveDate.value
          : this.lastActiveDate,
      graceUsed: data.graceUsed.present ? data.graceUsed.value : this.graceUsed,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Streak(')
          ..write('id: $id, ')
          ..write('streakType: $streakType, ')
          ..write('currentCount: $currentCount, ')
          ..write('longestCount: $longestCount, ')
          ..write('lastActiveDate: $lastActiveDate, ')
          ..write('graceUsed: $graceUsed, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    streakType,
    currentCount,
    longestCount,
    lastActiveDate,
    graceUsed,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Streak &&
          other.id == this.id &&
          other.streakType == this.streakType &&
          other.currentCount == this.currentCount &&
          other.longestCount == this.longestCount &&
          other.lastActiveDate == this.lastActiveDate &&
          other.graceUsed == this.graceUsed &&
          other.updatedAt == this.updatedAt);
}

class StreaksCompanion extends UpdateCompanion<Streak> {
  final Value<int> id;
  final Value<String> streakType;
  final Value<int> currentCount;
  final Value<int> longestCount;
  final Value<String> lastActiveDate;
  final Value<int> graceUsed;
  final Value<int> updatedAt;
  const StreaksCompanion({
    this.id = const Value.absent(),
    this.streakType = const Value.absent(),
    this.currentCount = const Value.absent(),
    this.longestCount = const Value.absent(),
    this.lastActiveDate = const Value.absent(),
    this.graceUsed = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  StreaksCompanion.insert({
    this.id = const Value.absent(),
    required String streakType,
    this.currentCount = const Value.absent(),
    this.longestCount = const Value.absent(),
    required String lastActiveDate,
    this.graceUsed = const Value.absent(),
    required int updatedAt,
  }) : streakType = Value(streakType),
       lastActiveDate = Value(lastActiveDate),
       updatedAt = Value(updatedAt);
  static Insertable<Streak> custom({
    Expression<int>? id,
    Expression<String>? streakType,
    Expression<int>? currentCount,
    Expression<int>? longestCount,
    Expression<String>? lastActiveDate,
    Expression<int>? graceUsed,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (streakType != null) 'streak_type': streakType,
      if (currentCount != null) 'current_count': currentCount,
      if (longestCount != null) 'longest_count': longestCount,
      if (lastActiveDate != null) 'last_active_date': lastActiveDate,
      if (graceUsed != null) 'grace_used': graceUsed,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  StreaksCompanion copyWith({
    Value<int>? id,
    Value<String>? streakType,
    Value<int>? currentCount,
    Value<int>? longestCount,
    Value<String>? lastActiveDate,
    Value<int>? graceUsed,
    Value<int>? updatedAt,
  }) {
    return StreaksCompanion(
      id: id ?? this.id,
      streakType: streakType ?? this.streakType,
      currentCount: currentCount ?? this.currentCount,
      longestCount: longestCount ?? this.longestCount,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      graceUsed: graceUsed ?? this.graceUsed,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (streakType.present) {
      map['streak_type'] = Variable<String>(streakType.value);
    }
    if (currentCount.present) {
      map['current_count'] = Variable<int>(currentCount.value);
    }
    if (longestCount.present) {
      map['longest_count'] = Variable<int>(longestCount.value);
    }
    if (lastActiveDate.present) {
      map['last_active_date'] = Variable<String>(lastActiveDate.value);
    }
    if (graceUsed.present) {
      map['grace_used'] = Variable<int>(graceUsed.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StreaksCompanion(')
          ..write('id: $id, ')
          ..write('streakType: $streakType, ')
          ..write('currentCount: $currentCount, ')
          ..write('longestCount: $longestCount, ')
          ..write('lastActiveDate: $lastActiveDate, ')
          ..write('graceUsed: $graceUsed, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class DailyMetrics extends Table with TableInfo<DailyMetrics, DailyMetric> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  DailyMetrics(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT',
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _metricTypeMeta = const VerificationMeta(
    'metricType',
  );
  late final GeneratedColumn<String> metricType = GeneratedColumn<String>(
    'metric_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    metricType,
    value,
    projectId,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_metrics';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyMetric> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('metric_type')) {
      context.handle(
        _metricTypeMeta,
        metricType.isAcceptableOrUnknown(data['metric_type']!, _metricTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_metricTypeMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {date, metricType},
  ];
  @override
  DailyMetric map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyMetric(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      metricType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metric_type'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  DailyMetrics createAlias(String alias) {
    return DailyMetrics(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const ['UNIQUE(date, metric_type)'];
  @override
  bool get dontWriteConstraints => true;
}

class DailyMetric extends DataClass implements Insertable<DailyMetric> {
  final int id;
  final String date;
  final String metricType;
  final double value;
  final String? projectId;
  final int updatedAt;
  const DailyMetric({
    required this.id,
    required this.date,
    required this.metricType,
    required this.value,
    this.projectId,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<String>(date);
    map['metric_type'] = Variable<String>(metricType);
    map['value'] = Variable<double>(value);
    if (!nullToAbsent || projectId != null) {
      map['project_id'] = Variable<String>(projectId);
    }
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  DailyMetricsCompanion toCompanion(bool nullToAbsent) {
    return DailyMetricsCompanion(
      id: Value(id),
      date: Value(date),
      metricType: Value(metricType),
      value: Value(value),
      projectId: projectId == null && nullToAbsent
          ? const Value.absent()
          : Value(projectId),
      updatedAt: Value(updatedAt),
    );
  }

  factory DailyMetric.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyMetric(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<String>(json['date']),
      metricType: serializer.fromJson<String>(json['metric_type']),
      value: serializer.fromJson<double>(json['value']),
      projectId: serializer.fromJson<String?>(json['project_id']),
      updatedAt: serializer.fromJson<int>(json['updated_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<String>(date),
      'metric_type': serializer.toJson<String>(metricType),
      'value': serializer.toJson<double>(value),
      'project_id': serializer.toJson<String?>(projectId),
      'updated_at': serializer.toJson<int>(updatedAt),
    };
  }

  DailyMetric copyWith({
    int? id,
    String? date,
    String? metricType,
    double? value,
    Value<String?> projectId = const Value.absent(),
    int? updatedAt,
  }) => DailyMetric(
    id: id ?? this.id,
    date: date ?? this.date,
    metricType: metricType ?? this.metricType,
    value: value ?? this.value,
    projectId: projectId.present ? projectId.value : this.projectId,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DailyMetric copyWithCompanion(DailyMetricsCompanion data) {
    return DailyMetric(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      metricType: data.metricType.present
          ? data.metricType.value
          : this.metricType,
      value: data.value.present ? data.value.value : this.value,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyMetric(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('metricType: $metricType, ')
          ..write('value: $value, ')
          ..write('projectId: $projectId, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, date, metricType, value, projectId, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyMetric &&
          other.id == this.id &&
          other.date == this.date &&
          other.metricType == this.metricType &&
          other.value == this.value &&
          other.projectId == this.projectId &&
          other.updatedAt == this.updatedAt);
}

class DailyMetricsCompanion extends UpdateCompanion<DailyMetric> {
  final Value<int> id;
  final Value<String> date;
  final Value<String> metricType;
  final Value<double> value;
  final Value<String?> projectId;
  final Value<int> updatedAt;
  const DailyMetricsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.metricType = const Value.absent(),
    this.value = const Value.absent(),
    this.projectId = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  DailyMetricsCompanion.insert({
    this.id = const Value.absent(),
    required String date,
    required String metricType,
    required double value,
    this.projectId = const Value.absent(),
    required int updatedAt,
  }) : date = Value(date),
       metricType = Value(metricType),
       value = Value(value),
       updatedAt = Value(updatedAt);
  static Insertable<DailyMetric> custom({
    Expression<int>? id,
    Expression<String>? date,
    Expression<String>? metricType,
    Expression<double>? value,
    Expression<String>? projectId,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (metricType != null) 'metric_type': metricType,
      if (value != null) 'value': value,
      if (projectId != null) 'project_id': projectId,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  DailyMetricsCompanion copyWith({
    Value<int>? id,
    Value<String>? date,
    Value<String>? metricType,
    Value<double>? value,
    Value<String?>? projectId,
    Value<int>? updatedAt,
  }) {
    return DailyMetricsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      metricType: metricType ?? this.metricType,
      value: value ?? this.value,
      projectId: projectId ?? this.projectId,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (metricType.present) {
      map['metric_type'] = Variable<String>(metricType.value);
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyMetricsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('metricType: $metricType, ')
          ..write('value: $value, ')
          ..write('projectId: $projectId, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class AgenticWal extends Table with TableInfo<AgenticWal, AgenticWalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  AgenticWal(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT',
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _iterationMeta = const VerificationMeta(
    'iteration',
  );
  late final GeneratedColumn<int> iteration = GeneratedColumn<int>(
    'iteration',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _intentionMeta = const VerificationMeta(
    'intention',
  );
  late final GeneratedColumn<String> intention = GeneratedColumn<String>(
    'intention',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _toolNameMeta = const VerificationMeta(
    'toolName',
  );
  late final GeneratedColumn<String> toolName = GeneratedColumn<String>(
    'tool_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _toolArgsMeta = const VerificationMeta(
    'toolArgs',
  );
  late final GeneratedColumn<String> toolArgs = GeneratedColumn<String>(
    'tool_args',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'pending\'',
    defaultValue: const CustomExpression('\'pending\''),
  );
  static const VerificationMeta _resultSummaryMeta = const VerificationMeta(
    'resultSummary',
  );
  late final GeneratedColumn<String> resultSummary = GeneratedColumn<String>(
    'result_summary',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  late final GeneratedColumn<int> startedAt = GeneratedColumn<int>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  late final GeneratedColumn<int> completedAt = GeneratedColumn<int>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    iteration,
    intention,
    toolName,
    toolArgs,
    status,
    resultSummary,
    startedAt,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'agentic_wal';
  @override
  VerificationContext validateIntegrity(
    Insertable<AgenticWalData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('iteration')) {
      context.handle(
        _iterationMeta,
        iteration.isAcceptableOrUnknown(data['iteration']!, _iterationMeta),
      );
    } else if (isInserting) {
      context.missing(_iterationMeta);
    }
    if (data.containsKey('intention')) {
      context.handle(
        _intentionMeta,
        intention.isAcceptableOrUnknown(data['intention']!, _intentionMeta),
      );
    } else if (isInserting) {
      context.missing(_intentionMeta);
    }
    if (data.containsKey('tool_name')) {
      context.handle(
        _toolNameMeta,
        toolName.isAcceptableOrUnknown(data['tool_name']!, _toolNameMeta),
      );
    } else if (isInserting) {
      context.missing(_toolNameMeta);
    }
    if (data.containsKey('tool_args')) {
      context.handle(
        _toolArgsMeta,
        toolArgs.isAcceptableOrUnknown(data['tool_args']!, _toolArgsMeta),
      );
    } else if (isInserting) {
      context.missing(_toolArgsMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('result_summary')) {
      context.handle(
        _resultSummaryMeta,
        resultSummary.isAcceptableOrUnknown(
          data['result_summary']!,
          _resultSummaryMeta,
        ),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AgenticWalData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AgenticWalData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      iteration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}iteration'],
      )!,
      intention: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}intention'],
      )!,
      toolName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tool_name'],
      )!,
      toolArgs: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tool_args'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      resultSummary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}result_summary'],
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}started_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  AgenticWal createAlias(String alias) {
    return AgenticWal(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class AgenticWalData extends DataClass implements Insertable<AgenticWalData> {
  final int id;
  final String sessionId;
  final int iteration;
  final String intention;
  final String toolName;
  final String toolArgs;
  final String status;
  final String? resultSummary;
  final int startedAt;
  final int? completedAt;
  const AgenticWalData({
    required this.id,
    required this.sessionId,
    required this.iteration,
    required this.intention,
    required this.toolName,
    required this.toolArgs,
    required this.status,
    this.resultSummary,
    required this.startedAt,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['iteration'] = Variable<int>(iteration);
    map['intention'] = Variable<String>(intention);
    map['tool_name'] = Variable<String>(toolName);
    map['tool_args'] = Variable<String>(toolArgs);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || resultSummary != null) {
      map['result_summary'] = Variable<String>(resultSummary);
    }
    map['started_at'] = Variable<int>(startedAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<int>(completedAt);
    }
    return map;
  }

  AgenticWalCompanion toCompanion(bool nullToAbsent) {
    return AgenticWalCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      iteration: Value(iteration),
      intention: Value(intention),
      toolName: Value(toolName),
      toolArgs: Value(toolArgs),
      status: Value(status),
      resultSummary: resultSummary == null && nullToAbsent
          ? const Value.absent()
          : Value(resultSummary),
      startedAt: Value(startedAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory AgenticWalData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AgenticWalData(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<String>(json['session_id']),
      iteration: serializer.fromJson<int>(json['iteration']),
      intention: serializer.fromJson<String>(json['intention']),
      toolName: serializer.fromJson<String>(json['tool_name']),
      toolArgs: serializer.fromJson<String>(json['tool_args']),
      status: serializer.fromJson<String>(json['status']),
      resultSummary: serializer.fromJson<String?>(json['result_summary']),
      startedAt: serializer.fromJson<int>(json['started_at']),
      completedAt: serializer.fromJson<int?>(json['completed_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'session_id': serializer.toJson<String>(sessionId),
      'iteration': serializer.toJson<int>(iteration),
      'intention': serializer.toJson<String>(intention),
      'tool_name': serializer.toJson<String>(toolName),
      'tool_args': serializer.toJson<String>(toolArgs),
      'status': serializer.toJson<String>(status),
      'result_summary': serializer.toJson<String?>(resultSummary),
      'started_at': serializer.toJson<int>(startedAt),
      'completed_at': serializer.toJson<int?>(completedAt),
    };
  }

  AgenticWalData copyWith({
    int? id,
    String? sessionId,
    int? iteration,
    String? intention,
    String? toolName,
    String? toolArgs,
    String? status,
    Value<String?> resultSummary = const Value.absent(),
    int? startedAt,
    Value<int?> completedAt = const Value.absent(),
  }) => AgenticWalData(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    iteration: iteration ?? this.iteration,
    intention: intention ?? this.intention,
    toolName: toolName ?? this.toolName,
    toolArgs: toolArgs ?? this.toolArgs,
    status: status ?? this.status,
    resultSummary: resultSummary.present
        ? resultSummary.value
        : this.resultSummary,
    startedAt: startedAt ?? this.startedAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  AgenticWalData copyWithCompanion(AgenticWalCompanion data) {
    return AgenticWalData(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      iteration: data.iteration.present ? data.iteration.value : this.iteration,
      intention: data.intention.present ? data.intention.value : this.intention,
      toolName: data.toolName.present ? data.toolName.value : this.toolName,
      toolArgs: data.toolArgs.present ? data.toolArgs.value : this.toolArgs,
      status: data.status.present ? data.status.value : this.status,
      resultSummary: data.resultSummary.present
          ? data.resultSummary.value
          : this.resultSummary,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AgenticWalData(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('iteration: $iteration, ')
          ..write('intention: $intention, ')
          ..write('toolName: $toolName, ')
          ..write('toolArgs: $toolArgs, ')
          ..write('status: $status, ')
          ..write('resultSummary: $resultSummary, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    iteration,
    intention,
    toolName,
    toolArgs,
    status,
    resultSummary,
    startedAt,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AgenticWalData &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.iteration == this.iteration &&
          other.intention == this.intention &&
          other.toolName == this.toolName &&
          other.toolArgs == this.toolArgs &&
          other.status == this.status &&
          other.resultSummary == this.resultSummary &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt);
}

class AgenticWalCompanion extends UpdateCompanion<AgenticWalData> {
  final Value<int> id;
  final Value<String> sessionId;
  final Value<int> iteration;
  final Value<String> intention;
  final Value<String> toolName;
  final Value<String> toolArgs;
  final Value<String> status;
  final Value<String?> resultSummary;
  final Value<int> startedAt;
  final Value<int?> completedAt;
  const AgenticWalCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.iteration = const Value.absent(),
    this.intention = const Value.absent(),
    this.toolName = const Value.absent(),
    this.toolArgs = const Value.absent(),
    this.status = const Value.absent(),
    this.resultSummary = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
  });
  AgenticWalCompanion.insert({
    this.id = const Value.absent(),
    required String sessionId,
    required int iteration,
    required String intention,
    required String toolName,
    required String toolArgs,
    this.status = const Value.absent(),
    this.resultSummary = const Value.absent(),
    required int startedAt,
    this.completedAt = const Value.absent(),
  }) : sessionId = Value(sessionId),
       iteration = Value(iteration),
       intention = Value(intention),
       toolName = Value(toolName),
       toolArgs = Value(toolArgs),
       startedAt = Value(startedAt);
  static Insertable<AgenticWalData> custom({
    Expression<int>? id,
    Expression<String>? sessionId,
    Expression<int>? iteration,
    Expression<String>? intention,
    Expression<String>? toolName,
    Expression<String>? toolArgs,
    Expression<String>? status,
    Expression<String>? resultSummary,
    Expression<int>? startedAt,
    Expression<int>? completedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (iteration != null) 'iteration': iteration,
      if (intention != null) 'intention': intention,
      if (toolName != null) 'tool_name': toolName,
      if (toolArgs != null) 'tool_args': toolArgs,
      if (status != null) 'status': status,
      if (resultSummary != null) 'result_summary': resultSummary,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
    });
  }

  AgenticWalCompanion copyWith({
    Value<int>? id,
    Value<String>? sessionId,
    Value<int>? iteration,
    Value<String>? intention,
    Value<String>? toolName,
    Value<String>? toolArgs,
    Value<String>? status,
    Value<String?>? resultSummary,
    Value<int>? startedAt,
    Value<int?>? completedAt,
  }) {
    return AgenticWalCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      iteration: iteration ?? this.iteration,
      intention: intention ?? this.intention,
      toolName: toolName ?? this.toolName,
      toolArgs: toolArgs ?? this.toolArgs,
      status: status ?? this.status,
      resultSummary: resultSummary ?? this.resultSummary,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (iteration.present) {
      map['iteration'] = Variable<int>(iteration.value);
    }
    if (intention.present) {
      map['intention'] = Variable<String>(intention.value);
    }
    if (toolName.present) {
      map['tool_name'] = Variable<String>(toolName.value);
    }
    if (toolArgs.present) {
      map['tool_args'] = Variable<String>(toolArgs.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (resultSummary.present) {
      map['result_summary'] = Variable<String>(resultSummary.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<int>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(completedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AgenticWalCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('iteration: $iteration, ')
          ..write('intention: $intention, ')
          ..write('toolName: $toolName, ')
          ..write('toolArgs: $toolArgs, ')
          ..write('status: $status, ')
          ..write('resultSummary: $resultSummary, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }
}

class ProjectState extends Table
    with TableInfo<ProjectState, ProjectStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ProjectState(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT',
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _currentStatusMeta = const VerificationMeta(
    'currentStatus',
  );
  late final GeneratedColumn<String> currentStatus = GeneratedColumn<String>(
    'current_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _unvalidatedAssumptionsMeta =
      const VerificationMeta('unvalidatedAssumptions');
  late final GeneratedColumn<String> unvalidatedAssumptions =
      GeneratedColumn<String>(
        'unvalidated_assumptions',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  static const VerificationMeta _riskiestItemMeta = const VerificationMeta(
    'riskiestItem',
  );
  late final GeneratedColumn<String> riskiestItem = GeneratedColumn<String>(
    'riskiest_item',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _scopeCreepFlagsMeta = const VerificationMeta(
    'scopeCreepFlags',
  );
  late final GeneratedColumn<String> scopeCreepFlags = GeneratedColumn<String>(
    'scope_creep_flags',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _sourceConversationIdMeta =
      const VerificationMeta('sourceConversationId');
  late final GeneratedColumn<String> sourceConversationId =
      GeneratedColumn<String>(
        'source_conversation_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    projectId,
    currentStatus,
    unvalidatedAssumptions,
    riskiestItem,
    scopeCreepFlags,
    updatedAt,
    sourceConversationId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'project_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProjectStateData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('current_status')) {
      context.handle(
        _currentStatusMeta,
        currentStatus.isAcceptableOrUnknown(
          data['current_status']!,
          _currentStatusMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currentStatusMeta);
    }
    if (data.containsKey('unvalidated_assumptions')) {
      context.handle(
        _unvalidatedAssumptionsMeta,
        unvalidatedAssumptions.isAcceptableOrUnknown(
          data['unvalidated_assumptions']!,
          _unvalidatedAssumptionsMeta,
        ),
      );
    }
    if (data.containsKey('riskiest_item')) {
      context.handle(
        _riskiestItemMeta,
        riskiestItem.isAcceptableOrUnknown(
          data['riskiest_item']!,
          _riskiestItemMeta,
        ),
      );
    }
    if (data.containsKey('scope_creep_flags')) {
      context.handle(
        _scopeCreepFlagsMeta,
        scopeCreepFlags.isAcceptableOrUnknown(
          data['scope_creep_flags']!,
          _scopeCreepFlagsMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('source_conversation_id')) {
      context.handle(
        _sourceConversationIdMeta,
        sourceConversationId.isAcceptableOrUnknown(
          data['source_conversation_id']!,
          _sourceConversationIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProjectStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProjectStateData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      currentStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}current_status'],
      )!,
      unvalidatedAssumptions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unvalidated_assumptions'],
      ),
      riskiestItem: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}riskiest_item'],
      ),
      scopeCreepFlags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scope_creep_flags'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      sourceConversationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_conversation_id'],
      ),
    );
  }

  @override
  ProjectState createAlias(String alias) {
    return ProjectState(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class ProjectStateData extends DataClass
    implements Insertable<ProjectStateData> {
  final int id;
  final String projectId;
  final String currentStatus;
  final String? unvalidatedAssumptions;
  final String? riskiestItem;
  final String? scopeCreepFlags;
  final int updatedAt;
  final String? sourceConversationId;
  const ProjectStateData({
    required this.id,
    required this.projectId,
    required this.currentStatus,
    this.unvalidatedAssumptions,
    this.riskiestItem,
    this.scopeCreepFlags,
    required this.updatedAt,
    this.sourceConversationId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['project_id'] = Variable<String>(projectId);
    map['current_status'] = Variable<String>(currentStatus);
    if (!nullToAbsent || unvalidatedAssumptions != null) {
      map['unvalidated_assumptions'] = Variable<String>(unvalidatedAssumptions);
    }
    if (!nullToAbsent || riskiestItem != null) {
      map['riskiest_item'] = Variable<String>(riskiestItem);
    }
    if (!nullToAbsent || scopeCreepFlags != null) {
      map['scope_creep_flags'] = Variable<String>(scopeCreepFlags);
    }
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || sourceConversationId != null) {
      map['source_conversation_id'] = Variable<String>(sourceConversationId);
    }
    return map;
  }

  ProjectStateCompanion toCompanion(bool nullToAbsent) {
    return ProjectStateCompanion(
      id: Value(id),
      projectId: Value(projectId),
      currentStatus: Value(currentStatus),
      unvalidatedAssumptions: unvalidatedAssumptions == null && nullToAbsent
          ? const Value.absent()
          : Value(unvalidatedAssumptions),
      riskiestItem: riskiestItem == null && nullToAbsent
          ? const Value.absent()
          : Value(riskiestItem),
      scopeCreepFlags: scopeCreepFlags == null && nullToAbsent
          ? const Value.absent()
          : Value(scopeCreepFlags),
      updatedAt: Value(updatedAt),
      sourceConversationId: sourceConversationId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceConversationId),
    );
  }

  factory ProjectStateData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProjectStateData(
      id: serializer.fromJson<int>(json['id']),
      projectId: serializer.fromJson<String>(json['project_id']),
      currentStatus: serializer.fromJson<String>(json['current_status']),
      unvalidatedAssumptions: serializer.fromJson<String?>(
        json['unvalidated_assumptions'],
      ),
      riskiestItem: serializer.fromJson<String?>(json['riskiest_item']),
      scopeCreepFlags: serializer.fromJson<String?>(json['scope_creep_flags']),
      updatedAt: serializer.fromJson<int>(json['updated_at']),
      sourceConversationId: serializer.fromJson<String?>(
        json['source_conversation_id'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'project_id': serializer.toJson<String>(projectId),
      'current_status': serializer.toJson<String>(currentStatus),
      'unvalidated_assumptions': serializer.toJson<String?>(
        unvalidatedAssumptions,
      ),
      'riskiest_item': serializer.toJson<String?>(riskiestItem),
      'scope_creep_flags': serializer.toJson<String?>(scopeCreepFlags),
      'updated_at': serializer.toJson<int>(updatedAt),
      'source_conversation_id': serializer.toJson<String?>(
        sourceConversationId,
      ),
    };
  }

  ProjectStateData copyWith({
    int? id,
    String? projectId,
    String? currentStatus,
    Value<String?> unvalidatedAssumptions = const Value.absent(),
    Value<String?> riskiestItem = const Value.absent(),
    Value<String?> scopeCreepFlags = const Value.absent(),
    int? updatedAt,
    Value<String?> sourceConversationId = const Value.absent(),
  }) => ProjectStateData(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    currentStatus: currentStatus ?? this.currentStatus,
    unvalidatedAssumptions: unvalidatedAssumptions.present
        ? unvalidatedAssumptions.value
        : this.unvalidatedAssumptions,
    riskiestItem: riskiestItem.present ? riskiestItem.value : this.riskiestItem,
    scopeCreepFlags: scopeCreepFlags.present
        ? scopeCreepFlags.value
        : this.scopeCreepFlags,
    updatedAt: updatedAt ?? this.updatedAt,
    sourceConversationId: sourceConversationId.present
        ? sourceConversationId.value
        : this.sourceConversationId,
  );
  ProjectStateData copyWithCompanion(ProjectStateCompanion data) {
    return ProjectStateData(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      currentStatus: data.currentStatus.present
          ? data.currentStatus.value
          : this.currentStatus,
      unvalidatedAssumptions: data.unvalidatedAssumptions.present
          ? data.unvalidatedAssumptions.value
          : this.unvalidatedAssumptions,
      riskiestItem: data.riskiestItem.present
          ? data.riskiestItem.value
          : this.riskiestItem,
      scopeCreepFlags: data.scopeCreepFlags.present
          ? data.scopeCreepFlags.value
          : this.scopeCreepFlags,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      sourceConversationId: data.sourceConversationId.present
          ? data.sourceConversationId.value
          : this.sourceConversationId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProjectStateData(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('currentStatus: $currentStatus, ')
          ..write('unvalidatedAssumptions: $unvalidatedAssumptions, ')
          ..write('riskiestItem: $riskiestItem, ')
          ..write('scopeCreepFlags: $scopeCreepFlags, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('sourceConversationId: $sourceConversationId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    projectId,
    currentStatus,
    unvalidatedAssumptions,
    riskiestItem,
    scopeCreepFlags,
    updatedAt,
    sourceConversationId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProjectStateData &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.currentStatus == this.currentStatus &&
          other.unvalidatedAssumptions == this.unvalidatedAssumptions &&
          other.riskiestItem == this.riskiestItem &&
          other.scopeCreepFlags == this.scopeCreepFlags &&
          other.updatedAt == this.updatedAt &&
          other.sourceConversationId == this.sourceConversationId);
}

class ProjectStateCompanion extends UpdateCompanion<ProjectStateData> {
  final Value<int> id;
  final Value<String> projectId;
  final Value<String> currentStatus;
  final Value<String?> unvalidatedAssumptions;
  final Value<String?> riskiestItem;
  final Value<String?> scopeCreepFlags;
  final Value<int> updatedAt;
  final Value<String?> sourceConversationId;
  const ProjectStateCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.currentStatus = const Value.absent(),
    this.unvalidatedAssumptions = const Value.absent(),
    this.riskiestItem = const Value.absent(),
    this.scopeCreepFlags = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.sourceConversationId = const Value.absent(),
  });
  ProjectStateCompanion.insert({
    this.id = const Value.absent(),
    required String projectId,
    required String currentStatus,
    this.unvalidatedAssumptions = const Value.absent(),
    this.riskiestItem = const Value.absent(),
    this.scopeCreepFlags = const Value.absent(),
    required int updatedAt,
    this.sourceConversationId = const Value.absent(),
  }) : projectId = Value(projectId),
       currentStatus = Value(currentStatus),
       updatedAt = Value(updatedAt);
  static Insertable<ProjectStateData> custom({
    Expression<int>? id,
    Expression<String>? projectId,
    Expression<String>? currentStatus,
    Expression<String>? unvalidatedAssumptions,
    Expression<String>? riskiestItem,
    Expression<String>? scopeCreepFlags,
    Expression<int>? updatedAt,
    Expression<String>? sourceConversationId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (currentStatus != null) 'current_status': currentStatus,
      if (unvalidatedAssumptions != null)
        'unvalidated_assumptions': unvalidatedAssumptions,
      if (riskiestItem != null) 'riskiest_item': riskiestItem,
      if (scopeCreepFlags != null) 'scope_creep_flags': scopeCreepFlags,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (sourceConversationId != null)
        'source_conversation_id': sourceConversationId,
    });
  }

  ProjectStateCompanion copyWith({
    Value<int>? id,
    Value<String>? projectId,
    Value<String>? currentStatus,
    Value<String?>? unvalidatedAssumptions,
    Value<String?>? riskiestItem,
    Value<String?>? scopeCreepFlags,
    Value<int>? updatedAt,
    Value<String?>? sourceConversationId,
  }) {
    return ProjectStateCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      currentStatus: currentStatus ?? this.currentStatus,
      unvalidatedAssumptions:
          unvalidatedAssumptions ?? this.unvalidatedAssumptions,
      riskiestItem: riskiestItem ?? this.riskiestItem,
      scopeCreepFlags: scopeCreepFlags ?? this.scopeCreepFlags,
      updatedAt: updatedAt ?? this.updatedAt,
      sourceConversationId: sourceConversationId ?? this.sourceConversationId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (currentStatus.present) {
      map['current_status'] = Variable<String>(currentStatus.value);
    }
    if (unvalidatedAssumptions.present) {
      map['unvalidated_assumptions'] = Variable<String>(
        unvalidatedAssumptions.value,
      );
    }
    if (riskiestItem.present) {
      map['riskiest_item'] = Variable<String>(riskiestItem.value);
    }
    if (scopeCreepFlags.present) {
      map['scope_creep_flags'] = Variable<String>(scopeCreepFlags.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (sourceConversationId.present) {
      map['source_conversation_id'] = Variable<String>(
        sourceConversationId.value,
      );
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectStateCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('currentStatus: $currentStatus, ')
          ..write('unvalidatedAssumptions: $unvalidatedAssumptions, ')
          ..write('riskiestItem: $riskiestItem, ')
          ..write('scopeCreepFlags: $scopeCreepFlags, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('sourceConversationId: $sourceConversationId')
          ..write(')'))
        .toString();
  }
}

class DistilledFacts extends Table
    with TableInfo<DistilledFacts, DistilledFact> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  DistilledFacts(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _conversationIdMeta = const VerificationMeta(
    'conversationId',
  );
  late final GeneratedColumn<String> conversationId = GeneratedColumn<String>(
    'conversation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _factKeyMeta = const VerificationMeta(
    'factKey',
  );
  late final GeneratedColumn<String> factKey = GeneratedColumn<String>(
    'fact_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _factValueMeta = const VerificationMeta(
    'factValue',
  );
  late final GeneratedColumn<String> factValue = GeneratedColumn<String>(
    'fact_value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0.8',
    defaultValue: const CustomExpression('0.8'),
  );
  static const VerificationMeta _distilledAtMeta = const VerificationMeta(
    'distilledAt',
  );
  late final GeneratedColumn<int> distilledAt = GeneratedColumn<int>(
    'distilled_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _sourceMessageRangeMeta =
      const VerificationMeta('sourceMessageRange');
  late final GeneratedColumn<String> sourceMessageRange =
      GeneratedColumn<String>(
        'source_message_range',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    conversationId,
    category,
    factKey,
    factValue,
    confidence,
    distilledAt,
    sourceMessageRange,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'distilled_facts';
  @override
  VerificationContext validateIntegrity(
    Insertable<DistilledFact> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
        _conversationIdMeta,
        conversationId.isAcceptableOrUnknown(
          data['conversation_id']!,
          _conversationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('fact_key')) {
      context.handle(
        _factKeyMeta,
        factKey.isAcceptableOrUnknown(data['fact_key']!, _factKeyMeta),
      );
    }
    if (data.containsKey('fact_value')) {
      context.handle(
        _factValueMeta,
        factValue.isAcceptableOrUnknown(data['fact_value']!, _factValueMeta),
      );
    } else if (isInserting) {
      context.missing(_factValueMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    if (data.containsKey('distilled_at')) {
      context.handle(
        _distilledAtMeta,
        distilledAt.isAcceptableOrUnknown(
          data['distilled_at']!,
          _distilledAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_distilledAtMeta);
    }
    if (data.containsKey('source_message_range')) {
      context.handle(
        _sourceMessageRangeMeta,
        sourceMessageRange.isAcceptableOrUnknown(
          data['source_message_range']!,
          _sourceMessageRangeMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DistilledFact map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DistilledFact(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      conversationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conversation_id'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      factKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fact_key'],
      ),
      factValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fact_value'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      )!,
      distilledAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}distilled_at'],
      )!,
      sourceMessageRange: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_message_range'],
      ),
    );
  }

  @override
  DistilledFacts createAlias(String alias) {
    return DistilledFacts(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class DistilledFact extends DataClass implements Insertable<DistilledFact> {
  final String id;
  final String conversationId;
  final String category;
  final String? factKey;
  final String factValue;
  final double confidence;
  final int distilledAt;
  final String? sourceMessageRange;
  const DistilledFact({
    required this.id,
    required this.conversationId,
    required this.category,
    this.factKey,
    required this.factValue,
    required this.confidence,
    required this.distilledAt,
    this.sourceMessageRange,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['conversation_id'] = Variable<String>(conversationId);
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || factKey != null) {
      map['fact_key'] = Variable<String>(factKey);
    }
    map['fact_value'] = Variable<String>(factValue);
    map['confidence'] = Variable<double>(confidence);
    map['distilled_at'] = Variable<int>(distilledAt);
    if (!nullToAbsent || sourceMessageRange != null) {
      map['source_message_range'] = Variable<String>(sourceMessageRange);
    }
    return map;
  }

  DistilledFactsCompanion toCompanion(bool nullToAbsent) {
    return DistilledFactsCompanion(
      id: Value(id),
      conversationId: Value(conversationId),
      category: Value(category),
      factKey: factKey == null && nullToAbsent
          ? const Value.absent()
          : Value(factKey),
      factValue: Value(factValue),
      confidence: Value(confidence),
      distilledAt: Value(distilledAt),
      sourceMessageRange: sourceMessageRange == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceMessageRange),
    );
  }

  factory DistilledFact.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DistilledFact(
      id: serializer.fromJson<String>(json['id']),
      conversationId: serializer.fromJson<String>(json['conversation_id']),
      category: serializer.fromJson<String>(json['category']),
      factKey: serializer.fromJson<String?>(json['fact_key']),
      factValue: serializer.fromJson<String>(json['fact_value']),
      confidence: serializer.fromJson<double>(json['confidence']),
      distilledAt: serializer.fromJson<int>(json['distilled_at']),
      sourceMessageRange: serializer.fromJson<String?>(
        json['source_message_range'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'conversation_id': serializer.toJson<String>(conversationId),
      'category': serializer.toJson<String>(category),
      'fact_key': serializer.toJson<String?>(factKey),
      'fact_value': serializer.toJson<String>(factValue),
      'confidence': serializer.toJson<double>(confidence),
      'distilled_at': serializer.toJson<int>(distilledAt),
      'source_message_range': serializer.toJson<String?>(sourceMessageRange),
    };
  }

  DistilledFact copyWith({
    String? id,
    String? conversationId,
    String? category,
    Value<String?> factKey = const Value.absent(),
    String? factValue,
    double? confidence,
    int? distilledAt,
    Value<String?> sourceMessageRange = const Value.absent(),
  }) => DistilledFact(
    id: id ?? this.id,
    conversationId: conversationId ?? this.conversationId,
    category: category ?? this.category,
    factKey: factKey.present ? factKey.value : this.factKey,
    factValue: factValue ?? this.factValue,
    confidence: confidence ?? this.confidence,
    distilledAt: distilledAt ?? this.distilledAt,
    sourceMessageRange: sourceMessageRange.present
        ? sourceMessageRange.value
        : this.sourceMessageRange,
  );
  DistilledFact copyWithCompanion(DistilledFactsCompanion data) {
    return DistilledFact(
      id: data.id.present ? data.id.value : this.id,
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      category: data.category.present ? data.category.value : this.category,
      factKey: data.factKey.present ? data.factKey.value : this.factKey,
      factValue: data.factValue.present ? data.factValue.value : this.factValue,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      distilledAt: data.distilledAt.present
          ? data.distilledAt.value
          : this.distilledAt,
      sourceMessageRange: data.sourceMessageRange.present
          ? data.sourceMessageRange.value
          : this.sourceMessageRange,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DistilledFact(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('category: $category, ')
          ..write('factKey: $factKey, ')
          ..write('factValue: $factValue, ')
          ..write('confidence: $confidence, ')
          ..write('distilledAt: $distilledAt, ')
          ..write('sourceMessageRange: $sourceMessageRange')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    conversationId,
    category,
    factKey,
    factValue,
    confidence,
    distilledAt,
    sourceMessageRange,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DistilledFact &&
          other.id == this.id &&
          other.conversationId == this.conversationId &&
          other.category == this.category &&
          other.factKey == this.factKey &&
          other.factValue == this.factValue &&
          other.confidence == this.confidence &&
          other.distilledAt == this.distilledAt &&
          other.sourceMessageRange == this.sourceMessageRange);
}

class DistilledFactsCompanion extends UpdateCompanion<DistilledFact> {
  final Value<String> id;
  final Value<String> conversationId;
  final Value<String> category;
  final Value<String?> factKey;
  final Value<String> factValue;
  final Value<double> confidence;
  final Value<int> distilledAt;
  final Value<String?> sourceMessageRange;
  final Value<int> rowid;
  const DistilledFactsCompanion({
    this.id = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.category = const Value.absent(),
    this.factKey = const Value.absent(),
    this.factValue = const Value.absent(),
    this.confidence = const Value.absent(),
    this.distilledAt = const Value.absent(),
    this.sourceMessageRange = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DistilledFactsCompanion.insert({
    required String id,
    required String conversationId,
    required String category,
    this.factKey = const Value.absent(),
    required String factValue,
    this.confidence = const Value.absent(),
    required int distilledAt,
    this.sourceMessageRange = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       conversationId = Value(conversationId),
       category = Value(category),
       factValue = Value(factValue),
       distilledAt = Value(distilledAt);
  static Insertable<DistilledFact> custom({
    Expression<String>? id,
    Expression<String>? conversationId,
    Expression<String>? category,
    Expression<String>? factKey,
    Expression<String>? factValue,
    Expression<double>? confidence,
    Expression<int>? distilledAt,
    Expression<String>? sourceMessageRange,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (conversationId != null) 'conversation_id': conversationId,
      if (category != null) 'category': category,
      if (factKey != null) 'fact_key': factKey,
      if (factValue != null) 'fact_value': factValue,
      if (confidence != null) 'confidence': confidence,
      if (distilledAt != null) 'distilled_at': distilledAt,
      if (sourceMessageRange != null)
        'source_message_range': sourceMessageRange,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DistilledFactsCompanion copyWith({
    Value<String>? id,
    Value<String>? conversationId,
    Value<String>? category,
    Value<String?>? factKey,
    Value<String>? factValue,
    Value<double>? confidence,
    Value<int>? distilledAt,
    Value<String?>? sourceMessageRange,
    Value<int>? rowid,
  }) {
    return DistilledFactsCompanion(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      category: category ?? this.category,
      factKey: factKey ?? this.factKey,
      factValue: factValue ?? this.factValue,
      confidence: confidence ?? this.confidence,
      distilledAt: distilledAt ?? this.distilledAt,
      sourceMessageRange: sourceMessageRange ?? this.sourceMessageRange,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<String>(conversationId.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (factKey.present) {
      map['fact_key'] = Variable<String>(factKey.value);
    }
    if (factValue.present) {
      map['fact_value'] = Variable<String>(factValue.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (distilledAt.present) {
      map['distilled_at'] = Variable<int>(distilledAt.value);
    }
    if (sourceMessageRange.present) {
      map['source_message_range'] = Variable<String>(sourceMessageRange.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DistilledFactsCompanion(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('category: $category, ')
          ..write('factKey: $factKey, ')
          ..write('factValue: $factValue, ')
          ..write('confidence: $confidence, ')
          ..write('distilledAt: $distilledAt, ')
          ..write('sourceMessageRange: $sourceMessageRange, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class MoodStates extends Table with TableInfo<MoodStates, MoodState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  MoodStates(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _energyMeta = const VerificationMeta('energy');
  late final GeneratedColumn<int> energy = GeneratedColumn<int>(
    'energy',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _emotionMeta = const VerificationMeta(
    'emotion',
  );
  late final GeneratedColumn<String> emotion = GeneratedColumn<String>(
    'emotion',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _intentMeta = const VerificationMeta('intent');
  late final GeneratedColumn<String> intent = GeneratedColumn<String>(
    'intent',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _analyzedAtMeta = const VerificationMeta(
    'analyzedAt',
  );
  late final GeneratedColumn<int> analyzedAt = GeneratedColumn<int>(
    'analyzed_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _messageCountMeta = const VerificationMeta(
    'messageCount',
  );
  late final GeneratedColumn<int> messageCount = GeneratedColumn<int>(
    'message_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    energy,
    emotion,
    intent,
    analyzedAt,
    messageCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'mood_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<MoodState> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('energy')) {
      context.handle(
        _energyMeta,
        energy.isAcceptableOrUnknown(data['energy']!, _energyMeta),
      );
    } else if (isInserting) {
      context.missing(_energyMeta);
    }
    if (data.containsKey('emotion')) {
      context.handle(
        _emotionMeta,
        emotion.isAcceptableOrUnknown(data['emotion']!, _emotionMeta),
      );
    } else if (isInserting) {
      context.missing(_emotionMeta);
    }
    if (data.containsKey('intent')) {
      context.handle(
        _intentMeta,
        intent.isAcceptableOrUnknown(data['intent']!, _intentMeta),
      );
    } else if (isInserting) {
      context.missing(_intentMeta);
    }
    if (data.containsKey('analyzed_at')) {
      context.handle(
        _analyzedAtMeta,
        analyzedAt.isAcceptableOrUnknown(data['analyzed_at']!, _analyzedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_analyzedAtMeta);
    }
    if (data.containsKey('message_count')) {
      context.handle(
        _messageCountMeta,
        messageCount.isAcceptableOrUnknown(
          data['message_count']!,
          _messageCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_messageCountMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MoodState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MoodState(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      energy: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}energy'],
      )!,
      emotion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emotion'],
      )!,
      intent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}intent'],
      )!,
      analyzedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}analyzed_at'],
      )!,
      messageCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}message_count'],
      )!,
    );
  }

  @override
  MoodStates createAlias(String alias) {
    return MoodStates(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class MoodState extends DataClass implements Insertable<MoodState> {
  final String id;
  final String sessionId;
  final int energy;
  final String emotion;
  final String intent;
  final int analyzedAt;
  final int messageCount;
  const MoodState({
    required this.id,
    required this.sessionId,
    required this.energy,
    required this.emotion,
    required this.intent,
    required this.analyzedAt,
    required this.messageCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['energy'] = Variable<int>(energy);
    map['emotion'] = Variable<String>(emotion);
    map['intent'] = Variable<String>(intent);
    map['analyzed_at'] = Variable<int>(analyzedAt);
    map['message_count'] = Variable<int>(messageCount);
    return map;
  }

  MoodStatesCompanion toCompanion(bool nullToAbsent) {
    return MoodStatesCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      energy: Value(energy),
      emotion: Value(emotion),
      intent: Value(intent),
      analyzedAt: Value(analyzedAt),
      messageCount: Value(messageCount),
    );
  }

  factory MoodState.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MoodState(
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['session_id']),
      energy: serializer.fromJson<int>(json['energy']),
      emotion: serializer.fromJson<String>(json['emotion']),
      intent: serializer.fromJson<String>(json['intent']),
      analyzedAt: serializer.fromJson<int>(json['analyzed_at']),
      messageCount: serializer.fromJson<int>(json['message_count']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'session_id': serializer.toJson<String>(sessionId),
      'energy': serializer.toJson<int>(energy),
      'emotion': serializer.toJson<String>(emotion),
      'intent': serializer.toJson<String>(intent),
      'analyzed_at': serializer.toJson<int>(analyzedAt),
      'message_count': serializer.toJson<int>(messageCount),
    };
  }

  MoodState copyWith({
    String? id,
    String? sessionId,
    int? energy,
    String? emotion,
    String? intent,
    int? analyzedAt,
    int? messageCount,
  }) => MoodState(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    energy: energy ?? this.energy,
    emotion: emotion ?? this.emotion,
    intent: intent ?? this.intent,
    analyzedAt: analyzedAt ?? this.analyzedAt,
    messageCount: messageCount ?? this.messageCount,
  );
  MoodState copyWithCompanion(MoodStatesCompanion data) {
    return MoodState(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      energy: data.energy.present ? data.energy.value : this.energy,
      emotion: data.emotion.present ? data.emotion.value : this.emotion,
      intent: data.intent.present ? data.intent.value : this.intent,
      analyzedAt: data.analyzedAt.present
          ? data.analyzedAt.value
          : this.analyzedAt,
      messageCount: data.messageCount.present
          ? data.messageCount.value
          : this.messageCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MoodState(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('energy: $energy, ')
          ..write('emotion: $emotion, ')
          ..write('intent: $intent, ')
          ..write('analyzedAt: $analyzedAt, ')
          ..write('messageCount: $messageCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    energy,
    emotion,
    intent,
    analyzedAt,
    messageCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MoodState &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.energy == this.energy &&
          other.emotion == this.emotion &&
          other.intent == this.intent &&
          other.analyzedAt == this.analyzedAt &&
          other.messageCount == this.messageCount);
}

class MoodStatesCompanion extends UpdateCompanion<MoodState> {
  final Value<String> id;
  final Value<String> sessionId;
  final Value<int> energy;
  final Value<String> emotion;
  final Value<String> intent;
  final Value<int> analyzedAt;
  final Value<int> messageCount;
  final Value<int> rowid;
  const MoodStatesCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.energy = const Value.absent(),
    this.emotion = const Value.absent(),
    this.intent = const Value.absent(),
    this.analyzedAt = const Value.absent(),
    this.messageCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MoodStatesCompanion.insert({
    required String id,
    required String sessionId,
    required int energy,
    required String emotion,
    required String intent,
    required int analyzedAt,
    required int messageCount,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       energy = Value(energy),
       emotion = Value(emotion),
       intent = Value(intent),
       analyzedAt = Value(analyzedAt),
       messageCount = Value(messageCount);
  static Insertable<MoodState> custom({
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<int>? energy,
    Expression<String>? emotion,
    Expression<String>? intent,
    Expression<int>? analyzedAt,
    Expression<int>? messageCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (energy != null) 'energy': energy,
      if (emotion != null) 'emotion': emotion,
      if (intent != null) 'intent': intent,
      if (analyzedAt != null) 'analyzed_at': analyzedAt,
      if (messageCount != null) 'message_count': messageCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MoodStatesCompanion copyWith({
    Value<String>? id,
    Value<String>? sessionId,
    Value<int>? energy,
    Value<String>? emotion,
    Value<String>? intent,
    Value<int>? analyzedAt,
    Value<int>? messageCount,
    Value<int>? rowid,
  }) {
    return MoodStatesCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      energy: energy ?? this.energy,
      emotion: emotion ?? this.emotion,
      intent: intent ?? this.intent,
      analyzedAt: analyzedAt ?? this.analyzedAt,
      messageCount: messageCount ?? this.messageCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (energy.present) {
      map['energy'] = Variable<int>(energy.value);
    }
    if (emotion.present) {
      map['emotion'] = Variable<String>(emotion.value);
    }
    if (intent.present) {
      map['intent'] = Variable<String>(intent.value);
    }
    if (analyzedAt.present) {
      map['analyzed_at'] = Variable<int>(analyzedAt.value);
    }
    if (messageCount.present) {
      map['message_count'] = Variable<int>(messageCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MoodStatesCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('energy: $energy, ')
          ..write('emotion: $emotion, ')
          ..write('intent: $intent, ')
          ..write('analyzedAt: $analyzedAt, ')
          ..write('messageCount: $messageCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class AuditLog extends Table with TableInfo<AuditLog, AuditLogData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  AuditLog(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT',
  );
  static const VerificationMeta _actionTypeMeta = const VerificationMeta(
    'actionType',
  );
  late final GeneratedColumn<String> actionType = GeneratedColumn<String>(
    'action_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _toolNameMeta = const VerificationMeta(
    'toolName',
  );
  late final GeneratedColumn<String> toolName = GeneratedColumn<String>(
    'tool_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _tierMeta = const VerificationMeta('tier');
  late final GeneratedColumn<int> tier = GeneratedColumn<int>(
    'tier',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _reasoningMeta = const VerificationMeta(
    'reasoning',
  );
  late final GeneratedColumn<String> reasoning = GeneratedColumn<String>(
    'reasoning',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _resultMeta = const VerificationMeta('result');
  late final GeneratedColumn<String> result = GeneratedColumn<String>(
    'result',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _executedAtMeta = const VerificationMeta(
    'executedAt',
  );
  late final GeneratedColumn<int> executedAt = GeneratedColumn<int>(
    'executed_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _vesselTypeMeta = const VerificationMeta(
    'vesselType',
  );
  late final GeneratedColumn<String> vesselType = GeneratedColumn<String>(
    'vessel_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    actionType,
    toolName,
    tier,
    reasoning,
    result,
    executedAt,
    sessionId,
    vesselType,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'audit_log';
  @override
  VerificationContext validateIntegrity(
    Insertable<AuditLogData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('action_type')) {
      context.handle(
        _actionTypeMeta,
        actionType.isAcceptableOrUnknown(data['action_type']!, _actionTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_actionTypeMeta);
    }
    if (data.containsKey('tool_name')) {
      context.handle(
        _toolNameMeta,
        toolName.isAcceptableOrUnknown(data['tool_name']!, _toolNameMeta),
      );
    } else if (isInserting) {
      context.missing(_toolNameMeta);
    }
    if (data.containsKey('tier')) {
      context.handle(
        _tierMeta,
        tier.isAcceptableOrUnknown(data['tier']!, _tierMeta),
      );
    } else if (isInserting) {
      context.missing(_tierMeta);
    }
    if (data.containsKey('reasoning')) {
      context.handle(
        _reasoningMeta,
        reasoning.isAcceptableOrUnknown(data['reasoning']!, _reasoningMeta),
      );
    }
    if (data.containsKey('result')) {
      context.handle(
        _resultMeta,
        result.isAcceptableOrUnknown(data['result']!, _resultMeta),
      );
    }
    if (data.containsKey('executed_at')) {
      context.handle(
        _executedAtMeta,
        executedAt.isAcceptableOrUnknown(data['executed_at']!, _executedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_executedAtMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    }
    if (data.containsKey('vessel_type')) {
      context.handle(
        _vesselTypeMeta,
        vesselType.isAcceptableOrUnknown(data['vessel_type']!, _vesselTypeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AuditLogData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AuditLogData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      actionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action_type'],
      )!,
      toolName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tool_name'],
      )!,
      tier: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tier'],
      )!,
      reasoning: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reasoning'],
      ),
      result: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}result'],
      ),
      executedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}executed_at'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      ),
      vesselType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vessel_type'],
      ),
    );
  }

  @override
  AuditLog createAlias(String alias) {
    return AuditLog(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class AuditLogData extends DataClass implements Insertable<AuditLogData> {
  final int id;
  final String actionType;
  final String toolName;
  final int tier;
  final String? reasoning;
  final String? result;
  final int executedAt;
  final String? sessionId;
  final String? vesselType;
  const AuditLogData({
    required this.id,
    required this.actionType,
    required this.toolName,
    required this.tier,
    this.reasoning,
    this.result,
    required this.executedAt,
    this.sessionId,
    this.vesselType,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['action_type'] = Variable<String>(actionType);
    map['tool_name'] = Variable<String>(toolName);
    map['tier'] = Variable<int>(tier);
    if (!nullToAbsent || reasoning != null) {
      map['reasoning'] = Variable<String>(reasoning);
    }
    if (!nullToAbsent || result != null) {
      map['result'] = Variable<String>(result);
    }
    map['executed_at'] = Variable<int>(executedAt);
    if (!nullToAbsent || sessionId != null) {
      map['session_id'] = Variable<String>(sessionId);
    }
    if (!nullToAbsent || vesselType != null) {
      map['vessel_type'] = Variable<String>(vesselType);
    }
    return map;
  }

  AuditLogCompanion toCompanion(bool nullToAbsent) {
    return AuditLogCompanion(
      id: Value(id),
      actionType: Value(actionType),
      toolName: Value(toolName),
      tier: Value(tier),
      reasoning: reasoning == null && nullToAbsent
          ? const Value.absent()
          : Value(reasoning),
      result: result == null && nullToAbsent
          ? const Value.absent()
          : Value(result),
      executedAt: Value(executedAt),
      sessionId: sessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionId),
      vesselType: vesselType == null && nullToAbsent
          ? const Value.absent()
          : Value(vesselType),
    );
  }

  factory AuditLogData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AuditLogData(
      id: serializer.fromJson<int>(json['id']),
      actionType: serializer.fromJson<String>(json['action_type']),
      toolName: serializer.fromJson<String>(json['tool_name']),
      tier: serializer.fromJson<int>(json['tier']),
      reasoning: serializer.fromJson<String?>(json['reasoning']),
      result: serializer.fromJson<String?>(json['result']),
      executedAt: serializer.fromJson<int>(json['executed_at']),
      sessionId: serializer.fromJson<String?>(json['session_id']),
      vesselType: serializer.fromJson<String?>(json['vessel_type']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'action_type': serializer.toJson<String>(actionType),
      'tool_name': serializer.toJson<String>(toolName),
      'tier': serializer.toJson<int>(tier),
      'reasoning': serializer.toJson<String?>(reasoning),
      'result': serializer.toJson<String?>(result),
      'executed_at': serializer.toJson<int>(executedAt),
      'session_id': serializer.toJson<String?>(sessionId),
      'vessel_type': serializer.toJson<String?>(vesselType),
    };
  }

  AuditLogData copyWith({
    int? id,
    String? actionType,
    String? toolName,
    int? tier,
    Value<String?> reasoning = const Value.absent(),
    Value<String?> result = const Value.absent(),
    int? executedAt,
    Value<String?> sessionId = const Value.absent(),
    Value<String?> vesselType = const Value.absent(),
  }) => AuditLogData(
    id: id ?? this.id,
    actionType: actionType ?? this.actionType,
    toolName: toolName ?? this.toolName,
    tier: tier ?? this.tier,
    reasoning: reasoning.present ? reasoning.value : this.reasoning,
    result: result.present ? result.value : this.result,
    executedAt: executedAt ?? this.executedAt,
    sessionId: sessionId.present ? sessionId.value : this.sessionId,
    vesselType: vesselType.present ? vesselType.value : this.vesselType,
  );
  AuditLogData copyWithCompanion(AuditLogCompanion data) {
    return AuditLogData(
      id: data.id.present ? data.id.value : this.id,
      actionType: data.actionType.present
          ? data.actionType.value
          : this.actionType,
      toolName: data.toolName.present ? data.toolName.value : this.toolName,
      tier: data.tier.present ? data.tier.value : this.tier,
      reasoning: data.reasoning.present ? data.reasoning.value : this.reasoning,
      result: data.result.present ? data.result.value : this.result,
      executedAt: data.executedAt.present
          ? data.executedAt.value
          : this.executedAt,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      vesselType: data.vesselType.present
          ? data.vesselType.value
          : this.vesselType,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AuditLogData(')
          ..write('id: $id, ')
          ..write('actionType: $actionType, ')
          ..write('toolName: $toolName, ')
          ..write('tier: $tier, ')
          ..write('reasoning: $reasoning, ')
          ..write('result: $result, ')
          ..write('executedAt: $executedAt, ')
          ..write('sessionId: $sessionId, ')
          ..write('vesselType: $vesselType')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    actionType,
    toolName,
    tier,
    reasoning,
    result,
    executedAt,
    sessionId,
    vesselType,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AuditLogData &&
          other.id == this.id &&
          other.actionType == this.actionType &&
          other.toolName == this.toolName &&
          other.tier == this.tier &&
          other.reasoning == this.reasoning &&
          other.result == this.result &&
          other.executedAt == this.executedAt &&
          other.sessionId == this.sessionId &&
          other.vesselType == this.vesselType);
}

class AuditLogCompanion extends UpdateCompanion<AuditLogData> {
  final Value<int> id;
  final Value<String> actionType;
  final Value<String> toolName;
  final Value<int> tier;
  final Value<String?> reasoning;
  final Value<String?> result;
  final Value<int> executedAt;
  final Value<String?> sessionId;
  final Value<String?> vesselType;
  const AuditLogCompanion({
    this.id = const Value.absent(),
    this.actionType = const Value.absent(),
    this.toolName = const Value.absent(),
    this.tier = const Value.absent(),
    this.reasoning = const Value.absent(),
    this.result = const Value.absent(),
    this.executedAt = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.vesselType = const Value.absent(),
  });
  AuditLogCompanion.insert({
    this.id = const Value.absent(),
    required String actionType,
    required String toolName,
    required int tier,
    this.reasoning = const Value.absent(),
    this.result = const Value.absent(),
    required int executedAt,
    this.sessionId = const Value.absent(),
    this.vesselType = const Value.absent(),
  }) : actionType = Value(actionType),
       toolName = Value(toolName),
       tier = Value(tier),
       executedAt = Value(executedAt);
  static Insertable<AuditLogData> custom({
    Expression<int>? id,
    Expression<String>? actionType,
    Expression<String>? toolName,
    Expression<int>? tier,
    Expression<String>? reasoning,
    Expression<String>? result,
    Expression<int>? executedAt,
    Expression<String>? sessionId,
    Expression<String>? vesselType,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (actionType != null) 'action_type': actionType,
      if (toolName != null) 'tool_name': toolName,
      if (tier != null) 'tier': tier,
      if (reasoning != null) 'reasoning': reasoning,
      if (result != null) 'result': result,
      if (executedAt != null) 'executed_at': executedAt,
      if (sessionId != null) 'session_id': sessionId,
      if (vesselType != null) 'vessel_type': vesselType,
    });
  }

  AuditLogCompanion copyWith({
    Value<int>? id,
    Value<String>? actionType,
    Value<String>? toolName,
    Value<int>? tier,
    Value<String?>? reasoning,
    Value<String?>? result,
    Value<int>? executedAt,
    Value<String?>? sessionId,
    Value<String?>? vesselType,
  }) {
    return AuditLogCompanion(
      id: id ?? this.id,
      actionType: actionType ?? this.actionType,
      toolName: toolName ?? this.toolName,
      tier: tier ?? this.tier,
      reasoning: reasoning ?? this.reasoning,
      result: result ?? this.result,
      executedAt: executedAt ?? this.executedAt,
      sessionId: sessionId ?? this.sessionId,
      vesselType: vesselType ?? this.vesselType,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (actionType.present) {
      map['action_type'] = Variable<String>(actionType.value);
    }
    if (toolName.present) {
      map['tool_name'] = Variable<String>(toolName.value);
    }
    if (tier.present) {
      map['tier'] = Variable<int>(tier.value);
    }
    if (reasoning.present) {
      map['reasoning'] = Variable<String>(reasoning.value);
    }
    if (result.present) {
      map['result'] = Variable<String>(result.value);
    }
    if (executedAt.present) {
      map['executed_at'] = Variable<int>(executedAt.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (vesselType.present) {
      map['vessel_type'] = Variable<String>(vesselType.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AuditLogCompanion(')
          ..write('id: $id, ')
          ..write('actionType: $actionType, ')
          ..write('toolName: $toolName, ')
          ..write('tier: $tier, ')
          ..write('reasoning: $reasoning, ')
          ..write('result: $result, ')
          ..write('executedAt: $executedAt, ')
          ..write('sessionId: $sessionId, ')
          ..write('vesselType: $vesselType')
          ..write(')'))
        .toString();
  }
}

class InterventionStates extends Table
    with TableInfo<InterventionStates, InterventionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  InterventionStates(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _levelMeta = const VerificationMeta('level');
  late final GeneratedColumn<String> level = GeneratedColumn<String>(
    'level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _triggerDescriptionMeta =
      const VerificationMeta('triggerDescription');
  late final GeneratedColumn<String> triggerDescription =
      GeneratedColumn<String>(
        'trigger_description',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
        $customConstraints: 'NOT NULL',
      );
  static const VerificationMeta _proposedDefaultMeta = const VerificationMeta(
    'proposedDefault',
  );
  late final GeneratedColumn<String> proposedDefault = GeneratedColumn<String>(
    'proposed_default',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _proposalDeadlineAtMeta =
      const VerificationMeta('proposalDeadlineAt');
  late final GeneratedColumn<int> proposalDeadlineAt = GeneratedColumn<int>(
    'proposal_deadline_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _detectedAtMeta = const VerificationMeta(
    'detectedAt',
  );
  late final GeneratedColumn<int> detectedAt = GeneratedColumn<int>(
    'detected_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _level1SentAtMeta = const VerificationMeta(
    'level1SentAt',
  );
  late final GeneratedColumn<int> level1SentAt = GeneratedColumn<int>(
    'level1_sent_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _level2SentAtMeta = const VerificationMeta(
    'level2SentAt',
  );
  late final GeneratedColumn<int> level2SentAt = GeneratedColumn<int>(
    'level2_sent_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _level3SentAtMeta = const VerificationMeta(
    'level3SentAt',
  );
  late final GeneratedColumn<int> level3SentAt = GeneratedColumn<int>(
    'level3_sent_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _resolvedAtMeta = const VerificationMeta(
    'resolvedAt',
  );
  late final GeneratedColumn<int> resolvedAt = GeneratedColumn<int>(
    'resolved_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _relatedEntityIdMeta = const VerificationMeta(
    'relatedEntityId',
  );
  late final GeneratedColumn<String> relatedEntityId = GeneratedColumn<String>(
    'related_entity_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    level,
    triggerDescription,
    proposedDefault,
    proposalDeadlineAt,
    detectedAt,
    level1SentAt,
    level2SentAt,
    level3SentAt,
    resolvedAt,
    relatedEntityId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'intervention_states';
  @override
  VerificationContext validateIntegrity(
    Insertable<InterventionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('level')) {
      context.handle(
        _levelMeta,
        level.isAcceptableOrUnknown(data['level']!, _levelMeta),
      );
    } else if (isInserting) {
      context.missing(_levelMeta);
    }
    if (data.containsKey('trigger_description')) {
      context.handle(
        _triggerDescriptionMeta,
        triggerDescription.isAcceptableOrUnknown(
          data['trigger_description']!,
          _triggerDescriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_triggerDescriptionMeta);
    }
    if (data.containsKey('proposed_default')) {
      context.handle(
        _proposedDefaultMeta,
        proposedDefault.isAcceptableOrUnknown(
          data['proposed_default']!,
          _proposedDefaultMeta,
        ),
      );
    }
    if (data.containsKey('proposal_deadline_at')) {
      context.handle(
        _proposalDeadlineAtMeta,
        proposalDeadlineAt.isAcceptableOrUnknown(
          data['proposal_deadline_at']!,
          _proposalDeadlineAtMeta,
        ),
      );
    }
    if (data.containsKey('detected_at')) {
      context.handle(
        _detectedAtMeta,
        detectedAt.isAcceptableOrUnknown(data['detected_at']!, _detectedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_detectedAtMeta);
    }
    if (data.containsKey('level1_sent_at')) {
      context.handle(
        _level1SentAtMeta,
        level1SentAt.isAcceptableOrUnknown(
          data['level1_sent_at']!,
          _level1SentAtMeta,
        ),
      );
    }
    if (data.containsKey('level2_sent_at')) {
      context.handle(
        _level2SentAtMeta,
        level2SentAt.isAcceptableOrUnknown(
          data['level2_sent_at']!,
          _level2SentAtMeta,
        ),
      );
    }
    if (data.containsKey('level3_sent_at')) {
      context.handle(
        _level3SentAtMeta,
        level3SentAt.isAcceptableOrUnknown(
          data['level3_sent_at']!,
          _level3SentAtMeta,
        ),
      );
    }
    if (data.containsKey('resolved_at')) {
      context.handle(
        _resolvedAtMeta,
        resolvedAt.isAcceptableOrUnknown(data['resolved_at']!, _resolvedAtMeta),
      );
    }
    if (data.containsKey('related_entity_id')) {
      context.handle(
        _relatedEntityIdMeta,
        relatedEntityId.isAcceptableOrUnknown(
          data['related_entity_id']!,
          _relatedEntityIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InterventionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InterventionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      level: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}level'],
      )!,
      triggerDescription: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trigger_description'],
      )!,
      proposedDefault: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}proposed_default'],
      ),
      proposalDeadlineAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}proposal_deadline_at'],
      ),
      detectedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}detected_at'],
      )!,
      level1SentAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level1_sent_at'],
      ),
      level2SentAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level2_sent_at'],
      ),
      level3SentAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}level3_sent_at'],
      ),
      resolvedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}resolved_at'],
      ),
      relatedEntityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}related_entity_id'],
      ),
    );
  }

  @override
  InterventionStates createAlias(String alias) {
    return InterventionStates(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class InterventionRow extends DataClass implements Insertable<InterventionRow> {
  final String id;
  final String type;
  final String level;
  final String triggerDescription;
  final String? proposedDefault;
  final int? proposalDeadlineAt;
  final int detectedAt;
  final int? level1SentAt;
  final int? level2SentAt;
  final int? level3SentAt;
  final int? resolvedAt;
  final String? relatedEntityId;
  const InterventionRow({
    required this.id,
    required this.type,
    required this.level,
    required this.triggerDescription,
    this.proposedDefault,
    this.proposalDeadlineAt,
    required this.detectedAt,
    this.level1SentAt,
    this.level2SentAt,
    this.level3SentAt,
    this.resolvedAt,
    this.relatedEntityId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    map['level'] = Variable<String>(level);
    map['trigger_description'] = Variable<String>(triggerDescription);
    if (!nullToAbsent || proposedDefault != null) {
      map['proposed_default'] = Variable<String>(proposedDefault);
    }
    if (!nullToAbsent || proposalDeadlineAt != null) {
      map['proposal_deadline_at'] = Variable<int>(proposalDeadlineAt);
    }
    map['detected_at'] = Variable<int>(detectedAt);
    if (!nullToAbsent || level1SentAt != null) {
      map['level1_sent_at'] = Variable<int>(level1SentAt);
    }
    if (!nullToAbsent || level2SentAt != null) {
      map['level2_sent_at'] = Variable<int>(level2SentAt);
    }
    if (!nullToAbsent || level3SentAt != null) {
      map['level3_sent_at'] = Variable<int>(level3SentAt);
    }
    if (!nullToAbsent || resolvedAt != null) {
      map['resolved_at'] = Variable<int>(resolvedAt);
    }
    if (!nullToAbsent || relatedEntityId != null) {
      map['related_entity_id'] = Variable<String>(relatedEntityId);
    }
    return map;
  }

  InterventionStatesCompanion toCompanion(bool nullToAbsent) {
    return InterventionStatesCompanion(
      id: Value(id),
      type: Value(type),
      level: Value(level),
      triggerDescription: Value(triggerDescription),
      proposedDefault: proposedDefault == null && nullToAbsent
          ? const Value.absent()
          : Value(proposedDefault),
      proposalDeadlineAt: proposalDeadlineAt == null && nullToAbsent
          ? const Value.absent()
          : Value(proposalDeadlineAt),
      detectedAt: Value(detectedAt),
      level1SentAt: level1SentAt == null && nullToAbsent
          ? const Value.absent()
          : Value(level1SentAt),
      level2SentAt: level2SentAt == null && nullToAbsent
          ? const Value.absent()
          : Value(level2SentAt),
      level3SentAt: level3SentAt == null && nullToAbsent
          ? const Value.absent()
          : Value(level3SentAt),
      resolvedAt: resolvedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedAt),
      relatedEntityId: relatedEntityId == null && nullToAbsent
          ? const Value.absent()
          : Value(relatedEntityId),
    );
  }

  factory InterventionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InterventionRow(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      level: serializer.fromJson<String>(json['level']),
      triggerDescription: serializer.fromJson<String>(
        json['trigger_description'],
      ),
      proposedDefault: serializer.fromJson<String?>(json['proposed_default']),
      proposalDeadlineAt: serializer.fromJson<int?>(
        json['proposal_deadline_at'],
      ),
      detectedAt: serializer.fromJson<int>(json['detected_at']),
      level1SentAt: serializer.fromJson<int?>(json['level1_sent_at']),
      level2SentAt: serializer.fromJson<int?>(json['level2_sent_at']),
      level3SentAt: serializer.fromJson<int?>(json['level3_sent_at']),
      resolvedAt: serializer.fromJson<int?>(json['resolved_at']),
      relatedEntityId: serializer.fromJson<String?>(json['related_entity_id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'level': serializer.toJson<String>(level),
      'trigger_description': serializer.toJson<String>(triggerDescription),
      'proposed_default': serializer.toJson<String?>(proposedDefault),
      'proposal_deadline_at': serializer.toJson<int?>(proposalDeadlineAt),
      'detected_at': serializer.toJson<int>(detectedAt),
      'level1_sent_at': serializer.toJson<int?>(level1SentAt),
      'level2_sent_at': serializer.toJson<int?>(level2SentAt),
      'level3_sent_at': serializer.toJson<int?>(level3SentAt),
      'resolved_at': serializer.toJson<int?>(resolvedAt),
      'related_entity_id': serializer.toJson<String?>(relatedEntityId),
    };
  }

  InterventionRow copyWith({
    String? id,
    String? type,
    String? level,
    String? triggerDescription,
    Value<String?> proposedDefault = const Value.absent(),
    Value<int?> proposalDeadlineAt = const Value.absent(),
    int? detectedAt,
    Value<int?> level1SentAt = const Value.absent(),
    Value<int?> level2SentAt = const Value.absent(),
    Value<int?> level3SentAt = const Value.absent(),
    Value<int?> resolvedAt = const Value.absent(),
    Value<String?> relatedEntityId = const Value.absent(),
  }) => InterventionRow(
    id: id ?? this.id,
    type: type ?? this.type,
    level: level ?? this.level,
    triggerDescription: triggerDescription ?? this.triggerDescription,
    proposedDefault: proposedDefault.present
        ? proposedDefault.value
        : this.proposedDefault,
    proposalDeadlineAt: proposalDeadlineAt.present
        ? proposalDeadlineAt.value
        : this.proposalDeadlineAt,
    detectedAt: detectedAt ?? this.detectedAt,
    level1SentAt: level1SentAt.present ? level1SentAt.value : this.level1SentAt,
    level2SentAt: level2SentAt.present ? level2SentAt.value : this.level2SentAt,
    level3SentAt: level3SentAt.present ? level3SentAt.value : this.level3SentAt,
    resolvedAt: resolvedAt.present ? resolvedAt.value : this.resolvedAt,
    relatedEntityId: relatedEntityId.present
        ? relatedEntityId.value
        : this.relatedEntityId,
  );
  InterventionRow copyWithCompanion(InterventionStatesCompanion data) {
    return InterventionRow(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      level: data.level.present ? data.level.value : this.level,
      triggerDescription: data.triggerDescription.present
          ? data.triggerDescription.value
          : this.triggerDescription,
      proposedDefault: data.proposedDefault.present
          ? data.proposedDefault.value
          : this.proposedDefault,
      proposalDeadlineAt: data.proposalDeadlineAt.present
          ? data.proposalDeadlineAt.value
          : this.proposalDeadlineAt,
      detectedAt: data.detectedAt.present
          ? data.detectedAt.value
          : this.detectedAt,
      level1SentAt: data.level1SentAt.present
          ? data.level1SentAt.value
          : this.level1SentAt,
      level2SentAt: data.level2SentAt.present
          ? data.level2SentAt.value
          : this.level2SentAt,
      level3SentAt: data.level3SentAt.present
          ? data.level3SentAt.value
          : this.level3SentAt,
      resolvedAt: data.resolvedAt.present
          ? data.resolvedAt.value
          : this.resolvedAt,
      relatedEntityId: data.relatedEntityId.present
          ? data.relatedEntityId.value
          : this.relatedEntityId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InterventionRow(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('level: $level, ')
          ..write('triggerDescription: $triggerDescription, ')
          ..write('proposedDefault: $proposedDefault, ')
          ..write('proposalDeadlineAt: $proposalDeadlineAt, ')
          ..write('detectedAt: $detectedAt, ')
          ..write('level1SentAt: $level1SentAt, ')
          ..write('level2SentAt: $level2SentAt, ')
          ..write('level3SentAt: $level3SentAt, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('relatedEntityId: $relatedEntityId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    level,
    triggerDescription,
    proposedDefault,
    proposalDeadlineAt,
    detectedAt,
    level1SentAt,
    level2SentAt,
    level3SentAt,
    resolvedAt,
    relatedEntityId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InterventionRow &&
          other.id == this.id &&
          other.type == this.type &&
          other.level == this.level &&
          other.triggerDescription == this.triggerDescription &&
          other.proposedDefault == this.proposedDefault &&
          other.proposalDeadlineAt == this.proposalDeadlineAt &&
          other.detectedAt == this.detectedAt &&
          other.level1SentAt == this.level1SentAt &&
          other.level2SentAt == this.level2SentAt &&
          other.level3SentAt == this.level3SentAt &&
          other.resolvedAt == this.resolvedAt &&
          other.relatedEntityId == this.relatedEntityId);
}

class InterventionStatesCompanion extends UpdateCompanion<InterventionRow> {
  final Value<String> id;
  final Value<String> type;
  final Value<String> level;
  final Value<String> triggerDescription;
  final Value<String?> proposedDefault;
  final Value<int?> proposalDeadlineAt;
  final Value<int> detectedAt;
  final Value<int?> level1SentAt;
  final Value<int?> level2SentAt;
  final Value<int?> level3SentAt;
  final Value<int?> resolvedAt;
  final Value<String?> relatedEntityId;
  final Value<int> rowid;
  const InterventionStatesCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.level = const Value.absent(),
    this.triggerDescription = const Value.absent(),
    this.proposedDefault = const Value.absent(),
    this.proposalDeadlineAt = const Value.absent(),
    this.detectedAt = const Value.absent(),
    this.level1SentAt = const Value.absent(),
    this.level2SentAt = const Value.absent(),
    this.level3SentAt = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.relatedEntityId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InterventionStatesCompanion.insert({
    required String id,
    required String type,
    required String level,
    required String triggerDescription,
    this.proposedDefault = const Value.absent(),
    this.proposalDeadlineAt = const Value.absent(),
    required int detectedAt,
    this.level1SentAt = const Value.absent(),
    this.level2SentAt = const Value.absent(),
    this.level3SentAt = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.relatedEntityId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       level = Value(level),
       triggerDescription = Value(triggerDescription),
       detectedAt = Value(detectedAt);
  static Insertable<InterventionRow> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<String>? level,
    Expression<String>? triggerDescription,
    Expression<String>? proposedDefault,
    Expression<int>? proposalDeadlineAt,
    Expression<int>? detectedAt,
    Expression<int>? level1SentAt,
    Expression<int>? level2SentAt,
    Expression<int>? level3SentAt,
    Expression<int>? resolvedAt,
    Expression<String>? relatedEntityId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (level != null) 'level': level,
      if (triggerDescription != null) 'trigger_description': triggerDescription,
      if (proposedDefault != null) 'proposed_default': proposedDefault,
      if (proposalDeadlineAt != null)
        'proposal_deadline_at': proposalDeadlineAt,
      if (detectedAt != null) 'detected_at': detectedAt,
      if (level1SentAt != null) 'level1_sent_at': level1SentAt,
      if (level2SentAt != null) 'level2_sent_at': level2SentAt,
      if (level3SentAt != null) 'level3_sent_at': level3SentAt,
      if (resolvedAt != null) 'resolved_at': resolvedAt,
      if (relatedEntityId != null) 'related_entity_id': relatedEntityId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InterventionStatesCompanion copyWith({
    Value<String>? id,
    Value<String>? type,
    Value<String>? level,
    Value<String>? triggerDescription,
    Value<String?>? proposedDefault,
    Value<int?>? proposalDeadlineAt,
    Value<int>? detectedAt,
    Value<int?>? level1SentAt,
    Value<int?>? level2SentAt,
    Value<int?>? level3SentAt,
    Value<int?>? resolvedAt,
    Value<String?>? relatedEntityId,
    Value<int>? rowid,
  }) {
    return InterventionStatesCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      level: level ?? this.level,
      triggerDescription: triggerDescription ?? this.triggerDescription,
      proposedDefault: proposedDefault ?? this.proposedDefault,
      proposalDeadlineAt: proposalDeadlineAt ?? this.proposalDeadlineAt,
      detectedAt: detectedAt ?? this.detectedAt,
      level1SentAt: level1SentAt ?? this.level1SentAt,
      level2SentAt: level2SentAt ?? this.level2SentAt,
      level3SentAt: level3SentAt ?? this.level3SentAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      relatedEntityId: relatedEntityId ?? this.relatedEntityId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (level.present) {
      map['level'] = Variable<String>(level.value);
    }
    if (triggerDescription.present) {
      map['trigger_description'] = Variable<String>(triggerDescription.value);
    }
    if (proposedDefault.present) {
      map['proposed_default'] = Variable<String>(proposedDefault.value);
    }
    if (proposalDeadlineAt.present) {
      map['proposal_deadline_at'] = Variable<int>(proposalDeadlineAt.value);
    }
    if (detectedAt.present) {
      map['detected_at'] = Variable<int>(detectedAt.value);
    }
    if (level1SentAt.present) {
      map['level1_sent_at'] = Variable<int>(level1SentAt.value);
    }
    if (level2SentAt.present) {
      map['level2_sent_at'] = Variable<int>(level2SentAt.value);
    }
    if (level3SentAt.present) {
      map['level3_sent_at'] = Variable<int>(level3SentAt.value);
    }
    if (resolvedAt.present) {
      map['resolved_at'] = Variable<int>(resolvedAt.value);
    }
    if (relatedEntityId.present) {
      map['related_entity_id'] = Variable<String>(relatedEntityId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InterventionStatesCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('level: $level, ')
          ..write('triggerDescription: $triggerDescription, ')
          ..write('proposedDefault: $proposedDefault, ')
          ..write('proposalDeadlineAt: $proposalDeadlineAt, ')
          ..write('detectedAt: $detectedAt, ')
          ..write('level1SentAt: $level1SentAt, ')
          ..write('level2SentAt: $level2SentAt, ')
          ..write('level3SentAt: $level3SentAt, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('relatedEntityId: $relatedEntityId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class ApiUsage extends Table with TableInfo<ApiUsage, ApiUsageData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ApiUsage(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT',
  );
  static const VerificationMeta _conversationIdMeta = const VerificationMeta(
    'conversationId',
  );
  late final GeneratedColumn<int> conversationId = GeneratedColumn<int>(
    'conversation_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _inputTokensMeta = const VerificationMeta(
    'inputTokens',
  );
  late final GeneratedColumn<int> inputTokens = GeneratedColumn<int>(
    'input_tokens',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _outputTokensMeta = const VerificationMeta(
    'outputTokens',
  );
  late final GeneratedColumn<int> outputTokens = GeneratedColumn<int>(
    'output_tokens',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _cacheCreationTokensMeta =
      const VerificationMeta('cacheCreationTokens');
  late final GeneratedColumn<int> cacheCreationTokens = GeneratedColumn<int>(
    'cache_creation_tokens',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _cacheReadTokensMeta = const VerificationMeta(
    'cacheReadTokens',
  );
  late final GeneratedColumn<int> cacheReadTokens = GeneratedColumn<int>(
    'cache_read_tokens',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _costUsdMeta = const VerificationMeta(
    'costUsd',
  );
  late final GeneratedColumn<double> costUsd = GeneratedColumn<double>(
    'cost_usd',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    conversationId,
    model,
    inputTokens,
    outputTokens,
    cacheCreationTokens,
    cacheReadTokens,
    costUsd,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'api_usage';
  @override
  VerificationContext validateIntegrity(
    Insertable<ApiUsageData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
        _conversationIdMeta,
        conversationId.isAcceptableOrUnknown(
          data['conversation_id']!,
          _conversationIdMeta,
        ),
      );
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    } else if (isInserting) {
      context.missing(_modelMeta);
    }
    if (data.containsKey('input_tokens')) {
      context.handle(
        _inputTokensMeta,
        inputTokens.isAcceptableOrUnknown(
          data['input_tokens']!,
          _inputTokensMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_inputTokensMeta);
    }
    if (data.containsKey('output_tokens')) {
      context.handle(
        _outputTokensMeta,
        outputTokens.isAcceptableOrUnknown(
          data['output_tokens']!,
          _outputTokensMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_outputTokensMeta);
    }
    if (data.containsKey('cache_creation_tokens')) {
      context.handle(
        _cacheCreationTokensMeta,
        cacheCreationTokens.isAcceptableOrUnknown(
          data['cache_creation_tokens']!,
          _cacheCreationTokensMeta,
        ),
      );
    }
    if (data.containsKey('cache_read_tokens')) {
      context.handle(
        _cacheReadTokensMeta,
        cacheReadTokens.isAcceptableOrUnknown(
          data['cache_read_tokens']!,
          _cacheReadTokensMeta,
        ),
      );
    }
    if (data.containsKey('cost_usd')) {
      context.handle(
        _costUsdMeta,
        costUsd.isAcceptableOrUnknown(data['cost_usd']!, _costUsdMeta),
      );
    } else if (isInserting) {
      context.missing(_costUsdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ApiUsageData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ApiUsageData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      conversationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}conversation_id'],
      ),
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      )!,
      inputTokens: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}input_tokens'],
      )!,
      outputTokens: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}output_tokens'],
      )!,
      cacheCreationTokens: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cache_creation_tokens'],
      )!,
      cacheReadTokens: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cache_read_tokens'],
      )!,
      costUsd: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cost_usd'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  ApiUsage createAlias(String alias) {
    return ApiUsage(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class ApiUsageData extends DataClass implements Insertable<ApiUsageData> {
  final int id;
  final int? conversationId;
  final String model;
  final int inputTokens;
  final int outputTokens;
  final int cacheCreationTokens;
  final int cacheReadTokens;
  final double costUsd;
  final int createdAt;
  const ApiUsageData({
    required this.id,
    this.conversationId,
    required this.model,
    required this.inputTokens,
    required this.outputTokens,
    required this.cacheCreationTokens,
    required this.cacheReadTokens,
    required this.costUsd,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || conversationId != null) {
      map['conversation_id'] = Variable<int>(conversationId);
    }
    map['model'] = Variable<String>(model);
    map['input_tokens'] = Variable<int>(inputTokens);
    map['output_tokens'] = Variable<int>(outputTokens);
    map['cache_creation_tokens'] = Variable<int>(cacheCreationTokens);
    map['cache_read_tokens'] = Variable<int>(cacheReadTokens);
    map['cost_usd'] = Variable<double>(costUsd);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  ApiUsageCompanion toCompanion(bool nullToAbsent) {
    return ApiUsageCompanion(
      id: Value(id),
      conversationId: conversationId == null && nullToAbsent
          ? const Value.absent()
          : Value(conversationId),
      model: Value(model),
      inputTokens: Value(inputTokens),
      outputTokens: Value(outputTokens),
      cacheCreationTokens: Value(cacheCreationTokens),
      cacheReadTokens: Value(cacheReadTokens),
      costUsd: Value(costUsd),
      createdAt: Value(createdAt),
    );
  }

  factory ApiUsageData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ApiUsageData(
      id: serializer.fromJson<int>(json['id']),
      conversationId: serializer.fromJson<int?>(json['conversation_id']),
      model: serializer.fromJson<String>(json['model']),
      inputTokens: serializer.fromJson<int>(json['input_tokens']),
      outputTokens: serializer.fromJson<int>(json['output_tokens']),
      cacheCreationTokens: serializer.fromJson<int>(
        json['cache_creation_tokens'],
      ),
      cacheReadTokens: serializer.fromJson<int>(json['cache_read_tokens']),
      costUsd: serializer.fromJson<double>(json['cost_usd']),
      createdAt: serializer.fromJson<int>(json['created_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'conversation_id': serializer.toJson<int?>(conversationId),
      'model': serializer.toJson<String>(model),
      'input_tokens': serializer.toJson<int>(inputTokens),
      'output_tokens': serializer.toJson<int>(outputTokens),
      'cache_creation_tokens': serializer.toJson<int>(cacheCreationTokens),
      'cache_read_tokens': serializer.toJson<int>(cacheReadTokens),
      'cost_usd': serializer.toJson<double>(costUsd),
      'created_at': serializer.toJson<int>(createdAt),
    };
  }

  ApiUsageData copyWith({
    int? id,
    Value<int?> conversationId = const Value.absent(),
    String? model,
    int? inputTokens,
    int? outputTokens,
    int? cacheCreationTokens,
    int? cacheReadTokens,
    double? costUsd,
    int? createdAt,
  }) => ApiUsageData(
    id: id ?? this.id,
    conversationId: conversationId.present
        ? conversationId.value
        : this.conversationId,
    model: model ?? this.model,
    inputTokens: inputTokens ?? this.inputTokens,
    outputTokens: outputTokens ?? this.outputTokens,
    cacheCreationTokens: cacheCreationTokens ?? this.cacheCreationTokens,
    cacheReadTokens: cacheReadTokens ?? this.cacheReadTokens,
    costUsd: costUsd ?? this.costUsd,
    createdAt: createdAt ?? this.createdAt,
  );
  ApiUsageData copyWithCompanion(ApiUsageCompanion data) {
    return ApiUsageData(
      id: data.id.present ? data.id.value : this.id,
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      model: data.model.present ? data.model.value : this.model,
      inputTokens: data.inputTokens.present
          ? data.inputTokens.value
          : this.inputTokens,
      outputTokens: data.outputTokens.present
          ? data.outputTokens.value
          : this.outputTokens,
      cacheCreationTokens: data.cacheCreationTokens.present
          ? data.cacheCreationTokens.value
          : this.cacheCreationTokens,
      cacheReadTokens: data.cacheReadTokens.present
          ? data.cacheReadTokens.value
          : this.cacheReadTokens,
      costUsd: data.costUsd.present ? data.costUsd.value : this.costUsd,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ApiUsageData(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('model: $model, ')
          ..write('inputTokens: $inputTokens, ')
          ..write('outputTokens: $outputTokens, ')
          ..write('cacheCreationTokens: $cacheCreationTokens, ')
          ..write('cacheReadTokens: $cacheReadTokens, ')
          ..write('costUsd: $costUsd, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    conversationId,
    model,
    inputTokens,
    outputTokens,
    cacheCreationTokens,
    cacheReadTokens,
    costUsd,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ApiUsageData &&
          other.id == this.id &&
          other.conversationId == this.conversationId &&
          other.model == this.model &&
          other.inputTokens == this.inputTokens &&
          other.outputTokens == this.outputTokens &&
          other.cacheCreationTokens == this.cacheCreationTokens &&
          other.cacheReadTokens == this.cacheReadTokens &&
          other.costUsd == this.costUsd &&
          other.createdAt == this.createdAt);
}

class ApiUsageCompanion extends UpdateCompanion<ApiUsageData> {
  final Value<int> id;
  final Value<int?> conversationId;
  final Value<String> model;
  final Value<int> inputTokens;
  final Value<int> outputTokens;
  final Value<int> cacheCreationTokens;
  final Value<int> cacheReadTokens;
  final Value<double> costUsd;
  final Value<int> createdAt;
  const ApiUsageCompanion({
    this.id = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.model = const Value.absent(),
    this.inputTokens = const Value.absent(),
    this.outputTokens = const Value.absent(),
    this.cacheCreationTokens = const Value.absent(),
    this.cacheReadTokens = const Value.absent(),
    this.costUsd = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ApiUsageCompanion.insert({
    this.id = const Value.absent(),
    this.conversationId = const Value.absent(),
    required String model,
    required int inputTokens,
    required int outputTokens,
    this.cacheCreationTokens = const Value.absent(),
    this.cacheReadTokens = const Value.absent(),
    required double costUsd,
    required int createdAt,
  }) : model = Value(model),
       inputTokens = Value(inputTokens),
       outputTokens = Value(outputTokens),
       costUsd = Value(costUsd),
       createdAt = Value(createdAt);
  static Insertable<ApiUsageData> custom({
    Expression<int>? id,
    Expression<int>? conversationId,
    Expression<String>? model,
    Expression<int>? inputTokens,
    Expression<int>? outputTokens,
    Expression<int>? cacheCreationTokens,
    Expression<int>? cacheReadTokens,
    Expression<double>? costUsd,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (conversationId != null) 'conversation_id': conversationId,
      if (model != null) 'model': model,
      if (inputTokens != null) 'input_tokens': inputTokens,
      if (outputTokens != null) 'output_tokens': outputTokens,
      if (cacheCreationTokens != null)
        'cache_creation_tokens': cacheCreationTokens,
      if (cacheReadTokens != null) 'cache_read_tokens': cacheReadTokens,
      if (costUsd != null) 'cost_usd': costUsd,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ApiUsageCompanion copyWith({
    Value<int>? id,
    Value<int?>? conversationId,
    Value<String>? model,
    Value<int>? inputTokens,
    Value<int>? outputTokens,
    Value<int>? cacheCreationTokens,
    Value<int>? cacheReadTokens,
    Value<double>? costUsd,
    Value<int>? createdAt,
  }) {
    return ApiUsageCompanion(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      model: model ?? this.model,
      inputTokens: inputTokens ?? this.inputTokens,
      outputTokens: outputTokens ?? this.outputTokens,
      cacheCreationTokens: cacheCreationTokens ?? this.cacheCreationTokens,
      cacheReadTokens: cacheReadTokens ?? this.cacheReadTokens,
      costUsd: costUsd ?? this.costUsd,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<int>(conversationId.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (inputTokens.present) {
      map['input_tokens'] = Variable<int>(inputTokens.value);
    }
    if (outputTokens.present) {
      map['output_tokens'] = Variable<int>(outputTokens.value);
    }
    if (cacheCreationTokens.present) {
      map['cache_creation_tokens'] = Variable<int>(cacheCreationTokens.value);
    }
    if (cacheReadTokens.present) {
      map['cache_read_tokens'] = Variable<int>(cacheReadTokens.value);
    }
    if (costUsd.present) {
      map['cost_usd'] = Variable<double>(costUsd.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ApiUsageCompanion(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('model: $model, ')
          ..write('inputTokens: $inputTokens, ')
          ..write('outputTokens: $outputTokens, ')
          ..write('cacheCreationTokens: $cacheCreationTokens, ')
          ..write('cacheReadTokens: $cacheReadTokens, ')
          ..write('costUsd: $costUsd, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class Settings extends Table with TableInfo<Settings, Setting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Settings(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT',
  );
  static const VerificationMeta _settingKeyMeta = const VerificationMeta(
    'settingKey',
  );
  late final GeneratedColumn<String> settingKey = GeneratedColumn<String>(
    'setting_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL UNIQUE',
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [id, settingKey, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Setting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('setting_key')) {
      context.handle(
        _settingKeyMeta,
        settingKey.isAcceptableOrUnknown(data['setting_key']!, _settingKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_settingKeyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Setting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Setting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      settingKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}setting_key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  Settings createAlias(String alias) {
    return Settings(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class Setting extends DataClass implements Insertable<Setting> {
  final int id;
  final String settingKey;
  final String value;
  final int updatedAt;
  const Setting({
    required this.id,
    required this.settingKey,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['setting_key'] = Variable<String>(settingKey);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(
      id: Value(id),
      settingKey: Value(settingKey),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory Setting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Setting(
      id: serializer.fromJson<int>(json['id']),
      settingKey: serializer.fromJson<String>(json['setting_key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<int>(json['updated_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'setting_key': serializer.toJson<String>(settingKey),
      'value': serializer.toJson<String>(value),
      'updated_at': serializer.toJson<int>(updatedAt),
    };
  }

  Setting copyWith({
    int? id,
    String? settingKey,
    String? value,
    int? updatedAt,
  }) => Setting(
    id: id ?? this.id,
    settingKey: settingKey ?? this.settingKey,
    value: value ?? this.value,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Setting copyWithCompanion(SettingsCompanion data) {
    return Setting(
      id: data.id.present ? data.id.value : this.id,
      settingKey: data.settingKey.present
          ? data.settingKey.value
          : this.settingKey,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Setting(')
          ..write('id: $id, ')
          ..write('settingKey: $settingKey, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, settingKey, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Setting &&
          other.id == this.id &&
          other.settingKey == this.settingKey &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class SettingsCompanion extends UpdateCompanion<Setting> {
  final Value<int> id;
  final Value<String> settingKey;
  final Value<String> value;
  final Value<int> updatedAt;
  const SettingsCompanion({
    this.id = const Value.absent(),
    this.settingKey = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  SettingsCompanion.insert({
    this.id = const Value.absent(),
    required String settingKey,
    required String value,
    required int updatedAt,
  }) : settingKey = Value(settingKey),
       value = Value(value),
       updatedAt = Value(updatedAt);
  static Insertable<Setting> custom({
    Expression<int>? id,
    Expression<String>? settingKey,
    Expression<String>? value,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (settingKey != null) 'setting_key': settingKey,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  SettingsCompanion copyWith({
    Value<int>? id,
    Value<String>? settingKey,
    Value<String>? value,
    Value<int>? updatedAt,
  }) {
    return SettingsCompanion(
      id: id ?? this.id,
      settingKey: settingKey ?? this.settingKey,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (settingKey.present) {
      map['setting_key'] = Variable<String>(settingKey.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('id: $id, ')
          ..write('settingKey: $settingKey, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class StucknessSignals extends Table
    with TableInfo<StucknessSignals, StucknessSignal> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  StucknessSignals(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT',
  );
  static const VerificationMeta _topicMeta = const VerificationMeta('topic');
  late final GeneratedColumn<String> topic = GeneratedColumn<String>(
    'topic',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _conversationCountMeta = const VerificationMeta(
    'conversationCount',
  );
  late final GeneratedColumn<int> conversationCount = GeneratedColumn<int>(
    'conversation_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _decisionCountMeta = const VerificationMeta(
    'decisionCount',
  );
  late final GeneratedColumn<int> decisionCount = GeneratedColumn<int>(
    'decision_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _firstSeenMeta = const VerificationMeta(
    'firstSeen',
  );
  late final GeneratedColumn<int> firstSeen = GeneratedColumn<int>(
    'first_seen',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _lastSeenMeta = const VerificationMeta(
    'lastSeen',
  );
  late final GeneratedColumn<int> lastSeen = GeneratedColumn<int>(
    'last_seen',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  late final GeneratedColumn<double> score = GeneratedColumn<double>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _nudgeSentMeta = const VerificationMeta(
    'nudgeSent',
  );
  late final GeneratedColumn<int> nudgeSent = GeneratedColumn<int>(
    'nudge_sent',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    topic,
    conversationCount,
    decisionCount,
    firstSeen,
    lastSeen,
    score,
    nudgeSent,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stuckness_signals';
  @override
  VerificationContext validateIntegrity(
    Insertable<StucknessSignal> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('topic')) {
      context.handle(
        _topicMeta,
        topic.isAcceptableOrUnknown(data['topic']!, _topicMeta),
      );
    } else if (isInserting) {
      context.missing(_topicMeta);
    }
    if (data.containsKey('conversation_count')) {
      context.handle(
        _conversationCountMeta,
        conversationCount.isAcceptableOrUnknown(
          data['conversation_count']!,
          _conversationCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conversationCountMeta);
    }
    if (data.containsKey('decision_count')) {
      context.handle(
        _decisionCountMeta,
        decisionCount.isAcceptableOrUnknown(
          data['decision_count']!,
          _decisionCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_decisionCountMeta);
    }
    if (data.containsKey('first_seen')) {
      context.handle(
        _firstSeenMeta,
        firstSeen.isAcceptableOrUnknown(data['first_seen']!, _firstSeenMeta),
      );
    } else if (isInserting) {
      context.missing(_firstSeenMeta);
    }
    if (data.containsKey('last_seen')) {
      context.handle(
        _lastSeenMeta,
        lastSeen.isAcceptableOrUnknown(data['last_seen']!, _lastSeenMeta),
      );
    } else if (isInserting) {
      context.missing(_lastSeenMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    if (data.containsKey('nudge_sent')) {
      context.handle(
        _nudgeSentMeta,
        nudgeSent.isAcceptableOrUnknown(data['nudge_sent']!, _nudgeSentMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StucknessSignal map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StucknessSignal(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      topic: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}topic'],
      )!,
      conversationCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}conversation_count'],
      )!,
      decisionCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}decision_count'],
      )!,
      firstSeen: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}first_seen'],
      )!,
      lastSeen: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_seen'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}score'],
      )!,
      nudgeSent: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}nudge_sent'],
      )!,
    );
  }

  @override
  StucknessSignals createAlias(String alias) {
    return StucknessSignals(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class StucknessSignal extends DataClass implements Insertable<StucknessSignal> {
  final int id;
  final String topic;
  final int conversationCount;
  final int decisionCount;
  final int firstSeen;
  final int lastSeen;
  final double score;
  final int nudgeSent;
  const StucknessSignal({
    required this.id,
    required this.topic,
    required this.conversationCount,
    required this.decisionCount,
    required this.firstSeen,
    required this.lastSeen,
    required this.score,
    required this.nudgeSent,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['topic'] = Variable<String>(topic);
    map['conversation_count'] = Variable<int>(conversationCount);
    map['decision_count'] = Variable<int>(decisionCount);
    map['first_seen'] = Variable<int>(firstSeen);
    map['last_seen'] = Variable<int>(lastSeen);
    map['score'] = Variable<double>(score);
    map['nudge_sent'] = Variable<int>(nudgeSent);
    return map;
  }

  StucknessSignalsCompanion toCompanion(bool nullToAbsent) {
    return StucknessSignalsCompanion(
      id: Value(id),
      topic: Value(topic),
      conversationCount: Value(conversationCount),
      decisionCount: Value(decisionCount),
      firstSeen: Value(firstSeen),
      lastSeen: Value(lastSeen),
      score: Value(score),
      nudgeSent: Value(nudgeSent),
    );
  }

  factory StucknessSignal.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StucknessSignal(
      id: serializer.fromJson<int>(json['id']),
      topic: serializer.fromJson<String>(json['topic']),
      conversationCount: serializer.fromJson<int>(json['conversation_count']),
      decisionCount: serializer.fromJson<int>(json['decision_count']),
      firstSeen: serializer.fromJson<int>(json['first_seen']),
      lastSeen: serializer.fromJson<int>(json['last_seen']),
      score: serializer.fromJson<double>(json['score']),
      nudgeSent: serializer.fromJson<int>(json['nudge_sent']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'topic': serializer.toJson<String>(topic),
      'conversation_count': serializer.toJson<int>(conversationCount),
      'decision_count': serializer.toJson<int>(decisionCount),
      'first_seen': serializer.toJson<int>(firstSeen),
      'last_seen': serializer.toJson<int>(lastSeen),
      'score': serializer.toJson<double>(score),
      'nudge_sent': serializer.toJson<int>(nudgeSent),
    };
  }

  StucknessSignal copyWith({
    int? id,
    String? topic,
    int? conversationCount,
    int? decisionCount,
    int? firstSeen,
    int? lastSeen,
    double? score,
    int? nudgeSent,
  }) => StucknessSignal(
    id: id ?? this.id,
    topic: topic ?? this.topic,
    conversationCount: conversationCount ?? this.conversationCount,
    decisionCount: decisionCount ?? this.decisionCount,
    firstSeen: firstSeen ?? this.firstSeen,
    lastSeen: lastSeen ?? this.lastSeen,
    score: score ?? this.score,
    nudgeSent: nudgeSent ?? this.nudgeSent,
  );
  StucknessSignal copyWithCompanion(StucknessSignalsCompanion data) {
    return StucknessSignal(
      id: data.id.present ? data.id.value : this.id,
      topic: data.topic.present ? data.topic.value : this.topic,
      conversationCount: data.conversationCount.present
          ? data.conversationCount.value
          : this.conversationCount,
      decisionCount: data.decisionCount.present
          ? data.decisionCount.value
          : this.decisionCount,
      firstSeen: data.firstSeen.present ? data.firstSeen.value : this.firstSeen,
      lastSeen: data.lastSeen.present ? data.lastSeen.value : this.lastSeen,
      score: data.score.present ? data.score.value : this.score,
      nudgeSent: data.nudgeSent.present ? data.nudgeSent.value : this.nudgeSent,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StucknessSignal(')
          ..write('id: $id, ')
          ..write('topic: $topic, ')
          ..write('conversationCount: $conversationCount, ')
          ..write('decisionCount: $decisionCount, ')
          ..write('firstSeen: $firstSeen, ')
          ..write('lastSeen: $lastSeen, ')
          ..write('score: $score, ')
          ..write('nudgeSent: $nudgeSent')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    topic,
    conversationCount,
    decisionCount,
    firstSeen,
    lastSeen,
    score,
    nudgeSent,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StucknessSignal &&
          other.id == this.id &&
          other.topic == this.topic &&
          other.conversationCount == this.conversationCount &&
          other.decisionCount == this.decisionCount &&
          other.firstSeen == this.firstSeen &&
          other.lastSeen == this.lastSeen &&
          other.score == this.score &&
          other.nudgeSent == this.nudgeSent);
}

class StucknessSignalsCompanion extends UpdateCompanion<StucknessSignal> {
  final Value<int> id;
  final Value<String> topic;
  final Value<int> conversationCount;
  final Value<int> decisionCount;
  final Value<int> firstSeen;
  final Value<int> lastSeen;
  final Value<double> score;
  final Value<int> nudgeSent;
  const StucknessSignalsCompanion({
    this.id = const Value.absent(),
    this.topic = const Value.absent(),
    this.conversationCount = const Value.absent(),
    this.decisionCount = const Value.absent(),
    this.firstSeen = const Value.absent(),
    this.lastSeen = const Value.absent(),
    this.score = const Value.absent(),
    this.nudgeSent = const Value.absent(),
  });
  StucknessSignalsCompanion.insert({
    this.id = const Value.absent(),
    required String topic,
    required int conversationCount,
    required int decisionCount,
    required int firstSeen,
    required int lastSeen,
    required double score,
    this.nudgeSent = const Value.absent(),
  }) : topic = Value(topic),
       conversationCount = Value(conversationCount),
       decisionCount = Value(decisionCount),
       firstSeen = Value(firstSeen),
       lastSeen = Value(lastSeen),
       score = Value(score);
  static Insertable<StucknessSignal> custom({
    Expression<int>? id,
    Expression<String>? topic,
    Expression<int>? conversationCount,
    Expression<int>? decisionCount,
    Expression<int>? firstSeen,
    Expression<int>? lastSeen,
    Expression<double>? score,
    Expression<int>? nudgeSent,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (topic != null) 'topic': topic,
      if (conversationCount != null) 'conversation_count': conversationCount,
      if (decisionCount != null) 'decision_count': decisionCount,
      if (firstSeen != null) 'first_seen': firstSeen,
      if (lastSeen != null) 'last_seen': lastSeen,
      if (score != null) 'score': score,
      if (nudgeSent != null) 'nudge_sent': nudgeSent,
    });
  }

  StucknessSignalsCompanion copyWith({
    Value<int>? id,
    Value<String>? topic,
    Value<int>? conversationCount,
    Value<int>? decisionCount,
    Value<int>? firstSeen,
    Value<int>? lastSeen,
    Value<double>? score,
    Value<int>? nudgeSent,
  }) {
    return StucknessSignalsCompanion(
      id: id ?? this.id,
      topic: topic ?? this.topic,
      conversationCount: conversationCount ?? this.conversationCount,
      decisionCount: decisionCount ?? this.decisionCount,
      firstSeen: firstSeen ?? this.firstSeen,
      lastSeen: lastSeen ?? this.lastSeen,
      score: score ?? this.score,
      nudgeSent: nudgeSent ?? this.nudgeSent,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (topic.present) {
      map['topic'] = Variable<String>(topic.value);
    }
    if (conversationCount.present) {
      map['conversation_count'] = Variable<int>(conversationCount.value);
    }
    if (decisionCount.present) {
      map['decision_count'] = Variable<int>(decisionCount.value);
    }
    if (firstSeen.present) {
      map['first_seen'] = Variable<int>(firstSeen.value);
    }
    if (lastSeen.present) {
      map['last_seen'] = Variable<int>(lastSeen.value);
    }
    if (score.present) {
      map['score'] = Variable<double>(score.value);
    }
    if (nudgeSent.present) {
      map['nudge_sent'] = Variable<int>(nudgeSent.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StucknessSignalsCompanion(')
          ..write('id: $id, ')
          ..write('topic: $topic, ')
          ..write('conversationCount: $conversationCount, ')
          ..write('decisionCount: $decisionCount, ')
          ..write('firstSeen: $firstSeen, ')
          ..write('lastSeen: $lastSeen, ')
          ..write('score: $score, ')
          ..write('nudgeSent: $nudgeSent')
          ..write(')'))
        .toString();
  }
}

class Briefings extends Table with TableInfo<Briefings, Briefing> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Briefings(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT',
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL UNIQUE',
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _prioritiesMeta = const VerificationMeta(
    'priorities',
  );
  late final GeneratedColumn<String> priorities = GeneratedColumn<String>(
    'priorities',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _calendarSummaryMeta = const VerificationMeta(
    'calendarSummary',
  );
  late final GeneratedColumn<String> calendarSummary = GeneratedColumn<String>(
    'calendar_summary',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _conversationIdMeta = const VerificationMeta(
    'conversationId',
  );
  late final GeneratedColumn<int> conversationId = GeneratedColumn<int>(
    'conversation_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    content,
    priorities,
    calendarSummary,
    createdAt,
    conversationId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'briefings';
  @override
  VerificationContext validateIntegrity(
    Insertable<Briefing> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('priorities')) {
      context.handle(
        _prioritiesMeta,
        priorities.isAcceptableOrUnknown(data['priorities']!, _prioritiesMeta),
      );
    }
    if (data.containsKey('calendar_summary')) {
      context.handle(
        _calendarSummaryMeta,
        calendarSummary.isAcceptableOrUnknown(
          data['calendar_summary']!,
          _calendarSummaryMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
        _conversationIdMeta,
        conversationId.isAcceptableOrUnknown(
          data['conversation_id']!,
          _conversationIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Briefing map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Briefing(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      priorities: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}priorities'],
      ),
      calendarSummary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}calendar_summary'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      conversationId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}conversation_id'],
      ),
    );
  }

  @override
  Briefings createAlias(String alias) {
    return Briefings(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class Briefing extends DataClass implements Insertable<Briefing> {
  final int id;
  final String date;
  final String content;
  final String? priorities;
  final String? calendarSummary;
  final int createdAt;
  final int? conversationId;
  const Briefing({
    required this.id,
    required this.date,
    required this.content,
    this.priorities,
    this.calendarSummary,
    required this.createdAt,
    this.conversationId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<String>(date);
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || priorities != null) {
      map['priorities'] = Variable<String>(priorities);
    }
    if (!nullToAbsent || calendarSummary != null) {
      map['calendar_summary'] = Variable<String>(calendarSummary);
    }
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || conversationId != null) {
      map['conversation_id'] = Variable<int>(conversationId);
    }
    return map;
  }

  BriefingsCompanion toCompanion(bool nullToAbsent) {
    return BriefingsCompanion(
      id: Value(id),
      date: Value(date),
      content: Value(content),
      priorities: priorities == null && nullToAbsent
          ? const Value.absent()
          : Value(priorities),
      calendarSummary: calendarSummary == null && nullToAbsent
          ? const Value.absent()
          : Value(calendarSummary),
      createdAt: Value(createdAt),
      conversationId: conversationId == null && nullToAbsent
          ? const Value.absent()
          : Value(conversationId),
    );
  }

  factory Briefing.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Briefing(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<String>(json['date']),
      content: serializer.fromJson<String>(json['content']),
      priorities: serializer.fromJson<String?>(json['priorities']),
      calendarSummary: serializer.fromJson<String?>(json['calendar_summary']),
      createdAt: serializer.fromJson<int>(json['created_at']),
      conversationId: serializer.fromJson<int?>(json['conversation_id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<String>(date),
      'content': serializer.toJson<String>(content),
      'priorities': serializer.toJson<String?>(priorities),
      'calendar_summary': serializer.toJson<String?>(calendarSummary),
      'created_at': serializer.toJson<int>(createdAt),
      'conversation_id': serializer.toJson<int?>(conversationId),
    };
  }

  Briefing copyWith({
    int? id,
    String? date,
    String? content,
    Value<String?> priorities = const Value.absent(),
    Value<String?> calendarSummary = const Value.absent(),
    int? createdAt,
    Value<int?> conversationId = const Value.absent(),
  }) => Briefing(
    id: id ?? this.id,
    date: date ?? this.date,
    content: content ?? this.content,
    priorities: priorities.present ? priorities.value : this.priorities,
    calendarSummary: calendarSummary.present
        ? calendarSummary.value
        : this.calendarSummary,
    createdAt: createdAt ?? this.createdAt,
    conversationId: conversationId.present
        ? conversationId.value
        : this.conversationId,
  );
  Briefing copyWithCompanion(BriefingsCompanion data) {
    return Briefing(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      content: data.content.present ? data.content.value : this.content,
      priorities: data.priorities.present
          ? data.priorities.value
          : this.priorities,
      calendarSummary: data.calendarSummary.present
          ? data.calendarSummary.value
          : this.calendarSummary,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Briefing(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('content: $content, ')
          ..write('priorities: $priorities, ')
          ..write('calendarSummary: $calendarSummary, ')
          ..write('createdAt: $createdAt, ')
          ..write('conversationId: $conversationId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    content,
    priorities,
    calendarSummary,
    createdAt,
    conversationId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Briefing &&
          other.id == this.id &&
          other.date == this.date &&
          other.content == this.content &&
          other.priorities == this.priorities &&
          other.calendarSummary == this.calendarSummary &&
          other.createdAt == this.createdAt &&
          other.conversationId == this.conversationId);
}

class BriefingsCompanion extends UpdateCompanion<Briefing> {
  final Value<int> id;
  final Value<String> date;
  final Value<String> content;
  final Value<String?> priorities;
  final Value<String?> calendarSummary;
  final Value<int> createdAt;
  final Value<int?> conversationId;
  const BriefingsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.content = const Value.absent(),
    this.priorities = const Value.absent(),
    this.calendarSummary = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.conversationId = const Value.absent(),
  });
  BriefingsCompanion.insert({
    this.id = const Value.absent(),
    required String date,
    required String content,
    this.priorities = const Value.absent(),
    this.calendarSummary = const Value.absent(),
    required int createdAt,
    this.conversationId = const Value.absent(),
  }) : date = Value(date),
       content = Value(content),
       createdAt = Value(createdAt);
  static Insertable<Briefing> custom({
    Expression<int>? id,
    Expression<String>? date,
    Expression<String>? content,
    Expression<String>? priorities,
    Expression<String>? calendarSummary,
    Expression<int>? createdAt,
    Expression<int>? conversationId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (content != null) 'content': content,
      if (priorities != null) 'priorities': priorities,
      if (calendarSummary != null) 'calendar_summary': calendarSummary,
      if (createdAt != null) 'created_at': createdAt,
      if (conversationId != null) 'conversation_id': conversationId,
    });
  }

  BriefingsCompanion copyWith({
    Value<int>? id,
    Value<String>? date,
    Value<String>? content,
    Value<String?>? priorities,
    Value<String?>? calendarSummary,
    Value<int>? createdAt,
    Value<int?>? conversationId,
  }) {
    return BriefingsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      content: content ?? this.content,
      priorities: priorities ?? this.priorities,
      calendarSummary: calendarSummary ?? this.calendarSummary,
      createdAt: createdAt ?? this.createdAt,
      conversationId: conversationId ?? this.conversationId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (priorities.present) {
      map['priorities'] = Variable<String>(priorities.value);
    }
    if (calendarSummary.present) {
      map['calendar_summary'] = Variable<String>(calendarSummary.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<int>(conversationId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BriefingsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('content: $content, ')
          ..write('priorities: $priorities, ')
          ..write('calendarSummary: $calendarSummary, ')
          ..write('createdAt: $createdAt, ')
          ..write('conversationId: $conversationId')
          ..write(')'))
        .toString();
  }
}

class MonitoredNotifications extends Table
    with TableInfo<MonitoredNotifications, MonitoredNotification> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  MonitoredNotifications(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT',
  );
  static const VerificationMeta _packageNameMeta = const VerificationMeta(
    'packageName',
  );
  late final GeneratedColumn<String> packageName = GeneratedColumn<String>(
    'package_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _timestampMeta = const VerificationMeta(
    'timestamp',
  );
  late final GeneratedColumn<int> timestamp = GeneratedColumn<int>(
    'timestamp',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _isRelevantMeta = const VerificationMeta(
    'isRelevant',
  );
  late final GeneratedColumn<int> isRelevant = GeneratedColumn<int>(
    'is_relevant',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _isSurfacedMeta = const VerificationMeta(
    'isSurfaced',
  );
  late final GeneratedColumn<int> isSurfaced = GeneratedColumn<int>(
    'is_surfaced',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    packageName,
    title,
    content,
    timestamp,
    category,
    isRelevant,
    isSurfaced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'monitored_notifications';
  @override
  VerificationContext validateIntegrity(
    Insertable<MonitoredNotification> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('package_name')) {
      context.handle(
        _packageNameMeta,
        packageName.isAcceptableOrUnknown(
          data['package_name']!,
          _packageNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_packageNameMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    }
    if (data.containsKey('timestamp')) {
      context.handle(
        _timestampMeta,
        timestamp.isAcceptableOrUnknown(data['timestamp']!, _timestampMeta),
      );
    } else if (isInserting) {
      context.missing(_timestampMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('is_relevant')) {
      context.handle(
        _isRelevantMeta,
        isRelevant.isAcceptableOrUnknown(data['is_relevant']!, _isRelevantMeta),
      );
    }
    if (data.containsKey('is_surfaced')) {
      context.handle(
        _isSurfacedMeta,
        isSurfaced.isAcceptableOrUnknown(data['is_surfaced']!, _isSurfacedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MonitoredNotification map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MonitoredNotification(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      packageName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}package_name'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      ),
      timestamp: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}timestamp'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      isRelevant: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_relevant'],
      )!,
      isSurfaced: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_surfaced'],
      )!,
    );
  }

  @override
  MonitoredNotifications createAlias(String alias) {
    return MonitoredNotifications(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class MonitoredNotification extends DataClass
    implements Insertable<MonitoredNotification> {
  final int id;
  final String packageName;
  final String? title;
  final String? content;
  final int timestamp;
  final String? category;
  final int isRelevant;
  final int isSurfaced;
  const MonitoredNotification({
    required this.id,
    required this.packageName,
    this.title,
    this.content,
    required this.timestamp,
    this.category,
    required this.isRelevant,
    required this.isSurfaced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['package_name'] = Variable<String>(packageName);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || content != null) {
      map['content'] = Variable<String>(content);
    }
    map['timestamp'] = Variable<int>(timestamp);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    map['is_relevant'] = Variable<int>(isRelevant);
    map['is_surfaced'] = Variable<int>(isSurfaced);
    return map;
  }

  MonitoredNotificationsCompanion toCompanion(bool nullToAbsent) {
    return MonitoredNotificationsCompanion(
      id: Value(id),
      packageName: Value(packageName),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      content: content == null && nullToAbsent
          ? const Value.absent()
          : Value(content),
      timestamp: Value(timestamp),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      isRelevant: Value(isRelevant),
      isSurfaced: Value(isSurfaced),
    );
  }

  factory MonitoredNotification.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MonitoredNotification(
      id: serializer.fromJson<int>(json['id']),
      packageName: serializer.fromJson<String>(json['package_name']),
      title: serializer.fromJson<String?>(json['title']),
      content: serializer.fromJson<String?>(json['content']),
      timestamp: serializer.fromJson<int>(json['timestamp']),
      category: serializer.fromJson<String?>(json['category']),
      isRelevant: serializer.fromJson<int>(json['is_relevant']),
      isSurfaced: serializer.fromJson<int>(json['is_surfaced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'package_name': serializer.toJson<String>(packageName),
      'title': serializer.toJson<String?>(title),
      'content': serializer.toJson<String?>(content),
      'timestamp': serializer.toJson<int>(timestamp),
      'category': serializer.toJson<String?>(category),
      'is_relevant': serializer.toJson<int>(isRelevant),
      'is_surfaced': serializer.toJson<int>(isSurfaced),
    };
  }

  MonitoredNotification copyWith({
    int? id,
    String? packageName,
    Value<String?> title = const Value.absent(),
    Value<String?> content = const Value.absent(),
    int? timestamp,
    Value<String?> category = const Value.absent(),
    int? isRelevant,
    int? isSurfaced,
  }) => MonitoredNotification(
    id: id ?? this.id,
    packageName: packageName ?? this.packageName,
    title: title.present ? title.value : this.title,
    content: content.present ? content.value : this.content,
    timestamp: timestamp ?? this.timestamp,
    category: category.present ? category.value : this.category,
    isRelevant: isRelevant ?? this.isRelevant,
    isSurfaced: isSurfaced ?? this.isSurfaced,
  );
  MonitoredNotification copyWithCompanion(
    MonitoredNotificationsCompanion data,
  ) {
    return MonitoredNotification(
      id: data.id.present ? data.id.value : this.id,
      packageName: data.packageName.present
          ? data.packageName.value
          : this.packageName,
      title: data.title.present ? data.title.value : this.title,
      content: data.content.present ? data.content.value : this.content,
      timestamp: data.timestamp.present ? data.timestamp.value : this.timestamp,
      category: data.category.present ? data.category.value : this.category,
      isRelevant: data.isRelevant.present
          ? data.isRelevant.value
          : this.isRelevant,
      isSurfaced: data.isSurfaced.present
          ? data.isSurfaced.value
          : this.isSurfaced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MonitoredNotification(')
          ..write('id: $id, ')
          ..write('packageName: $packageName, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('timestamp: $timestamp, ')
          ..write('category: $category, ')
          ..write('isRelevant: $isRelevant, ')
          ..write('isSurfaced: $isSurfaced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    packageName,
    title,
    content,
    timestamp,
    category,
    isRelevant,
    isSurfaced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MonitoredNotification &&
          other.id == this.id &&
          other.packageName == this.packageName &&
          other.title == this.title &&
          other.content == this.content &&
          other.timestamp == this.timestamp &&
          other.category == this.category &&
          other.isRelevant == this.isRelevant &&
          other.isSurfaced == this.isSurfaced);
}

class MonitoredNotificationsCompanion
    extends UpdateCompanion<MonitoredNotification> {
  final Value<int> id;
  final Value<String> packageName;
  final Value<String?> title;
  final Value<String?> content;
  final Value<int> timestamp;
  final Value<String?> category;
  final Value<int> isRelevant;
  final Value<int> isSurfaced;
  const MonitoredNotificationsCompanion({
    this.id = const Value.absent(),
    this.packageName = const Value.absent(),
    this.title = const Value.absent(),
    this.content = const Value.absent(),
    this.timestamp = const Value.absent(),
    this.category = const Value.absent(),
    this.isRelevant = const Value.absent(),
    this.isSurfaced = const Value.absent(),
  });
  MonitoredNotificationsCompanion.insert({
    this.id = const Value.absent(),
    required String packageName,
    this.title = const Value.absent(),
    this.content = const Value.absent(),
    required int timestamp,
    this.category = const Value.absent(),
    this.isRelevant = const Value.absent(),
    this.isSurfaced = const Value.absent(),
  }) : packageName = Value(packageName),
       timestamp = Value(timestamp);
  static Insertable<MonitoredNotification> custom({
    Expression<int>? id,
    Expression<String>? packageName,
    Expression<String>? title,
    Expression<String>? content,
    Expression<int>? timestamp,
    Expression<String>? category,
    Expression<int>? isRelevant,
    Expression<int>? isSurfaced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (packageName != null) 'package_name': packageName,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (timestamp != null) 'timestamp': timestamp,
      if (category != null) 'category': category,
      if (isRelevant != null) 'is_relevant': isRelevant,
      if (isSurfaced != null) 'is_surfaced': isSurfaced,
    });
  }

  MonitoredNotificationsCompanion copyWith({
    Value<int>? id,
    Value<String>? packageName,
    Value<String?>? title,
    Value<String?>? content,
    Value<int>? timestamp,
    Value<String?>? category,
    Value<int>? isRelevant,
    Value<int>? isSurfaced,
  }) {
    return MonitoredNotificationsCompanion(
      id: id ?? this.id,
      packageName: packageName ?? this.packageName,
      title: title ?? this.title,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      category: category ?? this.category,
      isRelevant: isRelevant ?? this.isRelevant,
      isSurfaced: isSurfaced ?? this.isSurfaced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (packageName.present) {
      map['package_name'] = Variable<String>(packageName.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (timestamp.present) {
      map['timestamp'] = Variable<int>(timestamp.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (isRelevant.present) {
      map['is_relevant'] = Variable<int>(isRelevant.value);
    }
    if (isSurfaced.present) {
      map['is_surfaced'] = Variable<int>(isSurfaced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MonitoredNotificationsCompanion(')
          ..write('id: $id, ')
          ..write('packageName: $packageName, ')
          ..write('title: $title, ')
          ..write('content: $content, ')
          ..write('timestamp: $timestamp, ')
          ..write('category: $category, ')
          ..write('isRelevant: $isRelevant, ')
          ..write('isSurfaced: $isSurfaced')
          ..write(')'))
        .toString();
  }
}

class CachedCalendarEvents extends Table
    with TableInfo<CachedCalendarEvents, CachedCalendarEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  CachedCalendarEvents(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _calendarIdMeta = const VerificationMeta(
    'calendarId',
  );
  late final GeneratedColumn<String> calendarId = GeneratedColumn<String>(
    'calendar_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _startTimeMeta = const VerificationMeta(
    'startTime',
  );
  late final GeneratedColumn<int> startTime = GeneratedColumn<int>(
    'start_time',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _endTimeMeta = const VerificationMeta(
    'endTime',
  );
  late final GeneratedColumn<int> endTime = GeneratedColumn<int>(
    'end_time',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _attendeeEmailsMeta = const VerificationMeta(
    'attendeeEmails',
  );
  late final GeneratedColumn<String> attendeeEmails = GeneratedColumn<String>(
    'attendee_emails',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _lastSyncedMeta = const VerificationMeta(
    'lastSynced',
  );
  late final GeneratedColumn<int> lastSynced = GeneratedColumn<int>(
    'last_synced',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    eventId,
    calendarId,
    title,
    startTime,
    endTime,
    location,
    description,
    attendeeEmails,
    lastSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_calendar_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedCalendarEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('calendar_id')) {
      context.handle(
        _calendarIdMeta,
        calendarId.isAcceptableOrUnknown(data['calendar_id']!, _calendarIdMeta),
      );
    } else if (isInserting) {
      context.missing(_calendarIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('start_time')) {
      context.handle(
        _startTimeMeta,
        startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_startTimeMeta);
    }
    if (data.containsKey('end_time')) {
      context.handle(
        _endTimeMeta,
        endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_endTimeMeta);
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('attendee_emails')) {
      context.handle(
        _attendeeEmailsMeta,
        attendeeEmails.isAcceptableOrUnknown(
          data['attendee_emails']!,
          _attendeeEmailsMeta,
        ),
      );
    }
    if (data.containsKey('last_synced')) {
      context.handle(
        _lastSyncedMeta,
        lastSynced.isAcceptableOrUnknown(data['last_synced']!, _lastSyncedMeta),
      );
    } else if (isInserting) {
      context.missing(_lastSyncedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {eventId};
  @override
  CachedCalendarEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedCalendarEvent(
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      )!,
      calendarId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}calendar_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      startTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_time'],
      )!,
      endTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_time'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      attendeeEmails: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attendee_emails'],
      ),
      lastSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_synced'],
      )!,
    );
  }

  @override
  CachedCalendarEvents createAlias(String alias) {
    return CachedCalendarEvents(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class CachedCalendarEvent extends DataClass
    implements Insertable<CachedCalendarEvent> {
  final String eventId;
  final String calendarId;
  final String title;
  final int startTime;
  final int endTime;
  final String? location;
  final String? description;
  final String? attendeeEmails;
  final int lastSynced;
  const CachedCalendarEvent({
    required this.eventId,
    required this.calendarId,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.location,
    this.description,
    this.attendeeEmails,
    required this.lastSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['event_id'] = Variable<String>(eventId);
    map['calendar_id'] = Variable<String>(calendarId);
    map['title'] = Variable<String>(title);
    map['start_time'] = Variable<int>(startTime);
    map['end_time'] = Variable<int>(endTime);
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || attendeeEmails != null) {
      map['attendee_emails'] = Variable<String>(attendeeEmails);
    }
    map['last_synced'] = Variable<int>(lastSynced);
    return map;
  }

  CachedCalendarEventsCompanion toCompanion(bool nullToAbsent) {
    return CachedCalendarEventsCompanion(
      eventId: Value(eventId),
      calendarId: Value(calendarId),
      title: Value(title),
      startTime: Value(startTime),
      endTime: Value(endTime),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      attendeeEmails: attendeeEmails == null && nullToAbsent
          ? const Value.absent()
          : Value(attendeeEmails),
      lastSynced: Value(lastSynced),
    );
  }

  factory CachedCalendarEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedCalendarEvent(
      eventId: serializer.fromJson<String>(json['event_id']),
      calendarId: serializer.fromJson<String>(json['calendar_id']),
      title: serializer.fromJson<String>(json['title']),
      startTime: serializer.fromJson<int>(json['start_time']),
      endTime: serializer.fromJson<int>(json['end_time']),
      location: serializer.fromJson<String?>(json['location']),
      description: serializer.fromJson<String?>(json['description']),
      attendeeEmails: serializer.fromJson<String?>(json['attendee_emails']),
      lastSynced: serializer.fromJson<int>(json['last_synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'event_id': serializer.toJson<String>(eventId),
      'calendar_id': serializer.toJson<String>(calendarId),
      'title': serializer.toJson<String>(title),
      'start_time': serializer.toJson<int>(startTime),
      'end_time': serializer.toJson<int>(endTime),
      'location': serializer.toJson<String?>(location),
      'description': serializer.toJson<String?>(description),
      'attendee_emails': serializer.toJson<String?>(attendeeEmails),
      'last_synced': serializer.toJson<int>(lastSynced),
    };
  }

  CachedCalendarEvent copyWith({
    String? eventId,
    String? calendarId,
    String? title,
    int? startTime,
    int? endTime,
    Value<String?> location = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<String?> attendeeEmails = const Value.absent(),
    int? lastSynced,
  }) => CachedCalendarEvent(
    eventId: eventId ?? this.eventId,
    calendarId: calendarId ?? this.calendarId,
    title: title ?? this.title,
    startTime: startTime ?? this.startTime,
    endTime: endTime ?? this.endTime,
    location: location.present ? location.value : this.location,
    description: description.present ? description.value : this.description,
    attendeeEmails: attendeeEmails.present
        ? attendeeEmails.value
        : this.attendeeEmails,
    lastSynced: lastSynced ?? this.lastSynced,
  );
  CachedCalendarEvent copyWithCompanion(CachedCalendarEventsCompanion data) {
    return CachedCalendarEvent(
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      calendarId: data.calendarId.present
          ? data.calendarId.value
          : this.calendarId,
      title: data.title.present ? data.title.value : this.title,
      startTime: data.startTime.present ? data.startTime.value : this.startTime,
      endTime: data.endTime.present ? data.endTime.value : this.endTime,
      location: data.location.present ? data.location.value : this.location,
      description: data.description.present
          ? data.description.value
          : this.description,
      attendeeEmails: data.attendeeEmails.present
          ? data.attendeeEmails.value
          : this.attendeeEmails,
      lastSynced: data.lastSynced.present
          ? data.lastSynced.value
          : this.lastSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedCalendarEvent(')
          ..write('eventId: $eventId, ')
          ..write('calendarId: $calendarId, ')
          ..write('title: $title, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('location: $location, ')
          ..write('description: $description, ')
          ..write('attendeeEmails: $attendeeEmails, ')
          ..write('lastSynced: $lastSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    eventId,
    calendarId,
    title,
    startTime,
    endTime,
    location,
    description,
    attendeeEmails,
    lastSynced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedCalendarEvent &&
          other.eventId == this.eventId &&
          other.calendarId == this.calendarId &&
          other.title == this.title &&
          other.startTime == this.startTime &&
          other.endTime == this.endTime &&
          other.location == this.location &&
          other.description == this.description &&
          other.attendeeEmails == this.attendeeEmails &&
          other.lastSynced == this.lastSynced);
}

class CachedCalendarEventsCompanion
    extends UpdateCompanion<CachedCalendarEvent> {
  final Value<String> eventId;
  final Value<String> calendarId;
  final Value<String> title;
  final Value<int> startTime;
  final Value<int> endTime;
  final Value<String?> location;
  final Value<String?> description;
  final Value<String?> attendeeEmails;
  final Value<int> lastSynced;
  final Value<int> rowid;
  const CachedCalendarEventsCompanion({
    this.eventId = const Value.absent(),
    this.calendarId = const Value.absent(),
    this.title = const Value.absent(),
    this.startTime = const Value.absent(),
    this.endTime = const Value.absent(),
    this.location = const Value.absent(),
    this.description = const Value.absent(),
    this.attendeeEmails = const Value.absent(),
    this.lastSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedCalendarEventsCompanion.insert({
    required String eventId,
    required String calendarId,
    required String title,
    required int startTime,
    required int endTime,
    this.location = const Value.absent(),
    this.description = const Value.absent(),
    this.attendeeEmails = const Value.absent(),
    required int lastSynced,
    this.rowid = const Value.absent(),
  }) : eventId = Value(eventId),
       calendarId = Value(calendarId),
       title = Value(title),
       startTime = Value(startTime),
       endTime = Value(endTime),
       lastSynced = Value(lastSynced);
  static Insertable<CachedCalendarEvent> custom({
    Expression<String>? eventId,
    Expression<String>? calendarId,
    Expression<String>? title,
    Expression<int>? startTime,
    Expression<int>? endTime,
    Expression<String>? location,
    Expression<String>? description,
    Expression<String>? attendeeEmails,
    Expression<int>? lastSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (eventId != null) 'event_id': eventId,
      if (calendarId != null) 'calendar_id': calendarId,
      if (title != null) 'title': title,
      if (startTime != null) 'start_time': startTime,
      if (endTime != null) 'end_time': endTime,
      if (location != null) 'location': location,
      if (description != null) 'description': description,
      if (attendeeEmails != null) 'attendee_emails': attendeeEmails,
      if (lastSynced != null) 'last_synced': lastSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedCalendarEventsCompanion copyWith({
    Value<String>? eventId,
    Value<String>? calendarId,
    Value<String>? title,
    Value<int>? startTime,
    Value<int>? endTime,
    Value<String?>? location,
    Value<String?>? description,
    Value<String?>? attendeeEmails,
    Value<int>? lastSynced,
    Value<int>? rowid,
  }) {
    return CachedCalendarEventsCompanion(
      eventId: eventId ?? this.eventId,
      calendarId: calendarId ?? this.calendarId,
      title: title ?? this.title,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      location: location ?? this.location,
      description: description ?? this.description,
      attendeeEmails: attendeeEmails ?? this.attendeeEmails,
      lastSynced: lastSynced ?? this.lastSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (calendarId.present) {
      map['calendar_id'] = Variable<String>(calendarId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (startTime.present) {
      map['start_time'] = Variable<int>(startTime.value);
    }
    if (endTime.present) {
      map['end_time'] = Variable<int>(endTime.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (attendeeEmails.present) {
      map['attendee_emails'] = Variable<String>(attendeeEmails.value);
    }
    if (lastSynced.present) {
      map['last_synced'] = Variable<int>(lastSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedCalendarEventsCompanion(')
          ..write('eventId: $eventId, ')
          ..write('calendarId: $calendarId, ')
          ..write('title: $title, ')
          ..write('startTime: $startTime, ')
          ..write('endTime: $endTime, ')
          ..write('location: $location, ')
          ..write('description: $description, ')
          ..write('attendeeEmails: $attendeeEmails, ')
          ..write('lastSynced: $lastSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class CachedContacts extends Table
    with TableInfo<CachedContacts, CachedContact> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  CachedContacts(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _displayNameMeta = const VerificationMeta(
    'displayName',
  );
  late final GeneratedColumn<String> displayName = GeneratedColumn<String>(
    'display_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _phonesMeta = const VerificationMeta('phones');
  late final GeneratedColumn<String> phones = GeneratedColumn<String>(
    'phones',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _emailsMeta = const VerificationMeta('emails');
  late final GeneratedColumn<String> emails = GeneratedColumn<String>(
    'emails',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _lastSyncedMeta = const VerificationMeta(
    'lastSynced',
  );
  late final GeneratedColumn<int> lastSynced = GeneratedColumn<int>(
    'last_synced',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    displayName,
    phones,
    emails,
    lastSynced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cached_contacts';
  @override
  VerificationContext validateIntegrity(
    Insertable<CachedContact> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('display_name')) {
      context.handle(
        _displayNameMeta,
        displayName.isAcceptableOrUnknown(
          data['display_name']!,
          _displayNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayNameMeta);
    }
    if (data.containsKey('phones')) {
      context.handle(
        _phonesMeta,
        phones.isAcceptableOrUnknown(data['phones']!, _phonesMeta),
      );
    }
    if (data.containsKey('emails')) {
      context.handle(
        _emailsMeta,
        emails.isAcceptableOrUnknown(data['emails']!, _emailsMeta),
      );
    }
    if (data.containsKey('last_synced')) {
      context.handle(
        _lastSyncedMeta,
        lastSynced.isAcceptableOrUnknown(data['last_synced']!, _lastSyncedMeta),
      );
    } else if (isInserting) {
      context.missing(_lastSyncedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CachedContact map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CachedContact(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      displayName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}display_name'],
      )!,
      phones: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phones'],
      ),
      emails: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}emails'],
      ),
      lastSynced: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_synced'],
      )!,
    );
  }

  @override
  CachedContacts createAlias(String alias) {
    return CachedContacts(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class CachedContact extends DataClass implements Insertable<CachedContact> {
  final String id;
  final String displayName;
  final String? phones;
  final String? emails;
  final int lastSynced;
  const CachedContact({
    required this.id,
    required this.displayName,
    this.phones,
    this.emails,
    required this.lastSynced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['display_name'] = Variable<String>(displayName);
    if (!nullToAbsent || phones != null) {
      map['phones'] = Variable<String>(phones);
    }
    if (!nullToAbsent || emails != null) {
      map['emails'] = Variable<String>(emails);
    }
    map['last_synced'] = Variable<int>(lastSynced);
    return map;
  }

  CachedContactsCompanion toCompanion(bool nullToAbsent) {
    return CachedContactsCompanion(
      id: Value(id),
      displayName: Value(displayName),
      phones: phones == null && nullToAbsent
          ? const Value.absent()
          : Value(phones),
      emails: emails == null && nullToAbsent
          ? const Value.absent()
          : Value(emails),
      lastSynced: Value(lastSynced),
    );
  }

  factory CachedContact.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CachedContact(
      id: serializer.fromJson<String>(json['id']),
      displayName: serializer.fromJson<String>(json['display_name']),
      phones: serializer.fromJson<String?>(json['phones']),
      emails: serializer.fromJson<String?>(json['emails']),
      lastSynced: serializer.fromJson<int>(json['last_synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'display_name': serializer.toJson<String>(displayName),
      'phones': serializer.toJson<String?>(phones),
      'emails': serializer.toJson<String?>(emails),
      'last_synced': serializer.toJson<int>(lastSynced),
    };
  }

  CachedContact copyWith({
    String? id,
    String? displayName,
    Value<String?> phones = const Value.absent(),
    Value<String?> emails = const Value.absent(),
    int? lastSynced,
  }) => CachedContact(
    id: id ?? this.id,
    displayName: displayName ?? this.displayName,
    phones: phones.present ? phones.value : this.phones,
    emails: emails.present ? emails.value : this.emails,
    lastSynced: lastSynced ?? this.lastSynced,
  );
  CachedContact copyWithCompanion(CachedContactsCompanion data) {
    return CachedContact(
      id: data.id.present ? data.id.value : this.id,
      displayName: data.displayName.present
          ? data.displayName.value
          : this.displayName,
      phones: data.phones.present ? data.phones.value : this.phones,
      emails: data.emails.present ? data.emails.value : this.emails,
      lastSynced: data.lastSynced.present
          ? data.lastSynced.value
          : this.lastSynced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CachedContact(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('phones: $phones, ')
          ..write('emails: $emails, ')
          ..write('lastSynced: $lastSynced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, displayName, phones, emails, lastSynced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CachedContact &&
          other.id == this.id &&
          other.displayName == this.displayName &&
          other.phones == this.phones &&
          other.emails == this.emails &&
          other.lastSynced == this.lastSynced);
}

class CachedContactsCompanion extends UpdateCompanion<CachedContact> {
  final Value<String> id;
  final Value<String> displayName;
  final Value<String?> phones;
  final Value<String?> emails;
  final Value<int> lastSynced;
  final Value<int> rowid;
  const CachedContactsCompanion({
    this.id = const Value.absent(),
    this.displayName = const Value.absent(),
    this.phones = const Value.absent(),
    this.emails = const Value.absent(),
    this.lastSynced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CachedContactsCompanion.insert({
    required String id,
    required String displayName,
    this.phones = const Value.absent(),
    this.emails = const Value.absent(),
    required int lastSynced,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       displayName = Value(displayName),
       lastSynced = Value(lastSynced);
  static Insertable<CachedContact> custom({
    Expression<String>? id,
    Expression<String>? displayName,
    Expression<String>? phones,
    Expression<String>? emails,
    Expression<int>? lastSynced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (displayName != null) 'display_name': displayName,
      if (phones != null) 'phones': phones,
      if (emails != null) 'emails': emails,
      if (lastSynced != null) 'last_synced': lastSynced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CachedContactsCompanion copyWith({
    Value<String>? id,
    Value<String>? displayName,
    Value<String?>? phones,
    Value<String?>? emails,
    Value<int>? lastSynced,
    Value<int>? rowid,
  }) {
    return CachedContactsCompanion(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      phones: phones ?? this.phones,
      emails: emails ?? this.emails,
      lastSynced: lastSynced ?? this.lastSynced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (displayName.present) {
      map['display_name'] = Variable<String>(displayName.value);
    }
    if (phones.present) {
      map['phones'] = Variable<String>(phones.value);
    }
    if (emails.present) {
      map['emails'] = Variable<String>(emails.value);
    }
    if (lastSynced.present) {
      map['last_synced'] = Variable<int>(lastSynced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CachedContactsCompanion(')
          ..write('id: $id, ')
          ..write('displayName: $displayName, ')
          ..write('phones: $phones, ')
          ..write('emails: $emails, ')
          ..write('lastSynced: $lastSynced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class VesselTools extends Table with TableInfo<VesselTools, VesselTool> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  VesselTools(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL PRIMARY KEY AUTOINCREMENT',
  );
  static const VerificationMeta _vesselIdMeta = const VerificationMeta(
    'vesselId',
  );
  late final GeneratedColumn<String> vesselId = GeneratedColumn<String>(
    'vessel_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _toolNameMeta = const VerificationMeta(
    'toolName',
  );
  late final GeneratedColumn<String> toolName = GeneratedColumn<String>(
    'tool_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _capabilityGroupMeta = const VerificationMeta(
    'capabilityGroup',
  );
  late final GeneratedColumn<String> capabilityGroup = GeneratedColumn<String>(
    'capability_group',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  late final GeneratedColumn<int> cachedAt = GeneratedColumn<int>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    vesselId,
    toolName,
    description,
    capabilityGroup,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vessel_tools';
  @override
  VerificationContext validateIntegrity(
    Insertable<VesselTool> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('vessel_id')) {
      context.handle(
        _vesselIdMeta,
        vesselId.isAcceptableOrUnknown(data['vessel_id']!, _vesselIdMeta),
      );
    } else if (isInserting) {
      context.missing(_vesselIdMeta);
    }
    if (data.containsKey('tool_name')) {
      context.handle(
        _toolNameMeta,
        toolName.isAcceptableOrUnknown(data['tool_name']!, _toolNameMeta),
      );
    } else if (isInserting) {
      context.missing(_toolNameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('capability_group')) {
      context.handle(
        _capabilityGroupMeta,
        capabilityGroup.isAcceptableOrUnknown(
          data['capability_group']!,
          _capabilityGroupMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_capabilityGroupMeta);
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {vesselId, toolName},
  ];
  @override
  VesselTool map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VesselTool(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      vesselId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vessel_id'],
      )!,
      toolName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tool_name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      capabilityGroup: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}capability_group'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  VesselTools createAlias(String alias) {
    return VesselTools(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const ['UNIQUE(vessel_id, tool_name)'];
  @override
  bool get dontWriteConstraints => true;
}

class VesselTool extends DataClass implements Insertable<VesselTool> {
  final int id;
  final String vesselId;
  final String toolName;
  final String? description;
  final String capabilityGroup;
  final int cachedAt;
  const VesselTool({
    required this.id,
    required this.vesselId,
    required this.toolName,
    this.description,
    required this.capabilityGroup,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['vessel_id'] = Variable<String>(vesselId);
    map['tool_name'] = Variable<String>(toolName);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['capability_group'] = Variable<String>(capabilityGroup);
    map['cached_at'] = Variable<int>(cachedAt);
    return map;
  }

  VesselToolsCompanion toCompanion(bool nullToAbsent) {
    return VesselToolsCompanion(
      id: Value(id),
      vesselId: Value(vesselId),
      toolName: Value(toolName),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      capabilityGroup: Value(capabilityGroup),
      cachedAt: Value(cachedAt),
    );
  }

  factory VesselTool.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VesselTool(
      id: serializer.fromJson<int>(json['id']),
      vesselId: serializer.fromJson<String>(json['vessel_id']),
      toolName: serializer.fromJson<String>(json['tool_name']),
      description: serializer.fromJson<String?>(json['description']),
      capabilityGroup: serializer.fromJson<String>(json['capability_group']),
      cachedAt: serializer.fromJson<int>(json['cached_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'vessel_id': serializer.toJson<String>(vesselId),
      'tool_name': serializer.toJson<String>(toolName),
      'description': serializer.toJson<String?>(description),
      'capability_group': serializer.toJson<String>(capabilityGroup),
      'cached_at': serializer.toJson<int>(cachedAt),
    };
  }

  VesselTool copyWith({
    int? id,
    String? vesselId,
    String? toolName,
    Value<String?> description = const Value.absent(),
    String? capabilityGroup,
    int? cachedAt,
  }) => VesselTool(
    id: id ?? this.id,
    vesselId: vesselId ?? this.vesselId,
    toolName: toolName ?? this.toolName,
    description: description.present ? description.value : this.description,
    capabilityGroup: capabilityGroup ?? this.capabilityGroup,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  VesselTool copyWithCompanion(VesselToolsCompanion data) {
    return VesselTool(
      id: data.id.present ? data.id.value : this.id,
      vesselId: data.vesselId.present ? data.vesselId.value : this.vesselId,
      toolName: data.toolName.present ? data.toolName.value : this.toolName,
      description: data.description.present
          ? data.description.value
          : this.description,
      capabilityGroup: data.capabilityGroup.present
          ? data.capabilityGroup.value
          : this.capabilityGroup,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VesselTool(')
          ..write('id: $id, ')
          ..write('vesselId: $vesselId, ')
          ..write('toolName: $toolName, ')
          ..write('description: $description, ')
          ..write('capabilityGroup: $capabilityGroup, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    vesselId,
    toolName,
    description,
    capabilityGroup,
    cachedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VesselTool &&
          other.id == this.id &&
          other.vesselId == this.vesselId &&
          other.toolName == this.toolName &&
          other.description == this.description &&
          other.capabilityGroup == this.capabilityGroup &&
          other.cachedAt == this.cachedAt);
}

class VesselToolsCompanion extends UpdateCompanion<VesselTool> {
  final Value<int> id;
  final Value<String> vesselId;
  final Value<String> toolName;
  final Value<String?> description;
  final Value<String> capabilityGroup;
  final Value<int> cachedAt;
  const VesselToolsCompanion({
    this.id = const Value.absent(),
    this.vesselId = const Value.absent(),
    this.toolName = const Value.absent(),
    this.description = const Value.absent(),
    this.capabilityGroup = const Value.absent(),
    this.cachedAt = const Value.absent(),
  });
  VesselToolsCompanion.insert({
    this.id = const Value.absent(),
    required String vesselId,
    required String toolName,
    this.description = const Value.absent(),
    required String capabilityGroup,
    required int cachedAt,
  }) : vesselId = Value(vesselId),
       toolName = Value(toolName),
       capabilityGroup = Value(capabilityGroup),
       cachedAt = Value(cachedAt);
  static Insertable<VesselTool> custom({
    Expression<int>? id,
    Expression<String>? vesselId,
    Expression<String>? toolName,
    Expression<String>? description,
    Expression<String>? capabilityGroup,
    Expression<int>? cachedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vesselId != null) 'vessel_id': vesselId,
      if (toolName != null) 'tool_name': toolName,
      if (description != null) 'description': description,
      if (capabilityGroup != null) 'capability_group': capabilityGroup,
      if (cachedAt != null) 'cached_at': cachedAt,
    });
  }

  VesselToolsCompanion copyWith({
    Value<int>? id,
    Value<String>? vesselId,
    Value<String>? toolName,
    Value<String?>? description,
    Value<String>? capabilityGroup,
    Value<int>? cachedAt,
  }) {
    return VesselToolsCompanion(
      id: id ?? this.id,
      vesselId: vesselId ?? this.vesselId,
      toolName: toolName ?? this.toolName,
      description: description ?? this.description,
      capabilityGroup: capabilityGroup ?? this.capabilityGroup,
      cachedAt: cachedAt ?? this.cachedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (vesselId.present) {
      map['vessel_id'] = Variable<String>(vesselId.value);
    }
    if (toolName.present) {
      map['tool_name'] = Variable<String>(toolName.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (capabilityGroup.present) {
      map['capability_group'] = Variable<String>(capabilityGroup.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<int>(cachedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VesselToolsCompanion(')
          ..write('id: $id, ')
          ..write('vesselId: $vesselId, ')
          ..write('toolName: $toolName, ')
          ..write('description: $description, ')
          ..write('capabilityGroup: $capabilityGroup, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }
}

class VesselTasks extends Table with TableInfo<VesselTasks, VesselTask> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  VesselTasks(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _conversationIdMeta = const VerificationMeta(
    'conversationId',
  );
  late final GeneratedColumn<String> conversationId = GeneratedColumn<String>(
    'conversation_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _vesselTypeMeta = const VerificationMeta(
    'vesselType',
  );
  late final GeneratedColumn<String> vesselType = GeneratedColumn<String>(
    'vessel_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _toolNameMeta = const VerificationMeta(
    'toolName',
  );
  late final GeneratedColumn<String> toolName = GeneratedColumn<String>(
    'tool_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'proposed\'',
    defaultValue: const CustomExpression('\'proposed\''),
  );
  static const VerificationMeta _resultJsonMeta = const VerificationMeta(
    'resultJson',
  );
  late final GeneratedColumn<String> resultJson = GeneratedColumn<String>(
    'result_json',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _errorMessageMeta = const VerificationMeta(
    'errorMessage',
  );
  late final GeneratedColumn<String> errorMessage = GeneratedColumn<String>(
    'error_message',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  late final GeneratedColumn<int> completedAt = GeneratedColumn<int>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    conversationId,
    vesselType,
    toolName,
    description,
    status,
    resultJson,
    errorMessage,
    createdAt,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vessel_tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<VesselTask> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
        _conversationIdMeta,
        conversationId.isAcceptableOrUnknown(
          data['conversation_id']!,
          _conversationIdMeta,
        ),
      );
    }
    if (data.containsKey('vessel_type')) {
      context.handle(
        _vesselTypeMeta,
        vesselType.isAcceptableOrUnknown(data['vessel_type']!, _vesselTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_vesselTypeMeta);
    }
    if (data.containsKey('tool_name')) {
      context.handle(
        _toolNameMeta,
        toolName.isAcceptableOrUnknown(data['tool_name']!, _toolNameMeta),
      );
    } else if (isInserting) {
      context.missing(_toolNameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('result_json')) {
      context.handle(
        _resultJsonMeta,
        resultJson.isAcceptableOrUnknown(data['result_json']!, _resultJsonMeta),
      );
    }
    if (data.containsKey('error_message')) {
      context.handle(
        _errorMessageMeta,
        errorMessage.isAcceptableOrUnknown(
          data['error_message']!,
          _errorMessageMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VesselTask map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VesselTask(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      conversationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conversation_id'],
      ),
      vesselType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vessel_type'],
      )!,
      toolName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tool_name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      resultJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}result_json'],
      ),
      errorMessage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error_message'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  VesselTasks createAlias(String alias) {
    return VesselTasks(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class VesselTask extends DataClass implements Insertable<VesselTask> {
  final String id;
  final String? conversationId;
  final String vesselType;
  final String toolName;
  final String description;
  final String status;
  final String? resultJson;
  final String? errorMessage;
  final int createdAt;
  final int? completedAt;
  const VesselTask({
    required this.id,
    this.conversationId,
    required this.vesselType,
    required this.toolName,
    required this.description,
    required this.status,
    this.resultJson,
    this.errorMessage,
    required this.createdAt,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || conversationId != null) {
      map['conversation_id'] = Variable<String>(conversationId);
    }
    map['vessel_type'] = Variable<String>(vesselType);
    map['tool_name'] = Variable<String>(toolName);
    map['description'] = Variable<String>(description);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || resultJson != null) {
      map['result_json'] = Variable<String>(resultJson);
    }
    if (!nullToAbsent || errorMessage != null) {
      map['error_message'] = Variable<String>(errorMessage);
    }
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<int>(completedAt);
    }
    return map;
  }

  VesselTasksCompanion toCompanion(bool nullToAbsent) {
    return VesselTasksCompanion(
      id: Value(id),
      conversationId: conversationId == null && nullToAbsent
          ? const Value.absent()
          : Value(conversationId),
      vesselType: Value(vesselType),
      toolName: Value(toolName),
      description: Value(description),
      status: Value(status),
      resultJson: resultJson == null && nullToAbsent
          ? const Value.absent()
          : Value(resultJson),
      errorMessage: errorMessage == null && nullToAbsent
          ? const Value.absent()
          : Value(errorMessage),
      createdAt: Value(createdAt),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory VesselTask.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VesselTask(
      id: serializer.fromJson<String>(json['id']),
      conversationId: serializer.fromJson<String?>(json['conversation_id']),
      vesselType: serializer.fromJson<String>(json['vessel_type']),
      toolName: serializer.fromJson<String>(json['tool_name']),
      description: serializer.fromJson<String>(json['description']),
      status: serializer.fromJson<String>(json['status']),
      resultJson: serializer.fromJson<String?>(json['result_json']),
      errorMessage: serializer.fromJson<String?>(json['error_message']),
      createdAt: serializer.fromJson<int>(json['created_at']),
      completedAt: serializer.fromJson<int?>(json['completed_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'conversation_id': serializer.toJson<String?>(conversationId),
      'vessel_type': serializer.toJson<String>(vesselType),
      'tool_name': serializer.toJson<String>(toolName),
      'description': serializer.toJson<String>(description),
      'status': serializer.toJson<String>(status),
      'result_json': serializer.toJson<String?>(resultJson),
      'error_message': serializer.toJson<String?>(errorMessage),
      'created_at': serializer.toJson<int>(createdAt),
      'completed_at': serializer.toJson<int?>(completedAt),
    };
  }

  VesselTask copyWith({
    String? id,
    Value<String?> conversationId = const Value.absent(),
    String? vesselType,
    String? toolName,
    String? description,
    String? status,
    Value<String?> resultJson = const Value.absent(),
    Value<String?> errorMessage = const Value.absent(),
    int? createdAt,
    Value<int?> completedAt = const Value.absent(),
  }) => VesselTask(
    id: id ?? this.id,
    conversationId: conversationId.present
        ? conversationId.value
        : this.conversationId,
    vesselType: vesselType ?? this.vesselType,
    toolName: toolName ?? this.toolName,
    description: description ?? this.description,
    status: status ?? this.status,
    resultJson: resultJson.present ? resultJson.value : this.resultJson,
    errorMessage: errorMessage.present ? errorMessage.value : this.errorMessage,
    createdAt: createdAt ?? this.createdAt,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  VesselTask copyWithCompanion(VesselTasksCompanion data) {
    return VesselTask(
      id: data.id.present ? data.id.value : this.id,
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      vesselType: data.vesselType.present
          ? data.vesselType.value
          : this.vesselType,
      toolName: data.toolName.present ? data.toolName.value : this.toolName,
      description: data.description.present
          ? data.description.value
          : this.description,
      status: data.status.present ? data.status.value : this.status,
      resultJson: data.resultJson.present
          ? data.resultJson.value
          : this.resultJson,
      errorMessage: data.errorMessage.present
          ? data.errorMessage.value
          : this.errorMessage,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VesselTask(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('vesselType: $vesselType, ')
          ..write('toolName: $toolName, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('resultJson: $resultJson, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    conversationId,
    vesselType,
    toolName,
    description,
    status,
    resultJson,
    errorMessage,
    createdAt,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VesselTask &&
          other.id == this.id &&
          other.conversationId == this.conversationId &&
          other.vesselType == this.vesselType &&
          other.toolName == this.toolName &&
          other.description == this.description &&
          other.status == this.status &&
          other.resultJson == this.resultJson &&
          other.errorMessage == this.errorMessage &&
          other.createdAt == this.createdAt &&
          other.completedAt == this.completedAt);
}

class VesselTasksCompanion extends UpdateCompanion<VesselTask> {
  final Value<String> id;
  final Value<String?> conversationId;
  final Value<String> vesselType;
  final Value<String> toolName;
  final Value<String> description;
  final Value<String> status;
  final Value<String?> resultJson;
  final Value<String?> errorMessage;
  final Value<int> createdAt;
  final Value<int?> completedAt;
  final Value<int> rowid;
  const VesselTasksCompanion({
    this.id = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.vesselType = const Value.absent(),
    this.toolName = const Value.absent(),
    this.description = const Value.absent(),
    this.status = const Value.absent(),
    this.resultJson = const Value.absent(),
    this.errorMessage = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VesselTasksCompanion.insert({
    required String id,
    this.conversationId = const Value.absent(),
    required String vesselType,
    required String toolName,
    required String description,
    this.status = const Value.absent(),
    this.resultJson = const Value.absent(),
    this.errorMessage = const Value.absent(),
    required int createdAt,
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       vesselType = Value(vesselType),
       toolName = Value(toolName),
       description = Value(description),
       createdAt = Value(createdAt);
  static Insertable<VesselTask> custom({
    Expression<String>? id,
    Expression<String>? conversationId,
    Expression<String>? vesselType,
    Expression<String>? toolName,
    Expression<String>? description,
    Expression<String>? status,
    Expression<String>? resultJson,
    Expression<String>? errorMessage,
    Expression<int>? createdAt,
    Expression<int>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (conversationId != null) 'conversation_id': conversationId,
      if (vesselType != null) 'vessel_type': vesselType,
      if (toolName != null) 'tool_name': toolName,
      if (description != null) 'description': description,
      if (status != null) 'status': status,
      if (resultJson != null) 'result_json': resultJson,
      if (errorMessage != null) 'error_message': errorMessage,
      if (createdAt != null) 'created_at': createdAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VesselTasksCompanion copyWith({
    Value<String>? id,
    Value<String?>? conversationId,
    Value<String>? vesselType,
    Value<String>? toolName,
    Value<String>? description,
    Value<String>? status,
    Value<String?>? resultJson,
    Value<String?>? errorMessage,
    Value<int>? createdAt,
    Value<int?>? completedAt,
    Value<int>? rowid,
  }) {
    return VesselTasksCompanion(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      vesselType: vesselType ?? this.vesselType,
      toolName: toolName ?? this.toolName,
      description: description ?? this.description,
      status: status ?? this.status,
      resultJson: resultJson ?? this.resultJson,
      errorMessage: errorMessage ?? this.errorMessage,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<String>(conversationId.value);
    }
    if (vesselType.present) {
      map['vessel_type'] = Variable<String>(vesselType.value);
    }
    if (toolName.present) {
      map['tool_name'] = Variable<String>(toolName.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (resultJson.present) {
      map['result_json'] = Variable<String>(resultJson.value);
    }
    if (errorMessage.present) {
      map['error_message'] = Variable<String>(errorMessage.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VesselTasksCompanion(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('vesselType: $vesselType, ')
          ..write('toolName: $toolName, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('resultJson: $resultJson, ')
          ..write('errorMessage: $errorMessage, ')
          ..write('createdAt: $createdAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class VesselConfigs extends Table with TableInfo<VesselConfigs, VesselConfig> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  VesselConfigs(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _vesselTypeMeta = const VerificationMeta(
    'vesselType',
  );
  late final GeneratedColumn<String> vesselType = GeneratedColumn<String>(
    'vessel_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _hostMeta = const VerificationMeta('host');
  late final GeneratedColumn<String> host = GeneratedColumn<String>(
    'host',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _portMeta = const VerificationMeta('port');
  late final GeneratedColumn<int> port = GeneratedColumn<int>(
    'port',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _tokenRefMeta = const VerificationMeta(
    'tokenRef',
  );
  late final GeneratedColumn<String> tokenRef = GeneratedColumn<String>(
    'token_ref',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  late final GeneratedColumn<int> isActive = GeneratedColumn<int>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0',
    defaultValue: const CustomExpression('0'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    vesselType,
    host,
    port,
    tokenRef,
    isActive,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vessel_configs';
  @override
  VerificationContext validateIntegrity(
    Insertable<VesselConfig> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('vessel_type')) {
      context.handle(
        _vesselTypeMeta,
        vesselType.isAcceptableOrUnknown(data['vessel_type']!, _vesselTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_vesselTypeMeta);
    }
    if (data.containsKey('host')) {
      context.handle(
        _hostMeta,
        host.isAcceptableOrUnknown(data['host']!, _hostMeta),
      );
    } else if (isInserting) {
      context.missing(_hostMeta);
    }
    if (data.containsKey('port')) {
      context.handle(
        _portMeta,
        port.isAcceptableOrUnknown(data['port']!, _portMeta),
      );
    } else if (isInserting) {
      context.missing(_portMeta);
    }
    if (data.containsKey('token_ref')) {
      context.handle(
        _tokenRefMeta,
        tokenRef.isAcceptableOrUnknown(data['token_ref']!, _tokenRefMeta),
      );
    } else if (isInserting) {
      context.missing(_tokenRefMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VesselConfig map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VesselConfig(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      vesselType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vessel_type'],
      )!,
      host: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}host'],
      )!,
      port: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}port'],
      )!,
      tokenRef: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}token_ref'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  VesselConfigs createAlias(String alias) {
    return VesselConfigs(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class VesselConfig extends DataClass implements Insertable<VesselConfig> {
  final String id;
  final String vesselType;
  final String host;
  final int port;
  final String tokenRef;
  final int isActive;
  final int createdAt;
  final int updatedAt;
  const VesselConfig({
    required this.id,
    required this.vesselType,
    required this.host,
    required this.port,
    required this.tokenRef,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['vessel_type'] = Variable<String>(vesselType);
    map['host'] = Variable<String>(host);
    map['port'] = Variable<int>(port);
    map['token_ref'] = Variable<String>(tokenRef);
    map['is_active'] = Variable<int>(isActive);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  VesselConfigsCompanion toCompanion(bool nullToAbsent) {
    return VesselConfigsCompanion(
      id: Value(id),
      vesselType: Value(vesselType),
      host: Value(host),
      port: Value(port),
      tokenRef: Value(tokenRef),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory VesselConfig.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VesselConfig(
      id: serializer.fromJson<String>(json['id']),
      vesselType: serializer.fromJson<String>(json['vessel_type']),
      host: serializer.fromJson<String>(json['host']),
      port: serializer.fromJson<int>(json['port']),
      tokenRef: serializer.fromJson<String>(json['token_ref']),
      isActive: serializer.fromJson<int>(json['is_active']),
      createdAt: serializer.fromJson<int>(json['created_at']),
      updatedAt: serializer.fromJson<int>(json['updated_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'vessel_type': serializer.toJson<String>(vesselType),
      'host': serializer.toJson<String>(host),
      'port': serializer.toJson<int>(port),
      'token_ref': serializer.toJson<String>(tokenRef),
      'is_active': serializer.toJson<int>(isActive),
      'created_at': serializer.toJson<int>(createdAt),
      'updated_at': serializer.toJson<int>(updatedAt),
    };
  }

  VesselConfig copyWith({
    String? id,
    String? vesselType,
    String? host,
    int? port,
    String? tokenRef,
    int? isActive,
    int? createdAt,
    int? updatedAt,
  }) => VesselConfig(
    id: id ?? this.id,
    vesselType: vesselType ?? this.vesselType,
    host: host ?? this.host,
    port: port ?? this.port,
    tokenRef: tokenRef ?? this.tokenRef,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  VesselConfig copyWithCompanion(VesselConfigsCompanion data) {
    return VesselConfig(
      id: data.id.present ? data.id.value : this.id,
      vesselType: data.vesselType.present
          ? data.vesselType.value
          : this.vesselType,
      host: data.host.present ? data.host.value : this.host,
      port: data.port.present ? data.port.value : this.port,
      tokenRef: data.tokenRef.present ? data.tokenRef.value : this.tokenRef,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VesselConfig(')
          ..write('id: $id, ')
          ..write('vesselType: $vesselType, ')
          ..write('host: $host, ')
          ..write('port: $port, ')
          ..write('tokenRef: $tokenRef, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    vesselType,
    host,
    port,
    tokenRef,
    isActive,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VesselConfig &&
          other.id == this.id &&
          other.vesselType == this.vesselType &&
          other.host == this.host &&
          other.port == this.port &&
          other.tokenRef == this.tokenRef &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class VesselConfigsCompanion extends UpdateCompanion<VesselConfig> {
  final Value<String> id;
  final Value<String> vesselType;
  final Value<String> host;
  final Value<int> port;
  final Value<String> tokenRef;
  final Value<int> isActive;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const VesselConfigsCompanion({
    this.id = const Value.absent(),
    this.vesselType = const Value.absent(),
    this.host = const Value.absent(),
    this.port = const Value.absent(),
    this.tokenRef = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VesselConfigsCompanion.insert({
    required String id,
    required String vesselType,
    required String host,
    required int port,
    required String tokenRef,
    this.isActive = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       vesselType = Value(vesselType),
       host = Value(host),
       port = Value(port),
       tokenRef = Value(tokenRef),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<VesselConfig> custom({
    Expression<String>? id,
    Expression<String>? vesselType,
    Expression<String>? host,
    Expression<int>? port,
    Expression<String>? tokenRef,
    Expression<int>? isActive,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (vesselType != null) 'vessel_type': vesselType,
      if (host != null) 'host': host,
      if (port != null) 'port': port,
      if (tokenRef != null) 'token_ref': tokenRef,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VesselConfigsCompanion copyWith({
    Value<String>? id,
    Value<String>? vesselType,
    Value<String>? host,
    Value<int>? port,
    Value<String>? tokenRef,
    Value<int>? isActive,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return VesselConfigsCompanion(
      id: id ?? this.id,
      vesselType: vesselType ?? this.vesselType,
      host: host ?? this.host,
      port: port ?? this.port,
      tokenRef: tokenRef ?? this.tokenRef,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (vesselType.present) {
      map['vessel_type'] = Variable<String>(vesselType.value);
    }
    if (host.present) {
      map['host'] = Variable<String>(host.value);
    }
    if (port.present) {
      map['port'] = Variable<int>(port.value);
    }
    if (tokenRef.present) {
      map['token_ref'] = Variable<String>(tokenRef.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<int>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VesselConfigsCompanion(')
          ..write('id: $id, ')
          ..write('vesselType: $vesselType, ')
          ..write('host: $host, ')
          ..write('port: $port, ')
          ..write('tokenRef: $tokenRef, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class ProfileTraits extends Table with TableInfo<ProfileTraits, ProfileTrait> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ProfileTraits(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _traitKeyMeta = const VerificationMeta(
    'traitKey',
  );
  late final GeneratedColumn<String> traitKey = GeneratedColumn<String>(
    'trait_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _traitValueMeta = const VerificationMeta(
    'traitValue',
  );
  late final GeneratedColumn<String> traitValue = GeneratedColumn<String>(
    'trait_value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _confidenceMeta = const VerificationMeta(
    'confidence',
  );
  late final GeneratedColumn<double> confidence = GeneratedColumn<double>(
    'confidence',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 0.5',
    defaultValue: const CustomExpression('0.5'),
  );
  static const VerificationMeta _evidenceCountMeta = const VerificationMeta(
    'evidenceCount',
  );
  late final GeneratedColumn<int> evidenceCount = GeneratedColumn<int>(
    'evidence_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 1',
    defaultValue: const CustomExpression('1'),
  );
  static const VerificationMeta _firstObservedMeta = const VerificationMeta(
    'firstObserved',
  );
  late final GeneratedColumn<int> firstObserved = GeneratedColumn<int>(
    'first_observed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _lastObservedMeta = const VerificationMeta(
    'lastObserved',
  );
  late final GeneratedColumn<int> lastObserved = GeneratedColumn<int>(
    'last_observed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    category,
    traitKey,
    traitValue,
    confidence,
    evidenceCount,
    firstObserved,
    lastObserved,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profile_traits';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProfileTrait> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('trait_key')) {
      context.handle(
        _traitKeyMeta,
        traitKey.isAcceptableOrUnknown(data['trait_key']!, _traitKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_traitKeyMeta);
    }
    if (data.containsKey('trait_value')) {
      context.handle(
        _traitValueMeta,
        traitValue.isAcceptableOrUnknown(data['trait_value']!, _traitValueMeta),
      );
    } else if (isInserting) {
      context.missing(_traitValueMeta);
    }
    if (data.containsKey('confidence')) {
      context.handle(
        _confidenceMeta,
        confidence.isAcceptableOrUnknown(data['confidence']!, _confidenceMeta),
      );
    }
    if (data.containsKey('evidence_count')) {
      context.handle(
        _evidenceCountMeta,
        evidenceCount.isAcceptableOrUnknown(
          data['evidence_count']!,
          _evidenceCountMeta,
        ),
      );
    }
    if (data.containsKey('first_observed')) {
      context.handle(
        _firstObservedMeta,
        firstObserved.isAcceptableOrUnknown(
          data['first_observed']!,
          _firstObservedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_firstObservedMeta);
    }
    if (data.containsKey('last_observed')) {
      context.handle(
        _lastObservedMeta,
        lastObserved.isAcceptableOrUnknown(
          data['last_observed']!,
          _lastObservedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastObservedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {category, traitKey},
  ];
  @override
  ProfileTrait map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileTrait(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      traitKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trait_key'],
      )!,
      traitValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}trait_value'],
      )!,
      confidence: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}confidence'],
      )!,
      evidenceCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}evidence_count'],
      )!,
      firstObserved: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}first_observed'],
      )!,
      lastObserved: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_observed'],
      )!,
    );
  }

  @override
  ProfileTraits createAlias(String alias) {
    return ProfileTraits(attachedDatabase, alias);
  }

  @override
  List<String> get customConstraints => const ['UNIQUE(category, trait_key)'];
  @override
  bool get dontWriteConstraints => true;
}

class ProfileTrait extends DataClass implements Insertable<ProfileTrait> {
  final String id;
  final String category;
  final String traitKey;
  final String traitValue;
  final double confidence;
  final int evidenceCount;
  final int firstObserved;
  final int lastObserved;
  const ProfileTrait({
    required this.id,
    required this.category,
    required this.traitKey,
    required this.traitValue,
    required this.confidence,
    required this.evidenceCount,
    required this.firstObserved,
    required this.lastObserved,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['category'] = Variable<String>(category);
    map['trait_key'] = Variable<String>(traitKey);
    map['trait_value'] = Variable<String>(traitValue);
    map['confidence'] = Variable<double>(confidence);
    map['evidence_count'] = Variable<int>(evidenceCount);
    map['first_observed'] = Variable<int>(firstObserved);
    map['last_observed'] = Variable<int>(lastObserved);
    return map;
  }

  ProfileTraitsCompanion toCompanion(bool nullToAbsent) {
    return ProfileTraitsCompanion(
      id: Value(id),
      category: Value(category),
      traitKey: Value(traitKey),
      traitValue: Value(traitValue),
      confidence: Value(confidence),
      evidenceCount: Value(evidenceCount),
      firstObserved: Value(firstObserved),
      lastObserved: Value(lastObserved),
    );
  }

  factory ProfileTrait.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileTrait(
      id: serializer.fromJson<String>(json['id']),
      category: serializer.fromJson<String>(json['category']),
      traitKey: serializer.fromJson<String>(json['trait_key']),
      traitValue: serializer.fromJson<String>(json['trait_value']),
      confidence: serializer.fromJson<double>(json['confidence']),
      evidenceCount: serializer.fromJson<int>(json['evidence_count']),
      firstObserved: serializer.fromJson<int>(json['first_observed']),
      lastObserved: serializer.fromJson<int>(json['last_observed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'category': serializer.toJson<String>(category),
      'trait_key': serializer.toJson<String>(traitKey),
      'trait_value': serializer.toJson<String>(traitValue),
      'confidence': serializer.toJson<double>(confidence),
      'evidence_count': serializer.toJson<int>(evidenceCount),
      'first_observed': serializer.toJson<int>(firstObserved),
      'last_observed': serializer.toJson<int>(lastObserved),
    };
  }

  ProfileTrait copyWith({
    String? id,
    String? category,
    String? traitKey,
    String? traitValue,
    double? confidence,
    int? evidenceCount,
    int? firstObserved,
    int? lastObserved,
  }) => ProfileTrait(
    id: id ?? this.id,
    category: category ?? this.category,
    traitKey: traitKey ?? this.traitKey,
    traitValue: traitValue ?? this.traitValue,
    confidence: confidence ?? this.confidence,
    evidenceCount: evidenceCount ?? this.evidenceCount,
    firstObserved: firstObserved ?? this.firstObserved,
    lastObserved: lastObserved ?? this.lastObserved,
  );
  ProfileTrait copyWithCompanion(ProfileTraitsCompanion data) {
    return ProfileTrait(
      id: data.id.present ? data.id.value : this.id,
      category: data.category.present ? data.category.value : this.category,
      traitKey: data.traitKey.present ? data.traitKey.value : this.traitKey,
      traitValue: data.traitValue.present
          ? data.traitValue.value
          : this.traitValue,
      confidence: data.confidence.present
          ? data.confidence.value
          : this.confidence,
      evidenceCount: data.evidenceCount.present
          ? data.evidenceCount.value
          : this.evidenceCount,
      firstObserved: data.firstObserved.present
          ? data.firstObserved.value
          : this.firstObserved,
      lastObserved: data.lastObserved.present
          ? data.lastObserved.value
          : this.lastObserved,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileTrait(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('traitKey: $traitKey, ')
          ..write('traitValue: $traitValue, ')
          ..write('confidence: $confidence, ')
          ..write('evidenceCount: $evidenceCount, ')
          ..write('firstObserved: $firstObserved, ')
          ..write('lastObserved: $lastObserved')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    category,
    traitKey,
    traitValue,
    confidence,
    evidenceCount,
    firstObserved,
    lastObserved,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileTrait &&
          other.id == this.id &&
          other.category == this.category &&
          other.traitKey == this.traitKey &&
          other.traitValue == this.traitValue &&
          other.confidence == this.confidence &&
          other.evidenceCount == this.evidenceCount &&
          other.firstObserved == this.firstObserved &&
          other.lastObserved == this.lastObserved);
}

class ProfileTraitsCompanion extends UpdateCompanion<ProfileTrait> {
  final Value<String> id;
  final Value<String> category;
  final Value<String> traitKey;
  final Value<String> traitValue;
  final Value<double> confidence;
  final Value<int> evidenceCount;
  final Value<int> firstObserved;
  final Value<int> lastObserved;
  final Value<int> rowid;
  const ProfileTraitsCompanion({
    this.id = const Value.absent(),
    this.category = const Value.absent(),
    this.traitKey = const Value.absent(),
    this.traitValue = const Value.absent(),
    this.confidence = const Value.absent(),
    this.evidenceCount = const Value.absent(),
    this.firstObserved = const Value.absent(),
    this.lastObserved = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfileTraitsCompanion.insert({
    required String id,
    required String category,
    required String traitKey,
    required String traitValue,
    this.confidence = const Value.absent(),
    this.evidenceCount = const Value.absent(),
    required int firstObserved,
    required int lastObserved,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       category = Value(category),
       traitKey = Value(traitKey),
       traitValue = Value(traitValue),
       firstObserved = Value(firstObserved),
       lastObserved = Value(lastObserved);
  static Insertable<ProfileTrait> custom({
    Expression<String>? id,
    Expression<String>? category,
    Expression<String>? traitKey,
    Expression<String>? traitValue,
    Expression<double>? confidence,
    Expression<int>? evidenceCount,
    Expression<int>? firstObserved,
    Expression<int>? lastObserved,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (category != null) 'category': category,
      if (traitKey != null) 'trait_key': traitKey,
      if (traitValue != null) 'trait_value': traitValue,
      if (confidence != null) 'confidence': confidence,
      if (evidenceCount != null) 'evidence_count': evidenceCount,
      if (firstObserved != null) 'first_observed': firstObserved,
      if (lastObserved != null) 'last_observed': lastObserved,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfileTraitsCompanion copyWith({
    Value<String>? id,
    Value<String>? category,
    Value<String>? traitKey,
    Value<String>? traitValue,
    Value<double>? confidence,
    Value<int>? evidenceCount,
    Value<int>? firstObserved,
    Value<int>? lastObserved,
    Value<int>? rowid,
  }) {
    return ProfileTraitsCompanion(
      id: id ?? this.id,
      category: category ?? this.category,
      traitKey: traitKey ?? this.traitKey,
      traitValue: traitValue ?? this.traitValue,
      confidence: confidence ?? this.confidence,
      evidenceCount: evidenceCount ?? this.evidenceCount,
      firstObserved: firstObserved ?? this.firstObserved,
      lastObserved: lastObserved ?? this.lastObserved,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (traitKey.present) {
      map['trait_key'] = Variable<String>(traitKey.value);
    }
    if (traitValue.present) {
      map['trait_value'] = Variable<String>(traitValue.value);
    }
    if (confidence.present) {
      map['confidence'] = Variable<double>(confidence.value);
    }
    if (evidenceCount.present) {
      map['evidence_count'] = Variable<int>(evidenceCount.value);
    }
    if (firstObserved.present) {
      map['first_observed'] = Variable<int>(firstObserved.value);
    }
    if (lastObserved.present) {
      map['last_observed'] = Variable<int>(lastObserved.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfileTraitsCompanion(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('traitKey: $traitKey, ')
          ..write('traitValue: $traitValue, ')
          ..write('confidence: $confidence, ')
          ..write('evidenceCount: $evidenceCount, ')
          ..write('firstObserved: $firstObserved, ')
          ..write('lastObserved: $lastObserved, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Projects extends Table with TableInfo<Projects, Project> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Projects(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _techStackMeta = const VerificationMeta(
    'techStack',
  );
  late final GeneratedColumn<String> techStack = GeneratedColumn<String>(
    'tech_stack',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _goalsMeta = const VerificationMeta('goals');
  late final GeneratedColumn<String> goals = GeneratedColumn<String>(
    'goals',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _deadlineMeta = const VerificationMeta(
    'deadline',
  );
  late final GeneratedColumn<int> deadline = GeneratedColumn<int>(
    'deadline',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _repoUrlMeta = const VerificationMeta(
    'repoUrl',
  );
  late final GeneratedColumn<String> repoUrl = GeneratedColumn<String>(
    'repo_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'active\'',
    defaultValue: const CustomExpression('\'active\''),
  );
  static const VerificationMeta _onboardedAtMeta = const VerificationMeta(
    'onboardedAt',
  );
  late final GeneratedColumn<int> onboardedAt = GeneratedColumn<int>(
    'onboarded_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    description,
    techStack,
    goals,
    deadline,
    repoUrl,
    status,
    onboardedAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'projects';
  @override
  VerificationContext validateIntegrity(
    Insertable<Project> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('tech_stack')) {
      context.handle(
        _techStackMeta,
        techStack.isAcceptableOrUnknown(data['tech_stack']!, _techStackMeta),
      );
    }
    if (data.containsKey('goals')) {
      context.handle(
        _goalsMeta,
        goals.isAcceptableOrUnknown(data['goals']!, _goalsMeta),
      );
    }
    if (data.containsKey('deadline')) {
      context.handle(
        _deadlineMeta,
        deadline.isAcceptableOrUnknown(data['deadline']!, _deadlineMeta),
      );
    }
    if (data.containsKey('repo_url')) {
      context.handle(
        _repoUrlMeta,
        repoUrl.isAcceptableOrUnknown(data['repo_url']!, _repoUrlMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('onboarded_at')) {
      context.handle(
        _onboardedAtMeta,
        onboardedAt.isAcceptableOrUnknown(
          data['onboarded_at']!,
          _onboardedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_onboardedAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Project map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Project(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      techStack: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tech_stack'],
      ),
      goals: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}goals'],
      ),
      deadline: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deadline'],
      ),
      repoUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repo_url'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      onboardedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}onboarded_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  Projects createAlias(String alias) {
    return Projects(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class Project extends DataClass implements Insertable<Project> {
  final String id;
  final String name;
  final String? description;
  final String? techStack;
  final String? goals;
  final int? deadline;
  final String? repoUrl;
  final String status;
  final int onboardedAt;
  final int updatedAt;
  const Project({
    required this.id,
    required this.name,
    this.description,
    this.techStack,
    this.goals,
    this.deadline,
    this.repoUrl,
    required this.status,
    required this.onboardedAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || techStack != null) {
      map['tech_stack'] = Variable<String>(techStack);
    }
    if (!nullToAbsent || goals != null) {
      map['goals'] = Variable<String>(goals);
    }
    if (!nullToAbsent || deadline != null) {
      map['deadline'] = Variable<int>(deadline);
    }
    if (!nullToAbsent || repoUrl != null) {
      map['repo_url'] = Variable<String>(repoUrl);
    }
    map['status'] = Variable<String>(status);
    map['onboarded_at'] = Variable<int>(onboardedAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  ProjectsCompanion toCompanion(bool nullToAbsent) {
    return ProjectsCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      techStack: techStack == null && nullToAbsent
          ? const Value.absent()
          : Value(techStack),
      goals: goals == null && nullToAbsent
          ? const Value.absent()
          : Value(goals),
      deadline: deadline == null && nullToAbsent
          ? const Value.absent()
          : Value(deadline),
      repoUrl: repoUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(repoUrl),
      status: Value(status),
      onboardedAt: Value(onboardedAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Project.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Project(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      techStack: serializer.fromJson<String?>(json['tech_stack']),
      goals: serializer.fromJson<String?>(json['goals']),
      deadline: serializer.fromJson<int?>(json['deadline']),
      repoUrl: serializer.fromJson<String?>(json['repo_url']),
      status: serializer.fromJson<String>(json['status']),
      onboardedAt: serializer.fromJson<int>(json['onboarded_at']),
      updatedAt: serializer.fromJson<int>(json['updated_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'tech_stack': serializer.toJson<String?>(techStack),
      'goals': serializer.toJson<String?>(goals),
      'deadline': serializer.toJson<int?>(deadline),
      'repo_url': serializer.toJson<String?>(repoUrl),
      'status': serializer.toJson<String>(status),
      'onboarded_at': serializer.toJson<int>(onboardedAt),
      'updated_at': serializer.toJson<int>(updatedAt),
    };
  }

  Project copyWith({
    String? id,
    String? name,
    Value<String?> description = const Value.absent(),
    Value<String?> techStack = const Value.absent(),
    Value<String?> goals = const Value.absent(),
    Value<int?> deadline = const Value.absent(),
    Value<String?> repoUrl = const Value.absent(),
    String? status,
    int? onboardedAt,
    int? updatedAt,
  }) => Project(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    techStack: techStack.present ? techStack.value : this.techStack,
    goals: goals.present ? goals.value : this.goals,
    deadline: deadline.present ? deadline.value : this.deadline,
    repoUrl: repoUrl.present ? repoUrl.value : this.repoUrl,
    status: status ?? this.status,
    onboardedAt: onboardedAt ?? this.onboardedAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Project copyWithCompanion(ProjectsCompanion data) {
    return Project(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      techStack: data.techStack.present ? data.techStack.value : this.techStack,
      goals: data.goals.present ? data.goals.value : this.goals,
      deadline: data.deadline.present ? data.deadline.value : this.deadline,
      repoUrl: data.repoUrl.present ? data.repoUrl.value : this.repoUrl,
      status: data.status.present ? data.status.value : this.status,
      onboardedAt: data.onboardedAt.present
          ? data.onboardedAt.value
          : this.onboardedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Project(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('techStack: $techStack, ')
          ..write('goals: $goals, ')
          ..write('deadline: $deadline, ')
          ..write('repoUrl: $repoUrl, ')
          ..write('status: $status, ')
          ..write('onboardedAt: $onboardedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    description,
    techStack,
    goals,
    deadline,
    repoUrl,
    status,
    onboardedAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Project &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.techStack == this.techStack &&
          other.goals == this.goals &&
          other.deadline == this.deadline &&
          other.repoUrl == this.repoUrl &&
          other.status == this.status &&
          other.onboardedAt == this.onboardedAt &&
          other.updatedAt == this.updatedAt);
}

class ProjectsCompanion extends UpdateCompanion<Project> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<String?> techStack;
  final Value<String?> goals;
  final Value<int?> deadline;
  final Value<String?> repoUrl;
  final Value<String> status;
  final Value<int> onboardedAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const ProjectsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.techStack = const Value.absent(),
    this.goals = const Value.absent(),
    this.deadline = const Value.absent(),
    this.repoUrl = const Value.absent(),
    this.status = const Value.absent(),
    this.onboardedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProjectsCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    this.techStack = const Value.absent(),
    this.goals = const Value.absent(),
    this.deadline = const Value.absent(),
    this.repoUrl = const Value.absent(),
    this.status = const Value.absent(),
    required int onboardedAt,
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       onboardedAt = Value(onboardedAt),
       updatedAt = Value(updatedAt);
  static Insertable<Project> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? techStack,
    Expression<String>? goals,
    Expression<int>? deadline,
    Expression<String>? repoUrl,
    Expression<String>? status,
    Expression<int>? onboardedAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (techStack != null) 'tech_stack': techStack,
      if (goals != null) 'goals': goals,
      if (deadline != null) 'deadline': deadline,
      if (repoUrl != null) 'repo_url': repoUrl,
      if (status != null) 'status': status,
      if (onboardedAt != null) 'onboarded_at': onboardedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProjectsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<String?>? techStack,
    Value<String?>? goals,
    Value<int?>? deadline,
    Value<String?>? repoUrl,
    Value<String>? status,
    Value<int>? onboardedAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return ProjectsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      techStack: techStack ?? this.techStack,
      goals: goals ?? this.goals,
      deadline: deadline ?? this.deadline,
      repoUrl: repoUrl ?? this.repoUrl,
      status: status ?? this.status,
      onboardedAt: onboardedAt ?? this.onboardedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (techStack.present) {
      map['tech_stack'] = Variable<String>(techStack.value);
    }
    if (goals.present) {
      map['goals'] = Variable<String>(goals.value);
    }
    if (deadline.present) {
      map['deadline'] = Variable<int>(deadline.value);
    }
    if (repoUrl.present) {
      map['repo_url'] = Variable<String>(repoUrl.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (onboardedAt.present) {
      map['onboarded_at'] = Variable<int>(onboardedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('techStack: $techStack, ')
          ..write('goals: $goals, ')
          ..write('deadline: $deadline, ')
          ..write('repoUrl: $repoUrl, ')
          ..write('status: $status, ')
          ..write('onboardedAt: $onboardedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class ProjectFacts extends Table with TableInfo<ProjectFacts, ProjectFact> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  ProjectFacts(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES projects(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _factKeyMeta = const VerificationMeta(
    'factKey',
  );
  late final GeneratedColumn<String> factKey = GeneratedColumn<String>(
    'fact_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _factValueMeta = const VerificationMeta(
    'factValue',
  );
  late final GeneratedColumn<String> factValue = GeneratedColumn<String>(
    'fact_value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _sourceMessageIdMeta = const VerificationMeta(
    'sourceMessageId',
  );
  late final GeneratedColumn<String> sourceMessageId = GeneratedColumn<String>(
    'source_message_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES messages(id)',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    projectId,
    factKey,
    factValue,
    sourceMessageId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'project_facts';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProjectFact> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('fact_key')) {
      context.handle(
        _factKeyMeta,
        factKey.isAcceptableOrUnknown(data['fact_key']!, _factKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_factKeyMeta);
    }
    if (data.containsKey('fact_value')) {
      context.handle(
        _factValueMeta,
        factValue.isAcceptableOrUnknown(data['fact_value']!, _factValueMeta),
      );
    } else if (isInserting) {
      context.missing(_factValueMeta);
    }
    if (data.containsKey('source_message_id')) {
      context.handle(
        _sourceMessageIdMeta,
        sourceMessageId.isAcceptableOrUnknown(
          data['source_message_id']!,
          _sourceMessageIdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ProjectFact map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProjectFact(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      )!,
      factKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fact_key'],
      )!,
      factValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fact_value'],
      )!,
      sourceMessageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_message_id'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  ProjectFacts createAlias(String alias) {
    return ProjectFacts(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class ProjectFact extends DataClass implements Insertable<ProjectFact> {
  final String id;
  final String projectId;
  final String factKey;
  final String factValue;
  final String? sourceMessageId;
  final int createdAt;
  const ProjectFact({
    required this.id,
    required this.projectId,
    required this.factKey,
    required this.factValue,
    this.sourceMessageId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<String>(projectId);
    map['fact_key'] = Variable<String>(factKey);
    map['fact_value'] = Variable<String>(factValue);
    if (!nullToAbsent || sourceMessageId != null) {
      map['source_message_id'] = Variable<String>(sourceMessageId);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  ProjectFactsCompanion toCompanion(bool nullToAbsent) {
    return ProjectFactsCompanion(
      id: Value(id),
      projectId: Value(projectId),
      factKey: Value(factKey),
      factValue: Value(factValue),
      sourceMessageId: sourceMessageId == null && nullToAbsent
          ? const Value.absent()
          : Value(sourceMessageId),
      createdAt: Value(createdAt),
    );
  }

  factory ProjectFact.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProjectFact(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<String>(json['project_id']),
      factKey: serializer.fromJson<String>(json['fact_key']),
      factValue: serializer.fromJson<String>(json['fact_value']),
      sourceMessageId: serializer.fromJson<String?>(json['source_message_id']),
      createdAt: serializer.fromJson<int>(json['created_at']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'project_id': serializer.toJson<String>(projectId),
      'fact_key': serializer.toJson<String>(factKey),
      'fact_value': serializer.toJson<String>(factValue),
      'source_message_id': serializer.toJson<String?>(sourceMessageId),
      'created_at': serializer.toJson<int>(createdAt),
    };
  }

  ProjectFact copyWith({
    String? id,
    String? projectId,
    String? factKey,
    String? factValue,
    Value<String?> sourceMessageId = const Value.absent(),
    int? createdAt,
  }) => ProjectFact(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    factKey: factKey ?? this.factKey,
    factValue: factValue ?? this.factValue,
    sourceMessageId: sourceMessageId.present
        ? sourceMessageId.value
        : this.sourceMessageId,
    createdAt: createdAt ?? this.createdAt,
  );
  ProjectFact copyWithCompanion(ProjectFactsCompanion data) {
    return ProjectFact(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      factKey: data.factKey.present ? data.factKey.value : this.factKey,
      factValue: data.factValue.present ? data.factValue.value : this.factValue,
      sourceMessageId: data.sourceMessageId.present
          ? data.sourceMessageId.value
          : this.sourceMessageId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProjectFact(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('factKey: $factKey, ')
          ..write('factValue: $factValue, ')
          ..write('sourceMessageId: $sourceMessageId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    projectId,
    factKey,
    factValue,
    sourceMessageId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProjectFact &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.factKey == this.factKey &&
          other.factValue == this.factValue &&
          other.sourceMessageId == this.sourceMessageId &&
          other.createdAt == this.createdAt);
}

class ProjectFactsCompanion extends UpdateCompanion<ProjectFact> {
  final Value<String> id;
  final Value<String> projectId;
  final Value<String> factKey;
  final Value<String> factValue;
  final Value<String?> sourceMessageId;
  final Value<int> createdAt;
  final Value<int> rowid;
  const ProjectFactsCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.factKey = const Value.absent(),
    this.factValue = const Value.absent(),
    this.sourceMessageId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProjectFactsCompanion.insert({
    required String id,
    required String projectId,
    required String factKey,
    required String factValue,
    this.sourceMessageId = const Value.absent(),
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       projectId = Value(projectId),
       factKey = Value(factKey),
       factValue = Value(factValue),
       createdAt = Value(createdAt);
  static Insertable<ProjectFact> custom({
    Expression<String>? id,
    Expression<String>? projectId,
    Expression<String>? factKey,
    Expression<String>? factValue,
    Expression<String>? sourceMessageId,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (factKey != null) 'fact_key': factKey,
      if (factValue != null) 'fact_value': factValue,
      if (sourceMessageId != null) 'source_message_id': sourceMessageId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProjectFactsCompanion copyWith({
    Value<String>? id,
    Value<String>? projectId,
    Value<String>? factKey,
    Value<String>? factValue,
    Value<String?>? sourceMessageId,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return ProjectFactsCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      factKey: factKey ?? this.factKey,
      factValue: factValue ?? this.factValue,
      sourceMessageId: sourceMessageId ?? this.sourceMessageId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (factKey.present) {
      map['fact_key'] = Variable<String>(factKey.value);
    }
    if (factValue.present) {
      map['fact_value'] = Variable<String>(factValue.value);
    }
    if (sourceMessageId.present) {
      map['source_message_id'] = Variable<String>(sourceMessageId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectFactsCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('factKey: $factKey, ')
          ..write('factValue: $factValue, ')
          ..write('sourceMessageId: $sourceMessageId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Decisions extends Table with TableInfo<Decisions, Decision> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Decisions(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _conversationIdMeta = const VerificationMeta(
    'conversationId',
  );
  late final GeneratedColumn<String> conversationId = GeneratedColumn<String>(
    'conversation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES conversations(id)',
  );
  static const VerificationMeta _messageIdMeta = const VerificationMeta(
    'messageId',
  );
  late final GeneratedColumn<String> messageId = GeneratedColumn<String>(
    'message_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL REFERENCES messages(id)',
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _reasoningMeta = const VerificationMeta(
    'reasoning',
  );
  late final GeneratedColumn<String> reasoning = GeneratedColumn<String>(
    'reasoning',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _domainMeta = const VerificationMeta('domain');
  late final GeneratedColumn<String> domain = GeneratedColumn<String>(
    'domain',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _alternativesConsideredMeta =
      const VerificationMeta('alternativesConsidered');
  late final GeneratedColumn<String> alternativesConsidered =
      GeneratedColumn<String>(
        'alternatives_considered',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _supersededByMeta = const VerificationMeta(
    'supersededBy',
  );
  late final GeneratedColumn<String> supersededBy = GeneratedColumn<String>(
    'superseded_by',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES decisions(id)',
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  late final GeneratedColumn<int> isActive = GeneratedColumn<int>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT 1',
    defaultValue: const CustomExpression('1'),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'active\'',
    defaultValue: const CustomExpression('\'active\''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    conversationId,
    messageId,
    title,
    reasoning,
    domain,
    alternativesConsidered,
    createdAt,
    supersededBy,
    isActive,
    status,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'decisions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Decision> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
        _conversationIdMeta,
        conversationId.isAcceptableOrUnknown(
          data['conversation_id']!,
          _conversationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('message_id')) {
      context.handle(
        _messageIdMeta,
        messageId.isAcceptableOrUnknown(data['message_id']!, _messageIdMeta),
      );
    } else if (isInserting) {
      context.missing(_messageIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('reasoning')) {
      context.handle(
        _reasoningMeta,
        reasoning.isAcceptableOrUnknown(data['reasoning']!, _reasoningMeta),
      );
    } else if (isInserting) {
      context.missing(_reasoningMeta);
    }
    if (data.containsKey('domain')) {
      context.handle(
        _domainMeta,
        domain.isAcceptableOrUnknown(data['domain']!, _domainMeta),
      );
    } else if (isInserting) {
      context.missing(_domainMeta);
    }
    if (data.containsKey('alternatives_considered')) {
      context.handle(
        _alternativesConsideredMeta,
        alternativesConsidered.isAcceptableOrUnknown(
          data['alternatives_considered']!,
          _alternativesConsideredMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('superseded_by')) {
      context.handle(
        _supersededByMeta,
        supersededBy.isAcceptableOrUnknown(
          data['superseded_by']!,
          _supersededByMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Decision map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Decision(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      conversationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conversation_id'],
      )!,
      messageId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}message_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      reasoning: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reasoning'],
      )!,
      domain: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}domain'],
      )!,
      alternativesConsidered: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}alternatives_considered'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      supersededBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}superseded_by'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}is_active'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
    );
  }

  @override
  Decisions createAlias(String alias) {
    return Decisions(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class Decision extends DataClass implements Insertable<Decision> {
  final String id;
  final String conversationId;
  final String messageId;
  final String title;
  final String reasoning;
  final String domain;
  final String? alternativesConsidered;
  final int createdAt;
  final String? supersededBy;
  final int isActive;
  final String status;
  const Decision({
    required this.id,
    required this.conversationId,
    required this.messageId,
    required this.title,
    required this.reasoning,
    required this.domain,
    this.alternativesConsidered,
    required this.createdAt,
    this.supersededBy,
    required this.isActive,
    required this.status,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['conversation_id'] = Variable<String>(conversationId);
    map['message_id'] = Variable<String>(messageId);
    map['title'] = Variable<String>(title);
    map['reasoning'] = Variable<String>(reasoning);
    map['domain'] = Variable<String>(domain);
    if (!nullToAbsent || alternativesConsidered != null) {
      map['alternatives_considered'] = Variable<String>(alternativesConsidered);
    }
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || supersededBy != null) {
      map['superseded_by'] = Variable<String>(supersededBy);
    }
    map['is_active'] = Variable<int>(isActive);
    map['status'] = Variable<String>(status);
    return map;
  }

  DecisionsCompanion toCompanion(bool nullToAbsent) {
    return DecisionsCompanion(
      id: Value(id),
      conversationId: Value(conversationId),
      messageId: Value(messageId),
      title: Value(title),
      reasoning: Value(reasoning),
      domain: Value(domain),
      alternativesConsidered: alternativesConsidered == null && nullToAbsent
          ? const Value.absent()
          : Value(alternativesConsidered),
      createdAt: Value(createdAt),
      supersededBy: supersededBy == null && nullToAbsent
          ? const Value.absent()
          : Value(supersededBy),
      isActive: Value(isActive),
      status: Value(status),
    );
  }

  factory Decision.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Decision(
      id: serializer.fromJson<String>(json['id']),
      conversationId: serializer.fromJson<String>(json['conversation_id']),
      messageId: serializer.fromJson<String>(json['message_id']),
      title: serializer.fromJson<String>(json['title']),
      reasoning: serializer.fromJson<String>(json['reasoning']),
      domain: serializer.fromJson<String>(json['domain']),
      alternativesConsidered: serializer.fromJson<String?>(
        json['alternatives_considered'],
      ),
      createdAt: serializer.fromJson<int>(json['created_at']),
      supersededBy: serializer.fromJson<String?>(json['superseded_by']),
      isActive: serializer.fromJson<int>(json['is_active']),
      status: serializer.fromJson<String>(json['status']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'conversation_id': serializer.toJson<String>(conversationId),
      'message_id': serializer.toJson<String>(messageId),
      'title': serializer.toJson<String>(title),
      'reasoning': serializer.toJson<String>(reasoning),
      'domain': serializer.toJson<String>(domain),
      'alternatives_considered': serializer.toJson<String?>(
        alternativesConsidered,
      ),
      'created_at': serializer.toJson<int>(createdAt),
      'superseded_by': serializer.toJson<String?>(supersededBy),
      'is_active': serializer.toJson<int>(isActive),
      'status': serializer.toJson<String>(status),
    };
  }

  Decision copyWith({
    String? id,
    String? conversationId,
    String? messageId,
    String? title,
    String? reasoning,
    String? domain,
    Value<String?> alternativesConsidered = const Value.absent(),
    int? createdAt,
    Value<String?> supersededBy = const Value.absent(),
    int? isActive,
    String? status,
  }) => Decision(
    id: id ?? this.id,
    conversationId: conversationId ?? this.conversationId,
    messageId: messageId ?? this.messageId,
    title: title ?? this.title,
    reasoning: reasoning ?? this.reasoning,
    domain: domain ?? this.domain,
    alternativesConsidered: alternativesConsidered.present
        ? alternativesConsidered.value
        : this.alternativesConsidered,
    createdAt: createdAt ?? this.createdAt,
    supersededBy: supersededBy.present ? supersededBy.value : this.supersededBy,
    isActive: isActive ?? this.isActive,
    status: status ?? this.status,
  );
  Decision copyWithCompanion(DecisionsCompanion data) {
    return Decision(
      id: data.id.present ? data.id.value : this.id,
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      messageId: data.messageId.present ? data.messageId.value : this.messageId,
      title: data.title.present ? data.title.value : this.title,
      reasoning: data.reasoning.present ? data.reasoning.value : this.reasoning,
      domain: data.domain.present ? data.domain.value : this.domain,
      alternativesConsidered: data.alternativesConsidered.present
          ? data.alternativesConsidered.value
          : this.alternativesConsidered,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      supersededBy: data.supersededBy.present
          ? data.supersededBy.value
          : this.supersededBy,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      status: data.status.present ? data.status.value : this.status,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Decision(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('messageId: $messageId, ')
          ..write('title: $title, ')
          ..write('reasoning: $reasoning, ')
          ..write('domain: $domain, ')
          ..write('alternativesConsidered: $alternativesConsidered, ')
          ..write('createdAt: $createdAt, ')
          ..write('supersededBy: $supersededBy, ')
          ..write('isActive: $isActive, ')
          ..write('status: $status')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    conversationId,
    messageId,
    title,
    reasoning,
    domain,
    alternativesConsidered,
    createdAt,
    supersededBy,
    isActive,
    status,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Decision &&
          other.id == this.id &&
          other.conversationId == this.conversationId &&
          other.messageId == this.messageId &&
          other.title == this.title &&
          other.reasoning == this.reasoning &&
          other.domain == this.domain &&
          other.alternativesConsidered == this.alternativesConsidered &&
          other.createdAt == this.createdAt &&
          other.supersededBy == this.supersededBy &&
          other.isActive == this.isActive &&
          other.status == this.status);
}

class DecisionsCompanion extends UpdateCompanion<Decision> {
  final Value<String> id;
  final Value<String> conversationId;
  final Value<String> messageId;
  final Value<String> title;
  final Value<String> reasoning;
  final Value<String> domain;
  final Value<String?> alternativesConsidered;
  final Value<int> createdAt;
  final Value<String?> supersededBy;
  final Value<int> isActive;
  final Value<String> status;
  final Value<int> rowid;
  const DecisionsCompanion({
    this.id = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.messageId = const Value.absent(),
    this.title = const Value.absent(),
    this.reasoning = const Value.absent(),
    this.domain = const Value.absent(),
    this.alternativesConsidered = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.supersededBy = const Value.absent(),
    this.isActive = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DecisionsCompanion.insert({
    required String id,
    required String conversationId,
    required String messageId,
    required String title,
    required String reasoning,
    required String domain,
    this.alternativesConsidered = const Value.absent(),
    required int createdAt,
    this.supersededBy = const Value.absent(),
    this.isActive = const Value.absent(),
    this.status = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       conversationId = Value(conversationId),
       messageId = Value(messageId),
       title = Value(title),
       reasoning = Value(reasoning),
       domain = Value(domain),
       createdAt = Value(createdAt);
  static Insertable<Decision> custom({
    Expression<String>? id,
    Expression<String>? conversationId,
    Expression<String>? messageId,
    Expression<String>? title,
    Expression<String>? reasoning,
    Expression<String>? domain,
    Expression<String>? alternativesConsidered,
    Expression<int>? createdAt,
    Expression<String>? supersededBy,
    Expression<int>? isActive,
    Expression<String>? status,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (conversationId != null) 'conversation_id': conversationId,
      if (messageId != null) 'message_id': messageId,
      if (title != null) 'title': title,
      if (reasoning != null) 'reasoning': reasoning,
      if (domain != null) 'domain': domain,
      if (alternativesConsidered != null)
        'alternatives_considered': alternativesConsidered,
      if (createdAt != null) 'created_at': createdAt,
      if (supersededBy != null) 'superseded_by': supersededBy,
      if (isActive != null) 'is_active': isActive,
      if (status != null) 'status': status,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DecisionsCompanion copyWith({
    Value<String>? id,
    Value<String>? conversationId,
    Value<String>? messageId,
    Value<String>? title,
    Value<String>? reasoning,
    Value<String>? domain,
    Value<String?>? alternativesConsidered,
    Value<int>? createdAt,
    Value<String?>? supersededBy,
    Value<int>? isActive,
    Value<String>? status,
    Value<int>? rowid,
  }) {
    return DecisionsCompanion(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      messageId: messageId ?? this.messageId,
      title: title ?? this.title,
      reasoning: reasoning ?? this.reasoning,
      domain: domain ?? this.domain,
      alternativesConsidered:
          alternativesConsidered ?? this.alternativesConsidered,
      createdAt: createdAt ?? this.createdAt,
      supersededBy: supersededBy ?? this.supersededBy,
      isActive: isActive ?? this.isActive,
      status: status ?? this.status,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<String>(conversationId.value);
    }
    if (messageId.present) {
      map['message_id'] = Variable<String>(messageId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (reasoning.present) {
      map['reasoning'] = Variable<String>(reasoning.value);
    }
    if (domain.present) {
      map['domain'] = Variable<String>(domain.value);
    }
    if (alternativesConsidered.present) {
      map['alternatives_considered'] = Variable<String>(
        alternativesConsidered.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (supersededBy.present) {
      map['superseded_by'] = Variable<String>(supersededBy.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<int>(isActive.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DecisionsCompanion(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('messageId: $messageId, ')
          ..write('title: $title, ')
          ..write('reasoning: $reasoning, ')
          ..write('domain: $domain, ')
          ..write('alternativesConsidered: $alternativesConsidered, ')
          ..write('createdAt: $createdAt, ')
          ..write('supersededBy: $supersededBy, ')
          ..write('isActive: $isActive, ')
          ..write('status: $status, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Messages extends Table with TableInfo<Messages, Message> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Messages(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _conversationIdMeta = const VerificationMeta(
    'conversationId',
  );
  late final GeneratedColumn<String> conversationId = GeneratedColumn<String>(
    'conversation_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints:
        'NOT NULL REFERENCES conversations(id)ON DELETE CASCADE',
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _tokenCountMeta = const VerificationMeta(
    'tokenCount',
  );
  late final GeneratedColumn<int> tokenCount = GeneratedColumn<int>(
    'token_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    $customConstraints: '',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    conversationId,
    role,
    content,
    createdAt,
    tokenCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<Message> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('conversation_id')) {
      context.handle(
        _conversationIdMeta,
        conversationId.isAcceptableOrUnknown(
          data['conversation_id']!,
          _conversationIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_conversationIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('token_count')) {
      context.handle(
        _tokenCountMeta,
        tokenCount.isAcceptableOrUnknown(data['token_count']!, _tokenCountMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Message map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Message(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      conversationId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}conversation_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      tokenCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}token_count'],
      ),
    );
  }

  @override
  Messages createAlias(String alias) {
    return Messages(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class Message extends DataClass implements Insertable<Message> {
  final String id;
  final String conversationId;
  final String role;
  final String content;
  final int createdAt;
  final int? tokenCount;
  const Message({
    required this.id,
    required this.conversationId,
    required this.role,
    required this.content,
    required this.createdAt,
    this.tokenCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['conversation_id'] = Variable<String>(conversationId);
    map['role'] = Variable<String>(role);
    map['content'] = Variable<String>(content);
    map['created_at'] = Variable<int>(createdAt);
    if (!nullToAbsent || tokenCount != null) {
      map['token_count'] = Variable<int>(tokenCount);
    }
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      id: Value(id),
      conversationId: Value(conversationId),
      role: Value(role),
      content: Value(content),
      createdAt: Value(createdAt),
      tokenCount: tokenCount == null && nullToAbsent
          ? const Value.absent()
          : Value(tokenCount),
    );
  }

  factory Message.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Message(
      id: serializer.fromJson<String>(json['id']),
      conversationId: serializer.fromJson<String>(json['conversation_id']),
      role: serializer.fromJson<String>(json['role']),
      content: serializer.fromJson<String>(json['content']),
      createdAt: serializer.fromJson<int>(json['created_at']),
      tokenCount: serializer.fromJson<int?>(json['token_count']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'conversation_id': serializer.toJson<String>(conversationId),
      'role': serializer.toJson<String>(role),
      'content': serializer.toJson<String>(content),
      'created_at': serializer.toJson<int>(createdAt),
      'token_count': serializer.toJson<int?>(tokenCount),
    };
  }

  Message copyWith({
    String? id,
    String? conversationId,
    String? role,
    String? content,
    int? createdAt,
    Value<int?> tokenCount = const Value.absent(),
  }) => Message(
    id: id ?? this.id,
    conversationId: conversationId ?? this.conversationId,
    role: role ?? this.role,
    content: content ?? this.content,
    createdAt: createdAt ?? this.createdAt,
    tokenCount: tokenCount.present ? tokenCount.value : this.tokenCount,
  );
  Message copyWithCompanion(MessagesCompanion data) {
    return Message(
      id: data.id.present ? data.id.value : this.id,
      conversationId: data.conversationId.present
          ? data.conversationId.value
          : this.conversationId,
      role: data.role.present ? data.role.value : this.role,
      content: data.content.present ? data.content.value : this.content,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      tokenCount: data.tokenCount.present
          ? data.tokenCount.value
          : this.tokenCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Message(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt, ')
          ..write('tokenCount: $tokenCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, conversationId, role, content, createdAt, tokenCount);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Message &&
          other.id == this.id &&
          other.conversationId == this.conversationId &&
          other.role == this.role &&
          other.content == this.content &&
          other.createdAt == this.createdAt &&
          other.tokenCount == this.tokenCount);
}

class MessagesCompanion extends UpdateCompanion<Message> {
  final Value<String> id;
  final Value<String> conversationId;
  final Value<String> role;
  final Value<String> content;
  final Value<int> createdAt;
  final Value<int?> tokenCount;
  final Value<int> rowid;
  const MessagesCompanion({
    this.id = const Value.absent(),
    this.conversationId = const Value.absent(),
    this.role = const Value.absent(),
    this.content = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.tokenCount = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MessagesCompanion.insert({
    required String id,
    required String conversationId,
    required String role,
    required String content,
    required int createdAt,
    this.tokenCount = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       conversationId = Value(conversationId),
       role = Value(role),
       content = Value(content),
       createdAt = Value(createdAt);
  static Insertable<Message> custom({
    Expression<String>? id,
    Expression<String>? conversationId,
    Expression<String>? role,
    Expression<String>? content,
    Expression<int>? createdAt,
    Expression<int>? tokenCount,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (conversationId != null) 'conversation_id': conversationId,
      if (role != null) 'role': role,
      if (content != null) 'content': content,
      if (createdAt != null) 'created_at': createdAt,
      if (tokenCount != null) 'token_count': tokenCount,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MessagesCompanion copyWith({
    Value<String>? id,
    Value<String>? conversationId,
    Value<String>? role,
    Value<String>? content,
    Value<int>? createdAt,
    Value<int?>? tokenCount,
    Value<int>? rowid,
  }) {
    return MessagesCompanion(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      role: role ?? this.role,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      tokenCount: tokenCount ?? this.tokenCount,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (conversationId.present) {
      map['conversation_id'] = Variable<String>(conversationId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (tokenCount.present) {
      map['token_count'] = Variable<int>(tokenCount.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('id: $id, ')
          ..write('conversationId: $conversationId, ')
          ..write('role: $role, ')
          ..write('content: $content, ')
          ..write('createdAt: $createdAt, ')
          ..write('tokenCount: $tokenCount, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class Conversations extends Table with TableInfo<Conversations, Conversation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  Conversations(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL PRIMARY KEY',
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'NOT NULL DEFAULT \'New conversation\'',
    defaultValue: const CustomExpression('\'New conversation\''),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL',
  );
  static const VerificationMeta _lastMessagePreviewMeta =
      const VerificationMeta('lastMessagePreview');
  late final GeneratedColumn<String> lastMessagePreview =
      GeneratedColumn<String>(
        'last_message_preview',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        $customConstraints: '',
      );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  late final GeneratedColumn<String> projectId = GeneratedColumn<String>(
    'project_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'REFERENCES projects(id)',
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    createdAt,
    updatedAt,
    lastMessagePreview,
    projectId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'conversations';
  @override
  VerificationContext validateIntegrity(
    Insertable<Conversation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('last_message_preview')) {
      context.handle(
        _lastMessagePreviewMeta,
        lastMessagePreview.isAcceptableOrUnknown(
          data['last_message_preview']!,
          _lastMessagePreviewMeta,
        ),
      );
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Conversation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Conversation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
      lastMessagePreview: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_message_preview'],
      ),
      projectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}project_id'],
      ),
    );
  }

  @override
  Conversations createAlias(String alias) {
    return Conversations(attachedDatabase, alias);
  }

  @override
  bool get dontWriteConstraints => true;
}

class Conversation extends DataClass implements Insertable<Conversation> {
  final String id;
  final String title;
  final int createdAt;
  final int updatedAt;
  final String? lastMessagePreview;
  final String? projectId;
  const Conversation({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.lastMessagePreview,
    this.projectId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['title'] = Variable<String>(title);
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    if (!nullToAbsent || lastMessagePreview != null) {
      map['last_message_preview'] = Variable<String>(lastMessagePreview);
    }
    if (!nullToAbsent || projectId != null) {
      map['project_id'] = Variable<String>(projectId);
    }
    return map;
  }

  ConversationsCompanion toCompanion(bool nullToAbsent) {
    return ConversationsCompanion(
      id: Value(id),
      title: Value(title),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastMessagePreview: lastMessagePreview == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMessagePreview),
      projectId: projectId == null && nullToAbsent
          ? const Value.absent()
          : Value(projectId),
    );
  }

  factory Conversation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Conversation(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      createdAt: serializer.fromJson<int>(json['created_at']),
      updatedAt: serializer.fromJson<int>(json['updated_at']),
      lastMessagePreview: serializer.fromJson<String?>(
        json['last_message_preview'],
      ),
      projectId: serializer.fromJson<String?>(json['project_id']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String>(title),
      'created_at': serializer.toJson<int>(createdAt),
      'updated_at': serializer.toJson<int>(updatedAt),
      'last_message_preview': serializer.toJson<String?>(lastMessagePreview),
      'project_id': serializer.toJson<String?>(projectId),
    };
  }

  Conversation copyWith({
    String? id,
    String? title,
    int? createdAt,
    int? updatedAt,
    Value<String?> lastMessagePreview = const Value.absent(),
    Value<String?> projectId = const Value.absent(),
  }) => Conversation(
    id: id ?? this.id,
    title: title ?? this.title,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastMessagePreview: lastMessagePreview.present
        ? lastMessagePreview.value
        : this.lastMessagePreview,
    projectId: projectId.present ? projectId.value : this.projectId,
  );
  Conversation copyWithCompanion(ConversationsCompanion data) {
    return Conversation(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastMessagePreview: data.lastMessagePreview.present
          ? data.lastMessagePreview.value
          : this.lastMessagePreview,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Conversation(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastMessagePreview: $lastMessagePreview, ')
          ..write('projectId: $projectId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    createdAt,
    updatedAt,
    lastMessagePreview,
    projectId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Conversation &&
          other.id == this.id &&
          other.title == this.title &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastMessagePreview == this.lastMessagePreview &&
          other.projectId == this.projectId);
}

class ConversationsCompanion extends UpdateCompanion<Conversation> {
  final Value<String> id;
  final Value<String> title;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<String?> lastMessagePreview;
  final Value<String?> projectId;
  final Value<int> rowid;
  const ConversationsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastMessagePreview = const Value.absent(),
    this.projectId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConversationsCompanion.insert({
    required String id,
    this.title = const Value.absent(),
    required int createdAt,
    required int updatedAt,
    this.lastMessagePreview = const Value.absent(),
    this.projectId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Conversation> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<String>? lastMessagePreview,
    Expression<String>? projectId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastMessagePreview != null)
        'last_message_preview': lastMessagePreview,
      if (projectId != null) 'project_id': projectId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConversationsCompanion copyWith({
    Value<String>? id,
    Value<String>? title,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<String?>? lastMessagePreview,
    Value<String?>? projectId,
    Value<int>? rowid,
  }) {
    return ConversationsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastMessagePreview: lastMessagePreview ?? this.lastMessagePreview,
      projectId: projectId ?? this.projectId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (lastMessagePreview.present) {
      map['last_message_preview'] = Variable<String>(lastMessagePreview.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<String>(projectId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConversationsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastMessagePreview: $lastMessagePreview, ')
          ..write('projectId: $projectId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$SoulDatabase extends GeneratedDatabase {
  _$SoulDatabase(QueryExecutor e) : super(e);
  $SoulDatabaseManager get managers => $SoulDatabaseManager(this);
  late final WeeklyReviews weeklyReviews = WeeklyReviews(this);
  late final Achievements achievements = Achievements(this);
  late final Streaks streaks = Streaks(this);
  late final DailyMetrics dailyMetrics = DailyMetrics(this);
  late final AgenticWal agenticWal = AgenticWal(this);
  late final ProjectState projectState = ProjectState(this);
  late final DistilledFacts distilledFacts = DistilledFacts(this);
  late final MoodStates moodStates = MoodStates(this);
  late final AuditLog auditLog = AuditLog(this);
  late final InterventionStates interventionStates = InterventionStates(this);
  late final ApiUsage apiUsage = ApiUsage(this);
  late final Settings settings = Settings(this);
  late final StucknessSignals stucknessSignals = StucknessSignals(this);
  late final Briefings briefings = Briefings(this);
  late final MonitoredNotifications monitoredNotifications =
      MonitoredNotifications(this);
  late final CachedCalendarEvents cachedCalendarEvents = CachedCalendarEvents(
    this,
  );
  late final CachedContacts cachedContacts = CachedContacts(this);
  late final VesselTools vesselTools = VesselTools(this);
  late final VesselTasks vesselTasks = VesselTasks(this);
  late final VesselConfigs vesselConfigs = VesselConfigs(this);
  late final ProfileTraits profileTraits = ProfileTraits(this);
  late final Projects projects = Projects(this);
  late final ProjectFacts projectFacts = ProjectFacts(this);
  late final Decisions decisions = Decisions(this);
  late final Trigger decisionsAi = Trigger(
    'CREATE TRIGGER decisions_ai AFTER INSERT ON decisions BEGIN INSERT INTO decisions_fts ("rowid", title, reasoning) VALUES (new."rowid", new.title, new.reasoning);END',
    'decisions_ai',
  );
  late final Trigger decisionsAd = Trigger(
    'CREATE TRIGGER decisions_ad AFTER DELETE ON decisions BEGIN INSERT INTO decisions_fts (decisions_fts, "rowid", title, reasoning) VALUES (\'delete\', old."rowid", old.title, old.reasoning);END',
    'decisions_ad',
  );
  late final Trigger decisionsAu = Trigger(
    'CREATE TRIGGER decisions_au AFTER UPDATE ON decisions BEGIN INSERT INTO decisions_fts (decisions_fts, "rowid", title, reasoning) VALUES (\'delete\', old."rowid", old.title, old.reasoning);INSERT INTO decisions_fts ("rowid", title, reasoning) VALUES (new."rowid", new.title, new.reasoning);END',
    'decisions_au',
  );
  late final Messages messages = Messages(this);
  late final Trigger messagesAi = Trigger(
    'CREATE TRIGGER messages_ai AFTER INSERT ON messages BEGIN INSERT INTO messages_fts ("rowid", content) VALUES (new."rowid", new.content);END',
    'messages_ai',
  );
  late final Trigger messagesAd = Trigger(
    'CREATE TRIGGER messages_ad AFTER DELETE ON messages BEGIN INSERT INTO messages_fts (messages_fts, "rowid", content) VALUES (\'delete\', old."rowid", old.content);END',
    'messages_ad',
  );
  late final Trigger messagesAu = Trigger(
    'CREATE TRIGGER messages_au AFTER UPDATE ON messages BEGIN INSERT INTO messages_fts (messages_fts, "rowid", content) VALUES (\'delete\', old."rowid", old.content);INSERT INTO messages_fts ("rowid", content) VALUES (new."rowid", new.content);END',
    'messages_au',
  );
  late final Conversations conversations = Conversations(this);
  late final ConversationDao conversationDao = ConversationDao(
    this as SoulDatabase,
  );
  late final DecisionDao decisionDao = DecisionDao(this as SoulDatabase);
  late final ProjectDao projectDao = ProjectDao(this as SoulDatabase);
  late final ProfileDao profileDao = ProfileDao(this as SoulDatabase);
  late final VesselDao vesselDao = VesselDao(this as SoulDatabase);
  late final ContactsDao contactsDao = ContactsDao(this as SoulDatabase);
  late final CalendarDao calendarDao = CalendarDao(this as SoulDatabase);
  late final NotificationDao notificationDao = NotificationDao(
    this as SoulDatabase,
  );
  late final BriefingDao briefingDao = BriefingDao(this as SoulDatabase);
  late final SettingsDao settingsDao = SettingsDao(this as SoulDatabase);
  late final ApiUsageDao apiUsageDao = ApiUsageDao(this as SoulDatabase);
  late final InterventionDao interventionDao = InterventionDao(
    this as SoulDatabase,
  );
  late final AuditDao auditDao = AuditDao(this as SoulDatabase);
  late final MoodDao moodDao = MoodDao(this as SoulDatabase);
  late final DistillationDao distillationDao = DistillationDao(
    this as SoulDatabase,
  );
  late final ProjectStateDao projectStateDao = ProjectStateDao(
    this as SoulDatabase,
  );
  late final WalDao walDao = WalDao(this as SoulDatabase);
  late final MetricsDao metricsDao = MetricsDao(this as SoulDatabase);
  late final StreakDao streakDao = StreakDao(this as SoulDatabase);
  late final AchievementDao achievementDao = AchievementDao(
    this as SoulDatabase,
  );
  late final WeeklyReviewDao weeklyReviewDao = WeeklyReviewDao(
    this as SoulDatabase,
  );
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

  Selectable<InterventionRow> activeInterventions() {
    return customSelect(
      'SELECT * FROM intervention_states WHERE level != \'resolved\' AND level != \'inactive\' ORDER BY detected_at DESC',
      variables: [],
      readsFrom: {interventionStates},
    ).asyncMap(interventionStates.mapFromRow);
  }

  Selectable<InterventionRow> interventionById(String id) {
    return customSelect(
      'SELECT * FROM intervention_states WHERE id = ?1',
      variables: [Variable<String>(id)],
      readsFrom: {interventionStates},
    ).asyncMap(interventionStates.mapFromRow);
  }

  Selectable<InterventionRow> interventionsOlderThan(int cutoff) {
    return customSelect(
      'SELECT * FROM intervention_states WHERE detected_at < ?1',
      variables: [Variable<int>(cutoff)],
      readsFrom: {interventionStates},
    ).asyncMap(interventionStates.mapFromRow);
  }

  Selectable<VesselTool> toolsByVesselId(String vesselId) {
    return customSelect(
      'SELECT * FROM vessel_tools WHERE vessel_id = ?1 ORDER BY capability_group',
      variables: [Variable<String>(vesselId)],
      readsFrom: {vesselTools},
    ).asyncMap(vesselTools.mapFromRow);
  }

  Selectable<String> capabilityGroupsByVesselId(String vesselId) {
    return customSelect(
      'SELECT DISTINCT capability_group FROM vessel_tools WHERE vessel_id = ?1',
      variables: [Variable<String>(vesselId)],
      readsFrom: {vesselTools},
    ).map((QueryRow row) => row.read<String>('capability_group'));
  }

  Future<int> deleteByVesselId(String vesselId) {
    return customUpdate(
      'DELETE FROM vessel_tools WHERE vessel_id = ?1',
      variables: [Variable<String>(vesselId)],
      updates: {vesselTools},
      updateKind: UpdateKind.delete,
    );
  }

  Selectable<VesselTask> recentVesselTasks(int limit) {
    return customSelect(
      'SELECT * FROM vessel_tasks ORDER BY created_at DESC LIMIT ?1',
      variables: [Variable<int>(limit)],
      readsFrom: {vesselTasks},
    ).asyncMap(vesselTasks.mapFromRow);
  }

  Selectable<VesselTask> vesselTaskById(String id) {
    return customSelect(
      'SELECT * FROM vessel_tasks WHERE id = ?1',
      variables: [Variable<String>(id)],
      readsFrom: {vesselTasks},
    ).asyncMap(vesselTasks.mapFromRow);
  }

  Selectable<VesselTask> vesselTasksByStatus(String status) {
    return customSelect(
      'SELECT * FROM vessel_tasks WHERE status = ?1 ORDER BY created_at DESC',
      variables: [Variable<String>(status)],
      readsFrom: {vesselTasks},
    ).asyncMap(vesselTasks.mapFromRow);
  }

  Selectable<VesselConfig> activeConfigByType(String vesselType) {
    return customSelect(
      'SELECT * FROM vessel_configs WHERE vessel_type = ?1 AND is_active = 1 LIMIT 1',
      variables: [Variable<String>(vesselType)],
      readsFrom: {vesselConfigs},
    ).asyncMap(vesselConfigs.mapFromRow);
  }

  Selectable<VesselConfig> allConfigs() {
    return customSelect(
      'SELECT * FROM vessel_configs ORDER BY updated_at DESC',
      variables: [],
      readsFrom: {vesselConfigs},
    ).asyncMap(vesselConfigs.mapFromRow);
  }

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

  Selectable<Project> allProjects() {
    return customSelect(
      'SELECT * FROM projects ORDER BY updated_at DESC',
      variables: [],
      readsFrom: {projects},
    ).asyncMap(projects.mapFromRow);
  }

  Selectable<Project> projectById(String id) {
    return customSelect(
      'SELECT * FROM projects WHERE id = ?1',
      variables: [Variable<String>(id)],
      readsFrom: {projects},
    ).asyncMap(projects.mapFromRow);
  }

  Selectable<Project> activeProject() {
    return customSelect(
      'SELECT * FROM projects WHERE status = \'active\' ORDER BY updated_at DESC LIMIT 1',
      variables: [],
      readsFrom: {projects},
    ).asyncMap(projects.mapFromRow);
  }

  Selectable<ProjectFact> factsForProject(String projectId) {
    return customSelect(
      'SELECT * FROM project_facts WHERE project_id = ?1 ORDER BY created_at ASC',
      variables: [Variable<String>(projectId)],
      readsFrom: {projectFacts},
    ).asyncMap(projectFacts.mapFromRow);
  }

  Selectable<Project> activeProjects() {
    return customSelect(
      'SELECT * FROM projects WHERE status = \'active\' ORDER BY updated_at DESC',
      variables: [],
      readsFrom: {projects},
    ).asyncMap(projects.mapFromRow);
  }

  Selectable<Project> projectsWithDeadlines() {
    return customSelect(
      'SELECT * FROM projects WHERE deadline IS NOT NULL AND status = \'active\' ORDER BY deadline ASC',
      variables: [],
      readsFrom: {projects},
    ).asyncMap(projects.mapFromRow);
  }

  Selectable<Decision> allDecisions() {
    return customSelect(
      'SELECT * FROM decisions WHERE is_active = 1 ORDER BY created_at DESC',
      variables: [],
      readsFrom: {decisions},
    ).asyncMap(decisions.mapFromRow);
  }

  Selectable<Decision> decisionById(String id) {
    return customSelect(
      'SELECT * FROM decisions WHERE id = ?1',
      variables: [Variable<String>(id)],
      readsFrom: {decisions},
    ).asyncMap(decisions.mapFromRow);
  }

  Selectable<Decision> decisionsForConversation(String conversationId) {
    return customSelect(
      'SELECT * FROM decisions WHERE conversation_id = ?1 ORDER BY created_at ASC',
      variables: [Variable<String>(conversationId)],
      readsFrom: {decisions},
    ).asyncMap(decisions.mapFromRow);
  }

  Selectable<Decision> searchDecisions(String query) {
    return customSelect(
      'SELECT d.* FROM decisions AS d INNER JOIN decisions_fts AS f ON d."rowid" = f."rowid" WHERE decisions_fts MATCH ?1 AND d.is_active = 1 ORDER BY rank',
      variables: [Variable<String>(query)],
      readsFrom: {decisions},
    ).asyncMap(decisions.mapFromRow);
  }

  Selectable<Decision> recentDecisions(int limit) {
    return customSelect(
      'SELECT * FROM decisions WHERE is_active = 1 ORDER BY created_at DESC LIMIT ?1',
      variables: [Variable<int>(limit)],
      readsFrom: {decisions},
    ).asyncMap(decisions.mapFromRow);
  }

  Selectable<Message> messagesForConversation(String conversationId) {
    return customSelect(
      'SELECT * FROM messages WHERE conversation_id = ?1 ORDER BY created_at ASC',
      variables: [Variable<String>(conversationId)],
      readsFrom: {messages},
    ).asyncMap(messages.mapFromRow);
  }

  Selectable<Message> searchMessages(String query) {
    return customSelect(
      'SELECT m.* FROM messages AS m INNER JOIN messages_fts AS f ON m."rowid" = f."rowid" WHERE messages_fts MATCH ?1 ORDER BY rank',
      variables: [Variable<String>(query)],
      readsFrom: {messages},
    ).asyncMap(messages.mapFromRow);
  }

  Selectable<Conversation> allConversations() {
    return customSelect(
      'SELECT * FROM conversations ORDER BY updated_at DESC',
      variables: [],
      readsFrom: {conversations},
    ).asyncMap(conversations.mapFromRow);
  }

  Selectable<Conversation> conversationById(String id) {
    return customSelect(
      'SELECT * FROM conversations WHERE id = ?1',
      variables: [Variable<String>(id)],
      readsFrom: {conversations},
    ).asyncMap(conversations.mapFromRow);
  }

  Selectable<Conversation> conversationsSince(int sinceMs) {
    return customSelect(
      'SELECT * FROM conversations WHERE created_at >= ?1 ORDER BY created_at DESC',
      variables: [Variable<int>(sinceMs)],
      readsFrom: {conversations},
    ).asyncMap(conversations.mapFromRow);
  }

  Selectable<Conversation> conversationsForProject(String? projectId) {
    return customSelect(
      'SELECT * FROM conversations WHERE project_id = ?1 ORDER BY updated_at DESC',
      variables: [Variable<String>(projectId)],
      readsFrom: {conversations},
    ).asyncMap(conversations.mapFromRow);
  }

  Selectable<Conversation> conversationsWithoutProject() {
    return customSelect(
      'SELECT * FROM conversations WHERE project_id IS NULL ORDER BY updated_at DESC',
      variables: [],
      readsFrom: {conversations},
    ).asyncMap(conversations.mapFromRow);
  }

  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    weeklyReviews,
    achievements,
    streaks,
    dailyMetrics,
    agenticWal,
    projectState,
    distilledFacts,
    moodStates,
    auditLog,
    interventionStates,
    apiUsage,
    settings,
    stucknessSignals,
    briefings,
    monitoredNotifications,
    cachedCalendarEvents,
    cachedContacts,
    vesselTools,
    vesselTasks,
    vesselConfigs,
    profileTraits,
    projects,
    projectFacts,
    decisions,
    decisionsAi,
    decisionsAd,
    decisionsAu,
    messages,
    messagesAi,
    messagesAd,
    messagesAu,
    conversations,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'projects',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('project_facts', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'decisions',
        limitUpdateKind: UpdateKind.insert,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'decisions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'decisions',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'messages',
        limitUpdateKind: UpdateKind.insert,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'messages',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'messages',
        limitUpdateKind: UpdateKind.update,
      ),
      result: [],
    ),
  ]);
}

typedef $WeeklyReviewsCreateCompanionBuilder =
    WeeklyReviewsCompanion Function({
      Value<int> id,
      required String weekStart,
      required String content,
      Value<String?> metricsSummary,
      Value<double?> momentumScore,
      required int createdAt,
    });
typedef $WeeklyReviewsUpdateCompanionBuilder =
    WeeklyReviewsCompanion Function({
      Value<int> id,
      Value<String> weekStart,
      Value<String> content,
      Value<String?> metricsSummary,
      Value<double?> momentumScore,
      Value<int> createdAt,
    });

class $WeeklyReviewsFilterComposer
    extends Composer<_$SoulDatabase, WeeklyReviews> {
  $WeeklyReviewsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get weekStart => $composableBuilder(
    column: $table.weekStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metricsSummary => $composableBuilder(
    column: $table.metricsSummary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get momentumScore => $composableBuilder(
    column: $table.momentumScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $WeeklyReviewsOrderingComposer
    extends Composer<_$SoulDatabase, WeeklyReviews> {
  $WeeklyReviewsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get weekStart => $composableBuilder(
    column: $table.weekStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metricsSummary => $composableBuilder(
    column: $table.metricsSummary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get momentumScore => $composableBuilder(
    column: $table.momentumScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $WeeklyReviewsAnnotationComposer
    extends Composer<_$SoulDatabase, WeeklyReviews> {
  $WeeklyReviewsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get weekStart =>
      $composableBuilder(column: $table.weekStart, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get metricsSummary => $composableBuilder(
    column: $table.metricsSummary,
    builder: (column) => column,
  );

  GeneratedColumn<double> get momentumScore => $composableBuilder(
    column: $table.momentumScore,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $WeeklyReviewsTableManager
    extends
        RootTableManager<
          _$SoulDatabase,
          WeeklyReviews,
          WeeklyReview,
          $WeeklyReviewsFilterComposer,
          $WeeklyReviewsOrderingComposer,
          $WeeklyReviewsAnnotationComposer,
          $WeeklyReviewsCreateCompanionBuilder,
          $WeeklyReviewsUpdateCompanionBuilder,
          (
            WeeklyReview,
            BaseReferences<_$SoulDatabase, WeeklyReviews, WeeklyReview>,
          ),
          WeeklyReview,
          PrefetchHooks Function()
        > {
  $WeeklyReviewsTableManager(_$SoulDatabase db, WeeklyReviews table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $WeeklyReviewsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $WeeklyReviewsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $WeeklyReviewsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> weekStart = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String?> metricsSummary = const Value.absent(),
                Value<double?> momentumScore = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
              }) => WeeklyReviewsCompanion(
                id: id,
                weekStart: weekStart,
                content: content,
                metricsSummary: metricsSummary,
                momentumScore: momentumScore,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String weekStart,
                required String content,
                Value<String?> metricsSummary = const Value.absent(),
                Value<double?> momentumScore = const Value.absent(),
                required int createdAt,
              }) => WeeklyReviewsCompanion.insert(
                id: id,
                weekStart: weekStart,
                content: content,
                metricsSummary: metricsSummary,
                momentumScore: momentumScore,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $WeeklyReviewsProcessedTableManager =
    ProcessedTableManager<
      _$SoulDatabase,
      WeeklyReviews,
      WeeklyReview,
      $WeeklyReviewsFilterComposer,
      $WeeklyReviewsOrderingComposer,
      $WeeklyReviewsAnnotationComposer,
      $WeeklyReviewsCreateCompanionBuilder,
      $WeeklyReviewsUpdateCompanionBuilder,
      (
        WeeklyReview,
        BaseReferences<_$SoulDatabase, WeeklyReviews, WeeklyReview>,
      ),
      WeeklyReview,
      PrefetchHooks Function()
    >;
typedef $AchievementsCreateCompanionBuilder =
    AchievementsCompanion Function({
      Value<int> id,
      required String milestoneType,
      required int achievedAt,
      Value<String?> contextSummary,
      required String celebrationTier,
      Value<int> displayed,
    });
typedef $AchievementsUpdateCompanionBuilder =
    AchievementsCompanion Function({
      Value<int> id,
      Value<String> milestoneType,
      Value<int> achievedAt,
      Value<String?> contextSummary,
      Value<String> celebrationTier,
      Value<int> displayed,
    });

class $AchievementsFilterComposer
    extends Composer<_$SoulDatabase, Achievements> {
  $AchievementsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get milestoneType => $composableBuilder(
    column: $table.milestoneType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get achievedAt => $composableBuilder(
    column: $table.achievedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contextSummary => $composableBuilder(
    column: $table.contextSummary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get celebrationTier => $composableBuilder(
    column: $table.celebrationTier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get displayed => $composableBuilder(
    column: $table.displayed,
    builder: (column) => ColumnFilters(column),
  );
}

class $AchievementsOrderingComposer
    extends Composer<_$SoulDatabase, Achievements> {
  $AchievementsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get milestoneType => $composableBuilder(
    column: $table.milestoneType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get achievedAt => $composableBuilder(
    column: $table.achievedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contextSummary => $composableBuilder(
    column: $table.contextSummary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get celebrationTier => $composableBuilder(
    column: $table.celebrationTier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get displayed => $composableBuilder(
    column: $table.displayed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $AchievementsAnnotationComposer
    extends Composer<_$SoulDatabase, Achievements> {
  $AchievementsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get milestoneType => $composableBuilder(
    column: $table.milestoneType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get achievedAt => $composableBuilder(
    column: $table.achievedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contextSummary => $composableBuilder(
    column: $table.contextSummary,
    builder: (column) => column,
  );

  GeneratedColumn<String> get celebrationTier => $composableBuilder(
    column: $table.celebrationTier,
    builder: (column) => column,
  );

  GeneratedColumn<int> get displayed =>
      $composableBuilder(column: $table.displayed, builder: (column) => column);
}

class $AchievementsTableManager
    extends
        RootTableManager<
          _$SoulDatabase,
          Achievements,
          Achievement,
          $AchievementsFilterComposer,
          $AchievementsOrderingComposer,
          $AchievementsAnnotationComposer,
          $AchievementsCreateCompanionBuilder,
          $AchievementsUpdateCompanionBuilder,
          (
            Achievement,
            BaseReferences<_$SoulDatabase, Achievements, Achievement>,
          ),
          Achievement,
          PrefetchHooks Function()
        > {
  $AchievementsTableManager(_$SoulDatabase db, Achievements table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $AchievementsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $AchievementsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $AchievementsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> milestoneType = const Value.absent(),
                Value<int> achievedAt = const Value.absent(),
                Value<String?> contextSummary = const Value.absent(),
                Value<String> celebrationTier = const Value.absent(),
                Value<int> displayed = const Value.absent(),
              }) => AchievementsCompanion(
                id: id,
                milestoneType: milestoneType,
                achievedAt: achievedAt,
                contextSummary: contextSummary,
                celebrationTier: celebrationTier,
                displayed: displayed,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String milestoneType,
                required int achievedAt,
                Value<String?> contextSummary = const Value.absent(),
                required String celebrationTier,
                Value<int> displayed = const Value.absent(),
              }) => AchievementsCompanion.insert(
                id: id,
                milestoneType: milestoneType,
                achievedAt: achievedAt,
                contextSummary: contextSummary,
                celebrationTier: celebrationTier,
                displayed: displayed,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $AchievementsProcessedTableManager =
    ProcessedTableManager<
      _$SoulDatabase,
      Achievements,
      Achievement,
      $AchievementsFilterComposer,
      $AchievementsOrderingComposer,
      $AchievementsAnnotationComposer,
      $AchievementsCreateCompanionBuilder,
      $AchievementsUpdateCompanionBuilder,
      (Achievement, BaseReferences<_$SoulDatabase, Achievements, Achievement>),
      Achievement,
      PrefetchHooks Function()
    >;
typedef $StreaksCreateCompanionBuilder =
    StreaksCompanion Function({
      Value<int> id,
      required String streakType,
      Value<int> currentCount,
      Value<int> longestCount,
      required String lastActiveDate,
      Value<int> graceUsed,
      required int updatedAt,
    });
typedef $StreaksUpdateCompanionBuilder =
    StreaksCompanion Function({
      Value<int> id,
      Value<String> streakType,
      Value<int> currentCount,
      Value<int> longestCount,
      Value<String> lastActiveDate,
      Value<int> graceUsed,
      Value<int> updatedAt,
    });

class $StreaksFilterComposer extends Composer<_$SoulDatabase, Streaks> {
  $StreaksFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get streakType => $composableBuilder(
    column: $table.streakType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentCount => $composableBuilder(
    column: $table.currentCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get longestCount => $composableBuilder(
    column: $table.longestCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastActiveDate => $composableBuilder(
    column: $table.lastActiveDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get graceUsed => $composableBuilder(
    column: $table.graceUsed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $StreaksOrderingComposer extends Composer<_$SoulDatabase, Streaks> {
  $StreaksOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get streakType => $composableBuilder(
    column: $table.streakType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentCount => $composableBuilder(
    column: $table.currentCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get longestCount => $composableBuilder(
    column: $table.longestCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastActiveDate => $composableBuilder(
    column: $table.lastActiveDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get graceUsed => $composableBuilder(
    column: $table.graceUsed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $StreaksAnnotationComposer extends Composer<_$SoulDatabase, Streaks> {
  $StreaksAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get streakType => $composableBuilder(
    column: $table.streakType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get currentCount => $composableBuilder(
    column: $table.currentCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get longestCount => $composableBuilder(
    column: $table.longestCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastActiveDate => $composableBuilder(
    column: $table.lastActiveDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get graceUsed =>
      $composableBuilder(column: $table.graceUsed, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $StreaksTableManager
    extends
        RootTableManager<
          _$SoulDatabase,
          Streaks,
          Streak,
          $StreaksFilterComposer,
          $StreaksOrderingComposer,
          $StreaksAnnotationComposer,
          $StreaksCreateCompanionBuilder,
          $StreaksUpdateCompanionBuilder,
          (Streak, BaseReferences<_$SoulDatabase, Streaks, Streak>),
          Streak,
          PrefetchHooks Function()
        > {
  $StreaksTableManager(_$SoulDatabase db, Streaks table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $StreaksFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $StreaksOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $StreaksAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> streakType = const Value.absent(),
                Value<int> currentCount = const Value.absent(),
                Value<int> longestCount = const Value.absent(),
                Value<String> lastActiveDate = const Value.absent(),
                Value<int> graceUsed = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
              }) => StreaksCompanion(
                id: id,
                streakType: streakType,
                currentCount: currentCount,
                longestCount: longestCount,
                lastActiveDate: lastActiveDate,
                graceUsed: graceUsed,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String streakType,
                Value<int> currentCount = const Value.absent(),
                Value<int> longestCount = const Value.absent(),
                required String lastActiveDate,
                Value<int> graceUsed = const Value.absent(),
                required int updatedAt,
              }) => StreaksCompanion.insert(
                id: id,
                streakType: streakType,
                currentCount: currentCount,
                longestCount: longestCount,
                lastActiveDate: lastActiveDate,
                graceUsed: graceUsed,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $StreaksProcessedTableManager =
    ProcessedTableManager<
      _$SoulDatabase,
      Streaks,
      Streak,
      $StreaksFilterComposer,
      $StreaksOrderingComposer,
      $StreaksAnnotationComposer,
      $StreaksCreateCompanionBuilder,
      $StreaksUpdateCompanionBuilder,
      (Streak, BaseReferences<_$SoulDatabase, Streaks, Streak>),
      Streak,
      PrefetchHooks Function()
    >;
typedef $DailyMetricsCreateCompanionBuilder =
    DailyMetricsCompanion Function({
      Value<int> id,
      required String date,
      required String metricType,
      required double value,
      Value<String?> projectId,
      required int updatedAt,
    });
typedef $DailyMetricsUpdateCompanionBuilder =
    DailyMetricsCompanion Function({
      Value<int> id,
      Value<String> date,
      Value<String> metricType,
      Value<double> value,
      Value<String?> projectId,
      Value<int> updatedAt,
    });

class $DailyMetricsFilterComposer
    extends Composer<_$SoulDatabase, DailyMetrics> {
  $DailyMetricsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metricType => $composableBuilder(
    column: $table.metricType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $DailyMetricsOrderingComposer
    extends Composer<_$SoulDatabase, DailyMetrics> {
  $DailyMetricsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metricType => $composableBuilder(
    column: $table.metricType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $DailyMetricsAnnotationComposer
    extends Composer<_$SoulDatabase, DailyMetrics> {
  $DailyMetricsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get metricType => $composableBuilder(
    column: $table.metricType,
    builder: (column) => column,
  );

  GeneratedColumn<double> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $DailyMetricsTableManager
    extends
        RootTableManager<
          _$SoulDatabase,
          DailyMetrics,
          DailyMetric,
          $DailyMetricsFilterComposer,
          $DailyMetricsOrderingComposer,
          $DailyMetricsAnnotationComposer,
          $DailyMetricsCreateCompanionBuilder,
          $DailyMetricsUpdateCompanionBuilder,
          (
            DailyMetric,
            BaseReferences<_$SoulDatabase, DailyMetrics, DailyMetric>,
          ),
          DailyMetric,
          PrefetchHooks Function()
        > {
  $DailyMetricsTableManager(_$SoulDatabase db, DailyMetrics table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $DailyMetricsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $DailyMetricsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $DailyMetricsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> metricType = const Value.absent(),
                Value<double> value = const Value.absent(),
                Value<String?> projectId = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
              }) => DailyMetricsCompanion(
                id: id,
                date: date,
                metricType: metricType,
                value: value,
                projectId: projectId,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String date,
                required String metricType,
                required double value,
                Value<String?> projectId = const Value.absent(),
                required int updatedAt,
              }) => DailyMetricsCompanion.insert(
                id: id,
                date: date,
                metricType: metricType,
                value: value,
                projectId: projectId,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $DailyMetricsProcessedTableManager =
    ProcessedTableManager<
      _$SoulDatabase,
      DailyMetrics,
      DailyMetric,
      $DailyMetricsFilterComposer,
      $DailyMetricsOrderingComposer,
      $DailyMetricsAnnotationComposer,
      $DailyMetricsCreateCompanionBuilder,
      $DailyMetricsUpdateCompanionBuilder,
      (DailyMetric, BaseReferences<_$SoulDatabase, DailyMetrics, DailyMetric>),
      DailyMetric,
      PrefetchHooks Function()
    >;
typedef $AgenticWalCreateCompanionBuilder =
    AgenticWalCompanion Function({
      Value<int> id,
      required String sessionId,
      required int iteration,
      required String intention,
      required String toolName,
      required String toolArgs,
      Value<String> status,
      Value<String?> resultSummary,
      required int startedAt,
      Value<int?> completedAt,
    });
typedef $AgenticWalUpdateCompanionBuilder =
    AgenticWalCompanion Function({
      Value<int> id,
      Value<String> sessionId,
      Value<int> iteration,
      Value<String> intention,
      Value<String> toolName,
      Value<String> toolArgs,
      Value<String> status,
      Value<String?> resultSummary,
      Value<int> startedAt,
      Value<int?> completedAt,
    });

class $AgenticWalFilterComposer extends Composer<_$SoulDatabase, AgenticWal> {
  $AgenticWalFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get iteration => $composableBuilder(
    column: $table.iteration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get intention => $composableBuilder(
    column: $table.intention,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toolName => $composableBuilder(
    column: $table.toolName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toolArgs => $composableBuilder(
    column: $table.toolArgs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resultSummary => $composableBuilder(
    column: $table.resultSummary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $AgenticWalOrderingComposer extends Composer<_$SoulDatabase, AgenticWal> {
  $AgenticWalOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get iteration => $composableBuilder(
    column: $table.iteration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get intention => $composableBuilder(
    column: $table.intention,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toolName => $composableBuilder(
    column: $table.toolName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toolArgs => $composableBuilder(
    column: $table.toolArgs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resultSummary => $composableBuilder(
    column: $table.resultSummary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $AgenticWalAnnotationComposer
    extends Composer<_$SoulDatabase, AgenticWal> {
  $AgenticWalAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<int> get iteration =>
      $composableBuilder(column: $table.iteration, builder: (column) => column);

  GeneratedColumn<String> get intention =>
      $composableBuilder(column: $table.intention, builder: (column) => column);

  GeneratedColumn<String> get toolName =>
      $composableBuilder(column: $table.toolName, builder: (column) => column);

  GeneratedColumn<String> get toolArgs =>
      $composableBuilder(column: $table.toolArgs, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get resultSummary => $composableBuilder(
    column: $table.resultSummary,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );
}

class $AgenticWalTableManager
    extends
        RootTableManager<
          _$SoulDatabase,
          AgenticWal,
          AgenticWalData,
          $AgenticWalFilterComposer,
          $AgenticWalOrderingComposer,
          $AgenticWalAnnotationComposer,
          $AgenticWalCreateCompanionBuilder,
          $AgenticWalUpdateCompanionBuilder,
          (
            AgenticWalData,
            BaseReferences<_$SoulDatabase, AgenticWal, AgenticWalData>,
          ),
          AgenticWalData,
          PrefetchHooks Function()
        > {
  $AgenticWalTableManager(_$SoulDatabase db, AgenticWal table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $AgenticWalFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $AgenticWalOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $AgenticWalAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<int> iteration = const Value.absent(),
                Value<String> intention = const Value.absent(),
                Value<String> toolName = const Value.absent(),
                Value<String> toolArgs = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> resultSummary = const Value.absent(),
                Value<int> startedAt = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
              }) => AgenticWalCompanion(
                id: id,
                sessionId: sessionId,
                iteration: iteration,
                intention: intention,
                toolName: toolName,
                toolArgs: toolArgs,
                status: status,
                resultSummary: resultSummary,
                startedAt: startedAt,
                completedAt: completedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String sessionId,
                required int iteration,
                required String intention,
                required String toolName,
                required String toolArgs,
                Value<String> status = const Value.absent(),
                Value<String?> resultSummary = const Value.absent(),
                required int startedAt,
                Value<int?> completedAt = const Value.absent(),
              }) => AgenticWalCompanion.insert(
                id: id,
                sessionId: sessionId,
                iteration: iteration,
                intention: intention,
                toolName: toolName,
                toolArgs: toolArgs,
                status: status,
                resultSummary: resultSummary,
                startedAt: startedAt,
                completedAt: completedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $AgenticWalProcessedTableManager =
    ProcessedTableManager<
      _$SoulDatabase,
      AgenticWal,
      AgenticWalData,
      $AgenticWalFilterComposer,
      $AgenticWalOrderingComposer,
      $AgenticWalAnnotationComposer,
      $AgenticWalCreateCompanionBuilder,
      $AgenticWalUpdateCompanionBuilder,
      (
        AgenticWalData,
        BaseReferences<_$SoulDatabase, AgenticWal, AgenticWalData>,
      ),
      AgenticWalData,
      PrefetchHooks Function()
    >;
typedef $ProjectStateCreateCompanionBuilder =
    ProjectStateCompanion Function({
      Value<int> id,
      required String projectId,
      required String currentStatus,
      Value<String?> unvalidatedAssumptions,
      Value<String?> riskiestItem,
      Value<String?> scopeCreepFlags,
      required int updatedAt,
      Value<String?> sourceConversationId,
    });
typedef $ProjectStateUpdateCompanionBuilder =
    ProjectStateCompanion Function({
      Value<int> id,
      Value<String> projectId,
      Value<String> currentStatus,
      Value<String?> unvalidatedAssumptions,
      Value<String?> riskiestItem,
      Value<String?> scopeCreepFlags,
      Value<int> updatedAt,
      Value<String?> sourceConversationId,
    });

class $ProjectStateFilterComposer
    extends Composer<_$SoulDatabase, ProjectState> {
  $ProjectStateFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currentStatus => $composableBuilder(
    column: $table.currentStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unvalidatedAssumptions => $composableBuilder(
    column: $table.unvalidatedAssumptions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get riskiestItem => $composableBuilder(
    column: $table.riskiestItem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scopeCreepFlags => $composableBuilder(
    column: $table.scopeCreepFlags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceConversationId => $composableBuilder(
    column: $table.sourceConversationId,
    builder: (column) => ColumnFilters(column),
  );
}

class $ProjectStateOrderingComposer
    extends Composer<_$SoulDatabase, ProjectState> {
  $ProjectStateOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currentStatus => $composableBuilder(
    column: $table.currentStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unvalidatedAssumptions => $composableBuilder(
    column: $table.unvalidatedAssumptions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get riskiestItem => $composableBuilder(
    column: $table.riskiestItem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scopeCreepFlags => $composableBuilder(
    column: $table.scopeCreepFlags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceConversationId => $composableBuilder(
    column: $table.sourceConversationId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $ProjectStateAnnotationComposer
    extends Composer<_$SoulDatabase, ProjectState> {
  $ProjectStateAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<String> get currentStatus => $composableBuilder(
    column: $table.currentStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unvalidatedAssumptions => $composableBuilder(
    column: $table.unvalidatedAssumptions,
    builder: (column) => column,
  );

  GeneratedColumn<String> get riskiestItem => $composableBuilder(
    column: $table.riskiestItem,
    builder: (column) => column,
  );

  GeneratedColumn<String> get scopeCreepFlags => $composableBuilder(
    column: $table.scopeCreepFlags,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get sourceConversationId => $composableBuilder(
    column: $table.sourceConversationId,
    builder: (column) => column,
  );
}

class $ProjectStateTableManager
    extends
        RootTableManager<
          _$SoulDatabase,
          ProjectState,
          ProjectStateData,
          $ProjectStateFilterComposer,
          $ProjectStateOrderingComposer,
          $ProjectStateAnnotationComposer,
          $ProjectStateCreateCompanionBuilder,
          $ProjectStateUpdateCompanionBuilder,
          (
            ProjectStateData,
            BaseReferences<_$SoulDatabase, ProjectState, ProjectStateData>,
          ),
          ProjectStateData,
          PrefetchHooks Function()
        > {
  $ProjectStateTableManager(_$SoulDatabase db, ProjectState table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ProjectStateFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ProjectStateOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ProjectStateAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String> currentStatus = const Value.absent(),
                Value<String?> unvalidatedAssumptions = const Value.absent(),
                Value<String?> riskiestItem = const Value.absent(),
                Value<String?> scopeCreepFlags = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String?> sourceConversationId = const Value.absent(),
              }) => ProjectStateCompanion(
                id: id,
                projectId: projectId,
                currentStatus: currentStatus,
                unvalidatedAssumptions: unvalidatedAssumptions,
                riskiestItem: riskiestItem,
                scopeCreepFlags: scopeCreepFlags,
                updatedAt: updatedAt,
                sourceConversationId: sourceConversationId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String projectId,
                required String currentStatus,
                Value<String?> unvalidatedAssumptions = const Value.absent(),
                Value<String?> riskiestItem = const Value.absent(),
                Value<String?> scopeCreepFlags = const Value.absent(),
                required int updatedAt,
                Value<String?> sourceConversationId = const Value.absent(),
              }) => ProjectStateCompanion.insert(
                id: id,
                projectId: projectId,
                currentStatus: currentStatus,
                unvalidatedAssumptions: unvalidatedAssumptions,
                riskiestItem: riskiestItem,
                scopeCreepFlags: scopeCreepFlags,
                updatedAt: updatedAt,
                sourceConversationId: sourceConversationId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $ProjectStateProcessedTableManager =
    ProcessedTableManager<
      _$SoulDatabase,
      ProjectState,
      ProjectStateData,
      $ProjectStateFilterComposer,
      $ProjectStateOrderingComposer,
      $ProjectStateAnnotationComposer,
      $ProjectStateCreateCompanionBuilder,
      $ProjectStateUpdateCompanionBuilder,
      (
        ProjectStateData,
        BaseReferences<_$SoulDatabase, ProjectState, ProjectStateData>,
      ),
      ProjectStateData,
      PrefetchHooks Function()
    >;
typedef $DistilledFactsCreateCompanionBuilder =
    DistilledFactsCompanion Function({
      required String id,
      required String conversationId,
      required String category,
      Value<String?> factKey,
      required String factValue,
      Value<double> confidence,
      required int distilledAt,
      Value<String?> sourceMessageRange,
      Value<int> rowid,
    });
typedef $DistilledFactsUpdateCompanionBuilder =
    DistilledFactsCompanion Function({
      Value<String> id,
      Value<String> conversationId,
      Value<String> category,
      Value<String?> factKey,
      Value<String> factValue,
      Value<double> confidence,
      Value<int> distilledAt,
      Value<String?> sourceMessageRange,
      Value<int> rowid,
    });

class $DistilledFactsFilterComposer
    extends Composer<_$SoulDatabase, DistilledFacts> {
  $DistilledFactsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get factKey => $composableBuilder(
    column: $table.factKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get factValue => $composableBuilder(
    column: $table.factValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get distilledAt => $composableBuilder(
    column: $table.distilledAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceMessageRange => $composableBuilder(
    column: $table.sourceMessageRange,
    builder: (column) => ColumnFilters(column),
  );
}

class $DistilledFactsOrderingComposer
    extends Composer<_$SoulDatabase, DistilledFacts> {
  $DistilledFactsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get factKey => $composableBuilder(
    column: $table.factKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get factValue => $composableBuilder(
    column: $table.factValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get distilledAt => $composableBuilder(
    column: $table.distilledAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceMessageRange => $composableBuilder(
    column: $table.sourceMessageRange,
    builder: (column) => ColumnOrderings(column),
  );
}

class $DistilledFactsAnnotationComposer
    extends Composer<_$SoulDatabase, DistilledFacts> {
  $DistilledFactsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get factKey =>
      $composableBuilder(column: $table.factKey, builder: (column) => column);

  GeneratedColumn<String> get factValue =>
      $composableBuilder(column: $table.factValue, builder: (column) => column);

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<int> get distilledAt => $composableBuilder(
    column: $table.distilledAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sourceMessageRange => $composableBuilder(
    column: $table.sourceMessageRange,
    builder: (column) => column,
  );
}

class $DistilledFactsTableManager
    extends
        RootTableManager<
          _$SoulDatabase,
          DistilledFacts,
          DistilledFact,
          $DistilledFactsFilterComposer,
          $DistilledFactsOrderingComposer,
          $DistilledFactsAnnotationComposer,
          $DistilledFactsCreateCompanionBuilder,
          $DistilledFactsUpdateCompanionBuilder,
          (
            DistilledFact,
            BaseReferences<_$SoulDatabase, DistilledFacts, DistilledFact>,
          ),
          DistilledFact,
          PrefetchHooks Function()
        > {
  $DistilledFactsTableManager(_$SoulDatabase db, DistilledFacts table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $DistilledFactsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $DistilledFactsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $DistilledFactsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> conversationId = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String?> factKey = const Value.absent(),
                Value<String> factValue = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<int> distilledAt = const Value.absent(),
                Value<String?> sourceMessageRange = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DistilledFactsCompanion(
                id: id,
                conversationId: conversationId,
                category: category,
                factKey: factKey,
                factValue: factValue,
                confidence: confidence,
                distilledAt: distilledAt,
                sourceMessageRange: sourceMessageRange,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String conversationId,
                required String category,
                Value<String?> factKey = const Value.absent(),
                required String factValue,
                Value<double> confidence = const Value.absent(),
                required int distilledAt,
                Value<String?> sourceMessageRange = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DistilledFactsCompanion.insert(
                id: id,
                conversationId: conversationId,
                category: category,
                factKey: factKey,
                factValue: factValue,
                confidence: confidence,
                distilledAt: distilledAt,
                sourceMessageRange: sourceMessageRange,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $DistilledFactsProcessedTableManager =
    ProcessedTableManager<
      _$SoulDatabase,
      DistilledFacts,
      DistilledFact,
      $DistilledFactsFilterComposer,
      $DistilledFactsOrderingComposer,
      $DistilledFactsAnnotationComposer,
      $DistilledFactsCreateCompanionBuilder,
      $DistilledFactsUpdateCompanionBuilder,
      (
        DistilledFact,
        BaseReferences<_$SoulDatabase, DistilledFacts, DistilledFact>,
      ),
      DistilledFact,
      PrefetchHooks Function()
    >;
typedef $MoodStatesCreateCompanionBuilder =
    MoodStatesCompanion Function({
      required String id,
      required String sessionId,
      required int energy,
      required String emotion,
      required String intent,
      required int analyzedAt,
      required int messageCount,
      Value<int> rowid,
    });
typedef $MoodStatesUpdateCompanionBuilder =
    MoodStatesCompanion Function({
      Value<String> id,
      Value<String> sessionId,
      Value<int> energy,
      Value<String> emotion,
      Value<String> intent,
      Value<int> analyzedAt,
      Value<int> messageCount,
      Value<int> rowid,
    });

class $MoodStatesFilterComposer extends Composer<_$SoulDatabase, MoodStates> {
  $MoodStatesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get energy => $composableBuilder(
    column: $table.energy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emotion => $composableBuilder(
    column: $table.emotion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get intent => $composableBuilder(
    column: $table.intent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get analyzedAt => $composableBuilder(
    column: $table.analyzedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get messageCount => $composableBuilder(
    column: $table.messageCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $MoodStatesOrderingComposer extends Composer<_$SoulDatabase, MoodStates> {
  $MoodStatesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get energy => $composableBuilder(
    column: $table.energy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emotion => $composableBuilder(
    column: $table.emotion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get intent => $composableBuilder(
    column: $table.intent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get analyzedAt => $composableBuilder(
    column: $table.analyzedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get messageCount => $composableBuilder(
    column: $table.messageCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $MoodStatesAnnotationComposer
    extends Composer<_$SoulDatabase, MoodStates> {
  $MoodStatesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<int> get energy =>
      $composableBuilder(column: $table.energy, builder: (column) => column);

  GeneratedColumn<String> get emotion =>
      $composableBuilder(column: $table.emotion, builder: (column) => column);

  GeneratedColumn<String> get intent =>
      $composableBuilder(column: $table.intent, builder: (column) => column);

  GeneratedColumn<int> get analyzedAt => $composableBuilder(
    column: $table.analyzedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get messageCount => $composableBuilder(
    column: $table.messageCount,
    builder: (column) => column,
  );
}

class $MoodStatesTableManager
    extends
        RootTableManager<
          _$SoulDatabase,
          MoodStates,
          MoodState,
          $MoodStatesFilterComposer,
          $MoodStatesOrderingComposer,
          $MoodStatesAnnotationComposer,
          $MoodStatesCreateCompanionBuilder,
          $MoodStatesUpdateCompanionBuilder,
          (MoodState, BaseReferences<_$SoulDatabase, MoodStates, MoodState>),
          MoodState,
          PrefetchHooks Function()
        > {
  $MoodStatesTableManager(_$SoulDatabase db, MoodStates table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $MoodStatesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $MoodStatesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $MoodStatesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<int> energy = const Value.absent(),
                Value<String> emotion = const Value.absent(),
                Value<String> intent = const Value.absent(),
                Value<int> analyzedAt = const Value.absent(),
                Value<int> messageCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MoodStatesCompanion(
                id: id,
                sessionId: sessionId,
                energy: energy,
                emotion: emotion,
                intent: intent,
                analyzedAt: analyzedAt,
                messageCount: messageCount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String sessionId,
                required int energy,
                required String emotion,
                required String intent,
                required int analyzedAt,
                required int messageCount,
                Value<int> rowid = const Value.absent(),
              }) => MoodStatesCompanion.insert(
                id: id,
                sessionId: sessionId,
                energy: energy,
                emotion: emotion,
                intent: intent,
                analyzedAt: analyzedAt,
                messageCount: messageCount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $MoodStatesProcessedTableManager =
    ProcessedTableManager<
      _$SoulDatabase,
      MoodStates,
      MoodState,
      $MoodStatesFilterComposer,
      $MoodStatesOrderingComposer,
      $MoodStatesAnnotationComposer,
      $MoodStatesCreateCompanionBuilder,
      $MoodStatesUpdateCompanionBuilder,
      (MoodState, BaseReferences<_$SoulDatabase, MoodStates, MoodState>),
      MoodState,
      PrefetchHooks Function()
    >;
typedef $AuditLogCreateCompanionBuilder =
    AuditLogCompanion Function({
      Value<int> id,
      required String actionType,
      required String toolName,
      required int tier,
      Value<String?> reasoning,
      Value<String?> result,
      required int executedAt,
      Value<String?> sessionId,
      Value<String?> vesselType,
    });
typedef $AuditLogUpdateCompanionBuilder =
    AuditLogCompanion Function({
      Value<int> id,
      Value<String> actionType,
      Value<String> toolName,
      Value<int> tier,
      Value<String?> reasoning,
      Value<String?> result,
      Value<int> executedAt,
      Value<String?> sessionId,
      Value<String?> vesselType,
    });

class $AuditLogFilterComposer extends Composer<_$SoulDatabase, AuditLog> {
  $AuditLogFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toolName => $composableBuilder(
    column: $table.toolName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tier => $composableBuilder(
    column: $table.tier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reasoning => $composableBuilder(
    column: $table.reasoning,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get result => $composableBuilder(
    column: $table.result,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get executedAt => $composableBuilder(
    column: $table.executedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vesselType => $composableBuilder(
    column: $table.vesselType,
    builder: (column) => ColumnFilters(column),
  );
}

class $AuditLogOrderingComposer extends Composer<_$SoulDatabase, AuditLog> {
  $AuditLogOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toolName => $composableBuilder(
    column: $table.toolName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tier => $composableBuilder(
    column: $table.tier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reasoning => $composableBuilder(
    column: $table.reasoning,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get result => $composableBuilder(
    column: $table.result,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get executedAt => $composableBuilder(
    column: $table.executedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vesselType => $composableBuilder(
    column: $table.vesselType,
    builder: (column) => ColumnOrderings(column),
  );
}

class $AuditLogAnnotationComposer extends Composer<_$SoulDatabase, AuditLog> {
  $AuditLogAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get actionType => $composableBuilder(
    column: $table.actionType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get toolName =>
      $composableBuilder(column: $table.toolName, builder: (column) => column);

  GeneratedColumn<int> get tier =>
      $composableBuilder(column: $table.tier, builder: (column) => column);

  GeneratedColumn<String> get reasoning =>
      $composableBuilder(column: $table.reasoning, builder: (column) => column);

  GeneratedColumn<String> get result =>
      $composableBuilder(column: $table.result, builder: (column) => column);

  GeneratedColumn<int> get executedAt => $composableBuilder(
    column: $table.executedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumn<String> get vesselType => $composableBuilder(
    column: $table.vesselType,
    builder: (column) => column,
  );
}

class $AuditLogTableManager
    extends
        RootTableManager<
          _$SoulDatabase,
          AuditLog,
          AuditLogData,
          $AuditLogFilterComposer,
          $AuditLogOrderingComposer,
          $AuditLogAnnotationComposer,
          $AuditLogCreateCompanionBuilder,
          $AuditLogUpdateCompanionBuilder,
          (
            AuditLogData,
            BaseReferences<_$SoulDatabase, AuditLog, AuditLogData>,
          ),
          AuditLogData,
          PrefetchHooks Function()
        > {
  $AuditLogTableManager(_$SoulDatabase db, AuditLog table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $AuditLogFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $AuditLogOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $AuditLogAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> actionType = const Value.absent(),
                Value<String> toolName = const Value.absent(),
                Value<int> tier = const Value.absent(),
                Value<String?> reasoning = const Value.absent(),
                Value<String?> result = const Value.absent(),
                Value<int> executedAt = const Value.absent(),
                Value<String?> sessionId = const Value.absent(),
                Value<String?> vesselType = const Value.absent(),
              }) => AuditLogCompanion(
                id: id,
                actionType: actionType,
                toolName: toolName,
                tier: tier,
                reasoning: reasoning,
                result: result,
                executedAt: executedAt,
                sessionId: sessionId,
                vesselType: vesselType,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String actionType,
                required String toolName,
                required int tier,
                Value<String?> reasoning = const Value.absent(),
                Value<String?> result = const Value.absent(),
                required int executedAt,
                Value<String?> sessionId = const Value.absent(),
                Value<String?> vesselType = const Value.absent(),
              }) => AuditLogCompanion.insert(
                id: id,
                actionType: actionType,
                toolName: toolName,
                tier: tier,
                reasoning: reasoning,
                result: result,
                executedAt: executedAt,
                sessionId: sessionId,
                vesselType: vesselType,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $AuditLogProcessedTableManager =
    ProcessedTableManager<
      _$SoulDatabase,
      AuditLog,
      AuditLogData,
      $AuditLogFilterComposer,
      $AuditLogOrderingComposer,
      $AuditLogAnnotationComposer,
      $AuditLogCreateCompanionBuilder,
      $AuditLogUpdateCompanionBuilder,
      (AuditLogData, BaseReferences<_$SoulDatabase, AuditLog, AuditLogData>),
      AuditLogData,
      PrefetchHooks Function()
    >;
typedef $InterventionStatesCreateCompanionBuilder =
    InterventionStatesCompanion Function({
      required String id,
      required String type,
      required String level,
      required String triggerDescription,
      Value<String?> proposedDefault,
      Value<int?> proposalDeadlineAt,
      required int detectedAt,
      Value<int?> level1SentAt,
      Value<int?> level2SentAt,
      Value<int?> level3SentAt,
      Value<int?> resolvedAt,
      Value<String?> relatedEntityId,
      Value<int> rowid,
    });
typedef $InterventionStatesUpdateCompanionBuilder =
    InterventionStatesCompanion Function({
      Value<String> id,
      Value<String> type,
      Value<String> level,
      Value<String> triggerDescription,
      Value<String?> proposedDefault,
      Value<int?> proposalDeadlineAt,
      Value<int> detectedAt,
      Value<int?> level1SentAt,
      Value<int?> level2SentAt,
      Value<int?> level3SentAt,
      Value<int?> resolvedAt,
      Value<String?> relatedEntityId,
      Value<int> rowid,
    });

class $InterventionStatesFilterComposer
    extends Composer<_$SoulDatabase, InterventionStates> {
  $InterventionStatesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get triggerDescription => $composableBuilder(
    column: $table.triggerDescription,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get proposedDefault => $composableBuilder(
    column: $table.proposedDefault,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get proposalDeadlineAt => $composableBuilder(
    column: $table.proposalDeadlineAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get detectedAt => $composableBuilder(
    column: $table.detectedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get level1SentAt => $composableBuilder(
    column: $table.level1SentAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get level2SentAt => $composableBuilder(
    column: $table.level2SentAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get level3SentAt => $composableBuilder(
    column: $table.level3SentAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relatedEntityId => $composableBuilder(
    column: $table.relatedEntityId,
    builder: (column) => ColumnFilters(column),
  );
}

class $InterventionStatesOrderingComposer
    extends Composer<_$SoulDatabase, InterventionStates> {
  $InterventionStatesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get level => $composableBuilder(
    column: $table.level,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get triggerDescription => $composableBuilder(
    column: $table.triggerDescription,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get proposedDefault => $composableBuilder(
    column: $table.proposedDefault,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get proposalDeadlineAt => $composableBuilder(
    column: $table.proposalDeadlineAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get detectedAt => $composableBuilder(
    column: $table.detectedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get level1SentAt => $composableBuilder(
    column: $table.level1SentAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get level2SentAt => $composableBuilder(
    column: $table.level2SentAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get level3SentAt => $composableBuilder(
    column: $table.level3SentAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relatedEntityId => $composableBuilder(
    column: $table.relatedEntityId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $InterventionStatesAnnotationComposer
    extends Composer<_$SoulDatabase, InterventionStates> {
  $InterventionStatesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get level =>
      $composableBuilder(column: $table.level, builder: (column) => column);

  GeneratedColumn<String> get triggerDescription => $composableBuilder(
    column: $table.triggerDescription,
    builder: (column) => column,
  );

  GeneratedColumn<String> get proposedDefault => $composableBuilder(
    column: $table.proposedDefault,
    builder: (column) => column,
  );

  GeneratedColumn<int> get proposalDeadlineAt => $composableBuilder(
    column: $table.proposalDeadlineAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get detectedAt => $composableBuilder(
    column: $table.detectedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get level1SentAt => $composableBuilder(
    column: $table.level1SentAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get level2SentAt => $composableBuilder(
    column: $table.level2SentAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get level3SentAt => $composableBuilder(
    column: $table.level3SentAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get relatedEntityId => $composableBuilder(
    column: $table.relatedEntityId,
    builder: (column) => column,
  );
}

class $InterventionStatesTableManager
    extends
        RootTableManager<
          _$SoulDatabase,
          InterventionStates,
          InterventionRow,
          $InterventionStatesFilterComposer,
          $InterventionStatesOrderingComposer,
          $InterventionStatesAnnotationComposer,
          $InterventionStatesCreateCompanionBuilder,
          $InterventionStatesUpdateCompanionBuilder,
          (
            InterventionRow,
            BaseReferences<_$SoulDatabase, InterventionStates, InterventionRow>,
          ),
          InterventionRow,
          PrefetchHooks Function()
        > {
  $InterventionStatesTableManager(_$SoulDatabase db, InterventionStates table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $InterventionStatesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $InterventionStatesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $InterventionStatesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> level = const Value.absent(),
                Value<String> triggerDescription = const Value.absent(),
                Value<String?> proposedDefault = const Value.absent(),
                Value<int?> proposalDeadlineAt = const Value.absent(),
                Value<int> detectedAt = const Value.absent(),
                Value<int?> level1SentAt = const Value.absent(),
                Value<int?> level2SentAt = const Value.absent(),
                Value<int?> level3SentAt = const Value.absent(),
                Value<int?> resolvedAt = const Value.absent(),
                Value<String?> relatedEntityId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InterventionStatesCompanion(
                id: id,
                type: type,
                level: level,
                triggerDescription: triggerDescription,
                proposedDefault: proposedDefault,
                proposalDeadlineAt: proposalDeadlineAt,
                detectedAt: detectedAt,
                level1SentAt: level1SentAt,
                level2SentAt: level2SentAt,
                level3SentAt: level3SentAt,
                resolvedAt: resolvedAt,
                relatedEntityId: relatedEntityId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String type,
                required String level,
                required String triggerDescription,
                Value<String?> proposedDefault = const Value.absent(),
                Value<int?> proposalDeadlineAt = const Value.absent(),
                required int detectedAt,
                Value<int?> level1SentAt = const Value.absent(),
                Value<int?> level2SentAt = const Value.absent(),
                Value<int?> level3SentAt = const Value.absent(),
                Value<int?> resolvedAt = const Value.absent(),
                Value<String?> relatedEntityId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InterventionStatesCompanion.insert(
                id: id,
                type: type,
                level: level,
                triggerDescription: triggerDescription,
                proposedDefault: proposedDefault,
                proposalDeadlineAt: proposalDeadlineAt,
                detectedAt: detectedAt,
                level1SentAt: level1SentAt,
                level2SentAt: level2SentAt,
                level3SentAt: level3SentAt,
                resolvedAt: resolvedAt,
                relatedEntityId: relatedEntityId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $InterventionStatesProcessedTableManager =
    ProcessedTableManager<
      _$SoulDatabase,
      InterventionStates,
      InterventionRow,
      $InterventionStatesFilterComposer,
      $InterventionStatesOrderingComposer,
      $InterventionStatesAnnotationComposer,
      $InterventionStatesCreateCompanionBuilder,
      $InterventionStatesUpdateCompanionBuilder,
      (
        InterventionRow,
        BaseReferences<_$SoulDatabase, InterventionStates, InterventionRow>,
      ),
      InterventionRow,
      PrefetchHooks Function()
    >;
typedef $ApiUsageCreateCompanionBuilder =
    ApiUsageCompanion Function({
      Value<int> id,
      Value<int?> conversationId,
      required String model,
      required int inputTokens,
      required int outputTokens,
      Value<int> cacheCreationTokens,
      Value<int> cacheReadTokens,
      required double costUsd,
      required int createdAt,
    });
typedef $ApiUsageUpdateCompanionBuilder =
    ApiUsageCompanion Function({
      Value<int> id,
      Value<int?> conversationId,
      Value<String> model,
      Value<int> inputTokens,
      Value<int> outputTokens,
      Value<int> cacheCreationTokens,
      Value<int> cacheReadTokens,
      Value<double> costUsd,
      Value<int> createdAt,
    });

class $ApiUsageFilterComposer extends Composer<_$SoulDatabase, ApiUsage> {
  $ApiUsageFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get inputTokens => $composableBuilder(
    column: $table.inputTokens,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get outputTokens => $composableBuilder(
    column: $table.outputTokens,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cacheCreationTokens => $composableBuilder(
    column: $table.cacheCreationTokens,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cacheReadTokens => $composableBuilder(
    column: $table.cacheReadTokens,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get costUsd => $composableBuilder(
    column: $table.costUsd,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $ApiUsageOrderingComposer extends Composer<_$SoulDatabase, ApiUsage> {
  $ApiUsageOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get inputTokens => $composableBuilder(
    column: $table.inputTokens,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get outputTokens => $composableBuilder(
    column: $table.outputTokens,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cacheCreationTokens => $composableBuilder(
    column: $table.cacheCreationTokens,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cacheReadTokens => $composableBuilder(
    column: $table.cacheReadTokens,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get costUsd => $composableBuilder(
    column: $table.costUsd,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $ApiUsageAnnotationComposer extends Composer<_$SoulDatabase, ApiUsage> {
  $ApiUsageAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<int> get inputTokens => $composableBuilder(
    column: $table.inputTokens,
    builder: (column) => column,
  );

  GeneratedColumn<int> get outputTokens => $composableBuilder(
    column: $table.outputTokens,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cacheCreationTokens => $composableBuilder(
    column: $table.cacheCreationTokens,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cacheReadTokens => $composableBuilder(
    column: $table.cacheReadTokens,
    builder: (column) => column,
  );

  GeneratedColumn<double> get costUsd =>
      $composableBuilder(column: $table.costUsd, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $ApiUsageTableManager
    extends
        RootTableManager<
          _$SoulDatabase,
          ApiUsage,
          ApiUsageData,
          $ApiUsageFilterComposer,
          $ApiUsageOrderingComposer,
          $ApiUsageAnnotationComposer,
          $ApiUsageCreateCompanionBuilder,
          $ApiUsageUpdateCompanionBuilder,
          (
            ApiUsageData,
            BaseReferences<_$SoulDatabase, ApiUsage, ApiUsageData>,
          ),
          ApiUsageData,
          PrefetchHooks Function()
        > {
  $ApiUsageTableManager(_$SoulDatabase db, ApiUsage table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ApiUsageFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ApiUsageOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ApiUsageAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> conversationId = const Value.absent(),
                Value<String> model = const Value.absent(),
                Value<int> inputTokens = const Value.absent(),
                Value<int> outputTokens = const Value.absent(),
                Value<int> cacheCreationTokens = const Value.absent(),
                Value<int> cacheReadTokens = const Value.absent(),
                Value<double> costUsd = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
              }) => ApiUsageCompanion(
                id: id,
                conversationId: conversationId,
                model: model,
                inputTokens: inputTokens,
                outputTokens: outputTokens,
                cacheCreationTokens: cacheCreationTokens,
                cacheReadTokens: cacheReadTokens,
                costUsd: costUsd,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> conversationId = const Value.absent(),
                required String model,
                required int inputTokens,
                required int outputTokens,
                Value<int> cacheCreationTokens = const Value.absent(),
                Value<int> cacheReadTokens = const Value.absent(),
                required double costUsd,
                required int createdAt,
              }) => ApiUsageCompanion.insert(
                id: id,
                conversationId: conversationId,
                model: model,
                inputTokens: inputTokens,
                outputTokens: outputTokens,
                cacheCreationTokens: cacheCreationTokens,
                cacheReadTokens: cacheReadTokens,
                costUsd: costUsd,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $ApiUsageProcessedTableManager =
    ProcessedTableManager<
      _$SoulDatabase,
      ApiUsage,
      ApiUsageData,
      $ApiUsageFilterComposer,
      $ApiUsageOrderingComposer,
      $ApiUsageAnnotationComposer,
      $ApiUsageCreateCompanionBuilder,
      $ApiUsageUpdateCompanionBuilder,
      (ApiUsageData, BaseReferences<_$SoulDatabase, ApiUsage, ApiUsageData>),
      ApiUsageData,
      PrefetchHooks Function()
    >;
typedef $SettingsCreateCompanionBuilder =
    SettingsCompanion Function({
      Value<int> id,
      required String settingKey,
      required String value,
      required int updatedAt,
    });
typedef $SettingsUpdateCompanionBuilder =
    SettingsCompanion Function({
      Value<int> id,
      Value<String> settingKey,
      Value<String> value,
      Value<int> updatedAt,
    });

class $SettingsFilterComposer extends Composer<_$SoulDatabase, Settings> {
  $SettingsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get settingKey => $composableBuilder(
    column: $table.settingKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $SettingsOrderingComposer extends Composer<_$SoulDatabase, Settings> {
  $SettingsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get settingKey => $composableBuilder(
    column: $table.settingKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $SettingsAnnotationComposer extends Composer<_$SoulDatabase, Settings> {
  $SettingsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get settingKey => $composableBuilder(
    column: $table.settingKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $SettingsTableManager
    extends
        RootTableManager<
          _$SoulDatabase,
          Settings,
          Setting,
          $SettingsFilterComposer,
          $SettingsOrderingComposer,
          $SettingsAnnotationComposer,
          $SettingsCreateCompanionBuilder,
          $SettingsUpdateCompanionBuilder,
          (Setting, BaseReferences<_$SoulDatabase, Settings, Setting>),
          Setting,
          PrefetchHooks Function()
        > {
  $SettingsTableManager(_$SoulDatabase db, Settings table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $SettingsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $SettingsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $SettingsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> settingKey = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
              }) => SettingsCompanion(
                id: id,
                settingKey: settingKey,
                value: value,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String settingKey,
                required String value,
                required int updatedAt,
              }) => SettingsCompanion.insert(
                id: id,
                settingKey: settingKey,
                value: value,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $SettingsProcessedTableManager =
    ProcessedTableManager<
      _$SoulDatabase,
      Settings,
      Setting,
      $SettingsFilterComposer,
      $SettingsOrderingComposer,
      $SettingsAnnotationComposer,
      $SettingsCreateCompanionBuilder,
      $SettingsUpdateCompanionBuilder,
      (Setting, BaseReferences<_$SoulDatabase, Settings, Setting>),
      Setting,
      PrefetchHooks Function()
    >;
typedef $StucknessSignalsCreateCompanionBuilder =
    StucknessSignalsCompanion Function({
      Value<int> id,
      required String topic,
      required int conversationCount,
      required int decisionCount,
      required int firstSeen,
      required int lastSeen,
      required double score,
      Value<int> nudgeSent,
    });
typedef $StucknessSignalsUpdateCompanionBuilder =
    StucknessSignalsCompanion Function({
      Value<int> id,
      Value<String> topic,
      Value<int> conversationCount,
      Value<int> decisionCount,
      Value<int> firstSeen,
      Value<int> lastSeen,
      Value<double> score,
      Value<int> nudgeSent,
    });

class $StucknessSignalsFilterComposer
    extends Composer<_$SoulDatabase, StucknessSignals> {
  $StucknessSignalsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get topic => $composableBuilder(
    column: $table.topic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get conversationCount => $composableBuilder(
    column: $table.conversationCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get decisionCount => $composableBuilder(
    column: $table.decisionCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get firstSeen => $composableBuilder(
    column: $table.firstSeen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSeen => $composableBuilder(
    column: $table.lastSeen,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nudgeSent => $composableBuilder(
    column: $table.nudgeSent,
    builder: (column) => ColumnFilters(column),
  );
}

class $StucknessSignalsOrderingComposer
    extends Composer<_$SoulDatabase, StucknessSignals> {
  $StucknessSignalsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get topic => $composableBuilder(
    column: $table.topic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get conversationCount => $composableBuilder(
    column: $table.conversationCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get decisionCount => $composableBuilder(
    column: $table.decisionCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get firstSeen => $composableBuilder(
    column: $table.firstSeen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSeen => $composableBuilder(
    column: $table.lastSeen,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nudgeSent => $composableBuilder(
    column: $table.nudgeSent,
    builder: (column) => ColumnOrderings(column),
  );
}

class $StucknessSignalsAnnotationComposer
    extends Composer<_$SoulDatabase, StucknessSignals> {
  $StucknessSignalsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get topic =>
      $composableBuilder(column: $table.topic, builder: (column) => column);

  GeneratedColumn<int> get conversationCount => $composableBuilder(
    column: $table.conversationCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get decisionCount => $composableBuilder(
    column: $table.decisionCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get firstSeen =>
      $composableBuilder(column: $table.firstSeen, builder: (column) => column);

  GeneratedColumn<int> get lastSeen =>
      $composableBuilder(column: $table.lastSeen, builder: (column) => column);

  GeneratedColumn<double> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<int> get nudgeSent =>
      $composableBuilder(column: $table.nudgeSent, builder: (column) => column);
}

class $StucknessSignalsTableManager
    extends
        RootTableManager<
          _$SoulDatabase,
          StucknessSignals,
          StucknessSignal,
          $StucknessSignalsFilterComposer,
          $StucknessSignalsOrderingComposer,
          $StucknessSignalsAnnotationComposer,
          $StucknessSignalsCreateCompanionBuilder,
          $StucknessSignalsUpdateCompanionBuilder,
          (
            StucknessSignal,
            BaseReferences<_$SoulDatabase, StucknessSignals, StucknessSignal>,
          ),
          StucknessSignal,
          PrefetchHooks Function()
        > {
  $StucknessSignalsTableManager(_$SoulDatabase db, StucknessSignals table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $StucknessSignalsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $StucknessSignalsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $StucknessSignalsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> topic = const Value.absent(),
                Value<int> conversationCount = const Value.absent(),
                Value<int> decisionCount = const Value.absent(),
                Value<int> firstSeen = const Value.absent(),
                Value<int> lastSeen = const Value.absent(),
                Value<double> score = const Value.absent(),
                Value<int> nudgeSent = const Value.absent(),
              }) => StucknessSignalsCompanion(
                id: id,
                topic: topic,
                conversationCount: conversationCount,
                decisionCount: decisionCount,
                firstSeen: firstSeen,
                lastSeen: lastSeen,
                score: score,
                nudgeSent: nudgeSent,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String topic,
                required int conversationCount,
                required int decisionCount,
                required int firstSeen,
                required int lastSeen,
                required double score,
                Value<int> nudgeSent = const Value.absent(),
              }) => StucknessSignalsCompanion.insert(
                id: id,
                topic: topic,
                conversationCount: conversationCount,
                decisionCount: decisionCount,
                firstSeen: firstSeen,
                lastSeen: lastSeen,
                score: score,
                nudgeSent: nudgeSent,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $StucknessSignalsProcessedTableManager =
    ProcessedTableManager<
      _$SoulDatabase,
      StucknessSignals,
      StucknessSignal,
      $StucknessSignalsFilterComposer,
      $StucknessSignalsOrderingComposer,
      $StucknessSignalsAnnotationComposer,
      $StucknessSignalsCreateCompanionBuilder,
      $StucknessSignalsUpdateCompanionBuilder,
      (
        StucknessSignal,
        BaseReferences<_$SoulDatabase, StucknessSignals, StucknessSignal>,
      ),
      StucknessSignal,
      PrefetchHooks Function()
    >;
typedef $BriefingsCreateCompanionBuilder =
    BriefingsCompanion Function({
      Value<int> id,
      required String date,
      required String content,
      Value<String?> priorities,
      Value<String?> calendarSummary,
      required int createdAt,
      Value<int?> conversationId,
    });
typedef $BriefingsUpdateCompanionBuilder =
    BriefingsCompanion Function({
      Value<int> id,
      Value<String> date,
      Value<String> content,
      Value<String?> priorities,
      Value<String?> calendarSummary,
      Value<int> createdAt,
      Value<int?> conversationId,
    });

class $BriefingsFilterComposer extends Composer<_$SoulDatabase, Briefings> {
  $BriefingsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get priorities => $composableBuilder(
    column: $table.priorities,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get calendarSummary => $composableBuilder(
    column: $table.calendarSummary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnFilters(column),
  );
}

class $BriefingsOrderingComposer extends Composer<_$SoulDatabase, Briefings> {
  $BriefingsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get priorities => $composableBuilder(
    column: $table.priorities,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get calendarSummary => $composableBuilder(
    column: $table.calendarSummary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $BriefingsAnnotationComposer extends Composer<_$SoulDatabase, Briefings> {
  $BriefingsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get priorities => $composableBuilder(
    column: $table.priorities,
    builder: (column) => column,
  );

  GeneratedColumn<String> get calendarSummary => $composableBuilder(
    column: $table.calendarSummary,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => column,
  );
}

class $BriefingsTableManager
    extends
        RootTableManager<
          _$SoulDatabase,
          Briefings,
          Briefing,
          $BriefingsFilterComposer,
          $BriefingsOrderingComposer,
          $BriefingsAnnotationComposer,
          $BriefingsCreateCompanionBuilder,
          $BriefingsUpdateCompanionBuilder,
          (Briefing, BaseReferences<_$SoulDatabase, Briefings, Briefing>),
          Briefing,
          PrefetchHooks Function()
        > {
  $BriefingsTableManager(_$SoulDatabase db, Briefings table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $BriefingsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $BriefingsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $BriefingsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String?> priorities = const Value.absent(),
                Value<String?> calendarSummary = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int?> conversationId = const Value.absent(),
              }) => BriefingsCompanion(
                id: id,
                date: date,
                content: content,
                priorities: priorities,
                calendarSummary: calendarSummary,
                createdAt: createdAt,
                conversationId: conversationId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String date,
                required String content,
                Value<String?> priorities = const Value.absent(),
                Value<String?> calendarSummary = const Value.absent(),
                required int createdAt,
                Value<int?> conversationId = const Value.absent(),
              }) => BriefingsCompanion.insert(
                id: id,
                date: date,
                content: content,
                priorities: priorities,
                calendarSummary: calendarSummary,
                createdAt: createdAt,
                conversationId: conversationId,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $BriefingsProcessedTableManager =
    ProcessedTableManager<
      _$SoulDatabase,
      Briefings,
      Briefing,
      $BriefingsFilterComposer,
      $BriefingsOrderingComposer,
      $BriefingsAnnotationComposer,
      $BriefingsCreateCompanionBuilder,
      $BriefingsUpdateCompanionBuilder,
      (Briefing, BaseReferences<_$SoulDatabase, Briefings, Briefing>),
      Briefing,
      PrefetchHooks Function()
    >;
typedef $MonitoredNotificationsCreateCompanionBuilder =
    MonitoredNotificationsCompanion Function({
      Value<int> id,
      required String packageName,
      Value<String?> title,
      Value<String?> content,
      required int timestamp,
      Value<String?> category,
      Value<int> isRelevant,
      Value<int> isSurfaced,
    });
typedef $MonitoredNotificationsUpdateCompanionBuilder =
    MonitoredNotificationsCompanion Function({
      Value<int> id,
      Value<String> packageName,
      Value<String?> title,
      Value<String?> content,
      Value<int> timestamp,
      Value<String?> category,
      Value<int> isRelevant,
      Value<int> isSurfaced,
    });

class $MonitoredNotificationsFilterComposer
    extends Composer<_$SoulDatabase, MonitoredNotifications> {
  $MonitoredNotificationsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isRelevant => $composableBuilder(
    column: $table.isRelevant,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isSurfaced => $composableBuilder(
    column: $table.isSurfaced,
    builder: (column) => ColumnFilters(column),
  );
}

class $MonitoredNotificationsOrderingComposer
    extends Composer<_$SoulDatabase, MonitoredNotifications> {
  $MonitoredNotificationsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timestamp => $composableBuilder(
    column: $table.timestamp,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isRelevant => $composableBuilder(
    column: $table.isRelevant,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isSurfaced => $composableBuilder(
    column: $table.isSurfaced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $MonitoredNotificationsAnnotationComposer
    extends Composer<_$SoulDatabase, MonitoredNotifications> {
  $MonitoredNotificationsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get packageName => $composableBuilder(
    column: $table.packageName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<int> get timestamp =>
      $composableBuilder(column: $table.timestamp, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get isRelevant => $composableBuilder(
    column: $table.isRelevant,
    builder: (column) => column,
  );

  GeneratedColumn<int> get isSurfaced => $composableBuilder(
    column: $table.isSurfaced,
    builder: (column) => column,
  );
}

class $MonitoredNotificationsTableManager
    extends
        RootTableManager<
          _$SoulDatabase,
          MonitoredNotifications,
          MonitoredNotification,
          $MonitoredNotificationsFilterComposer,
          $MonitoredNotificationsOrderingComposer,
          $MonitoredNotificationsAnnotationComposer,
          $MonitoredNotificationsCreateCompanionBuilder,
          $MonitoredNotificationsUpdateCompanionBuilder,
          (
            MonitoredNotification,
            BaseReferences<
              _$SoulDatabase,
              MonitoredNotifications,
              MonitoredNotification
            >,
          ),
          MonitoredNotification,
          PrefetchHooks Function()
        > {
  $MonitoredNotificationsTableManager(
    _$SoulDatabase db,
    MonitoredNotifications table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $MonitoredNotificationsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $MonitoredNotificationsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $MonitoredNotificationsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> packageName = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<String?> content = const Value.absent(),
                Value<int> timestamp = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<int> isRelevant = const Value.absent(),
                Value<int> isSurfaced = const Value.absent(),
              }) => MonitoredNotificationsCompanion(
                id: id,
                packageName: packageName,
                title: title,
                content: content,
                timestamp: timestamp,
                category: category,
                isRelevant: isRelevant,
                isSurfaced: isSurfaced,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String packageName,
                Value<String?> title = const Value.absent(),
                Value<String?> content = const Value.absent(),
                required int timestamp,
                Value<String?> category = const Value.absent(),
                Value<int> isRelevant = const Value.absent(),
                Value<int> isSurfaced = const Value.absent(),
              }) => MonitoredNotificationsCompanion.insert(
                id: id,
                packageName: packageName,
                title: title,
                content: content,
                timestamp: timestamp,
                category: category,
                isRelevant: isRelevant,
                isSurfaced: isSurfaced,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $MonitoredNotificationsProcessedTableManager =
    ProcessedTableManager<
      _$SoulDatabase,
      MonitoredNotifications,
      MonitoredNotification,
      $MonitoredNotificationsFilterComposer,
      $MonitoredNotificationsOrderingComposer,
      $MonitoredNotificationsAnnotationComposer,
      $MonitoredNotificationsCreateCompanionBuilder,
      $MonitoredNotificationsUpdateCompanionBuilder,
      (
        MonitoredNotification,
        BaseReferences<
          _$SoulDatabase,
          MonitoredNotifications,
          MonitoredNotification
        >,
      ),
      MonitoredNotification,
      PrefetchHooks Function()
    >;
typedef $CachedCalendarEventsCreateCompanionBuilder =
    CachedCalendarEventsCompanion Function({
      required String eventId,
      required String calendarId,
      required String title,
      required int startTime,
      required int endTime,
      Value<String?> location,
      Value<String?> description,
      Value<String?> attendeeEmails,
      required int lastSynced,
      Value<int> rowid,
    });
typedef $CachedCalendarEventsUpdateCompanionBuilder =
    CachedCalendarEventsCompanion Function({
      Value<String> eventId,
      Value<String> calendarId,
      Value<String> title,
      Value<int> startTime,
      Value<int> endTime,
      Value<String?> location,
      Value<String?> description,
      Value<String?> attendeeEmails,
      Value<int> lastSynced,
      Value<int> rowid,
    });

class $CachedCalendarEventsFilterComposer
    extends Composer<_$SoulDatabase, CachedCalendarEvents> {
  $CachedCalendarEventsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get calendarId => $composableBuilder(
    column: $table.calendarId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attendeeEmails => $composableBuilder(
    column: $table.attendeeEmails,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSynced => $composableBuilder(
    column: $table.lastSynced,
    builder: (column) => ColumnFilters(column),
  );
}

class $CachedCalendarEventsOrderingComposer
    extends Composer<_$SoulDatabase, CachedCalendarEvents> {
  $CachedCalendarEventsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get calendarId => $composableBuilder(
    column: $table.calendarId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startTime => $composableBuilder(
    column: $table.startTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endTime => $composableBuilder(
    column: $table.endTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attendeeEmails => $composableBuilder(
    column: $table.attendeeEmails,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSynced => $composableBuilder(
    column: $table.lastSynced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $CachedCalendarEventsAnnotationComposer
    extends Composer<_$SoulDatabase, CachedCalendarEvents> {
  $CachedCalendarEventsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumn<String> get calendarId => $composableBuilder(
    column: $table.calendarId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get startTime =>
      $composableBuilder(column: $table.startTime, builder: (column) => column);

  GeneratedColumn<int> get endTime =>
      $composableBuilder(column: $table.endTime, builder: (column) => column);

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get attendeeEmails => $composableBuilder(
    column: $table.attendeeEmails,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastSynced => $composableBuilder(
    column: $table.lastSynced,
    builder: (column) => column,
  );
}

class $CachedCalendarEventsTableManager
    extends
        RootTableManager<
          _$SoulDatabase,
          CachedCalendarEvents,
          CachedCalendarEvent,
          $CachedCalendarEventsFilterComposer,
          $CachedCalendarEventsOrderingComposer,
          $CachedCalendarEventsAnnotationComposer,
          $CachedCalendarEventsCreateCompanionBuilder,
          $CachedCalendarEventsUpdateCompanionBuilder,
          (
            CachedCalendarEvent,
            BaseReferences<
              _$SoulDatabase,
              CachedCalendarEvents,
              CachedCalendarEvent
            >,
          ),
          CachedCalendarEvent,
          PrefetchHooks Function()
        > {
  $CachedCalendarEventsTableManager(
    _$SoulDatabase db,
    CachedCalendarEvents table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $CachedCalendarEventsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $CachedCalendarEventsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $CachedCalendarEventsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> eventId = const Value.absent(),
                Value<String> calendarId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> startTime = const Value.absent(),
                Value<int> endTime = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> attendeeEmails = const Value.absent(),
                Value<int> lastSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedCalendarEventsCompanion(
                eventId: eventId,
                calendarId: calendarId,
                title: title,
                startTime: startTime,
                endTime: endTime,
                location: location,
                description: description,
                attendeeEmails: attendeeEmails,
                lastSynced: lastSynced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String eventId,
                required String calendarId,
                required String title,
                required int startTime,
                required int endTime,
                Value<String?> location = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> attendeeEmails = const Value.absent(),
                required int lastSynced,
                Value<int> rowid = const Value.absent(),
              }) => CachedCalendarEventsCompanion.insert(
                eventId: eventId,
                calendarId: calendarId,
                title: title,
                startTime: startTime,
                endTime: endTime,
                location: location,
                description: description,
                attendeeEmails: attendeeEmails,
                lastSynced: lastSynced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $CachedCalendarEventsProcessedTableManager =
    ProcessedTableManager<
      _$SoulDatabase,
      CachedCalendarEvents,
      CachedCalendarEvent,
      $CachedCalendarEventsFilterComposer,
      $CachedCalendarEventsOrderingComposer,
      $CachedCalendarEventsAnnotationComposer,
      $CachedCalendarEventsCreateCompanionBuilder,
      $CachedCalendarEventsUpdateCompanionBuilder,
      (
        CachedCalendarEvent,
        BaseReferences<
          _$SoulDatabase,
          CachedCalendarEvents,
          CachedCalendarEvent
        >,
      ),
      CachedCalendarEvent,
      PrefetchHooks Function()
    >;
typedef $CachedContactsCreateCompanionBuilder =
    CachedContactsCompanion Function({
      required String id,
      required String displayName,
      Value<String?> phones,
      Value<String?> emails,
      required int lastSynced,
      Value<int> rowid,
    });
typedef $CachedContactsUpdateCompanionBuilder =
    CachedContactsCompanion Function({
      Value<String> id,
      Value<String> displayName,
      Value<String?> phones,
      Value<String?> emails,
      Value<int> lastSynced,
      Value<int> rowid,
    });

class $CachedContactsFilterComposer
    extends Composer<_$SoulDatabase, CachedContacts> {
  $CachedContactsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phones => $composableBuilder(
    column: $table.phones,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get emails => $composableBuilder(
    column: $table.emails,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastSynced => $composableBuilder(
    column: $table.lastSynced,
    builder: (column) => ColumnFilters(column),
  );
}

class $CachedContactsOrderingComposer
    extends Composer<_$SoulDatabase, CachedContacts> {
  $CachedContactsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phones => $composableBuilder(
    column: $table.phones,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get emails => $composableBuilder(
    column: $table.emails,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastSynced => $composableBuilder(
    column: $table.lastSynced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $CachedContactsAnnotationComposer
    extends Composer<_$SoulDatabase, CachedContacts> {
  $CachedContactsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get displayName => $composableBuilder(
    column: $table.displayName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phones =>
      $composableBuilder(column: $table.phones, builder: (column) => column);

  GeneratedColumn<String> get emails =>
      $composableBuilder(column: $table.emails, builder: (column) => column);

  GeneratedColumn<int> get lastSynced => $composableBuilder(
    column: $table.lastSynced,
    builder: (column) => column,
  );
}

class $CachedContactsTableManager
    extends
        RootTableManager<
          _$SoulDatabase,
          CachedContacts,
          CachedContact,
          $CachedContactsFilterComposer,
          $CachedContactsOrderingComposer,
          $CachedContactsAnnotationComposer,
          $CachedContactsCreateCompanionBuilder,
          $CachedContactsUpdateCompanionBuilder,
          (
            CachedContact,
            BaseReferences<_$SoulDatabase, CachedContacts, CachedContact>,
          ),
          CachedContact,
          PrefetchHooks Function()
        > {
  $CachedContactsTableManager(_$SoulDatabase db, CachedContacts table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $CachedContactsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $CachedContactsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $CachedContactsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> displayName = const Value.absent(),
                Value<String?> phones = const Value.absent(),
                Value<String?> emails = const Value.absent(),
                Value<int> lastSynced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CachedContactsCompanion(
                id: id,
                displayName: displayName,
                phones: phones,
                emails: emails,
                lastSynced: lastSynced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String displayName,
                Value<String?> phones = const Value.absent(),
                Value<String?> emails = const Value.absent(),
                required int lastSynced,
                Value<int> rowid = const Value.absent(),
              }) => CachedContactsCompanion.insert(
                id: id,
                displayName: displayName,
                phones: phones,
                emails: emails,
                lastSynced: lastSynced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $CachedContactsProcessedTableManager =
    ProcessedTableManager<
      _$SoulDatabase,
      CachedContacts,
      CachedContact,
      $CachedContactsFilterComposer,
      $CachedContactsOrderingComposer,
      $CachedContactsAnnotationComposer,
      $CachedContactsCreateCompanionBuilder,
      $CachedContactsUpdateCompanionBuilder,
      (
        CachedContact,
        BaseReferences<_$SoulDatabase, CachedContacts, CachedContact>,
      ),
      CachedContact,
      PrefetchHooks Function()
    >;
typedef $VesselToolsCreateCompanionBuilder =
    VesselToolsCompanion Function({
      Value<int> id,
      required String vesselId,
      required String toolName,
      Value<String?> description,
      required String capabilityGroup,
      required int cachedAt,
    });
typedef $VesselToolsUpdateCompanionBuilder =
    VesselToolsCompanion Function({
      Value<int> id,
      Value<String> vesselId,
      Value<String> toolName,
      Value<String?> description,
      Value<String> capabilityGroup,
      Value<int> cachedAt,
    });

class $VesselToolsFilterComposer extends Composer<_$SoulDatabase, VesselTools> {
  $VesselToolsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vesselId => $composableBuilder(
    column: $table.vesselId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toolName => $composableBuilder(
    column: $table.toolName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get capabilityGroup => $composableBuilder(
    column: $table.capabilityGroup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $VesselToolsOrderingComposer
    extends Composer<_$SoulDatabase, VesselTools> {
  $VesselToolsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vesselId => $composableBuilder(
    column: $table.vesselId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toolName => $composableBuilder(
    column: $table.toolName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get capabilityGroup => $composableBuilder(
    column: $table.capabilityGroup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $VesselToolsAnnotationComposer
    extends Composer<_$SoulDatabase, VesselTools> {
  $VesselToolsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get vesselId =>
      $composableBuilder(column: $table.vesselId, builder: (column) => column);

  GeneratedColumn<String> get toolName =>
      $composableBuilder(column: $table.toolName, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get capabilityGroup => $composableBuilder(
    column: $table.capabilityGroup,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $VesselToolsTableManager
    extends
        RootTableManager<
          _$SoulDatabase,
          VesselTools,
          VesselTool,
          $VesselToolsFilterComposer,
          $VesselToolsOrderingComposer,
          $VesselToolsAnnotationComposer,
          $VesselToolsCreateCompanionBuilder,
          $VesselToolsUpdateCompanionBuilder,
          (VesselTool, BaseReferences<_$SoulDatabase, VesselTools, VesselTool>),
          VesselTool,
          PrefetchHooks Function()
        > {
  $VesselToolsTableManager(_$SoulDatabase db, VesselTools table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $VesselToolsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $VesselToolsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $VesselToolsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> vesselId = const Value.absent(),
                Value<String> toolName = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> capabilityGroup = const Value.absent(),
                Value<int> cachedAt = const Value.absent(),
              }) => VesselToolsCompanion(
                id: id,
                vesselId: vesselId,
                toolName: toolName,
                description: description,
                capabilityGroup: capabilityGroup,
                cachedAt: cachedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String vesselId,
                required String toolName,
                Value<String?> description = const Value.absent(),
                required String capabilityGroup,
                required int cachedAt,
              }) => VesselToolsCompanion.insert(
                id: id,
                vesselId: vesselId,
                toolName: toolName,
                description: description,
                capabilityGroup: capabilityGroup,
                cachedAt: cachedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $VesselToolsProcessedTableManager =
    ProcessedTableManager<
      _$SoulDatabase,
      VesselTools,
      VesselTool,
      $VesselToolsFilterComposer,
      $VesselToolsOrderingComposer,
      $VesselToolsAnnotationComposer,
      $VesselToolsCreateCompanionBuilder,
      $VesselToolsUpdateCompanionBuilder,
      (VesselTool, BaseReferences<_$SoulDatabase, VesselTools, VesselTool>),
      VesselTool,
      PrefetchHooks Function()
    >;
typedef $VesselTasksCreateCompanionBuilder =
    VesselTasksCompanion Function({
      required String id,
      Value<String?> conversationId,
      required String vesselType,
      required String toolName,
      required String description,
      Value<String> status,
      Value<String?> resultJson,
      Value<String?> errorMessage,
      required int createdAt,
      Value<int?> completedAt,
      Value<int> rowid,
    });
typedef $VesselTasksUpdateCompanionBuilder =
    VesselTasksCompanion Function({
      Value<String> id,
      Value<String?> conversationId,
      Value<String> vesselType,
      Value<String> toolName,
      Value<String> description,
      Value<String> status,
      Value<String?> resultJson,
      Value<String?> errorMessage,
      Value<int> createdAt,
      Value<int?> completedAt,
      Value<int> rowid,
    });

class $VesselTasksFilterComposer extends Composer<_$SoulDatabase, VesselTasks> {
  $VesselTasksFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vesselType => $composableBuilder(
    column: $table.vesselType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get toolName => $composableBuilder(
    column: $table.toolName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get resultJson => $composableBuilder(
    column: $table.resultJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $VesselTasksOrderingComposer
    extends Composer<_$SoulDatabase, VesselTasks> {
  $VesselTasksOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vesselType => $composableBuilder(
    column: $table.vesselType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get toolName => $composableBuilder(
    column: $table.toolName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get resultJson => $composableBuilder(
    column: $table.resultJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $VesselTasksAnnotationComposer
    extends Composer<_$SoulDatabase, VesselTasks> {
  $VesselTasksAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get vesselType => $composableBuilder(
    column: $table.vesselType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get toolName =>
      $composableBuilder(column: $table.toolName, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get resultJson => $composableBuilder(
    column: $table.resultJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get errorMessage => $composableBuilder(
    column: $table.errorMessage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );
}

class $VesselTasksTableManager
    extends
        RootTableManager<
          _$SoulDatabase,
          VesselTasks,
          VesselTask,
          $VesselTasksFilterComposer,
          $VesselTasksOrderingComposer,
          $VesselTasksAnnotationComposer,
          $VesselTasksCreateCompanionBuilder,
          $VesselTasksUpdateCompanionBuilder,
          (VesselTask, BaseReferences<_$SoulDatabase, VesselTasks, VesselTask>),
          VesselTask,
          PrefetchHooks Function()
        > {
  $VesselTasksTableManager(_$SoulDatabase db, VesselTasks table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $VesselTasksFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $VesselTasksOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $VesselTasksAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> conversationId = const Value.absent(),
                Value<String> vesselType = const Value.absent(),
                Value<String> toolName = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> resultJson = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VesselTasksCompanion(
                id: id,
                conversationId: conversationId,
                vesselType: vesselType,
                toolName: toolName,
                description: description,
                status: status,
                resultJson: resultJson,
                errorMessage: errorMessage,
                createdAt: createdAt,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> conversationId = const Value.absent(),
                required String vesselType,
                required String toolName,
                required String description,
                Value<String> status = const Value.absent(),
                Value<String?> resultJson = const Value.absent(),
                Value<String?> errorMessage = const Value.absent(),
                required int createdAt,
                Value<int?> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VesselTasksCompanion.insert(
                id: id,
                conversationId: conversationId,
                vesselType: vesselType,
                toolName: toolName,
                description: description,
                status: status,
                resultJson: resultJson,
                errorMessage: errorMessage,
                createdAt: createdAt,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $VesselTasksProcessedTableManager =
    ProcessedTableManager<
      _$SoulDatabase,
      VesselTasks,
      VesselTask,
      $VesselTasksFilterComposer,
      $VesselTasksOrderingComposer,
      $VesselTasksAnnotationComposer,
      $VesselTasksCreateCompanionBuilder,
      $VesselTasksUpdateCompanionBuilder,
      (VesselTask, BaseReferences<_$SoulDatabase, VesselTasks, VesselTask>),
      VesselTask,
      PrefetchHooks Function()
    >;
typedef $VesselConfigsCreateCompanionBuilder =
    VesselConfigsCompanion Function({
      required String id,
      required String vesselType,
      required String host,
      required int port,
      required String tokenRef,
      Value<int> isActive,
      required int createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $VesselConfigsUpdateCompanionBuilder =
    VesselConfigsCompanion Function({
      Value<String> id,
      Value<String> vesselType,
      Value<String> host,
      Value<int> port,
      Value<String> tokenRef,
      Value<int> isActive,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $VesselConfigsFilterComposer
    extends Composer<_$SoulDatabase, VesselConfigs> {
  $VesselConfigsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vesselType => $composableBuilder(
    column: $table.vesselType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get host => $composableBuilder(
    column: $table.host,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get port => $composableBuilder(
    column: $table.port,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tokenRef => $composableBuilder(
    column: $table.tokenRef,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $VesselConfigsOrderingComposer
    extends Composer<_$SoulDatabase, VesselConfigs> {
  $VesselConfigsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vesselType => $composableBuilder(
    column: $table.vesselType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get host => $composableBuilder(
    column: $table.host,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get port => $composableBuilder(
    column: $table.port,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tokenRef => $composableBuilder(
    column: $table.tokenRef,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $VesselConfigsAnnotationComposer
    extends Composer<_$SoulDatabase, VesselConfigs> {
  $VesselConfigsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get vesselType => $composableBuilder(
    column: $table.vesselType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get host =>
      $composableBuilder(column: $table.host, builder: (column) => column);

  GeneratedColumn<int> get port =>
      $composableBuilder(column: $table.port, builder: (column) => column);

  GeneratedColumn<String> get tokenRef =>
      $composableBuilder(column: $table.tokenRef, builder: (column) => column);

  GeneratedColumn<int> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $VesselConfigsTableManager
    extends
        RootTableManager<
          _$SoulDatabase,
          VesselConfigs,
          VesselConfig,
          $VesselConfigsFilterComposer,
          $VesselConfigsOrderingComposer,
          $VesselConfigsAnnotationComposer,
          $VesselConfigsCreateCompanionBuilder,
          $VesselConfigsUpdateCompanionBuilder,
          (
            VesselConfig,
            BaseReferences<_$SoulDatabase, VesselConfigs, VesselConfig>,
          ),
          VesselConfig,
          PrefetchHooks Function()
        > {
  $VesselConfigsTableManager(_$SoulDatabase db, VesselConfigs table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $VesselConfigsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $VesselConfigsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $VesselConfigsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> vesselType = const Value.absent(),
                Value<String> host = const Value.absent(),
                Value<int> port = const Value.absent(),
                Value<String> tokenRef = const Value.absent(),
                Value<int> isActive = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VesselConfigsCompanion(
                id: id,
                vesselType: vesselType,
                host: host,
                port: port,
                tokenRef: tokenRef,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String vesselType,
                required String host,
                required int port,
                required String tokenRef,
                Value<int> isActive = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => VesselConfigsCompanion.insert(
                id: id,
                vesselType: vesselType,
                host: host,
                port: port,
                tokenRef: tokenRef,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $VesselConfigsProcessedTableManager =
    ProcessedTableManager<
      _$SoulDatabase,
      VesselConfigs,
      VesselConfig,
      $VesselConfigsFilterComposer,
      $VesselConfigsOrderingComposer,
      $VesselConfigsAnnotationComposer,
      $VesselConfigsCreateCompanionBuilder,
      $VesselConfigsUpdateCompanionBuilder,
      (
        VesselConfig,
        BaseReferences<_$SoulDatabase, VesselConfigs, VesselConfig>,
      ),
      VesselConfig,
      PrefetchHooks Function()
    >;
typedef $ProfileTraitsCreateCompanionBuilder =
    ProfileTraitsCompanion Function({
      required String id,
      required String category,
      required String traitKey,
      required String traitValue,
      Value<double> confidence,
      Value<int> evidenceCount,
      required int firstObserved,
      required int lastObserved,
      Value<int> rowid,
    });
typedef $ProfileTraitsUpdateCompanionBuilder =
    ProfileTraitsCompanion Function({
      Value<String> id,
      Value<String> category,
      Value<String> traitKey,
      Value<String> traitValue,
      Value<double> confidence,
      Value<int> evidenceCount,
      Value<int> firstObserved,
      Value<int> lastObserved,
      Value<int> rowid,
    });

class $ProfileTraitsFilterComposer
    extends Composer<_$SoulDatabase, ProfileTraits> {
  $ProfileTraitsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get traitKey => $composableBuilder(
    column: $table.traitKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get traitValue => $composableBuilder(
    column: $table.traitValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get evidenceCount => $composableBuilder(
    column: $table.evidenceCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get firstObserved => $composableBuilder(
    column: $table.firstObserved,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastObserved => $composableBuilder(
    column: $table.lastObserved,
    builder: (column) => ColumnFilters(column),
  );
}

class $ProfileTraitsOrderingComposer
    extends Composer<_$SoulDatabase, ProfileTraits> {
  $ProfileTraitsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get traitKey => $composableBuilder(
    column: $table.traitKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get traitValue => $composableBuilder(
    column: $table.traitValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get evidenceCount => $composableBuilder(
    column: $table.evidenceCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get firstObserved => $composableBuilder(
    column: $table.firstObserved,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastObserved => $composableBuilder(
    column: $table.lastObserved,
    builder: (column) => ColumnOrderings(column),
  );
}

class $ProfileTraitsAnnotationComposer
    extends Composer<_$SoulDatabase, ProfileTraits> {
  $ProfileTraitsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get traitKey =>
      $composableBuilder(column: $table.traitKey, builder: (column) => column);

  GeneratedColumn<String> get traitValue => $composableBuilder(
    column: $table.traitValue,
    builder: (column) => column,
  );

  GeneratedColumn<double> get confidence => $composableBuilder(
    column: $table.confidence,
    builder: (column) => column,
  );

  GeneratedColumn<int> get evidenceCount => $composableBuilder(
    column: $table.evidenceCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get firstObserved => $composableBuilder(
    column: $table.firstObserved,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastObserved => $composableBuilder(
    column: $table.lastObserved,
    builder: (column) => column,
  );
}

class $ProfileTraitsTableManager
    extends
        RootTableManager<
          _$SoulDatabase,
          ProfileTraits,
          ProfileTrait,
          $ProfileTraitsFilterComposer,
          $ProfileTraitsOrderingComposer,
          $ProfileTraitsAnnotationComposer,
          $ProfileTraitsCreateCompanionBuilder,
          $ProfileTraitsUpdateCompanionBuilder,
          (
            ProfileTrait,
            BaseReferences<_$SoulDatabase, ProfileTraits, ProfileTrait>,
          ),
          ProfileTrait,
          PrefetchHooks Function()
        > {
  $ProfileTraitsTableManager(_$SoulDatabase db, ProfileTraits table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ProfileTraitsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ProfileTraitsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ProfileTraitsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> traitKey = const Value.absent(),
                Value<String> traitValue = const Value.absent(),
                Value<double> confidence = const Value.absent(),
                Value<int> evidenceCount = const Value.absent(),
                Value<int> firstObserved = const Value.absent(),
                Value<int> lastObserved = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfileTraitsCompanion(
                id: id,
                category: category,
                traitKey: traitKey,
                traitValue: traitValue,
                confidence: confidence,
                evidenceCount: evidenceCount,
                firstObserved: firstObserved,
                lastObserved: lastObserved,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String category,
                required String traitKey,
                required String traitValue,
                Value<double> confidence = const Value.absent(),
                Value<int> evidenceCount = const Value.absent(),
                required int firstObserved,
                required int lastObserved,
                Value<int> rowid = const Value.absent(),
              }) => ProfileTraitsCompanion.insert(
                id: id,
                category: category,
                traitKey: traitKey,
                traitValue: traitValue,
                confidence: confidence,
                evidenceCount: evidenceCount,
                firstObserved: firstObserved,
                lastObserved: lastObserved,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $ProfileTraitsProcessedTableManager =
    ProcessedTableManager<
      _$SoulDatabase,
      ProfileTraits,
      ProfileTrait,
      $ProfileTraitsFilterComposer,
      $ProfileTraitsOrderingComposer,
      $ProfileTraitsAnnotationComposer,
      $ProfileTraitsCreateCompanionBuilder,
      $ProfileTraitsUpdateCompanionBuilder,
      (
        ProfileTrait,
        BaseReferences<_$SoulDatabase, ProfileTraits, ProfileTrait>,
      ),
      ProfileTrait,
      PrefetchHooks Function()
    >;
typedef $ProjectsCreateCompanionBuilder =
    ProjectsCompanion Function({
      required String id,
      required String name,
      Value<String?> description,
      Value<String?> techStack,
      Value<String?> goals,
      Value<int?> deadline,
      Value<String?> repoUrl,
      Value<String> status,
      required int onboardedAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $ProjectsUpdateCompanionBuilder =
    ProjectsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> description,
      Value<String?> techStack,
      Value<String?> goals,
      Value<int?> deadline,
      Value<String?> repoUrl,
      Value<String> status,
      Value<int> onboardedAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

final class $ProjectsReferences
    extends BaseReferences<_$SoulDatabase, Projects, Project> {
  $ProjectsReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<ProjectFacts, List<ProjectFact>>
  _projectFactsRefsTable(_$SoulDatabase db) => MultiTypedResultKey.fromTable(
    db.projectFacts,
    aliasName: $_aliasNameGenerator(db.projects.id, db.projectFacts.projectId),
  );

  $ProjectFactsProcessedTableManager get projectFactsRefs {
    final manager = $ProjectFactsTableManager(
      $_db,
      $_db.projectFacts,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_projectFactsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $ProjectsFilterComposer extends Composer<_$SoulDatabase, Projects> {
  $ProjectsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get techStack => $composableBuilder(
    column: $table.techStack,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get goals => $composableBuilder(
    column: $table.goals,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deadline => $composableBuilder(
    column: $table.deadline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repoUrl => $composableBuilder(
    column: $table.repoUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get onboardedAt => $composableBuilder(
    column: $table.onboardedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> projectFactsRefs(
    Expression<bool> Function($ProjectFactsFilterComposer f) f,
  ) {
    final $ProjectFactsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.projectFacts,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ProjectFactsFilterComposer(
            $db: $db,
            $table: $db.projectFacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $ProjectsOrderingComposer extends Composer<_$SoulDatabase, Projects> {
  $ProjectsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get techStack => $composableBuilder(
    column: $table.techStack,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get goals => $composableBuilder(
    column: $table.goals,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deadline => $composableBuilder(
    column: $table.deadline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repoUrl => $composableBuilder(
    column: $table.repoUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get onboardedAt => $composableBuilder(
    column: $table.onboardedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $ProjectsAnnotationComposer extends Composer<_$SoulDatabase, Projects> {
  $ProjectsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get techStack =>
      $composableBuilder(column: $table.techStack, builder: (column) => column);

  GeneratedColumn<String> get goals =>
      $composableBuilder(column: $table.goals, builder: (column) => column);

  GeneratedColumn<int> get deadline =>
      $composableBuilder(column: $table.deadline, builder: (column) => column);

  GeneratedColumn<String> get repoUrl =>
      $composableBuilder(column: $table.repoUrl, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get onboardedAt => $composableBuilder(
    column: $table.onboardedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> projectFactsRefs<T extends Object>(
    Expression<T> Function($ProjectFactsAnnotationComposer a) f,
  ) {
    final $ProjectFactsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.projectFacts,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ProjectFactsAnnotationComposer(
            $db: $db,
            $table: $db.projectFacts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $ProjectsTableManager
    extends
        RootTableManager<
          _$SoulDatabase,
          Projects,
          Project,
          $ProjectsFilterComposer,
          $ProjectsOrderingComposer,
          $ProjectsAnnotationComposer,
          $ProjectsCreateCompanionBuilder,
          $ProjectsUpdateCompanionBuilder,
          (Project, $ProjectsReferences),
          Project,
          PrefetchHooks Function({bool projectFactsRefs})
        > {
  $ProjectsTableManager(_$SoulDatabase db, Projects table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ProjectsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ProjectsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ProjectsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> techStack = const Value.absent(),
                Value<String?> goals = const Value.absent(),
                Value<int?> deadline = const Value.absent(),
                Value<String?> repoUrl = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> onboardedAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectsCompanion(
                id: id,
                name: name,
                description: description,
                techStack: techStack,
                goals: goals,
                deadline: deadline,
                repoUrl: repoUrl,
                status: status,
                onboardedAt: onboardedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> description = const Value.absent(),
                Value<String?> techStack = const Value.absent(),
                Value<String?> goals = const Value.absent(),
                Value<int?> deadline = const Value.absent(),
                Value<String?> repoUrl = const Value.absent(),
                Value<String> status = const Value.absent(),
                required int onboardedAt,
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => ProjectsCompanion.insert(
                id: id,
                name: name,
                description: description,
                techStack: techStack,
                goals: goals,
                deadline: deadline,
                repoUrl: repoUrl,
                status: status,
                onboardedAt: onboardedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (e.readTable(table), $ProjectsReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({projectFactsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (projectFactsRefs) db.projectFacts],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (projectFactsRefs)
                    await $_getPrefetchedData<Project, Projects, ProjectFact>(
                      currentTable: table,
                      referencedTable: $ProjectsReferences
                          ._projectFactsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $ProjectsReferences(db, table, p0).projectFactsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.projectId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $ProjectsProcessedTableManager =
    ProcessedTableManager<
      _$SoulDatabase,
      Projects,
      Project,
      $ProjectsFilterComposer,
      $ProjectsOrderingComposer,
      $ProjectsAnnotationComposer,
      $ProjectsCreateCompanionBuilder,
      $ProjectsUpdateCompanionBuilder,
      (Project, $ProjectsReferences),
      Project,
      PrefetchHooks Function({bool projectFactsRefs})
    >;
typedef $ProjectFactsCreateCompanionBuilder =
    ProjectFactsCompanion Function({
      required String id,
      required String projectId,
      required String factKey,
      required String factValue,
      Value<String?> sourceMessageId,
      required int createdAt,
      Value<int> rowid,
    });
typedef $ProjectFactsUpdateCompanionBuilder =
    ProjectFactsCompanion Function({
      Value<String> id,
      Value<String> projectId,
      Value<String> factKey,
      Value<String> factValue,
      Value<String?> sourceMessageId,
      Value<int> createdAt,
      Value<int> rowid,
    });

final class $ProjectFactsReferences
    extends BaseReferences<_$SoulDatabase, ProjectFacts, ProjectFact> {
  $ProjectFactsReferences(super.$_db, super.$_table, super.$_typedResult);

  static Projects _projectIdTable(_$SoulDatabase db) => db.projects.createAlias(
    $_aliasNameGenerator(db.projectFacts.projectId, db.projects.id),
  );

  $ProjectsProcessedTableManager get projectId {
    final $_column = $_itemColumn<String>('project_id')!;

    final manager = $ProjectsTableManager(
      $_db,
      $_db.projects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $ProjectFactsFilterComposer
    extends Composer<_$SoulDatabase, ProjectFacts> {
  $ProjectFactsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get factKey => $composableBuilder(
    column: $table.factKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get factValue => $composableBuilder(
    column: $table.factValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceMessageId => $composableBuilder(
    column: $table.sourceMessageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $ProjectsFilterComposer get projectId {
    final $ProjectsFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ProjectsFilterComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $ProjectFactsOrderingComposer
    extends Composer<_$SoulDatabase, ProjectFacts> {
  $ProjectFactsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get factKey => $composableBuilder(
    column: $table.factKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get factValue => $composableBuilder(
    column: $table.factValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceMessageId => $composableBuilder(
    column: $table.sourceMessageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $ProjectsOrderingComposer get projectId {
    final $ProjectsOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ProjectsOrderingComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $ProjectFactsAnnotationComposer
    extends Composer<_$SoulDatabase, ProjectFacts> {
  $ProjectFactsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get factKey =>
      $composableBuilder(column: $table.factKey, builder: (column) => column);

  GeneratedColumn<String> get factValue =>
      $composableBuilder(column: $table.factValue, builder: (column) => column);

  GeneratedColumn<String> get sourceMessageId => $composableBuilder(
    column: $table.sourceMessageId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $ProjectsAnnotationComposer get projectId {
    final $ProjectsAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $ProjectsAnnotationComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $ProjectFactsTableManager
    extends
        RootTableManager<
          _$SoulDatabase,
          ProjectFacts,
          ProjectFact,
          $ProjectFactsFilterComposer,
          $ProjectFactsOrderingComposer,
          $ProjectFactsAnnotationComposer,
          $ProjectFactsCreateCompanionBuilder,
          $ProjectFactsUpdateCompanionBuilder,
          (ProjectFact, $ProjectFactsReferences),
          ProjectFact,
          PrefetchHooks Function({bool projectId})
        > {
  $ProjectFactsTableManager(_$SoulDatabase db, ProjectFacts table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ProjectFactsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ProjectFactsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ProjectFactsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> projectId = const Value.absent(),
                Value<String> factKey = const Value.absent(),
                Value<String> factValue = const Value.absent(),
                Value<String?> sourceMessageId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProjectFactsCompanion(
                id: id,
                projectId: projectId,
                factKey: factKey,
                factValue: factValue,
                sourceMessageId: sourceMessageId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String projectId,
                required String factKey,
                required String factValue,
                Value<String?> sourceMessageId = const Value.absent(),
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ProjectFactsCompanion.insert(
                id: id,
                projectId: projectId,
                factKey: factKey,
                factValue: factValue,
                sourceMessageId: sourceMessageId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $ProjectFactsReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({projectId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (projectId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.projectId,
                                referencedTable: $ProjectFactsReferences
                                    ._projectIdTable(db),
                                referencedColumn: $ProjectFactsReferences
                                    ._projectIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $ProjectFactsProcessedTableManager =
    ProcessedTableManager<
      _$SoulDatabase,
      ProjectFacts,
      ProjectFact,
      $ProjectFactsFilterComposer,
      $ProjectFactsOrderingComposer,
      $ProjectFactsAnnotationComposer,
      $ProjectFactsCreateCompanionBuilder,
      $ProjectFactsUpdateCompanionBuilder,
      (ProjectFact, $ProjectFactsReferences),
      ProjectFact,
      PrefetchHooks Function({bool projectId})
    >;
typedef $DecisionsCreateCompanionBuilder =
    DecisionsCompanion Function({
      required String id,
      required String conversationId,
      required String messageId,
      required String title,
      required String reasoning,
      required String domain,
      Value<String?> alternativesConsidered,
      required int createdAt,
      Value<String?> supersededBy,
      Value<int> isActive,
      Value<String> status,
      Value<int> rowid,
    });
typedef $DecisionsUpdateCompanionBuilder =
    DecisionsCompanion Function({
      Value<String> id,
      Value<String> conversationId,
      Value<String> messageId,
      Value<String> title,
      Value<String> reasoning,
      Value<String> domain,
      Value<String?> alternativesConsidered,
      Value<int> createdAt,
      Value<String?> supersededBy,
      Value<int> isActive,
      Value<String> status,
      Value<int> rowid,
    });

class $DecisionsFilterComposer extends Composer<_$SoulDatabase, Decisions> {
  $DecisionsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reasoning => $composableBuilder(
    column: $table.reasoning,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get alternativesConsidered => $composableBuilder(
    column: $table.alternativesConsidered,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supersededBy => $composableBuilder(
    column: $table.supersededBy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );
}

class $DecisionsOrderingComposer extends Composer<_$SoulDatabase, Decisions> {
  $DecisionsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get messageId => $composableBuilder(
    column: $table.messageId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reasoning => $composableBuilder(
    column: $table.reasoning,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get domain => $composableBuilder(
    column: $table.domain,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get alternativesConsidered => $composableBuilder(
    column: $table.alternativesConsidered,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supersededBy => $composableBuilder(
    column: $table.supersededBy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );
}

class $DecisionsAnnotationComposer extends Composer<_$SoulDatabase, Decisions> {
  $DecisionsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get messageId =>
      $composableBuilder(column: $table.messageId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get reasoning =>
      $composableBuilder(column: $table.reasoning, builder: (column) => column);

  GeneratedColumn<String> get domain =>
      $composableBuilder(column: $table.domain, builder: (column) => column);

  GeneratedColumn<String> get alternativesConsidered => $composableBuilder(
    column: $table.alternativesConsidered,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get supersededBy => $composableBuilder(
    column: $table.supersededBy,
    builder: (column) => column,
  );

  GeneratedColumn<int> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);
}

class $DecisionsTableManager
    extends
        RootTableManager<
          _$SoulDatabase,
          Decisions,
          Decision,
          $DecisionsFilterComposer,
          $DecisionsOrderingComposer,
          $DecisionsAnnotationComposer,
          $DecisionsCreateCompanionBuilder,
          $DecisionsUpdateCompanionBuilder,
          (Decision, BaseReferences<_$SoulDatabase, Decisions, Decision>),
          Decision,
          PrefetchHooks Function()
        > {
  $DecisionsTableManager(_$SoulDatabase db, Decisions table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $DecisionsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $DecisionsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $DecisionsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> conversationId = const Value.absent(),
                Value<String> messageId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> reasoning = const Value.absent(),
                Value<String> domain = const Value.absent(),
                Value<String?> alternativesConsidered = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<String?> supersededBy = const Value.absent(),
                Value<int> isActive = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DecisionsCompanion(
                id: id,
                conversationId: conversationId,
                messageId: messageId,
                title: title,
                reasoning: reasoning,
                domain: domain,
                alternativesConsidered: alternativesConsidered,
                createdAt: createdAt,
                supersededBy: supersededBy,
                isActive: isActive,
                status: status,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String conversationId,
                required String messageId,
                required String title,
                required String reasoning,
                required String domain,
                Value<String?> alternativesConsidered = const Value.absent(),
                required int createdAt,
                Value<String?> supersededBy = const Value.absent(),
                Value<int> isActive = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DecisionsCompanion.insert(
                id: id,
                conversationId: conversationId,
                messageId: messageId,
                title: title,
                reasoning: reasoning,
                domain: domain,
                alternativesConsidered: alternativesConsidered,
                createdAt: createdAt,
                supersededBy: supersededBy,
                isActive: isActive,
                status: status,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $DecisionsProcessedTableManager =
    ProcessedTableManager<
      _$SoulDatabase,
      Decisions,
      Decision,
      $DecisionsFilterComposer,
      $DecisionsOrderingComposer,
      $DecisionsAnnotationComposer,
      $DecisionsCreateCompanionBuilder,
      $DecisionsUpdateCompanionBuilder,
      (Decision, BaseReferences<_$SoulDatabase, Decisions, Decision>),
      Decision,
      PrefetchHooks Function()
    >;
typedef $MessagesCreateCompanionBuilder =
    MessagesCompanion Function({
      required String id,
      required String conversationId,
      required String role,
      required String content,
      required int createdAt,
      Value<int?> tokenCount,
      Value<int> rowid,
    });
typedef $MessagesUpdateCompanionBuilder =
    MessagesCompanion Function({
      Value<String> id,
      Value<String> conversationId,
      Value<String> role,
      Value<String> content,
      Value<int> createdAt,
      Value<int?> tokenCount,
      Value<int> rowid,
    });

class $MessagesFilterComposer extends Composer<_$SoulDatabase, Messages> {
  $MessagesFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tokenCount => $composableBuilder(
    column: $table.tokenCount,
    builder: (column) => ColumnFilters(column),
  );
}

class $MessagesOrderingComposer extends Composer<_$SoulDatabase, Messages> {
  $MessagesOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tokenCount => $composableBuilder(
    column: $table.tokenCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $MessagesAnnotationComposer extends Composer<_$SoulDatabase, Messages> {
  $MessagesAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get conversationId => $composableBuilder(
    column: $table.conversationId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get tokenCount => $composableBuilder(
    column: $table.tokenCount,
    builder: (column) => column,
  );
}

class $MessagesTableManager
    extends
        RootTableManager<
          _$SoulDatabase,
          Messages,
          Message,
          $MessagesFilterComposer,
          $MessagesOrderingComposer,
          $MessagesAnnotationComposer,
          $MessagesCreateCompanionBuilder,
          $MessagesUpdateCompanionBuilder,
          (Message, BaseReferences<_$SoulDatabase, Messages, Message>),
          Message,
          PrefetchHooks Function()
        > {
  $MessagesTableManager(_$SoulDatabase db, Messages table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $MessagesFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $MessagesOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $MessagesAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> conversationId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int?> tokenCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessagesCompanion(
                id: id,
                conversationId: conversationId,
                role: role,
                content: content,
                createdAt: createdAt,
                tokenCount: tokenCount,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String conversationId,
                required String role,
                required String content,
                required int createdAt,
                Value<int?> tokenCount = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MessagesCompanion.insert(
                id: id,
                conversationId: conversationId,
                role: role,
                content: content,
                createdAt: createdAt,
                tokenCount: tokenCount,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $MessagesProcessedTableManager =
    ProcessedTableManager<
      _$SoulDatabase,
      Messages,
      Message,
      $MessagesFilterComposer,
      $MessagesOrderingComposer,
      $MessagesAnnotationComposer,
      $MessagesCreateCompanionBuilder,
      $MessagesUpdateCompanionBuilder,
      (Message, BaseReferences<_$SoulDatabase, Messages, Message>),
      Message,
      PrefetchHooks Function()
    >;
typedef $ConversationsCreateCompanionBuilder =
    ConversationsCompanion Function({
      required String id,
      Value<String> title,
      required int createdAt,
      required int updatedAt,
      Value<String?> lastMessagePreview,
      Value<String?> projectId,
      Value<int> rowid,
    });
typedef $ConversationsUpdateCompanionBuilder =
    ConversationsCompanion Function({
      Value<String> id,
      Value<String> title,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<String?> lastMessagePreview,
      Value<String?> projectId,
      Value<int> rowid,
    });

class $ConversationsFilterComposer
    extends Composer<_$SoulDatabase, Conversations> {
  $ConversationsFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastMessagePreview => $composableBuilder(
    column: $table.lastMessagePreview,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );
}

class $ConversationsOrderingComposer
    extends Composer<_$SoulDatabase, Conversations> {
  $ConversationsOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastMessagePreview => $composableBuilder(
    column: $table.lastMessagePreview,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $ConversationsAnnotationComposer
    extends Composer<_$SoulDatabase, Conversations> {
  $ConversationsAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<String> get lastMessagePreview => $composableBuilder(
    column: $table.lastMessagePreview,
    builder: (column) => column,
  );

  GeneratedColumn<String> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);
}

class $ConversationsTableManager
    extends
        RootTableManager<
          _$SoulDatabase,
          Conversations,
          Conversation,
          $ConversationsFilterComposer,
          $ConversationsOrderingComposer,
          $ConversationsAnnotationComposer,
          $ConversationsCreateCompanionBuilder,
          $ConversationsUpdateCompanionBuilder,
          (
            Conversation,
            BaseReferences<_$SoulDatabase, Conversations, Conversation>,
          ),
          Conversation,
          PrefetchHooks Function()
        > {
  $ConversationsTableManager(_$SoulDatabase db, Conversations table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $ConversationsFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $ConversationsOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $ConversationsAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<String?> lastMessagePreview = const Value.absent(),
                Value<String?> projectId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConversationsCompanion(
                id: id,
                title: title,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastMessagePreview: lastMessagePreview,
                projectId: projectId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String> title = const Value.absent(),
                required int createdAt,
                required int updatedAt,
                Value<String?> lastMessagePreview = const Value.absent(),
                Value<String?> projectId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConversationsCompanion.insert(
                id: id,
                title: title,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastMessagePreview: lastMessagePreview,
                projectId: projectId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $ConversationsProcessedTableManager =
    ProcessedTableManager<
      _$SoulDatabase,
      Conversations,
      Conversation,
      $ConversationsFilterComposer,
      $ConversationsOrderingComposer,
      $ConversationsAnnotationComposer,
      $ConversationsCreateCompanionBuilder,
      $ConversationsUpdateCompanionBuilder,
      (
        Conversation,
        BaseReferences<_$SoulDatabase, Conversations, Conversation>,
      ),
      Conversation,
      PrefetchHooks Function()
    >;

class $SoulDatabaseManager {
  final _$SoulDatabase _db;
  $SoulDatabaseManager(this._db);
  $WeeklyReviewsTableManager get weeklyReviews =>
      $WeeklyReviewsTableManager(_db, _db.weeklyReviews);
  $AchievementsTableManager get achievements =>
      $AchievementsTableManager(_db, _db.achievements);
  $StreaksTableManager get streaks => $StreaksTableManager(_db, _db.streaks);
  $DailyMetricsTableManager get dailyMetrics =>
      $DailyMetricsTableManager(_db, _db.dailyMetrics);
  $AgenticWalTableManager get agenticWal =>
      $AgenticWalTableManager(_db, _db.agenticWal);
  $ProjectStateTableManager get projectState =>
      $ProjectStateTableManager(_db, _db.projectState);
  $DistilledFactsTableManager get distilledFacts =>
      $DistilledFactsTableManager(_db, _db.distilledFacts);
  $MoodStatesTableManager get moodStates =>
      $MoodStatesTableManager(_db, _db.moodStates);
  $AuditLogTableManager get auditLog =>
      $AuditLogTableManager(_db, _db.auditLog);
  $InterventionStatesTableManager get interventionStates =>
      $InterventionStatesTableManager(_db, _db.interventionStates);
  $ApiUsageTableManager get apiUsage =>
      $ApiUsageTableManager(_db, _db.apiUsage);
  $SettingsTableManager get settings =>
      $SettingsTableManager(_db, _db.settings);
  $StucknessSignalsTableManager get stucknessSignals =>
      $StucknessSignalsTableManager(_db, _db.stucknessSignals);
  $BriefingsTableManager get briefings =>
      $BriefingsTableManager(_db, _db.briefings);
  $MonitoredNotificationsTableManager get monitoredNotifications =>
      $MonitoredNotificationsTableManager(_db, _db.monitoredNotifications);
  $CachedCalendarEventsTableManager get cachedCalendarEvents =>
      $CachedCalendarEventsTableManager(_db, _db.cachedCalendarEvents);
  $CachedContactsTableManager get cachedContacts =>
      $CachedContactsTableManager(_db, _db.cachedContacts);
  $VesselToolsTableManager get vesselTools =>
      $VesselToolsTableManager(_db, _db.vesselTools);
  $VesselTasksTableManager get vesselTasks =>
      $VesselTasksTableManager(_db, _db.vesselTasks);
  $VesselConfigsTableManager get vesselConfigs =>
      $VesselConfigsTableManager(_db, _db.vesselConfigs);
  $ProfileTraitsTableManager get profileTraits =>
      $ProfileTraitsTableManager(_db, _db.profileTraits);
  $ProjectsTableManager get projects =>
      $ProjectsTableManager(_db, _db.projects);
  $ProjectFactsTableManager get projectFacts =>
      $ProjectFactsTableManager(_db, _db.projectFacts);
  $DecisionsTableManager get decisions =>
      $DecisionsTableManager(_db, _db.decisions);
  $MessagesTableManager get messages =>
      $MessagesTableManager(_db, _db.messages);
  $ConversationsTableManager get conversations =>
      $ConversationsTableManager(_db, _db.conversations);
}
