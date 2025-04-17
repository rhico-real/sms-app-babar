import 'package:freezed_annotation/freezed_annotation.dart';
part 'auth_params.freezed.dart';
part 'auth_params.g.dart';

@Freezed()
class LoginParams with _$LoginParams {
  const factory LoginParams({required String identifier, required String password}) = _LoginParams;

  factory LoginParams.fromJson(Map<String, dynamic> json) => _$LoginParamsFromJson(json);
}
