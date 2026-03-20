// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'project.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Project {

 String get id; String get name; String? get description; List<String>? get techStack; List<String>? get goals; DateTime? get deadline; String? get repoUrl; String get status; DateTime get onboardedAt; DateTime get updatedAt;
/// Create a copy of Project
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectCopyWith<Project> get copyWith => _$ProjectCopyWithImpl<Project>(this as Project, _$identity);

  /// Serializes this Project to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Project&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other.techStack, techStack)&&const DeepCollectionEquality().equals(other.goals, goals)&&(identical(other.deadline, deadline) || other.deadline == deadline)&&(identical(other.repoUrl, repoUrl) || other.repoUrl == repoUrl)&&(identical(other.status, status) || other.status == status)&&(identical(other.onboardedAt, onboardedAt) || other.onboardedAt == onboardedAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,const DeepCollectionEquality().hash(techStack),const DeepCollectionEquality().hash(goals),deadline,repoUrl,status,onboardedAt,updatedAt);

@override
String toString() {
  return 'Project(id: $id, name: $name, description: $description, techStack: $techStack, goals: $goals, deadline: $deadline, repoUrl: $repoUrl, status: $status, onboardedAt: $onboardedAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ProjectCopyWith<$Res>  {
  factory $ProjectCopyWith(Project value, $Res Function(Project) _then) = _$ProjectCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? description, List<String>? techStack, List<String>? goals, DateTime? deadline, String? repoUrl, String status, DateTime onboardedAt, DateTime updatedAt
});




}
/// @nodoc
class _$ProjectCopyWithImpl<$Res>
    implements $ProjectCopyWith<$Res> {
  _$ProjectCopyWithImpl(this._self, this._then);

  final Project _self;
  final $Res Function(Project) _then;

/// Create a copy of Project
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? techStack = freezed,Object? goals = freezed,Object? deadline = freezed,Object? repoUrl = freezed,Object? status = null,Object? onboardedAt = null,Object? updatedAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,techStack: freezed == techStack ? _self.techStack : techStack // ignore: cast_nullable_to_non_nullable
as List<String>?,goals: freezed == goals ? _self.goals : goals // ignore: cast_nullable_to_non_nullable
as List<String>?,deadline: freezed == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as DateTime?,repoUrl: freezed == repoUrl ? _self.repoUrl : repoUrl // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,onboardedAt: null == onboardedAt ? _self.onboardedAt : onboardedAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [Project].
extension ProjectPatterns on Project {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Project value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Project() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Project value)  $default,){
final _that = this;
switch (_that) {
case _Project():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Project value)?  $default,){
final _that = this;
switch (_that) {
case _Project() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  List<String>? techStack,  List<String>? goals,  DateTime? deadline,  String? repoUrl,  String status,  DateTime onboardedAt,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Project() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.techStack,_that.goals,_that.deadline,_that.repoUrl,_that.status,_that.onboardedAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? description,  List<String>? techStack,  List<String>? goals,  DateTime? deadline,  String? repoUrl,  String status,  DateTime onboardedAt,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Project():
return $default(_that.id,_that.name,_that.description,_that.techStack,_that.goals,_that.deadline,_that.repoUrl,_that.status,_that.onboardedAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? description,  List<String>? techStack,  List<String>? goals,  DateTime? deadline,  String? repoUrl,  String status,  DateTime onboardedAt,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Project() when $default != null:
return $default(_that.id,_that.name,_that.description,_that.techStack,_that.goals,_that.deadline,_that.repoUrl,_that.status,_that.onboardedAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Project implements Project {
  const _Project({required this.id, required this.name, this.description, final  List<String>? techStack, final  List<String>? goals, this.deadline, this.repoUrl, this.status = 'active', required this.onboardedAt, required this.updatedAt}): _techStack = techStack,_goals = goals;
  factory _Project.fromJson(Map<String, dynamic> json) => _$ProjectFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? description;
 final  List<String>? _techStack;
@override List<String>? get techStack {
  final value = _techStack;
  if (value == null) return null;
  if (_techStack is EqualUnmodifiableListView) return _techStack;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

 final  List<String>? _goals;
@override List<String>? get goals {
  final value = _goals;
  if (value == null) return null;
  if (_goals is EqualUnmodifiableListView) return _goals;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override final  DateTime? deadline;
@override final  String? repoUrl;
@override@JsonKey() final  String status;
@override final  DateTime onboardedAt;
@override final  DateTime updatedAt;

/// Create a copy of Project
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProjectCopyWith<_Project> get copyWith => __$ProjectCopyWithImpl<_Project>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProjectToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Project&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&const DeepCollectionEquality().equals(other._techStack, _techStack)&&const DeepCollectionEquality().equals(other._goals, _goals)&&(identical(other.deadline, deadline) || other.deadline == deadline)&&(identical(other.repoUrl, repoUrl) || other.repoUrl == repoUrl)&&(identical(other.status, status) || other.status == status)&&(identical(other.onboardedAt, onboardedAt) || other.onboardedAt == onboardedAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,description,const DeepCollectionEquality().hash(_techStack),const DeepCollectionEquality().hash(_goals),deadline,repoUrl,status,onboardedAt,updatedAt);

@override
String toString() {
  return 'Project(id: $id, name: $name, description: $description, techStack: $techStack, goals: $goals, deadline: $deadline, repoUrl: $repoUrl, status: $status, onboardedAt: $onboardedAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ProjectCopyWith<$Res> implements $ProjectCopyWith<$Res> {
  factory _$ProjectCopyWith(_Project value, $Res Function(_Project) _then) = __$ProjectCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? description, List<String>? techStack, List<String>? goals, DateTime? deadline, String? repoUrl, String status, DateTime onboardedAt, DateTime updatedAt
});




}
/// @nodoc
class __$ProjectCopyWithImpl<$Res>
    implements _$ProjectCopyWith<$Res> {
  __$ProjectCopyWithImpl(this._self, this._then);

  final _Project _self;
  final $Res Function(_Project) _then;

/// Create a copy of Project
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? description = freezed,Object? techStack = freezed,Object? goals = freezed,Object? deadline = freezed,Object? repoUrl = freezed,Object? status = null,Object? onboardedAt = null,Object? updatedAt = null,}) {
  return _then(_Project(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,techStack: freezed == techStack ? _self._techStack : techStack // ignore: cast_nullable_to_non_nullable
as List<String>?,goals: freezed == goals ? _self._goals : goals // ignore: cast_nullable_to_non_nullable
as List<String>?,deadline: freezed == deadline ? _self.deadline : deadline // ignore: cast_nullable_to_non_nullable
as DateTime?,repoUrl: freezed == repoUrl ? _self.repoUrl : repoUrl // ignore: cast_nullable_to_non_nullable
as String?,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,onboardedAt: null == onboardedAt ? _self.onboardedAt : onboardedAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$ProjectFact {

 String get id; String get projectId; String get key; String get value; String? get sourceMessageId; DateTime get createdAt;
/// Create a copy of ProjectFact
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProjectFactCopyWith<ProjectFact> get copyWith => _$ProjectFactCopyWithImpl<ProjectFact>(this as ProjectFact, _$identity);

  /// Serializes this ProjectFact to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProjectFact&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.key, key) || other.key == key)&&(identical(other.value, value) || other.value == value)&&(identical(other.sourceMessageId, sourceMessageId) || other.sourceMessageId == sourceMessageId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,projectId,key,value,sourceMessageId,createdAt);

@override
String toString() {
  return 'ProjectFact(id: $id, projectId: $projectId, key: $key, value: $value, sourceMessageId: $sourceMessageId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ProjectFactCopyWith<$Res>  {
  factory $ProjectFactCopyWith(ProjectFact value, $Res Function(ProjectFact) _then) = _$ProjectFactCopyWithImpl;
@useResult
$Res call({
 String id, String projectId, String key, String value, String? sourceMessageId, DateTime createdAt
});




}
/// @nodoc
class _$ProjectFactCopyWithImpl<$Res>
    implements $ProjectFactCopyWith<$Res> {
  _$ProjectFactCopyWithImpl(this._self, this._then);

  final ProjectFact _self;
  final $Res Function(ProjectFact) _then;

/// Create a copy of ProjectFact
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? projectId = null,Object? key = null,Object? value = null,Object? sourceMessageId = freezed,Object? createdAt = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,sourceMessageId: freezed == sourceMessageId ? _self.sourceMessageId : sourceMessageId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ProjectFact].
extension ProjectFactPatterns on ProjectFact {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProjectFact value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProjectFact() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProjectFact value)  $default,){
final _that = this;
switch (_that) {
case _ProjectFact():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProjectFact value)?  $default,){
final _that = this;
switch (_that) {
case _ProjectFact() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String projectId,  String key,  String value,  String? sourceMessageId,  DateTime createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProjectFact() when $default != null:
return $default(_that.id,_that.projectId,_that.key,_that.value,_that.sourceMessageId,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String projectId,  String key,  String value,  String? sourceMessageId,  DateTime createdAt)  $default,) {final _that = this;
switch (_that) {
case _ProjectFact():
return $default(_that.id,_that.projectId,_that.key,_that.value,_that.sourceMessageId,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String projectId,  String key,  String value,  String? sourceMessageId,  DateTime createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ProjectFact() when $default != null:
return $default(_that.id,_that.projectId,_that.key,_that.value,_that.sourceMessageId,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProjectFact implements ProjectFact {
  const _ProjectFact({required this.id, required this.projectId, required this.key, required this.value, this.sourceMessageId, required this.createdAt});
  factory _ProjectFact.fromJson(Map<String, dynamic> json) => _$ProjectFactFromJson(json);

@override final  String id;
@override final  String projectId;
@override final  String key;
@override final  String value;
@override final  String? sourceMessageId;
@override final  DateTime createdAt;

/// Create a copy of ProjectFact
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProjectFactCopyWith<_ProjectFact> get copyWith => __$ProjectFactCopyWithImpl<_ProjectFact>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProjectFactToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProjectFact&&(identical(other.id, id) || other.id == id)&&(identical(other.projectId, projectId) || other.projectId == projectId)&&(identical(other.key, key) || other.key == key)&&(identical(other.value, value) || other.value == value)&&(identical(other.sourceMessageId, sourceMessageId) || other.sourceMessageId == sourceMessageId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,projectId,key,value,sourceMessageId,createdAt);

@override
String toString() {
  return 'ProjectFact(id: $id, projectId: $projectId, key: $key, value: $value, sourceMessageId: $sourceMessageId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ProjectFactCopyWith<$Res> implements $ProjectFactCopyWith<$Res> {
  factory _$ProjectFactCopyWith(_ProjectFact value, $Res Function(_ProjectFact) _then) = __$ProjectFactCopyWithImpl;
@override @useResult
$Res call({
 String id, String projectId, String key, String value, String? sourceMessageId, DateTime createdAt
});




}
/// @nodoc
class __$ProjectFactCopyWithImpl<$Res>
    implements _$ProjectFactCopyWith<$Res> {
  __$ProjectFactCopyWithImpl(this._self, this._then);

  final _ProjectFact _self;
  final $Res Function(_ProjectFact) _then;

/// Create a copy of ProjectFact
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? projectId = null,Object? key = null,Object? value = null,Object? sourceMessageId = freezed,Object? createdAt = null,}) {
  return _then(_ProjectFact(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,projectId: null == projectId ? _self.projectId : projectId // ignore: cast_nullable_to_non_nullable
as String,key: null == key ? _self.key : key // ignore: cast_nullable_to_non_nullable
as String,value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,sourceMessageId: freezed == sourceMessageId ? _self.sourceMessageId : sourceMessageId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

// dart format on
