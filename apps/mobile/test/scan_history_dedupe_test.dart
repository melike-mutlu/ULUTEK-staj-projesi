import 'package:flutter_test/flutter_test.dart';
import 'package:akilli_sepet/data/repositories/scan_history_repository.dart';

/// Serves rows from memory so the dedupe logic is tested without Supabase.
/// Rows are returned newest first, exactly like the real query does.
class _FakeScanHistoryRepository extends ScanHistoryRepository {
  _FakeScanHistoryRepository(this.rows);

  final List<Map<String, dynamic>> rows;
  int? lastRequestedLimit;

  @override
  Future<List<Map<String, dynamic>>> getScanHistory({int limit = 10}) async {
    lastRequestedLimit = limit;
    return rows.take(limit).toList();
  }
}

Map<String, dynamic> _scan(String barcode, String scannedAt) => <String, dynamic>{
      'barcode': barcode,
      'scanned_at': scannedAt,
    };

void main() {
  test('aynı barkod tek kayda düşer, en son tarama korunur', () async {
    final repository = _FakeScanHistoryRepository([
      _scan('111', '2026-08-04T10:00:00Z'),
      _scan('111', '2026-08-03T10:00:00Z'),
      _scan('222', '2026-08-02T10:00:00Z'),
    ]);

    final unique = await repository.getUniqueScanHistory(limit: 3);

    expect(unique.map((r) => r['barcode']), equals(['111', '222']));
    // The kept row is the most recent scan of that barcode, not the older one.
    expect(unique.first['scanned_at'], equals('2026-08-04T10:00:00Z'));
  });

  test('en son taranan en üstte, diğerlerinin sırası bozulmaz', () async {
    final repository = _FakeScanHistoryRepository([
      _scan('333', '2026-08-04T12:00:00Z'),
      _scan('111', '2026-08-04T11:00:00Z'),
      _scan('222', '2026-08-04T10:00:00Z'),
      _scan('333', '2026-08-01T09:00:00Z'),
    ]);

    final unique = await repository.getUniqueScanHistory(limit: 10);

    expect(unique.map((r) => r['barcode']), equals(['333', '111', '222']));
  });

  test('limit kadar tekil ürün döner, fazlası kesilir', () async {
    final repository = _FakeScanHistoryRepository([
      _scan('111', '2026-08-04T13:00:00Z'),
      _scan('222', '2026-08-04T12:00:00Z'),
      _scan('333', '2026-08-04T11:00:00Z'),
      _scan('444', '2026-08-04T10:00:00Z'),
    ]);

    final unique = await repository.getUniqueScanHistory(limit: 3);

    expect(unique.map((r) => r['barcode']), equals(['111', '222', '333']));
  });

  test('pencere yeterli tekil ürün içermezse eldeki kadarıyla döner', () async {
    // Same two products scanned over and over: fewer unique rows than asked for.
    final repository = _FakeScanHistoryRepository([
      for (var i = 0; i < 40; i++) _scan(i.isEven ? '111' : '222', '2026-08-04T10:00:00Z'),
    ]);

    final unique = await repository.getUniqueScanHistory(limit: 3);

    expect(unique.map((r) => r['barcode']), equals(['111', '222']));
  });

  test('tekilleştirme için limitten daha geniş bir pencere okunur', () async {
    final repository = _FakeScanHistoryRepository([
      _scan('111', '2026-08-04T10:00:00Z'),
    ]);

    await repository.getUniqueScanHistory(limit: 3);

    expect(repository.lastRequestedLimit, greaterThan(3));
  });

  test('barkodu boş veya eksik satırlar listeye girmez', () async {
    final repository = _FakeScanHistoryRepository([
      <String, dynamic>{'scanned_at': '2026-08-04T12:00:00Z'},
      _scan('', '2026-08-04T11:00:00Z'),
      _scan('111', '2026-08-04T10:00:00Z'),
    ]);

    final unique = await repository.getUniqueScanHistory(limit: 5);

    expect(unique.map((r) => r['barcode']), equals(['111']));
  });

  test('limit sıfır veya negatifse sorgu yapılmaz', () async {
    final repository = _FakeScanHistoryRepository([
      _scan('111', '2026-08-04T10:00:00Z'),
    ]);

    expect(await repository.getUniqueScanHistory(limit: 0), isEmpty);
    expect(repository.lastRequestedLimit, isNull);
  });
}
