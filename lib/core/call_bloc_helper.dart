
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms_app/main.dart';
import 'package:sms_app/presentation/bloc/appointment/appointment_bloc.dart';
import 'package:sms_app/presentation/bloc/auth/auth_bloc.dart';
import 'package:sms_app/presentation/bloc/sms/sms_bloc.dart';

final authBloc = BlocProvider.of<AuthBloc>(MainApp.navigatorKey.currentContext!);
final smsbloc = BlocProvider.of<SmsBloc>(MainApp.navigatorKey.currentContext!);
final appointmentBloc = BlocProvider.of<AppointmentBloc>(MainApp.navigatorKey.currentContext!);
