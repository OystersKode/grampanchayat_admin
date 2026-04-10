import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vehicle_model.dart';

class VehicleService {
  final CollectionReference _vehicleCollection =
      FirebaseFirestore.instance.collection('vehicles');

  Stream<List<Vehicle>> getVehicles() {
    return _vehicleCollection.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Vehicle.fromFirestore(doc)).toList();
    });
  }

  Future<void> addVehicle(Vehicle vehicle) {
    return _vehicleCollection.add(vehicle.toFirestore());
  }

  Future<void> updateVehicle(Vehicle vehicle) {
    return _vehicleCollection.doc(vehicle.id).update(vehicle.toFirestore());
  }

  Future<void> deleteVehicle(String id) {
    return _vehicleCollection.doc(id).delete();
  }
}
