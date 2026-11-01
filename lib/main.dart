import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:moviewebapp/app/providers/actors_info_provider.dart';
import 'package:moviewebapp/app/providers/dashboard_provider.dart';
import 'package:moviewebapp/app/providers/movie_info_provider.dart';
import 'package:moviewebapp/app/providers/movies_provider.dart';
import 'package:moviewebapp/app/providers/navigation_provider.dart';
import 'package:moviewebapp/app/providers/universal_provider.dart';
import 'package:moviewebapp/app/theme/app_theme.dart';
import 'package:moviewebapp/app/views/navigation_menu/navigation_menu.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashBoardProvider()),
        ChangeNotifierProvider(create: (_) => MoviesProvider()),
        ChangeNotifierProvider(create: (_) => MovieInfoProvider()),
        ChangeNotifierProvider(create: (_) => ActorsInfoProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
        ChangeNotifierProvider(create: (_) => UniversalProvider()),
      ],
      child: MaterialApp(
        title: 'Movie Flutter Web App',
        debugShowCheckedModeBanner: false,
        scrollBehavior: MyCustomScrollBehavior(),
        theme: AppTheme.getLightTheme(),
        darkTheme: AppTheme.getDarkTheme(),
        themeMode: ThemeMode.dark,
        home: const NavigationMenu(),
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
