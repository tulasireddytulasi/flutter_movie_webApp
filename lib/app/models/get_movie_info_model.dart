// To parse this JSON data, do
//
//     final getMovieInfo = getMovieInfoFromJson(jsonString);

import 'dart:convert';

GetMovieInfo getMovieInfoFromJson(String str) =>
    GetMovieInfo.fromJson(json.decode(str));

String getMovieInfoToJson(GetMovieInfo data) => json.encode(data.toJson());

class GetMovieInfo {
  GetMovieInfo({
    this.adult,
    this.backdropPath,
    this.belongsToCollection,
    this.budget,
    this.genres,
    this.homepage,
    this.id,
    this.imdbId,
    this.originalLanguage,
    this.originalTitle,
    this.overview,
    this.popularity,
    this.posterPath,
    this.productionCompanies,
    this.productionCountries,
    this.releaseDate,
    this.revenue,
    this.runtime,
    this.spokenLanguages,
    this.status,
    this.tagline,
    this.title,
    this.video,
    this.voteAverage,
    this.voteCount,
    this.credits,
  });

  bool? adult;
  String? backdropPath;
  Map<String, dynamic>? belongsToCollection;
  int? budget;
  List<Genre>? genres;
  String? homepage;
  int? id;
  String? imdbId;
  String? originalLanguage;
  String? originalTitle;
  String? overview;
  double? popularity;
  String? posterPath;
  List<ProductionCompany>? productionCompanies;
  List<ProductionCountry>? productionCountries;
  String? releaseDate;
  int? revenue;
  int? runtime;
  List<SpokenLanguage>? spokenLanguages;
  String? status;
  String? tagline;
  String? title;
  bool? video;
  double? voteAverage;
  int? voteCount;
  Credits? credits;

  factory GetMovieInfo.fromJson(Map<String, dynamic> json) => GetMovieInfo(
        adult: json["adult"],
        backdropPath: json["backdrop_path"],
        belongsToCollection: json["belongs_to_collection"],
        budget: json["budget"],
        genres: json["genres"] == null
            ? null
            : List<Genre>.from(json["genres"].map((x) => Genre.fromJson(x))),
        homepage: json["homepage"],
        id: json["id"],
        imdbId: json["imdb_id"],
        originalLanguage: json["original_language"],
        originalTitle: json["original_title"],
        overview: json["overview"],
        popularity: json["popularity"],
        posterPath: json["poster_path"],
        productionCompanies: json["production_companies"] == null
            ? null
            : List<ProductionCompany>.from(json["production_companies"]
                .map((x) => ProductionCompany.fromJson(x))),
        productionCountries: json["production_countries"] == null
            ? null
            : List<ProductionCountry>.from(json["production_countries"]
                .map((x) => ProductionCountry.fromJson(x))),
        releaseDate: json["release_date"],
        revenue: json["revenue"],
        runtime: json["runtime"],
        spokenLanguages: json["spoken_languages"] == null
            ? null
            : List<SpokenLanguage>.from(json["spoken_languages"]
                .map((x) => SpokenLanguage.fromJson(x))),
        status: json["status"],
        tagline: json["tagline"],
        title: json["title"],
        video: json["video"],
        voteAverage: json["vote_average"],
        voteCount: json["vote_count"],
        credits:
            json["credits"] == null ? null : Credits.fromJson(json["credits"]),
      );

  Map<String, dynamic> toJson() => {
        "adult": adult,
        "backdrop_path": backdropPath,
        "belongs_to_collection": belongsToCollection,
        "budget": budget,
        "genres": genres == null
            ? null
            : List<dynamic>.from(genres!.map((x) => x.toJson())),
        "homepage": homepage,
        "id": id,
        "imdb_id": imdbId,
        "original_language": originalLanguage,
        "original_title": originalTitle,
        "overview": overview,
        "popularity": popularity,
        "poster_path": posterPath,
        "production_companies": productionCompanies == null
            ? null
            : List<dynamic>.from(productionCompanies!.map((x) => x.toJson())),
        "production_countries": productionCountries == null
            ? null
            : List<dynamic>.from(productionCountries!.map((x) => x.toJson())),
        "release_date": releaseDate,
        "revenue": revenue,
        "runtime": runtime,
        "spoken_languages": spokenLanguages == null
            ? null
            : List<dynamic>.from(spokenLanguages!.map((x) => x.toJson())),
        "status": status,
        "tagline": tagline,
        "title": title,
        "video": video,
        "vote_average": voteAverage,
        "vote_count": voteCount,
        "credits": credits == null ? null : credits!.toJson(),
      };
}

