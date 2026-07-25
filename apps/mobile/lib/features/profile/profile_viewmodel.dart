import 'package:flutter/foundation.dart';

import '../../core/models/user_profile.dart';
import '../../data/repositories/profile_repository.dart';

/// Onboarding'de girilen profili sonradan düzenlemek için.
class ProfileViewModel extends ChangeNotifier {
  ProfileViewModel(this._profileRepository);

  final ProfileRepository _profileRepository;

  bool isLoading = false;
  UserProfile? profile;

  Future<void> load(String userId) async {
    isLoading = true;
    notifyListeners();
    profile = await _profileRepository.getProfile(userId);
    isLoading = false;
    notifyListeners();
  }

  Future<void> save(UserProfile updated) async {
    await _profileRepository.saveProfile(updated);
    profile = updated;
    notifyListeners();
  }
}
