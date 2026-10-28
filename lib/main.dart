import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_attend/injection_container.dart';
import 'package:flutter_attend/presentation/bloc/vehicle_bloc.dart';
import 'package:flutter_attend/presentation/bloc/vehicle_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'firebase_options.dart';
import 'package:flutter_attend/presentation/pages/onboarding.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  initInjection();
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getit<VehicleBloc>()..add(LoadVehicles()),
      child: MaterialApp(
        title: 'RentalApp',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const OnboardingPage(),
      ),
    );
  }
}
