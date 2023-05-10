import 'package:flutter/material.dart';
import 'package:flutter_mfa/screen/login_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/helper.dart';
import 'mfa_enroll_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  static const route = '/screen/register';

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mendaftar')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          _emailForm(),
          const SizedBox(height: 16),
          _passwordForm(),
          const SizedBox(height: 16),
          _registerButton(),
          const SizedBox(height: 16),
          _loginButton(),
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

  _registerButton() {
    return ElevatedButton(
      onPressed: () async {
        try {
          setState(() {
            _isLoading = true;
          });
          final email = _emailController.text.trim();
          final password = _passwordController.text.trim();
          await supabase.auth.signUp(
            email: email,
            password: password,
            emailRedirectTo:
                'mfa-app://callback${MFAEnrollScreen.route}', // redirect the user to setup MFA page after email confirmation
          );
          if (mounted) {
            ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text('Cek Inbox')));
          }
        } on AuthException catch (error) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(error.message)));
        } catch (error) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Error tak terduga')));
        }
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      },
      child: _isLoading
          ? const SizedBox(
              height: 24,
              width: 24,
              child:
                  Center(child: CircularProgressIndicator(color: Colors.white)),
            )
          : const Text('Daftar'),
    );
  }

  _loginButton() {
    return TextButton(
      onPressed: () => context.push(LoginScreen.route),
      child: const Text('Sudah punya akun'),
    );
  }
}
