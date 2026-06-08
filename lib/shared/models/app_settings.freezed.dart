// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_settings.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppSettings {

 ThemeModeOption get themeMode; AiProviderType get preferredProvider; String get huggingFaceApiKey; String get openRouterApiKey; String get togetherApiKey; String get groqApiKey; bool get onboardingComplete;
/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppSettingsCopyWith<AppSettings> get copyWith => _$AppSettingsCopyWithImpl<AppSettings>(this as AppSettings, _$identity);

  /// Serializes this AppSettings to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppSettings&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.preferredProvider, preferredProvider) || other.preferredProvider == preferredProvider)&&(identical(other.huggingFaceApiKey, huggingFaceApiKey) || other.huggingFaceApiKey == huggingFaceApiKey)&&(identical(other.openRouterApiKey, openRouterApiKey) || other.openRouterApiKey == openRouterApiKey)&&(identical(other.togetherApiKey, togetherApiKey) || other.togetherApiKey == togetherApiKey)&&(identical(other.groqApiKey, groqApiKey) || other.groqApiKey == groqApiKey)&&(identical(other.onboardingComplete, onboardingComplete) || other.onboardingComplete == onboardingComplete));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,themeMode,preferredProvider,huggingFaceApiKey,openRouterApiKey,togetherApiKey,groqApiKey,onboardingComplete);

@override
String toString() {
  return 'AppSettings(themeMode: $themeMode, preferredProvider: $preferredProvider, huggingFaceApiKey: $huggingFaceApiKey, openRouterApiKey: $openRouterApiKey, togetherApiKey: $togetherApiKey, groqApiKey: $groqApiKey, onboardingComplete: $onboardingComplete)';
}


}

/// @nodoc
abstract mixin class $AppSettingsCopyWith<$Res>  {
  factory $AppSettingsCopyWith(AppSettings value, $Res Function(AppSettings) _then) = _$AppSettingsCopyWithImpl;
@useResult
$Res call({
 ThemeModeOption themeMode, AiProviderType preferredProvider, String huggingFaceApiKey, String openRouterApiKey, String togetherApiKey, String groqApiKey, bool onboardingComplete
});




}
/// @nodoc
class _$AppSettingsCopyWithImpl<$Res>
    implements $AppSettingsCopyWith<$Res> {
  _$AppSettingsCopyWithImpl(this._self, this._then);

  final AppSettings _self;
  final $Res Function(AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? themeMode = null,Object? preferredProvider = null,Object? huggingFaceApiKey = null,Object? openRouterApiKey = null,Object? togetherApiKey = null,Object? groqApiKey = null,Object? onboardingComplete = null,}) {
  return _then(_self.copyWith(
themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as ThemeModeOption,preferredProvider: null == preferredProvider ? _self.preferredProvider : preferredProvider // ignore: cast_nullable_to_non_nullable
as AiProviderType,huggingFaceApiKey: null == huggingFaceApiKey ? _self.huggingFaceApiKey : huggingFaceApiKey // ignore: cast_nullable_to_non_nullable
as String,openRouterApiKey: null == openRouterApiKey ? _self.openRouterApiKey : openRouterApiKey // ignore: cast_nullable_to_non_nullable
as String,togetherApiKey: null == togetherApiKey ? _self.togetherApiKey : togetherApiKey // ignore: cast_nullable_to_non_nullable
as String,groqApiKey: null == groqApiKey ? _self.groqApiKey : groqApiKey // ignore: cast_nullable_to_non_nullable
as String,onboardingComplete: null == onboardingComplete ? _self.onboardingComplete : onboardingComplete // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [AppSettings].
extension AppSettingsPatterns on AppSettings {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppSettings value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppSettings value)  $default,){
final _that = this;
switch (_that) {
case _AppSettings():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppSettings value)?  $default,){
final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ThemeModeOption themeMode,  AiProviderType preferredProvider,  String huggingFaceApiKey,  String openRouterApiKey,  String togetherApiKey,  String groqApiKey,  bool onboardingComplete)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.themeMode,_that.preferredProvider,_that.huggingFaceApiKey,_that.openRouterApiKey,_that.togetherApiKey,_that.groqApiKey,_that.onboardingComplete);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ThemeModeOption themeMode,  AiProviderType preferredProvider,  String huggingFaceApiKey,  String openRouterApiKey,  String togetherApiKey,  String groqApiKey,  bool onboardingComplete)  $default,) {final _that = this;
switch (_that) {
case _AppSettings():
return $default(_that.themeMode,_that.preferredProvider,_that.huggingFaceApiKey,_that.openRouterApiKey,_that.togetherApiKey,_that.groqApiKey,_that.onboardingComplete);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ThemeModeOption themeMode,  AiProviderType preferredProvider,  String huggingFaceApiKey,  String openRouterApiKey,  String togetherApiKey,  String groqApiKey,  bool onboardingComplete)?  $default,) {final _that = this;
switch (_that) {
case _AppSettings() when $default != null:
return $default(_that.themeMode,_that.preferredProvider,_that.huggingFaceApiKey,_that.openRouterApiKey,_that.togetherApiKey,_that.groqApiKey,_that.onboardingComplete);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppSettings implements AppSettings {
  const _AppSettings({this.themeMode = ThemeModeOption.system, this.preferredProvider = AiProviderType.auto, this.huggingFaceApiKey = '', this.openRouterApiKey = '', this.togetherApiKey = '', this.groqApiKey = '', this.onboardingComplete = false});
  factory _AppSettings.fromJson(Map<String, dynamic> json) => _$AppSettingsFromJson(json);

@override@JsonKey() final  ThemeModeOption themeMode;
@override@JsonKey() final  AiProviderType preferredProvider;
@override@JsonKey() final  String huggingFaceApiKey;
@override@JsonKey() final  String openRouterApiKey;
@override@JsonKey() final  String togetherApiKey;
@override@JsonKey() final  String groqApiKey;
@override@JsonKey() final  bool onboardingComplete;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppSettingsCopyWith<_AppSettings> get copyWith => __$AppSettingsCopyWithImpl<_AppSettings>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppSettingsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppSettings&&(identical(other.themeMode, themeMode) || other.themeMode == themeMode)&&(identical(other.preferredProvider, preferredProvider) || other.preferredProvider == preferredProvider)&&(identical(other.huggingFaceApiKey, huggingFaceApiKey) || other.huggingFaceApiKey == huggingFaceApiKey)&&(identical(other.openRouterApiKey, openRouterApiKey) || other.openRouterApiKey == openRouterApiKey)&&(identical(other.togetherApiKey, togetherApiKey) || other.togetherApiKey == togetherApiKey)&&(identical(other.groqApiKey, groqApiKey) || other.groqApiKey == groqApiKey)&&(identical(other.onboardingComplete, onboardingComplete) || other.onboardingComplete == onboardingComplete));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,themeMode,preferredProvider,huggingFaceApiKey,openRouterApiKey,togetherApiKey,groqApiKey,onboardingComplete);

@override
String toString() {
  return 'AppSettings(themeMode: $themeMode, preferredProvider: $preferredProvider, huggingFaceApiKey: $huggingFaceApiKey, openRouterApiKey: $openRouterApiKey, togetherApiKey: $togetherApiKey, groqApiKey: $groqApiKey, onboardingComplete: $onboardingComplete)';
}


}

