import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/user_profile.dart';
import '../../core/providers.dart';
import '../../core/supabase_client.dart';

class OnboardingView extends ConsumerStatefulWidget {
  const OnboardingView({super.key});

  @override
  ConsumerState<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends ConsumerState<OnboardingView> {
  final List<String> _selectedAllergies = [];
  DietPreference _dietPreference = DietPreference.standard;
  final List<String> _selectedHealthConditions = [];

  final _allergyOptions = ['gluten', 'laktoz', 'fındık', 'yumurta', 'soya'];
  final _healthOptions = ['diyabet', 'hipertansiyon', 'kalp hastalığı'];

  Future<void> _submit() async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return;

    final profile = UserProfile(
      userId: userId,
      allergies: _selectedAllergies,
      dietPreference: _dietPreference,
      healthConditions: _selectedHealthConditions,
    );

    await ref.read(onboardingViewModelProvider).saveProfile(profile);

    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = ref.watch(onboardingViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profilini Oluştur')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Alerjilerin', style: TextStyle(fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 8,
            children: _allergyOptions.map((a) {
              final selected = _selectedAllergies.contains(a);
              return FilterChip(
                label: Text(a),
                selected: selected,
                onSelected: (v) => setState(() {
                  v ? _selectedAllergies.add(a) : _selectedAllergies.remove(a);
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          const Text('Diyet Tercihi', style: TextStyle(fontWeight: FontWeight.bold)),
          DropdownButton<DietPreference>(
            value: _dietPreference,
            items: DietPreference.values
                .map((d) => DropdownMenuItem(value: d, child: Text(d.name)))
                .toList(),
            onChanged: (v) => setState(() => _dietPreference = v!),
          ),
          const SizedBox(height: 24),
          const Text('Sağlık Durumu', style: TextStyle(fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 8,
            children: _healthOptions.map((h) {
              final selected = _selectedHealthConditions.contains(h);
              return FilterChip(
                label: Text(h),
                selected: selected,
                onSelected: (v) => setState(() {
                  v ? _selectedHealthConditions.add(h) : _selectedHealthConditions.remove(h);
                }),
              );
            }).toList(),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: vm.isSaving ? null : _submit,
            child: vm.isSaving
                ? const CircularProgressIndicator()
                : const Text('Profili Kaydet'),
          ),
        ],
      ),
    );
  }
}