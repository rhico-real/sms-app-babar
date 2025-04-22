import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sms_app/config/app_routes.dart';
import 'package:sms_app/core/injector.dart';
import 'package:sms_app/core/notification_service.dart';
import 'package:sms_app/core/pending_message_processor.dart';
import 'package:sms_app/local_db/sms_service.dart';
import 'package:sms_app/core/background_bloc_helper.dart';
import 'package:sms_app/presentation/bloc/appointment/appointment_bloc.dart';
import 'package:sms_app/presentation/bloc/auth/auth_bloc.dart';
import 'package:sms_app/presentation/bloc/sms/sms_bloc.dart';
import 'package:sms_app/core/sms_listener.dart';

@pragma('vm:entry-point')
Future<void> main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Set up dependencies
  await Injector().initializeDependencies();
  
  // Set up environment
  await dotenv.load(fileName: ".env");
  
  // Initialize notification service first
  await NotificationService().initialize();
  
  // Initialize SMS service
  await SmsService().initNotifications();
  
  // Start SMS listener at application startup
  await SmsListener().startListening();
  
  // Show persistent notification that app is listening
  // Short delay to ensure everything is initialized
  await Future.delayed(const Duration(seconds: 1));
  
  // Cancel any existing notifications first to prevent duplicates
  try {
    await NotificationService().cancelListeningNotification();
  } catch (e) {
    // This is expected on first run
    if (kDebugMode) {
      print('Note: Cancelling previous notifications returned: $e');
    }
  }
  
  // Show the persistent notification and initiate foreground service 
  try {
    // Trigger the platform-specific foreground service first
    try {
      final MethodChannel methodChannel = MethodChannel('com.babar.sms_app/sms');
      await methodChannel.invokeMethod('setupPeriodicChecking');
      if (kDebugMode) {
        print('Native foreground service started successfully');
      }
    } catch (e) {
      // This might fail on first run, which is expected
      if (kDebugMode) {
        print('Note: Native service setup returned: $e');
      }
    }
    
    // Add a small delay to ensure the service is started
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Then show notification through Flutter's notification system
    await NotificationService().showListeningNotification();
    
    if (kDebugMode) {
      print('Persistent notification displayed successfully');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Error showing persistent notification: $e');
    }
  }
  
  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> with WidgetsBindingObserver {
  Key key = UniqueKey();
  bool _hasProcessedPendingMessages = false;
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Schedule processing of pending messages after UI is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _processPendingMessages();
    });
  }
  
  // Process any pending messages
  Future<void> _processPendingMessages() async {
    try {
      if (!_hasProcessedPendingMessages) {
        if (kDebugMode) {
          print('Processing pending messages after app start');
        }
        await Future.delayed(const Duration(seconds: 2)); // Wait for blocs to fully initialize
        await PendingMessageProcessor().processPendingMessages();
        _hasProcessedPendingMessages = true;
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error processing pending messages: $e');
      }
    }
  }
  
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle changes
    if (state == AppLifecycleState.resumed) {
      // App is in the foreground again
      // Process any pending messages that might have been received while app was in background
      _processPendingMessages();
    } else if (state == AppLifecycleState.paused) {
      // App is minimized but still running
      // Ensure the notification is showing
      NotificationService().showListeningNotification();
    } else if (state == AppLifecycleState.detached) {
      // App is completely closed/terminated
      // We'll leave the notification running in this case since we want
      // the service to keep running even when the app is minimized
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => injector()..add(GetStoredAuthEvent()),
        ),
        BlocProvider<SmsBloc>(
          create: (context) {
            final bloc = SmsBloc()..add(LoadSmsMessages());
            // Register with both services for background operations
            SmsService.registerBloc(bloc);
            BackgroundBlocHelper.registerSmsBloc(bloc);
            return bloc;
          },
        ),
        BlocProvider<AppointmentBloc>(
          create: (context) {
            final bloc = AppointmentBloc();
            // Register for background operations
            BackgroundBlocHelper.registerAppointmentBloc(bloc);
            return bloc;
          }
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