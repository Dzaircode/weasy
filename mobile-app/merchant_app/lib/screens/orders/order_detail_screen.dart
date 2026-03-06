import 'package:flutter/material.dart';
import '../../constants.dart';

class OrderDetailScreen extends StatefulWidget {
  static const routeName = '/order-detail';
  const OrderDetailScreen({super.key});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool _isLoading = false;
  late Map<String, dynamic> _order;
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_loaded) {
      _order  = Map<String, dynamic>.from(
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>);
      _loaded = true;
    }
  }

  Future<void> _updateStatus(String newStatus) async {
    setState(() => _isLoading = true);
    // TODO: call ApiService.patch('/orders/${_order['id']}/status', {'status': newStatus})
    await Future.delayed(const Duration(milliseconds: 800));
    setState(() {
      _order['status'] = newStatus;
      _isLoading       = false;
    });

    final messages = {
      'ACCEPTED':  'Order accepted!',
      'READY':     'Order marked as ready for pickup!',
      'REJECTED':  'Order rejected.',
    };

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:         Text(messages[newStatus] ?? 'Status updated'),
        backgroundColor: newStatus == 'REJECTED' ? kErrorColor : kSuccessColor,
        behavior:        SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );

    if (newStatus == 'REJECTED') {
      Navigator.pop(context);
    }
  }

  String get _status => _order['status'] as String;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: Text(_order['id'] as String),
        actions: [
          if (_status == 'PENDING')
            TextButton(
              onPressed:
                  _isLoading ? null : () => _updateStatus('REJECTED'),
              child: const Text('Reject',
                  style: TextStyle(color: kErrorColor, fontWeight: FontWeight.w600)),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(kDefaultPadding),
              children: [
                // Status banner
                _StatusBanner(status: _status),
                const SizedBox(height: 20),

                // Customer info
                _InfoCard(
                  title:    'Customer',
                  icon:     Icons.person_outline_rounded,
                  children: [
                    _InfoRow(label: 'Name',    value: _order['customer'] as String),
                    _InfoRow(label: 'Address', value: _order['address']  as String),
                  ],
                ),
                const SizedBox(height: 14),

                // Items
                _InfoCard(
                  title: 'Order Items',
                  icon:  Icons.receipt_long_outlined,
                  children: [
                    ...(_order['items'] as List).map((item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Container(
                                width:  6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: kPrimaryColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                item as String,
                                style: const TextStyle(
                                    fontSize: 14, color: kTextColor),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
                const SizedBox(height: 14),

                // Total
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:        kPrimaryColor.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(14),
                    border:       Border.all(
                        color: kPrimaryColor.withOpacity(0.2)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize:   16,
                          fontWeight: FontWeight.w600,
                          color:      kTextColor,
                        ),
                      ),
                      Text(
                        '${_order['total']} DA',
                        style: const TextStyle(
                          fontSize:   20,
                          fontWeight: FontWeight.w800,
                          color:      kPrimaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Payment method (always cash for now)
                _InfoCard(
                  title: 'Payment',
                  icon:  Icons.payments_outlined,
                  children: [
                    _InfoRow(label: 'Method', value: 'Cash on delivery'),
                  ],
                ),
              ],
            ),
          ),

          // Action button
          Padding(
            padding: const EdgeInsets.all(kDefaultPadding),
            child: _buildActionButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    if (_isLoading) {
      return ElevatedButton(
        onPressed: null,
        child: const SizedBox(
          height: 22,
          width:  22,
          child:  CircularProgressIndicator(
              strokeWidth: 2, color: Colors.white),
        ),
      );
    }

    switch (_status) {
      case 'PENDING':
        return ElevatedButton.icon(
          onPressed: () => _updateStatus('ACCEPTED'),
          icon:  const Icon(Icons.check_circle_outline_rounded),
          label: const Text('Accept Order'),
          style: ElevatedButton.styleFrom(backgroundColor: kSuccessColor),
        );
      case 'ACCEPTED':
        return ElevatedButton.icon(
          onPressed: () => _updateStatus('READY'),
          icon:  const Icon(Icons.done_all_rounded),
          label: const Text('Mark as Ready'),
          style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
        );
      case 'READY':
        return Container(
          width:   double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color:        kSuccessColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
            border:       Border.all(color: kSuccessColor.withOpacity(0.3)),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.delivery_dining_rounded, color: kSuccessColor),
              SizedBox(width: 8),
              Text(
                'Waiting for driver pickup',
                style: TextStyle(
                  color:      kSuccessColor,
                  fontWeight: FontWeight.w600,
                  fontSize:   15,
                ),
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

// ── Status Banner ─────────────────────────────────────────
class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.status});
  final String status;

  Color get _color {
    switch (status) {
      case 'PENDING':  return const Color(0xFFF59E0B);
      case 'ACCEPTED': return kPrimaryColor;
      case 'READY':    return kSuccessColor;
      default:         return kSubTextColor;
    }
  }

  IconData get _icon {
    switch (status) {
      case 'PENDING':  return Icons.access_time_rounded;
      case 'ACCEPTED': return Icons.restaurant_rounded;
      case 'READY':    return Icons.done_all_rounded;
      default:         return Icons.check_circle_outline;
    }
  }

  String get _label {
    switch (status) {
      case 'PENDING':   return 'New Order — Awaiting your response';
      case 'ACCEPTED':  return 'Accepted — Prepare the order';
      case 'READY':     return 'Ready — Waiting for driver';
      case 'DELIVERED': return 'Delivered ✓';
      default:          return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        _color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: _color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(_icon, color: _color, size: 26),
          const SizedBox(width: 12),
          Text(
            _label,
            style: TextStyle(
              fontSize:   14,
              fontWeight: FontWeight.w600,
              color:      _color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Info Card ─────────────────────────────────────────────
class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String       title;
  final IconData     icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: kBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: kPrimaryColor, size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize:   15,
                  color:      kTextColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: kSubTextColor),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize:   13,
                fontWeight: FontWeight.w600,
                color:      kTextColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}