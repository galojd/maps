import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
part 'location_event.dart';
part 'location_state.dart';

class LocationBloc extends Bloc<LocationEvent, LocationState> {
  StreamSubscription? positionStream;

  LocationBloc() : super(const LocationState()) {
    on<OnStartFollowingUser>(
        (event, emit) => emit(state.copywith(followwingUser: true)));
    on<OnStopFollowingUser>(
        (event, emit) => emit(state.copywith(followwingUser: false)));

    on<OnNewUserLocationEvent>((event, emit) {
      emit(state.copywith(
          lastKnownLocation: event.newlocation,
          myLocationHistory: [...state.myLocationHistory, event.newlocation]));
    });
  }

  Future getCurrenPosition() async {
    final position = await Geolocator.getCurrentPosition();
    add(OnNewUserLocationEvent(LatLng(position.latitude, position.longitude)));
  }

  void startFollowingUser() {
    add(OnStopFollowingUser());
    positionStream = Geolocator.getPositionStream().listen((event) {
      final position = event;
      add(OnNewUserLocationEvent(
          LatLng(position.latitude, position.longitude)));
    });
  }

  void stopFollowingUser() {
    positionStream!.cancel();
    add(OnStopFollowingUser());
    print('Detener ubicación del usuario');
  }

  @override
  Future<void> close() {
    stopFollowingUser();
    return super.close();
  }
}
