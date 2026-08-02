import 'package:flutter/material.dart';

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
    return AlertDialog(
      title: const Text('Adın'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: widget.maxLength,
        textCapitalization: TextCapitalization.words,
        textInputAction: TextInputAction.done,
        decoration: const InputDecoration(hintText: 'Adını yaz'),
        onSubmitted: (_) => _submit(),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Vazgeç'),
        ),
        TextButton(onPressed: _submit, child: const Text('Tamam')),
      ],
    );
  }
}
