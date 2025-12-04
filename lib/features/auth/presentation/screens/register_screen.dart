import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:transport_scolaire/core/api/api_client.dart';
import 'package:transport_scolaire/features/auth/data/auth_api.dart';
import 'package:transport_scolaire/features/auth/data/auth_repository.dart';
import 'package:transport_scolaire/features/auth/presentation/widgets/input_field.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _roleController = TextEditingController();
  final _authRepository = AuthRepository(AuthApi(ApiClient()));

  bool _isLoading = false;

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        await _authRepository.register(
          email: _emailController.text,
          password: _passwordController.text,
          fullName: _fullNameController.text,
          role: _roleController.text,
        );
        if (mounted) {
          context.go('/login');
        }
      } catch (e) {
        if (mounted) {
          String errorMessage = 'Failed to register';
          if (e is DioException && e.response?.data != null) {
            errorMessage =
                e.response?.data['message'] ?? 'An unknown error occurred';
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(errorMessage), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.directions_bus,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Create Account',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 0),
            const Text(
              'Please fill the form to create an account',
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 32),
            InputField(
              controller: _fullNameController,
              labelText: 'Full Name',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your full name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            InputField(
              controller: _emailController,
              labelText: 'Email',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your email';
                }
                if (!value.contains('@')) {
                  return 'Please enter a valid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            InputField(
              controller: _passwordController,
              labelText: 'Password',
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your password';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            InputField(
              controller: _roleController,
              labelText: 'Role',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your role';
                }
                return null;
              },
            ),
            const SizedBox(height: 32),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _register,
                    child: const Text('Sign Up'),
                  ),
            const SizedBox(height: 16),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).primaryColor,
              ),
              onPressed: () {
                context.go('/login');
              },
              child: const Text('Already have an account? Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}
