import 'package:flutter/material.dart';
import '../models/vehicle_model.dart';
import '../services/vehicle_service.dart';
import '../widgets/admin_drawer.dart';
import '../services/seed_vehicles.dart';

class ManageVehiclesScreen extends StatefulWidget {
  const ManageVehiclesScreen({super.key});

  @override
  State<ManageVehiclesScreen> createState() => _ManageVehiclesScreenState();
}

class _ManageVehiclesScreenState extends State<ManageVehiclesScreen> {
  final VehicleService _vehicleService = VehicleService();
  final _formKey = GlobalKey<FormState>();
  bool _isSeeding = false;

  final _driverNameController = TextEditingController();
  final _driverPhoneController = TextEditingController();
  final _areaController = TextEditingController();
  final _vehicleNumberController = TextEditingController();
  final _vehicleModelController = TextEditingController();

  @override
  void dispose() {
    _driverNameController.dispose();
    _driverPhoneController.dispose();
    _areaController.dispose();
    _vehicleNumberController.dispose();
    _vehicleModelController.dispose();
    super.dispose();
  }

  void _clearControllers() {
    _driverNameController.clear();
    _driverPhoneController.clear();
    _areaController.clear();
    _vehicleNumberController.clear();
    _vehicleModelController.clear();
  }

  void _showVehicleDialog({Vehicle? vehicle}) {
    if (vehicle != null) {
      _driverNameController.text = vehicle.driverName;
      _driverPhoneController.text = vehicle.driverPhone;
      _areaController.text = vehicle.area;
      _vehicleNumberController.text = vehicle.vehicleNumber;
      _vehicleModelController.text = vehicle.vehicleModel;
    } else {
      _clearControllers();
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(vehicle == null ? 'Add Vehicle' : 'Edit Vehicle'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _driverNameController,
                  decoration: const InputDecoration(labelText: 'Driver Name'),
                  validator: (value) => value!.isEmpty ? 'Enter name' : null,
                ),
                TextFormField(
                  controller: _driverPhoneController,
                  decoration: const InputDecoration(labelText: 'Driver Phone'),
                  validator: (value) => value!.isEmpty ? 'Enter phone' : null,
                  keyboardType: TextInputType.phone,
                ),
                TextFormField(
                  controller: _areaController,
                  decoration: const InputDecoration(labelText: 'Area'),
                  validator: (value) => value!.isEmpty ? 'Enter area' : null,
                ),
                TextFormField(
                  controller: _vehicleNumberController,
                  decoration: const InputDecoration(labelText: 'Vehicle Number'),
                  validator: (value) => value!.isEmpty ? 'Enter number' : null,
                ),
                TextFormField(
                  controller: _vehicleModelController,
                  decoration: const InputDecoration(labelText: 'Vehicle Model'),
                  validator: (value) => value!.isEmpty ? 'Enter model' : null,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final newVehicle = Vehicle(
                  id: vehicle?.id ?? '',
                  driverName: _driverNameController.text,
                  driverPhone: _driverPhoneController.text,
                  area: _areaController.text,
                  vehicleNumber: _vehicleNumberController.text,
                  vehicleModel: _vehicleModelController.text,
                );

                if (vehicle == null) {
                  await _vehicleService.addVehicle(newVehicle);
                } else {
                  await _vehicleService.updateVehicle(newVehicle);
                }
                if (mounted) Navigator.pop(context);
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryMaroon = Color(0xFF8B0000);
    const Color backgroundColor = Color(0xFFFFF8F7);

    return Scaffold(
      backgroundColor: backgroundColor,
      drawer: const AdminDrawer(),
      appBar: AppBar(
        title: const Text('Manage Vehicles'),
        backgroundColor: backgroundColor,
        foregroundColor: primaryMaroon,
        elevation: 0,
        actions: [
          _isSeeding
              ? const Center(child: Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator(strokeWidth: 2)))
              : IconButton(
                  icon: const Icon(Icons.cloud_download, color: primaryMaroon),
                  tooltip: 'Import Driver Data',
                  onPressed: () async {
                    setState(() => _isSeeding = true);
                    try {
                      await seedVehicles();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Driver data imported successfully!')),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error importing data: $e')),
                        );
                      }
                    } finally {
                      if (mounted) setState(() => _isSeeding = false);
                    }
                  },
                ),
        ],
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: primaryMaroon),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      body: StreamBuilder<List<Vehicle>>(
        stream: _vehicleService.getVehicles(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());

          final vehicles = snapshot.data ?? [];

          return ListView.builder(
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              final vehicle = vehicles[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(vehicle.driverName, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${vehicle.vehicleModel} - ${vehicle.vehicleNumber}\n${vehicle.area}\n${vehicle.driverPhone}'),
                  isThreeLine: true,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _showVehicleDialog(vehicle: vehicle),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Vehicle'),
                              content: const Text('Are you sure you want to delete this vehicle?'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            await _vehicleService.deleteVehicle(vehicle.id);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showVehicleDialog(),
        backgroundColor: primaryMaroon,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

