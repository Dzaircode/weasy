import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../constants.dart';
import '../../../services/auth_service.dart';
import '../home/home_screen.dart';

class RegistrationScreen extends StatefulWidget {
  static const routeName = '/registration';
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker  = ImagePicker();
  bool  _isLoading = false;

  // Personal
  final _firstNameCtrl    = TextEditingController();
  final _lastNameCtrl     = TextEditingController();
  final _emailCtrl        = TextEditingController();

  // Restaurant
  final _restaurantCtrl   = TextEditingController();
  final _addressCtrl      = TextEditingController();

  // Social
  final _instagramCtrl    = TextEditingController();
  final _facebookCtrl     = TextEditingController();
  final _tiktokCtrl       = TextEditingController();
  final _whatsappCtrl     = TextEditingController();

  // Images
  File? _logoFile;
  File? _coverFile;

  late String _phone;
  bool _phoneLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_phoneLoaded) {
      _phone      = ModalRoute.of(context)!.settings.arguments as String;
      _phoneLoaded = true;
    }
  }

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
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
      source:     ImageSource.gallery,
      imageQuality: 80,
    );
    if (xFile == null) return;
    setState(() {
      if (isLogo) {
        _logoFile = File(xFile.path);
      } else {
        _coverFile = File(xFile.path);
      }
    });
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await AuthService.register(
      phone:          _phone,
      firstName:      _firstNameCtrl.text.trim(),
      lastName:       _lastNameCtrl.text.trim(),
      email:          _emailCtrl.text.trim(),
      restaurantName: _restaurantCtrl.text.trim(),
      address:        _addressCtrl.text.trim(),
      logoPath:       _logoFile?.path,
      coverPath:      _coverFile?.path,
      instagram:      _instagramCtrl.text.trim(),
      facebook:       _facebookCtrl.text.trim(),
      tiktok:         _tiktokCtrl.text.trim(),
      whatsapp:       _whatsappCtrl.text.trim(),
    );

    setState(() => _isLoading = false);

    if (!result.success) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:         Text(result.message ?? 'Registration failed.'),
          backgroundColor: kErrorColor,
          behavior:        SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      HomeScreen.routeName,
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('Create your account'),
        leading: const BackButton(),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(kDefaultPadding),
          children: [
            // ── Cover image ──────────────────────────────────
            _CoverImagePicker(
              file:     _coverFile,
              logoFile: _logoFile,
              onPickCover: () => _pickImage(false),
              onPickLogo:  () => _pickImage(true),
            ),
            const SizedBox(height: 28),

            // ── Section: Personal Info ────────────────────────
            _SectionHeader(
              icon:  Icons.person_outline_rounded,
              title: 'Personal Information',
            ),
            const SizedBox(height: 14),
            _buildField(
              controller: _firstNameCtrl,
              label:      'First Name',
              hint:       'Ahmed',
              validator:  (v) => v!.isEmpty ? kFirstNameNullError : null,
            ),
            const SizedBox(height: 14),
            _buildField(
              controller: _lastNameCtrl,
              label:      'Family Name',
              hint:       'Benali',
              validator:  (v) => v!.isEmpty ? kLastNameNullError : null,
            ),
            const SizedBox(height: 14),
            _buildField(
              controller:   _emailCtrl,
              label:        'Email Address',
              hint:         'ahmed@example.com',
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return kEmailInvalidError;
                final reg = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                return reg.hasMatch(v) ? null : kEmailInvalidError;
              },
            ),
            const SizedBox(height: 14),

            // Phone (pre-filled & locked)
            _LockedPhoneField(phone: _phoneLoaded ? _phone : ''),
            const SizedBox(height: 28),

            // ── Section: Restaurant Info ──────────────────────
            _SectionHeader(
              icon:  Icons.restaurant_menu_rounded,
              title: 'Restaurant Information',
            ),
            const SizedBox(height: 14),
            _buildField(
              controller: _restaurantCtrl,
              label:      'Restaurant Name',
              hint:       'Burger House Oran',
              validator:  (v) => v!.isEmpty ? kRestaurantNullError : null,
            ),
            const SizedBox(height: 14),
            _buildField(
              controller: _addressCtrl,
              label:      'Address',
              hint:       'Rue des Fleurs, Oran',
              maxLines:   2,
              validator:  (v) => v!.isEmpty ? kAddressNullError : null,
            ),
            const SizedBox(height: 28),

            // ── Section: Social Media ─────────────────────────
            _SectionHeader(
              icon:     Icons.link_rounded,
              title:    'Social Media',
              subtitle: 'Optional — helps customers find you',
            ),
            const SizedBox(height: 14),
            _SocialField(
              controller: _instagramCtrl,
              platform:   'Instagram',
              icon:       Icons.camera_alt_outlined,
              hint:       'instagram.com/yourpage',
              color:      const Color(0xFFE1306C),
            ),
            const SizedBox(height: 12),
            _SocialField(
              controller: _facebookCtrl,
              platform:   'Facebook',
              icon:       Icons.facebook_rounded,
              hint:       'facebook.com/yourpage',
              color:      const Color(0xFF1877F2),
            ),
            const SizedBox(height: 12),
            _SocialField(
              controller: _tiktokCtrl,
              platform:   'TikTok',
              icon:       Icons.music_note_rounded,
              hint:       'tiktok.com/@yourpage',
              color:      const Color(0xFF000000),
            ),
            const SizedBox(height: 12),
            _SocialField(
              controller: _whatsappCtrl,
              platform:   'WhatsApp',
              icon:       Icons.chat_rounded,
              hint:       '+213 7XX XX XX XX',
              color:      const Color(0xFF25D366),
            ),
            const SizedBox(height: 36),

            // ── Submit ────────────────────────────────────────
            ElevatedButton(
              onPressed: _isLoading ? null : _handleRegister,
              child: _isLoading
                  ? const SizedBox(
                      height: 22,
                      width:  22,
                      child:  CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Create Account'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller:   controller,
      keyboardType: keyboardType,
      maxLines:     maxLines,
      validator:    validator,
      decoration: InputDecoration(
        labelText: label,
        hintText:  hint,
      ),
    );
  }
}

