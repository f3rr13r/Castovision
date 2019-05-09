//
//  AssetCachingService.swift
//  Castovision
//
//  Created by Harry Ferrier on 5/9/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit

enum ImageCacheResponse {
    case noValueFound
    case imageFound
}

enum VideoCacheResponse {
    case noValueFound
    case videoDataFound
}

class AssetCachingService {
    
    private let _imageCache = NSCache<NSString, NSData>()
    private let _videoCache = NSCache<NSString, NSData>()
    
    typealias ImageCacheResponseCompletion = (ImageCacheResponse, Data?) -> ()
    typealias VideoCacheResponseCompletion = (VideoCacheResponse, Data?) -> ()
    
    static let instance = AssetCachingService()
    
    
    /*-- get methods --*/
    func clearCaches() {
        _imageCache.removeAllObjects()
        _videoCache.removeAllObjects()
    }
    
    func getCachedImage(withKey key: String, completion: ImageCacheResponseCompletion) {
        guard let cachedImageNSData = _imageCache.object(forKey: key as NSString) else {
            completion(.noValueFound, nil)
            return
        }
        let cachedImageData = Data(referencing: cachedImageNSData)
        completion(.imageFound, cachedImageData)
    }
    
    func getCachedVideo(withKey key: String, completion: VideoCacheResponseCompletion) {
        guard let cachedVideoNSData = _videoCache.object(forKey: key as NSString) else {
            completion(.noValueFound, nil)
            return
        }
        let cachedVideoData = Data(referencing: cachedVideoNSData)
        completion(.videoDataFound, cachedVideoData)
    }
    
    /*-- set methods --*/
    func setCachedImage(withKey key: String, andImageData imageData: Data) {
        _imageCache.setObject(imageData as NSData, forKey: key as NSString)
    }
    
    func setCachedVideo(withKey key: String, andVideoData videoData: Data) {
        _videoCache.setObject(videoData as NSData, forKey: key as NSString)
    }
}
