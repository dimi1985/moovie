import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:movie_streaming_app/models/movie.dart';
import 'package:movie_streaming_app/screens/video_player_screen.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class MovieDetail extends StatefulWidget {
  final Movie movie;

  const MovieDetail({Key? key, required this.movie}) : super(key: key);

  @override
  State<MovieDetail> createState() => _MovieDetailState();
}

class _MovieDetailState extends State<MovieDetail> {
  late VideoPlayerController videoPlayerController;
  late ChewieController chewieController;

  @override
  void initState() {
    super.initState();
    videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(widget.movie.trailerUrl),
    );
    chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
      errorBuilder: (context, errorMessage) {
        return Center(
          child: Text(
            !errorMessage.contains('Source Error')
                ? 'No movie trailer at this time'
                : '',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20.0,
            ),
          ),
        );
      },
      draggableProgressBar: false,
      autoPlay: true,
      looping: false,
      aspectRatio: 9 / 16,
      fullScreenByDefault: false,
      allowFullScreen: false,
      allowedScreenSleep: false,
    );
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    chewieController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white, // Change this color to your desired color
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          widget.movie.name,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          Stack(
            children: [
              Container(
                color: Colors.black,
                child: AspectRatio(
                  aspectRatio: 9 / 16,
                  child: Container(
                    foregroundDecoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.black,
                          Colors.transparent,
                          Colors.transparent,
                          Colors.black
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [0.2, 0.5, 1.0, 1.0],
                      ),
                    ),
                    child: Chewie(
                      controller: chewieController,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VideoPlayerScreen(
                      movie: widget.movie,
                    ),
                  ),
                );
              },
              child: const Text('Watch Movie'),
            ),
          ),
        ],
      ),
    );
  }
}
