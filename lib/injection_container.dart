import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_attend/data/datasources/firebase_vehicle_data_source.dart';
import 'package:flutter_attend/data/repo/vehicle_repo_impl.dart';
import 'package:flutter_attend/domain/repo/vehicle_repo.dart';
import 'package:flutter_attend/domain/usecases/get_vehicles.dart';
import 'package:get_it/get_it.dart';

import 'presentation/bloc/vehicle_bloc.dart';

GetIt getit=GetIt.instance;

void initInjection(){
  try{
    getit.registerLazySingleton<FirebaseFirestore>(()=>FirebaseFirestore.instance);

    getit.registerLazySingleton<FirebaseVehicleDataSource>(
            ()=>FirebaseVehicleDataSource(firestore: getit<FirebaseFirestore>()));

    getit.registerLazySingleton<VehicleRepo>(
            ()=>VehicleRepoImpl(dataSource: getit<FirebaseVehicleDataSource>()));

    getit.registerLazySingleton<GetVehicles>(
            ()=>GetVehicles(getit<VehicleRepo>()));

    getit.registerFactory<VehicleBloc>(()=>VehicleBloc(getVehicles: getit<GetVehicles>()));

  }
  catch(e){
    rethrow;
  }
}