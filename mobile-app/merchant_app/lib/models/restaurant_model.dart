class SocialMedia {
  final String? instagram;
  final String? facebook;
  final String? tiktok;
  final String? whatsapp;

  SocialMedia({
    this.instagram,
    this.facebook,
    this.tiktok,
    this.whatsapp,
  });

  factory SocialMedia.fromJson(Map<String, dynamic> json) {
    return SocialMedia(
      instagram: json['instagram'],
      facebook:  json['facebook'],
      tiktok:    json['tiktok'],
      whatsapp:  json['whatsapp'],
    );
  }

  Map<String, dynamic> toJson() => {
    'instagram': instagram,
    'facebook':  facebook,
    'tiktok':    tiktok,
    'whatsapp':  whatsapp,
  };
}

class RestaurantModel {
  final String id;
  final String merchantId;
  final String name;
  final String? logoUrl;
  final String? coverUrl;
  final String address;
  final double? lat;
  final double? lng;
  final SocialMedia? socials;
  final bool isActive;

  RestaurantModel({
    required this.id,
    required this.merchantId,
    required this.name,
    this.logoUrl,
    this.coverUrl,
    required this.address,
    this.lat,
    this.lng,
    this.socials,
    this.isActive = true,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) {
    return RestaurantModel(
      id:         json['_id'] ?? '',
      merchantId: json['merchantId'] ?? '',
      name:       json['name'] ?? '',
      logoUrl:    json['logoUrl'],
      coverUrl:   json['coverUrl'],
      address:    json['address'] ?? '',
      lat:        json['location']?['lat']?.toDouble(),
      lng:        json['location']?['lng']?.toDouble(),
      socials:    json['socials'] != null
                    ? SocialMedia.fromJson(json['socials'])
                    : null,
      isActive:   json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    '_id':       id,
    'merchantId': merchantId,
    'name':      name,
    'logoUrl':   logoUrl,
    'coverUrl':  coverUrl,
    'address':   address,
    'location':  lat != null ? {'lat': lat, 'lng': lng} : null,
    'socials':   socials?.toJson(),
    'isActive':  isActive,
  };
}