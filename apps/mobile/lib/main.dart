import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'TODO: Supabase proje URL',
    anonKey: 'TODO: Supabase anon key',
  );

  runApp(const ProviderScope(child: AkilliSepetApp()));
}
