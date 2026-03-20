// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'decision.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Decision {

 String get id; String get conversationId; String get messageId; String get title; String get reasoning; String get domain; List<String>? get alternativesConsidered; DateTime get createdAt; String? get supersededBy; bool get isActive; String get status;
/// Create a copy of Decision
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DecisionCopyWith<Decision> get copyWith => _$DecisionCopyWithImpl<Decision>(this as Decision, _$identity);

  /// Serializes this Decision to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Decision&&(identical(other.id, id) || other.id == id)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.messageId, messageId) || other.messageId == messageId)&&(identical(other.title, title) || other.title == title)&&(identical(other.reasoning, reasoning) || other.reasoning == reasoning)&&(identical(other.domain, domain) || other.domain == domain)&&const DeepCollectionEquality().equals(other.alternativesConsidered, alternativesConsidered)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.supersededBy, supersededBy) || other.supersededBy == supersededBy)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,conversationId,messageId,title,reasoning,domain,const DeepCollectionEquality().hash(alternativesConsidered),createdAt,supersededBy,isActive,status);

@override
String toString() {
  return 'Decision(id: $id, conversationId: $conversationId, messageId: $messageId, title: $title, reasoning: $reasoning, domain: $domain, alternativesConsidered: $alternativesConsidered, createdAt: $createdAt, supersededBy: $supersededBy, isActive: $isActive, status: $status)';
}


}

/// @nodoc
abstract mixin class $DecisionCopyWith<$Res>  {
  factory $DecisionCopyWith(Decision value, $Res Function(Decision) _then) = _$DecisionCopyWithImpl;
@useResult
$Res call({
 String id, String conversationId, String messageId, String title, String reasoning, String domain, List<String>? alternativesConsidered, DateTime createdAt, String? supersededBy, bool isActive, String status
});




}
/// @nodoc
class _$DecisionCopyWithImpl<$Res>
    implements $DecisionCopyWith<$Res> {
  _$DecisionCopyWithImpl(this._self, this._then);

  final Decision _self;
  final $Res Function(Decision) _then;

/// Create a copy of Decision
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? conversationId = null,Object? messageId = null,Object? title = null,Object? reasoning = null,Object? domain = null,Object? alternativesConsidered = freezed,Object? createdAt = null,Object? supersededBy = freezed,Object? isActive = null,Object? status = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,messageId: null == messageId ? _self.messageId : messageId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,reasoning: null == reasoning ? _self.reasoning : reasoning // ignore: cast_nullable_to_non_nullable
as String,domain: null == domain ? _self.domain : domain // ignore: cast_nullable_to_non_nullable
as String,alternativesConsidered: freezed == alternativesConsidered ? _self.alternativesConsidered : alternativesConsidered // ignore: cast_nullable_to_non_nullable
as List<String>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,supersededBy: freezed == supersededBy ? _self.supersededBy : supersededBy // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [Decision].
extension DecisionPatterns on Decision {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Decision value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Decision() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Decision value)  $default,){
final _that = this;
switch (_that) {
case _Decision():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Decision value)?  $default,){
final _that = this;
switch (_that) {
case _Decision() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String conversationId,  String messageId,  String title,  String reasoning,  String domain,  List<String>? alternativesConsidered,  DateTime createdAt,  String? supersededBy,  bool isActive,  String status)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Decision() when $default != null:
return $default(_that.id,_that.conversationId,_that.messageId,_that.title,_that.reasoning,_that.domain,_that.alternativesConsidered,_that.createdAt,_that.supersededBy,_that.isActive,_that.status);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String conversationId,  String messageId,  String title,  String reasoning,  String domain,  List<String>? alternativesConsidered,  DateTime createdAt,  String? supersededBy,  bool isActive,  String status)  $default,) {final _that = this;
switch (_that) {
case _Decision():
return $default(_that.id,_that.conversationId,_that.messageId,_that.title,_that.reasoning,_that.domain,_that.alternativesConsidered,_that.createdAt,_that.supersededBy,_that.isActive,_that.status);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String conversationId,  String messageId,  String title,  String reasoning,  String domain,  List<String>? alternativesConsidered,  DateTime createdAt,  String? supersededBy,  bool isActive,  String status)?  $default,) {final _that = this;
switch (_that) {
case _Decision() when $default != null:
return $default(_that.id,_that.conversationId,_that.messageId,_that.title,_that.reasoning,_that.domain,_that.alternativesConsidered,_that.createdAt,_that.supersededBy,_that.isActive,_that.status);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Decision implements Decision {
  const _Decision({required this.id, required this.conversationId, required this.messageId, required this.title, required this.reasoning, required this.domain, final  List<String>? alternativesConsidered, required this.createdAt, this.supersededBy, this.isActive = true, this.status = 'active'}): _alternativesConsidered = alternativesConsidered;
  factory _Decision.fromJson(Map<String, dynamic> json) => _$DecisionFromJson(json);

@override final  String id;
@override final  String conversationId;
@override final  String messageId;
@override final  String title;
@override final  String reasoning;
@override final  String domain;
 final  List<String>? _alternativesConsidered;
@override List<String>? get alternativesConsidered {
  final value = _alternativesConsidered;
  if (value == null) return null;
  if (_alternativesConsidered is EqualUnmodifiableListView) return _alternativesConsidered;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  DateTime createdAt;
@override final  String? supersededBy;
@override@JsonKey() final  bool isActive;
@override@JsonKey() final  String status;

/// Create a copy of Decision
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DecisionCopyWith<_Decision> get copyWith => __$DecisionCopyWithImpl<_Decision>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DecisionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Decision&&(identical(other.id, id) || other.id == id)&&(identical(other.conversationId, conversationId) || other.conversationId == conversationId)&&(identical(other.messageId, messageId) || other.messageId == messageId)&&(identical(other.title, title) || other.title == title)&&(identical(other.reasoning, reasoning) || other.reasoning == reasoning)&&(identical(other.domain, domain) || other.domain == domain)&&const DeepCollectionEquality().equals(other._alternativesConsidered, _alternativesConsidered)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.supersededBy, supersededBy) || other.supersededBy == supersededBy)&&(identical(other.isActive, isActive) || other.isActive == isActive)&&(identical(other.status, status) || other.status == status));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,conversationId,messageId,title,reasoning,domain,const DeepCollectionEquality().hash(_alternativesConsidered),createdAt,supersededBy,isActive,status);

