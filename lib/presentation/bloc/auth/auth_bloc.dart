import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:sms_app/local_db/shared_preferences/shared_preferences.dart';
import 'package:sms_app/local_db/shared_preferences/shared_prefs_helper.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(const AuthInitial()) {
    on<AuthEvent>((event, emit) async {
      if (event is GetStoredAuthEvent) {
        await _getStoredAuthEvent(emit);
      }
      if (event is LoginEvent) {
        await _login(emit);
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

  Future<void> _login(Emitter<AuthState> emit) async {
    emit(const LoadingAuthState());
    emit(const AuthenticatedState());

    // Sample use of API
    // if (loginParams != null) {
    //   DataState data = await AuthRepository().login(loginParams: loginParams);

    //   if (data is DataSuccess) {
    //     LoginModel loginModel = data.data;
    //     Logger().e(loginModel.toJson());

    //     // Sample use of API
    //     if (loginModel.jwt?.access != null && loginModel.jwt!.access!.isNotEmpty) {
    //       SharedPrefsUtil().storeString(SharedPrefsHelper.token, loginModel.jwt!.access!);

    //       //insert user account
    //       Map<String, dynamic> userAccount = {'email': loginParams.email, 'password': loginParams.password};
    //       int accountId = await UserAccountDBHelper.insert(userAccount);

    //       //insert user information
    //       Map<String, dynamic> userInfo = {
    //         'id': accountId,
    //         'first_name': loginModel.jwt?.user?.firstName,
    //         'last_name': loginModel.jwt?.user?.firstName,
    //         'logo': loginModel.jwt?.user?.avatarUrl,
    //         'name': loginModel.jwt?.user?.getDisplayName,
    //       };
    //       await UserInfoDBHelper.insert(userInfo);
    //     }

    //     emit(AuthenticatedState());
    //   } else {
    //     emit(UnauthenticatedState());
    //   }
    // } else {
    //   emit(UnauthenticatedState());
    // }
  
  await SharedPrefsUtil().storeString(SharedPrefsHelper.token, 'fake-access-token');
  
  emit(const AuthenticatedState());
  }

  Future<void> _logoutEvent(Emitter<AuthState> emit) async {
    emit(const LoadingAuthState());
    await SharedPrefsUtil().storeString(SharedPrefsHelper.token, '');
    
    emit(const UnauthenticatedState());
  }
}
