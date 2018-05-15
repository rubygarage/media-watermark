//
//  MediaItemImage.swift
//  MediaWatermark
//
//  Created by Sergei on 03/05/2017.
//  Copyright © 2017 rubygarage. All rights reserved.
//

import UIKit

extension MediaProcessor {
    func processImageWithElements(item: MediaItem, completion: @escaping ProcessCompletionHandler) {
        if item.filter != nil {
            filterProcessor = FilterProcessor(mediaFilter: item.filter)
            filterProcessor.processImage(image: item.sourceImage.fixedOrientation(), completion: { [weak self] (success, finished, image, error) in
                if error != nil {
                    completion(MediaProcessResult(processedUrl: nil, image: nil), error)
                } else if image != nil && finished == true {
                    completion(MediaProcessResult(processedUrl: nil, image: image), nil)

                    let updatedMediaItem = MediaItem(image: image!)
                    updatedMediaItem.add(elements: item.mediaElements)
                    self?.processItemAfterFiltering(item: updatedMediaItem, completion: completion)
                }
            })
            
        } else {
            processItemAfterFiltering(item: item, completion: completion)
        }
    }
    
    func processItemAfterFiltering(item: MediaItem, completion: @escaping ProcessCompletionHandler) {
        UIGraphicsBeginImageContextWithOptions(item.sourceImage.size, false, item.sourceImage.scale)
        item.sourceImage.draw(in: CGRect(x: 0, y: 0, width: item.sourceImage.size.width, height: item.sourceImage.size.height))
        
        for element in item.mediaElements {
            if element.type == .view {
                UIImage(view: element.contentView).draw(in: element.frame)
            } else if element.type == .image {
                element.contentImage.draw(in: element.frame)
            } else if element.type == .text {
                element.contentText.draw(in: element.frame)
            }
        }
        
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        completion(MediaProcessResult(processedUrl: nil, image: newImage), nil)
    }
}
