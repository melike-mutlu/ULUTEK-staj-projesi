import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/akilli_sepet_colors.dart';
import '../../data/repositories/pending_product_repository.dart';
import 'pending_product_viewmodel.dart';

class PendingProductView extends ConsumerStatefulWidget {
  const PendingProductView({super.key, this.barcode});

  final String? barcode;

  @override
  ConsumerState<PendingProductView> createState() => _PendingProductViewState();
}

class _PendingProductViewState extends ConsumerState<PendingProductView> {
  late final PendingProductViewModel _viewModel;
  late final TextEditingController _barcodeController;
  late final TextEditingController _nameController;
  late final TextEditingController _ingredientsController;

  @override
  void initState() {
    super.initState();
    final repo = ref.read(pendingProductRepositoryProvider);
    _viewModel = PendingProductViewModel(repo, initialBarcode: widget.barcode);
    _barcodeController = TextEditingController(text: _viewModel.barcode);
    _nameController = TextEditingController(text: _viewModel.productName);
    _ingredientsController = TextEditingController(text: _viewModel.ingredientsText);
    _viewModel.addListener(_onViewModelChanged);
  }

  void _onViewModelChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _barcodeController.dispose();
    _nameController.dispose();
    _ingredientsController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final success = await _viewModel.submit();
    if (!mounted) return;

    if (success) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: AkilliSepetColors.primary),
              SizedBox(width: 8),
              Text('Bildirim Alındı'),
            ],
          ),
          content: const Text(
            'Ürün bildirimi ve fotoğraflarınız başarıyla sisteme kaydedildi. Katkınız için teşekkür ederiz!',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx); // Close dialog
                Navigator.pop(context); // Pop view
              },
              child: const Text('Tamam'),
            ),
          ],
        ),
      );
    } else if (_viewModel.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_viewModel.errorMessage!),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Extract barcode argument from route if provided
    final routeArg = ModalRoute.of(context)?.settings.arguments;
    if (routeArg is String && _viewModel.barcode.isEmpty) {
      _viewModel.setBarcode(routeArg);
      _barcodeController.text = routeArg;
    }

    return Scaffold(
      backgroundColor: AkilliSepetColors.background,
      appBar: AppBar(
        backgroundColor: AkilliSepetColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Ürün Bulunamadı — Bildir'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Header Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF1D4ED8)),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Bu ürünü veritabanımıza eklememize yardımcı olun. Fotoğrafları yükleyerek doğruluk oranını artırabilirsiniz.',
                      style: TextStyle(fontSize: 13, color: Color(0xFF1E40AF), height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Form Fields
            const Text(
              'Ürün Bilgileri',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AkilliSepetColors.textPrimary),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _barcodeController,
              keyboardType: TextInputType.number,
              onChanged: (val) => _viewModel.setBarcode(val),
              decoration: InputDecoration(
                labelText: 'Barkod No *',
                hintText: 'Örn: 8690504112233',
                prefixIcon: const Icon(Icons.qr_code_scanner),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _nameController,
              onChanged: (val) => _viewModel.setProductName(val),
              decoration: InputDecoration(
                labelText: 'Ürün Adı & Markası',
                hintText: 'Örn: Ülker Çikolatalı Gofret',
                prefixIcon: const Icon(Icons.shopping_bag_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _ingredientsController,
              maxLines: 3,
              onChanged: (val) => _viewModel.setIngredientsText(val),
              decoration: InputDecoration(
                labelText: 'İçindekiler Metni (İsteğe Bağlı)',
                hintText: 'Etikette yer alan içindekiler...',
                prefixIcon: const Icon(Icons.article_outlined),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 28),

            // Photo Attachment Section
            const Text(
              'Ürün Fotoğrafları',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AkilliSepetColors.textPrimary),
            ),
            const SizedBox(height: 6),
            const Text(
              'Ürünün ön yüzü, içindekiler kısmı ve besin değerleri tablosunu çekin veya seçin.',
              style: TextStyle(fontSize: 13, color: AkilliSepetColors.textSecondary),
            ),
            const SizedBox(height: 16),

            // 3 Photo Upload Cards
            Row(
              children: [
                Expanded(
                  child: _buildPhotoCard(
                    title: 'Ön Yüz',
                    image: _viewModel.imageFront,
                    onPickCamera: () => _viewModel.pickImage('front', ImageSource.camera),
                    onPickGallery: () => _viewModel.pickImage('front', ImageSource.gallery),
                    onRemove: () => _viewModel.removeImage('front'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildPhotoCard(
                    title: 'İçindekiler',
                    image: _viewModel.imageIngredients,
                    onPickCamera: () => _viewModel.pickImage('ingredients', ImageSource.camera),
                    onPickGallery: () => _viewModel.pickImage('ingredients', ImageSource.gallery),
                    onRemove: () => _viewModel.removeImage('ingredients'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildPhotoCard(
                    title: 'Besin Değeri',
                    image: _viewModel.imageNutrition,
                    onPickCamera: () => _viewModel.pickImage('nutrition', ImageSource.camera),
                    onPickGallery: () => _viewModel.pickImage('nutrition', ImageSource.gallery),
                    onRemove: () => _viewModel.removeImage('nutrition'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _viewModel.isLoading ? null : _handleSubmit,
                icon: _viewModel.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Icon(Icons.send_rounded),
                label: Text(_viewModel.isLoading ? 'Gönderiliyor...' : 'Ürünü Bildir'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoCard({
    required String title,
    required XFile? image,
    required VoidCallback onPickCamera,
    required VoidCallback onPickGallery,
    required VoidCallback onRemove,
  }) {
    final hasImage = image != null;

    return AspectRatio(
      aspectRatio: 0.85,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: hasImage ? AkilliSepetColors.primary : const Color(0xFFE5E7EB), width: hasImage ? 2 : 1),
        ),
        child: Stack(
          children: [
            if (hasImage)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: kIsWeb
                    ? Image.network(image.path, fit: BoxFit.cover, width: double.infinity, height: double.infinity)
                    : Image.file(File(image.path), fit: BoxFit.cover, width: double.infinity, height: double.infinity),
              )
            else
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_a_photo_outlined, color: AkilliSepetColors.primary, size: 28),
                    const SizedBox(height: 6),
                    Text(
                      title,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AkilliSepetColors.textPrimary),
                    ),
                  ],
                ),
              ),
            if (hasImage)
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: onRemove,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                    child: const Icon(Icons.close, size: 14, color: Colors.white),
                  ),
                ),
              ),
            if (!hasImage)
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => _showPickOptions(context, onPickCamera, onPickGallery),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showPickOptions(BuildContext context, VoidCallback onCamera, VoidCallback onGallery) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: AkilliSepetColors.primary),
              title: const Text('Kamera ile Çek'),
              onTap: () {
                Navigator.pop(ctx);
                onCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AkilliSepetColors.primary),
              title: const Text('Galeriden Seç'),
              onTap: () {
                Navigator.pop(ctx);
                onGallery();
              },
            ),
          ],
        ),
      ),
    );
  }
}
