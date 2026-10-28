import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_attend/core/utils/encryption_helper.dart';
import 'onboarding.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  Future<void> _showRemoveConfirmationDialog(
    BuildContext context,
    DocumentReference bookingRef,
    String vehicleModel,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Remove Booking'),
          content: Text(
            'Are you sure you want to remove the booking for "$vehicleModel"?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await bookingRef.delete();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Booking removed successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to remove booking: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("No user logged in."),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => const OnboardingPage()),
                    (route) => false,
                  );
                },
                child: const Text("Go to Login"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile & Bookings"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
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
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final userData = userSnapshot.data?.data() as Map<String, dynamic>?;
          final name = userData?['name'] ?? 'User';
          final rawEmail = userData?['email'] ?? user.email ?? 'N/A';
          final email = EncryptionHelper.decrypt(rawEmail);
          final rawPhone = userData?['phone'] ?? 'N/A';
          final phone = EncryptionHelper.decrypt(rawPhone);
          final role = userData?['role'] ?? 'renter';

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2B32),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person, size: 35, color: Colors.black),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "Role: ${role.toUpperCase()}",
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: Colors.grey, height: 24),
                      Row(
                        children: [
                          const Icon(Icons.email, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(email, style: const TextStyle(color: Colors.white70)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.phone, size: 16, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(phone, style: const TextStyle(color: Colors.white70)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                if (role == 'owner') ...[
                  const Text(
                    "Incoming Bookings",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('bookings')
                          .where('ownerId', isEqualTo: user.uid)
                          .snapshots(),
                      builder: (context, bookingSnapshot) {
                        if (bookingSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (!bookingSnapshot.hasData || bookingSnapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Text(
                              "No incoming bookings yet.",
                              style: TextStyle(color: Colors.grey),
                            ),
                          );
                        }

                        final bookings = bookingSnapshot.data!.docs;

                        return ListView.builder(
                          itemCount: bookings.length,
                          itemBuilder: (context, index) {
                            final bookingData = bookings[index].data() as Map<String, dynamic>;
                            final vehicleId = bookingData['vehicleId'] ?? bookingData['carId'] ?? '';
                            final renterId = bookingData['renterId'] ?? bookingData['clientId'] ?? '';
                            final startDate = bookingData['startDate'] ?? 'N/A';
                            final timeWindow = bookingData['duration'] ?? bookingData['timeWindow'] ?? 'N/A';

                            return FutureBuilder<List<DocumentSnapshot>>(
                              future: Future.wait([
                                FirebaseFirestore.instance.collection('vehicles').doc(vehicleId).get(),
                                if (renterId.isNotEmpty)
                                  FirebaseFirestore.instance.collection('users').doc(renterId).get()
                                else
                                  FirebaseFirestore.instance.collection('users').doc('dummy').get(),
                              ]),
                              builder: (context, snapshots) {
                                String vehicleModel = 'Vehicle';
                                String renterName = 'Client';
                                String renterPhone = 'N/A';

                                if (snapshots.hasData && snapshots.data != null) {
                                  final vehicleDoc = snapshots.data![0];
                                  if (vehicleDoc.exists && vehicleDoc.data() != null) {
                                    final vData = vehicleDoc.data() as Map<String, dynamic>;
                                    vehicleModel = vData['model'] ?? 'Vehicle';
                                  }

                                  if (snapshots.data!.length > 1) {
                                    final renterDoc = snapshots.data![1];
                                    if (renterDoc.exists && renterDoc.data() != null) {
                                      final rData = renterDoc.data() as Map<String, dynamic>;
                                      renterName = rData['name'] ?? 'Client';
                                      renterPhone = EncryptionHelper.decrypt(rData['phone'] ?? 'N/A');
                                    }
                                  }
                                }

                                return Card(
                                  elevation: 2,
                                  margin: const EdgeInsets.symmetric(vertical: 6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  child: ListTile(
                                    leading: const Icon(Icons.bookmark, size: 30, color: Colors.blue),
                                    title: Text(vehicleModel, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text("Booked for: $startDate | $timeWindow\nClient: $renterName\nPhone: $renterPhone"),
                                    isThreeLine: true,
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Chip(
                                          label: Text("Rented", style: TextStyle(color: Colors.white, fontSize: 12)),
                                          backgroundColor: Colors.blue,
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                                          tooltip: 'Remove Booking',
                                          onPressed: () => _showRemoveConfirmationDialog(
                                            context,
                                            bookings[index].reference,
                                            vehicleModel,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ] else ...[
                  const Text(
                    "My Bookings",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('bookings')
                          .where('renterId', isEqualTo: user.uid)
                          .snapshots(),
                      builder: (context, bookingSnapshot) {
                        if (bookingSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (!bookingSnapshot.hasData || bookingSnapshot.data!.docs.isEmpty) {
                          return const Center(
                            child: Text(
                              "No bookings found yet.",
                              style: TextStyle(color: Colors.grey),
                            ),
                          );
                        }

                        final bookings = bookingSnapshot.data!.docs;

                        return ListView.builder(
                          itemCount: bookings.length,
                          itemBuilder: (context, index) {
                            final bookingData = bookings[index].data() as Map<String, dynamic>;
                            final carId = bookingData['carId'] ?? bookingData['vehicleId'] ?? 'Vehicle';
                            final startDate = bookingData['startDate'] ?? 'N/A';
                            final timeWindow = bookingData['duration'] ?? bookingData['timeWindow'] ?? 'N/A';

                            return FutureBuilder<DocumentSnapshot>(
                              future: FirebaseFirestore.instance.collection('vehicles').doc(carId).get(),
                              builder: (context, vehicleSnapshot) {
                                String vehicleModel = 'Vehicle';
                                if (vehicleSnapshot.hasData && vehicleSnapshot.data != null && vehicleSnapshot.data!.exists) {
                                  final vData = vehicleSnapshot.data!.data() as Map<String, dynamic>?;
                                  vehicleModel = vData?['model'] ?? 'Vehicle';
                                }

                                return Card(
                                  elevation: 2,
                                  margin: const EdgeInsets.symmetric(vertical: 6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  child: ListTile(
                                    leading: const Icon(Icons.directions_car, size: 30),
                                    title: Text(vehicleModel, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Text("Booked for: $startDate\nTime Window: $timeWindow"),
                                    isThreeLine: true,
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Chip(
                                          label: Text("Confirmed", style: TextStyle(color: Colors.white, fontSize: 12)),
                                          backgroundColor: Colors.green,
                                        ),
                                        const SizedBox(width: 4),
                                        IconButton(
                                          icon: const Icon(Icons.delete_forever, color: Colors.red),
                                          tooltip: 'Remove Booking',
                                          onPressed: () => _showRemoveConfirmationDialog(
                                            context,
                                            bookings[index].reference,
                                            vehicleModel,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}
