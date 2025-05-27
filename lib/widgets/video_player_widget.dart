//lib/widgets/video_player_widget.dart

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String url;
  const VideoPlayerWidget({super.key, required this.url});

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _ctrl;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _ctrl = VideoPlayerController.networkUrl(Uri.parse(widget.url))
      ..initialize().then((_) {
        setState(() => _ready = true);
      });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _ready
        ? Stack(
            alignment: Alignment.bottomCenter,
            children: [
              VideoPlayer(_ctrl),
              VideoProgressIndicator(_ctrl, allowScrubbing: true),
              Center(
                child: IconButton(
                  icon: Icon(
                    _ctrl.value.isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    size: 56,
                    color: Colors.white70,
                  ),
                  onPressed: () {
                    setState(() {
                      _ctrl.value.isPlaying ? _ctrl.pause() : _ctrl.play();
                    });
                  },
                ),
              ),
            ],
          )
        : const Center(child: CircularProgressIndicator());
  }
}
