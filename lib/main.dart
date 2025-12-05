import 'package:flutter/material.dart';

// 1. Import your screens
import 'features/tracking/presentation/simulation_screen.dart';
import 'features/tracking/presentation/live_map_screen.dart';
import 'features/tracking/presentation/scenario_screen.dart';

void main() {
  // No need for async or dotenv loading anymore
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // --- CONTROL VARIABLE ---
  // Change this to true or false to test the logic
  static const bool _isDevMode = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Microservice Tester',
      // Professional Theme Configuration
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5), // Professional Blue
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          iconTheme: IconThemeData(color: Colors.black87),
        ),
      ),
      // Simple conditional check based on the boolean above
      home: _isDevMode ? const ProfessionalDashboard() : const EnvErrorScreen(),
    );
  }
}

// --- SCREEN 1: THE PROFESSIONAL DASHBOARD ---
class ProfessionalDashboard extends StatelessWidget {
  const ProfessionalDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Tracking Microservice")),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            // Header Section
            const Padding(
              padding: EdgeInsets.only(bottom: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome, Developer",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Select a simulation mode to test the backend tracking services.",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ],
              ),
            ),

            // Option 1: Single Driver
            _MenuCard(
              title: "Single Driver App",
              subtitle: "Emulates a real driver using device GPS.",
              icon: Icons.person_pin_circle_outlined,
              color: Colors.blue.shade700,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SimulationScreen()),
              ),
            ),

            // Option 2: Scenario Builder
            _MenuCard(
              title: "Scenario Builder",
              subtitle: "Simulate a fleet with smart routing.",
              icon: Icons.hub_outlined,
              color: Colors.purple.shade700,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ScenarioScreen()),
              ),
            ),

            // Option 3: Admin Map
            _MenuCard(
              title: "Admin Dashboard",
              subtitle: "Live view of all active entities.",
              icon: Icons.map_outlined,
              color: Colors.orange.shade800,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LiveMapScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- HELPER: STYLED CARD WIDGET ---
class _MenuCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- SCREEN 2: ERROR SCREEN ---
class EnvErrorScreen extends StatelessWidget {
  const EnvErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEF2F2),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.lock_person_rounded,
                  size: 60,
                  color: Colors.red.shade400,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Development Mode Locked",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade900,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "You must enable developer mode in the code to access these tools.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: const Column(
                  children: [
                    Text(
                      "Set this variable to true in main.dart:",
                      style: TextStyle(fontSize: 14, color: Colors.black45),
                    ),
                    SizedBox(height: 8),
                    SelectableText(
                      'static const bool _isDevMode = true;',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