/// @nodoc
abstract mixin class _$AppSettingsCopyWith<$Res> implements $AppSettingsCopyWith<$Res> {
  factory _$AppSettingsCopyWith(_AppSettings value, $Res Function(_AppSettings) _then) = __$AppSettingsCopyWithImpl;
@override @useResult
$Res call({
 ThemeModeOption themeMode, AiProviderType preferredProvider, String huggingFaceApiKey, String openRouterApiKey, String togetherApiKey, String groqApiKey, bool onboardingComplete
});




}
/// @nodoc
class __$AppSettingsCopyWithImpl<$Res>
    implements _$AppSettingsCopyWith<$Res> {
  __$AppSettingsCopyWithImpl(this._self, this._then);

  final _AppSettings _self;
  final $Res Function(_AppSettings) _then;

/// Create a copy of AppSettings
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? themeMode = null,Object? preferredProvider = null,Object? huggingFaceApiKey = null,Object? openRouterApiKey = null,Object? togetherApiKey = null,Object? groqApiKey = null,Object? onboardingComplete = null,}) {
  return _then(_AppSettings(
themeMode: null == themeMode ? _self.themeMode : themeMode // ignore: cast_nullable_to_non_nullable
as ThemeModeOption,preferredProvider: null == preferredProvider ? _self.preferredProvider : preferredProvider // ignore: cast_nullable_to_non_nullable
as AiProviderType,huggingFaceApiKey: null == huggingFaceApiKey ? _self.huggingFaceApiKey : huggingFaceApiKey // ignore: cast_nullable_to_non_nullable
as String,openRouterApiKey: null == openRouterApiKey ? _self.openRouterApiKey : openRouterApiKey // ignore: cast_nullable_to_non_nullable
as String,togetherApiKey: null == togetherApiKey ? _self.togetherApiKey : togetherApiKey // ignore: cast_nullable_to_non_nullable
as String,groqApiKey: null == groqApiKey ? _self.groqApiKey : groqApiKey // ignore: cast_nullable_to_non_nullable
as String,onboardingComplete: null == onboardingComplete ? _self.onboardingComplete : onboardingComplete // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
