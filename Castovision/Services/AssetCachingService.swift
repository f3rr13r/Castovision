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
    
    let imageCache = NSCache<AnyObject, AnyObject>()
    let videoCache = NSCache<AnyObject, AnyObject>()
    
    typealias ImageCacheResponseCompletion = (ImageCacheResponse, UIImage?) -> ()
    typealias VideoCacheResponseCompletion = (VideoCacheResponse, Data?) -> ()
    
    static let instance = AssetCachingService()
    
    
    /*-- get methods --*/
    func getCachedImage(withKey key: String, completion: ImageCacheResponseCompletion) {
        guard let cachedImage = imageCache.value(forKey: key) as? UIImage else {
            completion(.noValueFound, nil)
            return
        }
        completion(.imageFound, cachedImage)
    }
    
    func getCachedVideo(withKey key: String, completion: VideoCacheResponseCompletion) {
        guard let cachedVideoData = videoCache.value(forKey: key) as? Data else {
            completion(.noValueFound, nil)
            return
        }
        completion(.videoDataFound, cachedVideoData)
    }
    
    /*-- set methods --*/
    func setCachedImage(withKey key: String, andImage image: UIImage) {
        imageCache.setValue(image, forKey: key)
    }
    
    func setCachedVideo(withKey key: String, andVideoData videoData: Data) {
        videoCache.setValue(videoData, forKey: key)
    }
}
