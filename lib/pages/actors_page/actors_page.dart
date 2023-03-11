import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:moviewebapp/pages/actors_page/widgets/ActorMoviesWidget.dart';
import 'package:moviewebapp/pages/actors_page/widgets/actors_Images_widget.dart';
import 'package:moviewebapp/pages/actors_page/widgets/lable_widget.dart';
import 'package:moviewebapp/providers/actors_info_provider.dart';
import 'package:moviewebapp/responses/api_constants.dart';
import 'package:moviewebapp/utils/colors.dart';
import 'package:moviewebapp/utils/commom_functions.dart';
import 'package:provider/provider.dart';

class ActorsPage extends StatefulWidget {
  final String actorId;
  const ActorsPage({Key? key, required this.actorId}) : super(key: key);

  @override
  _ActorsPageState createState() => _ActorsPageState();
}

class _ActorsPageState extends State<ActorsPage> {
  final ScrollController scrollController = ScrollController();
  final List<String> _actors = [
    "/oasuXFD9P9e4agQqppsqsiXSCoi.jpg",
    "/728rlT3uW8qzXSxa0sWGhkOvE7X.jpg",
    "/svYrIUXH59Dd9wp9HBpS1ASvRAu.jpg",
    "/l1QSwcXC25xOaTHoSFGsLMayaoe.jpg"
  ];

