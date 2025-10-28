import 'package:flutter/material.dart';
import '../services/user_manager.dart';
import '../services/notification_sender.dart';

// VIOLATES Dependency Inversion Principle
// This high-level UI component directly depends on low-level concrete classes
// instead of abstractions/interfaces
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // DIP VIOLATION: Directly instantiating concrete classes
  // Should depend on abstractions instead
  final UserManager _userManager = UserManager();
  final NotificationSender _notificationSender = NotificationSender();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Email field with duplicated validation
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) => _validateEmail(value),
            ),
            const SizedBox(height: 16),
            // Password field with duplicated validation
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              validator: (value) => _validatePassword(value),
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _login, child: const Text('Login')),
            const SizedBox(height: 16),
            // DIP VIOLATION: Creating another concrete dependency
            ListenableBuilder(
              listenable: _userManager,
              builder: (context, child) {
                if (_userManager.isLoading) {
                  return const CircularProgressIndicator();
                }
                if (_userManager.errorMessage != null) {
                  return Text(
                    _userManager.errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  // Duplicated validation logic from other places
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email cannot be empty';
    }
    if (!value.contains('@') || !value.contains('.')) {
      return 'Invalid email format';
    }
    return null;
  }

  // More duplicated validation logic
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password cannot be empty';
    }
    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }
    return null;
  }

  Future<void> _login() async {
    // Duplicated validation again
    final email = _emailController.text;
    final password = _passwordController.text;

    if (email.isEmpty || !email.contains('@') || !email.contains('.')) {
      _showError('Invalid email format');
      return;
    }
    if (password.isEmpty || password.length < 8) {
      _showError('Password must be at least 8 characters');
      return;
    }

    // DIP VIOLATION: Directly calling concrete class methods
    final success = await _userManager.login(email, password);

    if (success) {
      // DIP VIOLATION: Another direct concrete class usage
      await _notificationSender.sendNotification(
        'push',
        _userManager.currentUser!.id,
        'Welcome back!',
        null,
      );

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
