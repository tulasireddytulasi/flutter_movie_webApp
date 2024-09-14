import 'package:flutter/material.dart';
import 'package:moviewebapp/app/core/utils/assets_path.dart';
import 'package:moviewebapp/app/core/utils/colors.dart';

class UserCard extends StatelessWidget {
  const UserCard({
    Key? key,
    required this.picUrl,
    required this.name,
    required this.knownFor,
    required this.popularity,
    this.info,
    required this.gender,
  }) : super(key: key);

  final String picUrl;
  final String name;
  final String knownFor;
  final String gender;
  final String popularity;
  final String? info;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.width;
    return Card(
      color: pickledBlueWood,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10))),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: picUrl.isEmpty
                    ? Container(
                        width: 100,
                        height: 100,
                        color: WHITE,
                      )
                    : Hero(
                        tag: name,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.all(Radius.circular(10)),
                          child: picUrl.isNotEmpty
                              ? Image.network(
                                  picUrl,
                                  fit: BoxFit.cover,
                                  width: 100,
                                  height: 100,
                                )
                              : Image.asset(
                                  noProfilePic,
                                  fit: BoxFit.cover,
                                  width: 100,
                                  height: 100,
                                ),
                        ),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: size/2,
                      child: Text(
                        name,
                        softWrap: true,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          color: WHITE,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    RichText(
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 14,
                          color: WHITE,
                          fontWeight: FontWeight.normal,
                        ),
                        children: [
                          TextSpan(text: "$knownFor, "),
                          TextSpan(text: gender),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      popularity,
                      style: const TextStyle(
                        fontSize: 14,
                        color: WHITE,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          (info != null && info!.isNotEmpty)
              ? const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Divider(color: GREY, height: 1, thickness: 1),
                )
              : const SizedBox.shrink(),
          (info != null && info!.isNotEmpty)
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RichText(
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    maxLines: 5,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 14,
                        color: WHITE,
                        fontWeight: FontWeight.normal,
                      ),
                      children: [
                        const TextSpan(text: "Biography: "),
                        TextSpan(text: info),
                      ],
                    ),
                  ),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
