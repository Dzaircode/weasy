import 'package:flutter/material.dart';

import 'components/best_seller_section.dart';
import 'components/categories.dart';
import 'components/discount_banner.dart';
import 'components/home_header.dart';

/// Home screen matching Figma: header (search, location, bell), banner (30% OFF),
/// Services grid, Best Seller (filters + product card).
class HomeScreen extends StatelessWidget {
  static String routeName = "/home";

  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              HomeHeader(),
              DiscountBanner(),
              SizedBox(height: 20),
              Categories(),
              SizedBox(height: 24),
              BestSellerSection(),
            ],
          ),
        ),
      ),
    );
  }
}
