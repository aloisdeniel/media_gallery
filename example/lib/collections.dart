import 'package:flutter/material.dart';
import 'package:media_gallery/media_gallery.dart';
import 'package:media_gallery_example/medias.dart';

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
    try {
      this.collections = await MediaGallery.listMediaCollections(
        mediaTypes: [MediaType.image],
      );
      this.setState(() {});
    } catch (e) {
      print("Failed : $e");
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
              ),
            ),
          )
        ],
      ),
    );
  }
}
