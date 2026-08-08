import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/akilli_sepet_colors.dart';
import '../../core/providers.dart';
import '../../shared/widgets/user_avatar_circle.dart';
import '../shell/shell_viewmodel.dart';
import '../profile/profile_viewmodel.dart';
import '../../core/constants/profile_options.dart'; // OnboardingField (diet, allergy vs) için gerekli

class ChatbotView extends ConsumerStatefulWidget {
  const ChatbotView({super.key});

  @override
  ConsumerState<ChatbotView> createState() => _ChatbotViewState();
}

class _ChatbotViewState extends ConsumerState<ChatbotView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileVm = ref.read(profileViewModelProvider);
      if (profileVm.profile == null && !profileVm.isLoading) {
        profileVm.load(); // Parametresiz çağrılıyor
      }
    });
  }

  void _sendMessage() {
    final text = _messageController.text;
    if (text.trim().isNotEmpty) {
      ref.read(chatbotViewModelProvider).sendMessage(text);
      _messageController.clear();
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent + 100,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _acceptSuggestion(int index, String fieldStr, String value) async {
    final profileVm = ref.read(profileViewModelProvider);
    final chatVm = ref.read(chatbotViewModelProvider);

    final currentProfile = profileVm.profile;
    final user = Supabase.instance.client.auth.currentUser;

    if (currentProfile != null && user != null) {
      final f = fieldStr.toLowerCase();
      
      // 1. Listeye ekle
      if (f.contains('diet')) {
        if (!currentProfile.dietPreferences.contains(value)) {
          currentProfile.dietPreferences.add(value);
        }
      } 
      else if (f.contains('allerg')) {
        if (!currentProfile.allergies.contains(value)) {
          currentProfile.allergies.add(value); 
        }
      } 
      else if (f.contains('health')) {
        if (!currentProfile.healthConditions.contains(value)) {
          currentProfile.healthConditions.add(value);
        }
      }

      // 2. Doğrudan Supabase tablosuna yaz
      try {
        await Supabase.instance.client
            .from('profiles')
            .update(currentProfile.toJson())
            .eq('user_id', user.id);

        // 3. Profili parametresiz yenile
        await profileVm.load();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$value profilinize eklendi!'), 
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        debugPrint('Kayıt Hatası: $e');
      }
    }

    chatVm.markSuggestionAsHandled(index);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeVm = ref.watch(homeViewModelProvider);
    final chatVm = ref.watch(chatbotViewModelProvider);
    final profileVm = ref.watch(profileViewModelProvider);
    
    final isPremium = profileVm.profile?.isPremium ?? false;

    // Başka bir ekran (ör. profil "danış") bir metin bıraktıysa input'a yaz ve
    // tüket, böylece tekrar bu sekmeye girişte geri gelmesin.
    final pending = chatVm.pendingInput;
    if (pending != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _messageController.text = pending;
        chatVm.consumePendingInput();
      });
    }

    return Scaffold(
      backgroundColor: AkilliSepetColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // --- ÜST BAŞLIK (Hoşgeldin & Profil) ---
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                key: const Key('screenHeaderRow'),
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Akıllı Asistan',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AkilliSepetColors.textPrimary,
                            ),
                      ),
                      Text(
                        'Size nasıl yardımcı olabilirim ${homeVm.displayName}?',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AkilliSepetColors.textSecondary,
                            ),
                      ),
                    ],
                  ),
                  UserAvatarCircle(
                    name: homeVm.displayName,
                    avatarUrl: homeVm.avatarUrl,
                    onTap: () => ref.read(shellViewModelProvider).selectTab(ShellTab.profile),
                  ),
                ],
              ),
            ),

            const Divider(height: 1, color: Color(0xFFE5E7EB)),

            // --- İÇERİK KONTROLÜ ---
            if (profileVm.isLoading)
              const Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: AkilliSepetColors.primary),
                ),
              )
            else if (isPremium) ...[
              // --- PREMIUM İSE: SOHBET EKRANI ---
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  itemCount: chatVm.messages.length,
                  itemBuilder: (context, index) {
                    final msg = chatVm.messages[index];
                    final isUser = msg.isUser;

                    // --- YENİ: EĞER BU MESAJ BİR ONAY KARTI (SUGGESTION) İSE ---
                    if (msg.isSuggestion) {
                      return Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.85,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AkilliSepetColors.primary.withValues(alpha: 0.3)),
                            boxShadow: [
                              BoxShadow(
                                color: AkilliSepetColors.primary.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.auto_awesome, color: AkilliSepetColors.primary, size: 20),
                                  SizedBox(width: 8),
                                  Text(
                                    'Yapay Zeka Önerisi',
                                    style: TextStyle(
                                      color: AkilliSepetColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                msg.text.isNotEmpty 
                                  ? msg.text 
                                  : 'Profilinize yeni bir özellik eklememi ister misiniz?',
                                style: const TextStyle(fontSize: 15, color: Colors.black87),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: AkilliSepetColors.background,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '🏷️ ${msg.suggestedValue}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AkilliSepetColors.textPrimary),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                alignment: WrapAlignment.end,
                                spacing: 8, // Butonlar arası yatay boşluk
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      chatVm.markSuggestionAsHandled(index);
                                    },
                                    child: const Text('Hayır', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => _acceptSuggestion(
                                      index, 
                                      msg.suggestedField ?? '', 
                                      msg.suggestedValue ?? ''
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AkilliSepetColors.primary,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    ),
                                    child: const Text('Evet, Ekle', style: TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    }

                    // --- NORMAL SOHBET BALONU ---
                    return Align(
                      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
                        decoration: BoxDecoration(
                          color: isUser ? AkilliSepetColors.primary : Colors.white,
                          borderRadius: BorderRadius.circular(16).copyWith(
                            bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(16),
                            bottomLeft: !isUser ? const Radius.circular(0) : const Radius.circular(16),
                          ),
                          border: isUser ? null : Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Text(
                          msg.text,
                          style: TextStyle(
                            color: isUser ? Colors.white : AkilliSepetColors.textPrimary,
                            fontSize: 15,
                            height: 1.3,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              if (chatVm.isTyping)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Asistan yazıyor...',
                      style: TextStyle(color: Colors.grey, fontSize: 13, fontStyle: FontStyle.italic),
                    ),
                  ),
                ),

              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      offset: const Offset(0, -4),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) => _sendMessage(),
                              decoration: InputDecoration(
                                hintText: 'Bir şeyler sorun...',
                                hintStyle: TextStyle(color: Colors.grey.shade400),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: const Color(0xFFF3F4F6),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            decoration: const BoxDecoration(
                              color: AkilliSepetColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                              onPressed: _sendMessage,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (chatVm.messages.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: TextButton.icon(
                          onPressed: () {
                            ref.read(chatbotViewModelProvider).clearMessages();
                          },
                          icon: const Icon(Icons.refresh_rounded, size: 16),
                          label: const Text('Yeni Sohbet Başlat'),
                          style: TextButton.styleFrom(
                            foregroundColor: AkilliSepetColors.textSecondary,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ] else ...[
              // --- PREMIUM DEĞİLSE: PAYWALL EKRANI ---
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: AkilliSepetColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.lock_outline_rounded,
                            size: 56,
                            color: AkilliSepetColors.primary,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Premium Özellik',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AkilliSepetColors.textPrimary,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Sohbet asistanını kullanmak ve profilinize özel yapay zeka tavsiyeleri almak için Premium üye olmanız gerekmektedir.',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AkilliSepetColors.textSecondary,
                                height: 1.5,
                              ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: () {
                            ref.read(shellViewModelProvider).selectTab(ShellTab.profile);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AkilliSepetColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(24),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Ayarlara Git',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


