import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/supabase_client.dart';
import 'auth_error.dart';

class AuthViewModel extends ChangeNotifier {
  bool isLoading = false;

  /// Last failure reason, or null. The View maps this to a localized message.
  AuthError? error;

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
    error = null;
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
        _fail(AuthError.signUpFailed, e);
      }
      notifyListeners();
      return false;
    } catch (e) {
      _fail(AuthError.signUpFailed, e);
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    isLoading = true;
    error = null;
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
        _fail(AuthError.signInFailed, e);
      }
      notifyListeners();
      return false;
    } catch (e) {
      _fail(AuthError.signInFailed, e);
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Hesaba gerek duymadan misafir olarak giriş yapma.
  Future<bool> signInAsGuest() async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      await supabase.auth.signInAnonymously();
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _fail(AuthError.guestSignInFailed, e);
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // Google OAuth ile giriş yapma işlemi
  //(Not: Bu fonksiyonun çalışması için Google Cloud
  // ve Supabase panel ayarlarının yapılmış olması gerekir.)
  Future<bool> signInWithGoogle() async{
    isLoading = true;
    error = null;
    notifyListeners();
    try{
      //Supabase'in yerleşik OAuth fonksiyonunu çağırma
      //RedirectTo parametresi, giriş yapıldıktan sonra uygulamanın geri açılmasını sağlar
      final success = await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null: 'io.supabase.akillisepet://login-callback/',
      );
      isLoading = false;
      notifyListeners();
      return success;
    } catch (e){
      _fail(AuthError.googleSignInFailed, e);
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Records the failure reason; the raw cause goes to the debug console only,
  /// never into the UI.
  void _fail(AuthError reason, Object cause) {
    error = reason;
    if (kDebugMode) debugPrint('AuthViewModel: ${reason.name} <- $cause');
  }

  bool _isEmailAlreadyRegistered(AuthException error) =>
      error.code == ErrorCode.userAlreadyExists.code ||
      error.code == ErrorCode.emailExists.code;

  bool _isEmailNotConfirmed(AuthException error) =>
      error.code == 'email_not_confirmed' ||
      error.message.toLowerCase().contains('email not confirmed');
}
