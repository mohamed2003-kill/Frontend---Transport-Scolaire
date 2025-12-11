// lib/main.dart
import 'package:flutter/material.dart';

import 'package:transport_scolaire/features/notifications/presentation/screens/notification_history_screen.dart';
import 'package:transport_scolaire/features/notifications/presentation/push_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PushHandler().initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Transport Scolaire',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const NotificationHistoryScreen(userId: '1'),
    );
  }
}
