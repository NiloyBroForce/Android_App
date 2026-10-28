import 'package:bloc/bloc.dart';
import 'package:flutter_attend/domain/usecases/get_vehicles.dart';
import 'package:flutter_attend/presentation/bloc/vehicle_event.dart';
import 'package:flutter_attend/presentation/bloc/vehicle_state.dart';

class VehicleBloc extends Bloc<VehicleEvent, VehicleState> {
  final GetVehicles getVehicles;

  VehicleBloc({required this.getVehicles}) : super(VehiclesLoading()) {
    on<LoadVehicles>((event, emit) async {
      emit(VehiclesLoading());
      try {
        final vehicles = await getVehicles.call();
        emit(VehiclesLoaded(vehicles));
      } catch (e) {
        emit(VehiclesError(e.toString()));
      }
    });
  }
}
