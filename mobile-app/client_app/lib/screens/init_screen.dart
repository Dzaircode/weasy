import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants.dart';
import 'cart/cart_screen.dart';
import 'favorite/favorite_screen.dart';
import 'home/home_screen.dart';
import 'profile/profile_screen.dart';

/// White icon color on red bar. Figma: Home, Gift, Cart (badge), Heart, Person.
const Color _navIconColor = Colors.white;

class InitScreen extends StatefulWidget {
  const InitScreen({super.key});

  static String routeName = "/";

  @override
  State<InitScreen> createState() => _InitScreenState();
}

class _InitScreenState extends State<InitScreen> {
  int currentSelectedIndex = 0;

  final pages = [
    const HomeScreen(),
    const Center(child: Text("Gift")),
    const CartScreen(),
    const FavoriteScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentSelectedIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: kPrimaryColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: BottomNavigationBar(
          onTap: (index) => setState(() => currentSelectedIndex = index),
          currentIndex: currentSelectedIndex,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: _navIconColor,
          unselectedItemColor: _navIconColor.withValues(alpha: 0.8),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded, size: 26),
              label: "Home",
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.card_giftcard_rounded, size: 26),
              label: "Gift",
            ),
            BottomNavigationBarItem(
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.shopping_bag_rounded, size: 26),
                  Positioned(
                    top: -4,
                    right: -6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Text(
                        "2",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryColor,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              label: "Cart",
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border_rounded, size: 26),
              label: "Fav",
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded, size: 26),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}
