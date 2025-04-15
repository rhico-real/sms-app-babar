
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms_app/main.dart';
import 'package:sms_app/presentation/bloc/auth/auth_bloc.dart';

final authBloc = BlocProvider.of<AuthBloc>(MainApp.navigatorKey.currentContext!);