  @override
  void initState() {
    super.initState();
    final actorsInfoProvider =
        Provider.of<ActorsInfoProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      actorsInfoProvider.getActorsInfoAPI(actorId: widget.actorId);
      actorsInfoProvider.getActorsImagesAPI(actorId: widget.actorId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final double _screenWidth = MediaQuery.of(context).size.width;
    final bool _webView = _screenWidth >= 600;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: tealishBlue,
        elevation: 1,
        leading: InkWell(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: Container(
            padding: const EdgeInsets.all(2),
            margin: const EdgeInsets.all(10),
            child: const Icon(
              Icons.arrow_back,
              color: WHITE,
            ),
          ),
        ),
        // actions: [
        //   InkWell(
        //     onTap: () {
        //       Navigator.of(context).pop();
        //     },
        //     child: Container(
        //       decoration: BoxDecoration(
        //           border: Border.all(color: BLACK, width: 2),
        //           shape: BoxShape.circle,
        //           color: BLACK),
        //       padding: const EdgeInsets.all(2),
        //       margin: const EdgeInsets.all(10),
        //       child: const Icon(
        //         Icons.clear,
        //         color: WHITE,
        //       ),
        //     ),
        //   ),
        // ],
        title: const Text(
          "Actors Screen",
          style: TextStyle(fontSize: 18, color: WHITE),
        ),
      ),
      body: SafeArea(
        child: Consumer<ActorsInfoProvider>(
            builder: (context, actorsInfoProvider, child) {
          final double _pageWidth =
              getBottomSheetWidth(screenWidth: _screenWidth) + 30;
          return SingleChildScrollView(
            controller: scrollController,
            child: Center(
              child: Container(
                // alignment: Alignment.bottomCenter,
                width: _pageWidth,
                margin: EdgeInsets.only(
                  top: _screenWidth >= 600 ? 50 : 0,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(_webView ? 20 : 0),
                    topLeft: Radius.circular(_webView ? 20 : 0),
                  ),
                  color: tealishBlue,
                  shape: BoxShape.rectangle,
                ),
                child: Column(
                  //  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Visibility(
                      visible: false, //_webView ? true : false,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(2),
                              margin: const EdgeInsets.all(10),
                              child: const Icon(
                                Icons.arrow_back,
                                color: WHITE,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  border: Border.all(color: BLACK, width: 2),
                                  shape: BoxShape.circle,
                                  color: BLACK),
                              padding: const EdgeInsets.all(2),
                              margin: const EdgeInsets.all(10),
                              child: const Icon(
                                Icons.clear,
                                color: WHITE,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(5),
                            child: actorsInfoProvider.profilePic != ""
                                ? Image.network(
                                    ApiConstants.movieImageBaseUrlw500 +
                                        actorsInfoProvider.profilePic,
                                    height: getProfileImageSize(
                                        screenSize: _screenWidth),
                                    width: getProfileImageSize(
                                        screenSize: _screenWidth),
                                    fit: BoxFit.cover,
                                  )
                                : Container(),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: _pageWidth / 2,
                              // decoration: BoxDecoration(
                              //   border: Border.all(color: WHITE, width: 1),
                              // ),
                              margin: const EdgeInsets.only(left: 0, top: 20),
                              child: Text(
                                actorsInfoProvider.actorName,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 4,
                                style: const TextStyle(
                                    fontSize: 18,
                                    color: WHITE,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.only(
                                      left: 0, right: 5, top: 10, bottom: 0),
                                  child: const Icon(
                                    Icons.map,
                                    color: GREY,
                                  ),
                                ),
                                Container(
                                  // decoration: BoxDecoration(
                                  //   border: Border.all(color: WHITE, width: 1),
                                  // ),
                                  margin:
                                      const EdgeInsets.only(left: 0, top: 10),
                                  child: RichText(
                                    softWrap: true,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 4,
                                    text: const TextSpan(children: [
                                      TextSpan(
                                        text: "20",
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: WHITE,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      TextSpan(
                                        text: " movies",
                                        style: TextStyle(
                                            fontSize: 18,
                                            color: WHITE,
                                            fontWeight: FontWeight.normal),
                                      ),
                                    ]),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: 55,
                              // decoration: BoxDecoration(
                              //   border: Border.all(color: WHITE, width: 1),
                              // ),
                              margin: const EdgeInsets.only(left: 0, top: 10),
                              child: Text(
                                actorsInfoProvider.role,
                                softWrap: true,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 4,
                                style: const TextStyle(
                                    fontSize: 18,
                                    color: WHITE,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Divider(
                      height: 1,
                      color: GREY.withOpacity(0.5),
                      thickness: 1,
                    ),
                    Container(
                      // decoration: BoxDecoration(
                      //   border: Border.all(color: WHITE, width: 1),
                      // ),
                      padding: const EdgeInsets.only(
                          left: 0, right: 0, top: 10, bottom: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.only(left: 20, right: 5),
                            child: const Icon(
                              Icons.map,
                              color: GREY,
                            ),
                          ),
                          Container(
                            // decoration: BoxDecoration(
                            //   border: Border.all(color: WHITE, width: 1),
                            // ),
                            width: _pageWidth / 1.3,
                            child: RichText(
                              softWrap: true,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 4,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: actorsInfoProvider.dob,
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: WHITE,
                                        fontWeight: FontWeight.normal),
                                  ),
                                  TextSpan(
                                    text:
                                        " in ${actorsInfoProvider.birthPlace}",
                                    style: const TextStyle(
                                        fontSize: 14,
                                        color: WHITE,
                                        fontWeight: FontWeight.normal),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: _pageWidth / 1,
                      decoration: BoxDecoration(
                        // border: Border.all(color: WHITE, width: 1),
                        color: GREY.withOpacity(0.1),
                      ),
                      padding: const EdgeInsets.only(
                          left: 20, top: 20, right: 10, bottom: 15),
                      child: Text(
                        actorsInfoProvider.biography,
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 120,
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                            fontSize: 14,
                            color: WHITE,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    const LabelWidget(label: "Actor Pics"),
                    Container(
                      height: getSimilarMoviesSectionHeight(
                          screenSize: _screenWidth),
                      margin: const EdgeInsets.only(top: 0, left: 10),
                      child: ActorsImages(),
                    ),
                    const LabelWidget(label: "Known For"),
                    Container(
                      height: getSimilarMoviesSectionHeight(
                          screenSize: _screenWidth),
                      margin: const EdgeInsets.only(top: 0, left: 10),
                      child: ActorMoviesWidget(actorId: widget.actorId),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
