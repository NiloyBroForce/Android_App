import 'package:flutter/material.dart';
import 'package:flutter_attend/data/models/vehicle.dart';
import 'package:flutter_attend/presentation/pages/vehicle_details_page.dart';

class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback? onTap;

  const VehicleCard({
    super.key,
    required this.vehicle,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    String assetPath = "assets/car_image.png";
    if (vehicle.type.toLowerCase() == 'motorcycle') {
      assetPath = "assets/motorcycle_image.png";
    } else if (vehicle.type.toLowerCase() == 'bicycle') {
      assetPath = "assets/bicycle_image.png";
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFF2C2B32),
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap ?? () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CardDetailsPage(vehicle: vehicle),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Image.asset(
                  assetPath,
                  height: 120,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Image.asset(
                    "assets/car_image.png",
                    height: 120,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                vehicle.model,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildSpecItem(
                    assetPath: "assets/gps.png",
                    label: '${vehicle.distance.toStringAsFixed(0)} km',
                  ),
                  _buildSpecItem(
                    assetPath: "assets/pump.png",
                    label: '${vehicle.fuelCapacity.toStringAsFixed(0)} L',
                  ),
                  Text(
                    'BDT ${vehicle.pricePerHour.toStringAsFixed(0)}/h',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecItem({required String assetPath, required String label}) {
    return Row(
      children: [
        Image.asset(
          assetPath,
          height: 20,
          width: 20,
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
