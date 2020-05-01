import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:media_gallery/media_gallery.dart';

class MediaThumbnailImage extends StatefulWidget {
  final Media media;

  const MediaThumbnailImage({
    @required this.media,
  });

  @override
  _MediaThumbnailState createState() => _MediaThumbnailState();
}

class _MediaThumbnailState extends State<MediaThumbnailImage> {
  List<int> bytes;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initAsync();
    });
    super.initState();
  }

  Future<void> initAsync() async {
    try {
      this.bytes = await widget.media.getThumbnail();
      this.setState(() {});
    } catch (e) {
      print("Failed : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (bytes == null)
      return Container(
        width: 128,
        height: 128,
        color: Colors.grey,
      );
    return SizedBox(
      width: 128,
      height: 128,
      child: Image.memory(
        bytes,
        fit: BoxFit.cover,
      ),
    );
  }
}
