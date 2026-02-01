import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:mobile/src/collaborative_monitoring/services/officer_records_service_impl.dart';
import 'package:mobile/src/collaborative_monitoring/models/officer_profile.dart';
import 'package:mobile/src/collaborative_monitoring/models/complaint_record.dart';
import 'package:mobile/src/collaborative_monitoring/models/disciplinary_action.dart';
import 'package:mobile/src/collaborative_monitoring/models/career_timeline.dart';
import 'package:mobile/src/services/api_service.dart';

@GenerateMocks([ApiService])
import 'officer_records_tracking_test.mocks.dart';

void main() {
  group('Officer Records Tracking Tests', () {
    late OfficerRecordsServiceImpl service;
    late MockApiService mockApiService;

    setUp(() {
      mockApiService = MockApiService();
      service = OfficerRecordsServiceImpl(mockApiService);
    });

    tearDown(() {
      service.clearCache();
    });

    group('Complaint History Tracking', () {
      test('should retrieve complaints from multiple jurisdictions', () async {
        // Setup mock responses
        when(mockApiService.get('/officer-records/officer_123/jurisdictions'))
            .thenAnswer((_) async => {
              'jurisdictions': ['NYPD', 'LAPD', 'Chicago PD']
            });

        when(mockApiService.get('/officer-records/officer_123/complaints', any))
            .thenAnswer((invocation) async {
              final params = invocation.positionalArguments[1] as Map<String, dynamic>;
              final jurisdiction = params['jurisdiction'] as String;
              
              if (jurisdiction == 'NYPD') {
                return {
                  'complaints': [
                    {
                      'id': 'complaint_1',
                      'caseNumber': 'NYPD-2023-001',
                      'allegationType': 'excessive_force',
                      'description': 'Excessive force during arrest',
                      'dateReported': '2023-01-15T10:00:00Z',
                      'status': 'sustained',
                      'jurisdiction': 'NYPD',
                    }
                  ]
                };
              } else if (jurisdiction == 'LAPD') {
                return {
                  'complaints': [
                    {
                      'id': 'complaint_2',
                      'caseNumber': 'LAPD-2022-045',
                      'allegationType': 'misconduct',
                      'description': 'Professional misconduct',
                      'dateReported': '2022-08-20T14:30:00Z',
                      'status': 'not_sustained',
                      'jurisdiction': 'LAPD',
                    }
                  ]
                };
              }
              return {'complaints': []};
            });

        final complaints = await service.getComplaintHistory('officer_123');

        expect(complaints.length, equals(2));
        expect(complaints[0].caseNumber, equals('NYPD-2023-001')); // Most recent first
        expect(complaints[1].caseNumber, equals('LAPD-2022-045'));
        
        // Verify all jurisdictions were queried
        verify(mockApiService.get('/officer-records/officer_123/complaints', {'jurisdiction': 'NYPD'})).called(1);
        verify(mockApiService.get('/officer-records/officer_123/complaints', {'jurisdiction': 'LAPD'})).called(1);
        verify(mockApiService.get('/officer-records/officer_123/complaints', {'jurisdiction': 'Chicago PD'})).called(1);
      });

      test('should handle complaint retrieval errors gracefully', () async {
        when(mockApiService.get('/officer-records/officer_123/jurisdictions'))
            .thenAnswer((_) async => {'jurisdictions': ['NYPD']});

        when(mockApiService.get('/officer-records/officer_123/complaints', any))
            .thenThrow(Exception('API Error'));

        final complaints = await service.getComplaintHistory('officer_123');

        expect(complaints, isEmpty);
      });

      test('should deduplicate complaints from multiple sources', () async {
        when(mockApiService.get('/officer-records/officer_123/jurisdictions'))
            .thenAnswer((_) async => {'jurisdictions': ['NYPD']});

        // Return duplicate complaints
        when(mockApiService.get('/officer-records/officer_123/complaints', any))
            .thenAnswer((_) async => {
              'complaints': [
                {
                  'id': 'complaint_1',
                  'caseNumber': 'NYPD-2023-001',
                  'allegationType': 'excessive_force',
                  'description': 'Excessive force during arrest',
                  'dateReported': '2023-01-15T10:00:00Z',
                  'status': 'sustained',
                  'jurisdiction': 'NYPD',
                },
                {
                  'id': 'complaint_1_duplicate',
                  'caseNumber': 'NYPD-2023-001', // Same case number and date
                  'allegationType': 'excessive_force',
                  'description': 'Excessive force during arrest',
                  'dateReported': '2023-01-15T10:00:00Z',
                  'status': 'sustained',
                  'jurisdiction': 'NYPD',
                }
              ]
            });

        final complaints = await service.getComplaintHistory('officer_123');

        expect(complaints.length, equals(1)); // Duplicate should be removed
      });
    });

    group('Disciplinary Action Tracking', () {
      test('should retrieve disciplinary actions from multiple jurisdictions', () async {
        when(mockApiService.get('/officer-records/officer_123/jurisdictions'))
            .thenAnswer((_) async => {'jurisdictions': ['NYPD', 'LAPD']});

        when(mockApiService.get('/officer-records/officer_123/disciplinary-actions', any))
            .thenAnswer((invocation) async {
              final params = invocation.positionalArguments[1] as Map<String, dynamic>;
              final jurisdiction = params['jurisdiction'] as String;
              
              if (jurisdiction == 'NYPD') {
                return {
                  'actions': [
                    {
                      'id': 'action_1',
                      'actionType': 'suspension',
                      'description': '30-day suspension without pay',
                      'actionDate': '2023-02-01T00:00:00Z',
                      'duration': 30,
                      'jurisdiction': 'NYPD',
                    }
                  ]
                };
              }
              return {'actions': []};
            });

        final actions = await service.getDisciplinaryActions('officer_123');

        expect(actions.length, equals(1));
        expect(actions.first.actionType, equals('suspension'));
        expect(actions.first.duration, equals(30));
      });

      test('should sort disciplinary actions by date', () async {
        when(mockApiService.get('/officer-records/officer_123/jurisdictions'))
            .thenAnswer((_) async => {'jurisdictions': ['NYPD']});

        when(mockApiService.get('/officer-records/officer_123/disciplinary-actions', any))
            .thenAnswer((_) async => {
              'actions': [
                {
                  'id': 'action_1',
                  'actionType': 'reprimand',
                  'description': 'Written reprimand',
                  'actionDate': '2022-01-01T00:00:00Z',
                  'duration': null,
                  'jurisdiction': 'NYPD',
                },
                {
                  'id': 'action_2',
                  'actionType': 'suspension',
                  'description': 'Suspension',
                  'actionDate': '2023-01-01T00:00:00Z',
                  'duration': 10,
                  'jurisdiction': 'NYPD',
                }
              ]
            });

        final actions = await service.getDisciplinaryActions('officer_123');

        expect(actions.length, equals(2));
        expect(actions.first.actionDate.year, equals(2023)); // Most recent first
        expect(actions.last.actionDate.year, equals(2022));
      });
    });

    group('Career Timeline and Employment Gaps', () {
      test('should build career timeline with employment events', () async {
        when(mockApiService.get('/officer-records/officer_123/jurisdictions'))
            .thenAnswer((_) async => {'jurisdictions': ['NYPD', 'LAPD']});

        when(mockApiService.get('/officer-records/officer_123/employment', any))
            .thenAnswer((invocation) async {
              final params = invocation.positionalArguments[1] as Map<String, dynamic>;
              final jurisdiction = params['jurisdiction'] as String;
              
              if (jurisdiction == 'NYPD') {
                return {
                  'events': [
                    {
                      'date': '2020-01-01T00:00:00Z',
                      'eventType': 'hired',
                      'description': 'Hired as Police Officer',
                      'department': 'NYPD',
                      'jurisdiction': 'New York',
                    },
                    {
                      'date': '2022-12-31T00:00:00Z',
                      'eventType': 'resigned',
                      'description': 'Resigned from NYPD',
                      'department': 'NYPD',
                      'jurisdiction': 'New York',
                    }
                  ]
                };
              } else if (jurisdiction == 'LAPD') {
                return {
                  'events': [
                    {
                      'date': '2023-06-01T00:00:00Z',
                      'eventType': 'hired',
                      'description': 'Hired as Police Officer',
                      'department': 'LAPD',
                      'jurisdiction': 'California',
                    }
                  ]
                };
              }
              return {'events': []};
            });

        final timeline = await service.getCareerTimeline('officer_123');

        expect(timeline.events.length, greaterThan(2)); // Should include gap detection
        expect(timeline.departments, containsAll(['NYPD', 'LAPD']));
        expect(timeline.employmentGaps.isNotEmpty, isTrue); // Should detect gap between NYPD and LAPD
      });

      test('should detect employment gaps correctly', () async {
        when(mockApiService.get('/officer-records/officer_123/jurisdictions'))
            .thenAnswer((_) async => {'jurisdictions': ['Test PD']});

        when(mockApiService.get('/officer-records/officer_123/employment', any))
            .thenAnswer((_) async => {
              'events': [
                {
                  'date': '2020-01-01T00:00:00Z',
                  'eventType': 'hired',
                  'description': 'Hired',
                  'department': 'Test PD',
                },
                {
                  'date': '2020-06-01T00:00:00Z',
                  'eventType': 'resigned',
                  'description': 'Resigned',
                  'department': 'Test PD',
                },
                {
                  'date': '2021-01-01T00:00:00Z', // 7-month gap
                  'eventType': 'hired',
                  'description': 'Rehired',
                  'department': 'Test PD',
                }
              ]
            });

        final timeline = await service.getCareerTimeline('officer_123');

        final gaps = timeline.employmentGaps;
        expect(gaps.length, equals(1));
        expect(gaps.first.description, contains('gap'));
      });
    });

    group('Community Incident Reporting', () {
      test('should submit community incident report', () async {
        when(mockApiService.post('/officer-records/community-reports', any))
            .thenAnswer((_) async => {'success': true});

        await service.submitCommunityIncidentReport(
          officerId: 'officer_123',
          incidentType: 'excessive_force',
          description: 'Officer used excessive force during traffic stop',
          incidentDate: DateTime(2023, 6, 15),
          location: '123 Main St',
          witnesses: ['witness1', 'witness2'],
          evidence: ['video.mp4', 'photo.jpg'],
        );

        verify(mockApiService.post('/officer-records/community-reports', any)).called(1);
      });

      test('should invalidate cache after submitting report', () async {
        // First, populate cache
        when(mockApiService.get('/officer-records/officer_123/public-records'))
            .thenAnswer((_) async => {'name': 'John Doe'});
        when(mockApiService.get('/officer-records/officer_123/court-records'))
            .thenAnswer((_) async => {});
        when(mockApiService.get('/officer-records/officer_123/foia'))
            .thenAnswer((_) async => {});
        when(mockApiService.get('/officer-records/officer_123/community-reports'))
            .thenAnswer((_) async => {});
        when(mockApiService.get('/officer-records/officer_123/community-rating'))
            .thenAnswer((_) async => {'averageRating': 3.5, 'ratingCount': 10});
        when(mockApiService.get('/officer-records/officer_123/jurisdictions'))
            .thenAnswer((_) async => {'jurisdictions': ['Test PD']});
        when(mockApiService.get('/officer-records/officer_123/employment', any))
            .thenAnswer((_) async => {'events': []});

        // Get officer profile (should cache it)
        await service.getOfficer('officer_123');

        // Submit report
        when(mockApiService.post('/officer-records/community-reports', any))
            .thenAnswer((_) async => {'success': true});

        await service.submitCommunityIncidentReport(
          officerId: 'officer_123',
          incidentType: 'misconduct',
          description: 'Test incident',
          incidentDate: DateTime.now(),
        );

        // Get officer profile again (should make new API calls due to cache invalidation)
        await service.getOfficer('officer_123');

        // Verify API was called multiple times (once for initial load, once after cache invalidation)
        verify(mockApiService.get('/officer-records/officer_123/public-records')).called(2);
      });
    });

    group('Officer Search', () {
      test('should search officers by name', () async {
        when(mockApiService.get('/officer-records/search', any))
            .thenAnswer((_) async => {
              'officers': ['officer_1', 'officer_2', 'officer_3']
            });

        final results = await service.searchOfficersByName('John Doe');

        expect(results.length, equals(3));
        verify(mockApiService.get('/officer-records/search', {
          'name': 'John Doe',
          'jurisdiction': null,
        })).called(1);
      });

      test('should search officers by badge number', () async {
        when(mockApiService.get('/officer-records/search', any))
            .thenAnswer((_) async => {
              'officers': ['officer_123']
            });

        final results = await service.searchOfficersByBadge('12345', jurisdiction: 'NYPD');

        expect(results.length, equals(1));
        expect(results.first, equals('officer_123'));
        verify(mockApiService.get('/officer-records/search', {
          'badgeNumber': '12345',
          'jurisdiction': 'NYPD',
        })).called(1);
      });
    });

    group('Data Aggregation', () {
      test('should aggregate data from multiple sources', () async {
        // Setup mock responses for different data sources
        when(mockApiService.get('/officer-records/officer_123/public-records'))
            .thenAnswer((_) async => {
              'name': 'John Doe',
              'badgeNumber': '12345',
              'complaints': [
                {
                  'id': 'complaint_1',
                  'caseNumber': 'PUB-001',
                  'allegationType': 'excessive_force',
                  'description': 'Public records complaint',
                  'dateReported': '2023-01-01T00:00:00Z',
                  'status': 'sustained',
                  'jurisdiction': 'NYPD',
                }
              ]
            });

        when(mockApiService.get('/officer-records/officer_123/court-records'))
            .thenAnswer((_) async => {
              'complaints': [
                {
                  'id': 'complaint_2',
                  'caseNumber': 'COURT-001',
                  'allegationType': 'misconduct',
                  'description': 'Court records complaint',
                  'dateReported': '2023-02-01T00:00:00Z',
                  'status': 'not_sustained',
                  'jurisdiction': 'NYPD',
                }
              ]
            });

        when(mockApiService.get('/officer-records/officer_123/foia'))
            .thenAnswer((_) async => {});

        when(mockApiService.get('/officer-records/officer_123/community-reports'))
            .thenAnswer((_) async => {});

        when(mockApiService.get('/officer-records/officer_123/community-rating'))
            .thenAnswer((_) async => {'averageRating': 3.0, 'ratingCount': 5});

        when(mockApiService.get('/officer-records/officer_123/jurisdictions'))
            .thenAnswer((_) async => {'jurisdictions': ['NYPD']});

        when(mockApiService.get('/officer-records/officer_123/employment', any))
            .thenAnswer((_) async => {'events': []});

        final profile = await service.getOfficer('officer_123');

        expect(profile.name, equals('John Doe'));
        expect(profile.badgeNumber, equals('12345'));
        expect(profile.complaintRecords.length, equals(2)); // From both sources
        expect(profile.communityRating.averageRating, equals(3.0));
      });
    });

    group('Caching', () {
      test('should cache officer profiles', () async {
        when(mockApiService.get('/officer-records/officer_123/public-records'))
            .thenAnswer((_) async => {'name': 'John Doe'});
        when(mockApiService.get('/officer-records/officer_123/court-records'))
            .thenAnswer((_) async => {});
        when(mockApiService.get('/officer-records/officer_123/foia'))
            .thenAnswer((_) async => {});
        when(mockApiService.get('/officer-records/officer_123/community-reports'))
            .thenAnswer((_) async => {});
        when(mockApiService.get('/officer-records/officer_123/community-rating'))
            .thenAnswer((_) async => {'averageRating': 3.0, 'ratingCount': 5});
        when(mockApiService.get('/officer-records/officer_123/jurisdictions'))
            .thenAnswer((_) async => {'jurisdictions': ['NYPD']});
        when(mockApiService.get('/officer-records/officer_123/employment', any))
            .thenAnswer((_) async => {'events': []});

        // First call
        await service.getOfficer('officer_123');

        // Second call (should use cache)
        await service.getOfficer('officer_123');

        // Verify API was only called once
        verify(mockApiService.get('/officer-records/officer_123/public-records')).called(1);
      });

      test('should clear cache when requested', () async {
        when(mockApiService.get('/officer-records/officer_123/public-records'))
            .thenAnswer((_) async => {'name': 'John Doe'});
        when(mockApiService.get('/officer-records/officer_123/court-records'))
            .thenAnswer((_) async => {});
        when(mockApiService.get('/officer-records/officer_123/foia'))
            .thenAnswer((_) async => {});
        when(mockApiService.get('/officer-records/officer_123/community-reports'))
            .thenAnswer((_) async => {});
        when(mockApiService.get('/officer-records/officer_123/community-rating'))
            .thenAnswer((_) async => {'averageRating': 3.0, 'ratingCount': 5});
        when(mockApiService.get('/officer-records/officer_123/jurisdictions'))
            .thenAnswer((_) async => {'jurisdictions': ['NYPD']});
        when(mockApiService.get('/officer-records/officer_123/employment', any))
            .thenAnswer((_) async => {'events': []});

        // First call
        await service.getOfficer('officer_123');

        // Clear cache
        service.clearCache();

        // Second call (should make new API calls)
        await service.getOfficer('officer_123');

        // Verify API was called twice
        verify(mockApiService.get('/officer-records/officer_123/public-records')).called(2);
      });
    });
  });
}