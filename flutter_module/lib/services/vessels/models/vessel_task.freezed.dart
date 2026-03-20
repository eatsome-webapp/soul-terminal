// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'vessel_task.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$VesselTask {

 String get id; String get description; VesselType get targetVessel; TrustTier get tier;
/// Create a copy of VesselTask
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$VesselTaskCopyWith<VesselTask> get copyWith => _$VesselTaskCopyWithImpl<VesselTask>(this as VesselTask, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is VesselTask&&(identical(other.id, id) || other.id == id)&&(identical(other.description, description) || other.description == description)&&(identical(other.targetVessel, targetVessel) || other.targetVessel == targetVessel)&&(identical(other.tier, tier) || other.tier == tier));
}


@override
int get hashCode => Object.hash(runtimeType,id,description,targetVessel,tier);

@override
String toString() {
  return 'VesselTask(id: $id, description: $description, targetVessel: $targetVessel, tier: $tier)';
}


}

/// @nodoc
abstract mixin class $VesselTaskCopyWith<$Res>  {
  factory $VesselTaskCopyWith(VesselTask value, $Res Function(VesselTask) _then) = _$VesselTaskCopyWithImpl;
@useResult
$Res call({
 String id, String description, VesselType targetVessel, TrustTier tier
});




}
/// @nodoc
class _$VesselTaskCopyWithImpl<$Res>
    implements $VesselTaskCopyWith<$Res> {
  _$VesselTaskCopyWithImpl(this._self, this._then);

  final VesselTask _self;
  final $Res Function(VesselTask) _then;

/// Create a copy of VesselTask
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? description = null,Object? targetVessel = null,Object? tier = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,targetVessel: null == targetVessel ? _self.targetVessel : targetVessel // ignore: cast_nullable_to_non_nullable
as VesselType,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as TrustTier,
  ));
}

}


