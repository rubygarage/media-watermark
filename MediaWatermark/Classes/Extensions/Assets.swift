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
        return tracks(withMediaType: AVMediaTypeVideo).first?.naturalSize ?? .zero
    }
    
    var contentCorrectSize: CGSize {
        return isContentPortrait ? CGSize(width: contentNaturalSize.height, height: contentNaturalSize.width) : contentNaturalSize
    }
    
    var contentOrientation: UIInterfaceOrientation {
        guard let transform = tracks(withMediaType: AVMediaTypeVideo).first?.preferredTransform else {
            return .portrait
        }
        
        switch (transform.tx, transform.ty) {
        case (0, 0):
            return .landscapeRight
        case (contentNaturalSize.width, contentNaturalSize.height):
            return .landscapeLeft
        case (0, contentNaturalSize.width):
            return .portraitUpsideDown
        default:
            return .portrait
        }
    }
    
    var isContentPortrait: Bool {
        let portraits: [UIInterfaceOrientation] = [.portrait, .portraitUpsideDown]
        return portraits.contains(contentOrientation)
    }
}
