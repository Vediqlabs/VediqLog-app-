import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ActiveProfileProvider extends ChangeNotifier {
  String _activeProfileId = '';
  String _activeProfileName = 'Me';

  String get activeProfileId => _activeProfileId;
  String get activeProfileName => _activeProfileName;

  void initWithSelf() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    _activeProfileId = user.id;
    _activeProfileName = 'Me';
    notifyListeners();
  }

  void switchProfile({
    required String profileId,
    required String profileName,
  }) {
    if (profileId.isEmpty) return;

    _activeProfileId = profileId;
    _activeProfileName = profileName;
    notifyListeners();
  }
}
