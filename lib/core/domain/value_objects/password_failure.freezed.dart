// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'password_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$PasswordFailure {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PasswordFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PasswordFailure()';
}


}

/// @nodoc
class $PasswordFailureCopyWith<$Res>  {
$PasswordFailureCopyWith(PasswordFailure _, $Res Function(PasswordFailure) __);
}


/// Adds pattern-matching-related methods to [PasswordFailure].
extension PasswordFailurePatterns on PasswordFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( PasswordEmpty value)?  empty,TResult Function( PasswordTooShort value)?  tooShort,TResult Function( PasswordTooLong value)?  tooLong,TResult Function( PasswordMissingUppercase value)?  missingUppercase,TResult Function( PasswordMissingLowercase value)?  missingLowercase,TResult Function( PasswordMissingDigit value)?  missingDigit,TResult Function( PasswordMissingSpecialCharacter value)?  missingSpecialCharacter,required TResult orElse(),}){
final _that = this;
switch (_that) {
case PasswordEmpty() when empty != null:
return empty(_that);case PasswordTooShort() when tooShort != null:
return tooShort(_that);case PasswordTooLong() when tooLong != null:
return tooLong(_that);case PasswordMissingUppercase() when missingUppercase != null:
return missingUppercase(_that);case PasswordMissingLowercase() when missingLowercase != null:
return missingLowercase(_that);case PasswordMissingDigit() when missingDigit != null:
return missingDigit(_that);case PasswordMissingSpecialCharacter() when missingSpecialCharacter != null:
return missingSpecialCharacter(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( PasswordEmpty value)  empty,required TResult Function( PasswordTooShort value)  tooShort,required TResult Function( PasswordTooLong value)  tooLong,required TResult Function( PasswordMissingUppercase value)  missingUppercase,required TResult Function( PasswordMissingLowercase value)  missingLowercase,required TResult Function( PasswordMissingDigit value)  missingDigit,required TResult Function( PasswordMissingSpecialCharacter value)  missingSpecialCharacter,}){
final _that = this;
switch (_that) {
case PasswordEmpty():
return empty(_that);case PasswordTooShort():
return tooShort(_that);case PasswordTooLong():
return tooLong(_that);case PasswordMissingUppercase():
return missingUppercase(_that);case PasswordMissingLowercase():
return missingLowercase(_that);case PasswordMissingDigit():
return missingDigit(_that);case PasswordMissingSpecialCharacter():
return missingSpecialCharacter(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( PasswordEmpty value)?  empty,TResult? Function( PasswordTooShort value)?  tooShort,TResult? Function( PasswordTooLong value)?  tooLong,TResult? Function( PasswordMissingUppercase value)?  missingUppercase,TResult? Function( PasswordMissingLowercase value)?  missingLowercase,TResult? Function( PasswordMissingDigit value)?  missingDigit,TResult? Function( PasswordMissingSpecialCharacter value)?  missingSpecialCharacter,}){
final _that = this;
switch (_that) {
case PasswordEmpty() when empty != null:
return empty(_that);case PasswordTooShort() when tooShort != null:
return tooShort(_that);case PasswordTooLong() when tooLong != null:
return tooLong(_that);case PasswordMissingUppercase() when missingUppercase != null:
return missingUppercase(_that);case PasswordMissingLowercase() when missingLowercase != null:
return missingLowercase(_that);case PasswordMissingDigit() when missingDigit != null:
return missingDigit(_that);case PasswordMissingSpecialCharacter() when missingSpecialCharacter != null:
return missingSpecialCharacter(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  empty,TResult Function( int minLength,  int actualLength)?  tooShort,TResult Function( int maxLength,  int actualLength)?  tooLong,TResult Function()?  missingUppercase,TResult Function()?  missingLowercase,TResult Function()?  missingDigit,TResult Function()?  missingSpecialCharacter,required TResult orElse(),}) {final _that = this;
switch (_that) {
case PasswordEmpty() when empty != null:
return empty();case PasswordTooShort() when tooShort != null:
return tooShort(_that.minLength,_that.actualLength);case PasswordTooLong() when tooLong != null:
return tooLong(_that.maxLength,_that.actualLength);case PasswordMissingUppercase() when missingUppercase != null:
return missingUppercase();case PasswordMissingLowercase() when missingLowercase != null:
return missingLowercase();case PasswordMissingDigit() when missingDigit != null:
return missingDigit();case PasswordMissingSpecialCharacter() when missingSpecialCharacter != null:
return missingSpecialCharacter();case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  empty,required TResult Function( int minLength,  int actualLength)  tooShort,required TResult Function( int maxLength,  int actualLength)  tooLong,required TResult Function()  missingUppercase,required TResult Function()  missingLowercase,required TResult Function()  missingDigit,required TResult Function()  missingSpecialCharacter,}) {final _that = this;
switch (_that) {
case PasswordEmpty():
return empty();case PasswordTooShort():
return tooShort(_that.minLength,_that.actualLength);case PasswordTooLong():
return tooLong(_that.maxLength,_that.actualLength);case PasswordMissingUppercase():
return missingUppercase();case PasswordMissingLowercase():
return missingLowercase();case PasswordMissingDigit():
return missingDigit();case PasswordMissingSpecialCharacter():
return missingSpecialCharacter();}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  empty,TResult? Function( int minLength,  int actualLength)?  tooShort,TResult? Function( int maxLength,  int actualLength)?  tooLong,TResult? Function()?  missingUppercase,TResult? Function()?  missingLowercase,TResult? Function()?  missingDigit,TResult? Function()?  missingSpecialCharacter,}) {final _that = this;
switch (_that) {
case PasswordEmpty() when empty != null:
return empty();case PasswordTooShort() when tooShort != null:
return tooShort(_that.minLength,_that.actualLength);case PasswordTooLong() when tooLong != null:
return tooLong(_that.maxLength,_that.actualLength);case PasswordMissingUppercase() when missingUppercase != null:
return missingUppercase();case PasswordMissingLowercase() when missingLowercase != null:
return missingLowercase();case PasswordMissingDigit() when missingDigit != null:
return missingDigit();case PasswordMissingSpecialCharacter() when missingSpecialCharacter != null:
return missingSpecialCharacter();case _:
  return null;

}
}

}

/// @nodoc


class PasswordEmpty extends PasswordFailure {
  const PasswordEmpty(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PasswordEmpty);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PasswordFailure.empty()';
}


}




