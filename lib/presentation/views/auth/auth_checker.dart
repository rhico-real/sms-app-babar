import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms_app/presentation/bloc/auth/auth_bloc.dart';
import 'package:sms_app/presentation/bloc/sms/sms_bloc.dart';
import 'package:sms_app/presentation/views/auth/login_screen.dart';
import 'package:sms_app/presentation/views/dashboard_screen.dart';
import 'package:sms_app/presentation/widgets/blank_scaffold.dart';

class AuthChecker extends StatefulWidget {
  const AuthChecker({super.key});

  @override
  State<AuthChecker> createState() => _AuthCheckerState();
}

class _AuthCheckerState extends State<AuthChecker> {
  @override
  void initState() {
    super.initState();
    
    // Check if user is already authenticated and start listening for SMS
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthenticatedState) {
        // Refresh SMS messages when authenticated
        context.read<SmsBloc>().add(RefreshMessages());
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {},
        buildWhen: (previous, state) {
          if (state is LoadingAuthState) {
            return false;
          }
          return true;
        },
        builder: (context, state) {
          if (state is UnauthenticatedState) {
            return const LoginScreen();
          } else if (state is AuthenticatedState) {
            // Use our dashboard screen
            return const DashboardScreen();
          }
          return const BlankScaffoldPage();
        },
      ),
    );
  }
}