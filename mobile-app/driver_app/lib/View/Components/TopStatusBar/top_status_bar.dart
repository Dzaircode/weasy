import 'package:flutter/material.dart';
import 'package:driver_app/View/Themes/app_theme.dart' as theme;

class TopStatusBar extends StatefulWidget {
  final bool isOnline;
  final String earnings;
  final VoidCallback? onToggleStatus;
  final VoidCallback? onActionPressed;

  const TopStatusBar({
    Key? key,
    required this.isOnline,
    required this.earnings,
    this.onToggleStatus,
    this.onActionPressed,
  }) : super(key: key);

  @override
  State<TopStatusBar> createState() => _TopStatusBarState();
}

class _TopStatusBarState extends State<TopStatusBar>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleToggle() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
    if (widget.onToggleStatus != null) {
      widget.onToggleStatus!();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Row(
        children: [
          // Online/Offline Toggle
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return GestureDetector(
                onTap: _handleToggle,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.isOnline ? Colors.green : Colors.red,
                      boxShadow: [
                        BoxShadow(
                          color: (widget.isOnline ? Colors.green : Colors.red).withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Icon(
                      widget.isOnline ? Icons.power_settings_new : Icons.power_off_outlined,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              );
            },
          ),
          
          // Earnings Display
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: widget.isOnline ? theme.AppColors.primary : Colors.grey,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Earnings Today',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.earnings,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Action Button
          GestureDetector(
            onTap: widget.onActionPressed,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isOnline ? Colors.red : Colors.grey,
                boxShadow: [
                  BoxShadow(
                    color: (widget.isOnline ? Colors.red : Colors.grey).withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(
                Icons.search,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
