import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:transport_scolaire/core/api/api_client.dart';
import 'package:transport_scolaire/features/auth/data/auth_api.dart';
import 'package:transport_scolaire/features/auth/data/auth_repository.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepository(AuthApi(ApiClient()));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authRepository.logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: const Center(
        child: Text('Welcome!'),
      ),
    );
  }
}
