//
//  SobelFilter.swift
//  MediaWatermark-iOS
//
//  Created by sergey on 5/11/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import UIKit

public class SobelFilter: MediaFilter {
    private let kSobelFilterName = "sobel_filter"
    
    public override init() {
        super.init()
        
        name = kSobelFilterName
    }
}
