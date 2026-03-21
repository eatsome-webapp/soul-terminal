// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'intervention.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InterventionState {

 String get id; InterventionType get type; InterventionLevel get level; String get triggerDescription; String? get proposedDefault; DateTime? get proposalDeadlineAt; DateTime get detectedAt; DateTime? get level1SentAt; DateTime? get level2SentAt; DateTime? get level3SentAt; DateTime? get resolvedAt; String? get relatedEntityId;
/// Create a copy of InterventionState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InterventionStateCopyWith<InterventionState> get copyWith => _$InterventionStateCopyWithImpl<InterventionState>(this as InterventionState, _$identity);

  /// Serializes this InterventionState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InterventionState&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.level, level) || other.level == level)&&(identical(other.triggerDescription, triggerDescription) || other.triggerDescription == triggerDescription)&&(identical(other.proposedDefault, proposedDefault) || other.proposedDefault == proposedDefault)&&(identical(other.proposalDeadlineAt, proposalDeadlineAt) || other.proposalDeadlineAt == proposalDeadlineAt)&&(identical(other.detectedAt, detectedAt) || other.detectedAt == detectedAt)&&(identical(other.level1SentAt, level1SentAt) || other.level1SentAt == level1SentAt)&&(identical(other.level2SentAt, level2SentAt) || other.level2SentAt == level2SentAt)&&(identical(other.level3SentAt, level3SentAt) || other.level3SentAt == level3SentAt)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&(identical(other.relatedEntityId, relatedEntityId) || other.relatedEntityId == relatedEntityId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,level,triggerDescription,proposedDefault,proposalDeadlineAt,detectedAt,level1SentAt,level2SentAt,level3SentAt,resolvedAt,relatedEntityId);

@override
String toString() {
  return 'InterventionState(id: $id, type: $type, level: $level, triggerDescription: $triggerDescription, proposedDefault: $proposedDefault, proposalDeadlineAt: $proposalDeadlineAt, detectedAt: $detectedAt, level1SentAt: $level1SentAt, level2SentAt: $level2SentAt, level3SentAt: $level3SentAt, resolvedAt: $resolvedAt, relatedEntityId: $relatedEntityId)';
}


}

