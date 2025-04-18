import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:sms_app/presentation/bloc/auth/auth_bloc.dart';

final injector = GetIt.instance;

//This is dependency injection

class Injector {
  Future<void> initializeDependencies() async {
    // Dio client
    injector.registerSingleton<Dio>(Dio());

    // Dependencies and API services

    // Repositories

    // UseCases

    // Blocs
    injector.registerFactory<AuthBloc>(() => AuthBloc());
  }
}
