import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

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

class Movie {
  final String name;
  final String videoUrl;
  final String subtitleUrl;

  Movie({
    required this.name,
    required this.videoUrl,
    required this.subtitleUrl,
  });
}

class VideoPlayerScreen extends StatefulWidget {
  final Movie movie;

  const VideoPlayerScreen({Key? key, required this.movie}) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  late ChewieController _chewieController =
      ChewieController(videoPlayerController: _controller);

  @override
  void initState() {
    super.initState();
    log(widget.movie.videoUrl);
    _initializeChewieController();
    _controller =
        VideoPlayerController.networkUrl(Uri.parse(widget.movie.videoUrl))
          ..initialize().then((_) {
            setState(() {
              _controller.play();
            });
          });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.movie.name)),
      body: Center(child: Chewie(controller: _chewieController)),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
    _chewieController.dispose();
  }

  void _initializeChewieController() async {
    final subtitlesResponse =
        await http.get(Uri.parse(widget.movie.subtitleUrl));
    if (subtitlesResponse.statusCode == 200) {
      final subtitles = subtitlesResponse.body;
      final parsedSubtitles = parseSubtitles(subtitles);
      log('Subtitltes : $parsedSubtitles');
      _chewieController = ChewieController(
          videoPlayerController: _controller,
          autoInitialize: true,
          autoPlay: true,
          looping: false,
          subtitle: Subtitles(parsedSubtitles),
          subtitleBuilder: (context, subtitle) => Container(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  subtitle,
                  style: const TextStyle(color: Colors.white),
                ),
              ));
    } else {
      throw Exception('Failed to load subtitles');
    }
  }

  List<Subtitle> parseSubtitles(String subtitles) {
    final List<Subtitle> parsedSubtitles = [];
    final List<String> lines = subtitles.split('\n');

    int index = 0;
    Duration startTime = Duration.zero;
    Duration endTime = Duration.zero;
    String text = '';

    for (String line in lines) {
      if (line.isEmpty) {
        if (text.isNotEmpty) {
          parsedSubtitles.add(Subtitle(
            index: index,
            start: startTime,
            end: endTime,
            text: text.trim(),
          ));
          text = '';
        }
      } else if (line.contains('-->')) {
        final times = line.split(' --> ');
        startTime = _parseDuration(times[0]);
        endTime = _parseDuration(times[1]);
      } else if (int.tryParse(line) != null) {
        index = int.parse(line);
      } else {
        text += '$line\n';
      }
    }

    return parsedSubtitles;
  }

  Duration _parseDuration(String time) {
    final parts = time.split(',');
    final hoursMinutesSeconds =
        parts[0].split(':').map((part) => int.parse(part)).toList();
    final milliseconds = int.parse(parts[1]);
    return Duration(
      hours: hoursMinutesSeconds[0],
      minutes: hoursMinutesSeconds[1],
      seconds: hoursMinutesSeconds[2],
      milliseconds: milliseconds,
    );
  }
}
