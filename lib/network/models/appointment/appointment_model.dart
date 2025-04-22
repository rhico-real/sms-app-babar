import 'package:freezed_annotation/freezed_annotation.dart';
part 'appointment_model.freezed.dart';
part 'appointment_model.g.dart';

@Freezed()
class AppointmentModel with _$AppointmentModel {
  const factory AppointmentModel({
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
    }) = _AppointmentModel;

  factory AppointmentModel.fromJson(Map<String, dynamic> json) => _$AppointmentModelFromJson(json);
}