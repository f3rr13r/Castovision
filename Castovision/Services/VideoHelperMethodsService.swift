//
//  VideoThumbnailGeneratorService.swift
//  Castovision
//
//  Created by Harry Ferrier on 4/10/19.
//  Copyright © 2019 harryferrier. All rights reserved.
//

import UIKit
import AVKit

class VideoHelperMethodsService {
    
    static let instance = VideoHelperMethodsService()
    
    /*-- thumbnail generation stuff --*/
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
    
    /*-- video cropping stuff --*/
    func verifyPresetForAsset(preset: String, asset: AVAsset) -> Bool {
        let compatiblePresets = AVAssetExportSession.exportPresets(compatibleWith: asset)
        let filteredPresets = compatiblePresets.filter { $0 == preset }
        return filteredPresets.count > 0 || preset == AVAssetExportPresetPassthrough
    }
    
    func removeFileAtURLIfExists(url: URL) {
        
        let fileManager = FileManager.default
        
        guard fileManager.fileExists(atPath: url.path) else { return }
        
        do {
            try fileManager.removeItem(at: url)
        }
        catch let error {
            print("TrimVideo - Couldn't remove existing destination file: \(String(describing: error))")
        }
    }
    
    func trimVideo(sourceURL: URL, startTime: CMTime, endTime: CMTime, completion: @escaping (URL?, Bool) -> ()) {

        guard sourceURL.isFileURL else { return }
        
        let options = [
            AVURLAssetPreferPreciseDurationAndTimingKey: true
        ]
        
        let asset = AVURLAsset(url: sourceURL, options: options)
        let preferredPreset = AVAssetExportPresetHighestQuality
        
        if  verifyPresetForAsset(preset: preferredPreset, asset: asset) {
            
            let composition = AVMutableComposition()
            let videoCompTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: CMPersistentTrackID())
            let audioCompTrack = composition.addMutableTrack(withMediaType: .audio, preferredTrackID: CMPersistentTrackID())
            
            guard let assetVideoTrack: AVAssetTrack = asset.tracks(withMediaType: .video).first else { return }
            guard let assetAudioTrack: AVAssetTrack = asset.tracks(withMediaType: .audio).first else { return }
            
            let trimPoints = [(startTime, endTime)]
            
            var accumulatedTime = CMTime.zero
            for (startTimeForCurrentSlice, endTimeForCurrentSlice) in trimPoints {
                
                let durationOfCurrentSlice = CMTimeSubtract(endTimeForCurrentSlice, startTimeForCurrentSlice)
                let timeRangeForCurrentSlice = CMTimeRangeMake(start: startTimeForCurrentSlice, duration: durationOfCurrentSlice)
                
                do {
                    try videoCompTrack!.insertTimeRange(timeRangeForCurrentSlice, of: assetVideoTrack, at: accumulatedTime)
                    try audioCompTrack!.insertTimeRange(timeRangeForCurrentSlice, of: assetAudioTrack, at: accumulatedTime)
                    accumulatedTime = CMTimeAdd(accumulatedTime, durationOfCurrentSlice)
                }
                catch let compError {
                    print("TrimVideo: error during composition: \(compError)")
                    completion(nil, false)
                }
            }
            
            guard let exportSession = AVAssetExportSession(asset: composition, presetName: preferredPreset) else { return }
            
            exportSession.outputURL = sourceURL
            exportSession.outputFileType = AVFileType.mp4
            
            removeFileAtURLIfExists(url: sourceURL)
            
            exportSession.exportAsynchronously {
                completion(sourceURL, true)
            }
        }
        else {
            print("TrimVideo - Could not find a suitable export preset for the input video")
            let error = NSError(domain: "com.bighug.ios", code: -1, userInfo: nil)
            completion(nil, false)
        }
    }
}
