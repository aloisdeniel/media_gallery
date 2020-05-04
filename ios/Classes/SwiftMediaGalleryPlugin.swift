import Foundation
import MobileCoreServices
import Flutter
import UIKit
import Photos

public class SwiftMediaGalleryPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "media_gallery", binaryMessenger: registrar.messenger())
    let instance = SwiftMediaGalleryPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

    
  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if(call.method == "listMediaCollections") {
        let arguments = call.arguments as! Dictionary<String, AnyObject>
        let mediaTypes = arguments["mediaTypes"] as! [String];
        result(listMediaCollections(mediaTypes: mediaTypes))
    }
    else if(call.method == "listMedias") {
        let arguments = call.arguments as! Dictionary<String, AnyObject>
        let collectionId = arguments["collectionId"] as! String;
        let skip = arguments["skip"] as? NSNumber;
        let take = arguments["take"] as? NSNumber;
        let mediaType = arguments["mediaType"] as! String;
        result(listMedias(collectionId:collectionId, skip:skip, take: take,  mediaType: mediaType))
    }
    else if(call.method == "getMediaThumbnail") {
        let arguments = call.arguments as! Dictionary<String, AnyObject>
        let mediaId = arguments["mediaId"] as! String;
        let width = arguments["width"] as? NSNumber;
        let height = arguments["height"] as? NSNumber;
        let highQuality = arguments["highQuality"] as? Bool;
        getMediaThumbnail(mediaId: mediaId, width: width, height: height, highQuality: highQuality, completion:{ (data: Data?, error: Error?) -> () in
            result(data);
        })
    }
    else if(call.method == "getCollectionThumbnail") {
        let arguments = call.arguments as! Dictionary<String, AnyObject>
        let collectionId = arguments["collectionId"] as! String;
        let width = arguments["width"] as? Int;
        let height = arguments["height"] as? Int;
        let highQuality = arguments["highQuality"] as? Bool;
        getCollectionThumbnail(collectionId: collectionId, width: width, height: height, highQuality: highQuality, completion:{ (data: Data?, error: Error?) -> () in
            result(data);
        })
    }
    else if(call.method == "getMediaFile") {
        let arguments = call.arguments as! Dictionary<String, AnyObject>
        let mediaId = arguments["mediaId"] as! String;
        getMediaFile(mediaId: mediaId, completion:{ (filepath: String?, error: Error?) -> () in
            result(filepath?.replacingOccurrences(of: "file://", with: ""));
        })
    }
    else {
        result(FlutterMethodNotImplemented);
    }
  }
    
    private var collections : [PHAssetCollection]  = []
    
    private func listMediaCollections(mediaTypes: [String]) -> [NSDictionary] {
        self.collections = []
        let fetchOptions = PHFetchOptions()
        var collections = [NSDictionary]()
        
        var collectionIds = Set<String>()
        
        let addCollection: ((collection: PHAssetCollection, hideIfEmpty: Bool)) -> Void = { arg in
            let (collection, hideIfEmpty) = arg
            let options = PHFetchOptions()
            options.predicate = self.predicateFromMediaTypes(mediaTypes: mediaTypes)
                                if #available(iOS 9, *) {
                                    fetchOptions.fetchLimit = 1
                                }
                                let count = PHAsset.fetchAssets(in: collection, options: options).count
            if(count > 0 || !hideIfEmpty) {
                self.collections.append(collection);
                collections.append([
                             "id": collection.localIdentifier,
                             "collectionType": "album",
                             "name": collection.localizedTitle ?? "Unknown",
                             "count" :count,
                         ])
            }
        }

        let processPHCollection: ((collection: PHCollection, hideIfEmpty: Bool)) -> Void = { arg in
            let (collection, hideIfEmpty) = arg

            // De-duplicate by id.
            let collectionId = collection.localIdentifier
            guard !collectionIds.contains(collectionId) else {
                return
            }
            collectionIds.insert(collectionId)

            guard let assetCollection = collection as? PHAssetCollection else {
                // TODO: Add support for albmus nested in folders.
                if collection is PHCollectionList { return }
                //owsFailDebug("Asset collection has unexpected type: \(type(of: collection))")
                return
            }
            addCollection((assetCollection, hideIfEmpty))
        }
        let processPHAssetCollections: ((fetchResult: PHFetchResult<PHAssetCollection>, hideIfEmpty: Bool)) -> Void = { arg in
            let (fetchResult, hideIfEmpty) = arg

            fetchResult.enumerateObjects { (assetCollection, _, _) in
        
                // undocumented constant
                let kRecentlyDeletedAlbumSubtype = PHAssetCollectionSubtype(rawValue: 1000000201)
                guard assetCollection.assetCollectionSubtype != kRecentlyDeletedAlbumSubtype else {
                    return
                }

                processPHCollection((collection: assetCollection, hideIfEmpty: hideIfEmpty))
            }
        }
        let processPHCollections: ((fetchResult: PHFetchResult<PHCollection>, hideIfEmpty: Bool)) -> Void = { arg in
            let (fetchResult, hideIfEmpty) = arg

            for index in 0..<fetchResult.count {
                processPHCollection((collection: fetchResult.object(at: index), hideIfEmpty: hideIfEmpty))
            }
        }

        // Try to add "Camera Roll" first.
        processPHAssetCollections((fetchResult: PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumUserLibrary, options: fetchOptions),
                                   hideIfEmpty: false))

        // Favorites
        processPHAssetCollections((fetchResult: PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .smartAlbumFavorites, options: fetchOptions),
                                   hideIfEmpty: false))

        // Smart albums.
        processPHAssetCollections((fetchResult: PHAssetCollection.fetchAssetCollections(with: .smartAlbum, subtype: .albumRegular, options: fetchOptions),
                                   hideIfEmpty: false))

        // User-created albums.
        processPHCollections((fetchResult: PHAssetCollection.fetchTopLevelUserCollections(with: fetchOptions),
                              hideIfEmpty: false))
        
        return collections
     }
    
    private func listMedias(collectionId: String, skip: NSNumber?, take: NSNumber?, mediaType: String) -> NSDictionary {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
        fetchOptions.predicate = predicateFromMediaType(mediaType: mediaType)
        
        let collection = self.collections.first(where: { (collection) -> Bool in
            collection.localIdentifier == collectionId
        });
        let fetchResult = PHAsset.fetchAssets(in: collection!, options: fetchOptions)
        let start = skip?.intValue ?? 0;
        let total = fetchResult.count
        let end = take == nil ? total : min(start + take!.intValue, total)
        var items = [NSDictionary]()
        for index in start..<end
        {
            let asset = fetchResult.object(at: index) as PHAsset
            items.append([
                "id": asset.localIdentifier,
                "mediaType": toDartMediaType(value: asset.mediaType),
                "mediaSubtypes" : [],
                "isFavorite": asset.isFavorite,
                "width": asset.pixelWidth,
                "height": asset.pixelHeight,
                "creationDate" : NSInteger(asset.creationDate?.timeIntervalSince1970 ?? Date().timeIntervalSince1970)
            ])
        }
        
        return [
            "start": start,
            "total": total,
            "items": items]
    }
    
    private func getMediaThumbnail(mediaId: String, width: NSNumber?, height: NSNumber?, highQuality: Bool?, completion: @escaping (Data?, Error?)->()) {
        
        let manager = PHImageManager.default()
            
        let fetchOptions = PHFetchOptions()
        if #available(iOS 9, *) {
            fetchOptions.fetchLimit = 1
        }
        let assets: PHFetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [mediaId], options: fetchOptions)

        if (assets.count > 0) {
            let asset: PHAsset = assets[0];
            
            let options = PHImageRequestOptions()
            options.deliveryMode = (highQuality ?? false) ?  PHImageRequestOptionsDeliveryMode.highQualityFormat : PHImageRequestOptionsDeliveryMode.fastFormat
            options.isSynchronous = false
            options.isNetworkAccessAllowed = true
            options.version = .current

            let imageSize = CGSize(width: width?.intValue ?? 128, height: height?.intValue ?? 128)
            manager.requestImage(
               for: asset,
               targetSize: CGSize(width: imageSize.width *  UIScreen.main.scale, height: imageSize.height *  UIScreen.main.scale),
               contentMode: PHImageContentMode.aspectFill,
               options: options,
               resultHandler: {
                   (image: UIImage?, info) in
                let bytes = image!.jpegData(compressionQuality: CGFloat(70));
                completion(bytes, nil);
           })

        }
    }
    
    private func getCollectionThumbnail(collectionId: String, width: Int?, height: Int?, highQuality: Bool?, completion: @escaping (Data?, Error?)->()) {
        
        let manager = PHImageManager.default()
            
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key:"creationDate", ascending: false)]
        if #available(iOS 9, *) {
            fetchOptions.fetchLimit = 1
        }
        
        let collection = self.collections.first(where: { (collection) -> Bool in
            collection.localIdentifier == collectionId
        });
        let assets = PHAsset.fetchAssets(in: collection!, options: fetchOptions)
        
        if (assets.count > 0) {
            let asset: PHAsset = assets[0];
            
            let options = PHImageRequestOptions()
            options.deliveryMode = (highQuality ?? false) ?  PHImageRequestOptionsDeliveryMode.highQualityFormat : PHImageRequestOptionsDeliveryMode.fastFormat
            options.isSynchronous = false
            options.isNetworkAccessAllowed = true
            options.version = .current

            let imageSize = CGSize(width: width ?? 128, height: height ?? 128)
            manager.requestImage(
               for: asset,
               targetSize: CGSize(width: imageSize.width *  UIScreen.main.scale, height: imageSize.height *  UIScreen.main.scale),
               contentMode: PHImageContentMode.aspectFill,
               options: options,
               resultHandler: {
                   (image: UIImage?, info) in
                let bytes = image!.jpegData(compressionQuality: CGFloat(70));
                completion(bytes, nil);
           })

        }
    }
    
    private func getMediaFile(mediaId: String,completion: @escaping (String?, Error?)->()) {
        let manager = PHImageManager.default()
        
        let fetchOptions = PHFetchOptions()
        if #available(iOS 9, *) {
           fetchOptions.fetchLimit = 1
        }
        let assets: PHFetchResult = PHAsset.fetchAssets(withLocalIdentifiers: [mediaId], options: fetchOptions)
    
        if (assets.count > 0) {
            let asset: PHAsset = assets[0];
            
            if(asset.mediaType == PHAssetMediaType.image) {
                let options = PHImageRequestOptions()
                options.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
                options.isSynchronous = false
                options.isNetworkAccessAllowed = true
                options.version = .current
                
                manager.requestImageData(
                    for: asset,
                    options: options,
                    resultHandler: {
                        (data: Data?, uti: String?, orientation, info) in
                        
                        if let originalData = data {
                            if let jpgData = self.convertToJpeg(originalData: originalData) {
                                // Writing to file
                                let filepath = self.exportPathForAsset(asset: asset, ext: ".jpg")
                                try! jpgData.write(to: filepath, options: .atomic)
                                completion(filepath.absoluteString, nil)
                            }
                            else {
                                completion(nil, NSError(domain: "media_gallery", code: 3, userInfo: nil))
                            }
                        }
                        else {
                           
                            completion(nil, NSError(domain: "media_gallery", code: 4, userInfo: nil))
                        }
                })
            }
            else if(asset.mediaType == PHAssetMediaType.video || asset.mediaType == PHAssetMediaType.audio) {
                
                let options = PHVideoRequestOptions()
                options.isNetworkAccessAllowed = true
                options.version = .current
                
                manager.requestAVAsset(forVideo: asset, options: options, resultHandler: { (avAsset, avAudioMix, info) in
                    DispatchQueue.main.async(execute: {
                        do {
                            let avAsset = avAsset as? AVURLAsset
                            let data = try Data(contentsOf: avAsset!.url)
                            let filepath = self.exportPathForAsset(asset: asset, ext: ".mov")
                            try! data.write(to: filepath, options: .atomic)
                            completion(filepath.absoluteString, nil)
                        }
                        catch {
                            completion(nil,  NSError(domain: "media_gallery", code: 5, userInfo: nil))
                        }
                    })
                })
            }
        }
        
    }
    
    /// Converts to JPEG, and keep EXIF data.
    private func convertToJpeg(originalData: Data) -> Data? {
        if let image: UIImage = UIImage(data: originalData) {

            let originalSrc = CGImageSourceCreateWithData(originalData as CFData, nil)!
            let options = [kCGImageSourceShouldCache as String: kCFBooleanFalse]
            let originalMetadata = CGImageSourceCopyPropertiesAtIndex(originalSrc, 0, options as CFDictionary)
            
            if let jpeg = image.jpegData(compressionQuality:1.0) {
                
                
                let src = CGImageSourceCreateWithData(jpeg as CFData, nil)!
                let data = NSMutableData()
                let uti = CGImageSourceGetType(src)!
                let dest = CGImageDestinationCreateWithData(data as CFMutableData, uti, 1, nil)!
                CGImageDestinationAddImageFromSource(dest, src, 0,
                                                     originalMetadata) // m is the metadata
                if CGImageDestinationFinalize(dest) {
                    return data as Data
                }
            }
        }
        
        return nil;
    }
    
    
    private func exportPathForAsset(asset: PHAsset, ext: String) -> URL {
        let mediaId = asset.localIdentifier.replacingOccurrences(of: "/", with: "__").replacingOccurrences(of: "\\", with: "__")
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let tempFolder = paths[0].appendingPathComponent("media_gallery")
        try! FileManager.default.createDirectory(at: tempFolder, withIntermediateDirectories: true, attributes: nil)
       
        return paths[0].appendingPathComponent(mediaId+ext)
        
    }
    
    private func toSwiftMediaType(value: String) -> PHAssetMediaType? {
        switch value  {
            case "image": return PHAssetMediaType.image;
            case "video": return PHAssetMediaType.video;
            case "audio": return PHAssetMediaType.audio;
            default: return nil;
        }
    }
    
    private func toDartMediaType(value: PHAssetMediaType) -> String? {
           switch value  {
               case PHAssetMediaType.image : return "image";
               case PHAssetMediaType.video: return "video";
               case PHAssetMediaType.audio: return "audio";
               default: return nil;
           }
       }
    
    private func predicateFromMediaTypes(mediaTypes: [String]) -> NSPredicate {
        let predicates = mediaTypes.map { (dartValue) -> NSPredicate in
            return predicateFromMediaType(mediaType: dartValue);
        }
        
        return NSCompoundPredicate (type: NSCompoundPredicate.LogicalType.or, subpredicates:predicates);
    }
    
    private func predicateFromMediaType(mediaType: String) -> NSPredicate {
        let swiftType = toSwiftMediaType(value: mediaType);
        return NSPredicate(format: "mediaType = %d", swiftType!.rawValue);
    }
}

