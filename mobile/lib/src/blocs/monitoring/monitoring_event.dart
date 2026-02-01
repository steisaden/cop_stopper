import 'package:equatable/equatable.dart';
import '../../models/transcription_segment_model.dart';
import '../../models/fact_check_result_model.dart';
import '../../models/monitoring_session_model.dart';

/// Events for the monitoring BLoC
abstract class MonitoringEvent extends Equatable {
  const MonitoringEvent();

  @override
  List<Object?> get props => [];
}

/// Start monitoring session
class StartMonitoring extends MonitoringEvent {
  const StartMonitoring();
}

/// Stop monitoring session
class StopMonitoring extends MonitoringEvent {
  const StopMonitoring();
}

/// Add new transcription segment
class AddTranscriptionSegment extends MonitoringEvent {
  final TranscriptionSegment segment;

  const AddTranscriptionSegment(this.segment);

  @override
  List<Object?> get props => [segment];
}

/// Update existing transcription segment
class UpdateTranscriptionSegment extends MonitoringEvent {
  final TranscriptionSegment segment;

  const UpdateTranscriptionSegment(this.segment);

  @override
  List<Object?> get props => [segment];
}

/// Clear all transcription segments
class ClearTranscription extends MonitoringEvent {
  const ClearTranscription();
}

/// Toggle auto-scroll functionality
class ToggleAutoScroll extends MonitoringEvent {
  const ToggleAutoScroll();
}

/// Set speaker label for identification
class SetSpeakerLabel extends MonitoringEvent {
  final String speakerId;
  final String label;

  const SetSpeakerLabel(this.speakerId, this.label);

  @override
  List<Object?> get props => [speakerId, label];
}

/// Update transcription confidence threshold
class UpdateConfidenceThreshold extends MonitoringEvent {
  final double threshold;

  const UpdateConfidenceThreshold(this.threshold);

  @override
  List<Object?> get props => [threshold];
}

/// Add fact-check result
class AddFactCheckResult extends MonitoringEvent {
  final FactCheckResult result;

  const AddFactCheckResult(this.result);

  @override
  List<Object?> get props => [result];
}

/// Add legal alert
class AddLegalAlert extends MonitoringEvent {
  final LegalAlert alert;

  const AddLegalAlert(this.alert);

  @override
  List<Object?> get props => [alert];
}

/// Clear all fact-check results
class ClearFactCheckResults extends MonitoringEvent {
  const ClearFactCheckResults();
}

/// Clear all legal alerts
class ClearLegalAlerts extends MonitoringEvent {
  const ClearLegalAlerts();
}

/// Flag an incident during monitoring
class FlagIncident extends MonitoringEvent {
  final String description;
  final String? segmentId;

  const FlagIncident(this.description, {this.segmentId});

  @override
  List<Object?> get props => [description, segmentId];
}

/// Request legal help
class RequestLegalHelp extends MonitoringEvent {
  final String reason;
  final String? contactInfo;

  const RequestLegalHelp(this.reason, {this.contactInfo});

  @override
  List<Object?> get props => [reason, contactInfo];
}

/// Contact emergency services
class ContactEmergency extends MonitoringEvent {
  final String reason;
  final String? location;

  const ContactEmergency(this.reason, {this.location});

  @override
  List<Object?> get props => [reason, location];
}

/// Generate session report
class GenerateReport extends MonitoringEvent {
  const GenerateReport();
}

/// Add session event
class AddSessionEvent extends MonitoringEvent {
  final SessionEvent event;

  const AddSessionEvent(this.event);

  @override
  List<Object?> get props => [event];
}

/// Request to run fact check on current transcription
class FactCheckRequested extends MonitoringEvent {
  const FactCheckRequested();
}
