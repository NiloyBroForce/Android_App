import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_attend/data/models/vehicle.dart';
import 'package:flutter_attend/presentation/widgets/vehicle_card.dart';
import 'package:flutter_attend/presentation/pages/profile_page.dart';
import 'package:flutter_attend/presentation/pages/onboarding.dart';
import 'package:flutter_attend/presentation/pages/map_picker_page.dart';

class OwnerHomeScreen extends StatefulWidget {
  const OwnerHomeScreen({super.key});

  @override
  State<OwnerHomeScreen> createState() => _OwnerHomeScreenState();
}

class _OwnerHomeScreenState extends State<OwnerHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _OwnerDashboardTab(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class _OwnerDashboardTab extends StatefulWidget {
  const _OwnerDashboardTab();

  @override
  State<_OwnerDashboardTab> createState() => _OwnerDashboardTabState();
}

class _OwnerDashboardTabState extends State<_OwnerDashboardTab> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  void _showAddVehicleDialog(BuildContext context) {
    final modelController = TextEditingController();
    final distanceController = TextEditingController();
    final fuelController = TextEditingController();
    final priceController = TextEditingController();
    final latController = TextEditingController(text: '24.8949');
    final lngController = TextEditingController(text: '91.8687');
    String selectedType = 'car';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Add Vehicle for Renting",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      initialValue: selectedType,
                      decoration: const InputDecoration(
                        labelText: 'Vehicle Type',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'car', child: Text('Car')),
                        DropdownMenuItem(value: 'motorcycle', child: Text('Motorcycle')),
                        DropdownMenuItem(value: 'bicycle', child: Text('Bicycle')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() {
                            selectedType = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: modelController,
                      decoration: const InputDecoration(
                        labelText: 'Vehicle Model / Name (e.g. Toyota Corolla)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: distanceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Distance / Mileage (e.g. 1200)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: fuelController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Fuel / Battery Capacity (e.g. 50)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Daily Rate (BDT e.g. 5000)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final currentLat = double.tryParse(latController.text) ?? 24.8949;
                        final currentLng = double.tryParse(lngController.text) ?? 91.8687;

                        final LatLng? picked = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MapPickerPage(
                              initialLocation: LatLng(currentLat, currentLng),
                            ),
                          ),
                        );

                        if (picked != null) {
                          setModalState(() {
                            latController.text = picked.latitude.toStringAsFixed(6);
                            lngController.text = picked.longitude.toStringAsFixed(6);
                          });
                        }
                      },
                      icon: const Icon(Icons.map, color: Colors.black),
                      label: const Text("Pick Location on Map", style: TextStyle(color: Colors.black)),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.black),
                        minimumSize: const Size(double.infinity, 45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: latController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                            decoration: const InputDecoration(
                              labelText: 'Latitude',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: lngController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                            decoration: const InputDecoration(
                              labelText: 'Longitude',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () async {
                          final model = modelController.text.trim();
                          final distance = double.tryParse(distanceController.text) ?? 0.0;
                          final fuel = double.tryParse(fuelController.text) ?? 0.0;
                          final price = double.tryParse(priceController.text) ?? 50.0;
                          final latitude = double.tryParse(latController.text) ?? 24.8949;
                          final longitude = double.tryParse(lngController.text) ?? 91.8687;
                          final ownerId = _auth.currentUser?.uid ?? 'unknown_owner';

                          if (model.isNotEmpty) {
                            await _firestore.collection('vehicles').add({
                              'ownerId': ownerId,
                              'model': model,
                              'type': selectedType,
                              'distance': distance,
                              'fuelCapacity': fuel,
                              'pricePerHour': price,
                              'dailyRate': price,
                              'isAvailable': true,
                              'latitude': latitude,
                              'longitude': longitude,
                            });
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Vehicle added successfully!')),
                              );
                            }
                          }
                        },
                        child: const Text('Save Vehicle'),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentOwnerId = _auth.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Owner Dashboard"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const OnboardingPage()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: currentOwnerId != null
            ? _firestore.collection('vehicles').where('ownerId', isEqualTo: currentOwnerId).snapshots()
            : _firestore.collection('vehicles').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("No vehicles listed by you yet."),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _showAddVehicleDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text("Add Your First Vehicle"),
                  ),
                ],
              ),
            );
          }

          final vehicles = snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Vehicle.fromMap(data, id: doc.id);
          }).toList();

          return ListView.builder(
            itemCount: vehicles.length,
            itemBuilder: (context, index) {
              return VehicleCard(vehicle: vehicles[index]);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddVehicleDialog(context),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text("Add Vehicle"),
      ),
    );
  }
}
