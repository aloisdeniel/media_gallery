import 'package:flutter/widgets.dart';
import 'package:media_gallery_example/picker/collections.dart';
import 'package:media_gallery_example/picker/selection.dart';

class MediaPicker extends StatefulWidget {
  final MediaPickerSelection initialSelection;

  const MediaPicker({
    Key key,
    this.initialSelection,
  });

  @override
  _MediaPickerState createState() => _MediaPickerState();
}

class _MediaPickerState extends State<MediaPicker> {
  MediaPickerSelection _selection;

  @override
  void initState() {
    _selection = widget.initialSelection ?? MediaPickerSelection();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MediaPickerSelectionProvider(
      selection: _selection,
      child: MediaCollectionsPage(),
    );
  }
}
