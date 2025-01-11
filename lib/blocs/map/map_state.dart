part of 'map_bloc.dart';

class MapState extends Equatable {
  //si el mapa esta inicializado
  final bool isMapInitialized;
  //seguir la ubicacion del usuario
  final bool followUser;

  const MapState({this.isMapInitialized = false, this.followUser = false});

  MapState copyWith({
    bool? isMapInitialized,
    bool? followUser,
  }) =>
      MapState(
          isMapInitialized: isMapInitialized ?? this.isMapInitialized,
          followUser: followUser ?? this.followUser);

  //coloco las propiedades aqui para saber cuando un estado es diferente a otro
  @override
  List<Object> get props => [isMapInitialized, followUser];
}
