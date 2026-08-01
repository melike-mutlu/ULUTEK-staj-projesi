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

  /// Signing up with an address that already has an account. Kept apart from
  /// [needsEmailConfirmation]: with "Confirm email" on, Supabase answers both
  /// cases with a session-less 200 instead of an error.
  bool emailAlreadyRegistered = false;

  void clearEmailConfirmationNotice() {
    if (!needsEmailConfirmation) return;
    needsEmailConfirmation = false;
    notifyListeners();
  }

  void clearEmailAlreadyRegisteredNotice() {
    if (!emailAlreadyRegistered) return;
    emailAlreadyRegistered = false;
    notifyListeners();
  }

  Future<bool> signUp(String email, String password) async {
    isLoading = true;
    errorMessage = null;
    needsEmailConfirmation = false;
    emailAlreadyRegistered = false;
    notifyListeners();

    try {
      final response =
          await supabase.auth.signUp(email: email, password: password);
      isLoading = false;

      if (response.session == null) {
        // With "Confirm email" on the server hides existing accounts behind a
        // normal-looking 200; the giveaway is an empty identity list. A null
        // list tells us nothing, so it falls through to the confirmation
        // notice rather than claiming the address is taken.
        final identities = response.user?.identities;
        if (identities != null && identities.isEmpty) {
          emailAlreadyRegistered = true;
        } else {
          // The account was created but cannot be used until the link is used.
          needsEmailConfirmation = true;
        }
        notifyListeners();
        return false;
      }
      notifyListeners();
      return true;
    } on AuthException catch (e) {
      isLoading = false;
      // "Confirm email" off: the server rejects the signup outright.
      if (_isEmailAlreadyRegistered(e)) {
        emailAlreadyRegistered = true;
      } else {
        errorMessage = 'Kayıt başarısız: $e';
      }
      notifyListeners();
      return false;
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
    emailAlreadyRegistered = false;
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

  bool _isEmailAlreadyRegistered(AuthException error) =>
      error.code == ErrorCode.userAlreadyExists.code ||
      error.code == ErrorCode.emailExists.code;

  bool _isEmailNotConfirmed(AuthException error) =>
      error.code == 'email_not_confirmed' ||
      error.message.toLowerCase().contains('email not confirmed');
} 