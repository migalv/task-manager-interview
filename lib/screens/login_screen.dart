import 'package:flutter/material.dart';
import '../services/user_manager.dart';
import '../services/notification_sender.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

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
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              validator: (value) => _validateEmail(value),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              validator: (value) => _validatePassword(value),
            ),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: _login, child: const Text('Login')),
            const SizedBox(height: 16),
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

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email cannot be empty';
    }
    if (!value.contains('@') || !value.contains('.')) {
      return 'Invalid email format';
    }
    return null;
  }

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

    final success = await _userManager.login(email, password);

    if (success) {
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
