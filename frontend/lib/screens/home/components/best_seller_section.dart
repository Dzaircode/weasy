import 'package:flutter/material.dart';

import '../../../constants.dart';
import '../../cart/cart_screen.dart';

/// "Best Seller" title + "See all" link + horizontal filter chips + product card(s).
class BestSellerSection extends StatefulWidget {
  const BestSellerSection({Key? key}) : super(key: key);

  @override
  State<BestSellerSection> createState() => _BestSellerSectionState();
}

class _BestSellerSectionState extends State<BestSellerSection> {
  int _selectedFilterIndex = 0;
  static const List<Map<String, dynamic>> _filters = [
    {"label": "All", "icon": Icons.local_fire_department},
    {"label": "Fastfood", "icon": Icons.fastfood},
    {"label": "Restaurant", "icon": Icons.restaurant},
    {"label": "Desserts", "icon": Icons.icecream},
    {"label": "Drinks", "icon": Icons.local_cafe},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row: "Best Seller" + "See all >"
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Best Seller",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: kTextColor,
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: kSecondaryColor,
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text("See all >"),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Horizontal filter chips - matching exact design
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final isSelected = index == _selectedFilterIndex;
                final filter = _filters[index];
                return GestureDetector(
                  onTap: () => setState(() => _selectedFilterIndex = index),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? kPrimaryColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: kPrimaryColor,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          filter["label"],
                          style: TextStyle(
                            color: isSelected ? Colors.white : kPrimaryColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Icon(
                          filter["icon"],
                          size: 18,
                          color: isSelected ? Colors.white : kPrimaryColor,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          // Product cards matching exact design from image
          _BestSellerCard(
            imagePath: "images/restaurant/houseofburger.png",
            title: "House Burgers",
            restaurantLogo: "images/restaurant/logo.png",
            deliveryTime: "15min - 30min",
            onTap: () => Navigator.pushNamed(context, CartScreen.routeName),
          ),
          const SizedBox(height: 12),
          _BestSellerCard(
            imagePath: "images/restaurant/houseofburger.png",
            title: "House Burgers",
            restaurantLogo: "images/restaurant/logo.png",
            deliveryTime: "15min - 30min",
            onTap: () => Navigator.pushNamed(context, CartScreen.routeName),
          ),
          const SizedBox(height: 12),
          _BestSellerCard(
            imagePath: "images/restaurant/houseofburger.png",
            title: "House Burgers",
            restaurantLogo: "images/restaurant/logo.png",
            deliveryTime: "15min - 30min",
            onTap: () => Navigator.pushNamed(context, CartScreen.routeName),
          ),
        ],
      ),
    );
  }
}

class _BestSellerCard extends StatelessWidget {
  const _BestSellerCard({
    required this.imagePath,
    required this.title,
    required this.restaurantLogo,
    required this.deliveryTime,
    required this.onTap,
  });

  final String imagePath;
  final String title;
  final String restaurantLogo;
  final String deliveryTime;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Main image
              Image.asset(imagePath, fit: BoxFit.cover),

              // Heart icon - top-right
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.95),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.favorite,
                    size: 20,
                    color: kPrimaryColor,
                  ),
                ),
              ),

              // Bottom overlay with gradient
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.7),
                      ],
                    ),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Restaurant logo in circle
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            restaurantLogo,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback if logo doesn't exist
                              return Container(
                                color: kPrimaryColor,
                                child: const Icon(
                                  Icons.restaurant,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      // Star icon and delivery time
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.6),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              deliveryTime,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
