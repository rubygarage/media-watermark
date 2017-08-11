//
//  MediaItemVideo.swift
//  MediaWatermark
//
//  Created by Sergei on 03/05/2017.
//  Copyright © 2017 rubygarage. All rights reserved.
//

import UIKit
import AVFoundation

let kMediaContentDefaultScale: CGFloat = 1
let kProcessedTemporaryVideoFileName = "/processed.mov"
let kMediaContentTimeValue: Int64 = 1
let kMediaContentTimeScale: Int32 = 30

extension MediaProcessor {
    func processVideoWithElements(item: MediaItem, completion: @escaping ProcessCompletionHandler) {
        let mixComposition = AVMutableComposition()
        let compositionVideoTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
        let clipVideoTrack = item.sourceAsset.tracks(withMediaType: AVMediaTypeVideo).first
        let compositionAudioTrack = mixComposition.addMutableTrack(withMediaType: AVMediaTypeAudio, preferredTrackID: kCMPersistentTrackID_Invalid)
        let clipAudioTrack = item.sourceAsset.tracks(withMediaType: AVMediaTypeAudio).first
        
        do {
            try compositionVideoTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, item.sourceAsset.duration), of: clipVideoTrack!, at: kCMTimeZero)
        } catch {
            completion(MediaProcessResult(processedUrl: nil, image: nil), error)
            return
        }
        
        do {
            try compositionAudioTrack.insertTimeRange(CMTimeRangeMake(kCMTimeZero, item.sourceAsset.duration), of: clipAudioTrack!, at: kCMTimeZero)
        } catch {
            completion(MediaProcessResult(processedUrl: nil, image: nil), error)
            return
        }
        
        compositionVideoTrack.preferredTransform = (item.sourceAsset.tracks(withMediaType: AVMediaTypeVideo).first?.preferredTransform)!
        
        let sizeOfVideo = resolutionSizeForLocalVideo(url: item.sourceAsset.url)
        
        let optionalLayer = CALayer()
        processAndAddElements(item: item, layer: optionalLayer)
        optionalLayer.frame = CGRect(x: 0, y: 0, width: sizeOfVideo.width, height: sizeOfVideo.height)
        optionalLayer.masksToBounds = true
        
        let parentLayer = CALayer()
        let videoLayer = CALayer()
        parentLayer.frame = CGRect(x: 0, y: 0, width: sizeOfVideo.width, height: sizeOfVideo.height)
        videoLayer.frame = CGRect(x: 0, y: 0, width: sizeOfVideo.width, height: sizeOfVideo.height)
        parentLayer.addSublayer(videoLayer)
        parentLayer.addSublayer(optionalLayer)
        
        let videoComposition = AVMutableVideoComposition()
        videoComposition.frameDuration = CMTimeMake(kMediaContentTimeValue, kMediaContentTimeScale)
        videoComposition.renderSize = sizeOfVideo
        videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(postProcessingAsVideoLayer: videoLayer, in: parentLayer)
        
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRangeMake(kCMTimeZero, mixComposition.duration)
        
        let videoTrack = mixComposition.tracks(withMediaType: AVMediaTypeVideo).first
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack!)
        layerInstruction.setTransform(transform(avAsset: item.sourceAsset, scaleFactor: kMediaContentDefaultScale), at: kCMTimeZero)
        
        instruction.layerInstructions = [layerInstruction]
        videoComposition.instructions = [instruction]
        
        let processedUrl = processedMoviePath()
        let result = clearTemporaryData(url: processedUrl)
        
        if result.success {
            let exportSession = AVAssetExportSession(asset: mixComposition, presetName: AVAssetExportPresetHighestQuality)
            exportSession?.videoComposition = videoComposition
            exportSession?.outputURL = processedUrl
            exportSession?.outputFileType = AVFileTypeQuickTimeMovie
            
            exportSession?.exportAsynchronously(completionHandler: {
                if exportSession?.status == AVAssetExportSessionStatus.completed {
                    completion(MediaProcessResult(processedUrl: processedUrl, image: nil), nil)
                } else {
                    completion(MediaProcessResult(processedUrl: nil, image: nil), exportSession?.error)
                }
            })
        } else {
            completion(MediaProcessResult(processedUrl: nil, image: nil), result.error)
        }
    }
    
    // MARK: - private
    private func processAndAddElements(item: MediaItem, layer: CALayer) {
        for element in item.mediaElements {
            var elementLayer: CALayer! = nil
    
            if element.type == .view {
                elementLayer = CALayer()
                elementLayer.contents = UIImage(view: element.contentView).cgImage
            } else if element.type == .image {
                elementLayer = CALayer()
                elementLayer.contents = element.contentImage.cgImage
            } else if element.type == .text {
                elementLayer = CATextLayer()
                (elementLayer as! CATextLayer).string = element.contentText
            }

            elementLayer.frame = element.frame
            layer.addSublayer(elementLayer)
        }
    }
    
    private func processedMoviePath() -> URL {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + kProcessedTemporaryVideoFileName
        return URL(fileURLWithPath: documentsPath)
    }
    
    private func clearTemporaryData(url: URL) -> (success: Bool, error: Error?) {
        if (FileManager.default.fileExists(atPath: url.path)) {
            do {
                try FileManager.default.removeItem(at: url)
                return (true, nil)
            } catch {
                return (false, error)
            }
        }
        return (true, nil)
    }
    
    private func resolutionSizeForLocalVideo(url: URL) -> CGSize {
        guard let track = AVAsset(url: url).tracks(withMediaType: AVMediaTypeVideo).first
            else {
                return CGSize.zero
        }
        let size = track.naturalSize.applying(track.preferredTransform)
        return CGSize(width: fabs(size.width), height: fabs(size.height))
    }
    
    private func transform(avAsset: AVAsset, scaleFactor: CGFloat) -> CGAffineTransform {
        let offset: CGPoint
        let angle: Double
        
        switch avAsset.contentOrientation {
        case .landscapeLeft:
            offset = CGPoint(x: avAsset.contentCorrectSize.width, y: avAsset.contentCorrectSize.height)
            angle = Double.pi
        case .landscapeRight:
            offset = CGPoint.zero
            angle = 0
        case .portraitUpsideDown:
            offset = CGPoint(x: 0, y: avAsset.contentCorrectSize.height)
            angle = -(Double.pi / 2)
        default:
            offset = CGPoint(x: avAsset.contentCorrectSize.width, y: 0)
            angle = Double.pi / 2
        }
        
        let scale = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
        let translation = scale.translatedBy(x: offset.x, y: offset.y)
        let rotation = translation.rotated(by: CGFloat(angle))
        
        return rotation
    }
}
