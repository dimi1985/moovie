import 'dart:developer';
import 'package:flutter/material.dart';
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

    _videoPlayerController = VideoPlayerController.network(
      widget.movie.videoUrl,
    );
    _subtitleController = SubtitleController(
      subtitleUrl: widget.movie.subtitleUrl,
      subtitleType: SubtitleType.srt,
    );

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      subtitle: Subtitles(_parseSubtitles()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.movie.name)),
      body: SubtitleWrapper(
        videoPlayerController: _videoPlayerController,
        subtitleController: _subtitleController,
        subtitleStyle: SubtitleStyle(
          textColor: Colors.white,
          hasBorder: true,
        ),
        videoChild: Chewie(
          controller: _chewieController,
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _videoPlayerController.dispose();
    _chewieController.dispose();
  }

  List<Subtitle> _parseSubtitles() {
    // Here you can fetch subtitles from the subtitleUrl and parse them
    // For simplicity, I'm returning an empty list
    return [];
  }
}
