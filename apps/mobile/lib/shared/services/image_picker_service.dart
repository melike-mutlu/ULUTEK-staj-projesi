import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

/// A picked image: raw bytes plus the extension the repository needs to build
/// a storage path and content type.
class PickedImage {
  const PickedImage({required this.bytes, required this.extension});

  final Uint8List bytes;
  final String extension;
}

/// Wraps image_picker so ViewModels stay free of plugin and platform types —
/// and can be unit tested with a fake.
abstract class ImagePickerService {
  /// Returns null when the user cancels the picker.
  Future<PickedImage?> pickFromGallery();
  Future<PickedImage?> pickFromCamera();
}

class DeviceImagePickerService implements ImagePickerService {
  DeviceImagePickerService([ImagePicker? picker])
      : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  /// Avatars are displayed at well under 200px, so a full-resolution photo
  /// would be a slow upload for no visible gain.
  static const double _maxDimension = 512;
  static const int _quality = 85;

  /// Extensions the avatars bucket is set up to serve. Anything else (iOS
  /// HEIC, for instance) is already re-encoded to JPEG by the resize above.
  static const Set<String> _supportedExtensions = <String>{
    'jpg',
    'jpeg',
    'png',
    'webp',
  };

  @override
  Future<PickedImage?> pickFromGallery() async {
    final file = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: _maxDimension,
      maxHeight: _maxDimension,
      imageQuality: _quality,
    );
    if (file == null) return null;

    final extension = file.path.split('.').last.toLowerCase();
    return PickedImage(
      bytes: await file.readAsBytes(),
      extension:
          _supportedExtensions.contains(extension) ? extension : 'jpg',
    );
  }

  @override
  Future<PickedImage?> pickFromCamera() async {
    final file = await _picker.pickImage(
      source: ImageSource.camera,
      maxWidth: _maxDimension,
      maxHeight: _maxDimension,
      imageQuality: _quality,
    );
    if (file == null) return null;

    final extension = file.path.split('.').last.toLowerCase();
    return PickedImage(
      bytes: await file.readAsBytes(),
      extension: _supportedExtensions.contains(extension) ? extension : 'jpg',
    );
  }
}

final imagePickerServiceProvider = Provider<ImagePickerService>(
  (ref) => DeviceImagePickerService(),
);
