import 'package:flutter_attend/data/datasources/firebase_vehicle_data_source.dart';
import 'package:flutter_attend/data/models/vehicle.dart';
import 'package:flutter_attend/domain/repo/vehicle_repo.dart';

class VehicleRepoImpl implements VehicleRepo {
  final FirebaseVehicleDataSource _dataSource;

  VehicleRepoImpl({required this._dataSource});

  @override
  Future<List<Vehicle>> fetchVehicles() async {
    return await _dataSource.getVehicles();
  }
}
