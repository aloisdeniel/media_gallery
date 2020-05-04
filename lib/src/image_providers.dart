part of media_gallery;

/// Fetches the given media thumbnail from the gallery.
class MediaThumbnailProvider extends ImageProvider<MediaThumbnailProvider> {
  const MediaThumbnailProvider({
    @required this.media,
  }) : assert(media != null);

  final Media media;

  @override
  ImageStreamCompleter load(key, decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: 1.0,
      informationCollector: () sync* {
        yield ErrorDescription('Id: ${media?.id}');
      },
    );
  }

  Future<ui.Codec> _loadAsync(
      MediaThumbnailProvider key, DecoderCallback decode) async {
    assert(key == this);
    final bytes = await media.getThumbnail();
    if (bytes.length == 0) return null;

    return await decode(bytes);
  }

  @override
  Future<MediaThumbnailProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<MediaThumbnailProvider>(this);
  }

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final MediaThumbnailProvider typedOther = other;
    return media?.id == typedOther.media?.id;
  }

  @override
  int get hashCode => media?.id?.hashCode ?? 0;

  @override
  String toString() => '$runtimeType("${media?.id}")';
}

/// Fetches the given media collection thumbnail from the gallery.
class MediaCollectionThumbnailProvider
    extends ImageProvider<MediaCollectionThumbnailProvider> {
  const MediaCollectionThumbnailProvider({
    @required this.collection,
  }) : assert(collection != null);

  final MediaCollection collection;

  @override
  ImageStreamCompleter load(key, decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: 1.0,
      informationCollector: () sync* {
        yield ErrorDescription('Id: ${collection?.id}');
      },
    );
  }

  Future<ui.Codec> _loadAsync(
      MediaCollectionThumbnailProvider key, DecoderCallback decode) async {
    assert(key == this);
    final bytes = await collection.getThumbnail();
    if (bytes.length == 0) return null;

    return await decode(bytes);
  }

  @override
  Future<MediaCollectionThumbnailProvider> obtainKey(
      ImageConfiguration configuration) {
    return SynchronousFuture<MediaCollectionThumbnailProvider>(this);
  }

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final MediaCollectionThumbnailProvider typedOther = other;
    return collection?.id == typedOther.collection?.id;
  }

  @override
  int get hashCode => collection?.id?.hashCode ?? 0;

  @override
  String toString() => '$runtimeType("${collection?.id}")';
}

/// Fetches the given media image thumbnail from the gallery.
///
/// The given [media] must be of media type [MediaType.image].
class MediaImageProvider extends ImageProvider<MediaImageProvider> {
  MediaImageProvider({
    @required this.media,
  })  : assert(media != null),
        assert(media.mediaType == MediaType.image);

  final Media media;

  @override
  ImageStreamCompleter load(key, decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: 1.0,
      informationCollector: () sync* {
        yield ErrorDescription('Id: ${media?.id}');
      },
    );
  }

  Future<ui.Codec> _loadAsync(
      MediaImageProvider key, DecoderCallback decode) async {
    assert(key == this);
    final file = await media.getFile();
    if (file == null) return null;

    final bytes = await file.readAsBytes();
    if (bytes.lengthInBytes == 0) return null;

    return await decode(bytes);
  }

  @override
  Future<MediaImageProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<MediaImageProvider>(this);
  }

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final MediaImageProvider typedOther = other;
    return media?.id == typedOther.media?.id;
  }

  @override
  int get hashCode => media?.id?.hashCode ?? 0;

  @override
  String toString() => '$runtimeType("${media?.id}")';
}
