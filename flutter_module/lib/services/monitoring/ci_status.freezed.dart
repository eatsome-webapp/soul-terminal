// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'ci_status.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$CiStatus {

 String get projectId; CiHealth get health; String? get lastWorkflowName; String? get lastCommitSha; DateTime? get lastRunAt; int get openPrCount; int get stalePrCount; int get recentCommitCount; DateTime? get checkedAt;
/// Create a copy of CiStatus
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CiStatusCopyWith<CiStatus> get copyWith => _$CiStatusCopyWithImpl<CiStatus>(this as CiStatus, _$identity);

  /// Serializes this CiStatus to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CiStatus&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.health, health) || other.health == health)&&(identical(other.lastWorkflowName, lastWorkflowName) || other.lastWorkflowName == lastWorkflowName)&&(identical(other.lastCommitSha, lastCommitSha) || other.lastCommitSha == lastCommitSha)&&(identical(other.lastRunAt, lastRunAt) || other.lastRunAt == lastRunAt)&&(identical(other.openPrCount, openPrCount) || other.openPrCount == openPrCount)&&(identical(other.stalePrCount, stalePrCount) || other.stalePrCount == stalePrCount)&&(identical(other.recentCommitCount, recentCommitCount) || other.recentCommitCount == recentCommitCount)&&(identical(other.checkedAt, checkedAt) || other.checkedAt == checkedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,projectId,health,lastWorkflowName,lastCommitSha,lastRunAt,openPrCount,stalePrCount,recentCommitCount,checkedAt);

@override
String toString() {
  return 'CiStatus(projectId: $projectId, health: $health, lastWorkflowName: $lastWorkflowName, lastCommitSha: $lastCommitSha, lastRunAt: $lastRunAt, openPrCount: $openPrCount, stalePrCount: $stalePrCount, recentCommitCount: $recentCommitCount, checkedAt: $checkedAt)';
}


}

