//
//  ThresholdFilter.swift
//  MediaWatermark-iOS
//
//  Created by jowkame on 5/11/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import UIKit

public class ThresholdFilter: MediaFilter {
    private let kThresholdFilterName = "threshold_filter"
    private let kDefaultThresholdValue: Float = 0.5
    
    public var thresholdValue: Float = 0
    
    public override init() {
        super.init()
        
        name = kThresholdFilterName
        thresholdValue = kDefaultThresholdValue
    }
}
