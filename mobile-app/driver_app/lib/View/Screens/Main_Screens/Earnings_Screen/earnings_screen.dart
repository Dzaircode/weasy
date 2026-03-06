import 'package:flutter/material.dart';
import 'package:driver_app/View/Themes/app_theme.dart' as theme;
import 'package:driver_app/View/Components/TopStatusBar/top_status_bar.dart';
import 'package:driver_app/View/Components/BottomNavigation/bottom_navigation.dart';

class EarningsScreen extends StatefulWidget {
  const EarningsScreen({Key? key}) : super(key: key);

  @override
  State<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends State<EarningsScreen> {
  NavigationTab _currentTab = NavigationTab.earnings;
  String _totalEarnings = "12,450 DA";
  String _todayEarnings = "450 DA";
  String _weekEarnings = "3,200 DA";
  String _monthEarnings = "8,900 DA";

  void _handleTabChange(NavigationTab tab) {
    setState(() {
      _currentTab = tab;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Stack(
        children: [
          // Main Content
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            bottom: 80, // Space for bottom navigation
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Status Bar
                  TopStatusBar(
                    isOnline: true,
                    earnings: _todayEarnings,
                    onToggleStatus: () {
                      // Toggle online status
                    },
                    onActionPressed: () {
                      // Navigate to earnings details
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Earnings Overview Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildEarningsCard(
                          'Today',
                          _todayEarnings,
                          Icons.today,
                          theme.AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildEarningsCard(
                          'This Week',
                          _weekEarnings,
                          Icons.date_range,
                          Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  Row(
                    children: [
                      Expanded(
                        child: _buildEarningsCard(
                          'This Month',
                          _monthEarnings,
                          Icons.calendar_month,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildEarningsCard(
                          'Total',
                          _totalEarnings,
                          Icons.account_balance,
                          Colors.purple,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Earnings Chart Placeholder
                  Container(
                    height: 200,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Earnings Trend',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Simple chart placeholder
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[700],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.insert_chart,
                                color: Colors.grey[400],
                                size: 48,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom Navigation
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: BottomNavigation(
              currentTab: _currentTab,
              onTabChanged: _handleTabChange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsCard(String title, String amount, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
