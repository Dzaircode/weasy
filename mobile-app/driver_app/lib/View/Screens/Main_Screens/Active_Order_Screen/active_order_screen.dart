import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import 'dart:math';
import 'package:geolocator/geolocator.dart';

import 'package:driver_app/View/Components/LocationMarker/location_marker.dart';
import 'package:driver_app/View/Components/MapContainer/stadia_map_container.dart';
import 'package:driver_app/View/Components/TopStatusBar/top_status_bar.dart';
import 'package:driver_app/View/Components/BottomNavigation/bottom_navigation.dart';
import 'package:driver_app/View/Screens/Main_Screens/Active_Order_Screen/cancel_order_sheet.dart';

class ActiveOrderScreen extends StatefulWidget {
  final LocationMarker order;
  final LatLng destination;
  final LatLng origin;

  const ActiveOrderScreen({
    Key? key,
    required this.order,
    required this.destination,
    required this.origin,
  }) : super(key: key);

  @override
  State<ActiveOrderScreen> createState() => _ActiveOrderScreenState();
}

class _ActiveOrderScreenState extends State<ActiveOrderScreen> {
  static const Color _red = Color(0xFFE8000E);

  final StadiaMapController _mapCtrl = StadiaMapController();

  LatLng _driverPos = const LatLng(0, 0);
  StreamSubscription<Position>? _posStream;
  double _distanceMeters = 0;
  int _etaMinutes = 0;

  late List<LatLng> _routePoints;
  bool _delivered = false;

  // Progress along route (0.0 → 1.0), simulated while no real GPS movement
  double _progress = 0.0;
  Timer? _simTimer;

  @override
  void initState() {
    super.initState();
    _driverPos  = widget.origin;
    _routePoints = _buildRoute(widget.origin, widget.destination);
    _calcEta(widget.origin);

    WidgetsBinding.instance.addPostFrameCallback((_) => _fitBounds());
    _startTracking();
  }

  @override
  void dispose() {
    _posStream?.cancel();
    _simTimer?.cancel();
    super.dispose();
  }

  // ── Route ─────────────────────────────────────────────────────────────────

  List<LatLng> _buildRoute(LatLng from, LatLng to) {
    final rng = Random(77);
    const steps = 7;
    final pts = <LatLng>[from];
    for (int i = 1; i < steps; i++) {
      final t = i / steps;
      pts.add(LatLng(
        from.latitude  + (to.latitude  - from.latitude)  * t + (rng.nextDouble() - 0.5) * 0.002,
        from.longitude + (to.longitude - from.longitude) * t + (rng.nextDouble() - 0.5) * 0.002,
      ));
    }
    pts.add(to);
    return pts;
  }

  // ── Distance / ETA ────────────────────────────────────────────────────────

  void _calcEta(LatLng from) {
    // latlong2 Distance class
    final dist = const Distance().as(LengthUnit.Meter, from, widget.destination);
    setState(() {
      _distanceMeters = dist;
      _etaMinutes = max(1, (dist / 500).round()); // 30 km/h ≈ 500 m/min
    });
  }

  // ── GPS tracking ──────────────────────────────────────────────────────────

  void _startTracking() async {
    bool ok = await Geolocator.isLocationServiceEnabled();
    if (!ok) { _startSimulation(); return; }

    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.denied ||
        perm == LocationPermission.deniedForever) {
      _startSimulation();
      return;
    }

