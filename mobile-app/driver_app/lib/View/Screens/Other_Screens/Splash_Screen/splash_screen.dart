import 'package:flutter/material.dart';
import 'package:driver_app/View/Themes/app_theme.dart' as theme;
import 'package:driver_app/View/Components/primary_button.dart';
import 'package:driver_app/View/Screens/Auth_Screens/phone_login/phone_login_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              'images/splash.png',
              fit: BoxFit.cover,
            ),
          ),
          
          // Linear Gradient Overlay (bottom to top with red color)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    theme.AppColors.primary.withValues(alpha: 0.7),
                    theme.AppColors.primary.withValues(alpha: 0.4),
                    theme.AppColors.primary.withValues(alpha: 0.0),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.3, 0.6, 1.0],
                ),
              ),
            ),
          ),
          
          // Content
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 60),
                
                // Logo at top center
                Center(
                  child: Image.asset(
                    'images/logo.png',
                    width: 200,
                    height: 80,
                  ),
                ),
                
                const Spacer(),
                
                // Title Text
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Turn every ride\ninto an\nopportunity.',
                    style: TextStyle(
                      color: theme.AppColors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                
                const SizedBox(height: 40),
                
                // Start Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: PrimaryButton(
                    text: 'Start',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PhoneLoginScreen(),
                        ),
                      );
                    },
                    width: double.infinity,
                  ),
                ),
                const SizedBox(height: 50),
              ],
            ),
          ),
        ],
      ),
    );
  }
}