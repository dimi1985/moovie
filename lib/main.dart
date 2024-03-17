import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:video_player/video_player.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<Movie> movies = [];

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
                        VideoPlayerScreen(videoUrl: movies[index].videoUrl),
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

class Movie {
  final String name;
  final String videoUrl;

  Movie({required this.name, required this.videoUrl});
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerScreen({Key? key, required this.videoUrl}) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {
          _controller.play();
        });
      });
    log(widget.videoUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Movie Player')),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: VideoPlayer(_controller),
              )
            : CircularProgressIndicator(),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }
}
