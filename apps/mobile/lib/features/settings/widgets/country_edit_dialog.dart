import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';

const List<String> _popularCountries = <String>[
  'Türkiye',
  'Almanya',
  'İngiltere',
  'ABD',
  'Hollanda',
  'Fransa',
];

/// Ülke düzenleme kutusu. Kapatılınca girilen metni, vazgeçilirse null döner.
class CountryEditDialog extends StatefulWidget {
  const CountryEditDialog({
    super.key,
    required this.initialCountry,
    this.maxLength = 50,
  });

  final String initialCountry;
  final int maxLength;

  @override
  State<CountryEditDialog> createState() => _CountryEditDialogState();
}

class _CountryEditDialogState extends State<CountryEditDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialCountry);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => Navigator.pop(context, _controller.text);

  void _selectCountry(String countryName) {
    _controller.text = countryName;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.public_rounded, color: AppColors.brand),
          const SizedBox(width: 10),
          Text(l10n.countryDialogTitle),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            TextField(
              controller: _controller,
              autofocus: true,
              maxLength: widget.maxLength,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.done,
              decoration: InputDecoration(
                hintText: l10n.countryDialogHint,
                prefixIcon: const Icon(Icons.location_on_outlined),
                suffixIcon: _controller.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _controller.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
              onChanged: (_) => setState(() {}),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.quickSelect,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _popularCountries.map((cName) {
                final isSelected =
                    _controller.text.trim().toLowerCase() == cName.toLowerCase();
                return ChoiceChip(
                  label: Text(cName, style: const TextStyle(fontSize: 12)),
                  selected: isSelected,
                  onSelected: (_) => _selectCountry(cName),
                  selectedColor: AppColors.brandSoft,
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.brand : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        TextButton(
          onPressed: _submit,
          child: Text(l10n.save),
        ),
      ],
    );
  }
}
