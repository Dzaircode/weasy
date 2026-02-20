import 'package:flutter/material.dart';

import '../../constants.dart';
import '../sign_in/sign_in_screen.dart';
import 'components/splash_content.dart';

class SplashScreen extends StatefulWidget {
  static String routeName = "/splash";

  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  int currentPage = 0;
  final PageController _pageController = PageController();
  
  // Single background image for ALL screens (stays static)
  final String backgroundImage = "assets/images/splash_bg.png";
  
  List<Map<String, String>> splashData = [
    {
      "title": "Fast Delivery , Every Time",
      "description": "From our hands to your door\nin record time.",
      "image": "assets/images/splash_1.png",
    },
    {
      "title": "Fresh , Safe & Secure",
      "description": "Your items handled with care\nfrom start to finish.",
      "image": "assets/images/splash_2.png",
    },
    {
      "title": "Smart Payment Options",
      "description": "Pay cash , card , or online\nwhatever suits you best.",
      "image": "assets/images/splash_3.png",
    },
    {
      "title": "Track Your Driver Live",
      "description": "Know where your delivery is,\nevery step of the way.",
      "image": "assets/images/splash_4.png",
    },
    {
      "title": "Low Return Rate",
      "description": "Real reviews to help you\nchoose the best",
      "image": "assets/images/splash_5.png",
    },
    {
      "title": "One App , All Your Needs",
      "description": "Food, groceries, parcels\neverything delivered",
      "image": "assets/images/splash_6.png",
    },
  ];

  void _nextPage() {
    if (currentPage < splashData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushNamed(context, SignInScreen.routeName);
    }
  }

  void _previousPage() {
    if (currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // STATIC BACKGROUND - Positioned at the top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                backgroundImage,
                width: double.infinity,
                fit: BoxFit.contain,
                alignment: Alignment.topCenter,
              ),
            ),
            
            // CONTENT LAYER - Only this changes when navigating
            Column(
              children: <Widget>[
                // Content area with foreground images and text
                Expanded(
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(), // Disable swipe
                    onPageChanged: (value) {
                      setState(() {
                        currentPage = value;
                      });
                    },
                    itemCount: splashData.length,
                    itemBuilder: (context, index) => SplashContent(
                      title: splashData[index]['title'],
                      description: splashData[index]['description'],
                      image: splashData[index]["image"],
                      isActive: currentPage == index,
                    ),
                  ),
                ),
                
                // Bottom section with indicators and buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  child: Column(
                    children: <Widget>[
                      // Page indicators
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          splashData.length,
                          (index) => AnimatedContainer(
                            duration: kAnimationDuration,
                            margin: const EdgeInsets.only(right: 8),
                            height: 8,
                            width: currentPage == index ? 40 : 8,
                            decoration: BoxDecoration(
                              color: currentPage == index
                                  ? const Color(0xFFFF4D4D) // Red color for active
                                  : Colors.black,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 30),
                      
                      // Buttons
                      Row(
                        children: [
                          // Back button (only show after first screen)
                          if (currentPage > 0)
                            Expanded(
                              child: SizedBox(
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _previousPage,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.black,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(28),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Text(
                                    "Back",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          
                          // Spacing between buttons
                          if (currentPage > 0) const SizedBox(width: 16),
                          
                          // Next/Start button
                          Expanded(
                            child: SizedBox(
                              height: 56,
                              child: ElevatedButton(
                                onPressed: _nextPage,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFFF4D4D), // Red color
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                  elevation: 0,
                                ),
                                child: Text(
                                  currentPage == splashData.length - 1 ? "Start" : "Next",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}