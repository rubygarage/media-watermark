//
//  FilterShaderParamManager.swift
//  MediaWatermark-iOS
//
//  Created by sergey on 5/10/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import MetalKit

class FilterShaderParamManager {
    class func manageParameters(fromFilter: MediaFilter, toEncoder: MTLComputeCommandEncoder, withView: MTKView) {
        if fromFilter is ColorFilter {
            let colorFilter = fromFilter as! ColorFilter
            
            var data = [CFloat(colorFilter.r), CFloat(colorFilter.g), CFloat(colorFilter.b)]
            let dataBuffer = withView.device!.makeBuffer(bytes: &data, length: MemoryLayout.stride(ofValue: data), options: [])
            toEncoder.setBuffer(dataBuffer!, offset: 0, index: 0)
        }
    }
}
