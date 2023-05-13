import 'package:flutter/material.dart';
import 'package:flutter_mfa/screen/register_screen.dart';
import 'package:go_router/go_router.dart';

import '../utils/helper.dart';
import 'list_maf_screen.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  static const route = '/screen/home';

  final privatePostsFuture =
      supabase.from('private_posts').select<List<Map<String, dynamic>>>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: _contentBody(),
    );
  }

  _appBar() {
    return AppBar(
      title: const Text('Home'),
      actions: [
        PopupMenuButton(
          itemBuilder: (context) {
            return [
              PopupMenuItem(
                child: const Text('Unenroll MFA'),
                onTap: () {
                  context.push(ListMFAScreen.route);
                },
              ),
              PopupMenuItem(
                child: const Text('Logout'),
                onTap: () {
                  supabase.auth.signOut();
                  context.go(RegisterScreen.route);
                },
              ),
            ];
          },
        )
      ],
    );
  }

  _contentBody() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: privatePostsFuture,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final data = snapshot.data!;
        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            return ListTile(title: Text(data[index]['content']));
          },
        );
      },
    );
  }
}
