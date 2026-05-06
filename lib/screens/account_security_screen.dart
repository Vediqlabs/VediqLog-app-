import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../l10n/app_localizations.dart';

class AccountSecurityScreen extends StatelessWidget {
  AccountSecurityScreen({super.key});

  final supabase = Supabase.instance.client;

  Future<void> logoutAllDevices(BuildContext context) async {
    await supabase.auth.signOut(
      scope: SignOutScope.global,
    );

    if (context.mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.accountSecurity),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListTile(
                title: Text(t.logoutAllDevices),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(t.logoutEverywhere),
                      content: Text(t.logoutAllDevicesMessage),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(t.cancel),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            logoutAllDevices(context);
                          },
                          child: Text(t.logout),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
