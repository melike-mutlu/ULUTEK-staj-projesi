/// Failure reasons surfaced by [AuthViewModel]. Keeps the ViewModel free of UI
/// and localization: it reports the reason, the View maps it to a message.
enum AuthError {
  signUpFailed,
  signInFailed,
  guestSignInFailed,
  googleSignInFailed,
}
