import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MembershipProvider with ChangeNotifier {
  final supabase = Supabase.instance.client;

  bool isActive = false;
  DateTime? expiry;
  bool loading = true;

  Future<void> loadMembership() async {
    final user = supabase.auth.currentUser;
    if (user == null) return;

    final data = await supabase
        .from('profiles')
        .select('membership_active, membership_expiry')
        .eq('id', user.id)
        .maybeSingle();

    if (data != null) {
      final exp = data['membership_expiry'];

      if (exp != null) {
        expiry = DateTime.parse(exp);

        // auto expire check
        isActive = expiry!.isAfter(DateTime.now());
      } else {
        isActive = false;
      }
    }

    loading = false;
    notifyListeners();
  }

  void refresh() {
    loadMembership();
  }
}
