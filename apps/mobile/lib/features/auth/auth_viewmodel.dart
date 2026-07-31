import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase_client.dart';

class AuthViewModel extends ChangeNotifier {
  bool isLoading = false;
  String? errorMessage;

  /// Account exists but its email is unconfirmed, so there is no session and
  /// the user cannot get in yet. UI-only signal: nothing is verified or resent
  /// here, the screen just surfaces the state.
  bool needsEmailConfirmation = false;

  void clearEmailConfirmationNotice() {
    if (!needsEmailConfirmation) return;
    needsEmailConfirmation = false;
    notifyListeners();
  }

  Future<bool> signUp(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    needsEmailConfirmation = false;
    notifyListeners();

    try {
      final response =
          await supabase.auth.signUp(email: email, password: password);
      isLoading = false;
      // No session means the project requires email confirmation: the account
      // was created but the user cannot continue until they use the link.
      if (response.session == null) {
        needsEmailConfirmation = true;
        notifyListeners();
        return false;
      }
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
    needsEmailConfirmation = false;
    notifyListeners();

    try {
      await supabase.auth.signInWithPassword(email: email, password: password);
      isLoading = false;
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      isLoading = false;
      if (_isEmailNotConfirmed(e)) {
        needsEmailConfirmation = true;
      } else {
        errorMessage = 'Giriş başarısız: $e';
      }
      notifyListeners();
      return false;
    } catch (e) {
      errorMessage = 'Giriş başarısız: $e';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  bool _isEmailNotConfirmed(AuthException error) =>
      error.code == 'email_not_confirmed' ||
      error.message.toLowerCase().contains('email not confirmed');
} 