/// Failure reasons surfaced by [ProfileViewModel]. The ViewModel stays free of
/// UI and localization concerns: it reports the reason, and the View maps it to
/// a localized message.
enum ProfileError {
  sessionNotFound,
  profileLoadFailed,
  profileSaveFailed,
  nameSaveFailed,
  countrySaveFailed,
  photoUploadFailed,
}
