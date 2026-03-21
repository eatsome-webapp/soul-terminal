// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vessel_connection.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$VesselConnection {

 String get vesselId; String get vesselName; ConnectionStatus get status; String? get errorMessage; DateTime? get connectedAt; DateTime? get lastHealthCheck;
/// Create a copy of VesselConnection
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VesselConnectionCopyWith<VesselConnection> get copyWith => _$VesselConnectionCopyWithImpl<VesselConnection>(this as VesselConnection, _$identity);

  /// Serializes this VesselConnection to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VesselConnection&&(identical(other.vesselId, vesselId) || other.vesselId == vesselId)&&(identical(other.vesselName, vesselName) || other.vesselName == vesselName)&&(identical(other.status, status) || other.status == status)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.connectedAt, connectedAt) || other.connectedAt == connectedAt)&&(identical(other.lastHealthCheck, lastHealthCheck) || other.lastHealthCheck == lastHealthCheck));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,vesselId,vesselName,status,errorMessage,connectedAt,lastHealthCheck);

@override
String toString() {
  return 'VesselConnection(vesselId: $vesselId, vesselName: $vesselName, status: $status, errorMessage: $errorMessage, connectedAt: $connectedAt, lastHealthCheck: $lastHealthCheck)';
}


}

/// @nodoc
abstract mixin class $VesselConnectionCopyWith<$Res>  {
  factory $VesselConnectionCopyWith(VesselConnection value, $Res Function(VesselConnection) _then) = _$VesselConnectionCopyWithImpl;
@useResult
$Res call({
 String vesselId, String vesselName, ConnectionStatus status, String? errorMessage, DateTime? connectedAt, DateTime? lastHealthCheck
});




}
/// @nodoc
class _$VesselConnectionCopyWithImpl<$Res>
    implements $VesselConnectionCopyWith<$Res> {
  _$VesselConnectionCopyWithImpl(this._self, this._then);

  final VesselConnection _self;
  final $Res Function(VesselConnection) _then;

/// Create a copy of VesselConnection
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? vesselId = null,Object? vesselName = null,Object? status = null,Object? errorMessage = freezed,Object? connectedAt = freezed,Object? lastHealthCheck = freezed,}) {
  return _then(_self.copyWith(
vesselId: null == vesselId ? _self.vesselId : vesselId // ignore: cast_nullable_to_non_nullable
as String,vesselName: null == vesselName ? _self.vesselName : vesselName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConnectionStatus,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,connectedAt: freezed == connectedAt ? _self.connectedAt : connectedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastHealthCheck: freezed == lastHealthCheck ? _self.lastHealthCheck : lastHealthCheck // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [VesselConnection].
extension VesselConnectionPatterns on VesselConnection {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _VesselConnection value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _VesselConnection() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _VesselConnection value)  $default,){
final _that = this;
switch (_that) {
case _VesselConnection():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _VesselConnection value)?  $default,){
final _that = this;
switch (_that) {
case _VesselConnection() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String vesselId,  String vesselName,  ConnectionStatus status,  String? errorMessage,  DateTime? connectedAt,  DateTime? lastHealthCheck)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _VesselConnection() when $default != null:
return $default(_that.vesselId,_that.vesselName,_that.status,_that.errorMessage,_that.connectedAt,_that.lastHealthCheck);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String vesselId,  String vesselName,  ConnectionStatus status,  String? errorMessage,  DateTime? connectedAt,  DateTime? lastHealthCheck)  $default,) {final _that = this;
switch (_that) {
case _VesselConnection():
return $default(_that.vesselId,_that.vesselName,_that.status,_that.errorMessage,_that.connectedAt,_that.lastHealthCheck);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String vesselId,  String vesselName,  ConnectionStatus status,  String? errorMessage,  DateTime? connectedAt,  DateTime? lastHealthCheck)?  $default,) {final _that = this;
switch (_that) {
case _VesselConnection() when $default != null:
return $default(_that.vesselId,_that.vesselName,_that.status,_that.errorMessage,_that.connectedAt,_that.lastHealthCheck);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _VesselConnection implements VesselConnection {
  const _VesselConnection({required this.vesselId, required this.vesselName, required this.status, this.errorMessage, this.connectedAt, this.lastHealthCheck});
  factory _VesselConnection.fromJson(Map<String, dynamic> json) => _$VesselConnectionFromJson(json);

@override final  String vesselId;
@override final  String vesselName;
@override final  ConnectionStatus status;
@override final  String? errorMessage;
@override final  DateTime? connectedAt;
@override final  DateTime? lastHealthCheck;

/// Create a copy of VesselConnection
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$VesselConnectionCopyWith<_VesselConnection> get copyWith => __$VesselConnectionCopyWithImpl<_VesselConnection>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$VesselConnectionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _VesselConnection&&(identical(other.vesselId, vesselId) || other.vesselId == vesselId)&&(identical(other.vesselName, vesselName) || other.vesselName == vesselName)&&(identical(other.status, status) || other.status == status)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.connectedAt, connectedAt) || other.connectedAt == connectedAt)&&(identical(other.lastHealthCheck, lastHealthCheck) || other.lastHealthCheck == lastHealthCheck));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,vesselId,vesselName,status,errorMessage,connectedAt,lastHealthCheck);

@override
String toString() {
  return 'VesselConnection(vesselId: $vesselId, vesselName: $vesselName, status: $status, errorMessage: $errorMessage, connectedAt: $connectedAt, lastHealthCheck: $lastHealthCheck)';
}


}

/// @nodoc
abstract mixin class _$VesselConnectionCopyWith<$Res> implements $VesselConnectionCopyWith<$Res> {
  factory _$VesselConnectionCopyWith(_VesselConnection value, $Res Function(_VesselConnection) _then) = __$VesselConnectionCopyWithImpl;
@override @useResult
$Res call({
 String vesselId, String vesselName, ConnectionStatus status, String? errorMessage, DateTime? connectedAt, DateTime? lastHealthCheck
});




}
/// @nodoc
class __$VesselConnectionCopyWithImpl<$Res>
    implements _$VesselConnectionCopyWith<$Res> {
  __$VesselConnectionCopyWithImpl(this._self, this._then);

  final _VesselConnection _self;
  final $Res Function(_VesselConnection) _then;

/// Create a copy of VesselConnection
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? vesselId = null,Object? vesselName = null,Object? status = null,Object? errorMessage = freezed,Object? connectedAt = freezed,Object? lastHealthCheck = freezed,}) {
  return _then(_VesselConnection(
vesselId: null == vesselId ? _self.vesselId : vesselId // ignore: cast_nullable_to_non_nullable
as String,vesselName: null == vesselName ? _self.vesselName : vesselName // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ConnectionStatus,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,connectedAt: freezed == connectedAt ? _self.connectedAt : connectedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,lastHealthCheck: freezed == lastHealthCheck ? _self.lastHealthCheck : lastHealthCheck // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
