//
//  VideoThumbnailGeneratorService.swift
//  Castovision
//
//  Created by Harry Ferrier on 4/10/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit
import AVKit

class VideoThumbnailGeneratorService {
    
    static let instance = VideoThumbnailGeneratorService()
    
    func generateThumbnail(forVideoAtTempUrl tempUrl: URL, atTime time: CMTime, completion: (Data) -> ()) {
        let videoAsset = AVURLAsset(url: tempUrl)
        let videoThumbnailGenerator = AVAssetImageGenerator(asset: videoAsset)
        videoThumbnailGenerator.appliesPreferredTrackTransform = true
        
        let timeStamp = time
        
        do {
            let thumbnailImageRef = try videoThumbnailGenerator.copyCGImage(at: timeStamp, actualTime: nil)
            let thumbnailImage = UIImage(cgImage: thumbnailImageRef)
            let imageData = thumbnailImage.jpegData(compressionQuality: 0)
            completion(imageData ?? Data())
        } catch {
            completion(Data())
        }
    }
    
    private func correctlyOrientedImage(image: UIImage) -> UIImage {
        if image.imageOrientation == .up {
            return image
        } else {
            UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
            image.draw(in: CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height))
            let correctlyOrientatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return correctlyOrientatedImage!
        }
    }
}