/// Adds pattern-matching-related methods to [VesselTask].
extension VesselTaskPatterns on VesselTask {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( ProposedTask value)?  proposed,TResult Function( ApprovedTask value)?  approved,TResult Function( ExecutingTask value)?  executing,TResult Function( CompletedTask value)?  completed,TResult Function( FailedTask value)?  failed,TResult Function( RejectedTask value)?  rejected,required TResult orElse(),}){
final _that = this;
switch (_that) {
case ProposedTask() when proposed != null:
return proposed(_that);case ApprovedTask() when approved != null:
return approved(_that);case ExecutingTask() when executing != null:
return executing(_that);case CompletedTask() when completed != null:
return completed(_that);case FailedTask() when failed != null:
return failed(_that);case RejectedTask() when rejected != null:
return rejected(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( ProposedTask value)  proposed,required TResult Function( ApprovedTask value)  approved,required TResult Function( ExecutingTask value)  executing,required TResult Function( CompletedTask value)  completed,required TResult Function( FailedTask value)  failed,required TResult Function( RejectedTask value)  rejected,}){
final _that = this;
switch (_that) {
case ProposedTask():
return proposed(_that);case ApprovedTask():
return approved(_that);case ExecutingTask():
return executing(_that);case CompletedTask():
return completed(_that);case FailedTask():
return failed(_that);case RejectedTask():
return rejected(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( ProposedTask value)?  proposed,TResult? Function( ApprovedTask value)?  approved,TResult? Function( ExecutingTask value)?  executing,TResult? Function( CompletedTask value)?  completed,TResult? Function( FailedTask value)?  failed,TResult? Function( RejectedTask value)?  rejected,}){
final _that = this;
switch (_that) {
case ProposedTask() when proposed != null:
return proposed(_that);case ApprovedTask() when approved != null:
return approved(_that);case ExecutingTask() when executing != null:
return executing(_that);case CompletedTask() when completed != null:
return completed(_that);case FailedTask() when failed != null:
return failed(_that);case RejectedTask() when rejected != null:
return rejected(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function( String id,  String description,  VesselType targetVessel,  String toolName,  Map<String, dynamic> toolArgs,  DateTime proposedAt,  String? sessionKey,  TrustTier tier)?  proposed,TResult Function( String id,  String description,  VesselType targetVessel,  String toolName,  Map<String, dynamic> toolArgs,  DateTime approvedAt,  String? sessionKey,  TrustTier tier)?  approved,TResult Function( String id,  String description,  VesselType targetVessel,  double progress,  String currentStep,  DateTime startedAt,  String? sessionKey,  TrustTier tier)?  executing,TResult Function( String id,  String description,  VesselType targetVessel,  VesselResult result,  DateTime completedAt,  Duration duration,  TrustTier tier)?  completed,TResult Function( String id,  String description,  VesselType targetVessel,  String error,  DateTime failedAt,  TrustTier tier)?  failed,TResult Function( String id,  String description,  VesselType targetVessel,  DateTime rejectedAt,  TrustTier tier)?  rejected,required TResult orElse(),}) {final _that = this;
switch (_that) {
case ProposedTask() when proposed != null:
return proposed(_that.id,_that.description,_that.targetVessel,_that.toolName,_that.toolArgs,_that.proposedAt,_that.sessionKey,_that.tier);case ApprovedTask() when approved != null:
return approved(_that.id,_that.description,_that.targetVessel,_that.toolName,_that.toolArgs,_that.approvedAt,_that.sessionKey,_that.tier);case ExecutingTask() when executing != null:
return executing(_that.id,_that.description,_that.targetVessel,_that.progress,_that.currentStep,_that.startedAt,_that.sessionKey,_that.tier);case CompletedTask() when completed != null:
return completed(_that.id,_that.description,_that.targetVessel,_that.result,_that.completedAt,_that.duration,_that.tier);case FailedTask() when failed != null:
return failed(_that.id,_that.description,_that.targetVessel,_that.error,_that.failedAt,_that.tier);case RejectedTask() when rejected != null:
return rejected(_that.id,_that.description,_that.targetVessel,_that.rejectedAt,_that.tier);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function( String id,  String description,  VesselType targetVessel,  String toolName,  Map<String, dynamic> toolArgs,  DateTime proposedAt,  String? sessionKey,  TrustTier tier)  proposed,required TResult Function( String id,  String description,  VesselType targetVessel,  String toolName,  Map<String, dynamic> toolArgs,  DateTime approvedAt,  String? sessionKey,  TrustTier tier)  approved,required TResult Function( String id,  String description,  VesselType targetVessel,  double progress,  String currentStep,  DateTime startedAt,  String? sessionKey,  TrustTier tier)  executing,required TResult Function( String id,  String description,  VesselType targetVessel,  VesselResult result,  DateTime completedAt,  Duration duration,  TrustTier tier)  completed,required TResult Function( String id,  String description,  VesselType targetVessel,  String error,  DateTime failedAt,  TrustTier tier)  failed,required TResult Function( String id,  String description,  VesselType targetVessel,  DateTime rejectedAt,  TrustTier tier)  rejected,}) {final _that = this;
switch (_that) {
case ProposedTask():
return proposed(_that.id,_that.description,_that.targetVessel,_that.toolName,_that.toolArgs,_that.proposedAt,_that.sessionKey,_that.tier);case ApprovedTask():
return approved(_that.id,_that.description,_that.targetVessel,_that.toolName,_that.toolArgs,_that.approvedAt,_that.sessionKey,_that.tier);case ExecutingTask():
return executing(_that.id,_that.description,_that.targetVessel,_that.progress,_that.currentStep,_that.startedAt,_that.sessionKey,_that.tier);case CompletedTask():
return completed(_that.id,_that.description,_that.targetVessel,_that.result,_that.completedAt,_that.duration,_that.tier);case FailedTask():
return failed(_that.id,_that.description,_that.targetVessel,_that.error,_that.failedAt,_that.tier);case RejectedTask():
return rejected(_that.id,_that.description,_that.targetVessel,_that.rejectedAt,_that.tier);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function( String id,  String description,  VesselType targetVessel,  String toolName,  Map<String, dynamic> toolArgs,  DateTime proposedAt,  String? sessionKey,  TrustTier tier)?  proposed,TResult? Function( String id,  String description,  VesselType targetVessel,  String toolName,  Map<String, dynamic> toolArgs,  DateTime approvedAt,  String? sessionKey,  TrustTier tier)?  approved,TResult? Function( String id,  String description,  VesselType targetVessel,  double progress,  String currentStep,  DateTime startedAt,  String? sessionKey,  TrustTier tier)?  executing,TResult? Function( String id,  String description,  VesselType targetVessel,  VesselResult result,  DateTime completedAt,  Duration duration,  TrustTier tier)?  completed,TResult? Function( String id,  String description,  VesselType targetVessel,  String error,  DateTime failedAt,  TrustTier tier)?  failed,TResult? Function( String id,  String description,  VesselType targetVessel,  DateTime rejectedAt,  TrustTier tier)?  rejected,}) {final _that = this;
switch (_that) {
case ProposedTask() when proposed != null:
return proposed(_that.id,_that.description,_that.targetVessel,_that.toolName,_that.toolArgs,_that.proposedAt,_that.sessionKey,_that.tier);case ApprovedTask() when approved != null:
return approved(_that.id,_that.description,_that.targetVessel,_that.toolName,_that.toolArgs,_that.approvedAt,_that.sessionKey,_that.tier);case ExecutingTask() when executing != null:
return executing(_that.id,_that.description,_that.targetVessel,_that.progress,_that.currentStep,_that.startedAt,_that.sessionKey,_that.tier);case CompletedTask() when completed != null:
return completed(_that.id,_that.description,_that.targetVessel,_that.result,_that.completedAt,_that.duration,_that.tier);case FailedTask() when failed != null:
return failed(_that.id,_that.description,_that.targetVessel,_that.error,_that.failedAt,_that.tier);case RejectedTask() when rejected != null:
return rejected(_that.id,_that.description,_that.targetVessel,_that.rejectedAt,_that.tier);case _:
  return null;

}
}

}

/// @nodoc


class ProposedTask implements VesselTask {
  const ProposedTask({required this.id, required this.description, required this.targetVessel, required this.toolName, required final  Map<String, dynamic> toolArgs, required this.proposedAt, this.sessionKey, this.tier = TrustTier.hardApproval}): _toolArgs = toolArgs;
  

@override final  String id;
@override final  String description;
@override final  VesselType targetVessel;
 final  String toolName;
 final  Map<String, dynamic> _toolArgs;
 Map<String, dynamic> get toolArgs {
  if (_toolArgs is EqualUnmodifiableMapView) return _toolArgs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_toolArgs);
}

 final  DateTime proposedAt;
 final  String? sessionKey;
@override@JsonKey() final  TrustTier tier;

/// Create a copy of VesselTask
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProposedTaskCopyWith<ProposedTask> get copyWith => _$ProposedTaskCopyWithImpl<ProposedTask>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProposedTask&&(identical(other.id, id) || other.id == id)&&(identical(other.description, description) || other.description == description)&&(identical(other.targetVessel, targetVessel) || other.targetVessel == targetVessel)&&(identical(other.toolName, toolName) || other.toolName == toolName)&&const DeepCollectionEquality().equals(other._toolArgs, _toolArgs)&&(identical(other.proposedAt, proposedAt) || other.proposedAt == proposedAt)&&(identical(other.sessionKey, sessionKey) || other.sessionKey == sessionKey)&&(identical(other.tier, tier) || other.tier == tier));
}


