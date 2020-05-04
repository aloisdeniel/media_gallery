import 'dart:io';

import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:media_gallery/media_gallery.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:video_player/video_player.dart';

class MediaViewerPage extends StatelessWidget {
  final Media media;

  const MediaViewerPage({
    @required this.media,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(media.id),
      ),
      body: media.mediaType == MediaType.image
          ? MediaImagePlayer(
              media: media,
            )
          : MediaVideoPlayer(
              media: media,
            ),
    );
  }
}

class MediaImagePlayer extends StatefulWidget {
  final Media media;

  const MediaImagePlayer({
    @required this.media,
  });

  @override
  _MediaImagePlayerState createState() => _MediaImagePlayerState();
}

class _MediaImagePlayerState extends State<MediaImagePlayer> {
  File file;
  Map<String, IfdTag> exif;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initAsync();
    });
    super.initState();
  }

  Future<void> initAsync() async {
    try {
      this.file = await widget.media.getFile();
      this.exif = await readExifFromBytes(await this.file.readAsBytes());
      this.setState(() {});
    } catch (e) {
      print("Failed : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Expanded(
          child: FadeInImage(
            fit: BoxFit.cover,
            placeholder: MemoryImage(kTransparentImage),
            image: MediaImageProvider(
              media: widget.media,
            ),
          ),
        ),
        SizedBox(
          height: 200,
          child: SingleChildScrollView(
            child: Text("$exif"),
          ),
        )
      ],
    );
  }
}

class MediaVideoPlayer extends StatefulWidget {
  final Media media;

  const MediaVideoPlayer({
    @required this.media,
  });

  @override
  _MediaVideoPlayerState createState() => _MediaVideoPlayerState();
}

class _MediaVideoPlayerState extends State<MediaVideoPlayer> {
  VideoPlayerController _controller;
  File _file;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initAsync();
    });
    super.initState();
  }

  Future<void> initAsync() async {
    try {
      _file = await widget.media.getFile();
      _controller = VideoPlayerController.file(_file)
        ..initialize().then((_) {
          // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
          setState(() {});
        });
    } catch (e) {
      print("Failed : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return _controller != null && _controller.value.initialized
        ? Column(
            children: <Widget>[
              Expanded(
                child: AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: VideoPlayer(_controller),
                ),
              ),
              RaisedButton(
                onPressed: () {
                  setState(() {
                    _controller.value.isPlaying
                        ? _controller.pause()
                        : _controller.play();
                  });
                },
                child: Icon(
                  _controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                ),
              )
            ],
          )
        : Container();
  }
}
