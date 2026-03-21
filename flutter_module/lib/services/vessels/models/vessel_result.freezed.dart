// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vessel_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VesselResult {

 String get taskId; String? get terminalOutput; String? get codeDiff; String? get screenshotBase64; List<String> get links; String? get summary; Map<String, dynamic> get rawResponse;
/// Create a copy of VesselResult
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VesselResultCopyWith<VesselResult> get copyWith => _$VesselResultCopyWithImpl<VesselResult>(this as VesselResult, _$identity);

  /// Serializes this VesselResult to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VesselResult&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.terminalOutput, terminalOutput) || other.terminalOutput == terminalOutput)&&(identical(other.codeDiff, codeDiff) || other.codeDiff == codeDiff)&&(identical(other.screenshotBase64, screenshotBase64) || other.screenshotBase64 == screenshotBase64)&&const DeepCollectionEquality().equals(other.links, links)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other.rawResponse, rawResponse));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,taskId,terminalOutput,codeDiff,screenshotBase64,const DeepCollectionEquality().hash(links),summary,const DeepCollectionEquality().hash(rawResponse));

@override
String toString() {
  return 'VesselResult(taskId: $taskId, terminalOutput: $terminalOutput, codeDiff: $codeDiff, screenshotBase64: $screenshotBase64, links: $links, summary: $summary, rawResponse: $rawResponse)';
}


}

/// @nodoc
abstract mixin class $VesselResultCopyWith<$Res>  {
  factory $VesselResultCopyWith(VesselResult value, $Res Function(VesselResult) _then) = _$VesselResultCopyWithImpl;
@useResult
$Res call({
 String taskId, String? terminalOutput, String? codeDiff, String? screenshotBase64, List<String> links, String? summary, Map<String, dynamic> rawResponse
});




}
/// @nodoc
class _$VesselResultCopyWithImpl<$Res>
    implements $VesselResultCopyWith<$Res> {
  _$VesselResultCopyWithImpl(this._self, this._then);

  final VesselResult _self;
  final $Res Function(VesselResult) _then;

/// Create a copy of VesselResult
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? taskId = null,Object? terminalOutput = freezed,Object? codeDiff = freezed,Object? screenshotBase64 = freezed,Object? links = null,Object? summary = freezed,Object? rawResponse = null,}) {
  return _then(_self.copyWith(
taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,terminalOutput: freezed == terminalOutput ? _self.terminalOutput : terminalOutput // ignore: cast_nullable_to_non_nullable
as String?,codeDiff: freezed == codeDiff ? _self.codeDiff : codeDiff // ignore: cast_nullable_to_non_nullable
as String?,screenshotBase64: freezed == screenshotBase64 ? _self.screenshotBase64 : screenshotBase64 // ignore: cast_nullable_to_non_nullable
as String?,links: null == links ? _self.links : links // ignore: cast_nullable_to_non_nullable
as List<String>,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String?,rawResponse: null == rawResponse ? _self.rawResponse : rawResponse // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}

}


/// Adds pattern-matching-related methods to [VesselResult].
extension VesselResultPatterns on VesselResult {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VesselResult value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VesselResult() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VesselResult value)  $default,){
final _that = this;
switch (_that) {
case _VesselResult():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VesselResult value)?  $default,){
final _that = this;
switch (_that) {
case _VesselResult() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String taskId,  String? terminalOutput,  String? codeDiff,  String? screenshotBase64,  List<String> links,  String? summary,  Map<String, dynamic> rawResponse)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VesselResult() when $default != null:
return $default(_that.taskId,_that.terminalOutput,_that.codeDiff,_that.screenshotBase64,_that.links,_that.summary,_that.rawResponse);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String taskId,  String? terminalOutput,  String? codeDiff,  String? screenshotBase64,  List<String> links,  String? summary,  Map<String, dynamic> rawResponse)  $default,) {final _that = this;
switch (_that) {
case _VesselResult():
return $default(_that.taskId,_that.terminalOutput,_that.codeDiff,_that.screenshotBase64,_that.links,_that.summary,_that.rawResponse);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String taskId,  String? terminalOutput,  String? codeDiff,  String? screenshotBase64,  List<String> links,  String? summary,  Map<String, dynamic> rawResponse)?  $default,) {final _that = this;
switch (_that) {
case _VesselResult() when $default != null:
return $default(_that.taskId,_that.terminalOutput,_that.codeDiff,_that.screenshotBase64,_that.links,_that.summary,_that.rawResponse);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VesselResult implements VesselResult {
  const _VesselResult({required this.taskId, this.terminalOutput, this.codeDiff, this.screenshotBase64, final  List<String> links = const [], this.summary, final  Map<String, dynamic> rawResponse = const {}}): _links = links,_rawResponse = rawResponse;
  factory _VesselResult.fromJson(Map<String, dynamic> json) => _$VesselResultFromJson(json);

@override final  String taskId;
@override final  String? terminalOutput;
@override final  String? codeDiff;
@override final  String? screenshotBase64;
 final  List<String> _links;
@override@JsonKey() List<String> get links {
  if (_links is EqualUnmodifiableListView) return _links;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_links);
}

@override final  String? summary;
 final  Map<String, dynamic> _rawResponse;
@override@JsonKey() Map<String, dynamic> get rawResponse {
  if (_rawResponse is EqualUnmodifiableMapView) return _rawResponse;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_rawResponse);
}


/// Create a copy of VesselResult
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VesselResultCopyWith<_VesselResult> get copyWith => __$VesselResultCopyWithImpl<_VesselResult>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VesselResultToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VesselResult&&(identical(other.taskId, taskId) || other.taskId == taskId)&&(identical(other.terminalOutput, terminalOutput) || other.terminalOutput == terminalOutput)&&(identical(other.codeDiff, codeDiff) || other.codeDiff == codeDiff)&&(identical(other.screenshotBase64, screenshotBase64) || other.screenshotBase64 == screenshotBase64)&&const DeepCollectionEquality().equals(other._links, _links)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other._rawResponse, _rawResponse));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,taskId,terminalOutput,codeDiff,screenshotBase64,const DeepCollectionEquality().hash(_links),summary,const DeepCollectionEquality().hash(_rawResponse));

