//
//  MediaElement.swift
//  MediaWatermark
//
//  Created by Sergei on 03/05/2017.
//  Copyright © 2017 rubygarage. All rights reserved.
//

import UIKit

public enum MediaElementType {
    case image
    case view
    case text
}

public class MediaElement {
    public var frame: CGRect = .zero
    public var type: MediaElementType = .image
    
    public private(set) var contentImage: UIImage! = nil
    public private(set) var contentView: UIView! = nil
    public private(set) var contentText: NSAttributedString! = nil
    
    public init(image: UIImage) {
        contentImage = image
        type = .image
    }
    
    public init(view: UIView) {
        contentView = view
        type = .view
    }
    
    public init(text: NSAttributedString) {
        contentText = text
        type = .text
    }
}
