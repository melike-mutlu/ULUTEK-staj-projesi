import '../../core/navigation/app_routes.dart';
import '../../data/repositories/profile_repository.dart';

/// Where a user belongs right now: no session -> auth, no profile row yet
/// (fresh signup) -> onboarding, otherwise the shell.
///
/// Shared by [StartupGate] on cold launch and by the auth screen right after
/// sign in/up, so signing in can jump straight to the destination instead of
/// flashing an intermediate loading screen.
///
/// Throws whatever the profile read throws — callers decide how to surface it.
/// A failed read must never be treated as "no profile": onboarding would
/// overwrite an existing profile.
Future<String> resolveStartupRoute(ProfileRepository repository) async {
  final String? userId;
  try {
    userId = repository.currentUserId;
  } catch (_) {
    // Supabase not initialized (e.g. widget tests): treat as signed out.
    return AppRoutes.auth;
  }

  if (userId == null) return AppRoutes.auth;

  final profile = await repository.getProfile(userId);
  return profile == null ? AppRoutes.onboarding : AppRoutes.shell;
}
