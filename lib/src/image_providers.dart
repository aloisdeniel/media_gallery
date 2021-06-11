part of media_gallery;

/// Fetches the given media thumbnail from the gallery.
class MediaThumbnailProvider extends ImageProvider<MediaThumbnailProvider> {
  const MediaThumbnailProvider({
    required this.media,
  }) : assert(media != null);

  final Media media;

  @override
  ImageStreamCompleter load(key, decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: 1.0,
      informationCollector: () sync* {
        yield ErrorDescription('Id: ${media.id}');
      },
    );
  }

  Future<ui.Codec> _loadAsync(
      MediaThumbnailProvider key, DecoderCallback decode) async {
    assert(key == this);
    final bytes = await media.getThumbnail();
    if (bytes.length == 0) return await decode([] as Uint8List);

    return await decode(bytes as Uint8List);
  }

  @override
  Future<MediaThumbnailProvider> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<MediaThumbnailProvider>(this);
  }

  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final MediaThumbnailProvider typedOther = other;
    return media.id == typedOther.media.id;
  }

  @override
  int get hashCode => media.id.hashCode;

  @override
  String toString() => '$runtimeType("${media.id}")';
}

/// Fetches the given media collection thumbnail from the gallery.
class MediaCollectionThumbnailProvider
    extends ImageProvider<MediaCollectionThumbnailProvider> {
  const MediaCollectionThumbnailProvider({
    required this.collection,
  }) : assert(collection != null);

  final MediaCollection collection;

  @override
  ImageStreamCompleter load(key, decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: 1.0,
      informationCollector: () sync* {
        yield ErrorDescription('Id: ${collection.id}');
      },
    );
  }

  Future<ui.Codec> _loadAsync(
      MediaCollectionThumbnailProvider key, DecoderCallback decode) async {
    assert(key == this);
    final bytes = await collection.getThumbnail();
    if (bytes == null || bytes.length == 0) return await decode(kTransparentImageBytes);

    return await decode(bytes as Uint8List);
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
    return collection.id == typedOther.collection.id;
  }

  @override
  int get hashCode => collection.id.hashCode;

  @override
  String toString() => '$runtimeType("${collection.id}")';
}

/// Fetches the given media image thumbnail from the gallery.
///
/// The given [media] must be of media type [MediaType.image].
class MediaImageProvider extends ImageProvider<MediaImageProvider> {
  MediaImageProvider({
    required this.media,
  })  : assert(media != null),
        assert(media.mediaType == MediaType.image);

  final Media media;

  @override
  ImageStreamCompleter load(key, decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key, decode),
      scale: 1.0,
      informationCollector: () sync* {
        yield ErrorDescription('Id: ${media.id}');
      },
    );
  }

  Future<ui.Codec> _loadAsync(
      MediaImageProvider key, DecoderCallback decode) async {
    assert(key == this);
    final file = await media.getFile();
    if (file == null) return await decode([] as Uint8List);

    final bytes = await file.readAsBytes();
    if (bytes.lengthInBytes == 0) return await decode([] as Uint8List);

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
    return media.id == typedOther.media.id;
  }

  @override
  int get hashCode => media.id.hashCode;

  @override
  String toString() => '$runtimeType("${media.id}")';
}


final Uint8List kTransparentImageBytes = new Uint8List.fromList(<int>[
  0x89,
  0x50,
  0x4E,
  0x47,
  0x0D,
  0x0A,
  0x1A,
  0x0A,
  0x00,
  0x00,
  0x00,
  0x0D,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1F,
  0x15,
  0xC4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0A,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9C,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0D,
  0x0A,
  0x2D,
  0xB4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4E,
  0x44,
  0xAE,
]);