    _posStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((pos) {
      if (!mounted) return;
      final newPos = LatLng(pos.latitude, pos.longitude);
      setState(() {
        _driverPos   = newPos;
        _routePoints = [newPos, ..._routePoints.skip(1)];
      });
      _calcEta(newPos);
      _updateProgress();
    });
  }

  /// Fallback: simulate movement along the route every 2 seconds.
  void _startSimulation() {
    _simTimer = Timer.periodic(const Duration(seconds: 2), (_) {
      if (!mounted || _delivered) return;
      setState(() {
        _progress = (_progress + 0.04).clamp(0.0, 0.95);
        // Interpolate driver position along route
        final totalPts = _routePoints.length;
        final idx = (_progress * (totalPts - 1)).floor();
        final next = (idx + 1).clamp(0, totalPts - 1);
        final t = (_progress * (totalPts - 1)) - idx;
        _driverPos = LatLng(
          _routePoints[idx].latitude  + (_routePoints[next].latitude  - _routePoints[idx].latitude)  * t,
          _routePoints[idx].longitude + (_routePoints[next].longitude - _routePoints[idx].longitude) * t,
        );
        // Trim route from behind
        _routePoints = [_driverPos, ..._routePoints.skip(idx + 1)];
      });
      _calcEta(_driverPos);
    });
  }

  void _updateProgress() {
    final total = const Distance().as(
        LengthUnit.Meter, widget.origin, widget.destination);
    final done  = const Distance().as(
        LengthUnit.Meter, widget.origin, _driverPos);
    setState(() => _progress = (done / total).clamp(0.0, 1.0));
  }

  // ── Camera ────────────────────────────────────────────────────────────────

  void _fitBounds() {
    _mapCtrl.animateTo(
      LatLng(
        (widget.origin.latitude  + widget.destination.latitude)  / 2,
        (widget.origin.longitude + widget.destination.longitude) / 2,
      ),
      zoom: 14.8,
      verticalFraction: 0.40,
    );
  }

  // ── Cancel ────────────────────────────────────────────────────────────────

  void _onCancel() {
    showCancelOrderSheet(
      context,
      onConfirm: (reasonId, note) {
        debugPrint('Cancelled: $reasonId | note: $note');
        if (mounted) Navigator.of(context).pop();
      },
    );
  }

  // ── Delivered ─────────────────────────────────────────────────────────────

  void _onDelivered() {
    setState(() => _delivered = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) Navigator.of(context).pop();
    });
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final String distLabel = _distanceMeters >= 1000
        ? '${(_distanceMeters / 1000).toStringAsFixed(1)} km'
        : '${_distanceMeters.round()} m';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [

          // ── Map ───────────────────────────────────────────────
          Positioned.fill(
            child: StadiaMapContainer(
              markers: const [],
              isOnline: true,
              controller: _mapCtrl,
              activeOrderDestination: widget.destination,
              routePoints: _routePoints,
            ),
          ),

          // ── Top bar ───────────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: TopStatusBar(
              isOnline: true,
              earnings: '0 DA',
              onToggleStatus: () {},
              onActionPressed: () {},
            ),
          ),

          // ── Distance / ETA pill ───────────────────────────────
          Positioned(
            left: 12, right: 12,
            bottom: 80 + 130 + 8,
            child: _DistancePill(
              distLabel: distLabel,
              etaMinutes: _etaMinutes,
              progress: _progress,
            ),
          ),

          // ── Order info bar ────────────────────────────────────
          Positioned(
            left: 0, right: 0, bottom: 80,
            child: _OrderInfoBar(
              order: widget.order,
              delivered: _delivered,
              onDelivered: _onDelivered,
              onCancel: _onCancel,
            ),
          ),

          // ── Bottom nav ────────────────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: BottomNavigation(
              currentTab: NavigationTab.rides,
              onTabChanged: (_) {},
            ),
          ),

          // ── Delivered overlay ─────────────────────────────────
          if (_delivered)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.6),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.elasticOut,
                        builder: (_, v, child) =>
                            Transform.scale(scale: v, child: child),
                        child: Container(
                          width: 88, height: 88,
                          decoration: const BoxDecoration(
                              color: _red, shape: BoxShape.circle),
                          child: const Icon(Icons.check,
                              color: Colors.white, size: 48),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Commande livrée !',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Distance + ETA pill
// ─────────────────────────────────────────────────────────────────────────────
class _DistancePill extends StatelessWidget {
  final String distLabel;
  final int etaMinutes;
  final double progress; // 0.0 → 1.0

  const _DistancePill({
    required this.distLabel,
    required this.etaMinutes,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(distLabel,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87)),
              Container(
                width: 5, height: 5,
                margin: const EdgeInsets.symmetric(horizontal: 10),
                decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFE8000E)),
              ),
              Text('$etaMinutes min',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87)),
            ],
          ),
          const SizedBox(height: 10),
          // Progress bar
          LayoutBuilder(builder: (_, bc) {
            final filled = (bc.maxWidth * progress).clamp(0.0, bc.maxWidth);
            return Stack(
              clipBehavior: Clip.none,
              children: [
                // Track
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                // Fill
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  width: filled,
                  height: 6,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF6B6B), Color(0xFFE8000E)],
                    ),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                // Navigation arrow at tip
                Positioned(
                  left: (filled - 8).clamp(0.0, bc.maxWidth - 16),
                  top: -5,
                  child: const Icon(Icons.navigation,
                      color: Color(0xFFE8000E), size: 16),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Order info bar
// ─────────────────────────────────────────────────────────────────────────────
class _OrderInfoBar extends StatelessWidget {
  final LocationMarker order;
  final bool delivered;
  final VoidCallback onDelivered;
  final VoidCallback onCancel;

  const _OrderInfoBar({
    required this.order,
    required this.delivered,
    required this.onDelivered,
    required this.onCancel,
  });

  static const Color _red = Color(0xFFE8000E);
  String get _orderId =>
      '#${(order.hashCode.abs() % 90000000 + 10000000)}';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
              color: Colors.black12,
              blurRadius: 16,
              offset: Offset(0, -4))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 44, height: 44,
                decoration: BoxDecoration(
                    color: _red,
                    borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.restaurant,
                    color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.restaurantName ?? 'Restaurant',
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Order id  $_orderId',
                        style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
              _CircleAction(
                icon: Icons.phone,
                color: _red,
                onTap: () {},
              ),
              const SizedBox(width: 8),
              _CircleAction(
                icon: Icons.chat_bubble_outline,
                color: Colors.black87,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              // Cancel button
              GestureDetector(
                onTap: delivered ? null : onCancel,
                child: Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.close,
                      color: delivered
                          ? Colors.grey.shade300
                          : Colors.black54,
                      size: 22),
                ),
              ),
              const SizedBox(width: 10),
              // Delivered CTA
              Expanded(
                child: ElevatedButton(
                  onPressed: delivered ? null : onDelivered,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _red,
                    disabledBackgroundColor: Colors.grey.shade300,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    padding:
                        const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    delivered ? 'Livré ✓' : 'Order delivered',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CircleAction extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _CircleAction(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
      );
}