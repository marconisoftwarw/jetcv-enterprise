import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/legal_entity_image_service.dart';
import '../../widgets/custom_button.dart';
import '../../l10n/app_localizations.dart';

class LegalEntityImageUploadScreen extends StatefulWidget {
  final String legalEntityId;
  final String legalEntityName;

  const LegalEntityImageUploadScreen({
    super.key,
    required this.legalEntityId,
    required this.legalEntityName,
  });

  @override
  State<LegalEntityImageUploadScreen> createState() =>
      _LegalEntityImageUploadScreenState();
}

class _LegalEntityImageUploadScreenState
    extends State<LegalEntityImageUploadScreen> {
  // Image files
  File? _logoImage;
  File? _companyImage;

  // For web platform - store image data as Uint8List
  Uint8List? _logoImageData;
  Uint8List? _companyImageData;

  // Loading states
  bool _isLoading = false;
  bool _isPickingImage = false;
  bool _isUploading = false;

  // Services
  final ImagePicker _imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context).getString('upload_company_images') ??
              'Carica Immagini Azienda',
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              AppLocalizations.of(context).getString('upload_images_title') ??
                  'Carica Logo e Foto Azienda',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              AppLocalizations.of(
                    context,
                  ).getString('upload_images_subtitle') ??
                  'Carica il logo azienda e una foto rappresentativa della tua azienda.',
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),

            // Images section
            Row(
              children: [
                // Logo section
                Expanded(
                  child: _buildImageSection(
                    title:
                        AppLocalizations.of(
                          context,
                        ).getString('company_logo_label') ??
                        'Logo Azienda',
                    icon: Icons.business,
                    image: _logoImage,
                    imageData: _logoImageData,
                    onPick: _pickLogoImage,
                    onRemove: _removeLogoImage,
                    isUploading: _isUploading,
                  ),
                ),
                const SizedBox(width: 16),
                // Company photo section
                Expanded(
                  child: _buildImageSection(
                    title:
                        AppLocalizations.of(
                          context,
                        ).getString('company_photo_label') ??
                        'Foto Azienda',
                    icon: Icons.photo_camera,
                    image: _companyImage,
                    imageData: _companyImageData,
                    onPick: _pickCompanyImage,
                    onRemove: _removeCompanyImage,
                    isUploading: _isUploading,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Upload button
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                onPressed: _isUploading ? null : _uploadImages,
                text: _isUploading
                    ? AppLocalizations.of(context).getString('uploading') ??
                          'Caricamento...'
                    : AppLocalizations.of(context).getString('upload_images') ??
                          'Carica Immagini',
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 16),

            // Info text
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.blue.shade600,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(
                            context,
                          ).getString('image_upload_info') ??
                          'Formati supportati: JPG, PNG, GIF, WebP, AVIF, HEIC, BMP, TIFF. Dimensione massima: 50MB',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
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

  Widget _buildImageSection({
    required String title,
    required IconData icon,
    required File? image,
    required Uint8List? imageData,
    required VoidCallback onPick,
    required VoidCallback onRemove,
    required bool isUploading,
  }) {
    return Column(
      children: [
        // Image container
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: image != null
                  ? Colors.green.shade400
                  : Colors.grey.shade300,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipOval(
            child: image != null
                ? kIsWeb && imageData != null
                      ? Image.memory(
                          imageData,
                          fit: BoxFit.cover,
                          width: 120,
                          height: 120,
                        )
                      : Image.file(
                          image,
                          fit: BoxFit.cover,
                          width: 120,
                          height: 120,
                        )
                : Container(
                    color: Colors.grey.shade100,
                    child: Icon(icon, size: 40, color: Colors.grey.shade600),
                  ),
          ),
        ),

        const SizedBox(height: 12),

        // Title
        Text(
          title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        // Buttons
        Row(
          children: [
            Expanded(
              child: CustomButton(
                onPressed: isUploading ? null : onPick,
                text: image != null
                    ? AppLocalizations.of(context).getString('change') ??
                          'Cambia'
                    : AppLocalizations.of(context).getString('select') ??
                          'Seleziona',
                backgroundColor: image != null ? Colors.orange : Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            if (image != null) ...[
              const SizedBox(width: 8),
              CustomButton(
                onPressed: isUploading ? null : onRemove,
                text: '✕',
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ],
          ],
        ),

        // Status indicator
        if (image != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '✓ ${AppLocalizations.of(context).getString('ready_to_upload') ?? 'Pronto per l\'invio'}',
              style: TextStyle(
                fontSize: 10,
                color: Colors.green.shade600,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  Future<void> _pickLogoImage() async {
    await _pickImage(
      onImagePicked: (file, data) {
        setState(() {
          _logoImage = file;
          if (kIsWeb) {
            _logoImageData = data;
          }
        });
      },
    );
  }

  Future<void> _pickCompanyImage() async {
    await _pickImage(
      onImagePicked: (file, data) {
        setState(() {
          _companyImage = file;
          if (kIsWeb) {
            _companyImageData = data;
          }
        });
      },
    );
  }

  Future<void> _pickImage({
    required Function(File file, Uint8List? data) onImagePicked,
  }) async {
    if (_isPickingImage) return;

    setState(() {
      _isPickingImage = true;
    });

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final file = File(image.path);

        // Validate image file
        bool isValidFormat = false;
        if (image.path.startsWith('blob:')) {
          // For web blob URLs, validate using XFile name
          final fileName = image.name.toLowerCase();
          final validExtensions = [
            '.jpg',
            '.jpeg',
            '.png',
            '.gif',
            '.webp',
            '.avif',
            '.heic',
            '.bmp',
            '.tiff',
          ];
          isValidFormat = validExtensions.any((ext) => fileName.endsWith(ext));
        } else {
          // For regular file paths, use the existing validation
          isValidFormat = LegalEntityImageService.validateImageFile(file);
        }

        if (!isValidFormat) {
          _showError(
            AppLocalizations.of(context).getString('invalid_image_format') ??
                'Formato immagine non valido',
          );
          return;
        }

        // Check file size
        if (!await LegalEntityImageService.isFileSizeValid(
          file,
          maxSizeMB: 50.0,
        )) {
          _showError(
            AppLocalizations.of(context).getString('file_too_large') ??
                'File troppo grande',
          );
          return;
        }

        // Load image data for web platform
        Uint8List? imageData;
        if (kIsWeb) {
          imageData = await image.readAsBytes();
        }

        onImagePicked(file, imageData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(
                    context,
                  ).getString('image_selected_successfully') ??
                  'Immagine selezionata con successo!',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      _showError(
        '${AppLocalizations.of(context).getString('image_selection_error') ?? 'Errore nella selezione'}: $e',
      );
    } finally {
      setState(() {
        _isPickingImage = false;
      });
    }
  }

  void _removeLogoImage() {
    setState(() {
      _logoImage = null;
      if (kIsWeb) {
        _logoImageData = null;
      }
    });
  }

  void _removeCompanyImage() {
    setState(() {
      _companyImage = null;
      if (kIsWeb) {
        _companyImageData = null;
      }
    });
  }

  Future<void> _uploadImages() async {
    if (_logoImage == null && _companyImage == null) {
      _showError(
        AppLocalizations.of(context).getString('select_at_least_one_image') ??
            'Seleziona almeno un\'immagine da caricare',
      );
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Upload logo if selected
      if (_logoImage != null) {
        await LegalEntityImageService.uploadLegalEntityLogoPicture(
          imageFile: _logoImage!,
          legalEntityId: widget.legalEntityId,
          filename:
              'logo_${widget.legalEntityName.replaceAll(' ', '_').toLowerCase()}.jpg',
        );
        print('✅ Logo uploaded successfully');
      }

      // Upload company image if selected
      if (_companyImage != null) {
        await LegalEntityImageService.uploadLegalEntityCompanyPicture(
          imageFile: _companyImage!,
          legalEntityId: widget.legalEntityId,
          filename:
              'company_${widget.legalEntityName.replaceAll(' ', '_').toLowerCase()}.jpg',
        );
        print('✅ Company image uploaded successfully');
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(
                  context,
                ).getString('images_uploaded_successfully') ??
                'Immagini caricate con successo!',
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      // Navigate back
      Navigator.pop(context);
    } catch (e) {
      print('❌ Error uploading images: $e');
      _showError(
        '${AppLocalizations.of(context).getString('upload_error') ?? 'Errore nel caricamento'}: $e',
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