@override
String toString() {
  return 'Decision(id: $id, conversationId: $conversationId, messageId: $messageId, title: $title, reasoning: $reasoning, domain: $domain, alternativesConsidered: $alternativesConsidered, createdAt: $createdAt, supersededBy: $supersededBy, isActive: $isActive, status: $status)';
}


}

/// @nodoc
abstract mixin class _$DecisionCopyWith<$Res> implements $DecisionCopyWith<$Res> {
  factory _$DecisionCopyWith(_Decision value, $Res Function(_Decision) _then) = __$DecisionCopyWithImpl;
@override @useResult
$Res call({
 String id, String conversationId, String messageId, String title, String reasoning, String domain, List<String>? alternativesConsidered, DateTime createdAt, String? supersededBy, bool isActive, String status
});




}
/// @nodoc
class __$DecisionCopyWithImpl<$Res>
    implements _$DecisionCopyWith<$Res> {
  __$DecisionCopyWithImpl(this._self, this._then);

  final _Decision _self;
  final $Res Function(_Decision) _then;

/// Create a copy of Decision
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? conversationId = null,Object? messageId = null,Object? title = null,Object? reasoning = null,Object? domain = null,Object? alternativesConsidered = freezed,Object? createdAt = null,Object? supersededBy = freezed,Object? isActive = null,Object? status = null,}) {
  return _then(_Decision(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,conversationId: null == conversationId ? _self.conversationId : conversationId // ignore: cast_nullable_to_non_nullable
as String,messageId: null == messageId ? _self.messageId : messageId // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,reasoning: null == reasoning ? _self.reasoning : reasoning // ignore: cast_nullable_to_non_nullable
as String,domain: null == domain ? _self.domain : domain // ignore: cast_nullable_to_non_nullable
as String,alternativesConsidered: freezed == alternativesConsidered ? _self._alternativesConsidered : alternativesConsidered // ignore: cast_nullable_to_non_nullable
as List<String>?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,supersededBy: freezed == supersededBy ? _self.supersededBy : supersededBy // ignore: cast_nullable_to_non_nullable
as String?,isActive: null == isActive ? _self.isActive : isActive // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
