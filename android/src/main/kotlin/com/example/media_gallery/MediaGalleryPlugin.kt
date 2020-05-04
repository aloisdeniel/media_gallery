package com.example.media_gallery

import androidx.annotation.NonNull;
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import android.graphics.Bitmap
import java.io.ByteArrayOutputStream
import android.provider.MediaStore
import android.content.Context
import android.os.AsyncTask
import android.graphics.Matrix

/** MediaGalleryPlugin */
class MediaGalleryPlugin: FlutterPlugin, MethodCallHandler {
  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    val channel = MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "media_gallery")
    val plugin = MediaGalleryPlugin()
    plugin.context = flutterPluginBinding.applicationContext
    channel.setMethodCallHandler(plugin)
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  companion object {
    @JvmStatic
    fun registerWith(registrar: Registrar) {

      val channel = MethodChannel(registrar.messenger(), "media_gallery")
      val plugin = MediaGalleryPlugin()
      plugin.context = registrar.activeContext()
      channel.setMethodCallHandler(plugin)
    }
  }

  private var context: Context? = null

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    when {
        call.method == "listMediaCollections" -> {
          val mediaTypes = call.argument<List<String>>("mediaTypes")

          doAsync({
            listMediaCollections(mediaTypes!!)
          }, { v ->
            result.success(v)
          })
        }
        call.method == "listMedias" -> {
          val collectionId = call.argument<String>("collectionId")
          val skip = call.argument<Int>("skip")
          val take = call.argument<Int>("take")
          val mediaType = call.argument<String>("mediaType") ?: "image"
          doAsync({
            when (mediaType) {
              "image" -> listImages(collectionId!!, skip, take)
              "video" -> listVideos(collectionId!!, skip, take)
              else  -> null
            }
          }, { v ->
            result.success(v)
          })
        }
        call.method == "getMediaThumbnail"-> {
          val mediaId = call.argument<String>("mediaId")
          val mediaType = call.argument<String>("mediaType") ?: "image"
          doAsync({
            when (mediaType) {
              "image" -> getImageThumbnail(mediaId!!)
              "video" -> getVideoThumbnail(mediaId!!)
              else -> null
            }
          }, { v ->
            result.success(v)
          })
        }
        call.method == "getCollectionThumbnail"-> {
          val collectionId = call.argument<String>("collectionId")
          doAsync({
            getCollectionThumbnail(collectionId!!)
          }, { v ->
            result.success(v)
          })
        }
        call.method == "getMediaFile" -> {
          val mediaId = call.argument<String>("mediaId")
          val mediaType = call.argument<String>("mediaType") ?: "image"
          when (mediaType) {
            "image" -> result.success(getImageFile(mediaId!!))
            "video" -> result.success(getVideoFile(mediaId!!))
            else -> result.notImplemented()
          }
        }
        else -> result.notImplemented()
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {

  }

  private fun listMediaCollections(mediaTypes: List<String>) : List<Map<String,Any>>  {
    this.context.let { context ->
      if (context is Context) {
        val albumHashMap = mutableMapOf<Long, MutableMap<String, Any>>()

        // Getting images
        if (mediaTypes.contains("image")) {
          val imageOrderBy = MediaStore.Images.Media._ID + " DESC"
          val imageProjection = arrayOf(
                  MediaStore.Images.Media._ID,
                  MediaStore.Images.Media.BUCKET_DISPLAY_NAME,
                  MediaStore.Images.Media.BUCKET_ID)

          val imageCursor = context.contentResolver.query(
                  MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                  imageProjection,
                  null,
                  null,
                  imageOrderBy)

          if (imageCursor != null) {
            val bucketColumn = imageCursor
                    .getColumnIndex(MediaStore.Images.Media.BUCKET_DISPLAY_NAME)
            val bucketColumnId = imageCursor
                    .getColumnIndex(MediaStore.Images.Media.BUCKET_ID)

            while (imageCursor.moveToNext()) {
              val folderName = imageCursor.getString(bucketColumn)

              val bucketId = imageCursor.getInt(bucketColumnId)
              val album = albumHashMap[bucketId.toLong()]
              if (album == null) {
                albumHashMap[bucketId.toLong()] = mutableMapOf(
                        "id" to bucketId.toString(),
                        "collectionType" to "album",
                        "name" to folderName,
                        "count" to 1
                )
              } else {
                val count = album["count"] as Int
                album["count"] = count + 1
              }
            }
            imageCursor.close()
          }

          // Getting videos
          if (mediaTypes.contains("video")) {
            val videoOrderBy = MediaStore.Images.Media._ID + " DESC"
            val videoProjection = arrayOf(
                    MediaStore.Video.Media._ID,
                    MediaStore.Video.Media.BUCKET_DISPLAY_NAME,
                    MediaStore.Video.Media.BUCKET_ID)

            val videoCursor = context.contentResolver.query(
                    MediaStore.Video.Media.EXTERNAL_CONTENT_URI,
                    videoProjection,
                    null,
                    null,
                    videoOrderBy)

            if (videoCursor != null) {
              val bucketColumn = videoCursor
                      .getColumnIndex(MediaStore.Video.Media.BUCKET_DISPLAY_NAME)
              val bucketColumnId = videoCursor
                      .getColumnIndex(MediaStore.Video.Media.BUCKET_ID)

              while (videoCursor.moveToNext()) {
                val folderName = videoCursor.getString(bucketColumn)

                val bucketId = videoCursor.getInt(bucketColumnId)
                val album = albumHashMap[bucketId.toLong()]
                if (album == null) {
                  albumHashMap[bucketId.toLong()] = mutableMapOf(
                          "id" to bucketId.toString(),
                          "collectionType" to "album",
                          "name" to folderName,
                          "count" to 1
                  )
                } else {
                  val count = album["count"] as Int
                  album["count"] = count + 1
                }
              }
              videoCursor.close()
            }
          }

          val albumList = mutableListOf<Map<String, Any>>()

          for ((id, album) in albumHashMap) {
            if (id == 0L)
              albumList.add(0, album.toMap())
            else
              albumList.add(album.toMap())
          }

          return albumList
        }
      }
    }

    return listOf()
  }

  private fun listImages(collectionId: String, skip: Int?, take: Int?) : Map<String,Any> {
    val medias = mutableListOf<Map<String, Any>>()
    val offset = skip ?: 0
    var total = 0

    this.context.let { context ->
      if (context is Context) {

          val imageCountCursor = context.contentResolver.query(
                  MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                  arrayOf("count(*) AS count"),
                  "bucket_id = $collectionId",
                  null,
                  null)
          imageCountCursor!!.moveToFirst()
          total += imageCountCursor.getInt(0)
          imageCountCursor.close()

          // Getting range of images
          val limit = take ?: (total - offset)
          val orderBy = MediaStore.Images.Media.DATE_TAKEN + " DESC"

          val projection = arrayOf(MediaStore.Images.Media._ID,
                  MediaStore.Images.Media.BUCKET_ID,
                  MediaStore.Images.Media.DATE_ADDED,
                  MediaStore.Images.Media.HEIGHT,
                  MediaStore.Images.Media.MIME_TYPE,
                  MediaStore.Images.Media.WIDTH,
                  MediaStore.Images.Media.DATE_TAKEN,
                  MediaStore.Images.Media.ORIENTATION)

          val c = context.contentResolver.query(
                  MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                  projection,
                  "bucket_id = $collectionId",
                  null,
                  "$orderBy LIMIT $limit OFFSET $offset")

          if (c != null) {
            val idColumn = c.getColumnIndex(MediaStore.Images.Media._ID)
            val heightColumn = c.getColumnIndex(MediaStore.Images.Media.HEIGHT)
            val widthColumn = c.getColumnIndex(MediaStore.Images.Media.WIDTH)
            val dateTakenColumn = c.getColumnIndex(MediaStore.Images.Media.DATE_TAKEN)

            while (c.moveToNext()) {

              val id = c.getLong(idColumn)
              val width = c.getLong(widthColumn)
              val height = c.getLong(heightColumn)
              val dateTaken = c.getLong(dateTakenColumn)

              medias.add(mapOf(
                      "id" to id.toString(),
                      "mediaType" to "image",
                      "mediaSubtypes" to listOf<String>(),
                      "isFavorite" to false,
                      "width" to width,
                      "height" to height,
                      "creationDate" to dateTaken))

            }
            c.close()
          }

      }
    }

    return mapOf(
            "start" to offset,
            "total" to total,
            "items" to medias
    )
  }

  private fun listVideos(collectionId: String, skip: Int?, take: Int?) : Map<String,Any> {
    val medias = mutableListOf<Map<String, Any>>()
    val offset = skip ?: 0
    var total = 0

    this.context.let { context ->
      if (context is Context) {

        val videoCountCursor = context.contentResolver.query(
                  MediaStore.Video.Media.EXTERNAL_CONTENT_URI,
                  arrayOf("count(*) AS count"),
                  null,
                  null,
                  null)
          videoCountCursor!!.moveToFirst()
          total += videoCountCursor.getInt(0)
          videoCountCursor.close()


          // Getting range of video
          val limit = take ?: (total - offset)
          val orderBy = MediaStore.Video.Media.DATE_TAKEN + " DESC"

          val projection = arrayOf(MediaStore.Video.Media._ID,
                  MediaStore.Video.Media.BUCKET_ID,
                  MediaStore.Video.Media.DATE_ADDED,
                  MediaStore.Video.Media.HEIGHT,
                  MediaStore.Video.Media.MIME_TYPE,
                  MediaStore.Video.Media.WIDTH,
                  MediaStore.Video.Media.DATE_TAKEN)

          val c = context.contentResolver.query(
                  MediaStore.Video.Media.EXTERNAL_CONTENT_URI,
                  projection,
                  "bucket_id = $collectionId",
                  null,
                  orderBy  + " LIMIT $limit OFFSET $offset")

          if (c != null) {
            val idColumn = c.getColumnIndex(MediaStore.Video.Media._ID)
            val heightColumn = c.getColumnIndex(MediaStore.Video.Media.HEIGHT)
            val widthColumn = c.getColumnIndex(MediaStore.Video.Media.WIDTH)
            val dateTakenColumn = c.getColumnIndex(MediaStore.Video.Media.DATE_TAKEN)

            while (c.moveToNext()) {

              val id = c.getLong(idColumn)
              val width = c.getLong(widthColumn)
              val height = c.getLong(heightColumn)
              val dateTaken = c.getLong(dateTakenColumn)

              medias.add(mapOf(
                      "id" to id.toString(),
                      "mediaType" to "video",
                      "mediaSubtypes" to listOf<String>(),
                      "isFavorite" to false,
                      "width" to width,
                      "height" to height,
                      "creationDate" to dateTaken))

            }
            c.close()
          }
        }
    }

    return mapOf(
            "start" to offset,
            "total" to total,
            "items" to medias
    )
  }

  private fun getImageThumbnail(mediaId: String): ByteArray? {
    this.context.let { context ->
      if (context is Context) {
        // Trying to get image
        val imageProjection = arrayOf(MediaStore.Images.Media._ID,
                MediaStore.Images.Media.ORIENTATION)

        val imageCursor = context.contentResolver.query(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                imageProjection,
                "${MediaStore.Images.Media._ID} = $mediaId",
                null,
                null)

        if (imageCursor != null) {
          if (imageCursor.moveToNext()) {
            val orientationColumn = imageCursor.getColumnIndex(MediaStore.Images.Media.ORIENTATION)
            val orientation = imageCursor.getLong(orientationColumn)
            val bitmap: Bitmap? = MediaStore.Images.Thumbnails.getThumbnail(
                    context!!.contentResolver, mediaId.toLong(),
                    MediaStore.Images.Thumbnails.MINI_KIND,
                    null
            ) ?: return null

            return rotatedBitmap(bitmap!!, orientation)
          }
        }
      }
    }

    return null
  }

  private fun getVideoThumbnail(mediaId: String): ByteArray? {
    val bitmap: Bitmap? = MediaStore.Video.Thumbnails.getThumbnail(
            context!!.contentResolver, mediaId.toLong(),
            MediaStore.Video.Thumbnails.MINI_KIND,
            null
    ) ?: return null

    val stream = ByteArrayOutputStream()
    bitmap!!.compress(Bitmap.CompressFormat.JPEG, 100, stream)
    val byteArray = stream.toByteArray()
    stream.close()
    return byteArray
  }

  private fun getCollectionThumbnail(collectionId: String): ByteArray? {
    this.context.let { context ->
      if (context is Context) {
        val imageProjection = arrayOf(MediaStore.Images.Media._ID,
                MediaStore.Images.Media.BUCKET_ID)
        val imageCursor = context.contentResolver.query(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                imageProjection,
                "bucket_id = $collectionId",
                null,
                MediaStore.Images.Media.DATE_TAKEN + " DESC LIMIT 1")
        if (imageCursor != null) {
          if (imageCursor.moveToNext()) {
            val idColumn = imageCursor.getColumnIndex(MediaStore.Images.Media._ID)
            val id = imageCursor.getLong(idColumn)
            return getImageThumbnail(id.toString())
          }
        }


        val videoProjection = arrayOf(MediaStore.Video.Media._ID,
                MediaStore.Video.Media.BUCKET_ID)
        val videoCursor = context.contentResolver.query(
                MediaStore.Video.Media.EXTERNAL_CONTENT_URI,
                videoProjection,
                "bucket_id = $collectionId",
                null,
                MediaStore.Video.Media.DATE_TAKEN + " DESC LIMIT 1")
        if (videoCursor != null) {
          if (videoCursor.moveToNext()) {
            val idColumn = videoCursor.getColumnIndex(MediaStore.Images.Media._ID)
            val id = videoCursor.getLong(idColumn)
            return getVideoThumbnail(id.toString())
          }
        }
      }
    }
      return null
  }

  private fun getImageFile(mediaId: String): String? {
    this.context.let { context ->
      if (context is Context) {
        // Trying to get image
        val imageProjection = arrayOf(MediaStore.Images.Media._ID,
                MediaStore.Images.Media.DATA)

        val imageCursor = context.contentResolver.query(
                MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                imageProjection,
                "_id = $mediaId",
                null,
                null)

        if (imageCursor != null) {
          if(imageCursor.moveToNext()) {
            val dataColumn = imageCursor.getColumnIndex(MediaStore.Images.Media.DATA)
            val path = imageCursor.getString(dataColumn)
            imageCursor.close()
            return path
          }
        }
      }
    }

    return null
  }

  private fun getVideoFile(mediaId: String): String? {
    this.context.let { context ->
      if (context is Context) {
        // Trying to get video
        val videoProjection = arrayOf(MediaStore.Images.Media._ID,
                MediaStore.Images.Media.DATA)

        val videoCursor = context.contentResolver.query(
                MediaStore.Video.Media.EXTERNAL_CONTENT_URI,
                videoProjection,
                "_id = $mediaId",
                null,
                null)

        if (videoCursor != null) {
          if(videoCursor.moveToNext()) {
            val dataColumn = videoCursor.getColumnIndex(MediaStore.Video.Media.DATA)
            val path = videoCursor.getString(dataColumn)
            videoCursor.close()
            return path
          }
        }
      }
    }

    return null
  }

  private fun rotatedBitmap(bitmap: Bitmap, orientation: Long) : ByteArray {
    val matrix = Matrix()
    matrix.postRotate(orientation.toFloat())
    val resultBitmap = Bitmap.createBitmap(bitmap!!, 0, 0, bitmap!!.getWidth(), bitmap!!.getHeight(), matrix, true)
    val stream = ByteArrayOutputStream()
    resultBitmap!!.compress(Bitmap.CompressFormat.JPEG, 100, stream)
    val byteArray = stream.toByteArray()
    stream.close()
    return byteArray
  }
}

class doAsync<T>(val handler: () -> T, val post: (result:T) -> Unit) : AsyncTask<Void, Void, T>() {
  init {
    execute()
  }

  override fun doInBackground(vararg params: Void?): T {
    val result = handler()
    return result
  }

  override fun onPostExecute(result: T) {
    super.onPostExecute(result)
    post(result)
    return
  }
}