import 'package:flutter/material.dart';
import 'package:moviewebapp/pages/movie_info_screen/movie_info.dart';
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
      ],
      child: MaterialApp(
        title: 'Movie Flutter Web App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const MovieInfoScreen(),
      ),
    );
  }
}
