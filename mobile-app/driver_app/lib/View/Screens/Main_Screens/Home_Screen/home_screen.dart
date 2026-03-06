import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:driver_app/View/Components/TopStatusBar/top_status_bar.dart';
import 'package:driver_app/View/Components/BottomNavigation/bottom_navigation.dart';
import 'package:driver_app/View/Components/MapContainer/stadia_map_container.dart';
import 'package:driver_app/View/Components/LocationMarker/location_marker.dart';
import 'package:driver_app/View/Components/MapContainer/order_card.dart';
import 'package:driver_app/View/Components/FloatingButton/floating_button.dart';
import 'package:driver_app/View/Screens/Main_Screens/Active_Order_Screen/active_order_screen.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Test orders — all within ~600 m of Oran city centre (36.7372, 3.0865)
// so every pin is visible on one screen at zoom 15.
//
//   User dot  →  36.7372, 3.0865   (Oran city centre)
//   Marker 1  →  36.7410, 3.0820   (NW  ~500 m)
//   Marker 2  →  36.7420, 3.0910   (NE  ~540 m)
//   Marker 3  →  36.7335, 3.0830   (SW  ~490 m)
//   Marker 4  →  36.7345, 3.0900   (SE  ~430 m)
//   Marker 5  →  36.7390, 3.0865   (N   ~200 m  — closest)
// ─────────────────────────────────────────────────────────────────────────────
final List<LocationMarker> kTestMarkers = [
  const LocationMarker(
    type: LocationType.restaurant,
    latitude:  36.7410,
    longitude: 3.0820,
    title: 'Livraison',
    price: '300 DA',
    distance: '0.5 km',
    restaurantName: 'Pizziria wlad 19',
    address: 'Rue Benkahla\nAkid Lotfi, Oran',
    rating: '4.5',
  ),
  const LocationMarker(
    type: LocationType.pastry,
    latitude:  36.7420,
    longitude: 3.0910,
    title: 'Pâtisserie',
    price: '180 DA',
    distance: '0.6 km',
    restaurantName: 'Pâtisserie El Bahja',
    address: 'Bd Millénium\nOran',
    rating: '4.9',
  ),
  const LocationMarker(
    type: LocationType.package,
    latitude:  36.7335,
    longitude: 3.0830,
    title: 'Colis',
    price: '250 DA',
    distance: '0.5 km',
    restaurantName: 'Courier Express',
    address: 'Rue des Frères Bouchama\nOran',
    rating: '4.8',
  ),
  const LocationMarker(
    type: LocationType.market,
    latitude:  36.7345,
    longitude: 3.0900,
    title: 'Marché',
    price: '150 DA',
    distance: '0.4 km',
    restaurantName: 'Souk El Had',
    address: 'Place du 1er Novembre\nOran',
    rating: '4.7',
  ),
  const LocationMarker(
    type: LocationType.fish,
    latitude:  36.7390,
    longitude: 3.0865,
    title: 'Poissonnerie',
    price: '220 DA',
    distance: '0.2 km',
    restaurantName: 'Marché du Port',
    address: "Port d'Oran\nOran",
    rating: '4.6',
  ),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {

  bool _isOnline = true;
  int  _currentTab = 0;
  LocationMarker? _selectedMarker;
  String _earnings = '0 DA';
  bool _cardVisible = false;

  final StadiaMapController _mapCtrl = StadiaMapController();

  late final AnimationController _cardAnim;
  late final Animation<double>   _cardFade;
  late final Animation<Offset>   _cardSlide;

  static const double _focusFraction = 0.35;
  static const double _pinHalfH      = 32.0;
  static const Duration _camDuration = Duration(milliseconds: 650);

  @override
  void initState() {
    super.initState();
    _cardAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _cardFade = CurvedAnimation(parent: _cardAnim, curve: Curves.easeOut);
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _cardAnim, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _cardAnim.dispose();
    super.dispose();
  }

  // ── Marker tap ─────────────────────────────────────────────────────────────

  void _onMarkerTap(LocationMarker tapped) {
    if (_selectedMarker == tapped) { _dismiss(); return; }

    setState(() {
      _selectedMarker = tapped;
      _cardVisible    = false;
    });
    _cardAnim.reset();

    // positionOf() now just returns LatLng(marker.lat, marker.lng) directly
    final pos = _mapCtrl.positionOf(tapped);
    if (pos != null) {
      _mapCtrl.animateTo(pos,
          zoom: 15.5, verticalFraction: _focusFraction);
    }

    Future.delayed(_camDuration + const Duration(milliseconds: 60), () {
      if (!mounted || _selectedMarker != tapped) return;
      setState(() => _cardVisible = true);
      _cardAnim.forward();
    });
  }

  void _dismiss() {
    _cardAnim.reverse().then((_) {
      if (!mounted) return;
      setState(() {
        _selectedMarker = null;
        _cardVisible    = false;
      });
    });
    _mapCtrl.resetView();
  }

  // ── Accept → push tracking screen ─────────────────────────────────────────

  void _onAccept(LocationMarker accepted) {
    final destination = _mapCtrl.positionOf(accepted)!;
    // Use map controller's userCenter; fall back to Oran default
    final origin = _mapCtrl.userCenter ??
        const LatLng(36.7372, 3.0865);

    setState(() {
      _selectedMarker = null;
      _cardVisible    = false;
    });
    _cardAnim.reset();

    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, anim, __) => ActiveOrderScreen(
          order: accepted,
          destination: destination,
          origin: origin,
        ),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity:
              CurvedAnimation(parent: anim, curve: Curves.easeIn),
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  void _toggleOnlineStatus() {
    if (_isOnline && _selectedMarker != null) _dismiss();
    setState(() => _isOnline = !_isOnline);
  }

  void _centreOnUser() {
    if (_selectedMarker != null) _dismiss();
    _mapCtrl.resetView();
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final double screenH    = MediaQuery.of(context).size.height;
    final double pinTipY    = screenH * _focusFraction + _pinHalfH;
    final double cardTopMax = screenH - 300 - 80 - 8;
    final double cardTop    = pinTipY.clamp(120.0, cardTopMax);
    final bool   showCard   =
        _selectedMarker != null && _isOnline && _cardVisible;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [

          // ── Map ─────────────────────────────────────────────────
          Positioned.fill(
            child: StadiaMapContainer(
              markers: _isOnline ? kTestMarkers : [],
              isOnline: _isOnline,
              selectedMarker: _selectedMarker,
              controller: _mapCtrl,
              onMapTap: (_, __) {
                if (_selectedMarker != null) _dismiss();
              },
              onMarkerTap: _onMarkerTap,
            ),
          ),

          // ── Top bar ─────────────────────────────────────────────
          Positioned(
            top: 0, left: 0, right: 0,
            child: TopStatusBar(
              isOnline: _isOnline,
              earnings: _earnings,
              onToggleStatus: _toggleOnlineStatus,
              onActionPressed: () {},
            ),
          ),

          // ── Order card ───────────────────────────────────────────
          if (showCard)
            Positioned(
              top: cardTop, left: 12, right: 12,
              child: FadeTransition(
                opacity: _cardFade,
                child: SlideTransition(
                  position: _cardSlide,
                  child: _CardWithWatermark(
                    marker: _selectedMarker!,
                    onClose: _dismiss,
                    onAccept: () => _onAccept(_selectedMarker!),
                  ),
                ),
              ),
            ),

          // ── Right FABs ───────────────────────────────────────────
          if (_isOnline)
            Positioned(
              right: 16, bottom: 96,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingButton(
                    type: FloatingButtonType.flag,
                    isActive: true,
                    onPressed: () => ScaffoldMessenger.of(context)
                        .showSnackBar(const SnackBar(
                      content: Text('Position flagged'),
                      duration: Duration(seconds: 1),
                      backgroundColor: Color(0xFFE8000E),
                    )),
                  ),
                  const SizedBox(height: 12),
                  FloatingButton(
                    type: FloatingButtonType.target,
                    isActive: true,
                    onPressed: _centreOnUser,
                  ),
                ],
              ),
            ),

          // ── Left FAB ────────────────────────────────────────────
          if (_isOnline)
            Positioned(
              left: 16, bottom: 96,
              child: FloatingButton(
                type: FloatingButtonType.profile,
                isActive: true,
                onPressed: () => ScaffoldMessenger.of(context)
                    .showSnackBar(const SnackBar(
                  content: Text('Opening profile…'),
                  duration: Duration(seconds: 1),
                  backgroundColor: Color(0xFFE8000E),
                )),
              ),
            ),

          // ── Bottom nav ───────────────────────────────────────────
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: BottomNavigation(
              currentTab: NavigationTab.values[_currentTab],
              onTabChanged: (tab) => setState(
                  () => _currentTab =
                      NavigationTab.values.indexOf(tab)),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Order card wrapper with faint watermark icon
// ─────────────────────────────────────────────────────────────────────────────
class _CardWithWatermark extends StatelessWidget {
  final LocationMarker marker;
  final VoidCallback onClose;
  final VoidCallback onAccept;
  const _CardWithWatermark(
      {required this.marker,
      required this.onClose,
      required this.onAccept});

  IconData get _icon {
    switch (marker.type) {
      case LocationType.restaurant: return Icons.restaurant;
      case LocationType.pastry:     return Icons.cake;
      case LocationType.fish:       return Icons.set_meal;
      case LocationType.market:     return Icons.storefront;
      default:                      return Icons.inventory_2;
    }
  }

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            OrderCard(
                marker: marker, onClose: onClose, onAccept: onAccept),
            Positioned(
              right: -16, top: 0, bottom: 0,
              child: IgnorePointer(
                child: Center(
                  child: Icon(_icon,
                      size: 160,
                      color:
                          const Color(0xFFE8000E).withOpacity(0.08)),
                ),
              ),
            ),
          ],
        ),
      );
}