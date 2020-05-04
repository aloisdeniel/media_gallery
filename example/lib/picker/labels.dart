import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

@immutable
class MediaPickerLabels {
  final String collectionsTitle;
  final String items;
  final String images;
  final String albums;
  final String videos;
  final String mediaNotAuthorizedAccessTitle;
  final String mediaNotAuthorizedAccessDescription;
  final String openSettings;

  const MediaPickerLabels({
    @required this.collectionsTitle,
    @required this.images,
    @required this.videos,
    @required this.albums,
    @required this.items,
    @required this.mediaNotAuthorizedAccessTitle,
    @required this.mediaNotAuthorizedAccessDescription,
    @required this.openSettings,
  });

  static MediaPickerLabels of(BuildContext context) {
    final provider =
        context.dependOnInheritedWidgetOfExactType<MediaPickerLabelsProvider>();
    assert(provider != null);
    return provider.value;
  }

  factory MediaPickerLabels.fallback() => const MediaPickerLabels(
        collectionsTitle: 'Select images',
        albums: 'Albums',
        images: 'Photos',
        videos: 'Videos',
        items: 'item(s)',
        mediaNotAuthorizedAccessTitle: 'Not authorized',
        mediaNotAuthorizedAccessDescription:
            "This app can't have access to user media gallery. You must update authorizations in app settings.",
        openSettings: 'Open settings',
      );
}

class MediaPickerLabelsProvider extends InheritedWidget {
  final MediaPickerLabels value;

  const MediaPickerLabelsProvider({
    Key key,
    @required Widget child,
    @required this.value,
  }) : super(
          key: key,
          child: child,
        );

  @override
  bool updateShouldNotify(MediaPickerLabelsProvider oldWidget) {
    return value != oldWidget.value;
  }
}
