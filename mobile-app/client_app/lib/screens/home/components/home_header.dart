import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../../../frontend/lib/constants.dart';

/// Top bar: red circular search (left), red location pill (center), red bell (right).
/// Location button now opens a bottom sheet to select location!
class HomeHeader extends StatefulWidget {
  const HomeHeader({Key? key}) : super(key: key);

  @override
  State<HomeHeader> createState() => _HomeHeaderState();
}

class _HomeHeaderState extends State<HomeHeader> {
  String _selectedCity = "Oran";
  String _selectedArea = "Bir El Jir";

  // Available locations - you can expand this list
  static const List<Map<String, dynamic>> _locations = [
    {
      "city": "Oran",
      "areas": ["Bir El Jir", "Es Senia", "Arzew", "Mers El Kebir", "Gdyel"]
    },
    {
      "city": "Algiers",
      "areas": ["Bab Ezzouar", "Hydra", "El Biar", "Cheraga", "Dar El Beida"]
    },
    {
      "city": "Constantine",
      "areas": ["Zouaghi", "El Khroub", "Didouche Mourad", "Hamma Bouziane"]
    },
    {
      "city": "Annaba",
      "areas": ["Sidi Amar", "El Bouni", "Seraidi", "Berrahal"]
    },
    {
      "city": "Tlemcen",
      "areas": ["Mansourah", "Chetouane", "Maghnia", "Remchi"]
    },
  ];

  void _showLocationPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _LocationPickerBottomSheet(
        locations: _locations,
        currentCity: _selectedCity,
        currentArea: _selectedArea,
        onLocationSelected: (city, area) {
          setState(() {
            _selectedCity = city;
            _selectedArea = area;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Left: red circular search button
          _RedCircleIconButton(
            asset: "assets/icons/Search Icon.svg",
            onTap: () {
              // TODO: Implement search functionality
            },
          ),
          const SizedBox(width: 12),
          // Center: red pill – location button (NOW INTERACTIVE!)
          Expanded(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _showLocationPicker, // Opens location picker
                borderRadius: BorderRadius.circular(999),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.circular(999),
                    boxShadow: [
                      BoxShadow(
                        color: kPrimaryColor.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "localisation",
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white.withValues(alpha: 0.9),
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  "$_selectedCity. $_selectedArea",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.keyboard_arrow_down,
                                color: Colors.white,
                                size: 20,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Right: red circular bell
          _RedCircleIconButton(
            asset: "assets/icons/Bell.svg",
            onTap: () {
              // TODO: Implement notifications
            },
          ),
        ],
      ),
    );
  }
}

// Location Picker Bottom Sheet Widget
class _LocationPickerBottomSheet extends StatefulWidget {
  const _LocationPickerBottomSheet({
    required this.locations,
    required this.currentCity,
    required this.currentArea,
    required this.onLocationSelected,
  });

  final List<Map<String, dynamic>> locations;
  final String currentCity;
  final String currentArea;
  final Function(String city, String area) onLocationSelected;

  @override
  State<_LocationPickerBottomSheet> createState() =>
      _LocationPickerBottomSheetState();
}

class _LocationPickerBottomSheetState
    extends State<_LocationPickerBottomSheet> {
  late String _selectedCity;
  late String _selectedArea;

  @override
  void initState() {
    super.initState();
    _selectedCity = widget.currentCity;
    _selectedArea = widget.currentArea;
  }

  List<String> _getAreasForCity(String city) {
    final location = widget.locations.firstWhere(
      (loc) => loc["city"] == city,
      orElse: () => {"areas": []},
    );
    return List<String>.from(location["areas"] ?? []);
  }

  @override
  Widget build(BuildContext context) {
    final areas = _getAreasForCity(_selectedCity);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          // Title
          const Text(
            "Choose your location",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: kTextColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Select your city and area for delivery",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 24),
          // Content
          Expanded(
            child: Row(
              children: [
                // Cities list (left side)
                Expanded(
                  flex: 2,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      border: Border(
                        right: BorderSide(color: Colors.grey[200]!),
                      ),
                    ),
                    child: ListView.builder(
                      itemCount: widget.locations.length,
                      itemBuilder: (context, index) {
                        final city = widget.locations[index]["city"] as String;
                        final isSelected = city == _selectedCity;

                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedCity = city;
                              // Auto-select first area of the new city
                              final newAreas = _getAreasForCity(city);
                              if (newAreas.isNotEmpty) {
                                _selectedArea = newAreas[0];
                              }
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 16),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.transparent,
                              border: Border(
                                left: BorderSide(
                                  color: isSelected
                                      ? kPrimaryColor
                                      : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.location_city,
                                  color: isSelected
                                      ? kPrimaryColor
                                      : Colors.grey[600],
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    city,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                      color: isSelected
                                          ? kPrimaryColor
                                          : kTextColor,
                                    ),
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.chevron_right,
                                    color: kPrimaryColor,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                // Areas list (right side)
                Expanded(
                  flex: 3,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: areas.length,
                    itemBuilder: (context, index) {
                      final area = areas[index];
                      final isSelected = area == _selectedArea;

                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedArea = area;
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? kPrimaryColor.withValues(alpha: 0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? kPrimaryColor
                                  : Colors.grey[200]!,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_off,
                                color: isSelected
                                    ? kPrimaryColor
                                    : Colors.grey[400],
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  area,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    color:
                                        isSelected ? kPrimaryColor : kTextColor,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle,
                                  color: kPrimaryColor,
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Confirm button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onLocationSelected(_selectedCity, _selectedArea);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "Confirm Location: $_selectedCity, $_selectedArea",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Red Circle Icon Button (unchanged)
class _RedCircleIconButton extends StatelessWidget {
  const _RedCircleIconButton({required this.asset, required this.onTap});

  final String asset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          height: 48,
          width: 48,
          decoration: const BoxDecoration(
            color: kPrimaryColor,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: SvgPicture.asset(
              asset,
              colorFilter:
                  const ColorFilter.mode(Colors.white, BlendMode.srcIn),
              width: 22,
              height: 22,
            ),
          ),
        ),
      ),
    );
  }
}
