//
//  ColorFilter.swift
//  MediaWatermark-iOS
//
//  Created by sergey on 4/19/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import UIKit

public class ColorFilter: MediaFilter {
    private let kColorFilterName = "color_shader"
    
    public var r: CGFloat = 0.0
    public var g: CGFloat = 0.0
    public var b: CGFloat = 0.0
    
    public override init() {
        super.init()
        
        name = kColorFilterName
        hasCustomShader = true
    }
}
