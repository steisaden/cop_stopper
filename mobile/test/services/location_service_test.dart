import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mobile/src/services/location_service.dart';
import 'package:mobile/src/services/gps_location_service.dart';
import 'package:mobile/src/services/location_permission_service.dart';
import 'package:mobile/src/services/location_boundary_service.dart';

void main() {
  group('LocationService Models', () {
    group('Jurisdiction', () {
      test('should create jurisdiction from JSON', () {
        final json = {
          'city': 'San Francisco',
          'county': 'San Francisco County',
          'state': 'California',
          'country': 'United States',
          'fullName': 'San Francisco, San Francisco County, California, United States',
          'lastUpdated': '2023-01-01T00:00:00.000Z',
        };

        final jurisdiction = Jurisdiction.fromJson(json);

        expect(jurisdiction.city, 'San Francisco');
        expect(jurisdiction.county, 'San Francisco County');
        expect(jurisdiction.state, 'California');
        expect(jurisdiction.country, 'United States');
        expect(jurisdiction.fullName, 'San Francisco, San Francisco County, California, United States');
      });

      test('should convert jurisdiction to JSON', () {
        final jurisdiction = Jurisdiction(
          city: 'San Francisco',
          county: 'San Francisco County',
          state: 'California',
          country: 'United States',
          fullName: 'San Francisco, San Francisco County, California, United States',
          lastUpdated: DateTime.parse('2023-01-01T00:00:00.000Z'),
        );

        final json = jurisdiction.toJson();

        expect(json['city'], 'San Francisco');
        expect(json['county'], 'San Francisco County');
        expect(json['state'], 'California');
        expect(json['country'], 'United States');
        expect(json['fullName'], 'San Francisco, San Francisco County, California, United States');
        expect(json['lastUpdated'], '2023-01-01T00:00:00.000Z');
      });

      test('should have string representation', () {
        final jurisdiction = Jurisdiction(
          city: 'San Francisco',
          county: 'San Francisco County',
          state: 'California',
          country: 'United States',
          fullName: 'San Francisco, San Francisco County, California, United States',
          lastUpdated: DateTime.now(),
        );

        expect(jurisdiction.toString(), 'San Francisco, San Francisco County, California, United States');
      });
    });

    group('LocationResult', () {
      test('should create location result with accuracy', () {
        final position = Position(
          longitude: -122.4194,
          latitude: 37.7749,
          timestamp: DateTime.now(),
          accuracy: 5.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        );

        final result = LocationResult(
          position: position,
          accuracy: LocationAccuracyLevel.high,
          timestamp: DateTime.now(),
        );

        expect(result.position, position);
        expect(result.accuracy, LocationAccuracyLevel.high);
        expect(result.warning, isNull);
      });

      test('should create location result with warning', () {
        final position = Position(
          longitude: -122.4194,
          latitude: 37.7749,
          timestamp: DateTime.now(),
          accuracy: 5.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        );

        final result = LocationResult(
          position: position,
          accuracy: LocationAccuracyLevel.low,
          timestamp: DateTime.now(),
          warning: 'Using cached location',
        );

        expect(result.position, position);
        expect(result.accuracy, LocationAccuracyLevel.low);
        expect(result.warning, 'Using cached location');
      });
    });

    group('LocationAccuracyLevel', () {
      test('should have correct enum values', () {
        expect(LocationAccuracyLevel.values, [
          LocationAccuracyLevel.high,
          LocationAccuracyLevel.medium,
          LocationAccuracyLevel.low,
          LocationAccuracyLevel.unknown,
        ]);
      });
    });

    group('LocationException', () {
      test('should create exception with message', () {
        final exception = LocationException('Test error');
        
        expect(exception.message, 'Test error');
        expect(exception.code, isNull);
        expect(exception.toString(), 'LocationException: Test error');
      });

      test('should create exception with message and code', () {
        final exception = LocationException('Test error', code: 'TEST_CODE');
        
        expect(exception.message, 'Test error');
        expect(exception.code, 'TEST_CODE');
        expect(exception.toString(), 'LocationException: Test error');
      });
    });
  });

  group('LocationPermissionService', () {
    group('LocationPermissionResult', () {
      test('should create permission result', () {
        final result = LocationPermissionResult(
          granted: true,
          message: 'Permission granted',
        );

        expect(result.granted, true);
        expect(result.shouldShowRationale, false);
        expect(result.message, 'Permission granted');
        expect(result.action, isNull);
      });

      test('should create permission result with action', () {
        final result = LocationPermissionResult(
          granted: false,
          shouldShowRationale: true,
          message: 'Permission denied',
          action: LocationPermissionAction.openSettings,
        );

        expect(result.granted, false);
        expect(result.shouldShowRationale, true);
        expect(result.message, 'Permission denied');
        expect(result.action, LocationPermissionAction.openSettings);
      });
    });

    group('LocationPermissionAction', () {
      test('should have correct enum values', () {
        expect(LocationPermissionAction.values, [
          LocationPermissionAction.retry,
          LocationPermissionAction.openSettings,
          LocationPermissionAction.continueWithoutLocation,
        ]);
      });
    });
  });

  group('LocationBoundaryService', () {
    group('JurisdictionChangeEvent', () {
      test('should create jurisdiction change event', () {
        final position = Position(
          longitude: -122.4194,
          latitude: 37.7749,
          timestamp: DateTime.now(),
          accuracy: 5.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        );

        final jurisdiction = Jurisdiction(
          city: 'San Francisco',
          county: 'San Francisco County',
          state: 'California',
          country: 'United States',
          fullName: 'San Francisco, San Francisco County, California, United States',
          lastUpdated: DateTime.now(),
        );

        final event = JurisdictionChangeEvent(
          type: JurisdictionChangeType.initial,
          newJurisdiction: jurisdiction,
          position: position,
          timestamp: DateTime.now(),
        );

        expect(event.type, JurisdictionChangeType.initial);
        expect(event.newJurisdiction, jurisdiction);
        expect(event.position, position);
        expect(event.oldJurisdiction, isNull);
        expect(event.distance, isNull);
      });

      test('should get correct description for different change types', () {
        final position = Position(
          longitude: -122.4194,
          latitude: 37.7749,
          timestamp: DateTime.now(),
          accuracy: 5.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        );

        final jurisdiction = Jurisdiction(
          city: 'San Francisco',
          county: 'San Francisco County',
          state: 'California',
          country: 'United States',
          fullName: 'San Francisco, San Francisco County, California, United States',
          lastUpdated: DateTime.now(),
        );

        final initialEvent = JurisdictionChangeEvent(
          type: JurisdictionChangeType.initial,
          newJurisdiction: jurisdiction,
          position: position,
          timestamp: DateTime.now(),
        );

        final cityEvent = JurisdictionChangeEvent(
          type: JurisdictionChangeType.city,
          newJurisdiction: jurisdiction,
          position: position,
          timestamp: DateTime.now(),
        );

        expect(initialEvent.getDescription(), 'Current location: San Francisco, San Francisco County, California, United States');
        expect(cityEvent.getDescription(), 'Entered San Francisco');
      });

      test('should get correct severity for different change types', () {
        final position = Position(
          longitude: -122.4194,
          latitude: 37.7749,
          timestamp: DateTime.now(),
          accuracy: 5.0,
          altitude: 0.0,
          altitudeAccuracy: 0.0,
          heading: 0.0,
          headingAccuracy: 0.0,
          speed: 0.0,
          speedAccuracy: 0.0,
        );

        final jurisdiction = Jurisdiction(
          city: 'San Francisco',
          county: 'San Francisco County',
          state: 'California',
          country: 'United States',
          fullName: 'San Francisco, San Francisco County, California, United States',
          lastUpdated: DateTime.now(),
        );

        final countryEvent = JurisdictionChangeEvent(
          type: JurisdictionChangeType.country,
          newJurisdiction: jurisdiction,
          position: position,
          timestamp: DateTime.now(),
        );

        final cityEvent = JurisdictionChangeEvent(
          type: JurisdictionChangeType.city,
          newJurisdiction: jurisdiction,
          position: position,
          timestamp: DateTime.now(),
        );

        expect(countryEvent.getSeverity(), JurisdictionChangeSeverity.critical);
        expect(cityEvent.getSeverity(), JurisdictionChangeSeverity.low);
      });
    });

    group('JurisdictionChangeType', () {
      test('should have correct enum values', () {
        expect(JurisdictionChangeType.values, [
          JurisdictionChangeType.initial,
          JurisdictionChangeType.country,
          JurisdictionChangeType.state,
          JurisdictionChangeType.county,
          JurisdictionChangeType.city,
          JurisdictionChangeType.minor,
        ]);
      });
    });

    group('JurisdictionChangeSeverity', () {
      test('should have correct enum values', () {
        expect(JurisdictionChangeSeverity.values, [
          JurisdictionChangeSeverity.info,
          JurisdictionChangeSeverity.low,
          JurisdictionChangeSeverity.medium,
          JurisdictionChangeSeverity.high,
          JurisdictionChangeSeverity.critical,
        ]);
      });
    });
  });
}