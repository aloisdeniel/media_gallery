import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:media_gallery/src/model.dart';
import 'src/model.dart';

export 'src/model.dart';

class MediaGallery {
  static const MethodChannel _channel = const MethodChannel('media_gallery');

  static Future<List<dynamic>> listMediaCollections({
    @required List<MediaType> mediaTypes,
  }) async {
    assert(mediaTypes != null);
    final json = await _channel.invokeMethod('listMediaCollections', {
      'mediaTypes': mediaTypes.map((x) => mediaTypeToJson(x)).toList(),
    });
    return json
        .map<MediaCollection>((x) => MediaCollection.fromJson(x))
        .toList();
  }

  static Future<Medias> listMedias({
    @required String collectionId,
    @required List<MediaType> mediaTypes,
    int skip,
    int take,
  }) async {
    assert(collectionId != null);
    assert(mediaTypes != null);
    final json = await _channel.invokeMethod('listMedias', {
      'collectionId': collectionId,
      'skip': skip,
      'take': take,
      'mediaTypes': mediaTypes.map((x) => mediaTypeToJson(x)).toList(),
    });
    return Medias.fromJson(json);
  }

  static Future<List<int>> getMediaTumbnail({
    @required String mediaId,
    int width,
    int height,
    bool highQuality,
  }) async {
    assert(mediaId != null);
    final bytes = await _channel.invokeMethod('getMediaTumbnail', {
      'mediaId': mediaId,
      'width': width,
      'height': height,
      'highQuality': highQuality,
    });
    return bytes;
  }

  static Future<File> getMediaFile({
    @required String mediaId,
    int width,
    int height,
    bool highQuality,
  }) async {
    assert(mediaId != null);
    final path = await _channel.invokeMethod('getMediaFile', {
      'mediaId': mediaId,
    }) as String;
    return File(path);
  }
}
