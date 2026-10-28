class Vehicle {
  final String? vehicleId;
  final String ownerId;
  final String model;
  final double distance;
  final double fuelCapacity;
  final double pricePerHour;
  final double dailyRate;
  final bool isAvailable;
  final double latitude;
  final double longitude;

  Vehicle({
    this.vehicleId,
    this.ownerId = '',
    required this.model,
    required this.distance,
    required this.fuelCapacity,
    required this.pricePerHour,
    this.dailyRate = 50.0,
    this.isAvailable = true,
    this.latitude = 24.8949,
    this.longitude = 91.8687,
  });

  factory Vehicle.fromMap(Map<String, dynamic> map, {String? id}) {
    return Vehicle(
      vehicleId: id ?? map['vehicleId'] ?? map['carId'],
      ownerId: map['ownerId'] ?? '',
      model: map['model'] ?? '',
      distance: (map['distance'] as num?)?.toDouble() ?? 0.0,
      fuelCapacity: (map['fuelCapacity'] as num?)?.toDouble() ?? 0.0,
      pricePerHour: (map['pricePerHour'] as num?)?.toDouble() ?? (map['dailyRate'] as num?)?.toDouble() ?? 50.0,
      dailyRate: (map['dailyRate'] as num?)?.toDouble() ?? (map['pricePerHour'] as num?)?.toDouble() ?? 50.0,
      isAvailable: map['isAvailable'] ?? true,
      latitude: (map['latitude'] as num?)?.toDouble() ?? 24.8949,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 91.8687,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'model': model,
      'distance': distance,
      'fuelCapacity': fuelCapacity,
      'pricePerHour': pricePerHour,
      'dailyRate': dailyRate,
      'isAvailable': isAvailable,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
