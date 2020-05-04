library media_gallery;

import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'dart:ui' as ui;

part 'src/image_providers.dart';
part 'src/media_type.dart';
part 'src/model.dart';

/// Accessing the native media gallery.
class MediaGallery {
  static const MethodChannel _channel = const MethodChannel('media_gallery');

  /// List all available media gallery collections and counts number of
  /// items of [mediaTypes].
  static Future<List<dynamic>> listMediaCollections({
    @required List<MediaType> mediaTypes,
  }) async {
    assert(mediaTypes != null);
    final json = await _channel.invokeMethod('listMediaCollections', {
      'mediaTypes': mediaTypes.map((x) => _mediaTypeToJson(x)).toList(),
    });
    return json
        .map<MediaCollection>((x) => MediaCollection.fromJson(x))
        .toList();
  }

  static Future<MediaPage> _listMedias({
    @required MediaCollection collection,
    MediaType mediaType,
    int skip,
    int take,
  }) async {
    assert(collection.id != null);
    mediaType ??= MediaType.image;
    final json = await _channel.invokeMethod('listMedias', {
      'collectionId': collection.id,
      'skip': skip,
      'take': take,
      'mediaType': _mediaTypeToJson(mediaType),
    });
    return MediaPage.fromJson(collection, mediaType, json);
  }

  static Future<List<int>> _getMediaThumbnail({
    @required String mediaId,
    MediaType mediaType,
    int width,
    int height,
    bool highQuality,
  }) async {
    assert(mediaId != null);
    final bytes = await _channel.invokeMethod('getMediaThumbnail', {
      'mediaId': mediaId,
      'width': width,
      'height': height,
      'highQuality': highQuality,
      'mediaType': _mediaTypeToJson(mediaType),
    });
    return bytes;
  }

  static Future<List<int>> _getCollectionThumbnail({
    @required String collectionId,
    int width,
    int height,
    bool highQuality,
  }) async {
    assert(collectionId != null);
    final bytes = await _channel.invokeMethod('getCollectionThumbnail', {
      'collectionId': collectionId,
      'width': width,
      'height': height,
      'highQuality': highQuality,
    });
    return bytes;
  }

  static Future<File> _getMediaFile({
    @required String mediaId,
    MediaType mediaType,
    int width,
    int height,
    bool highQuality,
  }) async {
    assert(mediaId != null);
    mediaType ??= MediaType.image;
    final path = await _channel.invokeMethod('getMediaFile', {
      'mediaId': mediaId,
      'mediaType': _mediaTypeToJson(mediaType),
    }) as String;
    return File(path);
  }
}
