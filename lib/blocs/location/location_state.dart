part of 'location_bloc.dart';

class LocationState extends Equatable {
  final bool followwingUser;
  //ultimno geolocation
  //historia

  const LocationState({this.followwingUser = false});

  @override
  List<Object> get props => [followwingUser];
}
