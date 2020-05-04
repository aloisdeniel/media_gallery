import 'package:flutter/material.dart';
import 'labels.dart';
import 'package:media_gallery/media_gallery.dart';

import 'albums.dart';
import 'selection.dart';
import 'validate.dart';
import 'medias.dart';
import 'thumbnail.dart';

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
    final selection = MediaPickerSelection.of(context);
    try {
      collections = await MediaGallery.listMediaCollections(
        mediaTypes: selection.mediaTypes,
      );
      setState(() {});
    } catch (e) {
      print('Failed : $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final selection = MediaPickerSelection.of(context);
    final labels = MediaPickerLabels.of(context);
    final allCollection = collections.firstWhere(
      (c) => c.isAllCollection,
      orElse: () => null,
    );
    return DefaultTabController(
      length: selection.mediaTypes.length + 1,
      child: Scaffold(
        appBar: AppBar(
          title: Text(labels.collectionsTitle),
          actions: <Widget>[
            PickerValidateButton(
              onValidate: (selection) => Navigator.pop(context, selection),
            ),
          ],
          bottom: TabBar(
            tabs: [
              ...selection.mediaTypes.map(
                (x) => Tab(
                  text: x == MediaType.video ? labels.videos : labels.images,
                ),
              ),
              Tab(
                text: labels.albums,
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ...selection.mediaTypes.map(
              (x) => allCollection == null
                  ? SizedBox()
                  : MediaGrid(
                      key: Key(x.toString()),
                      collection: allCollection,
                      mediaType: x,
                    ),
            ),
            MediaAlbums(
              collections: collections
                  .where(
                    (x) => !x.isAllCollection,
                  )
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }
}
