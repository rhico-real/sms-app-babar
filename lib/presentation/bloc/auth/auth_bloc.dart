import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:logger/logger.dart';
import 'package:sms_app/core/data_state.dart';
import 'package:sms_app/local_db/shared_preferences/shared_preferences.dart';
import 'package:sms_app/local_db/shared_preferences/shared_prefs_helper.dart';
import 'package:sms_app/network/models/auth/auth_model.dart';
import 'package:sms_app/network/params/auth/auth_params.dart';
import 'package:sms_app/network/repository/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthInitial()) {
    on<AuthEvent>((event, emit) async {
      if (event is GetStoredAuthEvent) {
        await _getStoredAuthEvent(emit);
      }
      if (event is LoginEvent) {
        await _login(emit, event.loginParams);
      }
      if (event is LogoutEvent) {
        await _logoutEvent(emit);
      }
    });
  }

  Future<void> _getStoredAuthEvent(Emitter<AuthState> emit) async {
    emit(const LoadingAuthState());
    String accessToken = (await SharedPrefsUtil().getString(SharedPrefsHelper.token)) ?? '';
    if (accessToken.isNotEmpty) {
      emit(const AuthenticatedState());
    } else {
      emit(const UnauthenticatedState());
    }
  }

  Future<void> _login(Emitter<AuthState> emit, LoginParams? loginParams)async {
    emit(const LoadingAuthState());

    if (loginParams != null) {
      DataState data = await AuthRepository().login(loginParams: loginParams);

      if (data is DataSuccess) {
        LoginModel loginModel = data.data;
        Logger().e(loginModel.toJson());

        if (loginModel.user?.tokens?.access != null && loginModel.user!.tokens!.access!.isNotEmpty) {
          SharedPrefsUtil().storeString(SharedPrefsHelper.token, loginModel.user!.tokens!.access!);
        }

        emit(AuthenticatedState());
      } else {
        Logger().e(data);
        emit(ErrorLoginState());
        emit(UnauthenticatedState());
      }
    } else {
      emit(UnauthenticatedState());
    }
  }

  Future<void> _logoutEvent(Emitter<AuthState> emit) async {
    emit(const LoadingAuthState());
    await SharedPrefsUtil().storeString(SharedPrefsHelper.token, '');
    
    emit(const UnauthenticatedState());
  }
}