@override
int get hashCode => Object.hash(runtimeType,id,description,targetVessel,toolName,const DeepCollectionEquality().hash(_toolArgs),proposedAt,sessionKey,tier);

@override
String toString() {
  return 'VesselTask.proposed(id: $id, description: $description, targetVessel: $targetVessel, toolName: $toolName, toolArgs: $toolArgs, proposedAt: $proposedAt, sessionKey: $sessionKey, tier: $tier)';
}


}

/// @nodoc
abstract mixin class $ProposedTaskCopyWith<$Res> implements $VesselTaskCopyWith<$Res> {
  factory $ProposedTaskCopyWith(ProposedTask value, $Res Function(ProposedTask) _then) = _$ProposedTaskCopyWithImpl;
@override @useResult
$Res call({
 String id, String description, VesselType targetVessel, String toolName, Map<String, dynamic> toolArgs, DateTime proposedAt, String? sessionKey, TrustTier tier
});




}
/// @nodoc
class _$ProposedTaskCopyWithImpl<$Res>
    implements $ProposedTaskCopyWith<$Res> {
  _$ProposedTaskCopyWithImpl(this._self, this._then);

  final ProposedTask _self;
  final $Res Function(ProposedTask) _then;

/// Create a copy of VesselTask
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? description = null,Object? targetVessel = null,Object? toolName = null,Object? toolArgs = null,Object? proposedAt = null,Object? sessionKey = freezed,Object? tier = null,}) {
  return _then(ProposedTask(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,targetVessel: null == targetVessel ? _self.targetVessel : targetVessel // ignore: cast_nullable_to_non_nullable
as VesselType,toolName: null == toolName ? _self.toolName : toolName // ignore: cast_nullable_to_non_nullable
as String,toolArgs: null == toolArgs ? _self._toolArgs : toolArgs // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,proposedAt: null == proposedAt ? _self.proposedAt : proposedAt // ignore: cast_nullable_to_non_nullable
as DateTime,sessionKey: freezed == sessionKey ? _self.sessionKey : sessionKey // ignore: cast_nullable_to_non_nullable
as String?,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as TrustTier,
  ));
}


}

