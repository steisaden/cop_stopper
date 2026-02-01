import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/officer_record_model.dart';
import '../../collaborative_monitoring/interfaces/officer_records_service.dart';
import '../../collaborative_monitoring/models/officer_profile.dart' as collaborative_models;
import '../../collaborative_monitoring/models/complaint_record.dart' as collaborative_models;
import '../../collaborative_monitoring/models/commendation.dart' as collaborative_models;

part 'officer_records_event.dart';
part 'officer_records_state.dart';

class OfficerRecordsBloc extends Bloc<OfficerRecordsEvent, OfficerRecordsState> {
  final OfficerRecordsService _officerRecordsService;

  OfficerRecordsBloc({required OfficerRecordsService officerRecordsService})
      : _officerRecordsService = officerRecordsService,
        super(OfficerRecordsInitial()) {
    on<OfficerRecordsInitialize>(_onInitialize);
    on<GetOfficerDetailsRequested>(_onGetOfficerDetails);
    on<AddOfficerNoteRequested>(_onAddOfficerNote);
  }

  Future<void> _onInitialize(
    OfficerRecordsInitialize event,
    Emitter<OfficerRecordsState> emit,
  ) async {
    emit(OfficerRecordsReady());
  }

  Future<void> _onGetOfficerDetails(
    GetOfficerDetailsRequested event,
    Emitter<OfficerRecordsState> emit,
  ) async {
    emit(OfficerRecordsLoading());
    
    try {
      final officerProfile = await _officerRecordsService.getOfficer(event.officerId);
      emit(OfficerDetailsLoaded(_convertToOfficerRecord(officerProfile)));
    } catch (e) {
      emit(OfficerRecordsError('Failed to get officer details: $e'));
    }
  }

  Future<void> _onAddOfficerNote(
    AddOfficerNoteRequested event,
    Emitter<OfficerRecordsState> emit,
  ) async {
    emit(OfficerRecordsLoading());
    
    try {
      // The interface doesn't support adding notes directly
      // This would need to be implemented in the service
      await _officerRecordsService.addEncounter(
        event.officerId,
        // Create an encounter record with the note as description
        Encounter(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          location: 'unknown',
          timestamp: DateTime.now(),
          description: event.note,
          outcome: 'note',
        ),
      );
      
      // Reload officer details after adding note
      add(GetOfficerDetailsRequested(event.officerId));
    } catch (e) {
      emit(OfficerRecordsError('Failed to add note: $e'));
    }
  }

  // Helper method to convert the collaborative model to the app's model
  OfficerRecord _convertToOfficerRecord(OfficerProfile profile) {
    return OfficerRecord(
      id: profile.id,
      name: profile.name,
      badgeNumber: profile.badgeNumber,
      department: profile.department,
      complaints: profile.complaintRecords.map(_convertComplaintRecord).toList(),
      commendations: profile.commendations.map(_convertCommendation).toList(),
      // For now, using default values for other required fields
      rank: '',
      yearsOfService: 0,
      lastUpdated: DateTime.now(),
      dataSource: 'External API',
      reliability: profile.communityRating.averageRating,
    );
  }
  
  // Helper method to convert ComplaintRecord
  ComplaintRecord _convertComplaintRecord(
      collaborative_models.ComplaintRecord profileComplaintRecord) {
    // Since the actual model is different, we'll create a basic mapping
    return ComplaintRecord(
      id: profileComplaintRecord.id,
      date: profileComplaintRecord.date,
      type: 'General', // Default type since the model is different
      description: profileComplaintRecord.description,
      status: profileComplaintRecord.status,
      outcome: 'Unknown', // Default outcome since the model is different
    );
  }
  
  // Helper method to convert CommendationRecord
  CommendationRecord _convertCommendation(
      collaborative_models.Commendation profileCommendation) {
    // Since the actual model is different, we'll create a basic mapping
    return CommendationRecord(
      id: profileCommendation.id,
      date: profileCommendation.date,
      type: profileCommendation.type,
      description: profileCommendation.description,
    );
  }
}