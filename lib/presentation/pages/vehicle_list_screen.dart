import 'package:flutter/material.dart';
import 'package:flutter_attend/presentation/bloc/vehicle_bloc.dart';
import 'package:flutter_attend/presentation/bloc/vehicle_state.dart';
import 'package:flutter_attend/presentation/widgets/vehicle_card.dart';
import 'package:flutter_attend/presentation/pages/onboarding.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CarListScreen extends StatelessWidget {
  const CarListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Choose your vehicle"),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const OnboardingPage()),
              (route) => false,
            );
          },
        ),
      ),
      body: BlocBuilder<VehicleBloc, VehicleState>(
        builder: (context, state) {
          if (state is VehiclesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is VehiclesLoaded) {
            return ListView.builder(
              itemCount: state.vehicles.length,
              itemBuilder: (context, index) {
                return VehicleCard(vehicle: state.vehicles[index]);
              },
            );
          } else if (state is VehiclesError) {
            return const Center(child: Text("Something went wrong"));
          }
          return Container();
        },
      ),
    );
  }
}
