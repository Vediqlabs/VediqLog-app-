import 'package:supabase_flutter/supabase_flutter.dart';

class DoctorService {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getOnlineDoctors() async {
    final res = await supabase.from('doctors').select().eq('is_online', true);

    return List<Map<String, dynamic>>.from(res);
  }
}
