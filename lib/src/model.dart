part of media_gallery;

/// A media user collection.
@immutable
class MediaCollection {
  /// A unique identifier for the collection.
  final String id;

  /// The name of the collection.
  final String name;

  /// The total number of medias in the collection.
  final int count;

  /// Indicates whether this collection contains all medias.
  bool get isAllCollection => id == "__ALL__";

  /// Creates a range of media from platform channel protocol.
  MediaCollection.fromJson(dynamic json)
      : id = json['id'],
        name = json['name'],
        count = json['count'];

  /// Get media of the given [mediaType].
  ///
  /// Pagination can be controlled out of [skip] (defaults to `0`) and
  /// [take] (defaults to `<total>`).
  Future<MediaPage> getMedias({
    MediaType mediaType,
    int skip,
    int take,
  }) {
    return MediaGallery._listMedias(
      collection: this,
      mediaType: mediaType,
      skip: skip,
      take: take,
    );
  }

  /// Get thumbnail data for this collection.
  ///
  /// It will display the lastly taken media thumbnail.
  Future<List<int>> getThumbnail({
    int width,
    int height,
    bool highQuality = false,
  }) {
    return MediaGallery._getCollectionThumbnail(
      collectionId: id,
      width: width,
      height: height,
      highQuality: highQuality,
    );
  }
}

/// A list of medias with pagination support.
@immutable
class MediaPage {
  final MediaCollection collection;

  /// The media type of [items].
  final MediaType mediaType;

  /// The start offset for those medias.
  final int start;

  /// The total number of items.
  final int total;

  /// The current items.
  final List<Media> items;

  /// The end index in the collection.
  int get end => start + items.length;

  ///Indicates whether this page is the last in the collection.
  bool get isLast => end >= total;

  /// Creates a range of media from platform channel protocol.
  MediaPage.fromJson(this.collection, this.mediaType, dynamic json)
      : start = json['start'],
        total = json['total'],
        items = json['items'].map<Media>((x) => Media.fromJson(x)).toList();

  /// Gets the next page of medias in the collection.
  Future<MediaPage> nextPage() {
    assert(!isLast);
    return MediaGallery._listMedias(
      collection: collection,
      mediaType: mediaType,
      skip: end,
      take: items.length,
    );
  }
}

/// A media for the gallery.
///
/// It can be of image or video [mediaType].
@immutable
class Media {
  /// A unique identifier for the media.
  final String id;

  /// The media type.
  final MediaType mediaType;

  /// The media width.
  final int width;

  /// The media height.
  final int height;

  /// The date at which the photo or video was taken.
  final DateTime creationDate;

  /// Creates a media from platform channel protocol.
  Media.fromJson(dynamic json)
      : id = json["id"],
        mediaType = _jsonToMediaType(json["mediaType"]),
        width = json["width"],
        height = json["height"],
        creationDate =
            DateTime.fromMillisecondsSinceEpoch(json["creationDate"]);

  /// Get a JPEG thumbnail's data for this media.
  Future<List<int>> getThumbnail({
    int width,
    int height,
    bool highQuality = false,
  }) {
    return MediaGallery._getMediaThumbnail(
      mediaId: id,
      width: width,
      height: height,
      mediaType: mediaType,
      highQuality: highQuality,
    );
  }

  /// Get the original file.
  Future<File> getFile() {
    return MediaGallery._getMediaFile(
      mediaId: id,
      mediaType: mediaType,
    );
  }
}
