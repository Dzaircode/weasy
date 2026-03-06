import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_cancellable_tile_provider/flutter_map_cancellable_tile_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:driver_app/View/Components/LocationMarker/location_marker.dart';
import 'dart:math';
import 'dart:ui' as ui;

const String _kStadiaApiKey = '787afba2-231c-48c7-98b0-9518f400240e';

// ─────────────────────────────────────────────────────────────────────────────
// Controller
// ─────────────────────────────────────────────────────────────────────────────
class StadiaMapController {
  _StadiaMapContainerState? _state;

  void _attach(_StadiaMapContainerState s) => _state = s;
  void _detach() => _state = null;

  void animateTo(LatLng target,
          {double zoom = 15.5, double verticalFraction = 0.35}) =>
      _state?._animateTo(target, zoom: zoom, verticalFraction: verticalFraction);

  void resetView() => _state?._resetView();

  /// Returns the exact LatLng the marker is placed at on the map.
  /// This now uses marker.latitude / marker.longitude directly.
  LatLng? positionOf(LocationMarker marker) =>
      LatLng(marker.latitude, marker.longitude);

  LatLng? get userCenter => _state?._userCenter;
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget
// ─────────────────────────────────────────────────────────────────────────────
class StadiaMapContainer extends StatefulWidget {
  final List<LocationMarker> markers;
  final Function(double lat, double lng)? onMapTap;
  final Function(LocationMarker)? onMarkerTap;
  final bool isOnline;
  final LocationMarker? selectedMarker;
  final StadiaMapController? controller;
  final LatLng? activeOrderDestination;
  final List<LatLng>? routePoints;

  const StadiaMapContainer({
    Key? key,
    required this.markers,
    this.onMapTap,
    this.onMarkerTap,
    this.isOnline = true,
    this.selectedMarker,
    this.controller,
    this.activeOrderDestination,
    this.routePoints,
  }) : super(key: key);

  @override
  State<StadiaMapContainer> createState() => _StadiaMapContainerState();
}

class _StadiaMapContainerState extends State<StadiaMapContainer>
    with TickerProviderStateMixin {
  late final AnimatedMapController _animatedController;

  // Default to Oran city centre — overwritten once GPS arrives
  LatLng _userCenter = const LatLng(36.7372, 3.0865);

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(this);
    _animatedController = AnimatedMapController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
      curve: Curves.easeInOutCubic,
    );
    _getCurrentLocation();
  }

  @override
  void didUpdateWidget(StadiaMapContainer old) {
    super.didUpdateWidget(old);
    if (old.controller != widget.controller) {
      old.controller?._detach();
      widget.controller?._attach(this);
    }
  }

  @override
  void dispose() {
    _animatedController.dispose();
    widget.controller?._detach();
    super.dispose();
  }

  // ── Camera ────────────────────────────────────────────────────────────────

  void _animateTo(LatLng target,
      {double zoom = 15.5, double verticalFraction = 0.35}) {
    if (!mounted) return;
    final screenH = MediaQuery.of(context).size.height;
    final offsetPx = screenH * (0.5 - verticalFraction);
    final metersPerPx = 156543.03392 *
        cos(target.latitude * pi / 180.0) /
        pow(2, zoom);
    final latOffsetDeg = (offsetPx * metersPerPx) / 111320.0;
    _animatedController.animateTo(
      dest: LatLng(target.latitude - latOffsetDeg, target.longitude),
      zoom: zoom,
    );
  }

  void _resetView() =>
      _animatedController.animateTo(dest: _userCenter, zoom: 15.0);

  // ── Location ──────────────────────────────────────────────────────────────

  Future<void> _getCurrentLocation() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return;
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
        if (perm == LocationPermission.denied) return;
      }
      if (perm == LocationPermission.deniedForever) return;

      final pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      if (!mounted) return;
      setState(() => _userCenter = LatLng(pos.latitude, pos.longitude));
      _animatedController.mapController.move(_userCenter, 15.0);
    } catch (e) {
      debugPrint('Location: $e');
    }
  }

  void _onMapTap(TapPosition tp, LatLng ll) =>
      widget.onMapTap?.call(ll.latitude, ll.longitude);

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bool trackingMode = widget.activeOrderDestination != null;

    return Stack(
      children: [
        FlutterMap(
          mapController: _animatedController.mapController,
          options: MapOptions(
            initialCenter: _userCenter,
            initialZoom: 15.0,
            minZoom: 3.0,
            maxZoom: 19.0,
            onTap: _onMapTap,
            interactionOptions: InteractionOptions(
              flags: widget.isOnline
                  ? InteractiveFlag.all
                  : InteractiveFlag.none,
            ),
          ),
          children: [
            // ── Stadia dark tiles ─────────────────────────────────
            TileLayer(
              urlTemplate:
                  'https://tiles.stadiamaps.com/tiles/alidade_smooth_dark'
                  '/{z}/{x}/{y}{r}.png?api_key={api_key}',
              additionalOptions: const {'api_key': _kStadiaApiKey},
              maxNativeZoom: 20,
              maxZoom: 20,
              userAgentPackageName: 'com.driver_app',
              tileProvider: CancellableNetworkTileProvider(),
            ),

            // ── Route polyline ────────────────────────────────────
            if (trackingMode)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: widget.routePoints ??
                        [_userCenter, widget.activeOrderDestination!],
                    color: const Color(0xFFE8000E),
                    strokeWidth: 4.5,
                    strokeCap: StrokeCap.round,
                    strokeJoin: StrokeJoin.round,
                  ),
                ],
              ),

            // ── User dot (always on top of tiles, below pins) ────
            MarkerLayer(markers: _buildUserMarker(), rotate: false),

            // ── Order markers (idle) or destination pin (tracking) ─
            if (!trackingMode)
              MarkerLayer(
                  markers: _buildDeliveryMarkers(), rotate: false),
            if (trackingMode)
              MarkerLayer(
                  markers: _buildDestinationMarker(), rotate: false),

            const SimpleAttributionWidget(
              source: Text(
                'Stadia Maps © OpenMapTiles © OpenStreetMap',
                style: TextStyle(fontSize: 10, color: Colors.white54),
              ),
            ),
          ],
        ),
        if (!widget.isOnline)
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.45)),
          ),
      ],
    );
  }

  // ── Markers ───────────────────────────────────────────────────────────────

  List<Marker> _buildUserMarker() => [
        Marker(
          point: _userCenter,
          width: 60,
          height: 60,
          child: const _PulsingDot(),
        ),
      ];

  List<Marker> _buildDeliveryMarkers() {
    return widget.markers.map((lm) {
      // Use the marker's own lat/lng — set explicitly in HomeScreen
      final pos = LatLng(lm.latitude, lm.longitude);
      final sel = widget.selectedMarker == lm;
      return Marker(
        point: pos,
        width: sel ? 62.0 : 50.0,
        height: sel ? 78.0 : 64.0,
        child: GestureDetector(
          onTap: () => widget.onMarkerTap?.call(lm),
          child: _MapPin(marker: lm, isSelected: sel),
        ),
      );
    }).toList();
  }

  List<Marker> _buildDestinationMarker() => [
        Marker(
          point: widget.activeOrderDestination!,
          width: 62,
          height: 78,
          child: const _DestinationPin(),
        ),
      ];
}

