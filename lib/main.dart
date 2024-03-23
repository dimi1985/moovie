// ignore_for_file: library_private_types_in_public_api

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:movie_streaming_app/screens/movie_detail.dart';

import 'models/movie.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late List<Movie> movies = [];

  @override
  void initState() {
    super.initState();
    fetchMovies();

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
  }

  Future<void> fetchMovies() async {
    final response =
        await http.get(Uri.parse('http://192.168.66.229:3000/movies'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);

      // List of folder names to exclude
      List<String> excludedFolders = [
        '.thumbnails',
        'Movies'
      ]; // Add your folder names here
      setState(() {
        // Filter out excluded folder names
        movies = data
            .where((movieName) => !excludedFolders.contains(movieName))
            .map((movieName) {
          String movieNameEncoded = Uri.encodeComponent(movieName);
          return Movie(
            name: movieName,
            videoUrl:
                'http://192.168.66.229:3000/movies/$movieNameEncoded/$movieNameEncoded.mp4',
            subtitleUrl:
                'http://192.168.66.229:3000/movies/$movieNameEncoded/subtitles',
            trailerUrl:
                'http://192.168.66.229:3000/movies/$movieNameEncoded/trailer',
          );
        }).toList();
      });
    } else {
      throw Exception('Failed to load movies');
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Movie Streaming App',
      home: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          centerTitle: true,
          title: const Text(
            'Movies',
            style: TextStyle(color: Colors.white),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(top: 30),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Number of columns
              crossAxisSpacing: 8.0, // Spacing between columns
              mainAxisSpacing: 32.0, // Spacing between rows
            ),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MovieDetail(movie: movies[index]),
                    ),
                  );
                },
                child: GridTile(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                        10), // Adjust the radius as needed
                    child: Image.network(
                      'http://192.168.66.229:3000/movies/${Uri.encodeComponent(movies[index].name)}/poster',
                      width: 110.0,
                      height: 110.0,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
