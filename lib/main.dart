import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'core/theme.dart';
import 'core/theme_provider.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/register_screen.dart';
import 'features/auth/forgot_password_screen.dart';
import 'features/auth/splash_screen.dart';
import 'features/dashboard/dashboard_layout.dart';
import 'features/visitas/visit_workflow_screen.dart';
import 'features/ventas/sale_workflow_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);
  runApp(
    const ProviderScope(
      child: ZeroControlApp(),
    ),
  );
}

final _router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const DashboardLayout(),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),
    GoRoute(
      path: '/visit-workflow',
      builder: (context, state) {
        final id = state.uri.queryParameters['id'];
        return VisitWorkflowScreen(activoId: id);
      },
    ),
    GoRoute(
      path: '/sale-workflow',
      builder: (context, state) {
        final id = state.uri.queryParameters['id'];
        return SaleWorkflowScreen(ventaId: id!);
      },
    ),
  ],
);

class ZeroControlApp extends ConsumerWidget {
  const ZeroControlApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'ZeroCONTROL',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: _router,
    );
  }
}
