import 'dart:async';
import 'package:flutter/services.dart';
import 'package:mobile/src/services/location_service.dart';

/// Emergency contact information
class EmergencyContact {
  final String id;
  final String name;
  final String phoneNumber;
  final String? email;
  final bool isEnabled;
  final ContactType type;

  const EmergencyContact({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.email,
    required this.isEnabled,
    required this.type,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'email': email,
      'isEnabled': isEnabled,
      'type': type.toString(),
    };
  }

  factory EmergencyContact.fromMap(Map<String, dynamic> map) {
    return EmergencyContact(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      email: map['email'],
      isEnabled: map['isEnabled'] ?? true,
      type: ContactType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => ContactType.personal,
      ),
    );
  }

  EmergencyContact copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? email,
    bool? isEnabled,
    ContactType? type,
  }) {
    return EmergencyContact(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      isEnabled: isEnabled ?? this.isEnabled,
      type: type ?? this.type,
    );
  }

  @override
  String toString() {
    return 'EmergencyContact(id: $id, name: $name, phoneNumber: $phoneNumber, type: $type)';
  }
}

/// Types of emergency contacts
enum ContactType {
  personal,
  legal,
  medical,
  family,
}

/// Service for managing emergency contacts and notifications
class EmergencyContactService {
  static const MethodChannel _channel = MethodChannel('cop_stopper/emergency_contacts');
  final LocationService _locationService;

  EmergencyContactService(this._locationService);

  /// Get all emergency contacts
  Future<List<EmergencyContact>> getEmergencyContacts() async {
    try {
      final result = await _channel.invokeMethod<List<dynamic>>('getEmergencyContacts');
      if (result == null) return [];
      
      return result
          .cast<Map<String, dynamic>>()
          .map((map) => EmergencyContact.fromMap(map))
          .toList();
    } on PlatformException catch (e) {
      print('Failed to get emergency contacts: ${e.message}');
      return [];
    }
  }

  /// Add emergency contact
  Future<bool> addEmergencyContact(EmergencyContact contact) async {
    try {
      final result = await _channel.invokeMethod<bool>('addEmergencyContact', contact.toMap());
      return result ?? false;
    } on PlatformException catch (e) {
      print('Failed to add emergency contact: ${e.message}');
      return false;
    }
  }

  /// Update emergency contact
  Future<bool> updateEmergencyContact(EmergencyContact contact) async {
    try {
      final result = await _channel.invokeMethod<bool>('updateEmergencyContact', contact.toMap());
      return result ?? false;
    } on PlatformException catch (e) {
      print('Failed to update emergency contact: ${e.message}');
      return false;
    }
  }

  /// Remove emergency contact
  Future<bool> removeEmergencyContact(String contactId) async {
    try {
      final result = await _channel.invokeMethod<bool>('removeEmergencyContact', {
        'contactId': contactId,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      print('Failed to remove emergency contact: ${e.message}');
      return false;
    }
  }

  /// Send emergency notification to all enabled contacts
  Future<bool> sendEmergencyNotification({
    required String message,
    bool includeLocation = true,
    List<String>? specificContactIds,
  }) async {
    try {
      String? locationText;
      if (includeLocation) {
        try {
          final locationResult = await _locationService.getCurrentLocation();
          locationText = 'Location: ${locationResult.position.latitude}, ${locationResult.position.longitude}';
        } catch (e) {
          print('Failed to get location for emergency notification: $e');
        }
      }

      final fullMessage = locationText != null 
          ? '$message\n\n$locationText'
          : message;

      final result = await _channel.invokeMethod<bool>('sendEmergencyNotification', {
        'message': fullMessage,
        'includeLocation': includeLocation,
        'specificContactIds': specificContactIds,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      print('Failed to send emergency notification: ${e.message}');
      return false;
    }
  }

  /// Send location update to emergency contacts
  Future<bool> sendLocationUpdate() async {
    try {
      final locationResult = await _locationService.getCurrentLocation();
      final message = 'Emergency location update: ${locationResult.position.latitude}, ${locationResult.position.longitude}';
      
      return await sendEmergencyNotification(
        message: message,
        includeLocation: false, // Location already included in message
      );
    } catch (e) {
      print('Failed to send location update: $e');
      return false;
    }
  }

  /// Start periodic location sharing during emergency
  StreamSubscription<LocationResult>? _locationSubscription;
  
  Future<void> startPeriodicLocationSharing({
    Duration interval = const Duration(minutes: 5),
  }) async {
    await stopPeriodicLocationSharing(); // Stop any existing sharing
    
    _locationSubscription = _locationService.watchLocation().listen(
      (locationResult) async {
        await sendLocationUpdate();
      },
      onError: (error) {
        print('Error in periodic location sharing: $error');
      },
    );
  }

  /// Stop periodic location sharing
  Future<void> stopPeriodicLocationSharing() async {
    await _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  /// Check if SMS permissions are granted
  Future<bool> hasSMSPermission() async {
    try {
      final result = await _channel.invokeMethod<bool>('hasSMSPermission');
      return result ?? false;
    } on PlatformException catch (e) {
      print('Failed to check SMS permission: ${e.message}');
      return false;
    }
  }

  /// Request SMS permissions
  Future<bool> requestSMSPermission() async {
    try {
      final result = await _channel.invokeMethod<bool>('requestSMSPermission');
      return result ?? false;
    } on PlatformException catch (e) {
      print('Failed to request SMS permission: ${e.message}');
      return false;
    }
  }

  /// Test emergency notification system
  Future<bool> testEmergencyNotification() async {
    return await sendEmergencyNotification(
      message: 'This is a test of the Cop Stopper emergency notification system. Please ignore.',
      includeLocation: false,
    );
  }

  /// Get legal hotline numbers for current jurisdiction
  Future<List<EmergencyContact>> getLegalHotlines() async {
    try {
      // Get current jurisdiction
      final jurisdiction = await _locationService.getCurrentJurisdiction();
      
      final result = await _channel.invokeMethod<List<dynamic>>('getLegalHotlines', {
        'jurisdiction': jurisdiction?.toJson(),
      });
      
      if (result == null) return [];
      
      return result
          .cast<Map<String, dynamic>>()
          .map((map) => EmergencyContact.fromMap(map))
          .toList();
    } on PlatformException catch (e) {
      print('Failed to get legal hotlines: ${e.message}');
      return [];
    }
  }

  /// Call emergency services (911/local equivalent)
  Future<bool> callEmergencyServices() async {
    try {
      final result = await _channel.invokeMethod<bool>('callEmergencyServices');
      return result ?? false;
    } on PlatformException catch (e) {
      print('Failed to call emergency services: ${e.message}');
      return false;
    }
  }

  /// Call legal hotline
  Future<bool> callLegalHotline() async {
    try {
      final hotlines = await getLegalHotlines();
      if (hotlines.isEmpty) {
        print('No legal hotlines available for current jurisdiction');
        return false;
      }

      // Call the first available legal hotline
      final result = await _channel.invokeMethod<bool>('makePhoneCall', {
        'phoneNumber': hotlines.first.phoneNumber,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      print('Failed to call legal hotline: ${e.message}');
      return false;
    }
  }

  /// Dispose of resources
  void dispose() {
    stopPeriodicLocationSharing();
  }
}