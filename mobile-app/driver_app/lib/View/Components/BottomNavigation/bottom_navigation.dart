import 'package:flutter/material.dart';
import 'package:driver_app/View/Themes/app_theme.dart' as theme;

enum NavigationTab {
  rides,
  earnings,
  balance,
  more,
}

class BottomNavigation extends StatefulWidget {
  final NavigationTab currentTab;
  final Function(NavigationTab) onTabChanged;

  const BottomNavigation({
    Key? key,
    required this.currentTab,
    required this.onTabChanged,
  }) : super(key: key);

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTabTap(NavigationTab tab) {
    if (widget.currentTab != tab) {
      _animationController.forward().then((_) {
        _animationController.reset();
      });
      widget.onTabChanged(tab);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Expanded(
            child: _buildTabItem(NavigationTab.rides, Icons.directions_car, 'Rides'),
          ),
          Expanded(
            child: _buildTabItem(NavigationTab.earnings, Icons.attach_money, 'Earnings'),
          ),
          Expanded(
            child: _buildTabItem(NavigationTab.balance, Icons.account_balance_wallet, 'Balance'),
          ),
          Expanded(
            child: _buildTabItem(NavigationTab.more, Icons.more_horiz, 'More'),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(NavigationTab tab, IconData icon, String label) {
    final bool isActive = widget.currentTab == tab;
    
    return GestureDetector(
      onTap: () => _handleTabTap(tab),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(
          horizontal: isActive ? 12 : 8,
          vertical: isActive ? 8 : 6,
        ),
        decoration: BoxDecoration(
          color: isActive ? theme.AppColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : Colors.black,
              size: isActive ? 20 : 18,
            ),
            const SizedBox(height: 2),
            Text(
              label.toUpperCase(),
              style: TextStyle(
                color: isActive ? Colors.white : Colors.black,
                fontSize: isActive ? 12 : 10,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
