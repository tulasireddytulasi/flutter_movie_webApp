import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:moviewebapp/app/core/routing/app_router.dart';
import 'package:moviewebapp/app/providers/actors_info_provider.dart';
import 'package:moviewebapp/app/providers/dashboard_provider.dart';
import 'package:moviewebapp/app/providers/movie_info_provider.dart';
import 'package:moviewebapp/app/providers/movies_provider.dart';
import 'package:moviewebapp/app/providers/navigation_provider.dart';
import 'package:moviewebapp/app/providers/people_provider.dart';
import 'package:moviewebapp/app/providers/universal_provider.dart';
import 'package:moviewebapp/app/theme/app_theme.dart';
import 'package:provider/provider.dart';

void main() {
  usePathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<PeopleProvider>(create: (_) => PeopleProvider()),
        ChangeNotifierProvider(create: (_) => DashBoardProvider()),
        ChangeNotifierProvider(create: (_) => MoviesProvider()),
        ChangeNotifierProvider(create: (_) => MovieInfoProvider()),
        ChangeNotifierProvider(create: (_) => ActorsInfoProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => UniversalProvider()),
      ],
      child: MaterialApp.router(
        title: 'Movie Flutter Web App',
        debugShowCheckedModeBanner: false,
        scrollBehavior: MyCustomScrollBehavior(),
        theme: AppTheme.getLightTheme(),
        darkTheme: AppTheme.getDarkTheme(),
        themeMode: ThemeMode.dark,
        routerConfig: appRouter,
      ),
    );
  }
}

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  // Override behavior methods and getters like dragDevices
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}
