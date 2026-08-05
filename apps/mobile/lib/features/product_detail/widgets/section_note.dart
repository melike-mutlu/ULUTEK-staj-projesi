import 'package:flutter/material.dart';

import '../../../core/theme/akilli_sepet_colors.dart';
import 'detail_section.dart';

/// One quiet line inside a section: "nothing to report here".
class SectionNote extends StatelessWidget {
  const SectionNote({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 10,
        bottom: 4,
        left: DetailSection.dividerInset,
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 15,
          color: AkilliSepetColors.textSecondary,
          height: 1.35,
        ),
      ),
    );
  }
}
