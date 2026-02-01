import 'package:get_it/get_it.dart';
import 'package:mobile/src/services/encryption_service.dart';
import 'package:mobile/src/services/secure_document_service.dart';
import 'package:mobile/src/services/location_service.dart';
import 'package:mobile/src/services/gps_location_service.dart';
import 'package:mobile/src/services/jurisdiction_resolver.dart';
import 'package:mobile/src/services/location_permission_service.dart';
import 'package:mobile/src/services/location_boundary_service.dart';
import 'package:mobile/src/services/recording_service_interface.dart';
import 'package:mobile/src/services/storage_service.dart';
import 'package:mobile/src/services/navigation_service.dart';
import 'package:mobile/src/services/transcription_service_web.dart';
import 'package:mobile/src/services/transcription_service_interface.dart';
import 'package:mobile/src/services/recording_service_web.dart';
import 'package:mobile/src/services/api_service.dart';
import 'package:mobile/src/collaborative_monitoring/services/api_service.dart' as collaborative;
import 'package:mobile/src/collaborative_monitoring/interfaces/screen_sharing_service.dart';
import 'package:mobile/src/collaborative_monitoring/interfaces/session_management_service.dart';
import 'package:mobile/src/collaborative_monitoring/interfaces/officer_records_service.dart';
import 'package:mobile/src/collaborative_monitoring/services/screen_sharing_service_stub.dart';
import 'package:mobile/src/collaborative_monitoring/services/session_management_service_impl.dart';
import 'package:mobile/src/collaborative_monitoring/services/officer_records_service_impl.dart';
import 'package:mobile/src/collaborative_monitoring/services/collaborative_session_manager.dart';
import 'package:mobile/src/collaborative_monitoring/services/real_time_collaboration_service.dart';
import 'package:mobile/src/collaborative_monitoring/services/emergency_escalation_service.dart';
import 'package:mobile/src/services/webhook_service.dart';
import 'package:mobile/src/services/jurisdiction_mapping_service.dart';
import 'package:mobile/src/services/data_compliance_service.dart';
import 'package:mobile/src/models/data_retention_policy.dart';
import 'package:mobile/src/services/notification_service.dart';
import 'package:mobile/src/services/emergency_contact_service.dart';
import 'package:mobile/src/services/police_conduct_database_service.dart';
import 'package:mobile/src/services/real_police_api_service.dart';
import 'package:mobile/src/services/chatbot_service.dart';
import 'package:mobile/src/services/production_officer_records_service.dart';
import 'package:mobile/src/services/history_service.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  // Register real services here
  locator.registerLazySingleton<EncryptionService>(() => EncryptionService());
  locator.registerLazySingleton<SecureDocumentService>(() => SecureDocumentService());
  locator.registerLazySingleton<JurisdictionResolver>(() => JurisdictionResolver());
  locator.registerLazySingleton<LocationService>(() => GPSLocationService());
  locator.registerLazySingleton<LocationPermissionService>(() => LocationPermissionService());
  locator.registerLazySingleton<LocationBoundaryService>(() => LocationBoundaryService(locator<LocationService>()));
  locator.registerLazySingleton<StorageService>(() => StorageService());
  
  // Register HistoryService with dependencies
  locator.registerLazySingleton<HistoryService>(() => HistoryService(locator<StorageService>()));
  
  locator.registerLazySingleton<NavigationService>(() => NavigationService());

  // Register web-compatible RecordingService
  locator.registerLazySingleton<RecordingService>(() => WebRecordingService(
    locator<StorageService>(),
  ));

  // Register API service
  locator.registerLazySingleton(() => ApiService());
  
  // Register notification service
  locator.registerLazySingleton<NotificationService>(() => NotificationService());
  
  // Register emergency contact service
  locator.registerLazySingleton<EmergencyContactService>(() => EmergencyContactService(locator<LocationService>()));
  
  // Register web-compatible transcription service
  locator.registerLazySingleton<TranscriptionServiceInterface>(() => WebTranscriptionService(
    locator<ApiService>(),
    locator<RecordingService>(),
  ));
  
  // Register police conduct database service
  locator.registerLazySingleton<PoliceConductDatabaseService>(() => PoliceConductDatabaseService(
    encryptionService: locator<EncryptionService>(),
    storageService: locator<StorageService>(),
  ));
  
  // Register real police API service
  locator.registerLazySingleton<RealPoliceApiService>(() => RealPoliceApiService());
  
  // Register collaboration services
  locator.registerLazySingleton<RealTimeCollaborationService>(() => RealTimeCollaborationService());
  locator.registerLazySingleton<EmergencyEscalationService>(() => EmergencyEscalationService(
    locator<EmergencyContactService>(),
    locator<NotificationService>(),
  ));
  
  locator.registerLazySingleton<ScreenSharingService>(() => ScreenSharingServiceStub());
  locator.registerLazySingleton<SessionManagementService>(() => SessionManagementServiceImpl());
  locator.registerLazySingleton<collaborative.ApiService>(() => collaborative.ApiService());
  locator.registerLazySingleton<OfficerRecordsService>(() => OfficerRecordsServiceImpl(locator<collaborative.ApiService>()));
  
  // Register compliance-related services
  locator.registerLazySingleton<DataRetentionPolicy>(() => DataRetentionPolicy.publicRecordsDefault());
  locator.registerLazySingleton<DataComplianceService>(() => DataComplianceService(
    retentionPolicy: locator<DataRetentionPolicy>(),
  ));
  locator.registerLazySingleton<WebhookService>(() => WebhookServiceFactory.getInstance());
  locator.registerLazySingleton<JurisdictionMappingService>(() => JurisdictionMappingService());

  // Register collaborative session manager with web transcription service
  locator.registerLazySingleton<CollaborativeSessionManager>(() => CollaborativeSessionManager(
    locator<ScreenSharingService>(),
    locator<NotificationService>(),
    locator<RealTimeCollaborationService>(),
    locator<EmergencyEscalationService>(),
    locator<TranscriptionServiceInterface>(),
  ));
  
  // Register new Phase 1 services
  locator.registerLazySingleton<ChatbotService>(() => ChatbotService(
    apiService: locator<ApiService>(),
    baseUrl: ApiService.baseUrl, // Use the static base URL from ApiService
  ));
  
  locator.registerLazySingleton<ProductionOfficerRecordsService>(() => ProductionOfficerRecordsService(
    jurisdictionService: locator<JurisdictionMappingService>(),
    complianceService: locator<DataComplianceService>(),
    webhookService: locator<WebhookService>(),
  ));
}