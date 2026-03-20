// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'prompt_context.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PromptContext {

 MemoryContext? get memory; String? get phoneContext; MoodState? get moodState; ProjectState? get projectState; List<OpenQuestion>? get openQuestions; String get detectedLanguage; DateTime? get firstInteractionDate; int get totalConversationCount; String get distilledFacts; String? get extractedProjectStatus; String? get extractedRiskiestItem; String? get extractedAssumptions; double? get momentumScore;
/// Create a copy of PromptContext
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PromptContextCopyWith<PromptContext> get copyWith => _$PromptContextCopyWithImpl<PromptContext>(this as PromptContext, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PromptContext&&(identical(other.memory, memory) || other.memory == memory)&&(identical(other.phoneContext, phoneContext) || other.phoneContext == phoneContext)&&(identical(other.moodState, moodState) || other.moodState == moodState)&&(identical(other.projectState, projectState) || other.projectState == projectState)&&const DeepCollectionEquality().equals(other.openQuestions, openQuestions)&&(identical(other.detectedLanguage, detectedLanguage) || other.detectedLanguage == detectedLanguage)&&(identical(other.firstInteractionDate, firstInteractionDate) || other.firstInteractionDate == firstInteractionDate)&&(identical(other.totalConversationCount, totalConversationCount) || other.totalConversationCount == totalConversationCount)&&(identical(other.distilledFacts, distilledFacts) || other.distilledFacts == distilledFacts)&&(identical(other.extractedProjectStatus, extractedProjectStatus) || other.extractedProjectStatus == extractedProjectStatus)&&(identical(other.extractedRiskiestItem, extractedRiskiestItem) || other.extractedRiskiestItem == extractedRiskiestItem)&&(identical(other.extractedAssumptions, extractedAssumptions) || other.extractedAssumptions == extractedAssumptions)&&(identical(other.momentumScore, momentumScore) || other.momentumScore == momentumScore));
}


@override
int get hashCode => Object.hash(runtimeType,memory,phoneContext,moodState,projectState,const DeepCollectionEquality().hash(openQuestions),detectedLanguage,firstInteractionDate,totalConversationCount,distilledFacts,extractedProjectStatus,extractedRiskiestItem,extractedAssumptions,momentumScore);

@override
String toString() {
  return 'PromptContext(memory: $memory, phoneContext: $phoneContext, moodState: $moodState, projectState: $projectState, openQuestions: $openQuestions, detectedLanguage: $detectedLanguage, firstInteractionDate: $firstInteractionDate, totalConversationCount: $totalConversationCount, distilledFacts: $distilledFacts, extractedProjectStatus: $extractedProjectStatus, extractedRiskiestItem: $extractedRiskiestItem, extractedAssumptions: $extractedAssumptions, momentumScore: $momentumScore)';
}


}

