//
//  MediaItem.swift
//  MediaWatermark
//
//  Created by Sergei on 03/05/2017.
//  Copyright © 2017 rubygarage. All rights reserved.
//

import UIKit
import AVFoundation

enum MediaItemType {
    case image
    case video
}

public struct MediaProcessResult {
    public var processedUrl: URL?
    public var image: UIImage?
}

public typealias ProcessCompletionHandler = ((_ result: MediaProcessResult, _ error: Error?) -> ())

public class MediaItem {
    var type: MediaItemType {
        return sourceAsset != nil ? .video : .image
    }
    
    public var size: CGSize {
        get {
            if sourceAsset != nil {
                if let track = AVAsset(url: sourceAsset.url).tracks(withMediaType: AVMediaType.video).first {
                    let size = track.naturalSize.applying(track.preferredTransform)
                    return CGSize(width: abs(size.width), height: abs(size.height))
                } else {
                    return CGSize.zero
                }
            } else if sourceImage != nil {
                return sourceImage.size
            }
            
            return CGSize.zero
        }
    }
    
    public private(set) var sourceAsset: AVURLAsset! = nil
    public private(set) var sourceImage: UIImage! = nil
    public private(set) var mediaElements = [MediaElement]()
    public private(set) var filter: MediaFilter! = nil

    // MARK: - init
    public init(asset: AVURLAsset) {
        sourceAsset = asset
    }
    
    public init(image: UIImage) {
        sourceImage = image
    }
    
    public init?(url: URL) {
        if urlHasImageExtension(url: url) {
            do {
                let data = try Data(contentsOf: url)
                sourceImage = UIImage(data: data)
            } catch {
                return nil
            }
        } else {
            sourceAsset = AVURLAsset(url: url)
        }
    }
    
    // MARK: - elements
    public func add(element: MediaElement) {
        mediaElements.append(element)
    }
    
    public func add(elements: [MediaElement]) {
        mediaElements.append(contentsOf: elements)
    }
    
    public func removeAllElements() {
        mediaElements.removeAll()
    }
    
    // MARK: - filters
    public func applyFilter(mediaFilter: MediaFilter) {
        filter = mediaFilter
    }
    
    // MARK: - private
    private func urlHasImageExtension(url: URL) -> Bool {
        let imageExtensions = ["png", "jpg", "gif"]
        return imageExtensions.contains(url.pathExtension)
    }
}
