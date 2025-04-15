
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms_app/presentation/bloc/auth/auth_bloc.dart';
import 'package:sms_app/presentation/views/auth/login_screen.dart';
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
            // TODO: DASHBOARD SCREEN
            return Placeholder();
          }
          return const BlankScaffoldPage();
        },
      ),
    );
  }
}