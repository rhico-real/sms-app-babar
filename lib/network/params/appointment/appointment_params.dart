import 'package:freezed_annotation/freezed_annotation.dart';
part 'appointment_params.freezed.dart';
part 'appointment_params.g.dart';

@Freezed()
class AppointmentParams with _$AppointmentParams {
  const factory AppointmentParams({
    @JsonKey(
      name: "full_name",
    )
    String? fullName,
    String? email,
    @JsonKey(
      name: "phone_number",
    )
    String? phoneNumber,
    String? date,
    String? reason
    }) = _AppointmentParams;

  factory AppointmentParams.fromJson(Map<String, dynamic> json) => _$AppointmentParamsFromJson(json);
}