/// @nodoc


class ApprovedTask implements VesselTask {
  const ApprovedTask({required this.id, required this.description, required this.targetVessel, required this.toolName, required final  Map<String, dynamic> toolArgs, required this.approvedAt, this.sessionKey, this.tier = TrustTier.hardApproval}): _toolArgs = toolArgs;
  

@override final  String id;
@override final  String description;
@override final  VesselType targetVessel;
 final  String toolName;
 final  Map<String, dynamic> _toolArgs;
 Map<String, dynamic> get toolArgs {
  if (_toolArgs is EqualUnmodifiableMapView) return _toolArgs;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_toolArgs);
}

 final  DateTime approvedAt;
 final  String? sessionKey;
@override@JsonKey() final  TrustTier tier;

/// Create a copy of VesselTask
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ApprovedTaskCopyWith<ApprovedTask> get copyWith => _$ApprovedTaskCopyWithImpl<ApprovedTask>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ApprovedTask&&(identical(other.id, id) || other.id == id)&&(identical(other.description, description) || other.description == description)&&(identical(other.targetVessel, targetVessel) || other.targetVessel == targetVessel)&&(identical(other.toolName, toolName) || other.toolName == toolName)&&const DeepCollectionEquality().equals(other._toolArgs, _toolArgs)&&(identical(other.approvedAt, approvedAt) || other.approvedAt == approvedAt)&&(identical(other.sessionKey, sessionKey) || other.sessionKey == sessionKey)&&(identical(other.tier, tier) || other.tier == tier));
}


@override
int get hashCode => Object.hash(runtimeType,id,description,targetVessel,toolName,const DeepCollectionEquality().hash(_toolArgs),approvedAt,sessionKey,tier);

@override
String toString() {
  return 'VesselTask.approved(id: $id, description: $description, targetVessel: $targetVessel, toolName: $toolName, toolArgs: $toolArgs, approvedAt: $approvedAt, sessionKey: $sessionKey, tier: $tier)';
}


}

