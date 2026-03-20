// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_trait.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProfileTrait {

 String get id; String get category; String get traitKey; String get traitValue; double get confidence; int get evidenceCount; DateTime get firstObserved; DateTime get lastObserved;
/// Create a copy of ProfileTrait
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileTraitCopyWith<ProfileTrait> get copyWith => _$ProfileTraitCopyWithImpl<ProfileTrait>(this as ProfileTrait, _$identity);

  /// Serializes this ProfileTrait to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileTrait&&(identical(other.id, id) || other.id == id)&&(identical(other.category, category) || other.category == category)&&(identical(other.traitKey, traitKey) || other.traitKey == traitKey)&&(identical(other.traitValue, traitValue) || other.traitValue == traitValue)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.evidenceCount, evidenceCount) || other.evidenceCount == evidenceCount)&&(identical(other.firstObserved, firstObserved) || other.firstObserved == firstObserved)&&(identical(other.lastObserved, lastObserved) || other.lastObserved == lastObserved));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,category,traitKey,traitValue,confidence,evidenceCount,firstObserved,lastObserved);

@override
String toString() {
  return 'ProfileTrait(id: $id, category: $category, traitKey: $traitKey, traitValue: $traitValue, confidence: $confidence, evidenceCount: $evidenceCount, firstObserved: $firstObserved, lastObserved: $lastObserved)';
}


}

/// @nodoc
abstract mixin class $ProfileTraitCopyWith<$Res>  {
  factory $ProfileTraitCopyWith(ProfileTrait value, $Res Function(ProfileTrait) _then) = _$ProfileTraitCopyWithImpl;
@useResult
$Res call({
 String id, String category, String traitKey, String traitValue, double confidence, int evidenceCount, DateTime firstObserved, DateTime lastObserved
});




}
/// @nodoc
class _$ProfileTraitCopyWithImpl<$Res>
    implements $ProfileTraitCopyWith<$Res> {
  _$ProfileTraitCopyWithImpl(this._self, this._then);

  final ProfileTrait _self;
  final $Res Function(ProfileTrait) _then;

/// Create a copy of ProfileTrait
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? category = null,Object? traitKey = null,Object? traitValue = null,Object? confidence = null,Object? evidenceCount = null,Object? firstObserved = null,Object? lastObserved = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,traitKey: null == traitKey ? _self.traitKey : traitKey // ignore: cast_nullable_to_non_nullable
as String,traitValue: null == traitValue ? _self.traitValue : traitValue // ignore: cast_nullable_to_non_nullable
as String,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,evidenceCount: null == evidenceCount ? _self.evidenceCount : evidenceCount // ignore: cast_nullable_to_non_nullable
as int,firstObserved: null == firstObserved ? _self.firstObserved : firstObserved // ignore: cast_nullable_to_non_nullable
as DateTime,lastObserved: null == lastObserved ? _self.lastObserved : lastObserved // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfileTrait].
extension ProfileTraitPatterns on ProfileTrait {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileTrait value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileTrait() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileTrait value)  $default,){
final _that = this;
switch (_that) {
case _ProfileTrait():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileTrait value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileTrait() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String category,  String traitKey,  String traitValue,  double confidence,  int evidenceCount,  DateTime firstObserved,  DateTime lastObserved)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileTrait() when $default != null:
return $default(_that.id,_that.category,_that.traitKey,_that.traitValue,_that.confidence,_that.evidenceCount,_that.firstObserved,_that.lastObserved);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String category,  String traitKey,  String traitValue,  double confidence,  int evidenceCount,  DateTime firstObserved,  DateTime lastObserved)  $default,) {final _that = this;
switch (_that) {
case _ProfileTrait():
return $default(_that.id,_that.category,_that.traitKey,_that.traitValue,_that.confidence,_that.evidenceCount,_that.firstObserved,_that.lastObserved);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String category,  String traitKey,  String traitValue,  double confidence,  int evidenceCount,  DateTime firstObserved,  DateTime lastObserved)?  $default,) {final _that = this;
switch (_that) {
case _ProfileTrait() when $default != null:
return $default(_that.id,_that.category,_that.traitKey,_that.traitValue,_that.confidence,_that.evidenceCount,_that.firstObserved,_that.lastObserved);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProfileTrait implements ProfileTrait {
  const _ProfileTrait({required this.id, required this.category, required this.traitKey, required this.traitValue, this.confidence = 0.5, this.evidenceCount = 1, required this.firstObserved, required this.lastObserved});
  factory _ProfileTrait.fromJson(Map<String, dynamic> json) => _$ProfileTraitFromJson(json);

@override final  String id;
@override final  String category;
@override final  String traitKey;
@override final  String traitValue;
@override@JsonKey() final  double confidence;
@override@JsonKey() final  int evidenceCount;
@override final  DateTime firstObserved;
@override final  DateTime lastObserved;

/// Create a copy of ProfileTrait
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileTraitCopyWith<_ProfileTrait> get copyWith => __$ProfileTraitCopyWithImpl<_ProfileTrait>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfileTraitToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileTrait&&(identical(other.id, id) || other.id == id)&&(identical(other.category, category) || other.category == category)&&(identical(other.traitKey, traitKey) || other.traitKey == traitKey)&&(identical(other.traitValue, traitValue) || other.traitValue == traitValue)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.evidenceCount, evidenceCount) || other.evidenceCount == evidenceCount)&&(identical(other.firstObserved, firstObserved) || other.firstObserved == firstObserved)&&(identical(other.lastObserved, lastObserved) || other.lastObserved == lastObserved));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,category,traitKey,traitValue,confidence,evidenceCount,firstObserved,lastObserved);

@override
String toString() {
  return 'ProfileTrait(id: $id, category: $category, traitKey: $traitKey, traitValue: $traitValue, confidence: $confidence, evidenceCount: $evidenceCount, firstObserved: $firstObserved, lastObserved: $lastObserved)';
}


}

/// @nodoc
abstract mixin class _$ProfileTraitCopyWith<$Res> implements $ProfileTraitCopyWith<$Res> {
  factory _$ProfileTraitCopyWith(_ProfileTrait value, $Res Function(_ProfileTrait) _then) = __$ProfileTraitCopyWithImpl;
@override @useResult
$Res call({
 String id, String category, String traitKey, String traitValue, double confidence, int evidenceCount, DateTime firstObserved, DateTime lastObserved
});




}
/// @nodoc
class __$ProfileTraitCopyWithImpl<$Res>
    implements _$ProfileTraitCopyWith<$Res> {
  __$ProfileTraitCopyWithImpl(this._self, this._then);

  final _ProfileTrait _self;
  final $Res Function(_ProfileTrait) _then;

/// Create a copy of ProfileTrait
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? category = null,Object? traitKey = null,Object? traitValue = null,Object? confidence = null,Object? evidenceCount = null,Object? firstObserved = null,Object? lastObserved = null,}) {
  return _then(_ProfileTrait(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String,traitKey: null == traitKey ? _self.traitKey : traitKey // ignore: cast_nullable_to_non_nullable
as String,traitValue: null == traitValue ? _self.traitValue : traitValue // ignore: cast_nullable_to_non_nullable
as String,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as double,evidenceCount: null == evidenceCount ? _self.evidenceCount : evidenceCount // ignore: cast_nullable_to_non_nullable
as int,firstObserved: null == firstObserved ? _self.firstObserved : firstObserved // ignore: cast_nullable_to_non_nullable
as DateTime,lastObserved: null == lastObserved ? _self.lastObserved : lastObserved // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
