import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path/path.dart';

class UploadService {
  static final supabase = Supabase.instance.client;

  static Future<void> uploadReport(File file) async {
    final user = supabase.auth.currentUser;
    if (user == null) throw "User not logged in";

    final fileName = basename(file.path);
    final storagePath = "${user.id}/$fileName";

    // Upload to Supabase Storage
    await supabase.storage.from('reports').upload(storagePath, file);

    // Get public URL
    final fileUrl = supabase.storage.from('reports').getPublicUrl(storagePath);

    // Save record in database
    await supabase.from('reports').insert({
      'user_id': user.id,
      'file_name': fileName,
      'file_url': fileUrl,
    });
  }
}
