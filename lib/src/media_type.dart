part of media_gallery;

/// A media type.
enum MediaType {
  image,
  video,
}

String _mediaTypeToJson(MediaType? value) {
  switch (value) {
    case MediaType.video:
      return 'video';
    default:
      return 'image';
  }
}

MediaType _jsonToMediaType(String? value) {
  switch (value) {
    case 'video':
      return MediaType.video;
    default:
      return MediaType.image;
  }
}
