import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:maps_app/blocs/blocs.dart';

class mapView extends StatefulWidget {
  final LatLng initialLocation;

  const mapView({Key? key, required this.initialLocation}) : super(key: key);

  @override
  _mapViewState createState() => _mapViewState();
}

class _mapViewState extends State<mapView> {
  late FlutterLocalNotificationsPlugin _localNotificationsPlugin;
  late Location _location;
  late List<LatLng> _polygonPoints;
  late Set<Polygon> _polygons;
  bool _wasInside = false;

  @override
  void initState() {
    super.initState();
    _polygonPoints = [];
    _polygons = {};
    _initializeNotifications();
    _initializeLocation();
  }

  void _initializeNotifications() {
    _localNotificationsPlugin = FlutterLocalNotificationsPlugin();
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings =
        InitializationSettings(android: androidSettings);
    _localNotificationsPlugin.initialize(initializationSettings);
  }

  void _initializeLocation() async {
    _location = Location();
    bool _serviceEnabled = await _location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _location.requestService();
      if (!_serviceEnabled) return;
    }

    PermissionStatus _permissionGranted = await _location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await _location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) return;
    }

    _location.onLocationChanged.listen((LocationData currentLocation) {
      LatLng currentPosition = LatLng(
        currentLocation.latitude!,
        currentLocation.longitude!,
      );

      if (_polygonPoints.isNotEmpty) {
        bool isInside = _isInsidePerimeter(currentPosition, _polygonPoints);
        if (isInside != _wasInside) {
          _wasInside = isInside;
          _sendNotification(
            "Perímetro",
            isInside
                ? "Usted ingresó al área definida"
                : "Usted salió del área definida",
          );
        }
      }
    });
  }

  Future<void> _sendNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );
    const notificationDetails = NotificationDetails(android: androidDetails);
    await _localNotificationsPlugin.show(0, title, body, notificationDetails);
  }

  bool _isInsidePerimeter(LatLng point, List<LatLng> polygonPoints) {
    int intersections = 0;
    for (int i = 0; i < polygonPoints.length; i++) {
      final p1 = polygonPoints[i];
      final p2 = polygonPoints[(i + 1) % polygonPoints.length];
      if ((point.latitude > p1.latitude) != (point.latitude > p2.latitude) &&
          (point.longitude <
              (p2.longitude - p1.longitude) *
                      (point.latitude - p1.latitude) /
                      (p2.latitude - p1.latitude) +
                  p1.longitude)) {
        intersections++;
      }
    }
    return intersections % 2 != 0;
  }

  void _drawPerimeter() {
    if (_polygonPoints.isNotEmpty) {
      final polygon = Polygon(
        polygonId: PolygonId('home_area'),
        points: _polygonPoints,
        strokeColor: Colors.blue,
        strokeWidth: 3,
        fillColor: Colors.blue.withOpacity(0.3),
      );
      setState(() {
        _polygons.add(polygon);
      });
    }
  }

  void _clearPerimeter() {
    setState(() {
      _polygonPoints.clear();
      _polygons.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final mapBloc = BlocProvider.of<MapBloc>(context);

    final CameraPosition initialCameraPosition =
        CameraPosition(target: widget.initialLocation, zoom: 15);
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        SizedBox(
          width: size.width,
          height: size.height,
          child: GoogleMap(
            initialCameraPosition: initialCameraPosition,
            compassEnabled: false,
            myLocationEnabled: true,
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            onMapCreated: (controller) =>
                mapBloc.add(OnMapInitialzedEvent(controller)),
            polygons: _polygons,
            onTap: (position) {
              setState(() {
                _polygonPoints.add(position);
              });
            },
          ),
        ),
        Positioned(
          bottom: 20,
          left: 20,
          child: Row(children: [
            FloatingActionButton(
              onPressed: _drawPerimeter,
              child: Icon(Icons.check),
            ),
            const SizedBox(
              width: 10,
            ),
            FloatingActionButton(
              onPressed: _clearPerimeter,
              child: Icon(Icons.delete),
            )
          ]),
        ),
      ],
    );
  }
}
