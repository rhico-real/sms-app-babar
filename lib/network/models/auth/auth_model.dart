import 'package:freezed_annotation/freezed_annotation.dart';
part 'auth_model.freezed.dart';
part 'auth_model.g.dart';

@Freezed()
class LoginModel with _$LoginModel {
  const factory LoginModel({String? message, UserModel? user}) = _LoginModel;

  factory LoginModel.fromJson(Map<String, dynamic> json) => _$LoginModelFromJson(json);
}

@Freezed()
class UserModel with _$UserModel {
  const factory UserModel({String? identifier, TokenModel? tokens}) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
}

@Freezed()
class TokenModel with _$TokenModel {
  const factory TokenModel({String? refresh, String? access}) = _TokenModel;

  factory TokenModel.fromJson(Map<String, dynamic> json) => _$TokenModelFromJson(json);
}
