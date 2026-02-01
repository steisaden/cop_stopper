import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/legal_advice_model.dart';
import '../../services/chatbot_service.dart';

part 'chatbot_event.dart';
part 'chatbot_state.dart';

class ChatbotBloc extends Bloc<ChatbotEvent, ChatbotState> {
  final ChatbotService _chatbotService;

  ChatbotBloc({required ChatbotService chatbotService})
      : _chatbotService = chatbotService,
        super(ChatbotInitial()) {
    on<ChatbotInitialize>(_onInitialize);
    on<SendMessageRequested>(_onSendMessage);
    on<GetLegalAdviceRequested>(_onGetLegalAdvice);
    on<StartNewSessionRequested>(_onStartNewSession);
    on<GetConversationHistoryRequested>(_onGetConversationHistory);
    on<RateAdviceRequested>(_onRateAdvice);
  }

  Future<void> _onInitialize(
    ChatbotInitialize event,
    Emitter<ChatbotState> emit,
  ) async {
    emit(ChatbotReady());
  }

  Future<void> _onSendMessage(
    SendMessageRequested event,
    Emitter<ChatbotState> emit,
  ) async {
    emit(ChatbotLoading());
    
    try {
      final response = await _chatbotService.sendMessage(
        event.sessionId,
        event.message,
      );
      
      if (response.isSuccess) {
        emit(ChatbotMessageReceived(response.data!));
      } else {
        emit(ChatbotError(response.errorMessage!));
      }
    } catch (e) {
      emit(ChatbotError('Failed to send message: $e'));
    }
  }

  Future<void> _onGetLegalAdvice(
    GetLegalAdviceRequested event,
    Emitter<ChatbotState> emit,
  ) async {
    emit(ChatbotLoading());
    
    try {
      final response = await _chatbotService.getLegalAdvice(
        event.query,
        event.jurisdiction,
      );
      
      if (response.isSuccess) {
        emit(ChatbotLegalAdviceReceived(response.data!));
      } else {
        emit(ChatbotError(response.errorMessage!));
      }
    } catch (e) {
      emit(ChatbotError('Failed to get legal advice: $e'));
    }
  }

  Future<void> _onStartNewSession(
    StartNewSessionRequested event,
    Emitter<ChatbotState> emit,
  ) async {
    emit(ChatbotLoading());
    
    try {
      final response = await _chatbotService.startNewSession();
      
      if (response.isSuccess) {
        emit(ChatbotSessionStarted(response.data!));
      } else {
        emit(ChatbotError(response.errorMessage!));
      }
    } catch (e) {
      emit(ChatbotError('Failed to start new session: $e'));
    }
  }

  Future<void> _onGetConversationHistory(
    GetConversationHistoryRequested event,
    Emitter<ChatbotState> emit,
  ) async {
    emit(ChatbotLoading());
    
    try {
      final response = await _chatbotService.getConversationHistory(
        event.sessionId,
      );
      
      if (response.isSuccess) {
        emit(ChatbotHistoryReceived(response.data!));
      } else {
        emit(ChatbotError(response.errorMessage!));
      }
    } catch (e) {
      emit(ChatbotError('Failed to get conversation history: $e'));
    }
  }

  Future<void> _onRateAdvice(
    RateAdviceRequested event,
    Emitter<ChatbotState> emit,
  ) async {
    emit(ChatbotLoading());
    
    try {
      final response = await _chatbotService.rateAdvice(
        event.adviceId,
        event.rating,
        event.feedback,
      );
      
      if (response.isSuccess) {
        emit(ChatbotAdviceRated(event.adviceId));
      } else {
        emit(ChatbotError(response.errorMessage!));
      }
    } catch (e) {
      emit(ChatbotError('Failed to rate advice: $e'));
    }
  }
}