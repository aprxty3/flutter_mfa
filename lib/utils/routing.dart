import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../screen/home_screen.dart';
import '../screen/list_maf_screen.dart';
import '../screen/login_screen.dart';
import '../screen/mfa_enroll_screen.dart';
import '../screen/mfa_verify_screen.dart';
import '../screen/register_screen.dart';
import 'helper.dart';

final router = GoRouter(
  routes: [
    GoRoute(
      path: HomeScreen.route,
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: ListMFAScreen.route,
      builder: (context, state) => const ListMFAScreen(),
    ),
    GoRoute(
      path: LoginScreen.route,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: RegisterScreen.route,
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: MFAEnrollScreen.route,
      builder: (context, state) => const MFAEnrollScreen(),
    ),
    GoRoute(
      path: MFAVerifyScreen.route,
      builder: (context, state) => const MFAVerifyScreen(),
    ),
  ],
  redirect: (context, state) async {
    if (state.location.contains('/screen') == true) {
      return null;
    }

    final session = supabase.auth.currentSession;
    if (session == null) {
      return RegisterScreen.route;
    }

    final assuranceLevelData =
        supabase.auth.mfa.getAuthenticatorAssuranceLevel();
    if (assuranceLevelData.currentLevel == AuthenticatorAssuranceLevels.aal1) {
      await supabase.auth.refreshSession();
      final nextLevel =
          supabase.auth.mfa.getAuthenticatorAssuranceLevel().nextLevel;
      if (nextLevel == AuthenticatorAssuranceLevels.aal2) {
        return MFAVerifyScreen.route;
      } else {
        return MFAEnrollScreen.route;
      }
    }

    return null;
  },
);
