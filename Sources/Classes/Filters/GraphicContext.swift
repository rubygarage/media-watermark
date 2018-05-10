//
//  GraphicContext.swift
//  MediaWatermark-iOS
//
//  Created by sergey on 4/19/18.
//  Copyright © 2018 RubyGarage. All rights reserved.
//

import Foundation
import Metal
import MetalKit

public class GraphicContext {
    var mLibrary: MTLLibrary?
    var mDevice: MTLDevice?
    var mCommandQueue: MTLCommandQueue?
    var mTextureLoader: MTKTextureLoader?
    var mediaFilter: MediaFilter?
    
    init(mediaFilter: MediaFilter) {
        mDevice = MTLCreateSystemDefaultDevice()
        
        let shaderSource = FilterShaderProvider.provideShader(filter: mediaFilter)
        do {
            try mLibrary = mDevice?.makeLibrary(source: shaderSource, options: nil)
            mCommandQueue = mDevice?.makeCommandQueue()
            mTextureLoader = MTKTextureLoader(device: mDevice!)
        }
        catch {
            print(error)
        }      
    }
}
