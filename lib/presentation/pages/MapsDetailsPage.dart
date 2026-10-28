import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_attend/data/models/vehicle.dart';

class MapsDetailsPage extends StatelessWidget {
  final Vehicle vehicle;

  const MapsDetailsPage({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: LatLng(vehicle.latitude, vehicle.longitude),
              initialZoom: 14,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}.png?key=cb1_4wqg_1_5e965b78ca1d784889a54fc8',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.niloybroforce.rental',
                maxZoom: 19,
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: LatLng(vehicle.latitude, vehicle.longitude),
                    width: 80,
                    height: 80,
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _VehicleDetailsCard(vehicle: vehicle),
          ),
        ],
      ),
      floatingActionButton: user == null
          ? null
          : FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
                  final data = snapshot.data!.data() as Map<String, dynamic>?;
                  final role = data?['role'] ?? 'renter';
                  if (role == 'owner') {
                    return const SizedBox.shrink();
                  }
                }

                return FloatingActionButton.extended(
                  onPressed: () {
                    final durationController = TextEditingController();

                    showDialog(
                      context: context,
                      builder: (dialogContext) {
                        return AlertDialog(
                          title: const Text('Enter Rental Time Window'),
                          content: TextField(
                            controller: durationController,
                            decoration: const InputDecoration(
                              labelText: 'Time Window (e.g. 8pm-10pm or 8:00am - 10:00pm)',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () async {
                                final duration = durationController.text.trim();

                                final RegExp timeWindowRegExp = RegExp(
                                  r'^(?:1[0-2]|[1-9])(?::[0-5]\d)?\s*[ap]m\s*(?:-|to)\s*(?:1[0-2]|[1-9])(?::[0-5]\d)?\s*[ap]m$',
                                  caseSensitive: false,
                                );

                                if (!timeWindowRegExp.hasMatch(duration)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Invalid format. Hours must be between 1 and 12 AM/PM (e.g. "8pm-10pm" or "8:00am - 10:00pm").'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                Navigator.pop(dialogContext);

                                try {
                                  await FirebaseFirestore.instance.collection('bookings').add({
                                    'vehicleId': vehicle.vehicleId ?? 'unknown_vehicle',
                                    'carId': vehicle.vehicleId ?? 'unknown_vehicle',
                                    'ownerId': vehicle.ownerId,
                                    'renterId': user.uid,
                                    'startDate': DateTime.now().toIso8601String().split('T')[0],
                                    'duration': duration,
                                    'createdAt': FieldValue.serverTimestamp(),
                                  });

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Vehicle booked successfully!')),
                                    );
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(content: Text('Booking failed: $e')),
                                    );
                                  }
                                }
                              },
                              child: const Text('Confirm'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.bookmark_add),
                  label: const Text('Book Vehicle'),
                );
              },
            ),
    );
  }
}

class _VehicleDetailsCard extends StatelessWidget {
  final Vehicle vehicle;

  const _VehicleDetailsCard({required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black38,
                  spreadRadius: 0,
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Text(
                  vehicle.model,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.directions_car, color: Colors.white, size: 16),
                    const SizedBox(width: 5),
                    Text(
                      '> ${vehicle.distance} km',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    const SizedBox(width: 10),
                    const Icon(Icons.battery_full, color: Colors.white, size: 14),
                    const SizedBox(width: 5),
                    Text(
                      '${vehicle.fuelCapacity}',
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
