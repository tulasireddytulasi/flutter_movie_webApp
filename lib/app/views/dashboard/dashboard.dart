import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:moviewebapp/app/views/dashboard/main_banner_widget/main_banner.dart';
import 'package:moviewebapp/app/views/dashboard/widgets/appwrite_movies_sections.dart';
import 'package:moviewebapp/app/views/dashboard/widgets/movie_label.dart';
import 'package:moviewebapp/app/views/dashboard/widgets/movies_list.dart';
import 'package:moviewebapp/app/providers/dashboard_provider.dart';
import 'package:moviewebapp/app/core/utils/common_functions.dart';
import 'package:provider/provider.dart';
import 'main_banner_widget/main_banner.dart';
import 'package:moviewebapp/app/views/widgets/movies_card.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  late DashBoardProvider dashBoardProvider;
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    dashBoardProvider = Provider.of<DashBoardProvider>(context, listen: false);
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    /// Update the state based on scroll position
    _isScrolled = _scrollController.position.pixels >= 100;
    if (_isScrolled) {
      dashBoardProvider.setAppBarColorAndElevation(
        color: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1.0,
      );
    } else {
      dashBoardProvider.setAppBarColorAndElevation(
        color: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0.0,
      );
    }
  }

  // Todo: Will remove later
  void showAlert() {
    showCustomSnackBar(
      context: context,
      message: 'Opps!, This is not available!',
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: NotificationListener<ScrollNotification>(
        onNotification: (scrollNotification) {
          return true;
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MainBanner(),
              // const MovieBannerCard(),
              const AppwriteMoviesSections(),
            ],
          ),
        ),
      ),
    );
  }
}
