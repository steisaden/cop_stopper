part of 'officer_records_bloc.dart';

import '../../models/officer_record_model.dart';

abstract class OfficerRecordsState {}

class OfficerRecordsInitial extends OfficerRecordsState {}

class OfficerRecordsReady extends OfficerRecordsState {}

class OfficerRecordsLoading extends OfficerRecordsState {}

class OfficerRecordsError extends OfficerRecordsState {
  final String errorMessage;

  OfficerRecordsError(this.errorMessage);
}

class OfficerDetailsLoaded extends OfficerRecordsState {
  final OfficerRecord officer;

  OfficerDetailsLoaded(this.officer);
}