// ─────────────────────────────────────────────────────────────────────────────
// Pulsing radar dot — user location
// ─────────────────────────────────────────────────────────────────────────────
class _PulsingDot extends StatefulWidget {
  const _PulsingDot();
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1600))
      ..repeat();
    _scale = Tween<double>(begin: 0.3, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _opacity = Tween<double>(begin: 0.75, end: 0.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => Stack(
          alignment: Alignment.center,
          children: [
            // Outer ring
            Transform.scale(
              scale: _scale.value,
              child: Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE8000E)
                      .withOpacity(_opacity.value * 0.35),
                ),
              ),
            ),
            // Mid ring
            Transform.scale(
              scale: (_scale.value * 0.62).clamp(0.0, 1.0),
              child: Container(
                width: 60, height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE8000E).withOpacity(
                      (_opacity.value * 0.55).clamp(0.0, 1.0)),
                ),
              ),
            ),
            // White border
            Container(
              width: 18, height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.3), blurRadius: 4)
                ],
              ),
            ),
            // Red core
            Container(
              width: 12, height: 12,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Color(0xFFE8000E)),
            ),
          ],
        ),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Destination pin (active order)
// ─────────────────────────────────────────────────────────────────────────────
class _DestinationPin extends StatelessWidget {
  const _DestinationPin();

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 54, height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFFE8000E),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 3))
              ],
            ),
            child:
                const Icon(Icons.restaurant, color: Colors.white, size: 26),
          ),
          CustomPaint(
            size: const Size(14, 10),
            painter: _Tail(color: const Color(0xFFE8000E)),
          ),
        ],
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// Idle delivery pin
// ─────────────────────────────────────────────────────────────────────────────
class _MapPin extends StatelessWidget {
  final LocationMarker marker;
  final bool isSelected;
  const _MapPin({required this.marker, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    final double circle = isSelected ? 54 : 44;
    final double icon = isSelected ? 26 : 20;
    final Color bg = isSelected ? const Color(0xFFE8000E) : Colors.white;
    final Color fg = isSelected ? Colors.white : Colors.black87;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: circle, height: circle,
          decoration: BoxDecoration(
            color: bg, shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color:
                    Colors.black.withOpacity(isSelected ? 0.45 : 0.25),
                blurRadius: isSelected ? 12 : 5,
                offset: const Offset(0, 3),
              )
            ],
          ),
          child: Center(
              child: _PinIcon(type: marker.type, color: fg, size: icon)),
        ),
        CustomPaint(size: const Size(14, 10), painter: _Tail(color: bg)),
      ],
    );
  }
}

class _Tail extends CustomPainter {
  final Color color;
  const _Tail({required this.color});
  @override
  void paint(Canvas c, Size s) => c.drawPath(
        ui.Path()
          ..moveTo(0, 0)
          ..lineTo(s.width / 2, s.height)
          ..lineTo(s.width, 0)
          ..close(),
        Paint()..color = color,
      );
  @override
  bool shouldRepaint(_Tail o) => o.color != color;
}

class _PinIcon extends StatelessWidget {
  final LocationType type;
  final Color color;
  final double size;
  const _PinIcon(
      {required this.type, required this.color, required this.size});

  String get _asset {
    switch (type) {
      case LocationType.restaurant:
        return 'assets/icons/restaurant.png';
      case LocationType.pastry:
        return 'assets/icons/paisetry.png';
      default:
        return 'assets/icons/fastfood.png';
    }
  }

  @override
  Widget build(BuildContext context) => ColorFiltered(
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
        child: Image.asset(_asset,
            width: size,
            height: size,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) =>
                Icon(Icons.restaurant, color: color, size: size)),
      );
}