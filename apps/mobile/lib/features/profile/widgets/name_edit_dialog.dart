import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

/// Adı düzenleme kutusu. Kapatılınca girilen metni, vazgeçilirse null döner.
///
/// Controller'ı kendi state'inde tutar ve orada dispose eder. Çağıran taraf
/// `await showDialog(...)` sonrasında dispose edemez: future `Navigator.pop`
/// anında tamamlanır, ama kapanış animasyonu sürerken alan hâlâ controller'a
/// bağlıdır — erken dispose "used after being disposed" hatasına yol açar.
class NameEditDialog extends StatefulWidget {
  const NameEditDialog({
    super.key,
    required this.initialName,
    required this.maxLength,
  });

  final String initialName;
  final int maxLength;

  @override
  State<NameEditDialog> createState() => _NameEditDialogState();
}

class _NameEditDialogState extends State<NameEditDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() => Navigator.pop(context, _controller.text);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.nameDialogTitle),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: widget.maxLength,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(hintText: l10n.nameDialogHint),
        onSubmitted: (_) => _submit(),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        TextButton(onPressed: _submit, child: Text(l10n.ok)),
      ],
    );
  }
}
