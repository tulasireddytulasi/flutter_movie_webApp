import 'dart:convert';

PopularActorsModel popularActorsModelFromJson(String str) =>
    PopularActorsModel.fromJson(json.decode(str));

String popularActorsModelToJson(PopularActorsModel data) =>
    json.encode(data.toJson());

class PopularActorsModel {
  PopularActorsModel({
    this.page,
    this.actors,
    this.totalPages,
    this.totalResults,
  });

  int? page;
  List<Actors>? actors;
  int? totalPages;
  int? totalResults;

  factory PopularActorsModel.fromJson(Map<String, dynamic> json) =>
      PopularActorsModel(
        page: json["page"],
        actors: json["results"] == null
            ? null
            : List<Actors>.from(json["results"].map((x) => Actors.fromJson(x))),
        totalPages: json["total_pages"],
        totalResults: json["total_results"],
      );

  Map<String, dynamic> toJson() => {
        "page": page,
        "results": actors == null
            ? null
            : List<dynamic>.from(actors!.map((x) => x.toJson())),
        "total_pages": totalPages,
        "total_results": totalResults,
      };
}

class Actors {
  Actors({
    this.adult,
    this.gender,
    this.id,
    this.knownFor,
    this.knownForDepartment,
    this.name,
    this.popularity,
    this.profilePath,
  });

  bool? adult;
  int? gender;
  int? id;
  List<KnownFor>? knownFor;
  String? knownForDepartment;
  String? name;
  double? popularity;
  String? profilePath;

  factory Actors.fromJson(Map<String, dynamic> json) => Actors(
        adult: json["adult"],
        gender: json["gender"],
        id: json["id"],
        knownFor: json["known_for"] == null
            ? null
            : List<KnownFor>.from(
                json["known_for"].map((x) => KnownFor.fromJson(x))),
        knownForDepartment: json["known_for_department"],
        name: json["name"],
        popularity: json["popularity"].toDouble(),
        profilePath: json["profile_path"],
      );

  Map<String, dynamic> toJson() => {
        "adult": adult,
        "gender": gender,
        "id": id,
        "known_for": knownFor == null
            ? null
            : List<dynamic>.from(knownFor!.map((x) => x.toJson())),
        "known_for_department": knownForDepartment,
        "name": name,
        "popularity": popularity,
        "profile_path": profilePath,
      };
}

class KnownFor {
  KnownFor({
    this.adult,
    this.backdropPath,
    this.genreIds,
    this.id,
    this.mediaType,
    this.originalLanguage,
    this.originalTitle,
    this.overview,
    this.posterPath,
    this.releaseDate,
    this.title,
    this.video,
    this.voteAverage,
    this.voteCount,
    this.firstAirDate,
    this.name,
    this.originCountry,
    this.originalName,
  });

  bool? adult;
  String? backdropPath;
  List<int>? genreIds;
  int? id;
  String? mediaType;
  String? originalLanguage;
  String? originalTitle;
  String? overview;
  String? posterPath;
  DateTime? releaseDate;
  String? title;
  bool? video;
  double? voteAverage;
  int? voteCount;
  DateTime? firstAirDate;
  String? name;
  List<String>? originCountry;
  String? originalName;

  factory KnownFor.fromJson(Map<String, dynamic> json) => KnownFor(
        adult: json["adult"],
        backdropPath: json["backdrop_path"],
        genreIds: json["genre_ids"] == null
            ? null
            : List<int>.from(json["genre_ids"].map((x) => x)),
        id: json["id"],
        mediaType: json["media_type"],
        originalLanguage: json["original_language"],
        originalTitle: json["original_title"],
        overview: json["overview"],
        posterPath: json["poster_path"],
        releaseDate: json["release_date"] == null
            ? null
            : DateTime.parse(json["release_date"]),
        title: json["title"],
        video: json["video"],
        voteAverage: json["vote_average"].toDouble(),
        voteCount: json["vote_count"],
        firstAirDate: json["first_air_date"] == null
            ? null
            : DateTime.parse(json["first_air_date"]),
        name: json["name"],
        originCountry: json["origin_country"] == null
            ? null
            : List<String>.from(json["origin_country"].map((x) => x)),
        originalName: json["original_name"],
      );

  Map<String, dynamic> toJson() => {
        "adult": adult,
        "backdrop_path": backdropPath,
        "genre_ids": genreIds == null
            ? null
            : List<dynamic>.from(genreIds!.map((x) => x)),
        "id": id,
        "media_type": mediaType,
        "original_language": originalLanguage,
        "original_title": originalTitle,
        "overview": overview,
        "poster_path": posterPath,
        "release_date": releaseDate == null
            ? null
            : "${releaseDate!.year.toString().padLeft(4, '0')}-${releaseDate!.month.toString().padLeft(2, '0')}-${releaseDate!.day.toString().padLeft(2, '0')}",
        "title": title,
        "video": video,
        "vote_average": voteAverage,
        "vote_count": voteCount,
        "first_air_date": firstAirDate == null
            ? null
            : "${firstAirDate!.year.toString().padLeft(4, '0')}-${firstAirDate!.month.toString().padLeft(2, '0')}-${firstAirDate!.day.toString().padLeft(2, '0')}",
        "name": name,
        "origin_country": originCountry == null
            ? null
            : List<String>.from(originCountry!.map((x) => x)),
        "original_name": originalName,
      };
}
