import 'package:flutter_test/flutter_test.dart';
import 'package:akilli_sepet/core/utils/email_masker.dart';

void main() {
  group('EmailMasker tests', () {
    test('masks standard email addresses correctly', () {
      expect(EmailMasker.maskEmail('melike.mutlu@gmail.com'), equals('m***u@gmail.com'));
      expect(EmailMasker.maskEmail('melike@gmail.com'), equals('m***e@gmail.com'));
      expect(EmailMasker.maskEmail('john@example.com'), equals('j***n@example.com'));
    });

    test('handles short local parts', () {
      expect(EmailMasker.maskEmail('ab@gmail.com'), equals('a*b@gmail.com'));
      expect(EmailMasker.maskEmail('a@gmail.com'), equals('a*@gmail.com'));
    });

    test('handles null, empty or invalid emails gracefully', () {
      expect(EmailMasker.maskEmail(null), equals('Kullanıcı Hesabı'));
      expect(EmailMasker.maskEmail(''), equals('Kullanıcı Hesabı'));
      expect(EmailMasker.maskEmail('   '), equals('Kullanıcı Hesabı'));
      expect(EmailMasker.maskEmail('invalidemail'), equals('invalidemail'));
    });
  });
}
