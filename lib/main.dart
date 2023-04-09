import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:moviewebapp/pages/all_actors_page/all_actors_page.dart';
import 'package:moviewebapp/pages/navigation_menu/navigation_menu.dart';
import 'package:moviewebapp/providers/actors_info_provider.dart';
import 'package:moviewebapp/providers/dashboard_provider.dart';
import 'package:moviewebapp/providers/movie_info_provider.dart';
import 'package:moviewebapp/providers/movies_provider.dart';
import 'package:moviewebapp/providers/navigation_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  final MaterialColor mainAppColor =
      const MaterialColor(0xFF89cfbe, <int, Color>{
    50: Color(0xFF1B2230),
    100: Color(0xE61B2230),
    200: Color(0xCC1B2230),
    300: Color(0xB31B2230),
    400: Color(0x991B2230),
    500: Color(0x801B2230),
    600: Color(0x661B2230),
    700: Color(0x4D1B2230),
    800: Color(0x331B2230),
    900: Color(0x001B2230),
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DashBoardProvider()),
        ChangeNotifierProvider(create: (_) => MoviesProvider()),
        ChangeNotifierProvider(create: (_) => MovieInfoProvider()),
        ChangeNotifierProvider(create: (_) => ActorsInfoProvider()),
        ChangeNotifierProvider(create: (_) => NavigationProvider()),
      ],
      child: MaterialApp(
        title: 'Movie Flutter Web App',
        debugShowCheckedModeBanner: false,
        scrollBehavior: MyCustomScrollBehavior(),
        theme: ThemeData(
          primarySwatch: mainAppColor,
        ),
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
