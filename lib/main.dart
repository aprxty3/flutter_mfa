import 'package:flutter/material.dart';
import 'package:flutter_mfa/utils/helper.dart';
import 'package:flutter_mfa/utils/routing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await Supabase.initialize(
    url: 'https://dlhtoatbdpmenvzfynks.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImRsaHRvYXRiZHBtZW52emZ5bmtzIiwicm9sZSI6ImFub24iLCJpYXQiOjE2ODM3MDY0NTgsImV4cCI6MTk5OTI4MjQ1OH0.mfiegVRT8mGMGgS7yT63KKm2Xn7Xoqs81VVuH3jHxM4',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Flutter MFA',
      theme: appTheme,
      routerConfig: router,
    );
  }
}
