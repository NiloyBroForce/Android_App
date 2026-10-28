import 'package:flutter_attend/data/models/vehicle.dart';

abstract class VehicleRepo {
  Future<List<Vehicle>> fetchVehicles();
}
