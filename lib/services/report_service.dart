import 'package:supabase_flutter/supabase_flutter.dart';

class ReportService {
  static final supabase = Supabase.instance.client;

  static Future<List<Map<String, dynamic>>> fetchReports() async {
    final user = supabase.auth.currentUser;
    if (user == null) return [];

    final response = await supabase
        .from('reports')
        .select()
        .eq('user_id', user.id)
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(response);
  }
}
