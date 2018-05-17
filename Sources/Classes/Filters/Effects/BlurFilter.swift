//
//  BlurFilter.swift
//  MediaWatermark-iOS
//
//  Created by jowkame on 5/11/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import UIKit

public class BlurFilter: MediaFilter {
    private let kBlurFilterName = "blur_filter"
    private let kBlurSigmaDefaultValue: Float = 45
    
    public var sigma: Float = 0
    
    public override init() {
        super.init()
        
        sigma = kBlurSigmaDefaultValue
        name = kBlurFilterName
    }
}