@override
String toString() {
  return 'VesselResult(taskId: $taskId, terminalOutput: $terminalOutput, codeDiff: $codeDiff, screenshotBase64: $screenshotBase64, links: $links, summary: $summary, rawResponse: $rawResponse)';
}


}

/// @nodoc
abstract mixin class _$VesselResultCopyWith<$Res> implements $VesselResultCopyWith<$Res> {
  factory _$VesselResultCopyWith(_VesselResult value, $Res Function(_VesselResult) _then) = __$VesselResultCopyWithImpl;
@override @useResult
$Res call({
 String taskId, String? terminalOutput, String? codeDiff, String? screenshotBase64, List<String> links, String? summary, Map<String, dynamic> rawResponse
});




}
/// @nodoc
class __$VesselResultCopyWithImpl<$Res>
    implements _$VesselResultCopyWith<$Res> {
  __$VesselResultCopyWithImpl(this._self, this._then);

  final _VesselResult _self;
  final $Res Function(_VesselResult) _then;

/// Create a copy of VesselResult
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? taskId = null,Object? terminalOutput = freezed,Object? codeDiff = freezed,Object? screenshotBase64 = freezed,Object? links = null,Object? summary = freezed,Object? rawResponse = null,}) {
  return _then(_VesselResult(
taskId: null == taskId ? _self.taskId : taskId // ignore: cast_nullable_to_non_nullable
as String,terminalOutput: freezed == terminalOutput ? _self.terminalOutput : terminalOutput // ignore: cast_nullable_to_non_nullable
as String?,codeDiff: freezed == codeDiff ? _self.codeDiff : codeDiff // ignore: cast_nullable_to_non_nullable
as String?,screenshotBase64: freezed == screenshotBase64 ? _self.screenshotBase64 : screenshotBase64 // ignore: cast_nullable_to_non_nullable
as String?,links: null == links ? _self._links : links // ignore: cast_nullable_to_non_nullable
as List<String>,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as String?,rawResponse: null == rawResponse ? _self._rawResponse : rawResponse // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,
  ));
}


}

// dart format on
