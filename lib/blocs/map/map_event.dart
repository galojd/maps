part of 'map_bloc.dart';

sealed class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object> get props => [];
}

class OnMapInitialzedEvent extends MapEvent {
  final GoogleMapController controller;

  const OnMapInitialzedEvent(this.controller);
}
