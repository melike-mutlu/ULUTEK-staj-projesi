import 'package:flutter/material.dart';

/// Figma: "Ana Ekran" mockup — büyük "Tara" butonu + son taramalar.
class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: "Tara" butonu -> Navigator.pushNamed(context, '/scan')
    return const Scaffold(
      body: Center(child: Text('Ana Ekran')),
    );
  }
}
