/// A recommended alternative product shown in the "Öneriler" section.
///
/// Kept close to the expected backend response shape so that, once the real
/// service is ready, only the data layer changes — not the UI.
class Alternative {
  const Alternative({
    required this.id,
    required this.name,
    required this.brand,
    required this.imageUrl,
    required this.score,
  });

  final String id;
  final String name;
  final String brand;
  final String imageUrl;

  /// Backend sends the score level; colour and label are decided client-side.
  final AlternativeScore score;

  factory Alternative.fromJson(Map<String, dynamic> json) {
    return Alternative(
      id: json['id'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String,
      imageUrl: json['image_url'] as String? ?? '',
      score: AlternativeScore.fromKey(json['score'] as String?),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'image_url': imageUrl,
      'score': score.key,
    };
  }
}

/// Score level of an alternative. The UI derives the display label and colour
/// from this; the backend only ever sends the level.
enum AlternativeScore {
  excellent('excellent'),
  good('good');

  const AlternativeScore(this.key);

  /// Wire value exchanged with the backend.
  final String key;

  /// Falls back to [good] for unknown or missing values.
  static AlternativeScore fromKey(String? key) {
    return AlternativeScore.values.firstWhere(
      (score) => score.key == key,
      orElse: () => AlternativeScore.good,
    );
  }
}
