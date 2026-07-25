import 'package:flutter/foundation.dart';

import '../../core/models/explanation.dart';
import '../../core/models/product.dart';
import '../../core/models/rule_engine_result.dart';
import '../../core/models/user_profile.dart';
import '../../data/repositories/explanation_repository.dart';

enum ProductDetailStatus { loading, found, notFound, partial, error }

class ProductDetailViewModel extends ChangeNotifier {
  ProductDetailViewModel(this._explanationRepository);

  final ExplanationRepository _explanationRepository;

  ProductDetailStatus status = ProductDetailStatus.loading;
  Product? product;
  Explanation? explanation;

  Future<void> load({
    required Product product,
    required RuleEngineResult ruleEngineResult,
    required UserProfile userProfile,
  }) async {
    this.product = product;
    status = ProductDetailStatus.loading;
    notifyListeners();

    explanation = await _explanationRepository.explainProduct(
      product: product,
      ruleEngineResult: ruleEngineResult,
      userProfile: userProfile,
    );

    status = ProductDetailStatus.found;
    notifyListeners();
  }

  /// fetch-product "not_found" / "partial" döndüğünde View bunu çağırır.
  void setStatusFromFetch(String fetchStatus) {
    status = fetchStatus == 'not_found'
        ? ProductDetailStatus.notFound
        : ProductDetailStatus.partial;
    notifyListeners();
  }
}
