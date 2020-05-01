import 'dart:io';

import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:media_gallery/media_gallery.dart';

class MediaPage extends StatefulWidget {
  final Media media;

  const MediaPage({
    @required this.media,
  });

  @override
  _MediaTPageState createState() => _MediaTPageState();
}

class _MediaTPageState extends State<MediaPage> {
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

  Widget buildImage(BuildContext context) {
    if (file == null)
      return Container(
        color: Colors.black,
      );
    return Image.file(
      file,
      fit: BoxFit.contain,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.media.id),
      ),
      body: Column(
        children: <Widget>[
          Expanded(child: buildImage(context)),
          SizedBox(
            height: 200,
            child: SingleChildScrollView(
              child: Text("$exif"),
            ),
          )
        ],
      ),
    );
  }
}
