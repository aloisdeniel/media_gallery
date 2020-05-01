import 'dart:io';

import 'package:flutter/foundation.dart';

import '../media_gallery.dart';

enum MediaType {
  image,
  video,
}

String mediaTypeToJson(MediaType value) {
  switch (value) {
    case MediaType.video:
      return 'video';
    default:
      return 'image';
  }
}

MediaType jsonToMediaType(String value) {
  switch (value) {
    case 'video':
      return MediaType.video;
    default:
      return MediaType.image;
  }
}

class MediaCollection {
  final String id;
  final String name;
  final String type;
  final int count;

  MediaCollection.fromJson(dynamic json)
      : id = json['id'],
        name = json['name'],
        type = json['type'],
        count = json['count'];

  Future<Medias> getMedias({
    @required List<MediaType> mediaTypes,
    int skip,
    int take,
  }) {
    return MediaGallery.listMedias(
      collectionId: id,
      mediaTypes: mediaTypes,
      skip: skip,
      take: take,
    );
  }
}

class Medias {
  final int start;
  final int total;
  final List<Media> items;
  Medias.fromJson(dynamic json)
      : start = json['start'],
        total = json['total'],
        items = json['items'].map<Media>((x) => Media.fromJson(x)).toList();
}

class Media {
  final String id;
  final MediaType type;
  final int width;
  final int height;
  final DateTime creationDate;

  Media.fromJson(dynamic json)
      : id = json["id"],
        type = jsonToMediaType(json["type"]),
        width = json["width"],
        height = json["height"],
        creationDate =
            DateTime.fromMillisecondsSinceEpoch(json["creationDate"] * 1000);

  Future<List<int>> getThumbnail({
    int width,
    int height,
    bool highQuality = false,
  }) {
    return MediaGallery.getMediaTumbnail(
      mediaId: id,
      width: width,
      height: height,
      highQuality: highQuality,
    );
  }

  Future<File> getFile() {
    return MediaGallery.getMediaFile(
      mediaId: id,
    );
  }
}
