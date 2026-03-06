import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../constants.dart';
import '../../services/auth_service.dart';
import '../../services/storage_service.dart';
import '../../models/merchant_model.dart';
import '../auth/phone_entry/phone_entry_screen.dart';

class ProfileScreen extends StatefulWidget {
  static const routeName = '/profile';
  final bool embedded;
  const ProfileScreen({super.key, this.embedded = false});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey         = GlobalKey<FormState>();
  final _picker          = ImagePicker();
  final _restaurantCtrl  = TextEditingController();
  final _addressCtrl     = TextEditingController();
  final _instagramCtrl   = TextEditingController();
  final _facebookCtrl    = TextEditingController();
  final _tiktokCtrl      = TextEditingController();
  final _whatsappCtrl    = TextEditingController();

  MerchantModel? _merchant;
  File? _newLogoFile;
  File? _newCoverFile;
  bool  _isLoading = false;
  bool  _editMode  = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final m = await StorageService.getMerchant();
    setState(() {
      _merchant = m;
      // TODO: load restaurant data from API and pre-fill fields
      _restaurantCtrl.text = 'Burger House Oran'; // demo
      _addressCtrl.text    = 'Rue des Fleurs, Oran'; // demo
    });
  }

  @override
  void dispose() {
    _restaurantCtrl.dispose();
    _addressCtrl.dispose();
    _instagramCtrl.dispose();
    _facebookCtrl.dispose();
    _tiktokCtrl.dispose();
    _whatsappCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage(bool isLogo) async {
    final xFile = await _picker.pickImage(
        source: ImageSource.gallery, imageQuality: 80);
    if (xFile == null) return;
    setState(() {
      if (isLogo) {
        _newLogoFile = File(xFile.path);
      } else {
        _newCoverFile = File(xFile.path);
      }
    });
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    // TODO: call ApiService.putFormData('/restaurants/:id', formData)
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _isLoading = false;
      _editMode  = false;
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:         const Text('Profile updated!'),
        backgroundColor: kSuccessColor,
        behavior:        SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title:   const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout',
                style: TextStyle(color: kErrorColor)),
          ),
        ],
      ),
    );

    if (confirm != true) return;
    await AuthService.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      PhoneEntryScreen.routeName,
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: widget.embedded
          ? null
          : AppBar(
              title: const Text('Profile'),
              actions: [
                TextButton(
                  onPressed: () => setState(() => _editMode = !_editMode),
                  child: Text(
                    _editMode ? 'Cancel' : 'Edit',
                    style: const TextStyle(color: kPrimaryColor),
                  ),
                ),
              ],
            ),
      body: Form(
        key: _formKey,
        child: ListView(
          children: [
            // Header
            if (widget.embedded)
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    kDefaultPadding, kDefaultPadding, kDefaultPadding, 0),
                child: Row(
                  children: [
                    const Text(
                      'Profile',
                      style: TextStyle(
                        fontSize:   22,
                        fontWeight: FontWeight.w800,
                        color:      kTextColor,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => setState(() => _editMode = !_editMode),
                      child: Text(
                        _editMode ? 'Cancel' : 'Edit',
                        style: const TextStyle(color: kPrimaryColor),
                      ),
                    ),
                  ],
                ),
              ),

            // Cover + Logo
            Stack(
              clipBehavior: Clip.none,
              children: [
                // Cover
                GestureDetector(
                  onTap: _editMode ? () => _pickImage(false) : null,
                  child: Container(
                    height: 160,
                    margin: const EdgeInsets.all(kDefaultPadding),
                    decoration: BoxDecoration(
                      color:        kBorderColor.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(16),
                      image: _newCoverFile != null
                          ? DecorationImage(
                              image: FileImage(_newCoverFile!),
                              fit:   BoxFit.cover,
                            )
                          : null,
                    ),
                    child: _newCoverFile == null && _editMode
                        ? const Center(
                            child: Icon(Icons.add_photo_alternate_outlined,
                                size: 36, color: kSubTextColor),
                          )
                        : null,
                  ),
                ),

                // Logo
                Positioned(
                  bottom: -4,
                  left:   kDefaultPadding + 20,
                  child: GestureDetector(
                    onTap: _editMode ? () => _pickImage(true) : null,
                    child: Container(
                      width:  72,
                      height: 72,
                      decoration: BoxDecoration(
                        color:  Colors.white,
                        shape:  BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color:      Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                          )
                        ],
                        image: _newLogoFile != null
                            ? DecorationImage(
                                image: FileImage(_newLogoFile!),
                                fit:   BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _newLogoFile == null
                          ? const Icon(Icons.storefront_rounded,
                              size: 30, color: kSubTextColor)
                          : null,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: kDefaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Merchant name (read-only)
                  Text(
                    _merchant?.fullName ?? '—',
                    style: const TextStyle(
                      fontSize:   20,
                      fontWeight: FontWeight.w800,
                      color:      kTextColor,
                    ),
                  ),
                  Text(
                    _merchant?.phone ?? '—',
                    style: const TextStyle(
                        fontSize: 14, color: kSubTextColor),
                  ),
                  const SizedBox(height: 24),

                  // Restaurant fields
                  _SectionLabel(label: 'Restaurant'),
                  const SizedBox(height: 12),
                  _buildField(
                    controller: _restaurantCtrl,
                    label:      'Restaurant Name',
                    enabled:    _editMode,
                    validator:  (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 12),
                  _buildField(
                    controller: _addressCtrl,
                    label:      'Address',
                    enabled:    _editMode,
                    maxLines:   2,
                    validator:  (v) => v!.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 24),

                  // Social media
                  _SectionLabel(label: 'Social Media'),
                  const SizedBox(height: 12),
                  _buildSocialField(
                    controller: _instagramCtrl,
                    label:      'Instagram',
                    icon:       Icons.camera_alt_outlined,
                    color:      const Color(0xFFE1306C),
                    enabled:    _editMode,
                  ),
                  const SizedBox(height: 12),
                  _buildSocialField(
                    controller: _facebookCtrl,
                    label:      'Facebook',
                    icon:       Icons.facebook_rounded,
                    color:      const Color(0xFF1877F2),
                    enabled:    _editMode,
                  ),
                  const SizedBox(height: 12),
                  _buildSocialField(
                    controller: _tiktokCtrl,
                    label:      'TikTok',
                    icon:       Icons.music_note_rounded,
                    color:      const Color(0xFF000000),
                    enabled:    _editMode,
                  ),
                  const SizedBox(height: 12),
                  _buildSocialField(
                    controller: _whatsappCtrl,
                    label:      'WhatsApp',
                    icon:       Icons.chat_rounded,
                    color:      const Color(0xFF25D366),
                    enabled:    _editMode,
                  ),
                  const SizedBox(height: 32),

                  // Save button (only in edit mode)
                  if (_editMode)
                    ElevatedButton(
                      onPressed: _isLoading ? null : _handleSave,
                      child: _isLoading
                          ? const SizedBox(
                              height: 22,
                              width:  22,
                              child:  CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Text('Save Changes'),
                    ),

                  if (_editMode) const SizedBox(height: 14),

                  // Logout
                  OutlinedButton.icon(
                    onPressed: _logout,
                    icon:  const Icon(Icons.logout_rounded, color: kErrorColor),
                    label: const Text('Logout',
                        style: TextStyle(color: kErrorColor)),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: kErrorColor),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required bool enabled,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines:   maxLines,
      enabled:    enabled,
      validator:  validator,
      decoration: InputDecoration(
        labelText: label,
        filled:    true,
        fillColor: enabled ? Colors.white : kBorderColor.withOpacity(0.3),
      ),
    );
  }

  Widget _buildSocialField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required Color color,
    required bool enabled,
  }) {
    return TextFormField(
      controller: controller,
      enabled:    enabled,
      decoration: InputDecoration(
        labelText:  label,
        filled:     true,
        fillColor:  enabled ? Colors.white : kBorderColor.withOpacity(0.3),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize:       16,
        fontWeight:     FontWeight.w700,
        color:          kTextColor,
        letterSpacing:  0.3,
      ),
    );
  }
}