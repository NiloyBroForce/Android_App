import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_attend/injection_container.dart';
import 'package:flutter_attend/presentation/bloc/vehicle_bloc.dart';
import 'package:flutter_attend/presentation/bloc/vehicle_event.dart';
import 'package:flutter_attend/presentation/bloc/vehicle_state.dart';
import 'package:flutter_attend/presentation/widgets/vehicle_card.dart';
import 'package:flutter_attend/presentation/pages/profile_page.dart';
import 'package:flutter_attend/presentation/pages/onboarding.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CarListScreen extends StatefulWidget {
  const CarListScreen({super.key});

  @override
  State<CarListScreen> createState() => _CarListScreenState();
}

class _CarListScreenState extends State<CarListScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const _VehicleListTab(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getit<VehicleBloc>()..add(LoadVehicles()),
      child: Scaffold(
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
              icon: Icon(Icons.directions_car),
              label: 'Vehicles',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class _VehicleListTab extends StatelessWidget {
  const _VehicleListTab();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Choose your vehicle"),
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
      body: BlocBuilder<VehicleBloc, VehicleState>(
        builder: (context, state) {
          if (state is VehiclesLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is VehiclesLoaded) {
            if (state.vehicles.isEmpty) {
              return const Center(child: Text("No vehicles available right now."));
            }
            return ListView.builder(
              itemCount: state.vehicles.length,
              itemBuilder: (context, index) {
                return VehicleCard(vehicle: state.vehicles[index]);
              },
            );
          } else if (state is VehiclesError) {
            return Center(child: Text("Error: ${state.message}"));
          }
          return Container();
        },
      ),
    );
  }
}
