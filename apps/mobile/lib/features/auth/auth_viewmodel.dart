import 'package:flutter/foundation.dart';
import '../../core/supabase_client.dart';

class AuthViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  Future<bool> signUp(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await supabase.auth.signUp(email: email, password: password);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Kayıt başarısız: $e';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await supabase.auth.signInWithPassword(email: email, password: password);
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Giriş başarısız: $e';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Hesaba gerek duymadan misafir olarak giriş yapma.
  Future<bool> signInAsGuest() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      try {
        await supabase.auth.signInAnonymously();
      } catch (e) {
        debugPrint('[AuthViewModel] Anonymous sign in fallback: $e');
      }
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      errorMessage = 'Misafir girişi başarısız: $e';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }
}