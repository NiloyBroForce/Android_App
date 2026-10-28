import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_attend/data/models/vehicle.dart';

class FirebaseVehicleDataSource {
  final FirebaseFirestore _firestore;

  FirebaseVehicleDataSource({required this._firestore});

  Future<List<Vehicle>> getVehicles() async {
    var snapshot = await _firestore.collection('vehicles').get();
    if (snapshot.docs.isEmpty) {
      snapshot = await _firestore.collection('cars').get();
    }
    return snapshot.docs.map((doc) => Vehicle.fromMap(doc.data(), id: doc.id)).toList();
  }
}
