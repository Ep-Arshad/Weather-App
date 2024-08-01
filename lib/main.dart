import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lottie/lottie.dart';
import 'package:wheather_app/bloc/weather_bloc_bloc.dart';
import 'package:wheather_app/screens/home_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LocationWrapper(),
    );
  }
}

class LocationWrapper extends StatefulWidget {
  const LocationWrapper({super.key});

  @override
  _LocationWrapperState createState() => _LocationWrapperState();
}

class _LocationWrapperState extends State<LocationWrapper> {
  Future<Position>? _positionFuture;

  @override
  void initState() {
    super.initState();
    _checkLocation();
  }

  Future<void> _checkLocation() async {
    try {
      Position position = await _determinePosition();
      setState(() {
        _positionFuture = Future.value(position);
      });
    } catch (e) {
      _showLocationDialog(context, e.toString());
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      // Wait for the user to enable location services
      await Future.delayed(const Duration(seconds: 5));
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw 'Location services are disabled. Please enable them.';
      }
    }

    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw 'Location permissions are denied. Please enable them.';
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      throw 'Location permissions are permanently denied. We cannot request permissions.';
    }

    // Get the current position
    return await Geolocator.getCurrentPosition();
  }

  void _showLocationDialog(BuildContext context, String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Location Required'),
            content: Text(message),
            actions: <Widget>[
              TextButton(
                child: const Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                  _checkLocation();
                },
              ),
            ],
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Position>(
      future: _positionFuture,
      builder: (context, snap) {
        if (snap.hasData) {
          return BlocProvider<WeatherBloc>(
            create: (context) => WeatherBloc()..add(FetchWeather(snap.data as Position)),
            child: const HomeScreen(),
          );
        } else if (snap.hasError) {
          return Scaffold(
            body: Center(
              child: Text(
                snap.error.toString(),
                style: const TextStyle(color: Colors.white, fontSize: 18),
                textAlign: TextAlign.center,
              ),
            ),
            backgroundColor: Colors.black,
          );
        } else {
          return Scaffold(
            body: Center(
              child: LottieBuilder.asset(
                'assets/json/Animation - 1716810801279.json',
              ),
            ),
            backgroundColor: Colors.black,
          );
        }
      },
    );
  }
}
