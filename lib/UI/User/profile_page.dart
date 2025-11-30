import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../layout/theme.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();

  bool _isEditing = false;
  bool _isLoading = true;

  // User data
  String _fullName = '';
  String _email = '';
  String _phone = '';
  String _address = '';
  String _verificationStatus = 'Not Verified';

  // Controllers for editing
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('Account')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _fullName = data['fullName'] ?? '';
          _email = user.email ?? '';
          _phone = data['phone'] ?? '';
          _address = data['address'] ?? '';

          // Check isVerified boolean first, fallback to verificationStatus string
          bool isVerified = data['isVerified'] ?? false;
          if (isVerified) {
            _verificationStatus = 'Verified';
          } else {
            _verificationStatus = data['verificationStatus'] ?? 'Not Verified';
          }

          _fullNameController.text = _fullName;
          _phoneController.text = _phone;
          _addressController.text = _address;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading profile: $e')));
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    AppTheme.showLoadingDialog(context);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      await FirebaseFirestore.instance
          .collection('Account')
          .doc(user.uid)
          .update({
            'fullName': _fullNameController.text.trim(),
            'phone': _phoneController.text.trim(),
            'address': _addressController.text.trim(),
          });

      if (mounted) {
        Navigator.pop(context); // Dismiss loading dialog
        setState(() {
          _fullName = _fullNameController.text.trim();
          _phone = _phoneController.text.trim();
          _address = _addressController.text.trim();
          _isEditing = false;
        });
        AppTheme.showSuccessSnackBar(context, 'Profile updated successfully');
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Dismiss loading dialog
        AppTheme.showErrorSnackBar(context, 'Error updating profile: $e');
      }
    }
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Change Password',
            style: AppTheme.subheading.copyWith(color: Colors.black87),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: currentPasswordController,
                  obscureText: obscureCurrent,
                  decoration: InputDecoration(
                    labelText: 'Current Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureCurrent
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () => setDialogState(
                        () => obscureCurrent = !obscureCurrent,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: newPasswordController,
                  obscureText: obscureNew,
                  decoration: InputDecoration(
                    labelText: 'New Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureNew ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () =>
                          setDialogState(() => obscureNew = !obscureNew),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: obscureConfirm,
                  decoration: InputDecoration(
                    labelText: 'Confirm New Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureConfirm
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () => setDialogState(
                        () => obscureConfirm = !obscureConfirm,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (newPasswordController.text !=
                    confirmPasswordController.text) {
                  AppTheme.showErrorSnackBar(context, 'Passwords do not match');
                  return;
                }

                if (newPasswordController.text.length < 6) {
                  AppTheme.showErrorSnackBar(
                    context,
                    'Password must be at least 6 characters',
                  );
                  return;
                }

                Navigator.pop(context); // Close dialog
                AppTheme.showLoadingDialog(context); // Show loading

                try {
                  final user = FirebaseAuth.instance.currentUser;
                  final credential = EmailAuthProvider.credential(
                    email: user!.email!,
                    password: currentPasswordController.text,
                  );

                  await user.reauthenticateWithCredential(credential);
                  await user.updatePassword(newPasswordController.text);

                  if (mounted) {
                    Navigator.pop(context); // Dismiss loading
                    // ignore: use_build_context_synchronously
                    AppTheme.showSuccessSnackBar(
                      context,
                      'Password changed successfully',
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    Navigator.pop(context); // Dismiss loading
                    // ignore: use_build_context_synchronously
                    AppTheme.showErrorSnackBar(
                      context,
                      'Error: ${e.toString()}',
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryPink,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Change Password',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Profile',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: AppTheme.primaryPink),
              onPressed: () => setState(() => _isEditing = true),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Profile Header
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppTheme.softShadow,
                      ),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: AppTheme.primaryPink,
                            child: Text(
                              _fullName.isNotEmpty
                                  ? _fullName[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                fontSize: 40,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _fullName.isEmpty ? 'User' : _fullName,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _email,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _verificationStatus == 'Verified'
                                  ? AppTheme.success.withValues(alpha: 0.1)
                                  : AppTheme.warning.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _verificationStatus == 'Verified'
                                    ? AppTheme.success
                                    : AppTheme.warning,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _verificationStatus == 'Verified'
                                      ? Icons.verified
                                      : Icons.pending,
                                  size: 16,
                                  color: _verificationStatus == 'Verified'
                                      ? AppTheme.success
                                      : AppTheme.warning,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _verificationStatus,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _verificationStatus == 'Verified'
                                        ? AppTheme.success
                                        : AppTheme.warning,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Profile Information
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: AppTheme.softShadow,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Personal Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildInfoField(
                            'Full Name',
                            _fullNameController,
                            Icons.person_outline,
                            enabled: _isEditing,
                          ),
                          const SizedBox(height: 16),
                          _buildInfoField(
                            'Email',
                            TextEditingController(text: _email),
                            Icons.email_outlined,
                            enabled: false,
                          ),
                          const SizedBox(height: 16),
                          _buildInfoField(
                            'Phone Number',
                            _phoneController,
                            Icons.phone_outlined,
                            enabled: _isEditing,
                          ),
                          const SizedBox(height: 16),
                          _buildInfoField(
                            'Address',
                            _addressController,
                            Icons.location_on_outlined,
                            enabled: _isEditing,
                            maxLines: 2,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Action Buttons
                    if (_isEditing)
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                setState(() {
                                  _isEditing = false;
                                  _fullNameController.text = _fullName;
                                  _phoneController.text = _phone;
                                  _addressController.text = _address;
                                });
                              },
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                side: BorderSide(color: Colors.grey[300]!),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(color: Colors.black87),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryPink,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
                                'Save Changes',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          _buildActionButton(
                            'Change Password',
                            Icons.lock_outline,
                            _showChangePasswordDialog,
                          ),
                          const SizedBox(height: 12),
                          _buildActionButton(
                            _verificationStatus == 'Verified'
                                ? 'View Verification Status'
                                : 'Complete Verification',
                            _verificationStatus == 'Verified'
                                ? Icons.verified_user
                                : Icons.verified_user_outlined,
                            () => Navigator.pushNamed(context, '/verification'),
                          ),
                          const SizedBox(height: 12),
                          _buildActionButton(
                            'Delete Account',
                            Icons.delete_outline,
                            _showDeleteAccountDialog,
                            isDestructive: true,
                          ),
                        ],
                      ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool enabled = true,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppTheme.primaryPink),
            filled: true,
            fillColor: enabled ? Colors.white : Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppTheme.primaryPink,
                width: 2,
              ),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
          ),
          validator: enabled && label != 'Email'
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your $label';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    VoidCallback onTap, {
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDestructive
                ? Colors.red.withValues(alpha: 0.3)
                : Colors.grey[300]!,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isDestructive ? Colors.red : AppTheme.primaryPink,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: isDestructive ? Colors.red : Colors.black87,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    AppTheme.showConfirmDialog(
      context: context,
      title: 'Delete Account',
      content:
          'Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently deleted.',
      confirmText: 'Delete',
      confirmColor: Colors.red,
    ).then((confirmed) async {
      if (confirmed == true) {
        AppTheme.showLoadingDialog(context);
        try {
          final user = FirebaseAuth.instance.currentUser;
          await FirebaseFirestore.instance
              .collection('Account')
              .doc(user!.uid)
              .delete();
          await user.delete();

          if (mounted) {
            Navigator.pop(context); // Dismiss loading
            // ignore: use_build_context_synchronously
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/login', (route) => false);
          }
        } catch (e) {
          if (mounted) {
            Navigator.pop(context); // Dismiss loading
            // ignore: use_build_context_synchronously
            AppTheme.showErrorSnackBar(context, 'Error: ${e.toString()}');
          }
        }
      }
    });
  }
}
