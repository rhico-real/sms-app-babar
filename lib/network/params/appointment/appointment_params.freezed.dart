// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'appointment_params.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

AppointmentParams _$AppointmentParamsFromJson(Map<String, dynamic> json) {
  return _AppointmentParams.fromJson(json);
}

/// @nodoc
mixin _$AppointmentParams {
  @JsonKey(name: "full_name")
  String? get fullName => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  @JsonKey(name: "phone_number")
  String? get phoneNumber => throw _privateConstructorUsedError;
  String? get date => throw _privateConstructorUsedError;
  String? get reason => throw _privateConstructorUsedError;

  /// Serializes this AppointmentParams to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AppointmentParams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AppointmentParamsCopyWith<AppointmentParams> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AppointmentParamsCopyWith<$Res> {
  factory $AppointmentParamsCopyWith(
    AppointmentParams value,
    $Res Function(AppointmentParams) then,
  ) = _$AppointmentParamsCopyWithImpl<$Res, AppointmentParams>;
  @useResult
  $Res call({
    @JsonKey(name: "full_name") String? fullName,
    String? email,
    @JsonKey(name: "phone_number") String? phoneNumber,
    String? date,
    String? reason,
  });
}

/// @nodoc
class _$AppointmentParamsCopyWithImpl<$Res, $Val extends AppointmentParams>
    implements $AppointmentParamsCopyWith<$Res> {
  _$AppointmentParamsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AppointmentParams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fullName = freezed,
    Object? email = freezed,
    Object? phoneNumber = freezed,
    Object? date = freezed,
    Object? reason = freezed,
  }) {
    return _then(
      _value.copyWith(
            fullName:
                freezed == fullName
                    ? _value.fullName
                    : fullName // ignore: cast_nullable_to_non_nullable
                        as String?,
            email:
                freezed == email
                    ? _value.email
                    : email // ignore: cast_nullable_to_non_nullable
                        as String?,
            phoneNumber:
                freezed == phoneNumber
                    ? _value.phoneNumber
                    : phoneNumber // ignore: cast_nullable_to_non_nullable
                        as String?,
            date:
                freezed == date
                    ? _value.date
                    : date // ignore: cast_nullable_to_non_nullable
                        as String?,
            reason:
                freezed == reason
                    ? _value.reason
                    : reason // ignore: cast_nullable_to_non_nullable
                        as String?,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$AppointmentParamsImplCopyWith<$Res>
    implements $AppointmentParamsCopyWith<$Res> {
  factory _$$AppointmentParamsImplCopyWith(
    _$AppointmentParamsImpl value,
    $Res Function(_$AppointmentParamsImpl) then,
  ) = __$$AppointmentParamsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    @JsonKey(name: "full_name") String? fullName,
    String? email,
    @JsonKey(name: "phone_number") String? phoneNumber,
    String? date,
    String? reason,
  });
}

/// @nodoc
class __$$AppointmentParamsImplCopyWithImpl<$Res>
    extends _$AppointmentParamsCopyWithImpl<$Res, _$AppointmentParamsImpl>
    implements _$$AppointmentParamsImplCopyWith<$Res> {
  __$$AppointmentParamsImplCopyWithImpl(
    _$AppointmentParamsImpl _value,
    $Res Function(_$AppointmentParamsImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of AppointmentParams
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? fullName = freezed,
    Object? email = freezed,
    Object? phoneNumber = freezed,
    Object? date = freezed,
    Object? reason = freezed,
  }) {
    return _then(
      _$AppointmentParamsImpl(
        fullName:
            freezed == fullName
                ? _value.fullName
                : fullName // ignore: cast_nullable_to_non_nullable
                    as String?,
        email:
            freezed == email
                ? _value.email
                : email // ignore: cast_nullable_to_non_nullable
                    as String?,
        phoneNumber:
            freezed == phoneNumber
                ? _value.phoneNumber
                : phoneNumber // ignore: cast_nullable_to_non_nullable
                    as String?,
        date:
            freezed == date
                ? _value.date
                : date // ignore: cast_nullable_to_non_nullable
                    as String?,
        reason:
            freezed == reason
                ? _value.reason
                : reason // ignore: cast_nullable_to_non_nullable
                    as String?,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$AppointmentParamsImpl implements _AppointmentParams {
  const _$AppointmentParamsImpl({
    @JsonKey(name: "full_name") this.fullName,
    this.email,
    @JsonKey(name: "phone_number") this.phoneNumber,
    this.date,
    this.reason,
  });

  factory _$AppointmentParamsImpl.fromJson(Map<String, dynamic> json) =>
      _$$AppointmentParamsImplFromJson(json);

  @override
  @JsonKey(name: "full_name")
  final String? fullName;
  @override
  final String? email;
  @override
  @JsonKey(name: "phone_number")
  final String? phoneNumber;
  @override
  final String? date;
  @override
  final String? reason;

  @override
  String toString() {
    return 'AppointmentParams(fullName: $fullName, email: $email, phoneNumber: $phoneNumber, date: $date, reason: $reason)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AppointmentParamsImpl &&
            (identical(other.fullName, fullName) ||
                other.fullName == fullName) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.date, date) || other.date == date) &&
            (identical(other.reason, reason) || other.reason == reason));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, fullName, email, phoneNumber, date, reason);

  /// Create a copy of AppointmentParams
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AppointmentParamsImplCopyWith<_$AppointmentParamsImpl> get copyWith =>
      __$$AppointmentParamsImplCopyWithImpl<_$AppointmentParamsImpl>(
        this,
        _$identity,
      );

  @override
  Map<String, dynamic> toJson() {
    return _$$AppointmentParamsImplToJson(this);
  }
}

abstract class _AppointmentParams implements AppointmentParams {
  const factory _AppointmentParams({
    @JsonKey(name: "full_name") final String? fullName,
    final String? email,
    @JsonKey(name: "phone_number") final String? phoneNumber,
    final String? date,
    final String? reason,
  }) = _$AppointmentParamsImpl;

  factory _AppointmentParams.fromJson(Map<String, dynamic> json) =
      _$AppointmentParamsImpl.fromJson;

  @override
  @JsonKey(name: "full_name")
  String? get fullName;
  @override
  String? get email;
  @override
  @JsonKey(name: "phone_number")
  String? get phoneNumber;
  @override
  String? get date;
  @override
  String? get reason;

  /// Create a copy of AppointmentParams
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AppointmentParamsImplCopyWith<_$AppointmentParamsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
