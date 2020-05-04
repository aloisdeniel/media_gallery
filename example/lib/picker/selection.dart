import 'package:flutter/material.dart';
import 'package:media_gallery/media_gallery.dart';

class MediaPickerSelection extends ChangeNotifier {
  final List<Media> selectedMedias;
  final List<MediaType> mediaTypes;
  final int maxItems;

  MediaPickerSelection({
    this.maxItems,
    this.mediaTypes = const <MediaType>[
      MediaType.image,
      MediaType.video,
    ],
    List<Media> selectedMedias,
  }) : selectedMedias = selectedMedias ?? <Media>[];

  static MediaPickerSelection of(BuildContext context) {
    final provider = context
        .dependOnInheritedWidgetOfExactType<MediaPickerSelectionProvider>();
    assert(provider != null);
    return provider.selection;
  }

  void add(Media media) {
    if (maxItems == null || selectedMedias.length < maxItems) {
      selectedMedias.add(media);
      notifyListeners();
    }
  }

  void remove(Media media) {
    selectedMedias.removeWhere((x) => x.id == media.id);
    notifyListeners();
  }

  void toggle(Media media) {
    if (contains(media)) {
      remove(media);
    } else {
      add(media);
    }
  }

  bool contains(Media media) {
    return selectedMedias.any((x) => x.id == media.id);
  }
}

class MediaPickerSelectionProvider extends InheritedWidget {
  final MediaPickerSelection selection;

  const MediaPickerSelectionProvider({
    Key key,
    @required Widget child,
    @required this.selection,
  }) : super(
          key: key,
          child: child,
        );

  @override
  bool updateShouldNotify(MediaPickerSelectionProvider oldWidget) {
    return selection != oldWidget.selection;
  }
}
