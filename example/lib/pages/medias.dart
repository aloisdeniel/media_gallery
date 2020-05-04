import 'package:flutter/material.dart';
import 'package:media_gallery/media_gallery.dart';
import 'package:media_gallery_example/pages/thumbnail.dart';

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
  MediaPage imagePage;
  MediaPage videoPage;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initAsync();
    });
    super.initState();
  }

  Future<void> initAsync() async {
    try {
      imagePage = await widget.collection.getMedias(
        mediaType: MediaType.image,
        take: 20,
      );
      videoPage = await widget.collection.getMedias(
        mediaType: MediaType.video,
        take: 20,
      );
      this.medias = [
        ...imagePage.items,
        ...videoPage.items,
      ]..sort((x, y) => y.creationDate.compareTo(x.creationDate));
      setState(() {});
    } catch (e) {
      print("Failed : $e");
    }
  }

  Future<void> loadMore() async {
    if (!imagePage.isLast) {
      imagePage = await imagePage.nextPage();
      medias.addAll(imagePage.items);
    }
    if (!videoPage.isLast) {
      videoPage = await videoPage.nextPage();
      medias.addAll(videoPage.items);
    }
    medias.sort((x, y) => y.creationDate.compareTo(x.creationDate));
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.collection.name),
        actions: <Widget>[
          if (imagePage != null &&
              videoPage != null &&
              (!imagePage.isLast || !videoPage.isLast))
            IconButton(
              onPressed: () => loadMore(),
              icon: Icon(Icons.more),
            )
        ],
      ),
      body: GridView(
        children: <Widget>[
          ...medias.map<Widget>(
            (x) => InkWell(
              child: MediaThumbnailImage(
                media: x,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MediaViewerPage(
                      media: x,
                    ),
                  ),
                );
              },
            ),
          )
        ],
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.0,
        ),
      ),
    );
  }
}
