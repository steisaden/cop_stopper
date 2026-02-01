part of 'documents_bloc.dart';

import '../../models/document_model.dart';
import 'dart:io';

abstract class DocumentsEvent {}

class DocumentsInitialize extends DocumentsEvent {}

class LoadDocumentsRequested extends DocumentsEvent {}

class AddDocumentRequested extends DocumentsEvent {
  final Document document;
  final File file;

  AddDocumentRequested({
    required this.document,
    required this.file,
  });
}

class DeleteDocumentRequested extends DocumentsEvent {
  final String documentId;

  DeleteDocumentRequested(this.documentId);
}

class UpdateDocumentRequested extends DocumentsEvent {
  final Document document;

  UpdateDocumentRequested(this.document);
}

class ShareDocumentRequested extends DocumentsEvent {
  final String documentId;

  ShareDocumentRequested(this.documentId);
}

class AddDocumentNoteRequested extends DocumentsEvent {
  final String documentId;
  final String note;

  AddDocumentNoteRequested({
    required this.documentId,
    required this.note,
  });
}

class CheckExpiryNotificationsRequested extends DocumentsEvent {
  final int days;

  CheckExpiryNotificationsRequested({this.days = 30});
}