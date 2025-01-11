part of 'location_bloc.dart';

class LocationState extends Equatable {
  final bool followwingUser;
  final LatLng? lastKnownLocation;
  final List<LatLng> myLocationHistory;
  //ultimno geolocation
  //historia

  const LocationState(
      {this.followwingUser = false, this.lastKnownLocation, myLocationHistory})
      : myLocationHistory = myLocationHistory ?? const [];

  LocationState copywith({
    final bool? followwingUser,
    final LatLng? lastKnownLocation,
    final List<LatLng>? myLocationHistory,
  }) =>
      LocationState(
          followwingUser: followwingUser ?? this.followwingUser,
          lastKnownLocation: lastKnownLocation ?? this.lastKnownLocation,
          myLocationHistory: myLocationHistory ?? this.myLocationHistory);

  @override
  List<Object?> get props =>
      [followwingUser, lastKnownLocation, myLocationHistory];
}
