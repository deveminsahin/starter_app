// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'email_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$EmailFailure {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmailFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'EmailFailure()';
}


}

/// @nodoc
class $EmailFailureCopyWith<$Res>  {
$EmailFailureCopyWith(EmailFailure _, $Res Function(EmailFailure) __);
}


/// Adds pattern-matching-related methods to [EmailFailure].
extension EmailFailurePatterns on EmailFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( EmailEmpty value)?  empty,TResult Function( EmailTooLong value)?  tooLong,TResult Function( EmailInvalidFormat value)?  invalidFormat,required TResult orElse(),}){
final _that = this;
switch (_that) {
case EmailEmpty() when empty != null:
return empty(_that);case EmailTooLong() when tooLong != null:
return tooLong(_that);case EmailInvalidFormat() when invalidFormat != null:
return invalidFormat(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( EmailEmpty value)  empty,required TResult Function( EmailTooLong value)  tooLong,required TResult Function( EmailInvalidFormat value)  invalidFormat,}){
final _that = this;
switch (_that) {
case EmailEmpty():
return empty(_that);case EmailTooLong():
return tooLong(_that);case EmailInvalidFormat():
return invalidFormat(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( EmailEmpty value)?  empty,TResult? Function( EmailTooLong value)?  tooLong,TResult? Function( EmailInvalidFormat value)?  invalidFormat,}){
final _that = this;
switch (_that) {
case EmailEmpty() when empty != null:
return empty(_that);case EmailTooLong() when tooLong != null:
return tooLong(_that);case EmailInvalidFormat() when invalidFormat != null:
return invalidFormat(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  empty,TResult Function( int maxLength,  int actualLength)?  tooLong,TResult Function( String failedValue)?  invalidFormat,required TResult orElse(),}) {final _that = this;
switch (_that) {
case EmailEmpty() when empty != null:
return empty();case EmailTooLong() when tooLong != null:
return tooLong(_that.maxLength,_that.actualLength);case EmailInvalidFormat() when invalidFormat != null:
return invalidFormat(_that.failedValue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  empty,required TResult Function( int maxLength,  int actualLength)  tooLong,required TResult Function( String failedValue)  invalidFormat,}) {final _that = this;
switch (_that) {
case EmailEmpty():
return empty();case EmailTooLong():
return tooLong(_that.maxLength,_that.actualLength);case EmailInvalidFormat():
return invalidFormat(_that.failedValue);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  empty,TResult? Function( int maxLength,  int actualLength)?  tooLong,TResult? Function( String failedValue)?  invalidFormat,}) {final _that = this;
switch (_that) {
case EmailEmpty() when empty != null:
return empty();case EmailTooLong() when tooLong != null:
return tooLong(_that.maxLength,_that.actualLength);case EmailInvalidFormat() when invalidFormat != null:
return invalidFormat(_that.failedValue);case _:
  return null;

}
}

}

/// @nodoc


class EmailEmpty extends EmailFailure {
  const EmailEmpty(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmailEmpty);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'EmailFailure.empty()';
}


}




/// @nodoc


class EmailTooLong extends EmailFailure {
  const EmailTooLong({required this.maxLength, required this.actualLength}): super._();
  

 final  int maxLength;
 final  int actualLength;

/// Create a copy of EmailFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmailTooLongCopyWith<EmailTooLong> get copyWith => _$EmailTooLongCopyWithImpl<EmailTooLong>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmailTooLong&&(identical(other.maxLength, maxLength) || other.maxLength == maxLength)&&(identical(other.actualLength, actualLength) || other.actualLength == actualLength));
}


@override
int get hashCode => Object.hash(runtimeType,maxLength,actualLength);

@override
String toString() {
  return 'EmailFailure.tooLong(maxLength: $maxLength, actualLength: $actualLength)';
}


}

/// @nodoc
abstract mixin class $EmailTooLongCopyWith<$Res> implements $EmailFailureCopyWith<$Res> {
  factory $EmailTooLongCopyWith(EmailTooLong value, $Res Function(EmailTooLong) _then) = _$EmailTooLongCopyWithImpl;
@useResult
$Res call({
 int maxLength, int actualLength
});




}
/// @nodoc
class _$EmailTooLongCopyWithImpl<$Res>
    implements $EmailTooLongCopyWith<$Res> {
  _$EmailTooLongCopyWithImpl(this._self, this._then);

  final EmailTooLong _self;
  final $Res Function(EmailTooLong) _then;

/// Create a copy of EmailFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? maxLength = null,Object? actualLength = null,}) {
  return _then(EmailTooLong(
maxLength: null == maxLength ? _self.maxLength : maxLength // ignore: cast_nullable_to_non_nullable
as int,actualLength: null == actualLength ? _self.actualLength : actualLength // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc


class EmailInvalidFormat extends EmailFailure {
  const EmailInvalidFormat({required this.failedValue}): super._();
  

 final  String failedValue;

/// Create a copy of EmailFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EmailInvalidFormatCopyWith<EmailInvalidFormat> get copyWith => _$EmailInvalidFormatCopyWithImpl<EmailInvalidFormat>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EmailInvalidFormat&&(identical(other.failedValue, failedValue) || other.failedValue == failedValue));
}


@override
int get hashCode => Object.hash(runtimeType,failedValue);

@override
String toString() {
  return 'EmailFailure.invalidFormat(failedValue: $failedValue)';
}


}

/// @nodoc
abstract mixin class $EmailInvalidFormatCopyWith<$Res> implements $EmailFailureCopyWith<$Res> {
  factory $EmailInvalidFormatCopyWith(EmailInvalidFormat value, $Res Function(EmailInvalidFormat) _then) = _$EmailInvalidFormatCopyWithImpl;
@useResult
$Res call({
 String failedValue
});




}
/// @nodoc
class _$EmailInvalidFormatCopyWithImpl<$Res>
    implements $EmailInvalidFormatCopyWith<$Res> {
  _$EmailInvalidFormatCopyWithImpl(this._self, this._then);

  final EmailInvalidFormat _self;
  final $Res Function(EmailInvalidFormat) _then;

/// Create a copy of EmailFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? failedValue = null,}) {
  return _then(EmailInvalidFormat(
failedValue: null == failedValue ? _self.failedValue : failedValue // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
