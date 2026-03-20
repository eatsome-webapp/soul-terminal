// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'mood_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$MoodState {

 String get id; String get sessionId; int get energy;// 1-5
 String get emotion;// Plutchik: joy, trust, fear, surprise, sadness, disgust, anger, anticipation
 String get intent;// action, reflection, vent
 DateTime get analyzedAt; int get messageCount;
/// Create a copy of MoodState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$MoodStateCopyWith<MoodState> get copyWith => _$MoodStateCopyWithImpl<MoodState>(this as MoodState, _$identity);

  /// Serializes this MoodState to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is MoodState&&(identical(other.id, id) || other.id == id)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.energy, energy) || other.energy == energy)&&(identical(other.emotion, emotion) || other.emotion == emotion)&&(identical(other.intent, intent) || other.intent == intent)&&(identical(other.analyzedAt, analyzedAt) || other.analyzedAt == analyzedAt)&&(identical(other.messageCount, messageCount) || other.messageCount == messageCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sessionId,energy,emotion,intent,analyzedAt,messageCount);

@override
String toString() {
  return 'MoodState(id: $id, sessionId: $sessionId, energy: $energy, emotion: $emotion, intent: $intent, analyzedAt: $analyzedAt, messageCount: $messageCount)';
}


}

/// @nodoc
abstract mixin class $MoodStateCopyWith<$Res>  {
  factory $MoodStateCopyWith(MoodState value, $Res Function(MoodState) _then) = _$MoodStateCopyWithImpl;
@useResult
$Res call({
 String id, String sessionId, int energy, String emotion, String intent, DateTime analyzedAt, int messageCount
});




}
/// @nodoc
class _$MoodStateCopyWithImpl<$Res>
    implements $MoodStateCopyWith<$Res> {
  _$MoodStateCopyWithImpl(this._self, this._then);

  final MoodState _self;
  final $Res Function(MoodState) _then;

/// Create a copy of MoodState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? sessionId = null,Object? energy = null,Object? emotion = null,Object? intent = null,Object? analyzedAt = null,Object? messageCount = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,energy: null == energy ? _self.energy : energy // ignore: cast_nullable_to_non_nullable
as int,emotion: null == emotion ? _self.emotion : emotion // ignore: cast_nullable_to_non_nullable
as String,intent: null == intent ? _self.intent : intent // ignore: cast_nullable_to_non_nullable
as String,analyzedAt: null == analyzedAt ? _self.analyzedAt : analyzedAt // ignore: cast_nullable_to_non_nullable
as DateTime,messageCount: null == messageCount ? _self.messageCount : messageCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [MoodState].
extension MoodStatePatterns on MoodState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _MoodState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _MoodState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _MoodState value)  $default,){
final _that = this;
switch (_that) {
case _MoodState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _MoodState value)?  $default,){
final _that = this;
switch (_that) {
case _MoodState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String sessionId,  int energy,  String emotion,  String intent,  DateTime analyzedAt,  int messageCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _MoodState() when $default != null:
return $default(_that.id,_that.sessionId,_that.energy,_that.emotion,_that.intent,_that.analyzedAt,_that.messageCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String sessionId,  int energy,  String emotion,  String intent,  DateTime analyzedAt,  int messageCount)  $default,) {final _that = this;
switch (_that) {
case _MoodState():
return $default(_that.id,_that.sessionId,_that.energy,_that.emotion,_that.intent,_that.analyzedAt,_that.messageCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String sessionId,  int energy,  String emotion,  String intent,  DateTime analyzedAt,  int messageCount)?  $default,) {final _that = this;
switch (_that) {
case _MoodState() when $default != null:
return $default(_that.id,_that.sessionId,_that.energy,_that.emotion,_that.intent,_that.analyzedAt,_that.messageCount);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _MoodState implements MoodState {
  const _MoodState({required this.id, required this.sessionId, required this.energy, required this.emotion, required this.intent, required this.analyzedAt, required this.messageCount});
  factory _MoodState.fromJson(Map<String, dynamic> json) => _$MoodStateFromJson(json);

@override final  String id;
@override final  String sessionId;
@override final  int energy;
// 1-5
@override final  String emotion;
// Plutchik: joy, trust, fear, surprise, sadness, disgust, anger, anticipation
@override final  String intent;
// action, reflection, vent
@override final  DateTime analyzedAt;
@override final  int messageCount;

/// Create a copy of MoodState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$MoodStateCopyWith<_MoodState> get copyWith => __$MoodStateCopyWithImpl<_MoodState>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$MoodStateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _MoodState&&(identical(other.id, id) || other.id == id)&&(identical(other.sessionId, sessionId) || other.sessionId == sessionId)&&(identical(other.energy, energy) || other.energy == energy)&&(identical(other.emotion, emotion) || other.emotion == emotion)&&(identical(other.intent, intent) || other.intent == intent)&&(identical(other.analyzedAt, analyzedAt) || other.analyzedAt == analyzedAt)&&(identical(other.messageCount, messageCount) || other.messageCount == messageCount));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,sessionId,energy,emotion,intent,analyzedAt,messageCount);

@override
String toString() {
  return 'MoodState(id: $id, sessionId: $sessionId, energy: $energy, emotion: $emotion, intent: $intent, analyzedAt: $analyzedAt, messageCount: $messageCount)';
}


}

/// @nodoc
abstract mixin class _$MoodStateCopyWith<$Res> implements $MoodStateCopyWith<$Res> {
  factory _$MoodStateCopyWith(_MoodState value, $Res Function(_MoodState) _then) = __$MoodStateCopyWithImpl;
@override @useResult
$Res call({
 String id, String sessionId, int energy, String emotion, String intent, DateTime analyzedAt, int messageCount
});




}
/// @nodoc
class __$MoodStateCopyWithImpl<$Res>
    implements _$MoodStateCopyWith<$Res> {
  __$MoodStateCopyWithImpl(this._self, this._then);

  final _MoodState _self;
  final $Res Function(_MoodState) _then;

/// Create a copy of MoodState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? sessionId = null,Object? energy = null,Object? emotion = null,Object? intent = null,Object? analyzedAt = null,Object? messageCount = null,}) {
  return _then(_MoodState(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,sessionId: null == sessionId ? _self.sessionId : sessionId // ignore: cast_nullable_to_non_nullable
as String,energy: null == energy ? _self.energy : energy // ignore: cast_nullable_to_non_nullable
as int,emotion: null == emotion ? _self.emotion : emotion // ignore: cast_nullable_to_non_nullable
as String,intent: null == intent ? _self.intent : intent // ignore: cast_nullable_to_non_nullable
as String,analyzedAt: null == analyzedAt ? _self.analyzedAt : analyzedAt // ignore: cast_nullable_to_non_nullable
as DateTime,messageCount: null == messageCount ? _self.messageCount : messageCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
