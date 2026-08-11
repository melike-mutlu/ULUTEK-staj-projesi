/// E-posta adreslerini gizlilik amacıyla maskeleyen yardımcı sınıf.
/// Örneğin: `melike.mutlu@gmail.com` -> `m***u@gmail.com`
abstract final class EmailMasker {
  static String maskEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return 'Kullanıcı Hesabı';
    }

    final trimmed = email.trim();
    final parts = trimmed.split('@');
    if (parts.length != 2) {
      return trimmed;
    }

    final local = parts[0];
    final domain = parts[1];

    if (local.isEmpty) {
      return trimmed;
    }

    String maskedLocal;
    if (local.length <= 2) {
      maskedLocal = '${local[0]}*${local.length == 2 ? local[1] : ''}';
    } else {
      maskedLocal = '${local[0]}***${local[local.length - 1]}';
    }

    return '$maskedLocal@$domain';
  }
}
