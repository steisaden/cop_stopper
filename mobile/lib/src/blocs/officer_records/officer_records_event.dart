part of 'officer_records_bloc.dart';

abstract class OfficerRecordsEvent {}

class OfficerRecordsInitialize extends OfficerRecordsEvent {}

class GetOfficerDetailsRequested extends OfficerRecordsEvent {
  final String officerId;

  GetOfficerDetailsRequested(this.officerId);
}

class AddOfficerNoteRequested extends OfficerRecordsEvent {
  final String officerId;
  final String note;

  AddOfficerNoteRequested({
    required this.officerId,
    required this.note,
  });
}