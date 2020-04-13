//
//  Assets.swift
//  MediaWatermark
//
//  Created by Sergei on 03/05/2017.
//  Copyright © 2017 rubygarage. All rights reserved.
//

import UIKit
import AVFoundation

extension AVAsset {
    private var contentNaturalSize: CGSize {
        return tracks(withMediaType: AVMediaType.video).first?.naturalSize ?? .zero
    }
    
    var contentCorrectSize: CGSize {
        return isContentPortrait ? CGSize(width: contentNaturalSize.height, height: contentNaturalSize.width) : contentNaturalSize
    }
    
    var contentOrientation: UIImage.Orientation {
        var assetOrientation = UIImage.Orientation.up
        let transform = tracks(withMediaType: AVMediaType.video)[0].preferredTransform
        
        if (transform.a == 0 && transform.b == 1.0 && transform.c == -1.0 && transform.d == 0) {
            assetOrientation = .up
        }
        
        if (transform.a == 0 && transform.b == -1.0 && transform.c == 1.0 && transform.d == 0) {
            assetOrientation = .down
        }
        
        if (transform.a == 1.0 && transform.b == 0 && transform.c == 0 && transform.d == 1.0) {
            assetOrientation = .right
        }

        if (transform.a == -1.0 && transform.b == 0 && transform.c == 0 && transform.d == -1.0) {
            assetOrientation = .left
        }
        
        return assetOrientation
    }
    
    var isContentPortrait: Bool {
        let portraits: [UIImage.Orientation] = [.left, .right]
        return portraits.contains(contentOrientation)
    }
}
