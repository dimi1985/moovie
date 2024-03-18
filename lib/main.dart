import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:movie_streaming_app/screens/video_player_screen.dart';

import 'models/movie.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late List<Movie> movies = [];

  @override
  void initState() {
    super.initState();
    fetchMovies();
  }

  Future<void> fetchMovies() async {
    final response =
        await http.get(Uri.parse('http://192.168.227.229:3000/movies'));
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
                'http://192.168.227.229:3000/movies/$movieNameEncoded/$movieNameEncoded.mp4',
            subtitleUrl:
                'http://192.168.227.229:3000/movies/$movieNameEncoded/subtitles',
          );
        }).toList();
      });
    } else {
      throw Exception('Failed to load movies');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Movie Streaming App',
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Movies'),
        ),
        body: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // Number of columns
            crossAxisSpacing: 8.0, // Spacing between columns
            mainAxisSpacing: 8.0, // Spacing between rows
          ),
          itemCount: movies.length,
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        VideoPlayerScreen(movie: movies[index]),
                  ),
                );
              },
              child: GridTile(
                footer: GridTileBar(
                  backgroundColor: Colors.black45,
                  title: Text(
                    movies[index].name,
                    textAlign: TextAlign.center,
                  ),
                ),
                child: Image.network(
                  'http://192.168.227.229:3000/movies/${Uri.encodeComponent(movies[index].name)}/poster',
                  fit: BoxFit.cover,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
