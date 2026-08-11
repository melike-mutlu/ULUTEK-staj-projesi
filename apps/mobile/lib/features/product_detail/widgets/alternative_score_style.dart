import 'package:flutter/material.dart';

import '../../../core/models/alternative.dart';
import '../../../core/theme/app_colors.dart';

/// Presentation of an [AlternativeScore]: the backend sends only the level, the
/// label and colour are decided here in the UI layer.
extension AlternativeScoreStyle on AlternativeScore {
  String get label {
    switch (this) {
      case AlternativeScore.excellent:
        return 'Mükemmel';
      case AlternativeScore.good:
        return 'İyi';
    }
  }

  Color get color {
    switch (this) {
      case AlternativeScore.excellent:
        return AppColors.scoreExcellent;
      case AlternativeScore.good:
        return AppColors.scoreGood;
    }
  }
}
