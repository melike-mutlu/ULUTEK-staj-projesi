import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:akilli_sepet/core/utils/relative_date.dart';
import 'package:akilli_sepet/l10n/app_localizations_tr.dart';

/// Fixed reference point so the tests never depend on the wall clock.
final _now = DateTime(2026, 8, 4, 15, 30);

final _l10n = AppLocalizationsTr();

String _format(DateTime scannedAt) => formatScanDate(_l10n, scannedAt, now: _now);

void main() {
  // DateFormat needs the Turkish symbols loaded before formatting month names.
  setUpAll(() => initializeDateFormatting('tr'));

  group('dakika altı ve dakikalar', () {
    test('bir dakikadan yeni tarama "az önce"', () {
      expect(_format(_now.subtract(const Duration(seconds: 59))), equals('az önce'));
    });

    test('dakikalar "X dk önce"', () {
      expect(_format(_now.subtract(const Duration(minutes: 1))), equals('1 dk önce'));
      expect(_format(_now.subtract(const Duration(minutes: 59))), equals('59 dk önce'));
    });
  });

  group('saatler', () {
    test('60 dakikada saate geçer', () {
      expect(_format(_now.subtract(const Duration(minutes: 60))), equals('1 saat önce'));
    });

    test('23 saat hâlâ saat olarak gösterilir', () {
      expect(_format(_now.subtract(const Duration(hours: 23))), equals('23 saat önce'));
    });
  });

  group('günler', () {
    test('24 saat sonrası "dün"', () {
      expect(_format(_now.subtract(const Duration(hours: 24))), equals('dün'));
    });

    test('iki gün öncesi "2 gün önce"', () {
      expect(_format(DateTime(2026, 8, 2, 15, 30)), equals('2 gün önce'));
    });

    test('altı gün öncesi hâlâ gün olarak gösterilir', () {
      expect(_format(DateTime(2026, 7, 29, 15, 30)), equals('6 gün önce'));
    });

    test('24 saat dolmadan saat, dolduktan sonra takvim günü yazar', () {
      // 3 Ağustos 23:50 -> 4 Ağustos 15:30 arası 15 saatten fazla ama takvimde
      // bir gün fark var; yine de saat eşiği (24 saat) dolmadığı için saat yazar.
      expect(_format(DateTime(2026, 8, 3, 23, 50)), equals('15 saat önce'));
      // 2 Ağustos 00:10 -> takvimde iki gün geride.
      expect(_format(DateTime(2026, 8, 2, 0, 10)), equals('2 gün önce'));
    });
  });

  group('tarihe düşen eski taramalar', () {
    test('yedi gün ve sonrası kısa tarih', () {
      expect(_format(DateTime(2026, 7, 28, 15, 30)), equals('28 Tem'));
    });

    test('aynı yıl içinde yıl yazılmaz', () {
      expect(_format(DateTime(2026, 1, 9, 8, 0)), equals('9 Oca'));
    });

    test('farklı yılda yıl da yazılır', () {
      expect(_format(DateTime(2025, 12, 31, 23, 0)), equals('31 Ara 2025'));
    });

    test('tüm ay kısaltmaları doğru', () {
      const expected = [
        'Oca', 'Şub', 'Mar', 'Nis', 'May', 'Haz',
        'Tem', 'Ağu', 'Eyl', 'Eki', 'Kas', 'Ara',
      ];
      for (var month = 1; month <= 12; month++) {
        expect(
          formatScanDate(_l10n, DateTime(2024, month, 15), now: _now),
          equals('15 ${expected[month - 1]} 2024'),
        );
      }
    });
  });

  group('sınır durumlar', () {
    test('gelecek tarih negatif süre göstermez', () {
      expect(_format(_now.add(const Duration(hours: 5))), equals('az önce'));
    });

    test('UTC damgası yerel saate çevrilerek yorumlanır', () {
      final utcScan = _now.toUtc().subtract(const Duration(minutes: 30));
      expect(_format(utcScan), equals('30 dk önce'));
    });

    test('now verilmezse gerçek saate göre çalışır', () {
      expect(formatScanDate(_l10n, DateTime.now()), equals('az önce'));
    });
  });
}
