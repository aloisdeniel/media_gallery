import 'package:flutter/material.dart';
import 'package:media_gallery/media_gallery.dart';
import 'package:media_gallery_example/pages/medias.dart';
import 'package:media_gallery_example/pages/thumbnail.dart';
import 'package:permission_handler/permission_handler.dart';

class MediaCollectionsPage extends StatefulWidget {
  @override
  _MediaCollectionsPageState createState() => _MediaCollectionsPageState();
}

class _MediaCollectionsPageState extends State<MediaCollectionsPage> {
  List<MediaCollection> collections = [];

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initAsync();
    });
    super.initState();
  }

  Future<void> initAsync() async {
    if (await Permission.storage.request().isGranted) {
      try {
        this.collections = await MediaGallery.listMediaCollections(
          mediaTypes: [MediaType.image, MediaType.video],
        );
        this.setState(() {});
      } catch (e) {
        print("Failed : $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Collections'),
      ),
      body: ListView(
        children: <Widget>[
          ...collections.map<Widget>(
            (x) => Card(
              child: ListTile(
                leading: SizedBox(
                  width: 64,
                  child: MediaCollectionThumbnailImage(collection: x),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MediasPage(
                        collection: x,
                      ),
                    ),
                  );
                },
                title: Text(
                  x.name,
                ),
                subtitle: Text("${x.count} item(s)"),
              ),
            ),
          )
        ],
      ),
    );
  }
}
