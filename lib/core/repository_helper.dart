import 'dart:io';

import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:sms_app/core/constants.dart';
import 'package:sms_app/core/data_state.dart';

class RepositoryHelper {
  /// Post:
  /// payload -> parameters to send api
  /// endponint -> api endpoint
  /// fromJson -> response model
  Future<DataState> post<T>({required Map<String, dynamic> payload, required String endpoint, required T Function(Map<String, dynamic>) fromJson}) async {
    try {
      Logger().e(payload);
      Logger().e('${NetworkConstants.baseUrl}/$endpoint/');
      final request = await Dio().post('${NetworkConstants.baseUrl}/$endpoint/', data: payload);
      if (request.statusCode == HttpStatus.ok || request.statusCode == HttpStatus.created) {
        final T data = fromJson(request.data);

        Logger().i(data);
        return DataSuccess(data);
      } else {
        return NetworkConstants().datafailed();
      }
    } on DioError catch (e) {
      if (e.response?.statusCode == HttpStatus.unauthorized) {
        // TODO: add logic to refresh token or logout user
      }
      Logger().e("${e.message}\n${e.response}");
      return NetworkConstants().datafailed(errorMessage: e.response);
    } catch (e) {
      Logger().e(e);
      return NetworkConstants().datafailed();
    }
  }

  Future<DataState> repositoryHelper<T>(Future<Response?> Function() functionParams) async {
    Response? httpResponse;

    /// Future.any: the next line will wait until the
    /// functionParams() has completed. If the functionParams()
    /// hasn't completed by the time 'apiSecondsBeforeTimeOut'
    /// is complete, it is considered a timeout.
    ///
    /// We only allot for 20 seconds before timeout
    await Future.any([
      Future.delayed(const Duration(seconds: 20)),
      functionParams().then((value) => httpResponse = value),
    ]);

    /// Check httpResponse if it's null or not
    final res = httpResponse;
    if (res != null) {
      if (res.statusCode == HttpStatus.ok) {
        /// returns success if status code is 200
        return DataSuccess(res.data);
      }

      /// returns failed if status code is not 200
      return DataFailed(DioError(
        error: res.statusMessage,
        response: res,
        requestOptions: res.requestOptions,
      ));
    } else {
      /// returns failed if response is null
      return NetworkConstants().datafailed();
    }
  }
}
