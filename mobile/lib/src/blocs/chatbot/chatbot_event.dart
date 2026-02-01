part of 'chatbot_bloc.dart';

abstract class ChatbotEvent {}

class ChatbotInitialize extends ChatbotEvent {}

class SendMessageRequested extends ChatbotEvent {
  final String sessionId;
  final String message;

  SendMessageRequested({
    required this.sessionId,
    required this.message,
  });
}

class GetLegalAdviceRequested extends ChatbotEvent {
  final String query;
  final String jurisdiction;

  GetLegalAdviceRequested({
    required this.query,
    required this.jurisdiction,
  });
}

class StartNewSessionRequested extends ChatbotEvent {}

class GetConversationHistoryRequested extends ChatbotEvent {
  final String sessionId;

  GetConversationHistoryRequested({required this.sessionId});
}

class RateAdviceRequested extends ChatbotEvent {
  final String adviceId;
  final int rating;
  final String? feedback;

  RateAdviceRequested({
    required this.adviceId,
    required this.rating,
    this.feedback,
  });
}