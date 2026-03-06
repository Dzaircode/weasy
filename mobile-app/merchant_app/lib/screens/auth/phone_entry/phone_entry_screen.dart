import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../constants.dart';
import '../../../services/auth_service.dart';
import '../otp/otp_screen.dart';

class PhoneEntryScreen extends StatefulWidget {
  static const routeName = '/phone-entry';
  const PhoneEntryScreen({super.key});

  @override
  State<PhoneEntryScreen> createState() => _PhoneEntryScreenState();
}

class _PhoneEntryScreenState extends State<PhoneEntryScreen> {
  final _phoneController = TextEditingController();
  String _countryCode = '+213';
  bool   _isLoading   = false;

  // Algerian wilayas prefix codes (for UX only)
  final List<Map<String, String>> _countries = [
    {'name': 'Algeria 🇩🇿', 'code': '+213'},
    {'name': 'France 🇫🇷',  'code': '+33'},
    {'name': 'Morocco 🇲🇦', 'code': '+212'},
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  String get _fullPhone =>
      '$_countryCode${_phoneController.text.trim()}';

  Future<void> _handleContinue() async {
    final phone = _phoneController.text.trim();

    if (phone.isEmpty || phone.length < 9) {
      _showError(kInvalidPhoneError);
      return;
    }

    setState(() => _isLoading = true);

    // 1. Check if phone exists
    final checkResult = await AuthService.checkPhone(_fullPhone);

    if (!checkResult.success) {
      setState(() => _isLoading = false);
      _showError(checkResult.message ?? 'Something went wrong.');
      return;
    }

    // 2. Send OTP regardless of whether user exists or not
    final otpResult = await AuthService.sendOtp(_fullPhone);
    setState(() => _isLoading = false);

    if (!otpResult.success) {
      _showError(otpResult.message ?? 'Failed to send OTP.');
      return;
    }

    // 3. Navigate to OTP screen — pass phone and whether user is new
    if (!mounted) return;
    Navigator.pushNamed(
      context,
      OtpScreen.routeName,
      arguments: OtpArgs(
        phone:     _fullPhone,
        isNewUser: !(checkResult.userExists ?? false),
      ),
    );
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: kErrorColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 12),
        shrinkWrap: true,
        itemCount: _countries.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, i) => ListTile(
          title: Text(_countries[i]['name']!),
          trailing: Text(
            _countries[i]['code']!,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          onTap: () {
            setState(() => _countryCode = _countries[i]['code']!);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(kDefaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Header
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(Icons.storefront_rounded,
                    color: kPrimaryColor, size: 32),
              ),
              const SizedBox(height: 28),
              const Text(
                'Welcome back 👋',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: kTextColor,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Enter your phone number to continue',
                style: TextStyle(fontSize: 15, color: kSubTextColor),
              ),
              const SizedBox(height: 40),

              // Phone input
              const Text(
                'Phone Number',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: kTextColor,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kBorderColor),
                ),
                child: Row(
                  children: [
                    // Country code picker
                    GestureDetector(
                      onTap: _showCountryPicker,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 16),
                        decoration: BoxDecoration(
                          border: Border(
                            right: BorderSide(color: kBorderColor),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              _countryCode,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: kTextColor,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.keyboard_arrow_down,
                                size: 20, color: kSubTextColor),
                          ],
                        ),
                      ),
                    ),
                    // Phone field
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(10),
                        ],
                        decoration: const InputDecoration(
                          hintText: '07 XX XX XX XX',
                          border: InputBorder.none,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                        style: const TextStyle(fontSize: 15, color: kTextColor),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Hint
              Row(
                children: [
                  const Icon(Icons.info_outline,
                      size: 14, color: kSubTextColor),
                  const SizedBox(width: 6),
                  Text(
                    'You will receive an SMS verification code',
                    style: TextStyle(
                        fontSize: 12, color: kSubTextColor.withOpacity(0.8)),
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Continue button
              ElevatedButton(
                onPressed: _isLoading ? null : _handleContinue,
                child: _isLoading
                    ? const SizedBox(
                        height: 22,
                        width:  22,
                        child:  CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Continue'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
