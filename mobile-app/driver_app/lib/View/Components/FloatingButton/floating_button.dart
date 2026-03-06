import 'package:flutter/material.dart';
import 'package:driver_app/View/Themes/app_theme.dart' as theme;

enum FloatingButtonType {
  flag,
  target,
  profile,
}

class FloatingButton extends StatelessWidget {
  final FloatingButtonType type;
  final VoidCallback? onPressed;
  final bool isActive;

  const FloatingButton({
    Key? key,
    required this.type,
    this.onPressed,
    this.isActive = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isActive ? onPressed : null,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isActive ? Colors.white : Colors.grey.withOpacity(0.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          _getIcon(),
          color: isActive ? theme.AppColors.primary : Colors.grey,
          size: 24,
        ),
      ),
    );
  }

  IconData _getIcon() {
    switch (type) {
      case FloatingButtonType.flag:
        return Icons.flag;
      case FloatingButtonType.target:
        return Icons.gps_fixed;
      case FloatingButtonType.profile:
        return Icons.person;
      default:
        return Icons.location_on;
    }
  }

  IconData _getIconForType() {
    switch (type) {
      case FloatingButtonType.flag:
        return Icons.flag;
      case FloatingButtonType.target:
        return Icons.my_location;
      case FloatingButtonType.profile:
        return Icons.person;
    }
  }
}