/// @nodoc
abstract mixin class $CiStatusCopyWith<$Res>  {
  factory $CiStatusCopyWith(CiStatus value, $Res Function(CiStatus) _then) = _$CiStatusCopyWithImpl;
@useResult
$Res call({
 String projectId, CiHealth health, String? lastWorkflowName, String? lastCommitSha, DateTime? lastRunAt, int openPrCount, int stalePrCount, int recentCommitCount, DateTime? checkedAt
});




}
/// @nodoc
class _$CiStatusCopyWithImpl<$Res>
    implements $CiStatusCopyWith<$Res> {
  _$CiStatusCopyWithImpl(this._self, this._then);

  final CiStatus _self;
  final $Res Function(CiStatus) _then;

/// Create a copy of CiStatus
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? projectId = null,Object? health = null,Object? lastWorkflowName = freezed,Object? lastCommitSha = freezed,Object? lastRunAt = freezed,Object? openPrCount = null,Object? stalePrCount = null,Object? recentCommitCount = null,Object? checkedAt = freezed,}) {
  return _then(_self.copyWith(
projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,health: null == health ? _self.health : health // ignore: cast_nullable_to_non_nullable
as CiHealth,lastWorkflowName: freezed == lastWorkflowName ? _self.lastWorkflowName : lastWorkflowName // ignore: cast_nullable_to_non_nullable
as String?,lastCommitSha: freezed == lastCommitSha ? _self.lastCommitSha : lastCommitSha // ignore: cast_nullable_to_non_nullable
as String?,lastRunAt: freezed == lastRunAt ? _self.lastRunAt : lastRunAt // ignore: cast_nullable_to_non_nullable
as DateTime?,openPrCount: null == openPrCount ? _self.openPrCount : openPrCount // ignore: cast_nullable_to_non_nullable
as int,stalePrCount: null == stalePrCount ? _self.stalePrCount : stalePrCount // ignore: cast_nullable_to_non_nullable
as int,recentCommitCount: null == recentCommitCount ? _self.recentCommitCount : recentCommitCount // ignore: cast_nullable_to_non_nullable
as int,checkedAt: freezed == checkedAt ? _self.checkedAt : checkedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [CiStatus].
extension CiStatusPatterns on CiStatus {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CiStatus value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CiStatus() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CiStatus value)  $default,){
final _that = this;
switch (_that) {
case _CiStatus():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CiStatus value)?  $default,){
final _that = this;
switch (_that) {
case _CiStatus() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String projectId,  CiHealth health,  String? lastWorkflowName,  String? lastCommitSha,  DateTime? lastRunAt,  int openPrCount,  int stalePrCount,  int recentCommitCount,  DateTime? checkedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CiStatus() when $default != null:
return $default(_that.projectId,_that.health,_that.lastWorkflowName,_that.lastCommitSha,_that.lastRunAt,_that.openPrCount,_that.stalePrCount,_that.recentCommitCount,_that.checkedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String projectId,  CiHealth health,  String? lastWorkflowName,  String? lastCommitSha,  DateTime? lastRunAt,  int openPrCount,  int stalePrCount,  int recentCommitCount,  DateTime? checkedAt)  $default,) {final _that = this;
switch (_that) {
case _CiStatus():
return $default(_that.projectId,_that.health,_that.lastWorkflowName,_that.lastCommitSha,_that.lastRunAt,_that.openPrCount,_that.stalePrCount,_that.recentCommitCount,_that.checkedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String projectId,  CiHealth health,  String? lastWorkflowName,  String? lastCommitSha,  DateTime? lastRunAt,  int openPrCount,  int stalePrCount,  int recentCommitCount,  DateTime? checkedAt)?  $default,) {final _that = this;
switch (_that) {
case _CiStatus() when $default != null:
return $default(_that.projectId,_that.health,_that.lastWorkflowName,_that.lastCommitSha,_that.lastRunAt,_that.openPrCount,_that.stalePrCount,_that.recentCommitCount,_that.checkedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CiStatus implements CiStatus {
  const _CiStatus({required this.projectId, required this.health, this.lastWorkflowName, this.lastCommitSha, this.lastRunAt, this.openPrCount = 0, this.stalePrCount = 0, this.recentCommitCount = 0, this.checkedAt});
  factory _CiStatus.fromJson(Map<String, dynamic> json) => _$CiStatusFromJson(json);

@override final  String projectId;
@override final  CiHealth health;
@override final  String? lastWorkflowName;
@override final  String? lastCommitSha;
@override final  DateTime? lastRunAt;
@override@JsonKey() final  int openPrCount;
@override@JsonKey() final  int stalePrCount;
@override@JsonKey() final  int recentCommitCount;
@override final  DateTime? checkedAt;

/// Create a copy of CiStatus
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CiStatusCopyWith<_CiStatus> get copyWith => __$CiStatusCopyWithImpl<_CiStatus>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CiStatusToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CiStatus&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.health, health) || other.health == health)&&(identical(other.lastWorkflowName, lastWorkflowName) || other.lastWorkflowName == lastWorkflowName)&&(identical(other.lastCommitSha, lastCommitSha) || other.lastCommitSha == lastCommitSha)&&(identical(other.lastRunAt, lastRunAt) || other.lastRunAt == lastRunAt)&&(identical(other.openPrCount, openPrCount) || other.openPrCount == openPrCount)&&(identical(other.stalePrCount, stalePrCount) || other.stalePrCount == stalePrCount)&&(identical(other.recentCommitCount, recentCommitCount) || other.recentCommitCount == recentCommitCount)&&(identical(other.checkedAt, checkedAt) || other.checkedAt == checkedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,projectId,health,lastWorkflowName,lastCommitSha,lastRunAt,openPrCount,stalePrCount,recentCommitCount,checkedAt);

@override
String toString() {
  return 'CiStatus(projectId: $projectId, health: $health, lastWorkflowName: $lastWorkflowName, lastCommitSha: $lastCommitSha, lastRunAt: $lastRunAt, openPrCount: $openPrCount, stalePrCount: $stalePrCount, recentCommitCount: $recentCommitCount, checkedAt: $checkedAt)';
}


}

/// @nodoc
abstract mixin class _$CiStatusCopyWith<$Res> implements $CiStatusCopyWith<$Res> {
  factory _$CiStatusCopyWith(_CiStatus value, $Res Function(_CiStatus) _then) = __$CiStatusCopyWithImpl;
@override @useResult
$Res call({
 String projectId, CiHealth health, String? lastWorkflowName, String? lastCommitSha, DateTime? lastRunAt, int openPrCount, int stalePrCount, int recentCommitCount, DateTime? checkedAt
});




}
/// @nodoc
class __$CiStatusCopyWithImpl<$Res>
    implements _$CiStatusCopyWith<$Res> {
  __$CiStatusCopyWithImpl(this._self, this._then);

  final _CiStatus _self;
  final $Res Function(_CiStatus) _then;

/// Create a copy of CiStatus
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? projectId = null,Object? health = null,Object? lastWorkflowName = freezed,Object? lastCommitSha = freezed,Object? lastRunAt = freezed,Object? openPrCount = null,Object? stalePrCount = null,Object? recentCommitCount = null,Object? checkedAt = freezed,}) {
  return _then(_CiStatus(
projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,health: null == health ? _self.health : health // ignore: cast_nullable_to_non_nullable
as CiHealth,lastWorkflowName: freezed == lastWorkflowName ? _self.lastWorkflowName : lastWorkflowName // ignore: cast_nullable_to_non_nullable
as String?,lastCommitSha: freezed == lastCommitSha ? _self.lastCommitSha : lastCommitSha // ignore: cast_nullable_to_non_nullable
as String?,lastRunAt: freezed == lastRunAt ? _self.lastRunAt : lastRunAt // ignore: cast_nullable_to_non_nullable
as DateTime?,openPrCount: null == openPrCount ? _self.openPrCount : openPrCount // ignore: cast_nullable_to_non_nullable
as int,stalePrCount: null == stalePrCount ? _self.stalePrCount : stalePrCount // ignore: cast_nullable_to_non_nullable
as int,recentCommitCount: null == recentCommitCount ? _self.recentCommitCount : recentCommitCount // ignore: cast_nullable_to_non_nullable
as int,checkedAt: freezed == checkedAt ? _self.checkedAt : checkedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
