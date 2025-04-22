// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'appointment_params.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$AppointmentParamsImpl _$$AppointmentParamsImplFromJson(
  Map<String, dynamic> json,
) => _$AppointmentParamsImpl(
  fullName: json['full_name'] as String?,
  email: json['email'] as String?,
  phoneNumber: json['phone_number'] as String?,
  date: json['date'] as String?,
  reason: json['reason'] as String?,
);

Map<String, dynamic> _$$AppointmentParamsImplToJson(
  _$AppointmentParamsImpl instance,
) => <String, dynamic>{
  'full_name': instance.fullName,
  'email': instance.email,
  'phone_number': instance.phoneNumber,
  'date': instance.date,
  'reason': instance.reason,
};
