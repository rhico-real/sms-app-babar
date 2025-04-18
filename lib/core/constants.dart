
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sms_app/core/data_state.dart';
import 'package:sms_app/local_db/shared_preferences/shared_preferences.dart';
import 'package:sms_app/local_db/shared_preferences/shared_prefs_helper.dart';

class NetworkConstants {
  static var baseUrl = dotenv.env['BASE_URL'];

  Future<DataFailed> datafailed({dynamic errorMessage}) async {
    return DataFailed(DioError(
      error: errorMessage ?? "API timed out.",
      requestOptions: RequestOptions(path: ""),
    ));
  }

  Future<Map<String, dynamic>?> getHeaders() async {
    String? storedToken = await SharedPrefsUtil().getString(SharedPrefsHelper.token);

    if (storedToken != null && storedToken.isNotEmpty) {
      return {'Content-Type': 'application/json', 'Authorization': 'Bearer $storedToken'};
    }
    return null;
  }
}
