import 'package:flutter/material.dart';
import 'package:driver_app/View/Themes/app_theme.dart' as theme;
import 'package:driver_app/View/Components/TopStatusBar/top_status_bar.dart';
import 'package:driver_app/View/Components/BottomNavigation/bottom_navigation.dart';

class BalanceScreen extends StatefulWidget {
  const BalanceScreen({Key? key}) : super(key: key);

  @override
  State<BalanceScreen> createState() => _BalanceScreenState();
}

class _BalanceScreenState extends State<BalanceScreen> {
  NavigationTab _currentTab = NavigationTab.balance;
  String _currentBalance = "8,750 DA";
  String _pendingBalance = "1,200 DA";
  String _totalWithdrawn = "15,300 DA";

  void _handleTabChange(NavigationTab tab) {
    setState(() {
      _currentTab = tab;
    });
  }

  void _handleWithdraw() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[800],
        title: Text(
          'Withdraw Funds',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Withdrawal request will be processed within 24 hours.',
          style: TextStyle(color: Colors.grey[300]),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[400]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Withdrawal request submitted'),
                  backgroundColor: theme.AppColors.primary,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.AppColors.primary,
            ),
            child: Text('Confirm'),
          ),
        ],
      ),
    );
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
                    earnings: "0 DA",
                    onToggleStatus: () {
                      // Toggle online status
                    },
                    onActionPressed: () {
                      // Navigate to balance details
                    },
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Main Balance Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [theme.AppColors.primary, Colors.red.shade700],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: theme.AppColors.primary.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Balance',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _currentBalance,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _handleWithdraw,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: theme.AppColors.primary,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: Text(
                            'Withdraw',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Balance Details
                  Row(
                    children: [
                      Expanded(
                        child: _buildBalanceCard(
                          'Pending',
                          _pendingBalance,
                          Icons.pending,
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildBalanceCard(
                          'Total Withdrawn',
                          _totalWithdrawn,
                          Icons.account_balance_wallet_outlined,
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Recent Transactions
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[800],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Recent Transactions',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTransactionItem(
                          'Ride Earnings',
                          '450 DA',
                          'Today, 2:30 PM',
                          true,
                        ),
                        _buildTransactionItem(
                          'Withdrawal',
                          '-2,000 DA',
                          'Yesterday, 5:15 PM',
                          false,
                        ),
                        _buildTransactionItem(
                          'Ride Earnings',
                          '320 DA',
                          'Yesterday, 11:20 AM',
                          true,
                        ),
                        _buildTransactionItem(
                          'Ride Earnings',
                          '580 DA',
                          'Dec 28, 4:45 PM',
                          true,
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

  Widget _buildBalanceCard(String title, String amount, IconData icon, Color color) {
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
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(String title, String amount, String time, bool isCredit) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                time,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          Text(
            amount,
            style: TextStyle(
              color: isCredit ? Colors.green : Colors.red,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
