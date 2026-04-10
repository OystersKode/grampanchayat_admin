import 'package:cloud_firestore/cloud_firestore.dart';

class Vehicle {
  final String id;
  final String driverName;
  final String driverPhone;
  final String area;
  final String vehicleNumber;
  final String vehicleModel;

  Vehicle({
    required this.id,
    required this.driverName,
    required this.driverPhone,
    required this.area,
    required this.vehicleNumber,
    required this.vehicleModel,
  });

  factory Vehicle.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Vehicle(
      id: doc.id,
      driverName: data['driver_name'] ?? '',
      driverPhone: data['driver_phone'] ?? '',
      area: data['area'] ?? '',
      vehicleNumber: data['vehicle_number'] ?? '',
      vehicleModel: data['vehicle_model'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'driver_name': driverName,
      'driver_phone': driverPhone,
      'area': area,
      'vehicle_number': vehicleNumber,
      'vehicle_model': vehicleModel,
    };
  }
}
