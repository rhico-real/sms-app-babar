

import 'package:sms_app/core/data_state.dart';
import 'package:sms_app/core/repository_helper.dart';
import 'package:sms_app/network/models/auth/auth_model.dart';
import 'package:sms_app/network/params/auth/auth_params.dart';

class AuthRepository {
  // =================================================================
  //                         POST: LOGIN
  // =================================================================
  Future<DataState> login({required LoginParams loginParams}) async {
    final payload = {'identifier': loginParams.identifier, 'password': loginParams.password};

    DataState? data = await RepositoryHelper().post(payload: payload, endpoint: 'auth/login', fromJson: (json) => LoginModel.fromJson(json));
    return data;
  }
}
