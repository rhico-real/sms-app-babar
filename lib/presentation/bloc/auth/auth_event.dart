part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class GetStoredAuthEvent extends AuthEvent {}

class LoginEvent extends AuthEvent {
  final LoginParams? loginParams;

  const LoginEvent({this.loginParams});

  @override
  List<Object> get props => [];
}

class LogoutEvent extends AuthEvent {
  const LogoutEvent();
}
