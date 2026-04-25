import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  // static final List<Position> _capturedPositions = [];
  // static bool _isCapturing = false;
  // static StreamSubscription<Position>? _positionStreamSubscription;
  static bool _isDialogShowing = false;

  /// Starts background capture of location points.
  /// Should be called when the survey starts.
  // static void startGlobalCapture() {
  //   _capturedPositions.clear();
  //   _isCapturing = true;
  //   _positionStreamSubscription = Geolocator.getPositionStream(
  //     locationSettings: const LocationSettings(
  //       accuracy: LocationAccuracy.high,
  //       distanceFilter: 0,
  //     ),
  //   ).listen((Position position) {
  //     if (_isCapturing) {
  //       _capturedPositions.add(position);
  //       print("Global Capture: Received reading with accuracy: ${position.accuracy}");
  //     }
  //   });
  // }

  /// Stops global capture.
  // static void stopGlobalCapture() {
  //   _isCapturing = false;
  //   _positionStreamSubscription?.cancel();
  //   _positionStreamSubscription = null;
  // }

  // static List<Position> get capturedPositions => _capturedPositions;

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

  /// Gets the best location from the historical buffer and a fresh 10s capture.
  // static Future<Position?> getBestLocation(
  //   void Function(String message) onProgress,
  // ) async {
  //   List<Position> positions = List.from(_capturedPositions);
  //   bool isDone = false;

  //   onProgress("Refining location (10s pulse)...");

  //   // Start a 10 second timer for a final high-accuracy pulse
  //   Timer(const Duration(seconds: 10), () {
  //     isDone = true;
  //   });

  //   while (!isDone) {
  //     try {
  //       Position position = await Geolocator.getCurrentPosition(
  //         locationSettings: const LocationSettings(
  //           accuracy: LocationAccuracy.high,
  //           timeLimit: Duration(seconds: 5),
  //         ),
  //       );
  //       positions.add(position);
  //       onProgress("Optimizing... (${positions.length} total samples)");
  //     } catch (e) {
  //       // Silently continue if a single request fails
  //     }
  //     await Future.delayed(const Duration(milliseconds: 500));
  //   }

  //   if (positions.isEmpty) return null;

  //   // Return the position with the best accuracy (lowest accuracy value)
  //   positions.sort((a, b) => a.accuracy.compareTo(b.accuracy));
  //   return positions.first;
  // }

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
}
