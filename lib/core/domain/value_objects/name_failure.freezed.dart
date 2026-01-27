// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'name_failure.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$NameFailure {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NameFailure);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'NameFailure()';
}


}

/// @nodoc
class $NameFailureCopyWith<$Res>  {
$NameFailureCopyWith(NameFailure _, $Res Function(NameFailure) __);
}


/// Adds pattern-matching-related methods to [NameFailure].
extension NameFailurePatterns on NameFailure {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( NameEmpty value)?  empty,TResult Function( NameTooLong value)?  tooLong,required TResult orElse(),}){
final _that = this;
switch (_that) {
case NameEmpty() when empty != null:
return empty(_that);case NameTooLong() when tooLong != null:
return tooLong(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( NameEmpty value)  empty,required TResult Function( NameTooLong value)  tooLong,}){
final _that = this;
switch (_that) {
case NameEmpty():
return empty(_that);case NameTooLong():
return tooLong(_that);}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( NameEmpty value)?  empty,TResult? Function( NameTooLong value)?  tooLong,}){
final _that = this;
switch (_that) {
case NameEmpty() when empty != null:
return empty(_that);case NameTooLong() when tooLong != null:
return tooLong(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  empty,TResult Function( int maxLength,  int actualLength)?  tooLong,required TResult orElse(),}) {final _that = this;
switch (_that) {
case NameEmpty() when empty != null:
return empty();case NameTooLong() when tooLong != null:
return tooLong(_that.maxLength,_that.actualLength);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  empty,required TResult Function( int maxLength,  int actualLength)  tooLong,}) {final _that = this;
switch (_that) {
case NameEmpty():
return empty();case NameTooLong():
return tooLong(_that.maxLength,_that.actualLength);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  empty,TResult? Function( int maxLength,  int actualLength)?  tooLong,}) {final _that = this;
switch (_that) {
case NameEmpty() when empty != null:
return empty();case NameTooLong() when tooLong != null:
return tooLong(_that.maxLength,_that.actualLength);case _:
  return null;

}
}

}

/// @nodoc


class NameEmpty extends NameFailure {
  const NameEmpty(): super._();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NameEmpty);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'NameFailure.empty()';
}


}




/// @nodoc


class NameTooLong extends NameFailure {
  const NameTooLong({required this.maxLength, required this.actualLength}): super._();
  

 final  int maxLength;
 final  int actualLength;

/// Create a copy of NameFailure
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NameTooLongCopyWith<NameTooLong> get copyWith => _$NameTooLongCopyWithImpl<NameTooLong>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NameTooLong&&(identical(other.maxLength, maxLength) || other.maxLength == maxLength)&&(identical(other.actualLength, actualLength) || other.actualLength == actualLength));
}


@override
int get hashCode => Object.hash(runtimeType,maxLength,actualLength);

@override
String toString() {
  return 'NameFailure.tooLong(maxLength: $maxLength, actualLength: $actualLength)';
}


}

/// @nodoc
abstract mixin class $NameTooLongCopyWith<$Res> implements $NameFailureCopyWith<$Res> {
  factory $NameTooLongCopyWith(NameTooLong value, $Res Function(NameTooLong) _then) = _$NameTooLongCopyWithImpl;
@useResult
$Res call({
 int maxLength, int actualLength
});




}
/// @nodoc
class _$NameTooLongCopyWithImpl<$Res>
    implements $NameTooLongCopyWith<$Res> {
  _$NameTooLongCopyWithImpl(this._self, this._then);

  final NameTooLong _self;
  final $Res Function(NameTooLong) _then;

/// Create a copy of NameFailure
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? maxLength = null,Object? actualLength = null,}) {
  return _then(NameTooLong(
maxLength: null == maxLength ? _self.maxLength : maxLength // ignore: cast_nullable_to_non_nullable
as int,actualLength: null == actualLength ? _self.actualLength : actualLength // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
