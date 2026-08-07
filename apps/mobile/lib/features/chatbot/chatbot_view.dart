import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/akilli_sepet_colors.dart';
import '../../core/providers.dart';
import '../../shared/widgets/user_avatar_circle.dart';
import '../shell/shell_viewmodel.dart';

class ChatbotView extends ConsumerStatefulWidget {
  const ChatbotView({super.key});

  @override
  ConsumerState<ChatbotView> createState() => _ChatbotViewState();
}

class _ChatbotViewState extends ConsumerState<ChatbotView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

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

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Hem Home (Kullanıcı Adı) hem Chatbot (Mesajlar) beyinlerine ihtiyacımız var
    final homeVm = ref.watch(homeViewModelProvider);
    final chatVm = ref.watch(chatbotViewModelProvider);

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

            // --- ORTA: MESAJ LİSTESİ ---
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                itemCount: chatVm.messages.length,
                itemBuilder: (context, index) {
                  final msg = chatVm.messages[index];
                  final isUser = msg.isUser;

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

            // --- YAZIYOR ANİMASYONU ---
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

            // --- ALT: MESAJ YAZMA KUTUSU VE YENİ SOHBET BUTONU ---
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
                  // 1. Mesaj Yazma Alanı (Çift padding yapan bottomInset silindi!)
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
                  
                  // 2. Yeni Sohbet Butonu (Tam input'un altında, boşluğu dolduracak)
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
          ],
        ),
      ),
    );
  }
}
