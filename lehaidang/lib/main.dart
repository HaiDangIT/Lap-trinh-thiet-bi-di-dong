import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'services/auth_service.dart';
import 'services/event_service.dart';
import 'services/notification_service.dart';
import 'screens/login_screen.dart';
import 'screens/user/user_calendar_screen.dart';
import 'screens/admin/admin_dashboard_screen_new.dart';
import 'screens/manager/manager_dashboard_screen.dart';

Future<void> main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env file
  await dotenv.load(fileName: ".env");

  // Khởi tạo Notification Service
  final notificationService = NotificationService();
  await notificationService.initialize();
  await notificationService.requestPermissions();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => EventService()),
      ],
      child: MaterialApp(
        title: 'Quản Lý Lịch',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.grey.shade50,
          ),
        ),
        home: const AuthWrapper(),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthService>(
      builder: (context, authService, child) {
        print('🔍 AuthWrapper - isLoggedIn: ${authService.isLoggedIn}');
        print(
          '🔍 AuthWrapper - currentUser: ${authService.currentUser?.email}',
        );
        print('🔍 AuthWrapper - role: ${authService.currentUser?.role}');
        print('🔍 AuthWrapper - isAdminRole: ${authService.isAdminRole}');
        print('🔍 AuthWrapper - isManager: ${authService.isManager}');

        if (authService.isLoggedIn) {
          // Route based on user role
          if (authService.isAdminRole) {
            print('✅ Routing to AdminDashboardScreen');
            return const AdminDashboardScreen();
          } else if (authService.isManager) {
            print('✅ Routing to ManagerDashboardScreen');
            return const ManagerDashboardScreen();
          } else {
            print('✅ Routing to UserCalendarScreen');
            return const UserCalendarScreen();
          }
        }
        print('❌ Not logged in - showing LoginScreen');
        return const LoginScreen();
      },
    );
  }
}