/// @nodoc


class PasswordTooShort extends PasswordFailure {
  const PasswordTooShort({required this.minLength, required this.actualLength}): super._();
  

 final  int minLength;
 final  int actualLength;

/// Create a copy of PasswordFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PasswordTooShortCopyWith<PasswordTooShort> get copyWith => _$PasswordTooShortCopyWithImpl<PasswordTooShort>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PasswordTooShort&&(identical(other.minLength, minLength) || other.minLength == minLength)&&(identical(other.actualLength, actualLength) || other.actualLength == actualLength));
}


@override
int get hashCode => Object.hash(runtimeType,minLength,actualLength);

@override
String toString() {
  return 'PasswordFailure.tooShort(minLength: $minLength, actualLength: $actualLength)';
}


}

/// @nodoc
abstract mixin class $PasswordTooShortCopyWith<$Res> implements $PasswordFailureCopyWith<$Res> {
  factory $PasswordTooShortCopyWith(PasswordTooShort value, $Res Function(PasswordTooShort) _then) = _$PasswordTooShortCopyWithImpl;
@useResult
$Res call({
 int minLength, int actualLength
});




}
/// @nodoc
class _$PasswordTooShortCopyWithImpl<$Res>
    implements $PasswordTooShortCopyWith<$Res> {
  _$PasswordTooShortCopyWithImpl(this._self, this._then);

  final PasswordTooShort _self;
  final $Res Function(PasswordTooShort) _then;

/// Create a copy of PasswordFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? minLength = null,Object? actualLength = null,}) {
  return _then(PasswordTooShort(
minLength: null == minLength ? _self.minLength : minLength // ignore: cast_nullable_to_non_nullable
as int,actualLength: null == actualLength ? _self.actualLength : actualLength // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class PasswordTooLong extends PasswordFailure {
  const PasswordTooLong({required this.maxLength, required this.actualLength}): super._();
  

 final  int maxLength;
 final  int actualLength;

/// Create a copy of PasswordFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PasswordTooLongCopyWith<PasswordTooLong> get copyWith => _$PasswordTooLongCopyWithImpl<PasswordTooLong>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PasswordTooLong&&(identical(other.maxLength, maxLength) || other.maxLength == maxLength)&&(identical(other.actualLength, actualLength) || other.actualLength == actualLength));
}


@override
int get hashCode => Object.hash(runtimeType,maxLength,actualLength);

@override
String toString() {
  return 'PasswordFailure.tooLong(maxLength: $maxLength, actualLength: $actualLength)';
}


}

/// @nodoc
abstract mixin class $PasswordTooLongCopyWith<$Res> implements $PasswordFailureCopyWith<$Res> {
  factory $PasswordTooLongCopyWith(PasswordTooLong value, $Res Function(PasswordTooLong) _then) = _$PasswordTooLongCopyWithImpl;
@useResult
$Res call({
 int maxLength, int actualLength
});




}
/// @nodoc
class _$PasswordTooLongCopyWithImpl<$Res>
    implements $PasswordTooLongCopyWith<$Res> {
  _$PasswordTooLongCopyWithImpl(this._self, this._then);

  final PasswordTooLong _self;
  final $Res Function(PasswordTooLong) _then;

/// Create a copy of PasswordFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? maxLength = null,Object? actualLength = null,}) {
  return _then(PasswordTooLong(
maxLength: null == maxLength ? _self.maxLength : maxLength // ignore: cast_nullable_to_non_nullable
as int,actualLength: null == actualLength ? _self.actualLength : actualLength // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class PasswordMissingUppercase extends PasswordFailure {
  const PasswordMissingUppercase(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PasswordMissingUppercase);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PasswordFailure.missingUppercase()';
}


}




/// @nodoc


class PasswordMissingLowercase extends PasswordFailure {
  const PasswordMissingLowercase(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PasswordMissingLowercase);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PasswordFailure.missingLowercase()';
}


}




/// @nodoc


class PasswordMissingDigit extends PasswordFailure {
  const PasswordMissingDigit(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PasswordMissingDigit);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PasswordFailure.missingDigit()';
}


}




/// @nodoc


class PasswordMissingSpecialCharacter extends PasswordFailure {
  const PasswordMissingSpecialCharacter(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PasswordMissingSpecialCharacter);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'PasswordFailure.missingSpecialCharacter()';
}


}




// dart format on
