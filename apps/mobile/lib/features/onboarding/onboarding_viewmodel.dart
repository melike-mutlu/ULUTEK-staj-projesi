import 'package:flutter/foundation.dart';

import '../../core/models/user_profile.dart';
import '../../data/repositories/profile_repository.dart';

/// TODO: alerji/diyet/sağlık adımlarının state'ini burada tut (ör. çoklu seçim listeleri).
class OnboardingViewModel extends ChangeNotifier {
  OnboardingViewModel(this._profileRepository);

  final ProfileRepository _profileRepository;

  bool isSaving = false;

  Future<void> saveProfile(UserProfile profile) async {
    isSaving = true;
    notifyListeners();
    await _profileRepository.saveProfile(profile);
    isSaving = false;
    notifyListeners();
  }
}
