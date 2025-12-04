import 'package:flutter/material.dart';

class AuthScreen extends StatelessWidget {
  final Widget child;

  const AuthScreen({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5EF),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 400),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
