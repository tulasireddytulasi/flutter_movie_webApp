import 'package:moviewebapp/app/models/mcu_import_models.dart';
import 'package:moviewebapp/app/models/movie_editor_models.dart';

enum BulkMovieStatus { queued, fetching, ready, uploading, success, partial, failed }

extension BulkMovieStatusLabel on BulkMovieStatus {
  String get label {
    switch (this) {
      case BulkMovieStatus.queued:
        return 'Queued';
      case BulkMovieStatus.fetching:
        return 'Fetching';
      case BulkMovieStatus.ready:
        return 'Ready';
      case BulkMovieStatus.uploading:
        return 'Uploading';
      case BulkMovieStatus.success:
        return 'Success';
      case BulkMovieStatus.partial:
        return 'Partial';
      case BulkMovieStatus.failed:
        return 'Failed';
    }
  }
}

class BulkMovieSettings {
  const BulkMovieSettings({
    this.options = const McuImportOptions(),
    this.includePeople = true,
  });

  final McuImportOptions options;
  final bool includePeople;

  McuImportOptions get mappingOptions => McuImportOptions(
        castLimit: includePeople ? options.castLimit : 0,
        crewLimit: includePeople ? options.crewLimit : 0,
        franchise: options.normalizedFranchise,
      );
}

class BulkMovieEntry {
  BulkMovieEntry(this.id);

  final String id;
  Map<String, dynamic>? data;
  BulkMovieSettings? overrideSettings;
  BulkMovieStatus status = BulkMovieStatus.queued;
  String message = 'Waiting to fetch.';
  bool selected = true;
  McuMovieBundle? bundle;
  BulkMovieSettings? uploadSettings;
  bool movieVerified = false;
  final Set<String> verifiedGenres = {};
  final Set<String> verifiedCredits = {};
  final Map<String, PersonUploadResult> peopleResults = {};
  final Map<String, String> peopleNames = {};
  final List<String> warnings = [];

  String get title {
    final value = data?['title'];
    return value is String ? value : 'Movie $id';
  }

  String? get posterPath {
    final value = data?['poster_path'];
    return value is String && value.startsWith('/') && !value.startsWith('//') ? value : null;
  }

  bool get hasWrites => movieVerified || verifiedGenres.isNotEmpty || verifiedCredits.isNotEmpty;

  void resetUpload() {
    bundle = null;
    uploadSettings = null;
    movieVerified = false;
    verifiedGenres.clear();
    verifiedCredits.clear();
    peopleResults.clear();
    peopleNames.clear();
    warnings.clear();
    status = BulkMovieStatus.ready;
    message = 'Ready. Existing rows will be refreshed; no rows will be deleted.';
  }
}
