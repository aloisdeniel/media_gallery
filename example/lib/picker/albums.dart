import 'package:flutter/material.dart';
import 'package:media_gallery/media_gallery.dart';

import 'thumbnail.dart';
import 'labels.dart';
import 'medias.dart';
import 'selection.dart';

class MediaAlbums extends StatelessWidget {
  final List<MediaCollection> collections;

  const MediaAlbums({
    @required this.collections,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labels = MediaPickerLabels.of(context);
    final selection = MediaPickerSelection.of(context);
    final children = collections
        .map<Widget>(
          (x) => AlbumTile(
            collection: x,
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MediaPickerSelectionProvider(
                    selection: selection,
                    child: MediaPickerLabelsProvider(
                      value: labels,
                      child: MediasPage(
                        collection: x,
                      ),
                    ),
                  ),
                ),
              );
              if (result != null) {
                Navigator.pop(context, result);
              }
            },
          ),
        )
        .toList();
    return ListView.separated(
      separatorBuilder: (context, i) => Container(
        height: 1,
        color: theme.textTheme.body1.color.withOpacity(0.12),
      ),
      itemBuilder: (context, i) => children[i],
      itemCount: children.length,
    );
  }
}

class AlbumTile extends StatelessWidget {
  final GestureTapCallback onTap;
  final MediaCollection collection;

  const AlbumTile({
    @required this.onTap,
    @required this.collection,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labels = MediaPickerLabels.of(context);
    return InkWell(
      onTap: onTap,
      child: SafeArea(
        top: false,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: SizedBox(
            height: 64,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: Container(
                    width: 64,
                    height: 64,
                    color: theme.textTheme.subhead.color.withOpacity(0.1),
                    child:
                        MediaCollectionThumbnailImage(collection: collection),
                  ),
                ),
                SizedBox(
                  width: 12.0,
                ),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        collection.name,
                        style: theme.textTheme.subhead,
                      ),
                      Text(
                        '${collection.count} ${labels.items}',
                        style: theme.textTheme.caption,
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