/// @nodoc
abstract mixin class $InterventionStateCopyWith<$Res>  {
  factory $InterventionStateCopyWith(InterventionState value, $Res Function(InterventionState) _then) = _$InterventionStateCopyWithImpl;
@useResult
$Res call({
 String id, InterventionType type, InterventionLevel level, String triggerDescription, String? proposedDefault, DateTime? proposalDeadlineAt, DateTime detectedAt, DateTime? level1SentAt, DateTime? level2SentAt, DateTime? level3SentAt, DateTime? resolvedAt, String? relatedEntityId
});




}
/// @nodoc
class _$InterventionStateCopyWithImpl<$Res>
    implements $InterventionStateCopyWith<$Res> {
  _$InterventionStateCopyWithImpl(this._self, this._then);

  final InterventionState _self;
  final $Res Function(InterventionState) _then;

/// Create a copy of InterventionState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? level = null,Object? triggerDescription = null,Object? proposedDefault = freezed,Object? proposalDeadlineAt = freezed,Object? detectedAt = null,Object? level1SentAt = freezed,Object? level2SentAt = freezed,Object? level3SentAt = freezed,Object? resolvedAt = freezed,Object? relatedEntityId = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as InterventionType,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as InterventionLevel,triggerDescription: null == triggerDescription ? _self.triggerDescription : triggerDescription // ignore: cast_nullable_to_non_nullable
as String,proposedDefault: freezed == proposedDefault ? _self.proposedDefault : proposedDefault // ignore: cast_nullable_to_non_nullable
as String?,proposalDeadlineAt: freezed == proposalDeadlineAt ? _self.proposalDeadlineAt : proposalDeadlineAt // ignore: cast_nullable_to_non_nullable
as DateTime?,detectedAt: null == detectedAt ? _self.detectedAt : detectedAt // ignore: cast_nullable_to_non_nullable
as DateTime,level1SentAt: freezed == level1SentAt ? _self.level1SentAt : level1SentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,level2SentAt: freezed == level2SentAt ? _self.level2SentAt : level2SentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,level3SentAt: freezed == level3SentAt ? _self.level3SentAt : level3SentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,relatedEntityId: freezed == relatedEntityId ? _self.relatedEntityId : relatedEntityId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [InterventionState].
extension InterventionStatePatterns on InterventionState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InterventionState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InterventionState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InterventionState value)  $default,){
final _that = this;
switch (_that) {
case _InterventionState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InterventionState value)?  $default,){
final _that = this;
switch (_that) {
case _InterventionState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  InterventionType type,  InterventionLevel level,  String triggerDescription,  String? proposedDefault,  DateTime? proposalDeadlineAt,  DateTime detectedAt,  DateTime? level1SentAt,  DateTime? level2SentAt,  DateTime? level3SentAt,  DateTime? resolvedAt,  String? relatedEntityId)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InterventionState() when $default != null:
return $default(_that.id,_that.type,_that.level,_that.triggerDescription,_that.proposedDefault,_that.proposalDeadlineAt,_that.detectedAt,_that.level1SentAt,_that.level2SentAt,_that.level3SentAt,_that.resolvedAt,_that.relatedEntityId);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  InterventionType type,  InterventionLevel level,  String triggerDescription,  String? proposedDefault,  DateTime? proposalDeadlineAt,  DateTime detectedAt,  DateTime? level1SentAt,  DateTime? level2SentAt,  DateTime? level3SentAt,  DateTime? resolvedAt,  String? relatedEntityId)  $default,) {final _that = this;
switch (_that) {
case _InterventionState():
return $default(_that.id,_that.type,_that.level,_that.triggerDescription,_that.proposedDefault,_that.proposalDeadlineAt,_that.detectedAt,_that.level1SentAt,_that.level2SentAt,_that.level3SentAt,_that.resolvedAt,_that.relatedEntityId);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  InterventionType type,  InterventionLevel level,  String triggerDescription,  String? proposedDefault,  DateTime? proposalDeadlineAt,  DateTime detectedAt,  DateTime? level1SentAt,  DateTime? level2SentAt,  DateTime? level3SentAt,  DateTime? resolvedAt,  String? relatedEntityId)?  $default,) {final _that = this;
switch (_that) {
case _InterventionState() when $default != null:
return $default(_that.id,_that.type,_that.level,_that.triggerDescription,_that.proposedDefault,_that.proposalDeadlineAt,_that.detectedAt,_that.level1SentAt,_that.level2SentAt,_that.level3SentAt,_that.resolvedAt,_that.relatedEntityId);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InterventionState implements InterventionState {
  const _InterventionState({required this.id, required this.type, required this.level, required this.triggerDescription, this.proposedDefault, this.proposalDeadlineAt, required this.detectedAt, this.level1SentAt, this.level2SentAt, this.level3SentAt, this.resolvedAt, this.relatedEntityId});
  factory _InterventionState.fromJson(Map<String, dynamic> json) => _$InterventionStateFromJson(json);

@override final  String id;
@override final  InterventionType type;
@override final  InterventionLevel level;
@override final  String triggerDescription;
@override final  String? proposedDefault;
@override final  DateTime? proposalDeadlineAt;
@override final  DateTime detectedAt;
@override final  DateTime? level1SentAt;
@override final  DateTime? level2SentAt;
@override final  DateTime? level3SentAt;
@override final  DateTime? resolvedAt;
@override final  String? relatedEntityId;

/// Create a copy of InterventionState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InterventionStateCopyWith<_InterventionState> get copyWith => __$InterventionStateCopyWithImpl<_InterventionState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InterventionStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InterventionState&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.level, level) || other.level == level)&&(identical(other.triggerDescription, triggerDescription) || other.triggerDescription == triggerDescription)&&(identical(other.proposedDefault, proposedDefault) || other.proposedDefault == proposedDefault)&&(identical(other.proposalDeadlineAt, proposalDeadlineAt) || other.proposalDeadlineAt == proposalDeadlineAt)&&(identical(other.detectedAt, detectedAt) || other.detectedAt == detectedAt)&&(identical(other.level1SentAt, level1SentAt) || other.level1SentAt == level1SentAt)&&(identical(other.level2SentAt, level2SentAt) || other.level2SentAt == level2SentAt)&&(identical(other.level3SentAt, level3SentAt) || other.level3SentAt == level3SentAt)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&(identical(other.relatedEntityId, relatedEntityId) || other.relatedEntityId == relatedEntityId));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,type,level,triggerDescription,proposedDefault,proposalDeadlineAt,detectedAt,level1SentAt,level2SentAt,level3SentAt,resolvedAt,relatedEntityId);

@override
String toString() {
  return 'InterventionState(id: $id, type: $type, level: $level, triggerDescription: $triggerDescription, proposedDefault: $proposedDefault, proposalDeadlineAt: $proposalDeadlineAt, detectedAt: $detectedAt, level1SentAt: $level1SentAt, level2SentAt: $level2SentAt, level3SentAt: $level3SentAt, resolvedAt: $resolvedAt, relatedEntityId: $relatedEntityId)';
}


}

/// @nodoc
abstract mixin class _$InterventionStateCopyWith<$Res> implements $InterventionStateCopyWith<$Res> {
  factory _$InterventionStateCopyWith(_InterventionState value, $Res Function(_InterventionState) _then) = __$InterventionStateCopyWithImpl;
@override @useResult
$Res call({
 String id, InterventionType type, InterventionLevel level, String triggerDescription, String? proposedDefault, DateTime? proposalDeadlineAt, DateTime detectedAt, DateTime? level1SentAt, DateTime? level2SentAt, DateTime? level3SentAt, DateTime? resolvedAt, String? relatedEntityId
});




}
/// @nodoc
class __$InterventionStateCopyWithImpl<$Res>
    implements _$InterventionStateCopyWith<$Res> {
  __$InterventionStateCopyWithImpl(this._self, this._then);

  final _InterventionState _self;
  final $Res Function(_InterventionState) _then;

/// Create a copy of InterventionState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? level = null,Object? triggerDescription = null,Object? proposedDefault = freezed,Object? proposalDeadlineAt = freezed,Object? detectedAt = null,Object? level1SentAt = freezed,Object? level2SentAt = freezed,Object? level3SentAt = freezed,Object? resolvedAt = freezed,Object? relatedEntityId = freezed,}) {
  return _then(_InterventionState(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as InterventionType,level: null == level ? _self.level : level // ignore: cast_nullable_to_non_nullable
as InterventionLevel,triggerDescription: null == triggerDescription ? _self.triggerDescription : triggerDescription // ignore: cast_nullable_to_non_nullable
as String,proposedDefault: freezed == proposedDefault ? _self.proposedDefault : proposedDefault // ignore: cast_nullable_to_non_nullable
as String?,proposalDeadlineAt: freezed == proposalDeadlineAt ? _self.proposalDeadlineAt : proposalDeadlineAt // ignore: cast_nullable_to_non_nullable
as DateTime?,detectedAt: null == detectedAt ? _self.detectedAt : detectedAt // ignore: cast_nullable_to_non_nullable
as DateTime,level1SentAt: freezed == level1SentAt ? _self.level1SentAt : level1SentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,level2SentAt: freezed == level2SentAt ? _self.level2SentAt : level2SentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,level3SentAt: freezed == level3SentAt ? _self.level3SentAt : level3SentAt // ignore: cast_nullable_to_non_nullable
as DateTime?,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,relatedEntityId: freezed == relatedEntityId ? _self.relatedEntityId : relatedEntityId // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
