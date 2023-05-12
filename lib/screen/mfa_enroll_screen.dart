import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mfa/screen/home_screen.dart';
import 'package:flutter_mfa/screen/register_screen.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../utils/helper.dart';

class MFAEnrollScreen extends StatefulWidget {
  const MFAEnrollScreen({super.key});
  static const route = '/screen/enroll';

  @override
  State<MFAEnrollScreen> createState() => _MFAEnrollScreenState();
}

class _MFAEnrollScreenState extends State<MFAEnrollScreen> {
  final _enrollFuture = supabase.auth.mfa.enroll();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: FutureBuilder(
        future: _enrollFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final response = snapshot.data!;
          final qrCodeUrl = response.totp.qrCode;
          final secret = response.totp.secret;
          final factorId = response.id;

          return _contentBody(qrCodeUrl, secret, factorId);
        },
      ),
    );
  }

  _appBar() {
    return AppBar(
      title: const Text('Setup MFA'),
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

  _contentBody(String qrCodeUrl, String secret, String factorId) {
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 24,
      ),
      children: [
        const Text(
          'Buka Autentifikasi 2 Faktor',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        SvgPicture.string(
          qrCodeUrl,
          width: 150,
          height: 150,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Text(
                secret,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            IconButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: secret));
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('salin clip board')));
              },
              icon: const Icon(Icons.copy),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text('masukan code yang tertera di aplikasi authentifikas.'),
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
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Handle Error')));
            }
          },
        ),
      ],
    );
  }
}
