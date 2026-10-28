import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_attend/core/utils/encryption_helper.dart';
import 'package:flutter_attend/data/models/vehicle.dart';
import 'package:flutter_attend/presentation/pages/MapsDetailsPage.dart';
import 'package:flutter_attend/presentation/widgets/vehicle_card.dart';

class CardDetailsPage extends StatelessWidget {
  final Vehicle vehicle;

  const CardDetailsPage({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.info_outline),
            Text(' Information')
          ],
        ),
      ),
      body: Column(
        children: [
          VehicleCard(
            vehicle: Vehicle(
              model: vehicle.model,
              type: vehicle.type,
              distance: vehicle.distance,
              fuelCapacity: vehicle.fuelCapacity,
              pricePerHour: vehicle.pricePerHour,
              latitude: vehicle.latitude,
              longitude: vehicle.longitude,
            ),
            onTap: () {},
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                        color: const Color(0xffF3F3F3),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                              spreadRadius: 5
                          )
                        ]
                    ),
                    child: FutureBuilder<DocumentSnapshot>(
                      future: vehicle.ownerId.isNotEmpty
                          ? FirebaseFirestore.instance.collection('users').doc(vehicle.ownerId).get()
                          : null,
                      builder: (context, snapshot) {
                        String ownerName = 'Vehicle Owner';
                        String ownerPhone = 'N/A';
                        String ownerEmail = 'N/A';

                        if (snapshot.hasData && snapshot.data != null && snapshot.data!.exists) {
                          final data = snapshot.data!.data() as Map<String, dynamic>?;
                          if (data != null) {
                            ownerName = data['name'] ?? 'Vehicle Owner';
                            ownerPhone = EncryptionHelper.decrypt(data['phone'] ?? 'N/A');
                            ownerEmail = EncryptionHelper.decrypt(data['email'] ?? 'N/A');
                          }
                        }
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              ownerName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.phone, size: 16, color: Colors.grey),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    ownerPhone,
                                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.email, size: 16, color: Colors.grey),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    ownerEmail,
                                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: GestureDetector(
                    onTap: (){
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MapsDetailsPage(vehicle: vehicle))
                      );
                    },
                    child: Container(
                      height: 170,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                spreadRadius: 5
                            )
                          ]
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/maps.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
