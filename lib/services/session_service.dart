import 'package:supabase_flutter/supabase_flutter.dart';

class SessionService {
  final supabase = Supabase.instance.client;

  Future<String> createSession({
    required String doctorId,
    required String issue,
  }) async {
    final user = supabase.auth.currentUser;

    final res = await supabase
        .from('sessions')
        .insert({
          'user_id': user!.id,
          'doctor_id': doctorId,
          'issue': issue,
          'status': 'active'
        })
        .select()
        .single();

    return res['id'];
  }
}
