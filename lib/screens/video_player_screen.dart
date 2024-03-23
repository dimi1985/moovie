import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:movie_streaming_app/models/movie.dart';
import 'package:subtitle_wrapper_package/data/models/style/subtitle_style.dart';
import 'package:subtitle_wrapper_package/subtitle_controller.dart';
import 'package:subtitle_wrapper_package/subtitle_wrapper.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoPlayerScreen extends StatefulWidget {
  final Movie movie;

  const VideoPlayerScreen({Key? key, required this.movie}) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  late SubtitleController _subtitleController;

  @override
  void initState() {
    super.initState();

    _videoPlayerController = VideoPlayerController.networkUrl(
      Uri.parse(widget.movie.videoUrl),
    );
    _subtitleController = SubtitleController(
        subtitleUrl: widget.movie.subtitleUrl,
        subtitleType: SubtitleType.srt,
        showSubtitles: true);

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      aspectRatio: 16 / 9,
      fullScreenByDefault: false,
      allowFullScreen: false,
      allowedScreenSleep: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lock screen orientation to landscape mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        iconTheme: const IconThemeData(
          color: Colors.white, // Change this color to your desired color
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Colors.black,
      body: SubtitleWrapper(
        videoPlayerController: _videoPlayerController,
        subtitleController: _subtitleController,
        subtitleStyle: const SubtitleStyle(
          textColor: Colors.white,
          hasBorder: true,
        ),
        videoChild: SizedBox(
          child: Chewie(
            controller: _chewieController,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    // Unlock screen orientation when exiting
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _videoPlayerController.dispose();
    _chewieController.dispose();
  }
}
