import 'dart:convert';

import 'package:moviewebapp/app/models/mcu_import_models.dart';

enum MovieEditorFieldType { text, integer, decimal, boolean, date, json }

class MovieEditorField {
  const MovieEditorField(this.key, this.label, this.type, {this.required = false, this.multiline = false});

  final String key;
  final String label;
  final MovieEditorFieldType type;
  final bool required;
  final bool multiline;

  String display(dynamic value) {
    if (value == null) return '';
    return type == MovieEditorFieldType.json ? const JsonEncoder.withIndent('  ').convert(value) : value.toString();
  }

  dynamic parse(String input) {
    final trimmed = input.trim();
    if (trimmed.isEmpty) {
      if (required) throw McuImportException('$label is required.');
      return null;
    }
    switch (type) {
      case MovieEditorFieldType.integer:
        final number = int.tryParse(trimmed);
        if (number == null) {
          throw McuImportException('$label must be a whole number.');
        }
        return number;
      case MovieEditorFieldType.decimal:
        final number = double.tryParse(trimmed);
        if (number == null || !number.isFinite) {
          throw McuImportException('$label must be a finite number.');
        }
        return number;
      case MovieEditorFieldType.boolean:
        if (trimmed != 'true' && trimmed != 'false') {
          throw McuImportException('$label must be true or false.');
        }
        return trimmed == 'true';
      case MovieEditorFieldType.json:
        try {
          return jsonDecode(input);
        } on FormatException {
          throw McuImportException('$label must be valid JSON.');
        }
      case MovieEditorFieldType.date:
        return trimmed;
      case MovieEditorFieldType.text:
        return key == 'franchise' ? trimmed : input;
    }
  }
}

const movieEditorFields = [
  MovieEditorField('title', 'Title', MovieEditorFieldType.text, required: true),
  MovieEditorField('original_title', 'Original title', MovieEditorFieldType.text),
  MovieEditorField('overview', 'Overview', MovieEditorFieldType.text, multiline: true),
  MovieEditorField('tagline', 'Tagline', MovieEditorFieldType.text),
  MovieEditorField('release_date', 'Release date (YYYY-MM-DD)', MovieEditorFieldType.date),
  MovieEditorField('runtime', 'Runtime (minutes)', MovieEditorFieldType.integer),
  MovieEditorField('budget', 'Budget', MovieEditorFieldType.integer),
  MovieEditorField('revenue', 'Revenue', MovieEditorFieldType.integer),
  MovieEditorField('status', 'Status', MovieEditorFieldType.text),
  MovieEditorField('adult', 'Adult (true / false)', MovieEditorFieldType.boolean, required: true),
  MovieEditorField('popularity', 'Popularity', MovieEditorFieldType.decimal, required: true),
  MovieEditorField('vote_average', 'Vote average', MovieEditorFieldType.decimal, required: true),
  MovieEditorField('vote_count', 'Vote count', MovieEditorFieldType.integer, required: true),
  MovieEditorField('poster_path', 'Poster path (relative)', MovieEditorFieldType.text),
  MovieEditorField('backdrop_path', 'Backdrop path (relative)', MovieEditorFieldType.text),
  MovieEditorField('franchise', 'Franchise (optional)', MovieEditorFieldType.text),
  MovieEditorField('genres', 'Genres (JSON array of id/name objects)', MovieEditorFieldType.json,
      required: true, multiline: true),
];

class MovieCreditPerson {
  const MovieCreditPerson({required this.id, required this.name, required this.details});

  final String id;
  final String name;
  final String details;
}

enum PersonUploadStatus { pending, uploading, success, failed, alreadyExists }

extension PersonUploadStatusLabel on PersonUploadStatus {
  String get label {
    switch (this) {
      case PersonUploadStatus.pending:
        return 'Not uploaded';
      case PersonUploadStatus.uploading:
        return 'Uploading';
      case PersonUploadStatus.success:
        return 'Success';
      case PersonUploadStatus.failed:
        return 'Failed';
      case PersonUploadStatus.alreadyExists:
        return 'Already Exists';
    }
  }
}

class PersonUploadResult {
  const PersonUploadResult(this.status, this.message);

  final PersonUploadStatus status;
  final String message;
}
