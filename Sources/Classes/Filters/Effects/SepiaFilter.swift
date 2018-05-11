//
//  SepiaFilter.swift
//  MediaWatermark-iOS
//
//  Created by sergey on 5/10/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

public class SepiaFilter: MediaFilter {
    private let kSepiaFilterName = "sepia_shader"
    
    public override init() {
        super.init()
        
        name = kSepiaFilterName
        hasCustomShader = true
    }
}

