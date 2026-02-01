part of 'documents_bloc.dart';

import '../../models/document_model.dart';

abstract class DocumentsState {}

class DocumentsInitial extends DocumentsState {}

class DocumentsReady extends DocumentsState {}

class DocumentsLoading extends DocumentsState {}

class DocumentsError extends DocumentsState {
  final String errorMessage;

  DocumentsError(this.errorMessage);
}

class DocumentsLoaded extends DocumentsState {
  final List<Document> documents;

  DocumentsLoaded(this.documents);
}

class DocumentShared extends DocumentsState {
  final String documentId;

  DocumentShared(this.documentId);
}

class DocumentsExpiryNotifications extends DocumentsState {
  final List<Document> expiringDocuments;

  DocumentsExpiryNotifications(this.expiringDocuments);
}