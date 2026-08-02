/// The name to show for a user: their chosen name, else the email local-part.
///
/// Returns an empty string when neither is available — callers pick their own
/// last-resort label ('Kullanıcı' in greetings, 'U' on the avatar), so the
/// fallback order itself lives in exactly one place.
String resolveDisplayName({String? displayName, String? email}) {
  final name = displayName?.trim() ?? '';
  if (name.isNotEmpty) return name;
  return email?.split('@').first.trim() ?? '';
}