/// @nodoc
abstract mixin class $ApprovedTaskCopyWith<$Res> implements $VesselTaskCopyWith<$Res> {
  factory $ApprovedTaskCopyWith(ApprovedTask value, $Res Function(ApprovedTask) _then) = _$ApprovedTaskCopyWithImpl;
@override @useResult
$Res call({
 String id, String description, VesselType targetVessel, String toolName, Map<String, dynamic> toolArgs, DateTime approvedAt, String? sessionKey, TrustTier tier
});




}
/// @nodoc
class _$ApprovedTaskCopyWithImpl<$Res>
    implements $ApprovedTaskCopyWith<$Res> {
  _$ApprovedTaskCopyWithImpl(this._self, this._then);

  final ApprovedTask _self;
  final $Res Function(ApprovedTask) _then;

/// Create a copy of VesselTask
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? description = null,Object? targetVessel = null,Object? toolName = null,Object? toolArgs = null,Object? approvedAt = null,Object? sessionKey = freezed,Object? tier = null,}) {
  return _then(ApprovedTask(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,targetVessel: null == targetVessel ? _self.targetVessel : targetVessel // ignore: cast_nullable_to_non_nullable
as VesselType,toolName: null == toolName ? _self.toolName : toolName // ignore: cast_nullable_to_non_nullable
as String,toolArgs: null == toolArgs ? _self._toolArgs : toolArgs // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,approvedAt: null == approvedAt ? _self.approvedAt : approvedAt // ignore: cast_nullable_to_non_nullable
as DateTime,sessionKey: freezed == sessionKey ? _self.sessionKey : sessionKey // ignore: cast_nullable_to_non_nullable
as String?,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as TrustTier,
  ));
}


}

/// @nodoc


class ExecutingTask implements VesselTask {
  const ExecutingTask({required this.id, required this.description, required this.targetVessel, required this.progress, required this.currentStep, required this.startedAt, this.sessionKey, this.tier = TrustTier.hardApproval});
  

@override final  String id;
@override final  String description;
@override final  VesselType targetVessel;
 final  double progress;
 final  String currentStep;
 final  DateTime startedAt;
 final  String? sessionKey;
@override@JsonKey() final  TrustTier tier;

/// Create a copy of VesselTask
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExecutingTaskCopyWith<ExecutingTask> get copyWith => _$ExecutingTaskCopyWithImpl<ExecutingTask>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExecutingTask&&(identical(other.id, id) || other.id == id)&&(identical(other.description, description) || other.description == description)&&(identical(other.targetVessel, targetVessel) || other.targetVessel == targetVessel)&&(identical(other.progress, progress) || other.progress == progress)&&(identical(other.currentStep, currentStep) || other.currentStep == currentStep)&&(identical(other.startedAt, startedAt) || other.startedAt == startedAt)&&(identical(other.sessionKey, sessionKey) || other.sessionKey == sessionKey)&&(identical(other.tier, tier) || other.tier == tier));
}


@override
int get hashCode => Object.hash(runtimeType,id,description,targetVessel,progress,currentStep,startedAt,sessionKey,tier);

@override
String toString() {
  return 'VesselTask.executing(id: $id, description: $description, targetVessel: $targetVessel, progress: $progress, currentStep: $currentStep, startedAt: $startedAt, sessionKey: $sessionKey, tier: $tier)';
}


}

/// @nodoc
abstract mixin class $ExecutingTaskCopyWith<$Res> implements $VesselTaskCopyWith<$Res> {
  factory $ExecutingTaskCopyWith(ExecutingTask value, $Res Function(ExecutingTask) _then) = _$ExecutingTaskCopyWithImpl;
@override @useResult
$Res call({
 String id, String description, VesselType targetVessel, double progress, String currentStep, DateTime startedAt, String? sessionKey, TrustTier tier
});




}
/// @nodoc
class _$ExecutingTaskCopyWithImpl<$Res>
    implements $ExecutingTaskCopyWith<$Res> {
  _$ExecutingTaskCopyWithImpl(this._self, this._then);

  final ExecutingTask _self;
  final $Res Function(ExecutingTask) _then;

/// Create a copy of VesselTask
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? description = null,Object? targetVessel = null,Object? progress = null,Object? currentStep = null,Object? startedAt = null,Object? sessionKey = freezed,Object? tier = null,}) {
  return _then(ExecutingTask(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,targetVessel: null == targetVessel ? _self.targetVessel : targetVessel // ignore: cast_nullable_to_non_nullable
as VesselType,progress: null == progress ? _self.progress : progress // ignore: cast_nullable_to_non_nullable
as double,currentStep: null == currentStep ? _self.currentStep : currentStep // ignore: cast_nullable_to_non_nullable
as String,startedAt: null == startedAt ? _self.startedAt : startedAt // ignore: cast_nullable_to_non_nullable
as DateTime,sessionKey: freezed == sessionKey ? _self.sessionKey : sessionKey // ignore: cast_nullable_to_non_nullable
as String?,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as TrustTier,
  ));
}


}

