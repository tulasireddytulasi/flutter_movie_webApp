import 'dart:convert';

MovieBannerModel movieBannerModelFromJson(String str) => MovieBannerModel.fromJson(json.decode(str));

String movieBannerModelToJson(MovieBannerModel data) => json.encode(data.toJson());

class MovieBannerModel {
  List<MoviesList>? moviesList;

  MovieBannerModel({
    this.moviesList,
  });

  factory MovieBannerModel.fromJson(Map<String, dynamic> json) => MovieBannerModel(
        moviesList: json["moviesList"] == null
            ? []
            : List<MoviesList>.from(json["moviesList"]!.map((x) => MoviesList.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "moviesList": moviesList == null ? [] : List<dynamic>.from(moviesList!.map((x) => x.toJson())),
      };
}

class MoviesList {
  String? id;
  String? title;
  String? youTubeVideoKey;
  String? description;
  String? poster;
  String? backDrop;
  String? logo;
  List<String>? genre;

  MoviesList({
    this.id,
    this.title,
    this.youTubeVideoKey,
    this.description,
    this.poster,
    this.backDrop,
    this.logo,
    this.genre,
  });

  factory MoviesList.fromJson(Map<String, dynamic> json) => MoviesList(
        id: json["id"],
        title: json["title"],
        youTubeVideoKey: json["youTubeVideoKey"],
        description: json["description"],
        poster: json["poster"],
        backDrop: json["backDrop"],
        logo: json["logo"],
        genre: json["genre"] == null ? [] : List<String>.from(json["genre"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "youTubeVideoKey": youTubeVideoKey,
        "description": description,
        "poster": poster,
        "backDrop": backDrop,
        "logo": logo,
        "genre": genre == null ? [] : List<dynamic>.from(genre!.map((x) => x)),
      };
}
