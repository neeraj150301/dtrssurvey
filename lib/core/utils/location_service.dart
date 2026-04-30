import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static final List<Position> _capturedPositions = [];
  static bool _isDialogShowing = false;

  static Position? _bestPosition;
  static Position? _startPosition;
  static Timer? _timer;

  /// Starts background capture of location points.
  static void startGlobalCapture(BuildContext context) async {
    _capturedPositions.clear();
    _bestPosition = null;

    _startPosition = await Geolocator.getCurrentPosition();
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      try {
        Position position = await Geolocator.getCurrentPosition();
        _capturedPositions.add(position);
        if (_bestPosition == null ||
            position.accuracy < _bestPosition!.accuracy) {
          _bestPosition = position;
        }
        // print("New accuracy: ${position.accuracy}");
        final distance = Geolocator.distanceBetween(
          _startPosition!.latitude,
          _startPosition!.longitude,
          position.latitude,
          position.longitude,
        );

        if (distance > 100) {
          _showOutOfRangeDialog(context);
        }
      } catch (e) {
        // print("Location error: $e");
      }
    });
  }

  /// Stops global capture.
  static void stopGlobalCapture() {
    _timer?.cancel();
    _timer = null;
  }

  static Position? getBestPosition() {
    return _bestPosition;
  }

  static List<Position> get capturedPositions => _capturedPositions;

  /// Checks for both service enabled and permissions.
  static Future<void> checkLocationRequirements(BuildContext context) async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (context.mounted && !_isDialogShowing) {
        await _showLocationDisabledDialog(context);
      }
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location permissions are denied')),
          );
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permissions are permanently denied.'),
          ),
        );
      }
      return;
    }
  }

  static Future<void> _showLocationDisabledDialog(BuildContext context) async {
    _isDialogShowing = true;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Text(
              "Location Services Disabled",
              style: TextStyle(
                fontSize: 20,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            content: const Text(
              "This app requires location services to be enabled at all times during use. Please enable location to continue.",
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              FilledButton(
                child: const Text("Open Settings"),
                onPressed: () async {
                  await Geolocator.openLocationSettings();
                },
              ),
              OutlinedButton(
                child: const Text("Retry"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
    _isDialogShowing = false;
    if (context.mounted) {
      await checkLocationRequirements(context);
    }
  }

  /// Monitors the device's location service status and prompts if disabled.
  static void monitorLocationService(BuildContext context) {
    Geolocator.getServiceStatusStream().listen((ServiceStatus status) {
      if (status == ServiceStatus.disabled) {
        if (context.mounted) {
          checkLocationRequirements(context);
        }
      }
    });
  }

  static bool _isOutDialogShowing = false;

  static void _showOutOfRangeDialog(BuildContext context) {
    if (_isOutDialogShowing) return;

    _isOutDialogShowing = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            title: const Text(
              "Out of Range",
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
            content: const Text(
              "You have moved more than 100 meters.\nPlease return to the starting location to continue.",
            ),
            actions: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _isOutDialogShowing = false;
                },
                child: const Text("OK"),
              ),
            ],
          ),
        );
      },
    );
  }
}
