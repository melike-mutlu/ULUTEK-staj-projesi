/// Failure reasons surfaced by [PendingProductViewModel]. The ViewModel reports
/// the reason; the View maps it to a localized message.
enum PendingProductError {
  invalidBarcode,
  submitFailed,
}
