class MerchantModel {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? token; // JWT

  MerchantModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.token,
  });

  factory MerchantModel.fromJson(Map<String, dynamic> json) {
    return MerchantModel(
      id:        json['_id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName:  json['lastName'] ?? '',
      email:     json['email'] ?? '',
      phone:     json['phone'] ?? '',
      token:     json['token'],
    );
  }

  Map<String, dynamic> toJson() => {
    '_id':       id,
    'firstName': firstName,
    'lastName':  lastName,
    'email':     email,
    'phone':     phone,
  };

  String get fullName => '$firstName $lastName';
}