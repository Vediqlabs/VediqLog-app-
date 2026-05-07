import 'package:supabase_flutter/supabase_flutter.dart';

class MessageService {
  final supabase = Supabase.instance.client;

  Future<void> sendMessage({
    required String sessionId,
    required String message,
  }) async {
    final user = supabase.auth.currentUser;

    await supabase.from('messages').insert({
      'session_id': sessionId,
      'sender_id': user!.id,
      'sender_type': 'user', // ← make sure this is here
      'message': message,
    });
  }
}