class Credits {
  Credits({
    this.cast,
    this.crew,
  });

  List<Cast>? cast;
  List<Cast>? crew;

  factory Credits.fromJson(Map<String, dynamic> json) => Credits(
        cast: json["cast"] == null
            ? null
            : List<Cast>.from(json["cast"].map((x) => Cast.fromJson(x))),
        crew: json["crew"] == null
            ? null
            : List<Cast>.from(json["crew"].map((x) => Cast.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "cast": cast == null
            ? null
            : List<dynamic>.from(cast!.map((x) => x.toJson())),
        "crew": crew == null
            ? null
            : List<dynamic>.from(crew!.map((x) => x.toJson())),
      };
}

class Cast {
  Cast({
    this.adult,
    this.gender,
    this.id,
    this.knownForDepartment,
    this.name,
    this.originalName,
    this.popularity,
    this.profilePath,
    this.castId,
    this.character,
    this.creditId,
    this.order,
    this.department,
    this.job,
  });

  bool? adult;
  int? gender;
  int? id;
  String? knownForDepartment;
  String? name;
  String? originalName;
  double? popularity;
  String? profilePath;
  int? castId;
  String? character;
  String? creditId;
  int? order;
  String? department;
  String? job;

  factory Cast.fromJson(Map<String, dynamic> json) => Cast(
        adult: json["adult"],
        gender: json["gender"],
        id: json["id"],
        knownForDepartment: json["known_for_department"],
        name: json["name"],
        originalName: json["original_name"],
        popularity: json["popularity"] ?? 0.0,
        profilePath: json["profile_path"],
        castId: json["cast_id"],
        character: json["character"],
        creditId: json["credit_id"],
        order: json["order"],
        department: json["department"],
        job: json["job"],
      );

  Map<String, dynamic> toJson() => {
        "adult": adult,
        "gender": gender,
        "id": id,
        "known_for_department": knownForDepartment,
        "name": name,
        "original_name": originalName,
        "popularity": popularity,
        "profile_path": profilePath,
        "cast_id": castId,
        "character": character,
        "credit_id": creditId,
        "order": order,
        "department": department,
        "job": job,
      };
}

class Genre {
  Genre({
    this.id,
    this.name,
  });

  int? id;
  String? name;

  factory Genre.fromJson(Map<String, dynamic> json) => Genre(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
      };
}

class ProductionCompany {
  ProductionCompany({
    this.id,
    this.logoPath,
    this.name,
    this.originCountry,
  });

  int? id;
  String? logoPath;
  String? name;
  String? originCountry;

  factory ProductionCompany.fromJson(Map<String, dynamic> json) =>
      ProductionCompany(
        id: json["id"],
        logoPath: json["logo_path"],
        name: json["name"],
        originCountry: json["origin_country"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "logo_path": logoPath,
        "name": name,
        "origin_country": originCountry,
      };
}

class ProductionCountry {
  ProductionCountry({
    this.iso31661,
    this.name,
  });

  String? iso31661;
  String? name;

  factory ProductionCountry.fromJson(Map<String, dynamic> json) =>
      ProductionCountry(
        iso31661: json["iso_3166_1"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "iso_3166_1": iso31661,
        "name": name,
      };
}

class SpokenLanguage {
  SpokenLanguage({
    this.englishName,
    this.iso6391,
    this.name,
  });

  String? englishName;
  String? iso6391;
  String? name;

  factory SpokenLanguage.fromJson(Map<String, dynamic> json) => SpokenLanguage(
        englishName: json["english_name"],
        iso6391: json["iso_639_1"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {
        "english_name": englishName,
        "iso_639_1": iso6391,
        "name": name,
      };
}
