import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

/// Service for handling location permissions with user-friendly explanations
class LocationPermissionService {
  
  /// Check if location permission is granted
  Future<bool> hasLocationPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always || 
           permission == LocationPermission.whileInUse;
  }

  /// Request location permission with user explanation
  Future<LocationPermissionResult> requestLocationPermission(BuildContext context) async {
    // First check current permission status
    final currentPermission = await Geolocator.checkPermission();
    
    if (currentPermission == LocationPermission.deniedForever) {
      return LocationPermissionResult(
        granted: false,
        shouldShowRationale: true,
        message: 'Location permission has been permanently denied. Please enable it in Settings.',
        action: LocationPermissionAction.openSettings,
      );
    }

    if (currentPermission == LocationPermission.denied) {
      // Show explanation dialog before requesting permission
      final shouldRequest = await _showPermissionExplanationDialog(context);
      if (!shouldRequest) {
        return LocationPermissionResult(
          granted: false,
          shouldShowRationale: false,
          message: 'Location permission is required for legal guidance.',
        );
      }
    }

    // Request permission
    final permission = await Geolocator.requestPermission();
    
    switch (permission) {
      case LocationPermission.always:
      case LocationPermission.whileInUse:
        return LocationPermissionResult(
          granted: true,
          message: 'Location permission granted successfully.',
        );
        
      case LocationPermission.denied:
        return LocationPermissionResult(
          granted: false,
          shouldShowRationale: true,
          message: 'Location permission is needed to provide accurate legal guidance based on your jurisdiction.',
          action: LocationPermissionAction.retry,
        );
        
      case LocationPermission.deniedForever:
        return LocationPermissionResult(
          granted: false,
          shouldShowRationale: true,
          message: 'Location permission has been permanently denied. Please enable it in Settings to receive jurisdiction-specific legal guidance.',
          action: LocationPermissionAction.openSettings,
        );
        
      case LocationPermission.unableToDetermine:
        return LocationPermissionResult(
          granted: false,
          message: 'Unable to determine location permission status. Please try again.',
          action: LocationPermissionAction.retry,
        );
    }
  }

  /// Show explanation dialog for why location permission is needed
  Future<bool> _showPermissionExplanationDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Permission Required'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Cop Stopper needs access to your location to provide:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text('• Accurate legal guidance for your jurisdiction'),
              Text('• Local laws and regulations information'),
              Text('• Jurisdiction-specific rights and procedures'),
              Text('• Emergency contact information for your area'),
              SizedBox(height: 12),
              Text(
                'Your location data is stored securely on your device and is never shared without your explicit consent.',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Not Now'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Grant Permission'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  /// Open app settings for manual permission configuration
  Future<bool> openAppSettings() async {
    try {
      return await Geolocator.openAppSettings();
    } catch (e) {
      debugPrint('Failed to open app settings: $e');
      return false;
    }
  }

  /// Check if location services are enabled on the device
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Show dialog to enable location services
  Future<bool> showLocationServiceDialog(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Location Services Disabled'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.location_off,
                size: 48,
                color: Colors.orange,
              ),
              SizedBox(height: 16),
              Text(
                'Location services are currently disabled on your device. '
                'Please enable them in your device settings to receive '
                'jurisdiction-specific legal guidance.',
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Continue Without Location'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Open Settings'),
            ),
          ],
        );
      },
    ) ?? false;
  }

  /// Get user-friendly permission status message
  String getPermissionStatusMessage(LocationPermission permission) {
    switch (permission) {
      case LocationPermission.always:
        return 'Location access granted (always)';
      case LocationPermission.whileInUse:
        return 'Location access granted (while using app)';
      case LocationPermission.denied:
        return 'Location permission denied';
      case LocationPermission.deniedForever:
        return 'Location permission permanently denied';
      case LocationPermission.unableToDetermine:
        return 'Unable to determine location permission status';
    }
  }
}

/// Result of location permission request
class LocationPermissionResult {
  final bool granted;
  final bool shouldShowRationale;
  final String message;
  final LocationPermissionAction? action;

  const LocationPermissionResult({
    required this.granted,
    this.shouldShowRationale = false,
    required this.message,
    this.action,
  });
}

/// Actions that can be taken based on permission result
enum LocationPermissionAction {
  retry,
  openSettings,
  continueWithoutLocation,
}