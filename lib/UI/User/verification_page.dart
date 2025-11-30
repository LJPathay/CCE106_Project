import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import '../../layout/theme.dart';
import '../../Services/firebase_service.dart';
import '../../Services/cloudinary_service.dart';

class VerificationPage extends StatefulWidget {
  const VerificationPage({super.key});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  final TextEditingController _additionalInfoController =
      TextEditingController();
  final FirebaseService _firebaseService = FirebaseService();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final ImagePicker _imagePicker = ImagePicker();

  String _selectedIdType = 'National ID';
  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;
  final bool _isSubmitting = false;
  bool _isVerified = false;
  bool _isLoading = true;

  static const Color _accentPink = AppTheme.primaryPink;

  final List<String> _idTypes = [
    'National ID',
    'Passport',
    'Driver\'s License',
    'SSS ID',
    'TIN ID',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _checkVerificationStatus();
  }

  Future<void> _checkVerificationStatus() async {
    try {
      final verified = await _firebaseService.isUserVerified();
      if (mounted) {
        setState(() {
          _isVerified = verified;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image; // Store XFile directly
          _selectedImageBytes = null; // Will be read when needed
        });
      }
    } catch (e) {
      if (mounted) {
        AppTheme.showErrorSnackBar(context, 'Error picking image: $e');
      }
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = image; // Store XFile directly
          _selectedImageBytes = null; // Will be read when needed
        });
      }
    } catch (e) {
      if (mounted) {
        AppTheme.showErrorSnackBar(context, 'Error picking image: $e');
      }
    }
  }

  Future<void> _submitVerification() async {
    if (_selectedImage == null) {
      AppTheme.showErrorSnackBar(context, 'Please upload a photo of your ID');
      return;
    }

    AppTheme.showLoadingDialog(context);

    try {
      // Upload image to Cloudinary first
      final imageUrl = await _cloudinaryService.uploadImage(_selectedImage!);

      if (imageUrl == null) {
        throw Exception('Failed to upload image. Please try again.');
      }

      // Save verification request with Cloudinary URL
      await _firebaseService.submitVerificationRequest(
        idImageUrl: imageUrl,
        idType: _selectedIdType,
        additionalInfo: _additionalInfoController.text.trim().isEmpty
            ? null
            : _additionalInfoController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context); // Dismiss loading dialog
        AppTheme.showSuccessSnackBar(
          context,
          'Verification request submitted! We will review your documents and notify you once verified.',
        );
        setState(() {
          _selectedImage = null;
          _additionalInfoController.clear();
        });
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Dismiss loading dialog
        AppTheme.showErrorSnackBar(context, 'Error: ${e.toString()}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: ShaderMask(
          shaderCallback: (bounds) =>
              AppTheme.instagramGradient.createShader(bounds),
          child: const Text(
            'Account Verification',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _isVerified
          ? _buildVerifiedView()
          : _buildVerificationForm(),
    );
  }

  Widget _buildVerifiedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified,
                color: AppTheme.success,
                size: 80,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Account Verified',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.success,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Your account has been verified. You can now apply for loans.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationForm() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Info Card
        Card(
          color: Colors.blue.shade50,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.blue.shade100),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Verification is required to apply for loans. Please submit a valid government-issued ID.',
                    style: TextStyle(color: Colors.blue.shade900, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // ID Type
        Text(
          'ID Type',
          style: AppTheme.subheading.copyWith(color: Colors.black87),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedIdType,
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down,
                color: Colors.black87,
              ),
              items: _idTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(
                    type,
                    style: const TextStyle(color: Colors.black87),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedIdType = value);
                }
              },
            ),
          ),
        ),
        const SizedBox(height: 24),

        // ID Photo Upload
        Text(
          'Upload ID Photo',
          style: AppTheme.subheading.copyWith(color: Colors.black87),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) => SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.camera_alt),
                      title: const Text('Take Photo'),
                      onTap: () {
                        Navigator.pop(context);
                        _pickImage();
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.photo_library),
                      title: const Text('Choose from Gallery'),
                      onTap: () {
                        Navigator.pop(context);
                        _pickImageFromGallery();
                      },
                    ),
                  ],
                ),
              ),
            );
          },
          child: Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _selectedImage != null
                    ? AppTheme.success
                    : Colors.grey.shade300,
                width: 2,
              ),
            ),
            child: _selectedImage != null
                ? Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: _selectedImage != null
                            ? FutureBuilder<Uint8List>(
                                future: _selectedImage!.readAsBytes(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState ==
                                          ConnectionState.done &&
                                      snapshot.hasData) {
                                    return Image.memory(
                                      snapshot.data!,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                    );
                                  }
                                  return const Center(
                                    child: CircularProgressIndicator(),
                                  );
                                },
                              )
                            : const SizedBox.shrink(),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () {
                              setState(() => _selectedImage = null);
                            },
                          ),
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 64,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Tap to upload ID photo',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Camera or Gallery',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
        const SizedBox(height: 24),

        // Additional Information
        Text(
          'Additional Information (Optional)',
          style: AppTheme.subheading.copyWith(color: Colors.black87),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: TextField(
            controller: _additionalInfoController,
            maxLines: null,
            expands: true,
            decoration: InputDecoration(
              hintText: "Any additional information you'd like to provide",
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppTheme.primaryPink,
                  width: 2,
                ),
              ),
            ),
            style: const TextStyle(color: Colors.black87),
          ),
        ),
        const SizedBox(height: 32),

        // Submit Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryPink,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              elevation: 2,
            ),
            onPressed: _isSubmitting ? null : _submitVerification,
            child: _isSubmitting
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                : const Text(
                    'Submit Verification Request',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
          ),
        ),
        const SizedBox(height: 16),

        // Note
        Text(
          'Note: Verification typically takes 1-3 business days. You will be notified once your account is verified.',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
      ],
    );
  }
}
