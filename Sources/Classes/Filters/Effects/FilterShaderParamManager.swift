//
//  FilterShaderParamManager.swift
//  MediaWatermark-iOS
//
//  Created by sergey on 5/10/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import Metal
import MetalKit
import MetalPerformanceShaders

class FilterConfiguration {
    var filter: MediaFilter?
    var encoder: MTLComputeCommandEncoder?
    var view: MTKView?
    var sourceTexture: MTLTexture?
    var destinationTexture: MTLTexture?
    var commandBuffer: MTLCommandBuffer?
}

class FilterShaderParamManager {
    class func manageParameters(configuration: FilterConfiguration) {
        if configuration.filter is ColorFilter {
            FilterShaderParamManager.manageColorFilterParams(configuration: configuration)
        } else if configuration.filter is BlurFilter {
            FilterShaderParamManager.manageBlurFilterParams(configuration: configuration)
        } else if configuration.filter is ThresholdFilter {
            FilterShaderParamManager.manageThresholdFilterParams(configuration: configuration)
        }
    }
    
    private class func manageColorFilterParams(configuration: FilterConfiguration) {
        let colorFilter = configuration.filter as! ColorFilter
        
        var data = [CFloat(colorFilter.r), CFloat(colorFilter.g), CFloat(colorFilter.b)]
        let dataBuffer = configuration.view!.device!.makeBuffer(bytes: &data, length: MemoryLayout.stride(ofValue: data), options: [])
        configuration.encoder!.setBuffer(dataBuffer!, offset: 0, index: 0)
    }
    
    private class func manageBlurFilterParams(configuration: FilterConfiguration) {
        let filter = configuration.filter as! BlurFilter
        
        let blurFilter = MPSImageGaussianBlur(device: configuration.view!.device!, sigma: filter.sigma)
        blurFilter.encode(commandBuffer: configuration.commandBuffer!, sourceTexture: configuration.sourceTexture!, destinationTexture: configuration.destinationTexture!)
    }
    
    private class func manageSobelFilterParams(configuration: FilterConfiguration) {        
        let sobelFilter = MPSImageSobel(device: configuration.view!.device!)
        sobelFilter.encode(commandBuffer: configuration.commandBuffer!, sourceTexture: configuration.sourceTexture!, destinationTexture: configuration.destinationTexture!)
    }
    
    private class func manageThresholdFilterParams(configuration: FilterConfiguration) {
        let filter = configuration.filter as! ThresholdFilter
        
        let thresholdFilter = MPSImageThresholdToZero(device: configuration.view!.device!, thresholdValue: filter.thresholdValue, linearGrayColorTransform: nil)
        thresholdFilter.encode(commandBuffer: configuration.commandBuffer!, sourceTexture: configuration.sourceTexture!, destinationTexture: configuration.destinationTexture!)
    }
}
