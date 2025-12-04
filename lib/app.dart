import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:transport_scolaire/features/auth/presentation/screens/auth_screen.dart';
import 'package:transport_scolaire/features/auth/presentation/screens/login_screen.dart';
import 'package:transport_scolaire/features/auth/presentation/screens/register_screen.dart';
import 'package:transport_scolaire/features/home/presentation/screens/home_screen.dart';

const primaryColor = Color(0xFF424242);
const whiteColor = Color(0xFFF5F5EF);

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: _router,
      theme: ThemeData(
        primaryColor: primaryColor,
        scaffoldBackgroundColor: whiteColor,
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),
        useMaterial3: true,
        fontFamily: GoogleFonts.lato().fontFamily,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: primaryColor,
            foregroundColor: whiteColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.0),
            ),
          ),
        ),
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

final _router = GoRouter(
  initialLocation: '/login',
  routes: [
    GoRoute(
      path: '/login',
      builder: (context, state) => const AuthScreen(child: LoginScreen()),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => const AuthScreen(child: RegisterScreen()),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
  ],
);
