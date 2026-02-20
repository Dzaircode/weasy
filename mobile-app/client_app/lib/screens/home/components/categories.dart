import 'package:flutter/material.dart';

import '../../../constants.dart';

/// "Services" title + 2x3 grid: Food (red), Fresh, Market, Flight, Package, Credit.
/// Now interactive with smooth animations!
class Categories extends StatefulWidget {
  const Categories({super.key});

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  int _selectedIndex = 0; // Track which service is selected

  static const List<Map<String, dynamic>> _services = [
    {"label": "Food", "image": "images/services/food.png"},
    {"label": "Fresh", "image": "images/services/fresh.png"},
    {"label": "Market", "image": "images/services/market.png"},
    {"label": "Flight", "image": "images/services/flight.png"},
    {"label": "Package", "image": "images/services/package.png"},
    {"label": "Credit", "image": "images/services/credit.png"},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Services",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: kTextColor,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.85,
            ),
            itemCount: _services.length,
            itemBuilder: (context, index) {
              final service = _services[index];
              final isSelected = index == _selectedIndex;

              return _ServiceTile(
                label: service["label"] as String,
                imagePath: service["image"] as String,
                isSelected: isSelected,
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({
    required this.label,
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300), // Smooth transition
        curve: Curves.easeInOut, // Smooth curve
        decoration: BoxDecoration(
          // Active: red background (kPrimaryColor)
          // Inactive: pink background (kPrimaryLightColor)
          color: isSelected ? kPrimaryColor : kPrimaryLightColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: kPrimaryColor.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Active: white circle behind image
            // Inactive: no white circle, image directly shown
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return ScaleTransition(
                  scale: animation,
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
              child: isSelected
                  ? Container(
                      key: const ValueKey('selected'),
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Image.asset(
                          imagePath,
                          width: 36,
                          height: 36,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.image_not_supported,
                              color: kPrimaryColor,
                              size: 36,
                            );
                          },
                        ),
                      ),
                    )
                  : Image.asset(
                      key: const ValueKey('unselected'),
                      imagePath,
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.image_not_supported,
                          color: kPrimaryColor,
                          size: 40,
                        );
                      },
                    ),
            ),
            const SizedBox(height: 8),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                // Active: white text
                // Inactive: red text (kPrimaryColor)
                color: isSelected ? Colors.white : kPrimaryColor,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