// ── Cover + Logo picker ──────────────────────────────────
class _CoverImagePicker extends StatelessWidget {
  const _CoverImagePicker({
    required this.file,
    required this.logoFile,
    required this.onPickCover,
    required this.onPickLogo,
  });

  final File?      file;
  final File?      logoFile;
  final VoidCallback onPickCover;
  final VoidCallback onPickLogo;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Cover
        GestureDetector(
          onTap: onPickCover,
          child: Container(
            height: 160,
            decoration: BoxDecoration(
              color:        kBorderColor,
              borderRadius: BorderRadius.circular(16),
              image: file != null
                  ? DecorationImage(
                      image: FileImage(file!),
                      fit:   BoxFit.cover,
                    )
                  : null,
            ),
            child: file == null
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add_photo_alternate_outlined,
                          size: 36, color: kSubTextColor),
                      SizedBox(height: 8),
                      Text(
                        'Add cover photo',
                        style: TextStyle(color: kSubTextColor, fontSize: 14),
                      ),
                    ],
                  )
                : null,
          ),
        ),

        // Logo overlapping the cover
        Transform.translate(
          offset: const Offset(0, -40),
          child: GestureDetector(
            onTap: onPickLogo,
            child: Container(
              width:  80,
              height: 80,
              decoration: BoxDecoration(
                color:        Colors.white,
                shape:        BoxShape.circle,
                border:       Border.all(color: Colors.white, width: 3),
                boxShadow: [
                  BoxShadow(
                    color:      Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset:     const Offset(0, 2),
                  )
                ],
                image: logoFile != null
                    ? DecorationImage(
                        image: FileImage(logoFile!),
                        fit:   BoxFit.cover,
                      )
                    : null,
              ),
              child: logoFile == null
                  ? const Icon(Icons.add_a_photo_rounded,
                      size: 28, color: kSubTextColor)
                  : null,
            ),
          ),
        ),

        Transform.translate(
          offset: const Offset(0, -32),
          child: Text(
            'Logo',
            style: TextStyle(
              fontSize: 12,
              color:    kSubTextColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Section Header ────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    this.subtitle,
  });

  final IconData icon;
  final String   title;
  final String?  subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding:     const EdgeInsets.all(8),
          decoration:  BoxDecoration(
            color:        kPrimaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: kPrimaryColor, size: 20),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize:   16,
                fontWeight: FontWeight.w700,
                color:      kTextColor,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                style: const TextStyle(fontSize: 12, color: kSubTextColor),
              ),
          ],
        ),
      ],
    );
  }
}

// ── Locked phone field ────────────────────────────────────
class _LockedPhoneField extends StatelessWidget {
  const _LockedPhoneField({required this.phone});
  final String phone;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color:        kBorderColor.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: kBorderColor),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline_rounded,
              size: 18, color: kSubTextColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Phone Number',
                  style: TextStyle(fontSize: 12, color: kSubTextColor),
                ),
                const SizedBox(height: 2),
                Text(
                  phone,
                  style: const TextStyle(
                    fontSize:   15,
                    fontWeight: FontWeight.w600,
                    color:      kTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Social media field ────────────────────────────────────
class _SocialField extends StatelessWidget {
  const _SocialField({
    required this.controller,
    required this.platform,
    required this.icon,
    required this.hint,
    required this.color,
  });

  final TextEditingController controller;
  final String  platform;
  final IconData icon;
  final String  hint;
  final Color   color;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.url,
      decoration: InputDecoration(
        labelText: platform,
        hintText:  hint,
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }
}