/// @nodoc
abstract mixin class $PromptContextCopyWith<$Res>  {
  factory $PromptContextCopyWith(PromptContext value, $Res Function(PromptContext) _then) = _$PromptContextCopyWithImpl;
@useResult
$Res call({
 MemoryContext? memory, String? phoneContext, MoodState? moodState, ProjectState? projectState, List<OpenQuestion>? openQuestions, String detectedLanguage, DateTime? firstInteractionDate, int totalConversationCount, String distilledFacts, String? extractedProjectStatus, String? extractedRiskiestItem, String? extractedAssumptions, double? momentumScore
});




}
/// @nodoc
class _$PromptContextCopyWithImpl<$Res>
    implements $PromptContextCopyWith<$Res> {
  _$PromptContextCopyWithImpl(this._self, this._then);

  final PromptContext _self;
  final $Res Function(PromptContext) _then;

/// Create a copy of PromptContext
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? memory = freezed,Object? phoneContext = freezed,Object? moodState = freezed,Object? projectState = freezed,Object? openQuestions = freezed,Object? detectedLanguage = null,Object? firstInteractionDate = freezed,Object? totalConversationCount = null,Object? distilledFacts = null,Object? extractedProjectStatus = freezed,Object? extractedRiskiestItem = freezed,Object? extractedAssumptions = freezed,Object? momentumScore = freezed,}) {
  return _then(_self.copyWith(
memory: freezed == memory ? _self.memory : memory // ignore: cast_nullable_to_non_nullable
as MemoryContext?,phoneContext: freezed == phoneContext ? _self.phoneContext : phoneContext // ignore: cast_nullable_to_non_nullable
as String?,moodState: freezed == moodState ? _self.moodState : moodState // ignore: cast_nullable_to_non_nullable
as MoodState?,projectState: freezed == projectState ? _self.projectState : projectState // ignore: cast_nullable_to_non_nullable
as ProjectState?,openQuestions: freezed == openQuestions ? _self.openQuestions : openQuestions // ignore: cast_nullable_to_non_nullable
as List<OpenQuestion>?,detectedLanguage: null == detectedLanguage ? _self.detectedLanguage : detectedLanguage // ignore: cast_nullable_to_non_nullable
as String,firstInteractionDate: freezed == firstInteractionDate ? _self.firstInteractionDate : firstInteractionDate // ignore: cast_nullable_to_non_nullable
as DateTime?,totalConversationCount: null == totalConversationCount ? _self.totalConversationCount : totalConversationCount // ignore: cast_nullable_to_non_nullable
as int,distilledFacts: null == distilledFacts ? _self.distilledFacts : distilledFacts // ignore: cast_nullable_to_non_nullable
as String,extractedProjectStatus: freezed == extractedProjectStatus ? _self.extractedProjectStatus : extractedProjectStatus // ignore: cast_nullable_to_non_nullable
as String?,extractedRiskiestItem: freezed == extractedRiskiestItem ? _self.extractedRiskiestItem : extractedRiskiestItem // ignore: cast_nullable_to_non_nullable
as String?,extractedAssumptions: freezed == extractedAssumptions ? _self.extractedAssumptions : extractedAssumptions // ignore: cast_nullable_to_non_nullable
as String?,momentumScore: freezed == momentumScore ? _self.momentumScore : momentumScore // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [PromptContext].
extension PromptContextPatterns on PromptContext {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PromptContext value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PromptContext() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PromptContext value)  $default,){
final _that = this;
switch (_that) {
case _PromptContext():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PromptContext value)?  $default,){
final _that = this;
switch (_that) {
case _PromptContext() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( MemoryContext? memory,  String? phoneContext,  MoodState? moodState,  ProjectState? projectState,  List<OpenQuestion>? openQuestions,  String detectedLanguage,  DateTime? firstInteractionDate,  int totalConversationCount,  String distilledFacts,  String? extractedProjectStatus,  String? extractedRiskiestItem,  String? extractedAssumptions,  double? momentumScore)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PromptContext() when $default != null:
return $default(_that.memory,_that.phoneContext,_that.moodState,_that.projectState,_that.openQuestions,_that.detectedLanguage,_that.firstInteractionDate,_that.totalConversationCount,_that.distilledFacts,_that.extractedProjectStatus,_that.extractedRiskiestItem,_that.extractedAssumptions,_that.momentumScore);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( MemoryContext? memory,  String? phoneContext,  MoodState? moodState,  ProjectState? projectState,  List<OpenQuestion>? openQuestions,  String detectedLanguage,  DateTime? firstInteractionDate,  int totalConversationCount,  String distilledFacts,  String? extractedProjectStatus,  String? extractedRiskiestItem,  String? extractedAssumptions,  double? momentumScore)  $default,) {final _that = this;
switch (_that) {
case _PromptContext():
return $default(_that.memory,_that.phoneContext,_that.moodState,_that.projectState,_that.openQuestions,_that.detectedLanguage,_that.firstInteractionDate,_that.totalConversationCount,_that.distilledFacts,_that.extractedProjectStatus,_that.extractedRiskiestItem,_that.extractedAssumptions,_that.momentumScore);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( MemoryContext? memory,  String? phoneContext,  MoodState? moodState,  ProjectState? projectState,  List<OpenQuestion>? openQuestions,  String detectedLanguage,  DateTime? firstInteractionDate,  int totalConversationCount,  String distilledFacts,  String? extractedProjectStatus,  String? extractedRiskiestItem,  String? extractedAssumptions,  double? momentumScore)?  $default,) {final _that = this;
switch (_that) {
case _PromptContext() when $default != null:
return $default(_that.memory,_that.phoneContext,_that.moodState,_that.projectState,_that.openQuestions,_that.detectedLanguage,_that.firstInteractionDate,_that.totalConversationCount,_that.distilledFacts,_that.extractedProjectStatus,_that.extractedRiskiestItem,_that.extractedAssumptions,_that.momentumScore);case _:
  return null;

}
}

}

/// @nodoc


class _PromptContext implements PromptContext {
  const _PromptContext({this.memory = null, this.phoneContext = null, this.moodState = null, this.projectState = null, final  List<OpenQuestion>? openQuestions = null, this.detectedLanguage = 'nl', this.firstInteractionDate = null, this.totalConversationCount = 0, this.distilledFacts = '', this.extractedProjectStatus = null, this.extractedRiskiestItem = null, this.extractedAssumptions = null, this.momentumScore = null}): _openQuestions = openQuestions;
  

@override@JsonKey() final  MemoryContext? memory;
@override@JsonKey() final  String? phoneContext;
@override@JsonKey() final  MoodState? moodState;
@override@JsonKey() final  ProjectState? projectState;
 final  List<OpenQuestion>? _openQuestions;
@override@JsonKey() List<OpenQuestion>? get openQuestions {
  final value = _openQuestions;
  if (value == null) return null;
  if (_openQuestions is EqualUnmodifiableListView) return _openQuestions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey() final  String detectedLanguage;
@override@JsonKey() final  DateTime? firstInteractionDate;
@override@JsonKey() final  int totalConversationCount;
@override@JsonKey() final  String distilledFacts;
@override@JsonKey() final  String? extractedProjectStatus;
@override@JsonKey() final  String? extractedRiskiestItem;
@override@JsonKey() final  String? extractedAssumptions;
@override@JsonKey() final  double? momentumScore;

/// Create a copy of PromptContext
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PromptContextCopyWith<_PromptContext> get copyWith => __$PromptContextCopyWithImpl<_PromptContext>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PromptContext&&(identical(other.memory, memory) || other.memory == memory)&&(identical(other.phoneContext, phoneContext) || other.phoneContext == phoneContext)&&(identical(other.moodState, moodState) || other.moodState == moodState)&&(identical(other.projectState, projectState) || other.projectState == projectState)&&const DeepCollectionEquality().equals(other._openQuestions, _openQuestions)&&(identical(other.detectedLanguage, detectedLanguage) || other.detectedLanguage == detectedLanguage)&&(identical(other.firstInteractionDate, firstInteractionDate) || other.firstInteractionDate == firstInteractionDate)&&(identical(other.totalConversationCount, totalConversationCount) || other.totalConversationCount == totalConversationCount)&&(identical(other.distilledFacts, distilledFacts) || other.distilledFacts == distilledFacts)&&(identical(other.extractedProjectStatus, extractedProjectStatus) || other.extractedProjectStatus == extractedProjectStatus)&&(identical(other.extractedRiskiestItem, extractedRiskiestItem) || other.extractedRiskiestItem == extractedRiskiestItem)&&(identical(other.extractedAssumptions, extractedAssumptions) || other.extractedAssumptions == extractedAssumptions)&&(identical(other.momentumScore, momentumScore) || other.momentumScore == momentumScore));
}


@override
int get hashCode => Object.hash(runtimeType,memory,phoneContext,moodState,projectState,const DeepCollectionEquality().hash(_openQuestions),detectedLanguage,firstInteractionDate,totalConversationCount,distilledFacts,extractedProjectStatus,extractedRiskiestItem,extractedAssumptions,momentumScore);

@override
String toString() {
  return 'PromptContext(memory: $memory, phoneContext: $phoneContext, moodState: $moodState, projectState: $projectState, openQuestions: $openQuestions, detectedLanguage: $detectedLanguage, firstInteractionDate: $firstInteractionDate, totalConversationCount: $totalConversationCount, distilledFacts: $distilledFacts, extractedProjectStatus: $extractedProjectStatus, extractedRiskiestItem: $extractedRiskiestItem, extractedAssumptions: $extractedAssumptions, momentumScore: $momentumScore)';
}


}

/// @nodoc
abstract mixin class _$PromptContextCopyWith<$Res> implements $PromptContextCopyWith<$Res> {
  factory _$PromptContextCopyWith(_PromptContext value, $Res Function(_PromptContext) _then) = __$PromptContextCopyWithImpl;
@override @useResult
$Res call({
 MemoryContext? memory, String? phoneContext, MoodState? moodState, ProjectState? projectState, List<OpenQuestion>? openQuestions, String detectedLanguage, DateTime? firstInteractionDate, int totalConversationCount, String distilledFacts, String? extractedProjectStatus, String? extractedRiskiestItem, String? extractedAssumptions, double? momentumScore
});




}
/// @nodoc
class __$PromptContextCopyWithImpl<$Res>
    implements _$PromptContextCopyWith<$Res> {
  __$PromptContextCopyWithImpl(this._self, this._then);

  final _PromptContext _self;
  final $Res Function(_PromptContext) _then;

/// Create a copy of PromptContext
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? memory = freezed,Object? phoneContext = freezed,Object? moodState = freezed,Object? projectState = freezed,Object? openQuestions = freezed,Object? detectedLanguage = null,Object? firstInteractionDate = freezed,Object? totalConversationCount = null,Object? distilledFacts = null,Object? extractedProjectStatus = freezed,Object? extractedRiskiestItem = freezed,Object? extractedAssumptions = freezed,Object? momentumScore = freezed,}) {
  return _then(_PromptContext(
memory: freezed == memory ? _self.memory : memory // ignore: cast_nullable_to_non_nullable
as MemoryContext?,phoneContext: freezed == phoneContext ? _self.phoneContext : phoneContext // ignore: cast_nullable_to_non_nullable
as String?,moodState: freezed == moodState ? _self.moodState : moodState // ignore: cast_nullable_to_non_nullable
as MoodState?,projectState: freezed == projectState ? _self.projectState : projectState // ignore: cast_nullable_to_non_nullable
as ProjectState?,openQuestions: freezed == openQuestions ? _self._openQuestions : openQuestions // ignore: cast_nullable_to_non_nullable
as List<OpenQuestion>?,detectedLanguage: null == detectedLanguage ? _self.detectedLanguage : detectedLanguage // ignore: cast_nullable_to_non_nullable
as String,firstInteractionDate: freezed == firstInteractionDate ? _self.firstInteractionDate : firstInteractionDate // ignore: cast_nullable_to_non_nullable
as DateTime?,totalConversationCount: null == totalConversationCount ? _self.totalConversationCount : totalConversationCount // ignore: cast_nullable_to_non_nullable
as int,distilledFacts: null == distilledFacts ? _self.distilledFacts : distilledFacts // ignore: cast_nullable_to_non_nullable
as String,extractedProjectStatus: freezed == extractedProjectStatus ? _self.extractedProjectStatus : extractedProjectStatus // ignore: cast_nullable_to_non_nullable
as String?,extractedRiskiestItem: freezed == extractedRiskiestItem ? _self.extractedRiskiestItem : extractedRiskiestItem // ignore: cast_nullable_to_non_nullable
as String?,extractedAssumptions: freezed == extractedAssumptions ? _self.extractedAssumptions : extractedAssumptions // ignore: cast_nullable_to_non_nullable
as String?,momentumScore: freezed == momentumScore ? _self.momentumScore : momentumScore // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on
