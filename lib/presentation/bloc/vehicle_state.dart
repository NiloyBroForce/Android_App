import 'package:flutter_attend/data/models/vehicle.dart';

abstract class VehicleState {}

class VehiclesLoading extends VehicleState {}

class VehiclesLoaded extends VehicleState {
  final List<Vehicle> vehicles;

  VehiclesLoaded(this.vehicles);
}

class VehiclesError extends VehicleState {
  final String message;

  VehiclesError(this.message);
}
