import 'dart:convert';

MovieLogosAndPostersModel movieLogosAndPostersModelFromJson(String str) => MovieLogosAndPostersModel.fromJson(json.decode(str));

String movieLogosAndPostersModelToJson(MovieLogosAndPostersModel data) => json.encode(data.toJson());

class MovieLogosAndPostersModel {
  List<Backdrop>? backdrops;
  int? id;
  List<Backdrop>? logos;
  List<Backdrop>? posters;

  MovieLogosAndPostersModel({
    this.backdrops,
    this.id,
    this.logos,
    this.posters,
  });

  factory MovieLogosAndPostersModel.fromJson(Map<String, dynamic> json) => MovieLogosAndPostersModel(
        backdrops: json["backdrops"] == null ? [] : List<Backdrop>.from(json["backdrops"]!.map((x) => Backdrop.fromJson(x))),
        id: json["id"],
        logos: json["logos"] == null ? [] : List<Backdrop>.from(json["logos"]!.map((x) => Backdrop.fromJson(x))),
        posters: json["posters"] == null ? [] : List<Backdrop>.from(json["posters"]!.map((x) => Backdrop.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "backdrops": backdrops == null ? [] : List<dynamic>.from(backdrops!.map((x) => x.toJson())),
        "id": id,
        "logos": logos == null ? [] : List<dynamic>.from(logos!.map((x) => x.toJson())),
        "posters": posters == null ? [] : List<dynamic>.from(posters!.map((x) => x.toJson())),
      };
}

class Backdrop {
  double? aspectRatio;
  int? height;
  String? iso6391;
  String? filePath;
  double? voteAverage;
  int? voteCount;
  int? width;

  Backdrop({
    this.aspectRatio,
    this.height,
    this.iso6391,
    this.filePath,
    this.voteAverage,
    this.voteCount,
    this.width,
  });

  factory Backdrop.fromJson(Map<String, dynamic> json) => Backdrop(
        aspectRatio: json["aspect_ratio"]?.toDouble(),
        height: json["height"],
        iso6391: json["iso_639_1"],
        filePath: json["file_path"],
        voteAverage: json["vote_average"]?.toDouble(),
        voteCount: json["vote_count"],
        width: json["width"],
      );

  Map<String, dynamic> toJson() => {
        "aspect_ratio": aspectRatio,
        "height": height,
        "iso_639_1": iso6391,
        "file_path": filePath,
        "vote_average": voteAverage,
        "vote_count": voteCount,
        "width": width,
      };
}
