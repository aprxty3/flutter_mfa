import 'package:flutter/material.dart';
import 'package:flutter_mfa/screen/register_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/helper.dart';
import 'home_screen.dart';

class MFAVerifyScreen extends StatelessWidget {
  const MFAVerifyScreen({super.key});
  static const route = '/screen/verify';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(context),
      body: _bodyContent(context, true),
    );
  }

  _appBar(context) {
    return AppBar(
      title: const Text('Verify MFA'),
      actions: [
        TextButton(
          onPressed: () {
            supabase.auth.signOut();
            context.go(RegisterScreen.route);
          },
          child: Text(
            'Keluar',
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          ),
        ),
      ],
    );
  }

  _bodyContent(context, mounted) {
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 24,
      ),
      children: [
        Text(
          'Verification Required',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        const Text('Enter the code shown in your authentication app.'),
        const SizedBox(height: 16),
        TextFormField(
          decoration: const InputDecoration(
            hintText: '000000',
          ),
          style: const TextStyle(fontSize: 24),
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          onChanged: (value) async {
            if (value.length != 6) return;

            try {
              final factorsResponse = await supabase.auth.mfa.listFactors();
              final factor = factorsResponse.totp.first;
              final factorId = factor.id;

              final challenge =
                  await supabase.auth.mfa.challenge(factorId: factorId);
              await supabase.auth.mfa.verify(
                factorId: factorId,
                challengeId: challenge.id,
                code: value,
              );
              await supabase.auth.refreshSession();
              if (mounted) {
                context.go(HomeScreen.route);
              }
            } on AuthException catch (error) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(error.message)));
            } catch (error) {
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Unexpected error occurred')));
            }
          },
        ),
      ],
    );
  }
}
