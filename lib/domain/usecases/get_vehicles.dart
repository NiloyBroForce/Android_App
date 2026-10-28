import 'package:flutter_attend/domain/repo/vehicle_repo.dart';
import 'package:flutter_attend/data/models/vehicle.dart';

class GetVehicles {
  final VehicleRepo repo;

  GetVehicles(this.repo);

  Future<List<Vehicle>> call() async {
    return await repo.fetchVehicles();
  }
}
