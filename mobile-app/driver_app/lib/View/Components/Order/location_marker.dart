enum LocationType { restaurant, pastry, package, fish, market }

class LocationMarker {
  final LocationType type;

  /// Short label shown in the red chip (e.g. "Laivrison")
  final String title;

  /// Price string shown large (e.g. "300 DA")
  final String price;

  /// Distance string (e.g. "3.3 km")
  final String distance;

  /// Restaurant / business name (e.g. "Pizziria wlad 19")
  final String restaurantName;

  /// Full address (e.g. "Rue Benkahla\nAkid Lotfi ,Oran")
  final String address;

  const LocationMarker({
    required this.type,
    required this.title,
    required this.price,
    required this.distance,
    required this.restaurantName,
    required this.address,
  });
}