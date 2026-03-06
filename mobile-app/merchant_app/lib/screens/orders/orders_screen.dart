import 'package:flutter/material.dart';
import '../../constants.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  static const routeName = '/orders';
  final bool embedded;
  const OrdersScreen({super.key, this.embedded = false});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<String> _tabs = ['All', 'Pending', 'Active', 'Done'];

  // Demo orders — replace with Socket.IO + API
  final List<Map<String, dynamic>> _orders = [
    {
      'id':       '#1024',
      'customer': 'Youcef Bouali',
      'items':    ['Classic Burger x1', 'Coca Cola x2'],
      'total':    850,
      'status':   'PENDING',
      'time':     '5 min ago',
      'address':  'Rue des Orangers, Oran',
    },
    {
      'id':       '#1023',
      'customer': 'Amina Kaddour',
      'items':    ['Double Smash x1', 'Fries x1'],
      'total':    1200,
      'status':   'ACCEPTED',
      'time':     '12 min ago',
      'address':  'Hay Yasmine, Oran',
    },
    {
      'id':       '#1022',
      'customer': 'Riad Mansouri',
      'items':    ['Margherita x1'],
      'total':    500,
      'status':   'READY',
      'time':     '20 min ago',
      'address':  'Centre Ville, Oran',
    },
    {
      'id':       '#1021',
      'customer': 'Lynda Benali',
      'items':    ['Chocolate Lava x2', 'Juice x1'],
      'total':    680,
      'status':   'DELIVERED',
      'time':     '1 hr ago',
      'address':  'Es Senia, Oran',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _filteredOrders(String tab) {
    if (tab == 'All') return _orders;
    if (tab == 'Pending')  return _orders.where((o) => o['status'] == 'PENDING').toList();
    if (tab == 'Active')   return _orders.where((o) => ['ACCEPTED', 'READY'].contains(o['status'])).toList();
    if (tab == 'Done')     return _orders.where((o) => o['status'] == 'DELIVERED').toList();
    return _orders;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: widget.embedded ? null : AppBar(title: const Text('Orders')),
      body: Column(
        children: [
          if (widget.embedded)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  kDefaultPadding, kDefaultPadding, kDefaultPadding, 0),
              child: Row(
                children: [
                  const Text(
                    'Orders',
                    style: TextStyle(
                      fontSize:   22,
                      fontWeight: FontWeight.w800,
                      color:      kTextColor,
                    ),
                  ),
                  const Spacer(),
                  // Live indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color:        kSuccessColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width:        8,
                          height:       8,
                          decoration:   const BoxDecoration(
                            color:  kSuccessColor,
                            shape:  BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          'Live',
                          style: TextStyle(
                            fontSize:   12,
                            fontWeight: FontWeight.w700,
                            color:      kSuccessColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          TabBar(
            controller:           _tabController,
            indicatorColor:       kPrimaryColor,
            labelColor:           kPrimaryColor,
            unselectedLabelColor: kSubTextColor,
            labelStyle: const TextStyle(fontWeight: FontWeight.w600),
            tabs: _tabs.map((t) => Tab(text: t)).toList(),
          ),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: _tabs.map((tab) {
                final orders = _filteredOrders(tab);
                if (orders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.receipt_long_outlined,
                            size: 48, color: kBorderColor),
                        const SizedBox(height: 12),
                        const Text('No orders here',
                            style: TextStyle(color: kSubTextColor)),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding:      const EdgeInsets.all(kDefaultPadding),
                  itemCount:    orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (_, i) => _OrderCard(
                    order:   orders[i],
                    onTap: () => Navigator.pushNamed(
                      context,
                      OrderDetailScreen.routeName,
                      arguments: orders[i],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Status helpers ─────────────────────────────────────────
Color _statusColor(String status) {
  switch (status) {
    case 'PENDING':   return const Color(0xFFF59E0B);
    case 'ACCEPTED':  return kPrimaryColor;
    case 'READY':     return kSuccessColor;
    case 'DELIVERED': return kSubTextColor;
    default:          return kSubTextColor;
  }
}

String _statusLabel(String status) {
  switch (status) {
    case 'PENDING':   return 'New Order';
    case 'ACCEPTED':  return 'Preparing';
    case 'READY':     return 'Ready';
    case 'DELIVERED': return 'Delivered';
    default:          return status;
  }
}

// ── Order Card ────────────────────────────────────────────
class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.onTap});

  final Map<String, dynamic> order;
  final VoidCallback          onTap;

  @override
  Widget build(BuildContext context) {
    final status  = order['status'] as String;
    final isPending = status == 'PENDING';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:        Colors.white,
          borderRadius: BorderRadius.circular(16),
          border:       isPending
              ? Border.all(color: const Color(0xFFF59E0B), width: 1.5)
              : Border.all(color: kBorderColor),
          boxShadow: isPending
              ? [
                  BoxShadow(
                    color:      const Color(0xFFF59E0B).withOpacity(0.12),
                    blurRadius: 12,
                    offset:     const Offset(0, 2),
                  )
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  order['id'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize:   16,
                    color:      kTextColor,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                    color:        _statusColor(status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _statusLabel(status),
                    style: TextStyle(
                      fontSize:   11,
                      fontWeight: FontWeight.w700,
                      color:      _statusColor(status),
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  order['time'] as String,
                  style: const TextStyle(
                      fontSize: 12, color: kSubTextColor),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Text(
              order['customer'] as String,
              style: const TextStyle(
                  fontSize: 14, color: kSubTextColor, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 6),

            Text(
              (order['items'] as List).join(' · '),
              style: const TextStyle(fontSize: 13, color: kSubTextColor),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                const Icon(Icons.payments_outlined,
                    size: 16, color: kPrimaryColor),
                const SizedBox(width: 4),
                Text(
                  '${order['total']} DA',
                  style: const TextStyle(
                    fontSize:   15,
                    fontWeight: FontWeight.w700,
                    color:      kPrimaryColor,
                  ),
                ),
                const Spacer(),
                if (isPending)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color:        kPrimaryColor,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'View & Accept',
                      style: TextStyle(
                        color:      Colors.white,
                        fontSize:   12,
                        fontWeight: FontWeight.w600,
                      ),
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