part of 'chatbot_bloc.dart';

import '../../models/legal_advice_model.dart';

abstract class ChatbotState {}

class ChatbotInitial extends ChatbotState {}

class ChatbotReady extends ChatbotState {}

class ChatbotLoading extends ChatbotState {}

class ChatbotError extends ChatbotState {
  final String errorMessage;

  ChatbotError(this.errorMessage);
}

class ChatbotSessionStarted extends ChatbotState {
  final String sessionId;

  ChatbotSessionStarted(this.sessionId);
}

class ChatbotMessageReceived extends ChatbotState {
  final LegalAdvice message;

  ChatbotMessageReceived(this.message);
}

class ChatbotLegalAdviceReceived extends ChatbotState {
  final LegalAdvice legalAdvice;

  ChatbotLegalAdviceReceived(this.legalAdvice);
}

class ChatbotHistoryReceived extends ChatbotState {
  final List<LegalAdvice> history;

  ChatbotHistoryReceived(this.history);
}

class ChatbotAdviceRated extends ChatbotState {
  final String adviceId;

  ChatbotAdviceRated(this.adviceId);
}