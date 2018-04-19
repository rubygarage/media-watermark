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
    
    init() {
        mDevice = MTLCreateSystemDefaultDevice()
        mLibrary = mDevice?.makeDefaultLibrary()
        mCommandQueue = mDevice?.makeCommandQueue()
        mTextureLoader = MTKTextureLoader(device: mDevice!)
    }
}
