import 'package:flutter/material.dart';
import 'package:media_gallery/media_gallery.dart';
import 'package:media_gallery_example/thumbnail.dart';

import 'media.dart';

class MediasPage extends StatefulWidget {
  final MediaCollection collection;
  MediasPage({
    @required this.collection,
  });

  @override
  _MediasPageState createState() => _MediasPageState();
}

class _MediasPageState extends State<MediasPage> {
  List<Media> medias = [];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initAsync();
    });
    super.initState();
  }

  Future<void> initAsync() async {
    try {
      final range = await widget.collection.getMedias(
        mediaTypes: [MediaType.image],
      );
      this.medias = range.items;
      this.setState(() {});
    } catch (e) {
      print("Failed : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.collection.name),
      ),
      body: ListView(
        children: <Widget>[
          ...medias.map<Widget>(
            (x) => Card(
              child: ListTile(
                leading: MediaThumbnailImage(
                  media: x,
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MediaPage(
                        media: x,
                      ),
                    ),
                  );
                },
                title: Text(
                  x.id,
                ),
                subtitle: Text("${x.width}*${x.height} | ${x.creationDate}"),
              ),
            ),
          )
        ],
      ),
    );
  }
}
