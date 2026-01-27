// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'token_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$TokenFailure {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TokenFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TokenFailure()';
}


}

/// @nodoc
class $TokenFailureCopyWith<$Res>  {
$TokenFailureCopyWith(TokenFailure _, $Res Function(TokenFailure) __);
}


/// Adds pattern-matching-related methods to [TokenFailure].
extension TokenFailurePatterns on TokenFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( TokenEmpty value)?  empty,TResult Function( TokenTooShort value)?  tooShort,TResult Function( TokenInvalidFormat value)?  invalidFormat,TResult Function( TokenExpired value)?  expired,required TResult orElse(),}){
final _that = this;
switch (_that) {
case TokenEmpty() when empty != null:
return empty(_that);case TokenTooShort() when tooShort != null:
return tooShort(_that);case TokenInvalidFormat() when invalidFormat != null:
return invalidFormat(_that);case TokenExpired() when expired != null:
return expired(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( TokenEmpty value)  empty,required TResult Function( TokenTooShort value)  tooShort,required TResult Function( TokenInvalidFormat value)  invalidFormat,required TResult Function( TokenExpired value)  expired,}){
final _that = this;
switch (_that) {
case TokenEmpty():
return empty(_that);case TokenTooShort():
return tooShort(_that);case TokenInvalidFormat():
return invalidFormat(_that);case TokenExpired():
return expired(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( TokenEmpty value)?  empty,TResult? Function( TokenTooShort value)?  tooShort,TResult? Function( TokenInvalidFormat value)?  invalidFormat,TResult? Function( TokenExpired value)?  expired,}){
final _that = this;
switch (_that) {
case TokenEmpty() when empty != null:
return empty(_that);case TokenTooShort() when tooShort != null:
return tooShort(_that);case TokenInvalidFormat() when invalidFormat != null:
return invalidFormat(_that);case TokenExpired() when expired != null:
return expired(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  empty,TResult Function( int minLength,  int actualLength)?  tooShort,TResult Function( String expectedFormat)?  invalidFormat,TResult Function()?  expired,required TResult orElse(),}) {final _that = this;
switch (_that) {
case TokenEmpty() when empty != null:
return empty();case TokenTooShort() when tooShort != null:
return tooShort(_that.minLength,_that.actualLength);case TokenInvalidFormat() when invalidFormat != null:
return invalidFormat(_that.expectedFormat);case TokenExpired() when expired != null:
return expired();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  empty,required TResult Function( int minLength,  int actualLength)  tooShort,required TResult Function( String expectedFormat)  invalidFormat,required TResult Function()  expired,}) {final _that = this;
switch (_that) {
case TokenEmpty():
return empty();case TokenTooShort():
return tooShort(_that.minLength,_that.actualLength);case TokenInvalidFormat():
return invalidFormat(_that.expectedFormat);case TokenExpired():
return expired();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  empty,TResult? Function( int minLength,  int actualLength)?  tooShort,TResult? Function( String expectedFormat)?  invalidFormat,TResult? Function()?  expired,}) {final _that = this;
switch (_that) {
case TokenEmpty() when empty != null:
return empty();case TokenTooShort() when tooShort != null:
return tooShort(_that.minLength,_that.actualLength);case TokenInvalidFormat() when invalidFormat != null:
return invalidFormat(_that.expectedFormat);case TokenExpired() when expired != null:
return expired();case _:
  return null;

}
}

}

/// @nodoc


class TokenEmpty extends TokenFailure {
  const TokenEmpty(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TokenEmpty);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TokenFailure.empty()';
}


}




/// @nodoc


class TokenTooShort extends TokenFailure {
  const TokenTooShort({required this.minLength, required this.actualLength}): super._();
  

 final  int minLength;
 final  int actualLength;

/// Create a copy of TokenFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TokenTooShortCopyWith<TokenTooShort> get copyWith => _$TokenTooShortCopyWithImpl<TokenTooShort>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TokenTooShort&&(identical(other.minLength, minLength) || other.minLength == minLength)&&(identical(other.actualLength, actualLength) || other.actualLength == actualLength));
}


@override
int get hashCode => Object.hash(runtimeType,minLength,actualLength);

@override
String toString() {
  return 'TokenFailure.tooShort(minLength: $minLength, actualLength: $actualLength)';
}


}

/// @nodoc
abstract mixin class $TokenTooShortCopyWith<$Res> implements $TokenFailureCopyWith<$Res> {
  factory $TokenTooShortCopyWith(TokenTooShort value, $Res Function(TokenTooShort) _then) = _$TokenTooShortCopyWithImpl;
@useResult
$Res call({
 int minLength, int actualLength
});




}
/// @nodoc
class _$TokenTooShortCopyWithImpl<$Res>
    implements $TokenTooShortCopyWith<$Res> {
  _$TokenTooShortCopyWithImpl(this._self, this._then);

  final TokenTooShort _self;
  final $Res Function(TokenTooShort) _then;

/// Create a copy of TokenFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? minLength = null,Object? actualLength = null,}) {
  return _then(TokenTooShort(
minLength: null == minLength ? _self.minLength : minLength // ignore: cast_nullable_to_non_nullable
as int,actualLength: null == actualLength ? _self.actualLength : actualLength // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class TokenInvalidFormat extends TokenFailure {
  const TokenInvalidFormat({required this.expectedFormat}): super._();
  

 final  String expectedFormat;

/// Create a copy of TokenFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TokenInvalidFormatCopyWith<TokenInvalidFormat> get copyWith => _$TokenInvalidFormatCopyWithImpl<TokenInvalidFormat>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TokenInvalidFormat&&(identical(other.expectedFormat, expectedFormat) || other.expectedFormat == expectedFormat));
}


@override
int get hashCode => Object.hash(runtimeType,expectedFormat);

@override
String toString() {
  return 'TokenFailure.invalidFormat(expectedFormat: $expectedFormat)';
}


}

/// @nodoc
abstract mixin class $TokenInvalidFormatCopyWith<$Res> implements $TokenFailureCopyWith<$Res> {
  factory $TokenInvalidFormatCopyWith(TokenInvalidFormat value, $Res Function(TokenInvalidFormat) _then) = _$TokenInvalidFormatCopyWithImpl;
@useResult
$Res call({
 String expectedFormat
});




}
/// @nodoc
class _$TokenInvalidFormatCopyWithImpl<$Res>
    implements $TokenInvalidFormatCopyWith<$Res> {
  _$TokenInvalidFormatCopyWithImpl(this._self, this._then);

  final TokenInvalidFormat _self;
  final $Res Function(TokenInvalidFormat) _then;

/// Create a copy of TokenFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? expectedFormat = null,}) {
  return _then(TokenInvalidFormat(
expectedFormat: null == expectedFormat ? _self.expectedFormat : expectedFormat // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class TokenExpired extends TokenFailure {
  const TokenExpired(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TokenExpired);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'TokenFailure.expired()';
}


}




// dart format on
