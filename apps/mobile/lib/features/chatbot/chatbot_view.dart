import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/akilli_sepet_colors.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/widgets/user_avatar_circle.dart';
import '../shell/shell_viewmodel.dart';
import '../profile/profile_viewmodel.dart';
import '../../shared/services/image_picker_service.dart';
import '../../core/constants/profile_options.dart'; // OnboardingField (diet, allergy vs) için gerekli

class ChatbotView extends ConsumerStatefulWidget {
  const ChatbotView({super.key});

  @override
  ConsumerState<ChatbotView> createState() => _ChatbotViewState();
}

class _ChatbotViewState extends ConsumerState<ChatbotView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  //Hazır Soru Çipleri İçin Liste
  final List<String> _suggestionChips = [
    "Bu ürün vegan mı?",
    "İçindekileri açıkla",
    "Bana sağlıklı bir atıştırmalık öner",
    "Glutensiz ürünleri nasıl anlarım?",
  ];

  @override
  void initState() {
    super.initState();
    // Chatbot ekranı açıldığında profil henüz yüklenmemişse yüklemeyi tetikliyoruz
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileVm = ref.read(profileViewModelProvider);
      if (profileVm.profile == null && !profileVm.isLoading) {
        profileVm.load(); 
      }
    });
  }

  //textOverride parametresi sayesinde çiplere tıklanınca textfield'ı beklemeden mesaj atabileceğiz.
  void _sendMessage({String? textOverride}) {
    final text = textOverride ?? _messageController.text;
    if (text.trim().isNotEmpty) {
      ref.read(chatbotViewModelProvider).sendMessage(
            text,
            errorText: AppLocalizations.of(context).chatError,
          );
      if (textOverride == null){
        _messageController.clear(); //Eğer textfield'dan geldiyse kutuyu temizle
      }
      _scrollToBottom();
    }
  }

  // FOTOĞRAF SEÇME MENÜSÜ ---
  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: AkilliSepetColors.primary),
                title: const Text('Kameradan Çek'),
                onTap: () async {
                  Navigator.pop(context); // Menüyü kapat
                  final picker = ref.read(imagePickerServiceProvider);
                  final image = await picker.pickFromCamera();
                  if (image != null) {
                    ref.read(chatbotViewModelProvider).setSelectedImage(image);
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: AkilliSepetColors.primary),
                title: const Text('Galeriden Seç'),
                onTap: () async {
                  Navigator.pop(context); // Menüyü kapat
                  final picker = ref.read(imagePickerServiceProvider);
                  final image = await picker.pickFromGallery();
                  if (image != null) {
                    ref.read(chatbotViewModelProvider).setSelectedImage(image);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
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

  // --- KUSURSUZ ONAY FONKSİYONU ---
  Future<void> _acceptSuggestion(int index, String fieldStr, String value) async {
    final profileVm = ref.read(profileViewModelProvider);
    final chatVm = ref.read(chatbotViewModelProvider);

    // 1. Gelen metni İngilizce veya Türkçe gelse bile yakalayacak şekilde OnboardingField'a çevir
    OnboardingField? targetField;
    final f = fieldStr.toLowerCase();
    
    if (f.contains('diet') || f.contains('diyet')) {
      targetField = OnboardingField.diet;
    } else if (f.contains('allerg') || f.contains('alerj')) {
      targetField = OnboardingField.allergies;
    } else if (f.contains('health') || f.contains('sağlık') || f.contains('hastalık')) {
      targetField = OnboardingField.health;
    }

    if (targetField != null) {
      final trimmedValue = value.trim();
      String actualValue = trimmedValue;
      
      // 2. Büyük/küçük harf eşleşmesini bul (örn: AI "yumurta" yolladı ama sistemde "Yumurta" kayıtlı)
      for (final existingOption in profileVm.optionsFor(targetField)) {
        if (existingOption.toLowerCase() == trimmedValue.toLowerCase()) {
          actualValue = existingOption;
          break;
        }
      }

      // 3. Eğer kelime sistemde HİÇ YOKSA (örn: Kivi), listeye özel kelime olarak ekle
      profileVm.addCustomOption(targetField, actualValue);
      
      // 4. ASIL ÇÖZÜM: Kelime sistemde zaten varsa addCustomOption onu seçmez. 
      // Bu yüzden eğer henüz seçili değilse biz zorla seçili (toggle) hale getiriyoruz!
      if (!profileVm.selectionsFor(targetField).contains(actualValue)) {
        profileVm.toggleOption(targetField, actualValue);
      }
      
      // 5. Artık taslakta kesinlikle var. Veritabanına kaydet!
      final success = await profileVm.save();
      
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).addedToProfileSnack(actualValue)),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } else {
      debugPrint("Chatbot Hatası: Bilinmeyen alan -> $fieldStr");
    }

    // 6. Sohbet ekranındaki kartı kaldırıp normal mesaja dönüştür
    if (mounted) {
      chatVm.markSuggestionAsHandled(index, AppLocalizations.of(context).addedToProfile);
    }
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
    final l10n = AppLocalizations.of(context);

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

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final backgroundColor = theme.scaffoldBackgroundColor;
    final textColor = isDark ? AppColors.darkTextPrimary : AkilliSepetColors.textPrimary;
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AkilliSepetColors.textSecondary;
    final surfaceColor = isDark ? AppColors.darkSurface : Colors.white;
    final borderColor = isDark ? AppColors.darkBorder : const Color(0xFFE5E7EB);
    final inputFillColor = isDark ? AppColors.darkSurfaceMuted : const Color(0xFFF3F4F6);

    return Scaffold(
      backgroundColor: backgroundColor,
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
                        l10n.chatbotTitle,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                      ),
                      Text(
                        l10n.chatbotGreeting(homeVm.displayName),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: secondaryTextColor,
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

            Divider(height: 1, color: borderColor),

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
                child:chatVm.messages.isEmpty
                    // 1. durum: Mesaj yoksa karşılama ekranı çiz
                    ? Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  color: AkilliSepetColors.primary.withValues(alpha: 0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.smart_toy_rounded,
                                  size: 64,
                                  color: AkilliSepetColors.primary,
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                "Nasıl yardımcı olabilirim?",
                                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: textColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Sağlığın ve beslenmenle ilgili her şeyi bana sorabilirsin.",
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: secondaryTextColor,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 32),
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 8,
                                runSpacing: 8,
                                children: _suggestionChips.map((chipText){
                                  return ActionChip(
                                    label: Text(chipText),
                                    backgroundColor: surfaceColor,
                                    onPressed: () => _sendMessage(textOverride: chipText),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                        ),
                    )
                    //Mesaj varsa listeyi çiz
                : ListView.builder(
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
                            color: surfaceColor,
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
                              Row(
                                children: [
                                  const Icon(Icons.auto_awesome, color: AkilliSepetColors.primary, size: 20),
                                  const SizedBox(width: 8),
                                  Text(
                                    l10n.aiSuggestion,
                                    style: const TextStyle(
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
                                  : l10n.suggestionFallback,
                                style: TextStyle(fontSize: 15, color: textColor),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.darkSurfaceMuted : AkilliSepetColors.background,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  '🏷️ ${msg.suggestedValue}',
                                  style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
                                ),
                              ),
                              const SizedBox(height: 16),
                              Wrap(
                                alignment: WrapAlignment.end,
                                spacing: 8,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      chatVm.markSuggestionAsHandled(index, l10n.addedToProfile);
                                    },
                                    child: Text(l10n.no, style: TextStyle(color: secondaryTextColor, fontWeight: FontWeight.bold)),
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
                                    child: Text(l10n.yesAdd, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    }

                    // --- NORMAL SOHBET BALONU ---
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          // EĞER MESAJ AI İSE SOLA AVATAR KOY
                          if (!isUser) ...[
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: AkilliSepetColors.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.smart_toy_rounded, size: 16, color: Colors.white),
                            ),
                          ],

                          // MESAJ BALONU (Flexible ile sarmaladık ki taşıp hata vermesin)
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isUser ? AkilliSepetColors.primary : surfaceColor,
                                borderRadius: BorderRadius.circular(16).copyWith(
                                  bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(16),
                                  bottomLeft: !isUser ? const Radius.circular(0) : const Radius.circular(16),
                                ),
                                border: isUser ? null : Border.all(color: borderColor),
                              ),
                              // --- GÜNCELLENDİ: MESAJ BALONU ---
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // YENİ: EĞER FOTOĞRAF VARSA GÖSTER
                                  if (msg.attachedImageBytes != null)
                                    Padding(
                                      padding: const EdgeInsets.only(bottom: 8.0),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.memory(
                                          msg.attachedImageBytes!,
                                          width: 150, // Balonun içinde tatlı bir boyutta dursun
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  // ESKİ: METİN KISMI AYNEN DURUYOR
                                  Text(
                                    msg.text,
                                    style: TextStyle(
                                      color: isUser ? Colors.white : textColor,
                                      fontSize: 15,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              if (chatVm.isTyping)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.assistantTyping,
                      style: TextStyle(color: secondaryTextColor, fontSize: 13, fontStyle: FontStyle.italic),
                    ),
                  ),
                ),

              Container(
                decoration: BoxDecoration(
                  color: surfaceColor,
                  border: Border(top: BorderSide(color: borderColor)),
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

                    if (chatVm.selectedImage != null)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  chatVm.selectedImage!.bytes,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                right: -4,
                                top: -4,
                                child: IconButton(
                                  icon: Container(
                                    padding: const EdgeInsets.all(2),
                                    decoration: const BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.close, color: Colors.white, size: 16),
                                  ),
                                  onPressed: () => chatVm.removeSelectedImage(),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),


                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Row(
                        children: [

                          IconButton(
                            icon: const Icon(Icons.add_a_photo_outlined),
                            color: secondaryTextColor,
                            onPressed: _showImagePickerOptions,
                          ),


                          Expanded(
                            child: TextField(
                              controller: _messageController,
                              style: TextStyle(color: textColor),
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) => _sendMessage(),
                              decoration: InputDecoration(
                                hintText: l10n.askSomething,
                                hintStyle: TextStyle(color: secondaryTextColor),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(24),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: inputFillColor,
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
                              onPressed: () => _sendMessage(),
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
                          label: Text(l10n.newChat),
                          style: TextButton.styleFrom(
                            foregroundColor: secondaryTextColor,
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
                          l10n.premiumFeature,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AkilliSepetColors.textPrimary,
                              ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          l10n.chatbotPaywallBody,
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
                          child: Text(
                            l10n.goToSettings,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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

