import 'package:flutter/material.dart';

enum LocationType {
  package,
  restaurant,
  pastry,
  fish,
  market,
}

class LocationMarker {
  final LocationType type;
  final double latitude;
  final double longitude;
  final String? rating;
  final String? title;
  final String? price;
  final String? distance;
  final String? restaurantName;
  final String? address;

  const LocationMarker({
    required this.type,
    required this.latitude,
    required this.longitude,
    this.rating,
    this.title,
    this.price,
    this.distance,
    this.restaurantName,
    this.address,
  });
}