/// @nodoc


class CompletedTask implements VesselTask {
  const CompletedTask({required this.id, required this.description, required this.targetVessel, required this.result, required this.completedAt, required this.duration, this.tier = TrustTier.hardApproval});
  

@override final  String id;
@override final  String description;
@override final  VesselType targetVessel;
 final  VesselResult result;
 final  DateTime completedAt;
 final  Duration duration;
@override@JsonKey() final  TrustTier tier;

/// Create a copy of VesselTask
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CompletedTaskCopyWith<CompletedTask> get copyWith => _$CompletedTaskCopyWithImpl<CompletedTask>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CompletedTask&&(identical(other.id, id) || other.id == id)&&(identical(other.description, description) || other.description == description)&&(identical(other.targetVessel, targetVessel) || other.targetVessel == targetVessel)&&(identical(other.result, result) || other.result == result)&&(identical(other.completedAt, completedAt) || other.completedAt == completedAt)&&(identical(other.duration, duration) || other.duration == duration)&&(identical(other.tier, tier) || other.tier == tier));
}


@override
int get hashCode => Object.hash(runtimeType,id,description,targetVessel,result,completedAt,duration,tier);

@override
String toString() {
  return 'VesselTask.completed(id: $id, description: $description, targetVessel: $targetVessel, result: $result, completedAt: $completedAt, duration: $duration, tier: $tier)';
}


}

/// @nodoc
abstract mixin class $CompletedTaskCopyWith<$Res> implements $VesselTaskCopyWith<$Res> {
  factory $CompletedTaskCopyWith(CompletedTask value, $Res Function(CompletedTask) _then) = _$CompletedTaskCopyWithImpl;
@override @useResult
$Res call({
 String id, String description, VesselType targetVessel, VesselResult result, DateTime completedAt, Duration duration, TrustTier tier
});


$VesselResultCopyWith<$Res> get result;

}
/// @nodoc
class _$CompletedTaskCopyWithImpl<$Res>
    implements $CompletedTaskCopyWith<$Res> {
  _$CompletedTaskCopyWithImpl(this._self, this._then);

  final CompletedTask _self;
  final $Res Function(CompletedTask) _then;

/// Create a copy of VesselTask
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? description = null,Object? targetVessel = null,Object? result = null,Object? completedAt = null,Object? duration = null,Object? tier = null,}) {
  return _then(CompletedTask(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,targetVessel: null == targetVessel ? _self.targetVessel : targetVessel // ignore: cast_nullable_to_non_nullable
as VesselType,result: null == result ? _self.result : result // ignore: cast_nullable_to_non_nullable
as VesselResult,completedAt: null == completedAt ? _self.completedAt : completedAt // ignore: cast_nullable_to_non_nullable
as DateTime,duration: null == duration ? _self.duration : duration // ignore: cast_nullable_to_non_nullable
as Duration,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as TrustTier,
  ));
}

/// Create a copy of VesselTask
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$VesselResultCopyWith<$Res> get result {
  
  return $VesselResultCopyWith<$Res>(_self.result, (value) {
    return _then(_self.copyWith(result: value));
  });
}
}

/// @nodoc


class FailedTask implements VesselTask {
  const FailedTask({required this.id, required this.description, required this.targetVessel, required this.error, required this.failedAt, this.tier = TrustTier.hardApproval});
  

@override final  String id;
@override final  String description;
@override final  VesselType targetVessel;
 final  String error;
 final  DateTime failedAt;
@override@JsonKey() final  TrustTier tier;

/// Create a copy of VesselTask
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FailedTaskCopyWith<FailedTask> get copyWith => _$FailedTaskCopyWithImpl<FailedTask>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FailedTask&&(identical(other.id, id) || other.id == id)&&(identical(other.description, description) || other.description == description)&&(identical(other.targetVessel, targetVessel) || other.targetVessel == targetVessel)&&(identical(other.error, error) || other.error == error)&&(identical(other.failedAt, failedAt) || other.failedAt == failedAt)&&(identical(other.tier, tier) || other.tier == tier));
}


