import 'package:flutter/material.dart';
import 'package:flutter_mfa/screen/mfa_verify_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/helper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  static const route = '/screen/login';

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          _emailForm(),
          const SizedBox(height: 16),
          _passwordForm(),
          const SizedBox(height: 16),
          _actionButton(),
        ],
      ),
    );
  }

  _emailForm() {
    return TextFormField(
      controller: _emailController,
      decoration: const InputDecoration(
        label: Text('Email'),
      ),
    );
  }

  _passwordForm() {
    return TextFormField(
      controller: _passwordController,
      decoration: const InputDecoration(
        label: Text('Password'),
      ),
      obscureText: true,
    );
  }

  _actionButton() {
    return ElevatedButton(
      onPressed: () async {
        try {
          final email = _emailController.text.trim();
          final password = _passwordController.text.trim();
          await supabase.auth.signInWithPassword(
            email: email,
            password: password,
          );
          if (mounted) {
            context.go(MFAVerifyScreen.route);
          }
        } on AuthException catch (error) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(error.message)));
        } catch (error) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Handle Error')));
        }
      },
      child: const Text('Login'),
    );
  }
}
