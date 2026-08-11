import '../../core/models/alternative.dart';

/// Supplies the recommended alternatives for the "Öneriler" section.
///
/// Backend service (Zeynep) is not ready yet, so this returns mock data. Once
/// the real endpoint exists, only [getAlternatives] changes; the UI stays the
/// same.
class AlternativesRepository {
  /// The [barcode] will scope the request once the backend is wired in.
  Future<List<Alternative>> getAlternatives(String barcode) async {
    // Mimic network latency so loading states behave like the real thing.
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return _mockAlternatives;
  }
}

const List<Alternative> _mockAlternatives = [
  Alternative(
    id: '1',
    name: 'Fındık & Kakao Meyve Barı',
    brand: 'Zuber',
    imageUrl:
        'https://images.openfoodfacts.org/images/products/869/050/404/1502/front_tr.3.400.jpg',
    score: AlternativeScore.excellent,
  ),
  Alternative(
    id: '2',
    name: 'Yulaf & Muz Bar',
    brand: 'Eti',
    imageUrl:
        'https://images.openfoodfacts.org/images/products/869/050/411/2233/front_tr.3.400.jpg',
    score: AlternativeScore.good,
  ),
  Alternative(
    id: '3',
    name: 'Hurma & Badem Bar',
    brand: 'Zuber',
    imageUrl: '',
    score: AlternativeScore.excellent,
  ),
  Alternative(
    id: '4',
    name: 'Fıstık Ezmeli Protein Bar',
    brand: 'Fellas',
    imageUrl: '',
    score: AlternativeScore.good,
  ),
  Alternative(
    id: '5',
    name: 'Kuru Meyve Bar',
    brand: 'Seeberger',
    imageUrl: '',
    score: AlternativeScore.good,
  ),
  Alternative(
    id: '6',
    name: 'Çikolatalı Yulaf Bar',
    brand: 'Nature Valley',
    imageUrl: '',
    score: AlternativeScore.excellent,
  ),
];