@override
int get hashCode => Object.hash(runtimeType,id,description,targetVessel,error,failedAt,tier);

@override
String toString() {
  return 'VesselTask.failed(id: $id, description: $description, targetVessel: $targetVessel, error: $error, failedAt: $failedAt, tier: $tier)';
}


}

/// @nodoc
abstract mixin class $FailedTaskCopyWith<$Res> implements $VesselTaskCopyWith<$Res> {
  factory $FailedTaskCopyWith(FailedTask value, $Res Function(FailedTask) _then) = _$FailedTaskCopyWithImpl;
@override @useResult
$Res call({
 String id, String description, VesselType targetVessel, String error, DateTime failedAt, TrustTier tier
});




}
/// @nodoc
class _$FailedTaskCopyWithImpl<$Res>
    implements $FailedTaskCopyWith<$Res> {
  _$FailedTaskCopyWithImpl(this._self, this._then);

  final FailedTask _self;
  final $Res Function(FailedTask) _then;

/// Create a copy of VesselTask
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? description = null,Object? targetVessel = null,Object? error = null,Object? failedAt = null,Object? tier = null,}) {
  return _then(FailedTask(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,targetVessel: null == targetVessel ? _self.targetVessel : targetVessel // ignore: cast_nullable_to_non_nullable
as VesselType,error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,failedAt: null == failedAt ? _self.failedAt : failedAt // ignore: cast_nullable_to_non_nullable
as DateTime,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as TrustTier,
  ));
}


}

/// @nodoc


class RejectedTask implements VesselTask {
  const RejectedTask({required this.id, required this.description, required this.targetVessel, required this.rejectedAt, this.tier = TrustTier.hardApproval});
  

@override final  String id;
@override final  String description;
@override final  VesselType targetVessel;
 final  DateTime rejectedAt;
@override@JsonKey() final  TrustTier tier;

/// Create a copy of VesselTask
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RejectedTaskCopyWith<RejectedTask> get copyWith => _$RejectedTaskCopyWithImpl<RejectedTask>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RejectedTask&&(identical(other.id, id) || other.id == id)&&(identical(other.description, description) || other.description == description)&&(identical(other.targetVessel, targetVessel) || other.targetVessel == targetVessel)&&(identical(other.rejectedAt, rejectedAt) || other.rejectedAt == rejectedAt)&&(identical(other.tier, tier) || other.tier == tier));
}


@override
int get hashCode => Object.hash(runtimeType,id,description,targetVessel,rejectedAt,tier);

@override
String toString() {
  return 'VesselTask.rejected(id: $id, description: $description, targetVessel: $targetVessel, rejectedAt: $rejectedAt, tier: $tier)';
}


}

/// @nodoc
abstract mixin class $RejectedTaskCopyWith<$Res> implements $VesselTaskCopyWith<$Res> {
  factory $RejectedTaskCopyWith(RejectedTask value, $Res Function(RejectedTask) _then) = _$RejectedTaskCopyWithImpl;
@override @useResult
$Res call({
 String id, String description, VesselType targetVessel, DateTime rejectedAt, TrustTier tier
});




}
/// @nodoc
class _$RejectedTaskCopyWithImpl<$Res>
    implements $RejectedTaskCopyWith<$Res> {
  _$RejectedTaskCopyWithImpl(this._self, this._then);

  final RejectedTask _self;
  final $Res Function(RejectedTask) _then;

/// Create a copy of VesselTask
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? description = null,Object? targetVessel = null,Object? rejectedAt = null,Object? tier = null,}) {
  return _then(RejectedTask(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,targetVessel: null == targetVessel ? _self.targetVessel : targetVessel // ignore: cast_nullable_to_non_nullable
as VesselType,rejectedAt: null == rejectedAt ? _self.rejectedAt : rejectedAt // ignore: cast_nullable_to_non_nullable
as DateTime,tier: null == tier ? _self.tier : tier // ignore: cast_nullable_to_non_nullable
as TrustTier,
  ));
}


}

// dart format on
