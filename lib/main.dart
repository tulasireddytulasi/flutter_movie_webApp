import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:moviewebapp/pages/all_movies_screen/all_movies_screen.dart';
import 'package:moviewebapp/providers/movie_info_provider.dart';
import 'package:moviewebapp/providers/movies_provider.dart';
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
        ChangeNotifierProvider(create: (_) => MoviesProvider()),
        ChangeNotifierProvider(create: (_) => MovieInfoProvider()),
      ],
      child: MaterialApp(
        title: 'Movie Flutter Web App',
        debugShowCheckedModeBanner: false,
        scrollBehavior: MyCustomScrollBehavior(),
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MovieHomePage(),
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
