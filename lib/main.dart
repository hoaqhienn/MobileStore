import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_store/screens/main/home_page.dart';
import 'package:mobile_store/screens/auth/login_page.dart';
import 'package:mobile_store/screens/auth/registration_page.dart';
import 'package:mobile_store/cubits/auth_cubit.dart';
import 'package:mobile_store/cubits/cart_cubit.dart';
import 'package:mobile_store/cubits/product_cubit.dart';
import 'package:mobile_store/utils/shared_prefs_util.dart';

import 'cubits/auth_state.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Required for SharedPreferences

  // Initialize utilities and cubits
  final sharedPrefsUtil = SharedPrefsUtil();
  final authCubit = AuthCubit();

  // Wait for auth status check
  await authCubit.checkAuthStatus();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider.value(value: authCubit),
        BlocProvider(
          create: (context) => ProductCubit()..fetchProducts(),
        ),
        BlocProvider(
          create: (context) => CartCubit(
            prefsUtil: sharedPrefsUtil,
            authCubit: authCubit,
          )..loadCart(), // Load cart data on initialization
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Mobile Store',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            useMaterial3: true,
          ),
          home: _buildInitialScreen(authState),
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case '/':
                return MaterialPageRoute(
                  builder: (context) => const HomePage(),
                );
              case '/login':
                return MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                );
              case '/register':
                return MaterialPageRoute(
                  builder: (context) => const RegistrationPage(),
                );
              default:
                return MaterialPageRoute(
                  builder: (context) => Scaffold(
                    body: Center(
                      child: Text('No route defined for ${settings.name}'),
                    ),
                  ),
                );
            }
          },
          navigatorObservers: [
            // Add route observer for analytics or other purposes
            RouteObserver<PageRoute>(),
          ],
        );
      },
    );
  }

  Widget _buildInitialScreen(AuthState authState) {
    if (authState.isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (authState.isAuthenticated) {
      return const HomePage();
    }
    return const HomePage();

    // return const LoginPage();
  }
}

// Optional: Add a custom navigator observer for route tracking
class AppNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // Add analytics tracking or logging here
    if (kDebugMode) {
      print('New route pushed: ${route.settings.name}');
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    // Add analytics tracking or logging here
    if (kDebugMode) {
      print('Route popped: ${route.settings.name}');
    }
  }
}

// Optional: Add a custom page route builder for transitions
class AppPageRoute<T> extends MaterialPageRoute<T> {
  AppPageRoute({
    required super.builder,
    super.settings,
  });

  @override
  Widget buildTransitions(
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
      ) {
    // Custom transition animation
    return FadeTransition(opacity: animation, child: child);
  }
}