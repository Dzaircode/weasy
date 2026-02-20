import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:driver_app/View/Themes/app_theme.dart' as theme;
import 'package:driver_app/View/Components/primary_button.dart';
import 'package:driver_app/View/Screens/Auth_Screens/phone_login/otp_confermation.dart';

class PhoneLoginScreen extends StatefulWidget {
  const PhoneLoginScreen({Key? key}) : super(key: key);

  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  String _selectedCountryCode = '+213';
  
  final List<Map<String, String>> _countries = [
    {'code': '+213', 'flag': '🇩🇿', 'name': 'Algeria'},
    {'code': '+212', 'flag': '🇲🇦', 'name': 'Morocco'},
    {'code': '+216', 'flag': '🇹🇳', 'name': 'Tunisia'},
  ];

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select Country',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ..._countries.map((country) {
              return ListTile(
                leading: Text(
                  country['flag']!,
                  style: TextStyle(fontSize: 28),
                ),
                title: Text(country['name']!),
                trailing: Text(
                  country['code']!,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: theme.AppColors.black,
                  ),
                ),
                onTap: () {
                  setState(() {
                    _selectedCountryCode = country['code']!;
                  });
                  Navigator.pop(context);
                },
              );
            }).toList(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _handleContinue() {
    final phone = _phoneController.text.trim();
    
    if (phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter your phone number'),
          backgroundColor: theme.AppColors.primary,
        ),
      );
      return;
    }

    if (phone.length < 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid phone number'),
          backgroundColor: theme.AppColors.primary,
        ),
      );
      return;
    }

    // Navigate to OTP screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OTPVerificationScreen(
          phoneNumber: '$_selectedCountryCode $phone',
        ),
      ),
    );
  }

  void _handleSocialLogin(String provider) {
    // Implement social login
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$provider login coming soon'),
        backgroundColor: theme.AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: theme.AppColors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Red Header with Logo
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 60, horizontal: 40),
                decoration: BoxDecoration(
                  color: theme.AppColors.primary,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    // Decorative lines
                    CustomPaint(
                      size: Size(double.infinity, 100),
                      painter: DecorativeLinesPainter(),
                    ),
                    SizedBox(height: 20),
                    
                    // Logo
                    Image.asset(
                      'images/logo.png',
                      width: 200,
                      height: 80,
                    ),
                    SizedBox(height: 16),
                    
                    // Tagline
                    Text(
                      'Move smart | Drive smart',
                      style: TextStyle(
                        color: theme.AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Form Content
              Padding(
                padding: EdgeInsets.all(30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Please Enter your phone number to continue',
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.AppColors.black,
                        height: 1.5,
                      ),
                    ),
                    SizedBox(height: 20),
                    
                    // Phone Input
                    Container(
                      decoration: BoxDecoration(
                        color: theme.AppColors.white,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(
                          color: theme.AppColors.primary,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          // Country Code Selector
                          InkWell(
                            onTap: _showCountryPicker,
                            borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(50),
                            ),
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 18,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _countries.firstWhere(
                                      (c) => c['code'] == _selectedCountryCode,
                                    )['flag']!,
                                    style: TextStyle(fontSize: 24),
                                  ),
                                  SizedBox(width: 8),
                                  Icon(
                                    Icons.arrow_drop_down,
                                    color: theme.AppColors.black,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          
                          Container(
                            width: 1,
                            height: 30,
                            color: Colors.grey[300],
                          ),
                          
                          // Phone Number Input
                          Expanded(
                            child: TextField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(10),
                              ],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                              decoration: InputDecoration(
                                hintText: '($_selectedCountryCode) XX XX XX XX XX',
                                hintStyle: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 16,
                                ),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 18,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 40),
                    
                    // Continue Button
                    PrimaryButton(
                      text: 'Continue',
                      onPressed: _handleContinue,
                      width: double.infinity,
                    ),
                    SizedBox(height: 32),
                    
                    // Social Login
                    Center(
                      child: Text(
                        'Did register with this?',
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.AppColors.black,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    
                    // Social Icons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _SocialLoginButton(
                          icon: Icons.apple,
                          onTap: () => _handleSocialLogin('Apple'),
                          backgroundColor: theme.AppColors.black,
                        ),
                        SizedBox(width: 16),
                        _SocialLoginButton(
                          icon: Icons.facebook,
                          onTap: () => _handleSocialLogin('Facebook'),
                          backgroundColor: Color(0xFF1877F2),
                        ),
                        SizedBox(width: 16),
                        _SocialLoginButton(
                          onTap: () => _handleSocialLogin('Google'),
                          backgroundColor: theme.AppColors.white,
                          borderColor: Colors.grey[300],
                          child: Image.network(
                            'https://www.google.com/favicon.ico',
                            width: 24,
                            height: 24,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  final IconData? icon;
  final Widget? child;
  final VoidCallback onTap;
  final Color backgroundColor;
  final Color? borderColor;

  _SocialLoginButton({
    this.icon,
    this.child,
    required this.onTap,
    required this.backgroundColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(50),
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
          border: borderColor != null
              ? Border.all(color: borderColor!, width: 1)
              : null,
        ),
        child: child ?? Icon(
          icon,
          color: theme.AppColors.white,
          size: 28,
        ),
      ),
    );
  }
}

class DecorativeLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = theme.AppColors.white.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw decorative dashed lines
    final dashWidth = 5.0;
    final dashSpace = 5.0;
    
    // Top left lines
    _drawDashedLine(
      canvas,
      paint,
      const Offset(20, 10),
      const Offset(80, 10),
      dashWidth,
      dashSpace,
    );
    _drawDashedLine(
      canvas,
      paint,
      const Offset(10, 30),
      const Offset(60, 30),
      dashWidth,
      dashSpace,
    );
    
    // Top right lines
    _drawDashedLine(
      canvas,
      paint,
      Offset(size.width - 80, 10),
      Offset(size.width - 20, 10),
      dashWidth,
      dashSpace,
    );
    _drawDashedLine(
      canvas,
      paint,
      Offset(size.width - 60, 30),
      Offset(size.width - 10, 30),
      dashWidth,
      dashSpace,
    );
  }

  void _drawDashedLine(
    Canvas canvas,
    Paint paint,
    Offset start,
    Offset end,
    double dashWidth,
    double dashSpace,
  ) {
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final distance = (dx * dx + dy * dy);
    final steps = distance / (dashWidth + dashSpace);

    for (int i = 0; i < steps; i++) {
      final x1 = start.dx + (dx / steps) * i;
      final y1 = start.dy + (dy / steps) * i;
      final x2 = x1 + (dx / steps) * (dashWidth / (dashWidth + dashSpace));
      final y2 = y1 + (dy / steps) * (dashWidth / (dashWidth + dashSpace));
      
      canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}