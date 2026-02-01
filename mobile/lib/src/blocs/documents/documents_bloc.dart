import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/document_model.dart';
import '../../services/secure_document_service.dart';

part 'documents_event.dart';
part 'documents_state.dart';

class DocumentsBloc extends Bloc<DocumentsEvent, DocumentsState> {
  final SecureDocumentService _documentService;

  DocumentsBloc({required SecureDocumentService documentService})
      : _documentService = documentService,
        super(DocumentsInitial()) {
    on<DocumentsInitialize>(_onInitialize);
    on<LoadDocumentsRequested>(_onLoadDocuments);
    on<AddDocumentRequested>(_onAddDocument);
    on<DeleteDocumentRequested>(_onDeleteDocument);
    on<UpdateDocumentRequested>(_onUpdateDocument);
    on<ShareDocumentRequested>(_onShareDocument);
    on<AddDocumentNoteRequested>(_onAddDocumentNote);
    on<CheckExpiryNotificationsRequested>(_onCheckExpiryNotifications);
  }

  Future<void> _onInitialize(
    DocumentsInitialize event,
    Emitter<DocumentsState> emit,
  ) async {
    emit(DocumentsReady());
    
    // Load documents after initialization
    add(LoadDocumentsRequested());
  }

  Future<void> _onLoadDocuments(
    LoadDocumentsRequested event,
    Emitter<DocumentsState> emit,
  ) async {
    emit(DocumentsLoading());
    
    try {
      final documents = await _documentService.getAllDocuments();
      emit(DocumentsLoaded(documents));
    } catch (e) {
      emit(DocumentsError('Failed to load documents: $e'));
    }
  }

  Future<void> _onAddDocument(
    AddDocumentRequested event,
    Emitter<DocumentsState> emit,
  ) async {
    emit(DocumentsLoading());
    
    try {
      final result = await _documentService.addDocument(
        event.document,
        event.file,
      );
      
      if (result) {
        // Reload documents after adding
        add(LoadDocumentsRequested());
      } else {
        emit(DocumentsError('Failed to add document'));
      }
    } catch (e) {
      emit(DocumentsError('Failed to add document: $e'));
    }
  }

  Future<void> _onDeleteDocument(
    DeleteDocumentRequested event,
    Emitter<DocumentsState> emit,
  ) async {
    emit(DocumentsLoading());
    
    try {
      final result = await _documentService.deleteDocument(event.documentId);
      
      if (result) {
        // Reload documents after deletion
        add(LoadDocumentsRequested());
      } else {
        emit(DocumentsError('Failed to delete document'));
      }
    } catch (e) {
      emit(DocumentsError('Failed to delete document: $e'));
    }
  }

  Future<void> _onUpdateDocument(
    UpdateDocumentRequested event,
    Emitter<DocumentsState> emit,
  ) async {
    emit(DocumentsLoading());
    
    try {
      final result = await _documentService.updateDocument(event.document);
      
      if (result) {
        // Reload documents after update
        add(LoadDocumentsRequested());
      } else {
        emit(DocumentsError('Failed to update document'));
      }
    } catch (e) {
      emit(DocumentsError('Failed to update document: $e'));
    }
  }

  Future<void> _onShareDocument(
    ShareDocumentRequested event,
    Emitter<DocumentsState> emit,
  ) async {
    emit(DocumentsLoading());
    
    try {
      final result = await _documentService.shareDocument(event.documentId);
      
      if (result) {
        emit(DocumentShared(event.documentId));
      } else {
        emit(DocumentsError('Failed to share document'));
      }
    } catch (e) {
      emit(DocumentsError('Failed to share document: $e'));
    }
  }

  Future<void> _onAddDocumentNote(
    AddDocumentNoteRequested event,
    Emitter<DocumentsState> emit,
  ) async {
    emit(DocumentsLoading());
    
    try {
      final result = await _documentService.addNote(
        event.documentId,
        event.note,
      );
      
      if (result) {
        // Reload document after adding note
        add(LoadDocumentsRequested());
      } else {
        emit(DocumentsError('Failed to add note to document'));
      }
    } catch (e) {
      emit(DocumentsError('Failed to add note to document: $e'));
    }
  }

  Future<void> _onCheckExpiryNotifications(
    CheckExpiryNotificationsRequested event,
    Emitter<DocumentsState> emit,
  ) async {
    try {
      final expiringDocuments = await _documentService.checkExpiringDocuments(
        days: event.days,
      );
      
      emit(DocumentsExpiryNotifications(expiringDocuments));
    } catch (e) {
      emit(DocumentsError('Failed to check expiry notifications: $e'));
    }
  }
}