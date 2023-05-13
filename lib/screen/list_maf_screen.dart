import 'package:flutter/material.dart';
import 'package:flutter_mfa/screen/register_screen.dart';
import 'package:go_router/go_router.dart';

import '../utils/helper.dart';

class ListMFAScreen extends StatelessWidget {
  ListMFAScreen({super.key});
  static const route = '/screen/list_mfa';

  final _factorListFuture = supabase.auth.mfa.listFactors();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('List MFA Factors')),
      body: FutureBuilder(
        future: _factorListFuture,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final response = snapshot.data!;
          final factors = response.all;
          return ListView.builder(
            itemCount: factors.length,
            itemBuilder: (context, index) {
              final factor = factors[index];
              return ListTile(
                title: Text(factor.friendlyName ?? factor.factorType.name),
                subtitle: Text(factor.status.name),
                trailing: IconButton(
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text(
                              'Apakah anda yakin untuk menghapus ini? kamu akan keluar dari aplikasi setelah menghapusnya.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  context.pop();
                                },
                                child: const Text('batal'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  await supabase.auth.mfa.unenroll(factor.id);
                                  await supabase.auth.signOut();
                                  if (context.mounted) {
                                    context.go(RegisterScreen.route);
                                  }
                                },
                                child: const Text('hapus'),
                              ),
                            ],
                          );
                        });
                  },
                  icon: const Icon(Icons.delete_outline),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
