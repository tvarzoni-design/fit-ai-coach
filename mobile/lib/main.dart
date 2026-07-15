import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'core/services/api_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/notification_polling_service.dart';
import 'core/services/notification_service.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final authService = AuthService();
  await authService.init();

  runApp(FitAiCoachApp(authService: authService));
}

class FitAiCoachApp extends StatefulWidget {
  final AuthService authService;
  const FitAiCoachApp({super.key, required this.authService});

  @override
  State<FitAiCoachApp> createState() => _FitAiCoachAppState();
}

class _FitAiCoachAppState extends State<FitAiCoachApp> {
  late final NotificationPollingService _notificationService;
  late final NotificationService _inAppNotificationService;

  @override
  void initState() {
    super.initState();
    _notificationService = NotificationPollingService(widget.authService);
    _inAppNotificationService = NotificationService();

    if (widget.authService.isAuthenticated) {
      _notificationService.startPolling();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: widget.authService),
        ChangeNotifierProvider(create: (_) => ApiService()),
        ChangeNotifierProvider.value(value: _notificationService),
        Provider<NotificationService>.value(value: _inAppNotificationService),
      ],
      child: MaterialApp.router(
        title: 'Fit AI Coach',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        routerConfig: AppRouter.router,
        builder: (context, child) {
          return Scaffold(
            key: _inAppNotificationService.scaffoldMessengerKey,
            body: child,
          );
        },
      ),
    );
  }
}
