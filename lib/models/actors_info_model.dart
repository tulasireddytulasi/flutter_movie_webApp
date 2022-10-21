import 'dart:convert';

ActorInfoModel actorInfoModelFromJson(String str) =>
    ActorInfoModel.fromJson(json.decode(str));

String actorInfoModelToJson(ActorInfoModel data) => json.encode(data.toJson());

class ActorInfoModel {
  ActorInfoModel({
    this.adult,
    this.alsoKnownAs,
    this.biography,
    this.birthday,
    this.deathday,
    this.gender,
    this.homepage,
    this.id,
    this.imdbId,
    this.knownForDepartment,
    this.name,
    this.placeOfBirth,
    this.popularity,
    this.profilePath,
  });

  bool? adult;
  List<String>? alsoKnownAs;
  String? biography;
  DateTime? birthday;
  dynamic? deathday;
  int? gender;
  dynamic? homepage;
  int? id;
  String? imdbId;
  String? knownForDepartment;
  String? name;
  String? placeOfBirth;
  double? popularity;
  String? profilePath;

  factory ActorInfoModel.fromJson(Map<String, dynamic> json) => ActorInfoModel(
        adult: json["adult"] == null ? null : json["adult"],
        alsoKnownAs: json["also_known_as"] == null
            ? null
            : List<String>.from(json["also_known_as"].map((x) => x)),
        biography: json["biography"] == null ? null : json["biography"],
        birthday:
            json["birthday"] == null ? null : DateTime.parse(json["birthday"]),
        deathday: json["deathday"],
        gender: json["gender"] == null ? null : json["gender"],
        homepage: json["homepage"],
        id: json["id"] == null ? null : json["id"],
        imdbId: json["imdb_id"] == null ? null : json["imdb_id"],
        knownForDepartment: json["known_for_department"] == null
            ? null
            : json["known_for_department"],
        name: json["name"] == null ? null : json["name"],
        placeOfBirth:
            json["place_of_birth"] == null ? null : json["place_of_birth"],
        popularity:
            json["popularity"] == null ? null : json["popularity"].toDouble(),
        profilePath: json["profile_path"] == null ? null : json["profile_path"],
      );

  Map<String, dynamic> toJson() => {
        "adult": adult == null ? null : adult,
        "also_known_as": alsoKnownAs == null
            ? null
            : List<dynamic>.from(alsoKnownAs!.map((x) => x)),
        "biography": biography == null ? null : biography,
        "birthday": birthday == null
            ? null
            : "${birthday!.year.toString().padLeft(4, '0')}-${birthday!.month.toString().padLeft(2, '0')}-${birthday!.day.toString().padLeft(2, '0')}",
        "deathday": deathday,
        "gender": gender == null ? null : gender,
        "homepage": homepage,
        "id": id == null ? null : id,
        "imdb_id": imdbId == null ? null : imdbId,
        "known_for_department":
            knownForDepartment == null ? null : knownForDepartment,
        "name": name == null ? null : name,
        "place_of_birth": placeOfBirth == null ? null : placeOfBirth,
        "popularity": popularity == null ? null : popularity,
        "profile_path": profilePath == null ? null : profilePath,
      };
}
