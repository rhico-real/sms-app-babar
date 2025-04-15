import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sms_app/config/app_routes.dart';
import 'package:sms_app/core/injector.dart';
import 'package:sms_app/presentation/bloc/auth/auth_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Injector().initializeDependencies();
  // InitDB.database();
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  Key key = UniqueKey();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => injector()..add(GetStoredAuthEvent()),
        ),
      ],
      child: MaterialApp(
        title: 'BABAR APPOINTMENT SYSTEM SMS App',
        debugShowCheckedModeBanner: false,
        onGenerateRoute: AppRoutes.onGenerateRoutes,
        navigatorKey: MainApp.navigatorKey,
        initialRoute: '/',
      ),
    );
  }
}
